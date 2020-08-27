CREATE TABLE [ms].[MsisdnWhitelist] (
    [FilterId]      INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid]    UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid] INT              NULL,
    [Msisdn]        BIGINT           NOT NULL,
    CONSTRAINT [PK_MSISDNWhitelist] PRIMARY KEY CLUSTERED ([FilterId] ASC)
);


GO
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2019-01-16
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[MSISDNWhitelist_DataChanged]
   ON  [ms].[MsisdnWhitelist]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.MSISDNWhitelist'
END
