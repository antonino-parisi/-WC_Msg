CREATE TABLE [ms].[AuthSmpp] (
    [SubAccountId]                    VARCHAR (50)  NOT NULL,
    [Password]                        VARCHAR (50)  NOT NULL,
    [MO_Enabled]                      BIT           CONSTRAINT [DF_AuthSmpp_MO_Enabled] DEFAULT ((0)) NOT NULL,
    [MT_DLR_Accept_Enabled]           BIT           CONSTRAINT [DF_AuthSmpp_MT_DLR_Accept_Enabled] DEFAULT ((0)) NOT NULL,
    [MT_FetchSize]                    SMALLINT      NOT NULL,
    [DLR_FetchSize]                   SMALLINT      NOT NULL,
    [MO_FetchSize]                    SMALLINT      NOT NULL,
    [MT_QueueSizeThreshold]           SMALLINT      CONSTRAINT [DF_AuthSmpp_MT_QueueSizeThreshold] DEFAULT ((500)) NOT NULL,
    [DLR_QueueSizeThreshold]          SMALLINT      CONSTRAINT [DF_AuthSmpp_DLR_QueueSizeThreshold] DEFAULT ((500)) NOT NULL,
    [MO_QueueSizeThreshold]           SMALLINT      CONSTRAINT [DF_AuthSmpp_MO_QueueSizeThreshold] DEFAULT ((500)) NOT NULL,
    [DLR_CacheSize]                   SMALLINT      CONSTRAINT [DF_AuthSmpp_DLR_CacheSize] DEFAULT ((36)) NOT NULL,
    [AMQ_QoSPrefetch]                 SMALLINT      CONSTRAINT [DF_AuthSmpp_AMQ_QoSPrefetch] DEFAULT ((12)) NOT NULL,
    [AMQ_MT_QueueName]                VARCHAR (50)  NULL,
    [SmppWindowSize]                  SMALLINT      CONSTRAINT [DF_AuthSmpp_SmppWindowSize] DEFAULT ((10)) NOT NULL,
    [ConcatenationRefOnSystemIdLevel] BIT           CONSTRAINT [DF_AuthSmpp_ConcatenationRefOnSystemidLevel] DEFAULT ((1)) NOT NULL,
    [HostsAcceptingBinds]             VARCHAR (100) NULL,
    [CreatedAt]                       DATETIME      CONSTRAINT [DF_AuthSmpp_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [LastUsedAt]                      DATETIME      NULL,
    [DeletedAt]                       DATETIME      NULL,
    [WindowWaitTimeout]               BIGINT        CONSTRAINT [DF_AuthSmpp_WindowWaitTimeout] DEFAULT ((5000)) NOT NULL,
    [RequestExpiryTimeout]            BIGINT        CONSTRAINT [DF_AuthSmpp_RequestExpiryTimeout] DEFAULT ((2000)) NOT NULL,
    [ConcatenationKey]                VARCHAR (50)  NULL,
    [DlrSkipCountOnWindowError]       SMALLINT      CONSTRAINT [DF_AuthSmpp_DlrSkipCountOnWindowError] DEFAULT ((0)) NOT NULL,
    [DlrSkipCountOnRequestError]      SMALLINT      CONSTRAINT [DF_AuthSmpp_DlrSkipCountOnRequestError] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AuthSmpp] PRIMARY KEY CLUSTERED ([SubAccountId] ASC),
    CONSTRAINT [FK_AuthSmpp_Account] FOREIGN KEY ([SubAccountId]) REFERENCES [dbo].[Account] ([SubAccountId]),
    CONSTRAINT [IX_AuthSmpp] UNIQUE NONCLUSTERED ([SubAccountId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-21
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[AuthSmpp_DataChanged]
   ON  [ms].[AuthSmpp]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.AuthSmpp'
END

GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = N'C64ABA7B-3A3E-95B6-535D-3BC535DA5A59', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = N'Credentials', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = N'331F0B13-76B5-2F1B-A77B-DEF5A73C73C2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = N'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_id', @value = 'd22fa6e9-5ee4-3bde-4c2b-a409604c4646', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'RequestExpiryTimeout';


GO
EXECUTE sp_addextendedproperty @name = N'sys_information_type_name', @value = 'Credit Card', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'RequestExpiryTimeout';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_id', @value = '331f0b13-76b5-2f1b-a77b-def5a73c73c2', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'RequestExpiryTimeout';


GO
EXECUTE sp_addextendedproperty @name = N'sys_sensitivity_label_name', @value = 'Confidential', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'AuthSmpp', @level2type = N'COLUMN', @level2name = N'RequestExpiryTimeout';

