
-- =============================================
-- Author: Rebecca Loh
-- Create date: 21 Mar 2019
-- Description: Update ipm.StatIpmLog with data in ipm.IpmLog_ChangeLog
-- Usage : EXEC sms.job_IpmLog_UpdateStats @start_date = '2018-10-04'
-- =============================================
CREATE PROCEDURE [sms].[job_IpmLog_UpdateStats]
	@start_date date = NULL,
	@end_date date = NULL
AS
BEGIN
	PRINT 'job_IpmLog_UpdateStats : ' + ISNULL(CAST(@start_date AS VARCHAR(20)), '')
			+ ' to ' + ISNULL(CAST(@end_date AS VARCHAR(20)), '') ;

	CREATE TABLE #tmpUMID
		(UMID uniqueidentifier,
		UpdatedAt datetime2(2)) ;

	CREATE TABLE #tmp
		(StatDate date,
		SubAccountUid int,
		Country char(2),
		ChannelUid int,
		Delivered int,
		[Read] int,
		Chargeable int
		) ;

	INSERT INTO #tmpUMID
	SELECT DISTINCT UMID, UpdatedAt FROM ipm.IpmLog_ChangeLog WITH (NOLOCK)
	WHERE (@start_date IS NULL OR CreatedAt >= @start_date)
		AND (@end_date IS NULL OR CreatedAt < DATEADD(dd, 1, @end_date)) ;	

	-- Assumptions of updates in sms.IpmLog
	-- Direction, CreatedAt, InitSession do not change after creation

	INSERT INTO #tmp
	SELECT StatDate, SubAccountUid, Country, ChannelUid,
			SUM(Delivered), SUM([Read]), SUM(Chargeable)
	FROM
		(SELECT CAST(CreatedAt AS DATE) StatDate,
				SubAccountUid, Country,	ChannelUid,
				Delivered = CASE
							WHEN Direction = 1 AND NewStatusId = 40 THEN 1
							WHEN Direction = 1 AND NewStatusId = 50 AND OldStatusId = 40 THEN -1
							ELSE 0
						END,
				[Read] = CASE WHEN Direction = 1 AND NewStatusId = 50 THEN 1 ELSE 0 END,
				Chargeable = CASE WHEN OldStatusId < 40 AND NewStatusId >= 40 AND Direction = 1
								AND ((ChannelUid = 1 AND ISNULL(InitSession, 1) = 1) OR ChannelUid BETWEEN 5 AND 6) THEN 1 ELSE 0 END
		FROM ipm.IpmLog_ChangeLog A WITH (NOLOCK)
				INNER JOIN #tmpUMID B
				ON A.UMID = B.UMID
				AND A.UpdatedAt = B.UpdatedAt
		WHERE A.OldStatusId <> A.NewStatusId
		) A
	GROUP BY StatDate, SubAccountUid, Country, ChannelUid ;

	UPDATE A
	SET MsgDelivered = MsgDelivered + B.Delivered,
		MsgRead = MsgRead + B.[Read],
		MsgChargeable = MsgChargeable + B.Chargeable
	FROM ipm.StatIpmLog A WITH (NOLOCK) JOIN #tmp B
	ON A.StatDate = B.StatDate
		AND A.SubAccountUid = B.SubAccountUid
		AND A.Country = B.Country
		AND A.ChannelUid = B.ChannelUid ;

	DELETE FROM A
	FROM ipm.IpmLog_ChangeLog A WITH (NOLOCK)
		INNER JOIN #tmpUMID B
		ON A.UMID = B.UMID
		AND A.UpdatedAt = B.UpdatedAt ;
END

