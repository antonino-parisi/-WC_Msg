CREATE TABLE [optimus].[SenderMaskingRules] (
    [RuleId]             INT            IDENTITY (1, 1) NOT NULL,
    [Country]            CHAR (2)       NOT NULL,
    [OperatorId]         INT            NULL,
    [RouteId]            VARCHAR (50)   NULL,
    [CustomerType]       CHAR (1)       NULL,
    [AccountId]          VARCHAR (50)   NULL,
    [SubAccountId]       VARCHAR (50)   NULL,
    [SenderIdFilterType] VARCHAR (2)    CONSTRAINT [DF_SenderMaskingRules_SenderIdFilterType] DEFAULT ('P') NULL,
    [OriginalSenderId]   NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CS_AS CONSTRAINT [DF_SenderMaskingRules_OriginalSenderId] DEFAULT (N'.+') NOT NULL,
    [Priority]           TINYINT        CONSTRAINT [DF_SenderMaskingRules_Priority] DEFAULT ((0)) NOT NULL,
    [NewSenderId]        NVARCHAR (22)  NULL,
    [NewSenderPoolId]    SMALLINT       NULL,
    [UpdatedAt]          DATETIME2 (2)  CONSTRAINT [DF_SenderMaskingRules_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]            BIT            CONSTRAINT [DF_SenderMaskingRules_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SenderMaskingRules] PRIMARY KEY CLUSTERED ([RuleId] ASC),
    CONSTRAINT [CK_SenderMaskingRules_SenderIdFilterType] CHECK ([SenderIdFilterType]='TI' OR [SenderIdFilterType]='TS' OR [SenderIdFilterType]='PS' OR [SenderIdFilterType]='PI' OR [SenderIdFilterType]='P' OR [SenderIdFilterType]='T'),
    CONSTRAINT [CK_SenderMaskingRules_SubAccount] CHECK ([SubAccountId] IS NULL OR [SubAccountId] IS NOT NULL AND [AccountId] IS NOT NULL),
    CONSTRAINT [FK_SenderMaskingRules_Account] FOREIGN KEY ([SubAccountId]) REFERENCES [dbo].[Account] ([SubAccountId]),
    CONSTRAINT [FK_SenderMaskingRules_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_SenderMaskingRules_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CarrierConnections] ([RouteId]),
    CONSTRAINT [FK_SenderMaskingRules_SenderRotationPool] FOREIGN KEY ([NewSenderPoolId]) REFERENCES [optimus].[SenderRotationPool] ([SenderPoolId]),
    CONSTRAINT [UIX_SenderMaskingRules] UNIQUE NONCLUSTERED ([Country] ASC, [OperatorId] ASC, [RouteId] ASC, [CustomerType] ASC, [AccountId] ASC, [SubAccountId] ASC, [OriginalSenderId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [optimus].[SenderMaskingRules_DataChanged]
   ON [optimus].[SenderMaskingRules]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	UPDATE f SET UpdatedAt = SYSUTCDATETIME()
	FROM [optimus].[SenderMaskingRules] f
		INNER JOIN inserted AS i ON f.RuleId = i.RuleId
	
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'Optimus.SenderId.Rules'
END
