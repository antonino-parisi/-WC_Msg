CREATE PROCEDURE [map].[CustomerGroup_SubAccount_Delete]
	@CustomerGroupId int,
	@SubAccountUid int
AS
BEGIN

	UPDATE rt.CustomerGroupSubAccount 
	SET Deleted = 1, UpdatedAt = SYSUTCDATETIME()
	WHERE CustomerGroupId = @CustomerGroupId AND SubAccountUid = @SubAccountUid

END
