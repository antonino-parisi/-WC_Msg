CREATE TABLE [cls].[ClassificationPatternDefault] (
    [PatternId]     INT            IDENTITY (1, 1) NOT NULL,
    [SubCategoryId] SMALLINT       NOT NULL,
    [Country]       CHAR (2)       NULL,
    [SenderId]      VARCHAR (500)  NULL,
    [BodyPattern]   NVARCHAR (500) NULL,
    [Deleted]       BIT            CONSTRAINT [DF_clsClassificationPatternDefault_Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2)  CONSTRAINT [DF_clsClassificationPatternDefault_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_clsClassificationPatternDefault] PRIMARY KEY CLUSTERED ([PatternId] ASC),
    CONSTRAINT [CK_ClassificationPatternDefault] CHECK ([SenderId] IS NOT NULL OR [BodyPattern] IS NOT NULL),
    CONSTRAINT [FK_ClassificationPatternDefault_Category] FOREIGN KEY ([SubCategoryId]) REFERENCES [cls].[Category] ([SubCategoryId])
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-08-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [cls].[ClassificationPatternDefault_DataChanged] 
   ON  [cls].[ClassificationPatternDefault] 
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'cls.Classifier'

	IF EXISTS (SELECT 1 FROM inserted)
		UPDATE f
		SET [UpdatedAt] = SYSUTCDATETIME()
		FROM [cls].[ClassificationPatternDefault] AS f
			INNER JOIN inserted AS i ON f.PatternId = i.PatternId
END
