-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-08-14
-- =============================================
-- EXEC cp.SmsLog_UrlShortenDownload @AccountUid = '2318BDEB-C250-E711-8141-06B9B96CA965', @UserId = '2EDC4963-8E94-4999-BEBD-04BBCBF3E7BB', @SubAccountId = 'PRAKSMOL-4yY8D_hq', @BaseUrlId = 168,  @TimeFrom = '2018-07-25', @TimeTill = '2018-08-31', @PageSize = 10000
CREATE PROCEDURE [cp].[SmsLog_UrlShortenDownload]
	@AccountUid uniqueidentifier,
    @UserId uniqueidentifier,
	@SubAccountId varchar(50),
	@BaseUrlId int,
	@TimeFrom smalldatetime,
	@TimeTill smalldatetime,
	@PageOffset int = 0,
	@PageSize int = 10000
WITH EXECUTE AS OWNER
AS
BEGIN

	-- access check
	EXEC cp.User_CheckPermissions @AccountUid = @AccountUid, @UserId = @UserId, @SubAccountId = @SubAccountId

	-- validate params
	IF @PageSize < 1		SET @PageSize = 1
	IF @PageSize > 10000	SET @PageSize = 10000

	-- temporary, while INDEX is on SubAccountId column
	--DECLARE @SubAccountId varchar(50)
	--SELECT @SubAccountId =  SubAccountId FROM dbo.Account WHERE SubAccountUid = @SubAccountUid

	-- main select
	SELECT UMID, SubAccountId, [Date Sent], [Mobile Number], [Message Body],
			dss.[ShortenStatusName] [Status], OriginalUrl, Clicked
	FROM
		(SELECT sl.CreatedTime,
			CAST(sl.UMID as varchar(50)) AS UMID,
			sl.SubAccountId,
			CAST(sl.CreatedTime as smalldatetime) AS [Date Sent],
			sl.MSISDN AS [Mobile Number],
			sl.Body AS [Message Body],
			sl.StatusId,
			u.OriginalUrl,
			IIF(u.Hits > 0, 1, 0) AS Clicked
		FROM sms.SmsLog sl  WITH (INDEX (IX_SmsLog_SubAccount_CreatedTime), NOLOCK)
			INNER JOIN sms.UrlShorten u (NOLOCK) ON sl.UMID = u.UMID
		WHERE 
			sl.CreatedTime >= @TimeFrom AND sl.CreatedTime < @TimeTill
			--AND sl.SubAccountUid = @SubAccountUid -- TODO: there is no index yet for this column
			AND sl.SubAccountId = @SubAccountId
			AND sl.SmsTypeId = 1
			AND u.BaseUrlId = @BaseUrlId
		) s
		LEFT JOIN sms.DimSmsStatus dss ON s.StatusId = dss.StatusId
	ORDER BY s.CreatedTime
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY ;

END
