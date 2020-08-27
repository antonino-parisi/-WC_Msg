-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-29
-- Description:	Rounddown time to interval
-- =============================================
-- SELECT dbo.fnTimeRoundDown(GETUTCDATE(), 10) as Time
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 21/11/2018  Rebecca  Amended to make it simpler
CREATE FUNCTION [dbo].[fnTimeRoundDown]
(
	@Time datetime,
	@IntervalInMins smallint
)
RETURNS smalldatetime
AS
BEGIN
	RETURN DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Time) / @IntervalInMins * @IntervalInMins, 0);
END
