CREATE TABLE [optimus].[MessageBodyPrefixMapping_Deprecated] (
    [SubAccountId]      VARCHAR (50)  NOT NULL,
    [OperatorId]        INT           NOT NULL,
    [MessageBodyPrefix] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MessageBodyPrefix] PRIMARY KEY CLUSTERED ([SubAccountId] ASC, [OperatorId] ASC),
    CONSTRAINT [FK_MessageBodyPrefix_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId])
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [optimus].[MessageBodyPrefixMapping_DataChanged]
   ON  [optimus].[MessageBodyPrefixMapping_Deprecated]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'Optimus.MessageBody.Rules'
END
