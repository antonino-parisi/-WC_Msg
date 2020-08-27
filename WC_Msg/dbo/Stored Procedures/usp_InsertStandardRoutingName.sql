-- =============================================
-- Author:		<Raju Gupta>
-- Create date: <14-01-2014,>
-- Description:	<Inserting standard routename>
-- =============================================
create PROCEDURE [dbo].[usp_InsertStandardRoutingName]
@AccountId as nvarchar(50),
@SubAccountId as nvarchar(50),
@StandardRouteIdName as nvarchar(250),
@count int=0 OUTPUT
AS
BEGIN
	IF EXISTS(SELECT * FROM StandardAccount WHERE AccountId=@AccountId AND SubAccountId=@SubAccountId)
	BEGIN
	--UPDATE StandardAccount SET StandardRouteIdName=@StandardRouteIdName WHERE AccountId=@AccountId AND SubAccountId=@SubAccountId
	set @count=-1
	END
	ELSE
	BEGIN
	INSERT INTO StandardAccount(AccountId,SubAccountId,StandardRouteIdName) values(@AccountId,@SubAccountId,@StandardRouteIdName)
		set @count=1
	END
	
                                     	
END
