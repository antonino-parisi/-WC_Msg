-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchMessageByUmid] 
	@SubAccountId VARCHAR(MAX),
	@Umid VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	
	-- If there is not SubAccountId, we list all the countries
	if (@SubAccountId='')
	BEGIN
		SELECT TOP 1000 *
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE
		 (TrafficRecord.UMID= @Umid) 
		END
		ELSE
		BEGIN
		SELECT TOP 1000 *
		FROM [dbo].[TrafficRecord] WITH(NOLOCK)
		WHERE (TrafficRecord.SubAccountId=@SubAccountId ) and 
		 (TrafficRecord.UMID= @Umid) 
		
	/*
	NO search older that 10 days by UMID!   @Anton Shchekalov 2018-04-29
		IF @@ROWCOUNT =0
			SELECT TOP 1000 *
		FROM [dbo].TrafficRecordArchive WITH(NOLOCK)
		WHERE (TrafficRecordArchive.SubAccountId=@SubAccountId ) and 
		 (TrafficRecordArchive.UMID= @Umid) 
	*/		
		END
		
	
END
