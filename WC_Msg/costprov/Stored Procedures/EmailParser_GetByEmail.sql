
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-06-10
-- Description:	CostProvisioning process / Define Parser that should be used for process received email 
-- =============================================
CREATE PROCEDURE [costprov].[EmailParser_GetByEmail] (
	@Email varchar(50)
) 
AS
BEGIN
	SELECT ParserId FROM costprov.EmailParser WHERE Email = @Email AND IsActive = 1
END

