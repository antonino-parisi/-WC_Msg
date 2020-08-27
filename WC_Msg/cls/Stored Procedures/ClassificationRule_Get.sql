-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-07
-- =============================================
-- EXEC [cls].[ClassificationRule_Get]
CREATE PROCEDURE [cls].[ClassificationRule_Get]
	@LastSyncTimeStamp datetime2(2) = NULL
AS
BEGIN
	SELECT r.RuleId, r.SubCategoryId, c.SubCategory, r.SubAccountUid, a.SubAccountId, r.Country, r.Deleted
	FROM [cls].[ClassificationRule] AS r
		JOIN [cls].[Category] AS c ON r.SubCategoryId = c.SubCategoryId
		JOIN [dbo].[Account] AS a ON r.SubAccountUid = a.SubAccountUid
	WHERE ((@LastSyncTimestamp IS NULL AND r.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND r.UpdatedAt >= @LastSyncTimestamp))
END
