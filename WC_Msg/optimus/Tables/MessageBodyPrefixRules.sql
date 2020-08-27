CREATE TABLE [optimus].[MessageBodyPrefixRules] (
    [RuleId]         INT          IDENTITY (1, 1) NOT NULL,
    [Country]        CHAR (2)     NOT NULL,
    [OperatorId]     INT          NULL,
    [AccountId]      VARCHAR (50) NULL,
    [SubAccountId]   VARCHAR (50) NULL,
    [RouteId]        VARCHAR (50) NULL,
    [Priority]       TINYINT      NOT NULL,
    [Prefix]         VARCHAR (50) NOT NULL,
    [ExcludePattern] VARCHAR (50) NULL,
    CONSTRAINT [PK_MessageBodyPrefixRules] PRIMARY KEY CLUSTERED ([RuleId] ASC),
    CONSTRAINT [FK_MessageBodyPrefixRules_Account] FOREIGN KEY ([SubAccountId]) REFERENCES [dbo].[Account] ([SubAccountId]),
    CONSTRAINT [FK_MessageBodyPrefixRules_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [FK_MessageBodyPrefixRules_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CarrierConnections] ([RouteId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_MessageBodyPrefixRules]
    ON [optimus].[MessageBodyPrefixRules]([Country] ASC, [OperatorId] ASC, [AccountId] ASC, [SubAccountId] ASC, [RouteId] ASC, [Prefix] ASC, [ExcludePattern] ASC);


GO
-- =============================================
-- Author:		Maxim Tkachenko
-- Create date: 2016-09-21
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [optimus].[MessageBodyPrefixRules_DataChanged]
   ON  [optimus].[MessageBodyPrefixRules]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'optimus.MessageBodyPrefixRules'
END
