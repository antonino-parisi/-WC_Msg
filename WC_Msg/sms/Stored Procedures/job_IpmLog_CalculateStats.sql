
-- =============================================
-- Author: Rebecca Loh
-- Create date: 20 Mar 2019
-- Description: Aggregate sms.IpmLog table on a daily basis
-- Usage : EXEC sms.job_IpmLog_CalculateStats @start_date = '2018-10-04'
--       : EXEC sms.job_IpmLog_CalculateStats @start_date = '2018-10-04', @end_date = '2018-10-06'
-- =============================================
CREATE PROCEDURE [sms].[job_IpmLog_CalculateStats]
	@start_date DATE = NULL,
	@end_date DATE = NULL
AS
BEGIN
	DECLARE @statdate SMALLDATETIME, @nextday SMALLDATETIME ;
	DECLARE @update_records INT, @insert_records INT;

	--Get start date & prev day
	SET @statdate = CAST(CAST(ISNULL(@start_date, GETUTCDATE()) AS DATE) AS SMALLDATETIME) ;
	SET @end_date = ISNULL(@end_date, @statdate);

	CREATE TABLE #Stats
		(StatDate DATE,
		SubAccountUid INT,
		Country CHAR(2),
		ChannelUid TINYINT,
		MsgDelivered INT,
		MsgRead INT,
		MsgIncoming INT,
		MsgOutgoing INT,
		MsgChargeable INT
		) ;

	WHILE @statdate <= @end_date
	BEGIN
		SET @nextday = DATEADD(dd, 1, @statdate) ;

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Statdate : '+CAST(@statdate AS VARCHAR(20))+'    '+'Next day : '+CAST(@nextday AS VARCHAR(20));

		--Stop sms.job_IpmLog_UpdateStats from updating
		--the newly created records with passe data
		DELETE FROM ipm.IpmLog_ChangeLog
		WHERE CreatedAt >= @statdate
			AND CreatedAt < @nextday ;

		INSERT INTO #Stats
			(StatDate, SubAccountUid, Country, ChannelUid,
			MsgDelivered, MsgRead, MsgIncoming, MsgOutgoing, MsgChargeable)
		SELECT @statdate, SubAccountUid, Country, ChannelUid,
				Delivered = SUM(IIF(Direction = 1 AND [StatusId] = 40, 1, 0)),
				[Read] = SUM(IIF(Direction = 1 AND [StatusId] = 50, 1, 0)),
				Incoming = SUM(CASE Direction WHEN 0 THEN 1 ELSE 0 END),
				Outgoing = SUM(CASE Direction WHEN 1 THEN 1 ELSE 0 END),
				--Chargeable = SUM(CASE WHEN Direction = 1 AND InitSession = 1 AND StatusId >= 40 THEN 1 ELSE 0 END)
				Chargeable = SUM(CASE WHEN Direction = 1 AND StatusId >= 40
                          AND ((ChannelUid = 1 AND ISNULL(InitSession, 1) = 1) -- whatsapp
                            OR ChannelUid BETWEEN 5 AND 6) THEN 1 ELSE 0 END) -- Viber or Line
		FROM sms.IpmLog WITH (NOLOCK, FORCESEEK)
		WHERE CreatedAt >= @statdate
			AND CreatedAt < @nextday
		GROUP BY SubAccountUid, Country, ChannelUid ;

		EXEC dbo.Print_RowCount @msg='Insert into #Stats', @procid=@@PROCID ;
	
		UPDATE A
			SET MsgDelivered = B.MsgDelivered,
				MsgRead = B.MsgRead,
				MsgIncoming = B.MsgIncoming,
				MsgOutgoing = B.MsgOutgoing,
				MsgChargeable = B.MsgChargeable,
				LastUpdatedAt = GETUTCDATE()
		FROM ipm.StatIpmLog A WITH (NOLOCK) JOIN #Stats B
		ON A.StatDate = @statdate
			AND A.SubAccountUid = B.SubAccountUid
			AND ISNULL(A.Country, '') = ISNULL(B.Country, '')
			AND A.ChannelUid = B.ChannelUid
		WHERE A.MsgDelivered <> B.MsgDelivered
			OR A.MsgRead <> B.MsgRead
			OR A.MsgIncoming <> B.MsgIncoming
			OR A.MsgOutgoing <> B.MsgOutgoing
			OR A.MsgChargeable <> B.MsgChargeable ;

		EXEC @update_records = dbo.Print_RowCount @msg='Records updated in ipm.StatIpmLog ', @procid=@@PROCID ;

		INSERT INTO ipm.StatIpmLog
			(StatDate, SubAccountUid, Country, ChannelUid, MsgDelivered,
			MsgRead, MsgIncoming, MsgOutgoing, MsgChargeable, LastUpdatedAt)
		SELECT StatDate, SubAccountUid, Country, ChannelUid, MsgDelivered,
			MsgRead, MsgIncoming, MsgOutgoing, MsgChargeable, GETUTCDATE()
		FROM #Stats A
		WHERE NOT EXISTS (SELECT 1 FROM ipm.StatIpmLog
							WHERE StatDate = A.StatDate
								AND SubAccountUid = A.SubAccountUid
								AND ISNULL(Country, '') = ISNULL(A.Country, '')
								AND ChannelUid = A.ChannelUid );

		EXEC @insert_records = dbo.Print_RowCount @msg='Records inserted into ipm.StatIpmLog ', @procid=@@PROCID ;

		TRUNCATE TABLE #Stats ;

		SET @statdate = DATEADD(dd, 1, @statdate) ;
	END ;

	--SELECT @insert_records, @update_records ;
END


