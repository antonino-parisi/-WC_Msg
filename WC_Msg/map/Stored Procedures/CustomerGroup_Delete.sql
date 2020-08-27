-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-12-13
-- =============================================
-- EXEC map.CustomerGroup_Delete @CustomerGroupId=123
CREATE PROCEDURE [map].[CustomerGroup_Delete]
	@CustomerGroupId int
AS
BEGIN

	UPDATE rt.CustomerGroup
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHERE CustomerGroupId = @CustomerGroupId

END
