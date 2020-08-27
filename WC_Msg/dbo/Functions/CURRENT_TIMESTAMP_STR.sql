
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-03
-- Description:	Current time for logging
-- =============================================
CREATE FUNCTION [dbo].[CURRENT_TIMESTAMP_STR]()
RETURNS VARCHAR(30)
AS
BEGIN

	RETURN (CONVERT( VARCHAR(24), CURRENT_TIMESTAMP, 121)) + ' | '

END

