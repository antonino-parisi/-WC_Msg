
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-08
-- Description:	Update record for Country
-- =============================================
CREATE PROCEDURE [rt].[Country_UpdateJson]
	@CountryISO2alpha char(2),
	@JsonData nvarchar(max)
AS
BEGIN
	UPDATE mno.Country 
	SET JsonData = @JsonData
	WHERE CountryISO2alpha = @CountryISO2alpha
END

