CREATE PROCEDURE [dbo].[sp_GetRecordBySubAccountIdUmid]
		@UMID VARCHAR(50),
		@SubAccountId VARCHAR(50)		
AS
BEGIN
	SET NOCOUNT ON;

	--commented on 2016-09-28 by Anton
	--WAITFOR DELAY '00:00:00.100'

	--draft of columns that are used by app
	--SELECT AccountId, SubAccountId, Destination, ShortCode, Body, DeliveryMethod, WapUrl, IsEncrypted, Encoding, OperatorId, RegisteredDelivery, Tariff, UMID, DateTimeStamp, Attempt
	SELECT * 
	FROM [dbo].[TrafficRecord] WITH(NOLOCK)
	WHERE UMID = @UMID and SubAccountId = @SubAccountId
END
