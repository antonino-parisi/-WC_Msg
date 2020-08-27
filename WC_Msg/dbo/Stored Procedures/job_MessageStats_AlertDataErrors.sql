
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-06-04
-- Description:	Sending alert for wrong Cost in db
-- =============================================
CREATE PROCEDURE [dbo].[job_MessageStats_AlertDataErrors]
AS
BEGIN
	
	DECLARE @ErrorCount int
	
	SELECT @ErrorCount = COUNT(*) 
	FROM dbo.MessageStats s (NOLOCK)
	WHERE s.date >= DATEADD(WEEK, -2, GETUTCDATE()) AND s.Cost / s.TotalMessage > 900

	IF (@ErrorCount > 0)
	BEGIN
		DECLARE @xml NVARCHAR(MAX)
		
		SET @xml = CAST((
			SELECT TOP 100
				s.[Date]		AS 'td','', 
				s.SubAccountId	AS 'td','',
				s.country		AS 'td','',
				s.OperatorName	AS 'td','', 
				s.Cost	AS 'td',''
			FROM dbo.MessageStats s
			WHERE s.date >= DATEADD(WEEK, -2, GETUTCDATE()) AND s.Cost / s.TotalMessage > 900
		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))
		--PRINT @xml

		DECLARE @body NVARCHAR(MAX)
		SET @body ='<H4>Records with wrong Cost</H4>
			<table border = 1>
			<tr>
				<th> Date </th>
				<th> SubAccount </th>
				<th> Country </th>
				<th> Operator </th>
				<th> Cost </th>
			</tr>'

		SET @body ='<html><body>Total errors in stats: '+ cast(@ErrorCount as varchar(50)) + @body + @xml +'</table></body></html>'

		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'Email Alert', 
			@body = @body,
			@body_format ='HTML',
			@importance ='High',
			@recipients = 'dev@wavecell.com',
			@subject = 'MessageStats Data Warning';
	
	END
END
