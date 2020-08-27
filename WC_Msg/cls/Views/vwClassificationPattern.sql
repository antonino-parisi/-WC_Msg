
CREATE VIEW cls.vwClassificationPattern
AS
	SELECT cp.PatternId,
		   cp.RuleId,
		   cp.SenderId,
		   cp.BodyPattern,
		   cp.Deleted AS Pattern_Deleted,
		   cp.UpdatedAt,
		   cr.SubAccountUid,
		   cr.Country,
		   cr.SubCategoryId,
		   cr.Deleted AS Rule_Deleted,
		   sa.SubAccountId,
		   sa.AccountId,
		   sa.AccountUid,
		   c.SubCategory,
		   c.Category,
		   c.Priority
	FROM cls.ClassificationPattern cp (NOLOCK)
		INNER JOIN cls.ClassificationRule cr (NOLOCK) ON cr.RuleId = cp.RuleId
		INNER JOIN ms.vwSubAccount sa ON cr.SubAccountUid = sa.SubAccountUid
		INNER JOIN cls.Category c ON cr.SubCategoryId = c.SubCategoryId
