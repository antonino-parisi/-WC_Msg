CREATE TABLE [ms].[MsisdnBlacklist] (
    [FilterId]      INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]    UNIQUEIDENTIFIER NULL,
    [SubAccountUid] INT              NULL,
    [Msisdn]        BIGINT           NOT NULL,
    CONSTRAINT [PK_MSISDNBlacklist] PRIMARY KEY CLUSTERED ([FilterId] ASC),
    CONSTRAINT [CK_MSISDNBlacklist_SubAccountUid] CHECK ([SubAccountUid] IS NULL OR [SubAccountUid] IS NOT NULL AND [AccountUid] IS NOT NULL)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-11-08
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[MSISDNBlacklist_DataChanged]
   ON  [ms].[MsisdnBlacklist]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.MSISDNBlacklist'
END
