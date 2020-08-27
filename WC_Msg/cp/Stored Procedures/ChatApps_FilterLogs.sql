-- =============================================
-- Author:		Rebecca
-- Create date: 2019-10-01
-- Usage : cp.ChatApps_FilterLogs @SubAccountUid=6716, @FromDate='2019-09-01', @ToDate='2019-09-14', @ChannelId='WA', @PageForward = 0
-- =============================================
CREATE PROCEDURE [cp].[ChatApps_FilterLogs]
	@SubAccountUid int,
	@ChannelId char(2) = NULL, -- 2 char abbrev
	@Status varchar(30) = NULL, -- optional. Can be a single char or a comma-delimited string of status
	@FromDate datetime,
	@ToDate datetime,
	@CampaignId int = NULL,
	@UMID uniqueidentifier = NULL,
	@Country char(2) = NULL,
	@MSISDN bigint = NULL,
	@PageForward bit = 1, --direction of pagination, 1 for forward, 0 for backwards
	@PageCursor datetime = NULL, -- the value of SentAt at which to start searching for records onwards
	@PageLimit int = 1000 -- no of records to fetch
AS
BEGIN
	DECLARE @ChannelTypeId tinyint ;
	DECLARE @BatchId TABLE (BatchId uniqueidentifier) ;
	
	IF @ChannelId IS NOT NULL
		SELECT @ChannelTypeId = ChannelTypeId FROM ipm.ChannelType WITH (NOLOCK) WHERE ChannelId = @ChannelId ;

	IF @CampaignId IS NOT NULL
		INSERT INTO @BatchId
		SELECT BatchId FROM cp.CmCampaignBatchIds WHERE CampaignId = @CampaignId ;

	--IF @Forward = 1 -- forward
	--	SELECT	TOP (@Limit)
	--			UMID,
	--			Ch.ChannelType Channel,
	--			a.SubAccountId,
	--			IIF(Direction = 0, 'Incoming', 'Outgoing') Direction,
	--			L.StatusId,
	--			ms.[Status],
	--			L.Country,
	--			MSISDN,
	--			L.CreatedAt [SentAt],
	--			DeliveredAt,
	--			ReadAt,
	--			L.UpdatedAt
	--	FROM sms.IpmLog L WITH (NOLOCK)
	--		LEFT JOIN dbo.Account a WITH (NOLOCK)
	--			ON L.SubAccountUid = a.SubAccountUid
	--		LEFT JOIN ipm.ChannelType Ch WITH (NOLOCK)
	--			ON L.ChannelUid = Ch.ChannelUid
	--		LEFT JOIN sms.DimSmsStatus ms WITH (NOLOCK)
	--			ON L.StatusId = ms.StatusId
	--	WHERE L.CreatedAt >= @FromDate
	--		AND L.CreatedAt < @ToDate
	--		AND (@Cursor IS NULL OR L.CreatedAt > @Cursor)
	--		AND L.SubAccountUid = @SubAccountUid
	--		AND (@ChannelUId IS NULL OR L.ChannelUid = @ChannelUid)
	--		AND (@Status IS NULL OR L.StatusId IN (SELECT item FROM dbo.SplitString(@Status, ',')))
	--	ORDER BY L.CreatedAt ;
	--ELSE -- going backwards
		SELECT * FROM
			(SELECT	TOP (@PageLimit)
					UMID,
					Ch.ChannelTypeName AS Channel,
					sa.SubAccountId,
					IIF(Direction = 0, 'Incoming', 'Outgoing') AS Direction,
					L.StatusId,
					ms.[Status],
					L.Country,
					MSISDN,
					ClientMessageId,
					L.CreatedAt [SentAt],
					DeliveredAt,
					ReadAt,
					L.UpdatedAt
			FROM sms.IpmLog L WITH (NOLOCK)
				LEFT JOIN ms.SubAccount sa WITH (NOLOCK)
					ON L.SubAccountUid = sa.SubAccountUid
				LEFT JOIN ipm.ChannelType Ch WITH (NOLOCK)
					ON L.ChannelUid = Ch.ChannelTypeId
				LEFT JOIN sms.DimSmsStatus ms WITH (NOLOCK)
					ON L.StatusId = ms.StatusId
			WHERE L.CreatedAt >= @FromDate
				AND L.CreatedAt < @ToDate
				AND (@CampaignId IS NULL OR L.BatchId IN (SELECT BatchId FROM @BatchId))
				AND (@PageCursor IS NULL OR 
						(@PageForward = 0 AND L.CreatedAt < @PageCursor) OR
						(@PageForward = 1 AND L.CreatedAt > @PageCursor)
					)
				AND L.SubAccountUid = @SubAccountUid
				AND (@ChannelTypeId IS NULL OR L.ChannelUid = @ChannelTypeId)
				AND (@Status IS NULL OR L.StatusId IN (SELECT item FROM dbo.SplitString(@Status, ',')))
				AND (@UMID IS NULL OR L.UMID = @UMID)
				AND (@Country IS NULL OR L.Country = @Country)
				AND (@MSISDN IS NULL OR L.MSISDN = @MSISDN)
			ORDER BY 
				-- https://stackoverflow.com/questions/3884884/conditional-sql-order-by-asc-desc-for-alpha-columns
				CASE WHEN @PageForward = 1 THEN L.CreatedAt ELSE '' END ASC,
				CASE WHEN @PageForward = 0 THEN L.CreatedAt ELSE '' END DESC
			) ll
		ORDER BY SentAt ;
END
