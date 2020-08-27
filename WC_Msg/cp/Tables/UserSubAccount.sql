CREATE TABLE [cp].[UserSubAccount] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [UserId]        UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid] INT              NOT NULL,
    CONSTRAINT [PK_UserSubAccount] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [UIX_UserSubAccount_UserId_SubAccountUid]
    ON [cp].[UserSubAccount]([UserId] ASC, [SubAccountUid] ASC);

