-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2020-05-09
-- =============================================
CREATE PROCEDURE ms.AccountWallet_IsPositive
	@AccountUid uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT aw.ValidBalance FROM cp.AccountWallet aw WHERE AccountUid = @AccountUid
           
END
