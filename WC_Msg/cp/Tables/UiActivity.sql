CREATE TABLE [cp].[UiActivity] (
    [ActivityId] INT              IDENTITY (1, 1) NOT NULL,
    [AccountUid] UNIQUEIDENTIFIER NOT NULL,
    [Message]    NVARCHAR (1000)  NOT NULL,
    [CreatedAt]  DATETIME         CONSTRAINT [DF_UiActivity_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [CreatedBy]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_UiActivity] PRIMARY KEY CLUSTERED ([ActivityId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_UiActivity_AccountUid_CreatedAt]
    ON [cp].[UiActivity]([AccountUid] ASC, [CreatedAt] ASC);

