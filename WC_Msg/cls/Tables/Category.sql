CREATE TABLE [cls].[Category] (
    [SubCategoryId] SMALLINT      NOT NULL,
    [SubCategory]   VARCHAR (20)  NOT NULL,
    [Category]      VARCHAR (3)   NOT NULL,
    [Deleted]       BIT           CONSTRAINT [DF_Category_Deleted] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]     DATETIME2 (2) CONSTRAINT [DF_Category_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Priority]      SMALLINT      DEFAULT ((0)) NULL,
    CONSTRAINT [PK_clsClass] PRIMARY KEY CLUSTERED ([SubCategoryId] ASC),
    CONSTRAINT [UIX_clsCategory_Key] UNIQUE NONCLUSTERED ([SubCategory] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-08-18
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [cls].[Category_DataChanged]
   ON  [cls].[Category]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'cls.Classifier'
END
