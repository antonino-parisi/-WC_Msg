CREATE TABLE [cp].[CmGroup] (
    [GroupId]          INT              IDENTITY (1, 1) NOT NULL,
    [GroupName]        NVARCHAR (100)   NOT NULL,
    [GroupDescription] NVARCHAR (1000)  NULL,
    [AccountUid]       UNIQUEIDENTIFIER NOT NULL,
    [ContactsCount]    INT              CONSTRAINT [DF_cpCmGroup_Count] DEFAULT ((0)) NULL,
    [CreatedAt]        DATETIME2 (2)    CONSTRAINT [DF_cpCmGroup_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CreatedBy]        UNIQUEIDENTIFIER NULL,
    [DeletedAt]        DATETIME2 (2)    NULL,
    [DeletedBy]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_cpCmGroup] PRIMARY KEY CLUSTERED ([GroupId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_cpCmGroup_AccountUid_DeletedAt]
    ON [cp].[CmGroup]([AccountUid] ASC, [DeletedAt] ASC)
    INCLUDE([GroupId]) WHERE ([DeletedAt] IS NULL);

