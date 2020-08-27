CREATE TABLE [cp].[CmFileState] (
    [FileStateId]   TINYINT      NOT NULL,
    [FileStateName] VARCHAR (50) NOT NULL,
    [OrderNum]      TINYINT      NOT NULL,
    CONSTRAINT [PK_cpCmFileState] PRIMARY KEY CLUSTERED ([FileStateId] ASC)
);

