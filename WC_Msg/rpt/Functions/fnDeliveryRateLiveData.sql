-- =============================================
-- Author:		Rebecca
-- Create date: 2019-05-30
-- =============================================
-- SELECT * FROM rpt.fnDeliveryRateLiveData (120, 'tix_otp', 'ID', DEFAULT)
-- SELECT * from rpt.fnDeliveryRateLiveData (30, 'tix_otp', 'ID', 'Indosat_Local')

CREATE FUNCTION [rpt].[fnDeliveryRateLiveData] (
	@Interval_Min smallint,
	@SubAccountId varchar(50) = NULL,
	@Country char(2) = NULL,
	@ConnId varchar(50) = NULL
)
RETURNS @retDeliveryRate TABLE
(
	TimeInterval varchar(20),
	SubAccountId varchar(50),
	ConnId varchar(50),
	Country char(2),
	OperatorId int,
	OperatorName varchar(50),
	DeliveryRate decimal(6,2),
	MsgCountTotal int,
	MsgCountDelivered int,
	MsgCountUndelivered int,
	MsgCountRejectedBySupplier int,
	MsgCountStuckWithSupplier int,
	MsgCountRejectedByWavecell int,
	MsgCountAccepted int,
	SmsCountTotal int,
	SmsCountDelivered int,
	SmsCountUndelivered int,
	SmsCountRejectedBySupplier int,
	SmsCountStuckWithSupplier int,
	SmsCountRejectedByWavecell int,
	SmsCountAccepted int
) 
AS  
BEGIN 
	DECLARE @start_time datetime ;
	DECLARE @from_time datetime, @to_time datetime ;
	DECLARE @tmp TABLE (
		TimeFrom varchar(5),
		SubAccountId varchar(50),
		ConnId varchar(50),
		Country char(2),
		Operatorid int,
		StatusId tinyint,
		SegmentsReceived tinyint
	) ;

	-- Cannot both be null
	IF @SubAccountId IS NULL AND @ConnId IS NULL
		RETURN ;

	IF @interval_min > 120 -- limit query to 2 hrs
		SET @interval_min = 120 ;

	SET @interval_min = @Interval_Min/5*5 ;

	SET @to_time = CAST(FORMAT(dbo.fnTimeRoundDown(GETUTCDATE(), 5), 'yyyy-MM-dd HH:mm') AS datetime) ;
	--SET @from_time = DATEADD(minute, -@Interval_Min, GETUTCDATE()) ;
	SET @from_time = DATEADD(minute, -@Interval_Min, @to_time) ;
	SET @start_time = @from_time ;

	WHILE @start_time <= @to_time
	BEGIN
		--PRINT CAST(DATEADD(minute, -15, @start_time) as varchar(20)) + ' to ' + CAST(@start_time as varchar(20)) ;
		IF @ConnId IS NULL
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom,
						SubAccountId, ConnId, Country, OperatorId, StatusId, SegmentsReceived
				FROM sms.SmsLog WITH (NOLOCK)
				WHERE
					CreatedTime >= @start_time 
					AND CreatedTime < DATEADD(minute, 5, @start_time)
					AND SubAccountId = @SubAccountId
					AND (@Country IS NULL OR Country = @Country) ;
					--AND Country = @Country ;
		ELSE IF @SubAccountId IS NULL
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom, 
						SubAccountId, ConnId, Country, OperatorId, StatusId, SegmentsReceived
				FROM sms.SmsLog WITH (NOLOCK, FORCESEEK)
				WHERE
					CreatedTime >= @start_time 
					AND CreatedTime < DATEADD(minute, 5, @start_time)
					--AND Country = @Country
					AND (@Country IS NULL OR Country = @Country)
					AND ConnId = @ConnId ;
		ELSE -- Both @ConnId & @SubAccountId not null
			INSERT INTO @tmp
			SELECT FORMAT(dbo.fnTimeRoundDown(CreatedTime, 5), 'HH:mm') TimeFrom,
						SubAccountId, ConnId, Country, OperatorId, StatusId, SegmentsReceived
				FROM sms.SmsLog WITH (NOLOCK, FORCESEEK)
				WHERE
					CreatedTime >= @start_time
					AND CreatedTime < DATEADD(minute, 5, @start_time)
					AND SubAccountId = @SubAccountId
					--AND Country = @Country
					AND (@Country IS NULL OR Country = @Country)
					AND ConnId = @ConnId ;

		INSERT INTO @retDeliveryRate
		SELECT TimeFrom, SubAccountId, ConnId, n.Country, n.OperatorId, o.Operatorname,
				IIF(MsgCountTotal = MsgCountRejectedByWavecell, 0, CAST(100*MsgCountDelivered/CAST((MsgCountTotal-MsgCountRejectedByWavecell) AS decimal(6,2)) AS decimal(6,2))) AS DeliveryRate,
				MsgCountTotal, MsgCountDelivered, MsgCountUndelivered, MsgCountRejectedBySupplier,
				MsgCountStuckWithSupplier, MsgCountRejectedByWavecell,
				MsgCountTotal-MsgCountRejectedByWavecell MsgCountAccepted,
				SmsCountTotal, SmsCountDelivered, SmsCountUndelivered, SmsCountRejectedBySupplier,
				SmsCountStuckWithSupplier, SmsCountRejectedByWavecell,
				SmsCountTotal-SmsCountRejectedByWavecell SmsCountAccepted
		FROM
			(SELECT TimeFrom, SubAccountId, ConnId, Country, OperatorId,
					COUNT(1) MsgCountTotal,
					SUM(CASE WHEN StatusId IN (40, 50) THEN 1 ELSE 0 END) MsgCountDelivered,
					SUM(CASE WHEN StatusId = 41 THEN 1 ELSE 0 END) MsgCountUndelivered,
					SUM(CASE WHEN StatusId = 31 THEN 1 ELSE 0 END) MsgCountRejectedBySupplier,
					SUM(CASE WHEN StatusId = 30 THEN 1 ELSE 0 END) MsgCountStuckWithSupplier,
					SUM(CASE WHEN StatusId <= 21 THEN 1 ELSE 0 END) MsgCountRejectedByWavecell,
					SUM(SegmentsReceived) as SmsCountTotal,
					SUM(CASE WHEN StatusId IN (40, 50) THEN SegmentsReceived ELSE 0 END) SmsCountDelivered,
					SUM(CASE WHEN StatusId = 41 THEN SegmentsReceived ELSE 0 END) SmsCountUndelivered,
					SUM(CASE WHEN StatusId = 31 THEN SegmentsReceived ELSE 0 END) SmsCountRejectedBySupplier,
					SUM(CASE WHEN StatusId = 30 THEN SegmentsReceived ELSE 0 END) SmsCountStuckWithSupplier,
					SUM(CASE WHEN StatusId <= 21 THEN SegmentsReceived ELSE 0 END) SmsCountRejectedByWavecell
			FROM @tmp s
			GROUP BY TimeFrom, SubAccountId, ConnId, Country, OperatorId
			) n
			LEFT JOIN mno.Operator o ON n.OperatorId = o.OperatorId ;

		DELETE @tmp ;
		SELECT @start_time = DATEADD(minute, 5, @start_time) ;
	END ;

	RETURN ;

END ;
