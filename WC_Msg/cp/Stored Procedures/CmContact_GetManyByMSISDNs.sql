-- =============================================
-- Author:		RAUL
-- Create date: 2020-01-15
-- =============================================
CREATE PROCEDURE [cp].[CmContact_GetManyByMSISDNs]
	@AccountUid uniqueidentifier,
	@GroupIds varchar(1000),
    @MSISDNs varchar(1000)
AS
BEGIN
    SELECT DISTINCT(c.MSISDN) AS MSISDN
	FROM cp.CmContact c (NOLOCK)
	WHERE c.AccountUid = @AccountUid AND c.DeletedAt IS NULL
		AND EXISTS (
			SELECT 1 FROM cp.CmGroupContact gc 
			WHERE gc.ContactId = c.ContactId AND gc.GroupId IN (SELECT Item FROM dbo.SplitString_Int(@GroupIds, ','))
		)
        AND MSISDN IN (SELECT Item FROM dbo.SplitString(@MSISDNs, ','))
END
