
-- =============================================
-- Author: Rebecca Loh
-- Create date: 24 Jun 2020
-- Description: Delete record from cp.AccountSSOConfig
-- Usage : EXEC cp.AccountSSOConfig_Delete @AccountUid = '95272080-6282-E711-8143-02D85F55FCE7'
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
CREATE PROCEDURE [cp].[AccountSSOConfig_Delete]
	@AccountUid uniqueidentifier
AS
BEGIN
	DELETE FROM cp.AccountSSOConfig
	WHERE AccountUid = @AccountUid ;

END
