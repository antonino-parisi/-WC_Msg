CREATE TABLE [ms].[TableChanges] (
    [Key]            VARCHAR (50) NOT NULL,
    [LastChangeTime] DATETIME     CONSTRAINT [DF_TableChanges_LastChangeTime] DEFAULT (getutcdate()) NOT NULL,
    [ToClearCache]   BIT          CONSTRAINT [DF_TableChanges_ToClearCache] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TableChanges] PRIMARY KEY CLUSTERED ([Key] ASC)
);

