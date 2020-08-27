
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-18
-- =============================================
-- EXEC cp.TimeZone_GetAll
CREATE PROCEDURE [cp].[TimeZone_GetAll]
AS
BEGIN

	SELECT TimeZoneId, Country, TimeZoneName, Abbreviation, GMTOffset, Dst
	FROM mno.TimeZone

END

