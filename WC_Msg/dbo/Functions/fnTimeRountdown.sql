-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-29
-- Description:	Rounddown time to interval
-- =============================================
-- SELECT dbo.fnTimeRountdown(GETUTCDATE(), 10) as Time
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 21/11/2018  Rebecca  Amended to make it simpler
-- SELECT [dbo].[fnTimeRountdown] ('2018-11-20 11:14:59', 15)
CREATE FUNCTION [dbo].[fnTimeRountdown]
(
	@Time datetime,
	@IntervalInMins smallint
)
RETURNS smalldatetime
AS
BEGIN
	RETURN DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Time) / @IntervalInMins * @IntervalInMins, 0);
END
