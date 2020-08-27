-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-25
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 30 Aug 2019 Rebecca	Modify to sum from ms.AccountMeta currency
-- 18 May 2020 Rebecca	Modify to sum for chatapps
-- 10 Jun 2020 Anton	CA billing data added
-- =============================================
-- EXEC cp.[job_Campaign_Delivered_Update]
-- SELECT TOP 100 * FROM cp.CmCampaign ORDER BY CampaignId DESC
-- SELECT TOP 100 * FROM cp.CmCampaignSummary ORDER BY CampaignId DESC

CREATE PROCEDURE [cp].[job_Campaign_Delivered_Update]
AS
BEGIN
	DECLARE @CampaignId int ;
	DECLARE @SubAccountId varchar(50), @SubAccountUid INT, @Product varchar(10) ;
	DECLARE @StartTime datetime2(2), @EndTime datetime2(2), @ScheduledAt datetime ;
	DECLARE @PriceCurrency char(3);
	DECLARE @CostCurrency char(3) = 'USD';	-- Constant for now. It's not clear, what is a official currency of CA provider

	DECLARE @SumL1 TABLE (
		Date DATE,
		ChannelTypeId TINYINT,
		MsgTotal INT, MsgDelivered INT, MsgRejected INT, MsgRead INT, MsgCharged INT, 
		SmsTotal INT, SmsDelivered INT, SmsRejected INT, SmsCharged INT,
		PriceCurrency CHAR(3), Price DECIMAL(19,7), 
		CostCurrency CHAR(3), Cost DECIMAL(19,7), 
		CompletedAt DATETIME2(2)) ;

	DECLARE @SumL2 TABLE (
		ChannelTypeId TINYINT,
		MsgTotal INT, MsgDelivered INT, MsgRejected INT, MsgRead INT, MsgCharged INT, 
		PriceCurrency CHAR(3), Price DECIMAL(19,7), 
		PriceUSD DECIMAL(12,6), CostUSD DECIMAL(12,6)) ;

	DECLARE task_cursor CURSOR LOCAL FOR
		SELECT c.CampaignId, c.SubAccountId, c.SubAccountUid, c.Product, c.ScheduledAt, am.Currency
		FROM cp.CmCampaign c WITH (NOLOCK)
			INNER JOIN cp.Account a ON c.AccountUid = a.AccountUid
			INNER JOIN ms.AccountMeta am ON am.AccountId = a.AccountId
		WHERE 
			c.CampaignStatusId IN (4 /* SENDING */, 8 /* COMPLETED */)
			AND c.ScheduledAt < SYSUTCDATETIME() -- ignore future campaigns
			--AND MsgDelivered + MsgError + MsgRejected < MsgTotal -- ignore completed campaigns
			-- timeframe for update
			AND (ScheduledAt > DATEADD(MINUTE, -120, SYSUTCDATETIME())
					OR (ScheduledAt > DATEADD(HOUR, -48, SYSUTCDATETIME()) AND MsgTotal > 100000)) ; 

	OPEN task_cursor ;

	FETCH NEXT FROM task_cursor INTO @CampaignId, @SubAccountId, @SubAccountUid, @Product, @ScheduledAt, @PriceCurrency ;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @StartTime = DATEADD(MINUTE, -20, @ScheduledAt) ;
		SET @EndTime = DATEADD(MINUTE, 40, @ScheduledAt) ;

		DELETE @SumL1 ; -- clear the temp table
		DELETE @SumL2 ; -- clear the temp table

		--- Aggregate CA Logs -----
		IF @Product = 'CA'
		BEGIN
			/* v2 */
			WITH stat AS 
			(
     			SELECT 
					CAST(CreatedAt AS DATE) AS Date, -- TODO: timestamp of DeliveredAt is more accurate
					ChannelUid AS ChannelTypeId, 
					ContentTypeId, 
					Country,
					COUNT(1) MsgTotal,
					SUM(CASE WHEN StatusId IN (40, 50) THEN 1 ELSE 0 END) AS MsgDelivered, /* Delivered + Read */
					SUM(CASE WHEN StatusId = 21 THEN 1 ELSE 0 END) AS MsgRejected,
					SUM(CASE WHEN StatusId = 50 THEN 1 ELSE 0 END) AS MsgRead,
					SUM(CASE WHEN Chargable = 1 THEN 1 ELSE 0 END) AS MsgCharged,
					MAX(CreatedAt) AS CompletedAt
				--SELECT *
				FROM sms.IpmLog WITH (NOLOCK, INDEX(IX_IpmLog_SubAccount_CreatedAt))
				WHERE CreatedAt >= @StartTime
					AND CreatedAt < DATEADD(MINUTE, 120, @ScheduledAt) -- CA campaigns are processed slower that SMS
					AND SubAccountUid = @SubAccountUid
					AND Direction = 1	-- not required condition, but prefered for accuracy
					AND BatchId IN (SELECT BatchId FROM cp.CmCampaignBatchIds WITH (NOLOCK)
														WHERE CampaignId = @CampaignId)
				GROUP BY ChannelUid, ContentTypeId, CAST(CreatedAt AS DATE), Country    
			 ),
			 pricing AS (
				SELECT
					IIF(ppc.PeriodStart < ppsa.PeriodStart, ppsa.PeriodStart, ppc.PeriodStart) AS PeriodStart, 
					IIF(ppc.PeriodEnd > ppsa.PeriodEnd, ppsa.PeriodEnd, ppc.PeriodEnd) AS PeriodEnd, 
					ppc.ChannelTypeId, ppc.ContentTypeCode, ppc.Country, ppc.Currency, ppc.Price AS UnitPrice
				FROM ipm.PricingPlanSubAccount AS ppsa (NOLOCK)
					INNER JOIN ipm.PricingPlanCoverage AS ppc (NOLOCK) 
						ON ppsa.PricingPlanId = ppc.PricingPlanId
							AND (ppsa.PeriodStart BETWEEN ppc.PeriodStart AND ppc.PeriodEnd
								OR ppsa.PeriodEnd BETWEEN ppc.PeriodStart AND ppc.PeriodEnd)
				WHERE ppsa.SubAccountUid = @SubAccountUid 
					AND ppsa.PeriodStart <= @EndTime
					AND ppsa.PeriodEnd >= @StartTime
					AND ppc.PeriodStart <= @EndTime
					AND ppc.PeriodEnd >= @StartTime
			),
			costing AS (
				SELECT
					cpc.PeriodStart, 
					cpc.PeriodEnd, 
					cpc.ChannelTypeId, cpc.ContentTypeCode, cpc.Country, cpc.Currency, cpc.Cost AS UnitCost
				FROM ipm.CostPlanCoverage AS cpc (NOLOCK) 
				WHERE cpc.CostPlanId = 1 /* hardcoded for now, solution is not finilized yet */
					AND cpc.VolumeStart = 0 /* TODO: add Tier supporting in future somehow */
			)
			INSERT INTO @SumL1 (
				Date, 
				ChannelTypeId,
				MsgTotal, MsgDelivered, MsgRejected, MsgRead, MsgCharged,
				SmsTotal, SmsDelivered, SmsRejected, SmsCharged,
				PriceCurrency, Price, 
				CostCurrency, Cost, 
				CompletedAt)
			SELECT
				stat.Date,
				stat.ChannelTypeId,
				SUM(MsgTotal) AS MsgTotal, 
				SUM(MsgDelivered) AS MsgDelivered, 
				SUM(MsgRejected) AS MsgRejected,
				SUM(MsgRead) AS MsgRead,
				SUM(MsgCharged) AS MsgCharged,
				SUM(MsgTotal) AS SmsTotal, 
				SUM(MsgDelivered) AS SmsDelivered, 
				SUM(MsgRejected) AS SmsRejected,
				SUM(MsgCharged) AS SmsCharged,
				pricing.Currency AS PriceCurrency, 
				SUM(stat.MsgCharged * ISNULL(pricing.UnitPrice,0)) AS Price, 
				costing.Currency AS CostCurrency, 
				SUM(stat.MsgCharged * ISNULL(costing.UnitCost,0))  AS Cost, 
				MAX(CompletedAt) AS CompletedAt
			FROM stat
				INNER JOIN sms.DimContentType ct ON stat.ContentTypeId = ct.ContentTypeId
				LEFT JOIN pricing ON 
					stat.ChannelTypeId = pricing.ChannelTypeId 
					AND ct.ContentTypePricing = pricing.ContentTypeCode
					AND stat.Country = pricing.Country
					AND stat.Date >= pricing.PeriodStart
					AND stat.Date < pricing.PeriodEnd
				LEFT JOIN costing ON 
					stat.ChannelTypeId = costing.ChannelTypeId 
					AND ct.ContentTypePricing = costing.ContentTypeCode
					AND stat.Country = costing.Country
					AND stat.Date >= costing.PeriodStart
					AND stat.Date < costing.PeriodEnd
			GROUP BY stat.Date, stat.ChannelTypeId, pricing.Currency, costing.Currency

			-- troubleshooting
			--SELECT * FROM @SumL1

			/* v1
			INSERT INTO @SumL1 (MsgTotal, MsgDelivered, MsgRejected, PriceCurrency, Price, CostCurrency, Cost, CompletedAt)
			SELECT MsgTotal, MsgDelivered, MsgRejected,	ContractCurrency, Price, ContractCurrency, Cost, CompletedAt
			FROM
				(SELECT ContractCurrency,
						COUNT(1) MsgTotal,
						SUM(CASE WHEN Direction = 1 AND [StatusId] = 40 THEN 1 ELSE 0 END) MsgDelivered,
						SUM(CASE WHEN Direction = 1 AND [StatusId] = 21 THEN 1 ELSE 0 END) MsgRejected,
						--MsgRead = SUM(CASE WHEN Direction = 1 AND [StatusId] = 50 THEN 1 ELSE 0 END),
						SUM(ChannelCostContract) Cost,
						SUM(CASE WHEN Direction = 1
									AND (StatusId = 40 OR StatusId = 50)
									AND ((ChannelUid = 1 AND InitSession = 1) --whatsapp
										OR ChannelUid = 5 -- viber
										OR ChannelUid = 6) -- line
								THEN MessageFeeContract
								ELSE 0
								END) AS Price,
						MAX(CreatedAt) AS CompletedAt
				FROM sms.IpmLog WITH (NOLOCK)
				WHERE CreatedAt >= @StartTime
					AND CreatedAt < DATEADD(MINUTE, 120, @ScheduledAt) -- CA campaigns are processed slower that SMS
					AND SubAccountUid = (SELECT SubAccountUid FROM ms.SubAccount WHERE SubAccountId = @SubAccountId)
					AND BatchId IN (SELECT BatchId FROM cp.CmCampaignBatchIds WITH (NOLOCK)
														WHERE CampaignId = @CampaignId)
				GROUP BY ContractCurrency
				) l ;
			*/
		END ;

		IF @Product IN ('CA', 'SMS')
		BEGIN
			-- quering even for chatapps because SMS may be configured as fallback or could have been configured as fallback
			INSERT INTO @SumL1
				(Date, ChannelTypeId, MsgTotal, MsgDelivered, MsgRejected, MsgRead, MsgCharged, SmsTotal, SmsDelivered, SmsRejected, SmsCharged, PriceCurrency, Price, CostCurrency, Cost, CompletedAt)
			SELECT
				CAST(CreatedTime AS DATE) AS Date, 
				0 AS ChannelTypeId, -- SMS
				COUNT(1) MsgTotal,
				SUM(CASE WHEN StatusId IN (40, 30 , 50) THEN 1 ELSE 0 END) MsgDelivered, /* Delivered Carrier + Delivered Handset + Read */
				SUM(CASE WHEN StatusId = 21 THEN 1 ELSE 0 END) MsgRejected,
				SUM(CASE WHEN StatusId = 50 THEN 1 ELSE 0 END) MsgRead,
				SUM(CASE WHEN PriceContractPerSms > 0 THEN 1 ELSE 0 END) MsgCharged,
				SUM(SegmentsReceived) SmsTotal,
				SUM(CASE WHEN StatusId IN (40, 30, 50) THEN SegmentsReceived ELSE 0 END) SmsDelivered,
				SUM(CASE WHEN StatusId = 21 THEN SegmentsReceived ELSE 0 END) SmsRejected,
				SUM(CASE WHEN PriceContractPerSms > 0 THEN SegmentsReceived ELSE 0 END) SmsCharged,
				PriceContractCurrency,
				SUM(SegmentsReceived * PriceContractPerSms) AS Price,
				CostContractCurrency,
				SUM(SegmentsReceived * CostContractPerSms) AS Cost,
				MAX(CreatedTime) AS CompletedAt
			FROM sms.SmsLog WITH (NOLOCK)
			WHERE SubAccountId = @SubAccountId
				AND CreatedTime >= @StartTime
				AND CreatedTime < @EndTime
				--AND SmsTypeId = 1 condition is not mandatory, cause MO SMS is not expected with not-null BatchId
				AND BatchId IN (SELECT BatchId FROM cp.CmCampaignBatchIds WITH (NOLOCK)
								WHERE CampaignId = @CampaignId)
			GROUP BY CAST(CreatedTime AS DATE), PriceContractCurrency, CostContractCurrency ;
		END;

		IF EXISTS (SELECT 1 FROM @SumL1)
		BEGIN

			-- update root table cp.CmCampaign
			UPDATE c
			SET
				MsgTotal = IIF(ISNULL(s.MsgTotal, 0) + MsgError > c.MsgTotal, ISNULL(s.MsgTotal, 0) + MsgError, c.MsgTotal),	-- overwrite only if value becomes higher than initial amount, set by CP itself
				MsgDelivered = ISNULL(s.MsgDelivered, 0),
				MsgRejected = ISNULL(s.MsgRejected, 0),
				SmsTotal = IIF(ISNULL(s.SmsTotal, 0) + SmsError > c.SmsTotal, ISNULL(s.SmsTotal, 0) + SmsError, c.SmsTotal),	-- overwrite only if value becomes higher than initial amount, set by CP itself
				SmsDelivered = ISNULL(s.SmsDelivered, 0),
				SmsRejected = ISNULL(s.SmsRejected, 0),
				SmsCharged = ISNULL(s.SmsCharged, 0),
				PriceCurrency = @PriceCurrency,
				Price = ISNULL(s.Price, 0),
				CostUSD = ISNULL(s.CostUSD, 0),
				PriceUSD = ISNULL(s.PriceUSD, 0),
				CompletedAt = s.CompletedAt
				-- for future implementation - to track Completed/processed campaign status
				--CampaignStatusId = IIF(c.CompletedAt = s.CompletedAt, 8 /* Completed */, c.CampaignStatusId /* keep current status */)
			FROM cp.CmCampaign c,
				(SELECT 
					SUM(MsgTotal) MsgTotal,
					SUM(MsgDelivered) MsgDelivered,
					SUM(MsgRejected) MsgRejected,
					SUM(SmsTotal) SmsTotal,
					SUM(SmsDelivered) SmsDelivered,
					SUM(SmsRejected) SmsRejected,
					SUM(SmsCharged) SmsCharged,
					SUM(ISNULL(Price,0)) Price, 
					SUM(ISNULL(CostUSD,0)) CostUSD, 
					SUM(ISNULL(PriceUSD,0)) PriceUSD,
					MAX(CompletedAt) AS CompletedAt
				FROM
					(SELECT
						SUM(MsgTotal) MsgTotal,
						SUM(MsgDelivered) MsgDelivered,
						SUM(MsgRejected) MsgRejected,
						SUM(SmsTotal) SmsTotal,
						SUM(SmsDelivered) SmsDelivered,
						SUM(SmsRejected) SmsRejected,
						SUM(SmsCharged) SmsCharged,
						mno.CurrencyConverter(SUM(Price), PriceCurrency, @PriceCurrency, @ScheduledAt) Price,
						mno.CurrencyConverter(SUM(Cost), CostCurrency, 'USD', @ScheduledAt) CostUSD,
						mno.CurrencyConverter(SUM(Price), PriceCurrency, 'USD', @ScheduledAt) PriceUSD,
						MAX(CompletedAt) CompletedAt
					FROM @SumL1
					GROUP BY PriceCurrency, CostCurrency
					) ss
				) s
			WHERE c.CampaignId = @CampaignId ;	
		
			-- update table cp.CmCampaignSummary
			INSERT @SumL2 (ChannelTypeId, MsgTotal, MsgDelivered, MsgRejected, MsgRead, MsgCharged, PriceCurrency, Price, PriceUSD, CostUSD)
			SELECT 
				ChannelTypeId, 
				SUM(MsgTotal) AS MsgTotal, 
				SUM(MsgDelivered) AS MsgDelivered, 
				SUM(MsgRejected) AS MsgRejected, 
				SUM(MsgRead) MsgRead, 
				SUM(MsgCharged) MsgCharged, 
				@PriceCurrency AS PriceCurrency, 
				SUM(ISNULL(mno.CurrencyConverter(Price, PriceCurrency, @PriceCurrency, Date), 0)) Price,
				SUM(ISNULL(mno.CurrencyConverter(Price, PriceCurrency, 'USD', Date), 0)) PriceUSD,
				SUM(ISNULL(mno.CurrencyConverter(Cost,  CostCurrency,  'USD', Date), 0)) CostUSD
			FROM @SumL1 s
			GROUP BY ChannelTypeId;

			-- MERGE changes from @SumL2 into cp.CmCampaignSummary by 2 queries (UPSERT)
			UPDATE cs
			SET
				MsgTotal = s.MsgTotal,
				MsgDelivered = s.MsgDelivered,
				MsgRejected = s.MsgRejected,
				PriceCurrency = @PriceCurrency,
				Price = s.Price,
				CostUSD = s.CostUSD,
				PriceUSD = s.PriceUSD
			FROM cp.CmCampaignSummary cs
				INNER JOIN @SumL2 s ON cs.CampaignId = @CampaignId AND cs.ChannelTypeId = s.ChannelTypeId

			INSERT INTO cp.CmCampaignSummary (CampaignId, ChannelTypeId, MsgTotal, MsgDelivered, MsgRejected, MsgRead, MsgCharged, PriceCurrency, Price, PriceUSD, CostUSD)
			SELECT @CampaignId AS CampaignId, ChannelTypeId, MsgTotal, MsgDelivered, MsgRejected, MsgRead, MsgCharged, PriceCurrency, Price, PriceUSD, CostUSD
			FROM @SumL2 s
			WHERE NOT EXISTS (SELECT 1 FROM cp.CmCampaignSummary WHERE CampaignId = @CampaignId AND ChannelTypeId = s.ChannelTypeId)

		END
		FETCH NEXT FROM task_cursor	INTO @CampaignId, @SubAccountId, @SubAccountUid, @Product, @ScheduledAt, @PriceCurrency ;
	END ;

	CLOSE task_cursor;
	DEALLOCATE task_cursor;
END
