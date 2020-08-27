-- =============================================
-- Author :         Raymond Torino
-- Created date :   2018-04-27
-- =============================================
-- EXEC [map].[SubAccount_GetUngroupedCount]
CREATE PROCEDURE [map].[SubAccount_GetUngroupedCount]
AS
BEGIN
    SELECT COUNT(*) as Count
    FROM dbo.Account a
    WHERE a.Deleted = 0 AND a.Active = 1
        AND NOT EXISTS(SELECT 1 FROM rt.CustomerGroupSubAccount WHERE SubAccountUid = a.SubAccountUid AND Deleted = 0)
END
