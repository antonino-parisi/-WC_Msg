CREATE TABLE [cls].[ClassificationRule] (
    [RuleId]        INT           IDENTITY (1, 1) NOT NULL,
    [SubAccountUid] INT           NOT NULL,
    [Country]       CHAR (2)      NULL,
    [SubCategoryId] SMALLINT      NOT NULL,
    [Deleted]       BIT           CONSTRAINT [DF_clsClassificationRule_Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2) CONSTRAINT [DF_clsClassificationRule_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_clsClassificationRule] PRIMARY KEY CLUSTERED ([RuleId] ASC),
    CONSTRAINT [FK_ClassificationRule_Category] FOREIGN KEY ([SubCategoryId]) REFERENCES [cls].[Category] ([SubCategoryId])
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-08-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [cls].[ClassificationRule_DataChanged] 
   ON  [cls].[ClassificationRule] 
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'cls.Classifier'

	IF EXISTS (SELECT 1 FROM inserted)
		UPDATE f
		SET [UpdatedAt] = SYSUTCDATETIME()
		FROM [cls].[ClassificationRule] AS f
			INNER JOIN inserted AS i ON f.RuleId = i.RuleId
END
