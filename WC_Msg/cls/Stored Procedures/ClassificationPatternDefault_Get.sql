-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-07
-- =============================================
-- EXEC [cls].[ClassificationPatternDefault_Get]
CREATE PROCEDURE [cls].[ClassificationPatternDefault_Get]
	@LastSyncTimeStamp datetime2(2) = NULL
AS
BEGIN
	SELECT p.PatternId, p.SubCategoryId, c.SubCategory, p.Country, p.SenderId, p.BodyPattern, p.Deleted
	FROM [cls].[ClassificationPatternDefault] AS p
		JOIN [cls].[Category] AS c ON p.SubCategoryId = c.SubCategoryId
	WHERE ((@LastSyncTimestamp IS NULL AND p.Deleted = 0) OR (@LastSyncTimestamp IS NOT NULL AND p.UpdatedAt >= @LastSyncTimestamp))
END
