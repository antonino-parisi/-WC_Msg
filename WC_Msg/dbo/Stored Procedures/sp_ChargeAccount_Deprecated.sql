-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_ChargeAccount_Deprecated]
	@AccountId NVARCHAR(50),
	@value DECIMAL(14,5)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @credit DECIMAL(14,5);
	DECLARE @RC bit;
	DECLARE @ERRORUPDATE int
	DECLARE @overdraftAuthorized DECIMAL(14,5);

	SET @RC = 1
  	
	BEGIN TRY
  
		UPDATE [dbo].[AccountCredit] 
		SET creditEuro = CASE WHEN (CreditEuro > @value) THEN CreditEuro - @value END  
		WHERE ( AccountId= @AccountId);

		SET @ERRORUPDATE =  @@ERROR 	
	END TRY
	BEGIN CATCH
		set @RC = 0	
		SET  @overdraftAuthorized = (SELECT overdraftAuthorized FROM [dbo].AccountCredentials WHERE (@AccountId = AccountId) );
		SET  @credit = (SELECT CreditEuro FROM [dbo].[AccountCredit] WHERE (@AccountId = AccountId))
		if ( ( @credit - @value )  > (   @overdraftAuthorized ))
		BEGIN
			UPDATE [dbo].[AccountCredit] SET creditEuro = creditEuro - @value WHERE (@AccountId = AccountId) ;
			set @RC = 1
		END
	END CATCH

	SELECT @rc AS rc
END
