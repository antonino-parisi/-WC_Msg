-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2020-01-22
-- Description:	Get company entity
-- =============================================
-- EXEC map.CompanyEntity_GetAll

CREATE PROCEDURE map.CompanyEntity_GetAll
AS
BEGIN

	SELECT CompanyEntity, Country, CompanyName
	FROM ms.DimCompanyEntity ;

END
