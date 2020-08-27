-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-11-22
-- Description:	List of credentials for SMPP integration
-- =============================================
-- EXEC [ms].[AuthSmpp_GetAll]
-- EXEC [ms].[AuthSmpp_GetAll] @Host = 'smpp-client3'
CREATE PROCEDURE [ms].[AuthSmpp_GetAll]
	@Host varchar(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @Host varchar(20) = NULL
	DECLARE @ClusterGroupId varchar(50)
	SET @ClusterGroupId = ms.ClusterGroup_GetByHost(@Host)
	
	SELECT DISTINCT sm.SubAccountId AS SystemId, sm.Password,
		sm.MO_Enabled, sm.MT_DLR_Accept_Enabled, sm.MT_FetchSize,
		sm.DLR_FetchSize, sm.MO_FetchSize, sm.MT_QueueSizeThreshold, sm.DLR_QueueSizeThreshold, sm.MO_QueueSizeThreshold, 
		sm.SmppWindowSize, sm.DLR_CacheSize, sm.AMQ_QoSPrefetch, ISNULL(ISNULL(qc_custom.QueueName, qc_def.QueueName), sm.AMQ_MT_QueueName) AS AMQ_MT_QueueName, sm.ConcatenationRefOnSystemIdLevel,
		sm.HostsAcceptingBinds,
		sm.WindowWaitTimeout, sm.RequestExpiryTimeout,
		sm.ConcatenationKey,
		sm.DlrSkipCountOnWindowError, sm.DlrSkipCountOnRequestError
	FROM ms.AuthSmpp sm
		INNER JOIN dbo.Account a ON a.SubAccountId = sm.SubAccountId AND a.Active = 1
		LEFT JOIN ms.QueueConfig qc_custom ON a.SubAccountUid = qc_custom.SubAccountUid AND qc_custom.QueueRole = 'MT' AND qc_custom.ClusterGroupId_Publish = @ClusterGroupId AND qc_custom.ConnectionName = 'pro-rabbit-def'
		LEFT JOIN ms.QueueConfig qc_def ON a.SubAccountUid = qc_def.SubAccountUid AND qc_def.QueueRole = 'MT' AND qc_def.ClusterGroupId_Publish = 'ANY' AND qc_def.ConnectionName = 'pro-rabbit-def'
	WHERE sm.DeletedAt IS NULL
END