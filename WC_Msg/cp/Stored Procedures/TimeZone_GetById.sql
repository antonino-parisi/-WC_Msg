
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-18
-- =============================================
-- EXEC cp.TimeZone_GetById @TimeZoneId = 10
CREATE PROCEDURE [cp].[TimeZone_GetById]
	@TimeZoneId smallint
AS
BEGIN

	SELECT TimeZoneId, Country, TimeZoneName, Abbreviation, GMTOffset, Dst
	FROM mno.TimeZone
	WHERE TimeZoneId = @TimeZoneId
END

