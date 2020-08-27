-- =============================================
-- Author: Rebecca Loh
-- Create date: 24 Oct 2018
-- Description: Aggregate smslog table senders' data on a daily basis
-- Usage : EXEC sms.job_SmsLog_CalculateSenderStats @start_date = '2018-10-04' (4 Oct 2018)
--       : EXEC sms.job_SmsLog_CalculateSenderStats @start_date = '2018-10-04', @end_date = '2018-10-06' (4 to 6 Oct 2018)
-- =============================================
CREATE PROCEDURE [sms].[job_SmsLog_CalculateSenderStats]
	@start_date DATE = NULL,
	@end_date DATE = NULL
AS
BEGIN
	DECLARE @statdate SMALLDATETIME, @nextday SMALLDATETIME, @stattime SMALLDATETIME ;
	--Below declaration is temp
	DECLARE @update_records INT, @insert_records INT;

	--Get start date & prev day
	SET @statdate = CAST(CAST(ISNULL(@start_date, GETUTCDATE()) AS DATE) AS SMALLDATETIME) ;
	SET @end_date = ISNULL(@end_date, @statdate);

	CREATE TABLE #SmsStatsSID
		(SubAccountUid INT,
		Country CHAR(2),
		OperatorId INT,
		ConnUid SMALLINT,
		SenderId_In VARCHAR(20),
		SenderId_Out VARCHAR(20),
		Cost_EUR DECIMAL(18,6),
		Price_EUR DECIMAL(18,6),
		SmsCountTotal INT,
		SmsCountDelivered INT,
		SmsCountUndelivered INT,
		SmsCountRejected INT,
		MsgCountTotal INT,
		MsgCountDelivered INT,
		MsgCountUndelivered INT,
		MsgCountRejected INT ) ;

	--Create same table columns as #SmsSenderStats
	SELECT * INTO #tmpStatsSID FROM #SmsStatsSID WHERE 1 = 2;
	SELECT * INTO #SmsSenderStats FROM #SmsStatsSID WHERE 1 = 2;

	WHILE @statdate <= @end_date
	BEGIN
		SET @nextday = DATEADD(dd, 1, @statdate) ;

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Statdate : '+CAST(@statdate AS VARCHAR(20))+'    '+'Next day : '+CAST(@nextday AS VARCHAR(20));

		SET @stattime = @statdate ;

		WHILE @stattime < @nextday
			BEGIN
				INSERT INTO #tmpStatsSID (
					SubAccountUid, Country, OperatorId, ConnUid,
					SenderId_In, SenderId_Out, Cost_EUR, Price_EUR,
					SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected,
					MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected)
				SELECT
					--NEXT VALUE FOR sms.StatSmsLogSIDDailySeq StatEntryId,
					SubAccountUid, Country,	OperatorId,	ConnUid,
					ISNULL(SourceOriginal, [Source]) SenderId_In,
					[Source] SenderId_Out,
					SUM(SegmentsReceived * Cost) Cost,
					SUM(SegmentsReceived * Price) Price,
					SUM(SegmentsReceived) SmsCountTotal,
					SUM(CASE WHEN StatusId = 40 THEN SegmentsReceived ELSE 0 END) SmsCountDelivered,
					SUM(CASE WHEN StatusId IN (31, 41) THEN SegmentsReceived ELSE 0 END) SmsCountUndelivered,
					SUM(CASE WHEN StatusId = 21 THEN SegmentsReceived ELSE 0 END) SmsCountRejected,
					COUNT(1) MsgCountTotal,
					SUM(CASE WHEN StatusId = 40 THEN 1 ELSE 0 END) MsgCountDelivered,
					SUM(CASE WHEN StatusId IN (31, 41) THEN 1 ELSE 0 END) MsgCountUndelivered,
					SUM(CASE WHEN StatusId = 21 THEN 1 ELSE 0 END) MsgCountRejected
				FROM sms.SmsLog WITH (NOLOCK, INDEX (IX_SmsLog_CreatedTime))
				WHERE 
					(CreatedTime >= @stattime  AND CreatedTime < DATEADD(hh, 1, @stattime))
				GROUP BY
					SubAccountUid, 
					Country, 
					OperatorId,
					ConnUid,
					SourceOriginal,
					[Source] ;

				EXEC dbo.Print_RowCount @msg='Insert into #tmpStatsSID', @procid=@@PROCID ;

				SET @stattime = DATEADD(hh, 1, @stattime) ;
			END ;

		INSERT INTO #SmsStatsSID (
			SubAccountUid, Country, OperatorId, ConnUid,
			SenderId_In, SenderId_Out, Cost_EUR, Price_EUR,
			SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected,
			MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected)
		SELECT
			SubAccountUid, Country,	OperatorId,	ConnUid, SenderId_In, SenderId_Out,
			SUM(Cost_EUR) Cost_EUR,
			SUM(Price_EUR) Price_EUR,
			SUM(SmsCountTotal) SmsCountTotal,
			SUM(SmsCountDelivered) SmsCountDelivered,
			SUM(SmsCountUndelivered) SmsCountUndelivered,
			SUM(SmsCountRejected) SmsCountRejected,
			SUM(MsgCountTotal) MsgCountTotal,
			SUM(MsgCountDelivered) MsgCountDelivered,
			SUM(MsgCountUndelivered) MsgCountUndelivered,
			SUM(MsgCountRejected) MsgCountRejected
		FROM #tmpStatsSID
		GROUP BY
			SubAccountUid, 
			Country, 
			OperatorId,
			ConnUid,
			SenderId_In,
			SenderId_Out ;

		EXEC dbo.Print_RowCount @msg='Insert into ##SmsStatsSID', @procid=@@PROCID ;

		INSERT INTO #SmsSenderStats (
			SubAccountUid, Country, OperatorId, ConnUid,
			SenderId_In, SenderId_Out, Cost_EUR, Price_EUR,
			SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected,
			MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected)
		SELECT 	SubAccountUid, Country, OperatorId, ConnUid, SenderId_In, SenderId_Out,
				SUM(Cost_EUR) Cost, SUM(Price_EUR) Price, SUM(SmsCountTotal) SmsCountTotal,
				SUM(SmsCountDelivered) SmsCountDelivered, SUM(SmsCountUndelivered) SmsCountUndelivered,
				SUM(SmsCountRejected) SmsCountRejected, SUM(MsgCountTotal) MsgCountTotal,
				SUM(MsgCountDelivered) MsgCountDelivered, SUM(MsgCountUndelivered) MsgCountUndelivered,
				SUM(MsgCountRejected) MsgCountRejected
		FROM
			(SELECT sms.SubAccountUid, sms.Country, sms.OperatorId, sms.ConnUid,
				sms.SenderId_In, ISNULL(srp.SenderPoolName, sms.SenderId_Out) SenderId_Out,
				sms.Cost_EUR, sms.Price_EUR, sms.SmsCountTotal, sms.SmsCountDelivered,
				sms.SmsCountUndelivered, sms.SmsCountRejected, sms.MsgCountTotal, sms.MsgCountDelivered,
				sms.MsgCountUndelivered, sms.MsgCountRejected
				FROM #SmsStatsSID sms LEFT JOIN
					(SELECT mr.OperatorId, ac.SubAccountUid, mr.Country, cc.RouteUid,
							 mr.OriginalSenderId, mr.NewSenderId, mr.NewSenderPoolId
						FROM optimus.SenderMaskingRules mr WITH (NOLOCK)
							LEFT JOIN dbo.Account ac WITH (NOLOCK)
								ON ISNULL(mr.SubAccountId,'') = ISNULL(ac.SubAccountId,'')
							LEFT JOIN dbo.CarrierConnections cc WITH (NOLOCK)
								ON ISNULL(mr.RouteId,'') = ISNULL(cc.RouteId,'')
						WHERE mr.NewSenderId IS NULL
							AND mr.NewSenderPoolId IS NOT NULL
					) smr
					ON ISNULL(sms.OperatorId,0) = ISNULL(smr.OperatorId,0)
						AND ISNULL(sms.SubAccountUid,0) = ISNULL(smr.SubAccountUid,0)
						AND ISNULL(sms.Country,'') = ISNULL(smr.Country,'')
						AND ISNULL(sms.ConnUid,'') = ISNULL(smr.RouteUid,'')
				LEFT JOIN optimus.SenderRotationPool srp WITH (NOLOCK)
					ON ISNULL(smr.NewSenderPoolId,0) = srp.SenderPoolId
			) SMS
		GROUP BY SubAccountUid, Country, OperatorId, ConnUid, SenderId_In, SenderId_Out ;

		EXEC dbo.Print_RowCount @msg='Insert into #SmsSenderStats', @procid=@@PROCID ;
		
		UPDATE A
			SET Cost_EUR = B.Cost_EUR,
				Price_EUR = B.Price_EUR,
				SmsCountAccepted = B.SmsCountTotal-B.SmsCountRejected,
				SmsCountDelivered = B.SmsCountDelivered,
				SmsCountUnDelivered = B.SmsCountUndelivered,
				SmsCountRejected = B.SmsCountRejected,
				MsgCountAccepted = B.MsgCountTotal-B.MsgCountRejected,
				MsgCountDelivered = B.MsgCountDelivered,
				MsgCountUndelivered = B.MsgCountUndelivered,
				MsgCountRejected = B.MsgCountRejected,
				LastUpdatedAt = GETUTCDATE()
		FROM sms.StatSmsLogSIDDaily A WITH (NOLOCK), #SmsSenderStats B
		WHERE A.StatDate = @statdate
			AND ISNULL(A.SubAccountUid,0) = ISNULL(B.SubAccountUid,0)
			AND ISNULL(A.Country,'') = ISNULL(B.Country,'')
			AND ISNULL(A.OperatorId,0) = ISNULL(B.OperatorId,0)
			AND ISNULL(A.ConnUid,0) = ISNULL(B.ConnUid,0)
			AND ISNULL(A.SenderId_In,'') = ISNULL(B.SenderId_In,'')
			AND A.SenderId_Out = B.SenderId_Out
			AND (A.SmsCountAccepted <> (B.SmsCountTotal-B.SmsCountRejected)
				OR A.SmsCountDelivered <> B.SmsCountDelivered
				OR A.SmsCountUnDelivered <> B.SmsCountUnDelivered
				OR A.SmsCountRejected <> B.SmsCountRejected
				OR A.MsgCountAccepted <> (B.MsgCountTotal-B.MsgCountRejected)
				OR A.MsgCountDelivered <> B.MsgCountDelivered
				OR A.MsgCountUndelivered <> B.MsgCountUndelivered
				OR A.MsgCountRejected <> B.MsgCountRejected ) ;

		EXEC @update_records = dbo.Print_RowCount @msg='Records updated in sms.StatSmsLogSIDDaily', @procid=@@PROCID ;

		INSERT INTO sms.StatSmsLogSIDDaily
			(StatDate, StatEntryId, SubAccountUid, Country, OperatorId, ConnUid,
			SenderId_In, SenderId_Out, Cost_EUR, Price_EUR,
			SmsCountAccepted, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected,
			MsgCountAccepted, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected)
		SELECT @statdate, NEXT VALUE FOR sms.StatSmsLogSIDDailySeq, SubAccountUid, Country,
			OperatorId, ConnUid, SenderId_In, SenderId_Out, Cost_EUR, Price_EUR,
			SmsCountTotal-SmsCountRejected, SmsCountDelivered, SmsCountUndelivered, SmsCountRejected,
			MsgCountTotal-MsgCountRejected, MsgCountDelivered, MsgCountUndelivered, MsgCountRejected
		FROM #SmsSenderStats A
		WHERE NOT EXISTS (SELECT 1 FROM sms.StatSmsLogSIDDaily WITH (NOLOCK)
							WHERE StatDate = @statdate
								AND ISNULL(SubAccountUid,0) = ISNULL(A.SubAccountUid,0)
								AND ISNULL(Country,'') = ISNULL(A.Country,'')
								AND ISNULL(OperatorId,0) = ISNULL(A.OperatorId,0)
								AND ISNULL(ConnUid,0) = ISNULL(A.ConnUid,0)
								AND ISNULL(SenderId_In,'') = ISNULL(A.SenderId_In,'')
								AND SenderId_Out = A.SenderId_Out );

		EXEC @insert_records = dbo.Print_RowCount @msg='Records inserted into sms.StatSmsLogSIDDaily', @procid=@@PROCID ;

		TRUNCATE TABLE #SmsStatsSID ;
		TRUNCATE TABLE #SmsSenderStats ;

		SET @statdate = DATEADD(dd, 1, @statdate) ;
	END ;

	--SELECT @insert_records, @update_records ;
END
