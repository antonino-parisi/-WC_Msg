﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_StatsTotalByMTAndCountry] 
	-- Add the parameters for the stored procedure here
		@AccountId VARCHAR(50),
		@SubAccountId VARCHAR(50),
		@Source VARCHAR(50),
		@MessageType VARCHAR(50),
		@Country VARCHAR(50),
		@DateBegin DATETIME,
		@DateEnd DATETIME
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	
	-- If there is not SubAccountId, we list all the countries
	IF (@SubAccountId='')
		BEGIN
		SELECT dialing_codes.Country, TrafficRecord.MessageType,TrafficRecord.Source,COUNT(*) AS TOTAL FROM dialing_codes   JOIN TrafficRecord   
		ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' ) 
		WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
		AND ( @Source='' OR TrafficRecord.Source=@Source) 
		AND  TrafficRecord.SubAccountId IN ( SELECT SubAccountId FROM Account WHERE AccountId=@AccountId) 
		AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )  
		AND(@Country='' OR dialing_codes.Country=@Country)
		GROUP BY TrafficRecord.MessageType,TrafficRecord.Source, dialing_codes.Country
		ORDER BY TOTAL DESC
		END
	ELSE
		BEGIN
		-- Insert statements for procedure here
		if EXISTS (SELECT * FROM Account WHERE AccountId=@AccountID AND SubAccountId=@SubAccountId)
		BEGIN
			SELECT dialing_codes.Country, TrafficRecord.MessageType,TrafficRecord.Source,COUNT(*) AS TOTAL FROM dialing_codes   JOIN TrafficRecord   
			ON ( '+'+TrafficRecord.Destination LIKE dialing_codes.Code+'%' ) 
			WHERE ( @MessageType='' OR TrafficRecord.MessageType=@MessageType) 
			AND ( @Source='' OR TrafficRecord.Source=@Source) 
			AND  TrafficRecord.SubAccountId=@SubAccountId 
			AND ( TrafficRecord.DateTimeStamp >@DateBegin  AND TrafficRecord.DateTimeStamp <@DateEnd )  
			AND(@Country='' OR dialing_codes.Country=@Country)
			GROUP BY TrafficRecord.MessageType,TrafficRecord.Source, dialing_codes.Country
			ORDER BY TOTAL DESC
		END
	END
END
