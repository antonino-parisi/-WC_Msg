CREATE TABLE [cp].[CmFileType] (
    [FileTypeId]     TINYINT      NOT NULL,
    [FileTypeName]   VARCHAR (50) NOT NULL,
    [FIleCategoryId] TINYINT      CONSTRAINT [DF_CmFileType_FIleCategoryId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_cpCmFileType] PRIMARY KEY CLUSTERED ([FileTypeId] ASC)
);

