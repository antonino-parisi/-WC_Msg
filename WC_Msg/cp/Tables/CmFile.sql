CREATE TABLE [cp].[CmFile] (
    [FileId]         UNIQUEIDENTIFIER CONSTRAINT [DF_cpCmFile_FileId] DEFAULT (newsequentialid()) NOT NULL,
    [AccountUid]     UNIQUEIDENTIFIER NOT NULL,
    [FileTypeId]     TINYINT          NOT NULL,
    [FileStateId]    TINYINT          NOT NULL,
    [Filename]       NVARCHAR (100)   NOT NULL,
    [FileLocation]   NVARCHAR (500)   NOT NULL,
    [TotalRows]      INT              NULL,
    [ErrorRows]      INT              NULL,
    [DuplicatedRows] INT              NULL,
    [CreatedAt]      DATETIME         CONSTRAINT [DF_cpCmFile_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]      UNIQUEIDENTIFIER NULL,
    [DeletedAt]      DATETIME         NULL,
    [DeletedBy]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_cpCmFile] PRIMARY KEY CLUSTERED ([FileId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_cpCmFile_AccountUid]
    ON [cp].[CmFile]([AccountUid] ASC) WHERE ([DeletedAt] IS NULL);


GO
CREATE NONCLUSTERED INDEX [IX_cpCmFile_FileStateId_CreatedAt]
    ON [cp].[CmFile]([FileStateId] ASC, [CreatedAt] ASC);

