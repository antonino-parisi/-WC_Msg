-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchMessage] 
	@AccountId VARCHAR(50),
	@SubAccountId VARCHAR(50),
	@Source VARCHAR(50),
	@MessageType VARCHAR(50),
	
	@Umid VARCHAR(200),
	@Country VARCHAR(50),
	@DateBegin DATETIME,	--UTC date
	@DateEnd DATETIME,		--UTC date
	@TimezoneOffset smallint = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @DateBegin > @DateEnd RETURN

	-- return only last 6 months
	IF @DateBegin < DATEADD(MONTH,-6,GETUTCDATE()) SET @DateBegin = DATEADD(MONTH,-6,GETUTCDATE())

	--apply timezone offset
	SET @DateBegin = DATEADD(MINUTE, @TimezoneOffset, @DateBegin)
	SET @DateEnd = DATEADD(MINUTE, @TimezoneOffset, @DateEnd)
	
	IF (@umid!='')
	BEGIN
		SELECT TrafficRecord.UMID, MessageType,TrafficRecord.Source,TrafficRecord.Destination, 
			DATEADD(MINUTE, -@TimezoneOffset, TrafficRecord.DateTimeStamp) AS DateTimeStamp, --convert to local tz
			TrafficRecord.Status,dialing_codes.Country,TrafficRecord.SubAccountId
		FROM dialing_codes   JOIN TrafficRecord(nolock)   ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' )
		WHERE (UMID = @UMID) AND SubAccountId IN ( Select SubAccountId From Account where AccountId=@AccountId)
		
		/*
		NO search older that 10 days by UMID!   @Anton Shchekalov 2016-09-27
		UNION ALL
		
		SELECT TrafficRecordArchive.UMID, MessageType,TrafficRecordArchive.Source,TrafficRecordArchive.Destination,TrafficRecordArchive.DateTimeStamp,TrafficRecordArchive.Status,dialing_codes.Country,TrafficRecordArchive.SubAccountId
		FROM dialing_codes   JOIN TrafficRecordArchive(nolock)   ON ( '+'+TrafficRecordArchive.Destination LIKE dialing_codes.Code+'%' )
		WHERE (UMID = @UMID) AND SubAccountId IN ( Select SubAccountId From Account where AccountId=@AccountId)
		order by  DateTimeStamp desc
		*/
	END
	ELSE
	BEGIN
	
		-- If there is not SubAccountId, we list all the countries
		IF (@SubAccountId='')
		BEGIN
			SELECT TOP 1000 * FROM (
				SELECT TrafficRecord.UMID, MessageType,TrafficRecord.Source,TrafficRecord.Destination,
					DATEADD(MINUTE, -@TimezoneOffset, TrafficRecord.DateTimeStamp) AS DateTimeStamp, --convert to local tz
					TrafficRecord.Status,dialing_codes.Country,TrafficRecord.SubAccountId
				FROM TrafficRecord (nolock)
					JOIN dialing_codes ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' )
				WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
					AND ( @Source='' OR TrafficRecord.Source=@Source) 
					AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
					AND ( TrafficRecord.DateTimeStamp >=@DateBegin  AND TrafficRecord.DateTimeStamp <=@DateEnd )  
					AND (@umid='' OR TrafficRecord.UMID= @Umid) 
					AND(@Country='' OR dialing_codes.Country=@Country)
		
				/*
				NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
				UNION ALL
		
				SELECT TrafficRecordArchive.UMID, MessageType,TrafficRecordArchive.Source,TrafficRecordArchive.Destination,
					DATEADD(MINUTE, -@TimezoneOffset, TrafficRecordArchive.DateTimeStamp) AS DateTimeStamp, --convert to local tz
					TrafficRecordArchive.Status,dialing_codes.Country,TrafficRecordArchive.SubAccountId  
				FROM TrafficRecordArchive(nolock)
					JOIN dialing_codes ON ( '+'+TrafficRecordArchive.Destination LIKE dialing_codes.Code+'%' )
				WHERE @DateBegin < DATEADD(DAY, -9, GETUTCDATE()) /* TrafficRecordArchive contains only data older than 10 days */
					AND ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
					AND ( @Source='' OR TrafficRecordArchive.Source=@Source) 
					AND  TrafficRecordArchive.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
					AND ( TrafficRecordArchive.DateTimeStamp >=@DateBegin  AND TrafficRecordArchive.DateTimeStamp <=@DateEnd )  
					AND (@umid='' OR TrafficRecordArchive.UMID= @Umid) 
					AND(@Country='' OR dialing_codes.Country=@Country)
				*/		
			) t
			ORDER BY DateTimeStamp DESC		
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM Account WHERE AccountId=@AccountID AND SubAccountId=@SubAccountId)
			BEGIN
				SELECT TOP 1000 * FROM (
					SELECT TrafficRecord.UMID, MessageType,TrafficRecord.Source,TrafficRecord.Destination,
						DATEADD(MINUTE, -@TimezoneOffset, TrafficRecord.DateTimeStamp) AS DateTimeStamp, --convert to local tz
						TrafficRecord.Status,dialing_codes.Country,TrafficRecord.SubAccountId
					FROM dialing_codes   JOIN TrafficRecord(nolock)   ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' )
					WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
						AND ( @Source='' OR TrafficRecord.Source=@Source) 
						AND  TrafficRecord.SubAccountId=@SubAccountId 
						AND ( TrafficRecord.DateTimeStamp >=@DateBegin  AND TrafficRecord.DateTimeStamp <=@DateEnd )  
						AND (@umid='' OR TrafficRecord.UMID= @Umid) 
						AND(@Country='' OR dialing_codes.Country=@Country)

				/*
				NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
					UNION ALL
		
					SELECT TrafficRecordArchive.UMID, MessageType,TrafficRecordArchive.Source,TrafficRecordArchive.Destination,
						DATEADD(MINUTE, -@TimezoneOffset, TrafficRecordArchive.DateTimeStamp) AS DateTimeStamp, --convert to local tz
						TrafficRecordArchive.Status,dialing_codes.Country,TrafficRecordArchive.SubAccountId
					FROM dialing_codes   JOIN TrafficRecordArchive(nolock)   ON ( '+'+TrafficRecordArchive.Destination LIKE dialing_codes.Code+'%' )
					WHERE @DateBegin < DATEADD(DAY, -9, GETUTCDATE()) /* TrafficRecordArchive contains only data older than 10 days */
						AND ( @MessageType='' OR TrafficRecordArchive.MessageType=@MessageType) 
						AND ( @Source='' OR TrafficRecordArchive.Source=@Source) 
						AND  TrafficRecordArchive.SubAccountId=@SubAccountId 
						AND ( TrafficRecordArchive.DateTimeStamp >=@DateBegin  AND TrafficRecordArchive.DateTimeStamp <=@DateEnd )  
						AND (@umid='' OR TrafficRecordArchive.UMID= @Umid) 
						AND(@Country='' OR dialing_codes.Country=@Country)
				*/
				) t
				ORDER BY DateTimeStamp DESC
			END
		END
	END
END
