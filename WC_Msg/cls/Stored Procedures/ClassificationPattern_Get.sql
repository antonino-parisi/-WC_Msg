-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-07
-- =============================================
-- EXEC [cls].[ClassificationPattern_Get]
CREATE PROCEDURE [cls].[ClassificationPattern_Get]
	@LastSyncTimeStamp datetime2(2) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SELECT p.PatternId, p.RuleId, c.SubCategory, r.SubAccountUid, a.SubAccountId, r.Country, p.SenderId, p.BodyPattern, p.Deleted
	FROM [cls].[ClassificationPattern] AS p
		INNER JOIN [cls].[ClassificationRule] AS r ON p.RuleId = r.RuleId
		INNER JOIN [cls].[Category] AS c ON r.SubCategoryId = c.SubCategoryId
		INNER JOIN [dbo].[Account] AS a ON r.SubAccountUid = a.SubAccountUid
	WHERE ((@LastSyncTimestamp IS NULL AND p.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND p.UpdatedAt >= @LastSyncTimestamp))
END
