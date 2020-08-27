-- =============================================
-- Author:		Maxim Tkachenko	
-- Create date: 2018-09-07
-- Description:	Get queue configuration for MTADD, MTUPD, MOADD, MOUPD queues
-- =============================================
-- EXEC [ms].[QueueConfig_SmsWriteToDbConsume] @Host = 'PRO-SMS3'
CREATE PROCEDURE [ms].[QueueConfig_SmsWriteToDbConsume]
	@Host varchar(20) = NULL
AS
BEGIN
	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)

	SELECT
		ConnectionName,
		QueueName,
		QueueRole,
		Priority,
		BufferSize,
		ThreadCount,
		SubAccountUid
	FROM ms.QueueConfig conf	
	WHERE QueueRole IN ('MTADD', 'MTUPD', 'MOADD', 'MOUPD', 'FDBK') 
		AND ClusterGroupId_Consumer IN ('ANY', @ClusterGroupId)
END
