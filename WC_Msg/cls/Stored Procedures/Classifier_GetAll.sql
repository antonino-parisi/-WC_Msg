
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-08-18
-- Description: Load Classification Rules for Classifier V2
-- =============================================
CREATE PROCEDURE [cls].[Classifier_GetAll]
AS
BEGIN
	
	SELECT 
		cpd.PatternId,
		NULL AS SubAccountUid, 
		cpd.Country, 
		cpd.SenderId, 
		cpd.BodyPattern, 
		c.Category, 
		c.SubCategory, 
		c.[Priority]
	FROM cls.ClassificationPatternDefault AS cpd
		INNER JOIN cls.Category AS c ON cpd.SubCategoryId = c.SubCategoryId
	WHERE cpd.Deleted = 0 AND c.Deleted = 0
	
	UNION

	SELECT 
		cp.PatternId,
		cl.SubAccountUid, 
		cl.Country, 
		cp.SenderId, 
		cp.BodyPattern, 
		c.Category,
		c.SubCategory, 
		c.[Priority]
	FROM cls.ClassificationRule AS cl
		INNER JOIN cls.ClassificationPattern AS cp ON cl.RuleId = cp.RuleId
		INNER JOIN cls.Category c ON c.SubCategoryId = cl.SubCategoryId
	WHERE cl.Deleted = 0 AND cp.Deleted = 0 AND c.Deleted = 0

END
