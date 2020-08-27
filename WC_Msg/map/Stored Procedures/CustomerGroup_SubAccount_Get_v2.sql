-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-03-05
-- Updated by:   Raymond Torino
-- Updated date: 2018-03-22
-- =============================================
-- EXEC map.CustomerGroup_SubAccount_Get_v2 @CustomerGroupId = 1
CREATE PROCEDURE [map].[CustomerGroup_SubAccount_Get_v2]
	@CustomerGroupId int,
	@SubAccountId_SearchString varchar(50) = NULL,
	@Offset int = 0,
	@Limit int = 100,
	@Output_Cnt int = 0
AS
BEGIN
	IF @SubAccountId_SearchString IS NOT NULL
		SET @SubAccountId_SearchString = REPLACE(@SubAccountId_SearchString, '_', '\_') ;

	SET @Limit = IIF(@Limit = 0, 9999999, @Limit) ; -- @Limit=0 means return all records

	SELECT cgs.CustomerGroupId, cgs.SubAccountUid, a.SubAccountId, ac.AccountId, cgs.UpdatedAt
	FROM [rt].[CustomerGroupSubAccount] cgs WITH (FORCESEEK)
		INNER JOIN ms.SubAccount a WITH (FORCESEEK) ON cgs.SubAccountUid = a.SubAccountUid
		INNER JOIN cp.Account ac WITH (FORCESEEK) ON a.AccountUid = ac.AccountUid
	WHERE
		cgs.CustomerGroupId = @CustomerGroupId
		AND (@SubAccountId_SearchString IS NULL OR a.SubAccountId LIKE '%'+@SubAccountId_SearchString+'%' ESCAPE '\')
		AND cgs.Deleted = 0
	ORDER BY cgs.UpdatedAt
	OFFSET (@Offset) ROWS FETCH NEXT (@Limit) ROWS ONLY ;

	IF @Output_Cnt =1 
		SELECT CustomerGroupId, COUNT(1) SubAccount_Cnt
		FROM [rt].[CustomerGroupSubAccount]
		WHERE
			CustomerGroupId = @CustomerGroupId
			AND Deleted = 0
		GROUP BY CustomerGroupId ;

END
