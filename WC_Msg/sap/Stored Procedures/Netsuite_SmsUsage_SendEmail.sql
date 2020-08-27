-- =============================================
-- Author: Anton Shchekalov
-- Description:	
-- Changes: 
--	2020-08-03 - Created
-- =============================================
-- EXEC sap.Netsuite_SmsUsage_SendEmail @Month = '2020-07-01', @CompanyEntity = '8x8UK', @Recipients = 'anton.shchekalov@8x8.com', @Recipients_Copy = 'atrony@gmail.com;anton.shchekalov@8x8.com'
CREATE PROCEDURE [sap].[Netsuite_SmsUsage_SendEmail]
	@Month DATE,
	@Recipients NVARCHAR(500),
	@Recipients_Copy NVARCHAR(500) =  NULL,
	@CompanyEntity varchar(50),
	@EmailSubject varchar(50) = 'CPaaS SMS Usage export'
AS BEGIN

	DECLARE @sql varchar(1000);
	DECLARE @MonthStr varchar(20) = FORMAT(@Month, 'yyyy-MM')
	DECLARE @EmailSubjectFull varchar(200) = @EmailSubject + ' | ' + @CompanyEntity + ' | ' + @MonthStr
	DECLARE @EmailFile varchar(200) = 'CPaaS-SMS-Usage ' + @CompanyEntity + ' ' + @MonthStr + '.csv'
	
	SET @sql = 
		'SET NOCOUNT ON; ' +
		'EXEC [' + DB_NAME() + '].sap.Netsuite_SmsUsage_Export '
		+ '@Month = ''' + @MonthStr + '-01'', '
		+ '@CompanyEntity = ''' + @CompanyEntity + '''; ' + 
		'SET NOCOUNT OFF;';

	PRINT @sql

	EXEC msdb.dbo.sp_send_dbmail  
		@recipients =  @Recipients,
		@copy_recipients = @Recipients_Copy,
		@query = @sql,
		@subject = @EmailSubjectFull, 
		@body = 'This is a SMS usage data to be uploaded to Netsuite for invoicing POSTPAID CPaaS customers',
		@attach_query_result_as_file = 1,
		@query_attachment_filename = @EmailFile,
		@query_result_header = 1,
		@exclude_query_output = 1,
		@query_result_no_padding = 1,
		@query_result_separator = ',',
		@append_query_error = 0,
		@sensitivity = 'Confidential',
		@from_address = 'no-reply@wavecell.com';

	RETURN 0;
END
