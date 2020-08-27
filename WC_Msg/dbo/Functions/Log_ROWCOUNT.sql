-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-005-03
-- Description:	Text for printing
-- =============================================
CREATE FUNCTION [dbo].[Log_ROWCOUNT]
(
	@Text nvarchar(100)
)
RETURNS nvarchar(1000)
AS
BEGIN
	RETURN dbo.CURRENT_TIMESTAMP_STR() + @text + ' | Changed records = ' + CAST(@@ROWCOUNT as varchar(10))
END

