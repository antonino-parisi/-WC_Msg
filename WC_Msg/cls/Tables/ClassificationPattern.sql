CREATE TABLE [cls].[ClassificationPattern] (
    [PatternId]   INT            IDENTITY (1, 1) NOT NULL,
    [RuleId]      INT            NOT NULL,
    [SenderId]    VARCHAR (500)  NULL,
    [BodyPattern] NVARCHAR (500) NULL,
    [Deleted]     BIT            CONSTRAINT [DF_clsClassificationPattern_Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]   DATETIME2 (2)  CONSTRAINT [DF_clsClassificationPattern_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_clsClassificationPattern] PRIMARY KEY CLUSTERED ([PatternId] ASC),
    CONSTRAINT [CK_ClassificationPattern] CHECK ([SenderId] IS NOT NULL OR [BodyPattern] IS NOT NULL),
    CONSTRAINT [FK_ClassificationPattern_ClassificationRule] FOREIGN KEY ([RuleId]) REFERENCES [cls].[ClassificationRule] ([RuleId])
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-08-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [cls].[ClassificationPattern_DataChanged] 
   ON  [cls].[ClassificationPattern] 
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'cls.Classifier'

	IF EXISTS (SELECT 1 FROM inserted)
		UPDATE f
		SET [UpdatedAt] = SYSUTCDATETIME()
		FROM [cls].[ClassificationPattern] f
			INNER JOIN inserted AS i ON f.PatternId = i.PatternId
END
