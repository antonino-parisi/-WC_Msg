-- =============================================
-- Author:		<Author,,Arbie Samong>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchMO] 
	-- Add the parameters for the stored procedure here
		@AccountId VARCHAR(50),
		@SubAccountId VARCHAR(50),
		@Recipient VARCHAR(50),
		@DateBegin DATETIME,
		@DateEnd DATETIME,
		@Country VARCHAR(MAX),
		@Sender VARCHAR(50),
		@Body VARCHAR(MAX)
		
AS
BEGIN

	-- ** Depricated data **
	SELECT '' as SubAccountId,
				'' as Recipient,
				'2017/01/01' as MODateTimeStamp,
				'' as Sender,
				'' as Body,
				'singapore' as Country
	FROM dialing_codes
	WHERE 1 = 0
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	--SET @DateEnd=DATEADD(DAY, 1, @DateEnd)
	--BEGIN
	--if EXISTS (SELECT * FROM Account WHERE AccountId=@AccountID)
	--	SELECT TOP 1000 MOTrafficRecord.SubAccountId,
	--		MOTrafficRecord.Recipient,
	--		MOTrafficRecord.DateTimeStamp as MODateTimeStamp,
	--		MOTrafficRecord.Sender,
	--		MOTrafficRecord.Body,
	--		dialing_codes.Country
	--	FROM MOTrafficRecord
	--	LEFT OUTER JOIN dialing_codes ON ( '+'+MOTrafficRecord.Sender LIKE dialing_codes.Code+'%' )
	--	WHERE MOTrafficRecord.AccountId=@AccountId
	--		AND ( @SubAccountId='' OR MOTrafficRecord.SubAccountId=@SubAccountId) 
	--		AND ( @Recipient='' OR MOTrafficRecord.Recipient=@Recipient) 
	--		AND ( MOTrafficRecord.DateTimeStamp >@DateBegin  AND MOTrafficRecord.DateTimeStamp <@DateEnd )  
	--		AND ( @Sender='' OR MOTrafficRecord.Sender=@Sender) 
	--		AND ( @Country='' OR dialing_codes.Country=@Country)
	--		AND ( @Body='' OR MOTrafficRecord.Body LIKE ('%'+@Body+'%')) order by MOTrafficRecord.DateTimeStamp desc
	--	END	
END

