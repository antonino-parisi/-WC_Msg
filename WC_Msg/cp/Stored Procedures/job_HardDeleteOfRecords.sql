-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-02-28
-- Description:	Hard delete for records
-- =============================================
CREATE PROCEDURE cp.job_HardDeleteOfRecords
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ExpiredBefore datetime = DATEADD(DAY, -7, GETUTCDATE())

	-- clean CmGroupContact by deleted Group
	DELETE FROM gc 
	FROM cp.CmGroupContact gc INNER JOIN cp.CmGroup g ON g.GroupId = gc.GroupId
	WHERE g.DeletedAt < @ExpiredBefore
	
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmGroupContact for deleted Groups')

	DELETE FROM gc 
	FROM cp.CmGroupContact gc INNER JOIN cp.CmContact c ON c.ContactId = gc.ContactId
	WHERE c.DeletedAt < @ExpiredBefore
	
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmGroupContact for deleted Contacts')

	-- clean Group
	DELETE FROM g FROM cp.CmGroup g WHERE g.DeletedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmGroup')

	-- clean ContactField
	DELETE FROM cf FROM cp.CmContactField cf WHERE cf.DeletedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmContactField')
	
	DELETE FROM cf 
	FROM cp.CmContactField cf INNER JOIN cp.CmContact c ON c.ContactId = cf.ContactId 
	WHERE c.DeletedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmContactField of deleted contacts')
	
	DELETE FROM c FROM cp.CmContact c WHERE c.DeletedAt < @ExpiredBefore
	PRINT [dbo].[Log_ROWCOUNT] ('Deleted CmContact')
	
	EXEC cp.CmSummary_Recalculate
	PRINT [dbo].[Log_ROWCOUNT] ('Summary recalculated')
	
END
