-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-24
-- Updated By:  Nathanael Hinay
-- Date Updated:2019-06-01
-- Changes: Add ReviewedBy and ReviewedAt on return data
-- =============================================
-- EXEC [cp].[CmCampaign_GetMany] @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @UserId = '2A793B40-1E23-47F4-9A95-7662822EE5DB', @OutputTotals = 1
-- EXEC [cp].[CmCampaign_GetMany] @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @UserId = '2A793B40-1E23-47F4-9A95-7662822EE5DB', @OutputTotals = 1, @DateFrom = '2020-01-01'
CREATE PROCEDURE [cp].[CmCampaign_GetMany]
	@AccountUid uniqueidentifier,		-- filter
	@UserId uniqueidentifier = NULL,	-- filter
	@CampaignType varchar(6) = NULL,	-- filter: NULL(any) / 'basic' / 'survey'
	@ScheduledFrom datetime = NULL,		-- DEPRECATED
	@ScheduledTill datetime = NULL,		-- DEPRECATED
	@DateFrom datetime = NULL,			-- filter by Campaign Created, default -14 days
	@DateTill datetime = NULL,			-- filter by Campaign Created, default now
	@CampaignStatusId tinyint = NULL,	-- filter on CampaignStatus (see table cp.CmCampaignStatus)
	@Product varchar(3) = NULL, -- SMS, CA etc
	@Offset int = 0,		-- pagination
	@Limit int = 200,		-- pagination
	@OutputTotals bit = 0	-- pagination
AS
BEGIN
	DECLARE @Total int = 0 ;

	-- DEPRECATED, TO remove after next release (in April 2020)
	SET @ScheduledFrom = ISNULL(@ScheduledFrom, DATEADD(DAY, -14, CAST(GETUTCDATE() as date))) ;
	SET @ScheduledTill = ISNULL(@ScheduledTill, GETUTCDATE()) ;

	-- fitler by Campaign Created
	SET @DateFrom = ISNULL(@DateFrom, DATEADD(DAY, -14, CAST(GETUTCDATE() as date))) ;
	SET @DateTill = ISNULL(@DateTill, GETUTCDATE()) ;

	-- main query
	SELECT 
		cm.CampaignId, cm.CampaignName, 
		cm.CampaignStatusId, st.CampaignStatusName,
		cm.TemplateBody, cm.TemplateSenderId, cm.TemplateId, cm.CampaignType,
        cm.ReviewedBy, cm.ReviewedAt, cm.RejectionMsg,
        ua.Login as ReviewedByLogin,
		-- counters
		cm.SmsTotal, cm.SmsDelivered, 
		cm.SmsError + cm.SmsRejected AS SmsError, 
		cm.SmsTotal - cm.SmsDelivered - cm.SmsRejected - cm.SmsError AS SmsUndelivered,
		cm.MsgTotal, cm.MsgDelivered, 
		cm.MsgError + cm.MsgRejected AS MsgError, 
		cm.MsgTotal - cm.MsgDelivered - cm.MsgRejected - cm.MsgError AS MsgUndelivered,
		cm.MsgClicked, cm.MsgResponded, 
		cm.Price, cm.PriceCurrency,
		cm.CreatedAt, cm.CreatedBy, 
		cm.ScheduledAt,
		u.Login as CreatedBy_Username,
		cm.SubAccountUid,
		sa.SubAccountId,
		cm.Product,
		cm.ChannelType,
		cm.ClientMessageId,
		cm.CampaignMeta
	FROM cp.CmCampaign cm
		LEFT JOIN cp.CmCampaignStatus st ON cm.CampaignStatusId = st.CampaignStatusId
		LEFT JOIN cp.[User] u ON cm.CreatedBy = u.UserId
		LEFT JOIN ms.SubAccount sa ON sa.SubAccountUid = cm.SubAccountUid
        LEFT JOIN cp.[User] ua ON cm.ReviewedBy = ua.UserId
		-- Get accessible subaccounts
		INNER JOIN cp.fnSubAccount_GetByUser (@AccountUid, @UserId, NULL, NULL, NULL, NULL, NULL) su 
			ON su.SubAccountUid = cm.SubAccountUid
	WHERE cm.AccountUid = @AccountUid AND cm.DeletedAt IS NULL
		AND cm.CreatedAt BETWEEN @DateFrom AND @DateTill
		--was replaced by fitler on CreatedAt: AND cm.ScheduledAt BETWEEN @ScheduledFrom AND @ScheduledTill
		AND (@CampaignStatusId IS NULL OR (@CampaignStatusId IS NOT NULL AND cm.CampaignStatusId = @CampaignStatusId))
		AND (@CampaignType IS NULL OR (@CampaignType IS NOT NULL AND cm.CampaignType = @CampaignType))
		AND (@Product IS NULL OR cm.Product = @Product)
	ORDER BY cm.CampaignId DESC
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY ;

	SET @Total = @@ROWCOUNT ;

	-- Get totals
	IF @OutputTotals = 1
		SELECT @Total AS TotalCampaignsActive ;
/*
		SELECT COUNT(1) AS TotalCampaignsActive
		FROM cp.CmCampaign cm
		WHERE cm.AccountUid = @AccountUid AND cm.DeletedAt IS NULL
			AND cm.ScheduledAt BETWEEN @ScheduledFrom AND @ScheduledTill
			AND (@CampaignStatusId IS NULL OR (@CampaignStatusId IS NOT NULL AND cm.CampaignStatusId = @CampaignStatusId))
			AND (@CampaignType IS NULL OR (@CampaignType  IS NOT NULL AND cm.CampaignType = @CampaignType))
			-- filter by allowed subaccounts for user
			AND (@LimitSubAccounts = 0 OR (@LimitSubAccounts = 1 AND
				cm.SubAccountUid IN (SELECT SubAccountUid FROM cp.UserSubAccount usa WHERE usa.UserId = @UserId)))
			AND (@Product IS NULL OR cm.Product = @Product) ;
*/
END
