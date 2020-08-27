-- =============================================
-- Author:		Raymond Torino
-- Create date: 2018-05-02
-- Description:	Update UpdatedAt of affected sub-account
-- =============================================
-- EXEC map.[CustomerGroupSubAccount_UpdateUpdatedAt] @SubAccountUids = '123,124'
CREATE PROCEDURE [map].[CustomerGroupSubAccount_UpdateUpdatedAt_NotInUse]
	@SubAccountUids VARCHAR(1000)
AS
BEGIN
	UPDATE cgs
	SET UpdatedAt = SYSUTCDATETIME()
	FROM rt.CustomerGroupSubAccount cgs
	WHERE cgs.SubAccountUid IN (SELECT * FROM dbo.SplitString(@SubAccountUids, ','))
END
