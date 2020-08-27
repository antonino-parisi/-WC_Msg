

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-29
-- Description:	Rounddown time to interval
-- =============================================
-- SELECT dbo.fnTimeRountup(GETUTCDATE(), 15) as Time
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 21/11/2018  Rebecca  Amended to fix bug of round up to next hr if time is on the hr

CREATE FUNCTION [dbo].[fnTimeRountup]
(
	@Time datetime,
	@IntervalInMins smallint
)
RETURNS smalldatetime
AS
BEGIN
	RETURN DATEADD(MINUTE, CEILING(DATEDIFF(MINUTE, 0, @Time) / CAST(@IntervalInMins AS NUMERIC(10,1))) * @IntervalInMins, 0);
END

