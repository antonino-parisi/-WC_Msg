-- =============================================
-- Author:		Nathanael Hinay
-- Create date: 2019-01-16
-- =============================================
CREATE PROCEDURE [cp].[FreeCreditCountry_GetAll]
AS
BEGIN
	SELECT Country
	FROM cp.FreeCreditCountry
END
