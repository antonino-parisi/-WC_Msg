-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2018-02-22
-- =============================================
-- EXEC map.[CustomerGroupCoverage_Delete] @CoverageId = 2, @UpdatedBy = 1
CREATE PROCEDURE [map].[CustomerGroupCoverage_Delete]
	@CoverageId int,		--filter
	@UpdatedBy smallint
AS
BEGIN

	-- Main update
	UPDATE rt.CustomerGroupCoverage 
	SET 
		Deleted = 1,
		UpdatedAt = SYSUTCDATETIME(), 
		UpdatedBy = @UpdatedBy
	WHERE CoverageId = @CoverageId

END
