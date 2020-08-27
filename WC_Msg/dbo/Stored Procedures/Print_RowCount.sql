

-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2018-11-07
-- =============================================
-- DECLARE @rows INT; EXEC @rows = Print_RowCount @msg = 'insert into XXX', @procid=@@PROCID
-- --@affectedrows output is optional. The procedure can be run as is.
CREATE PROCEDURE [dbo].[Print_RowCount]
	@msg NVARCHAR(200),
	@procid INT = 0
AS  
BEGIN 
	DECLARE @rowcnt INT ;
	DECLARE @procname VARCHAR(200) ;

	SET @rowcnt = @@ROWCOUNT;
	SET @procname = OBJECT_NAME(@PROCID);
	--SET @procname = ISNULL(OBJECT_NAME(@PROCID), '') ;

	PRINT dbo.CURRENT_TIMESTAMP_STR() + IIF(@procname IS NOT NULL, @procname + ' | ', '') + @msg + ' | ROWS = ' + CAST(@rowcnt AS VARCHAR(15)) ;
	RETURN @rowcnt ;
END
