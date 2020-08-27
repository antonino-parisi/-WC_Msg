CREATE TABLE [ms].[TableChangesForApp] (
    [App] VARCHAR (50) NOT NULL,
    [Key] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TableChangesForApp] PRIMARY KEY CLUSTERED ([App] ASC, [Key] ASC)
);

