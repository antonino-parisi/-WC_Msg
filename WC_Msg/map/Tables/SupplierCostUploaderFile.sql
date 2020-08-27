CREATE TABLE [map].[SupplierCostUploaderFile] (
    [FileId]     INT           IDENTITY (1, 1) NOT NULL,
    [FilePath]   VARCHAR (500) NOT NULL,
    [ItemsSaved] INT           NOT NULL,
    [ItemsError] INT           NOT NULL,
    [CreatedAt]  DATETIME2 (2) CONSTRAINT [DF_SupplierCostUploaderFile_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CreatedBy]  SMALLINT      NOT NULL,
    CONSTRAINT [PK_SupplierCostUploaderFile] PRIMARY KEY CLUSTERED ([FileId] ASC)
);

