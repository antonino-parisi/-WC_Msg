CREATE TABLE [rt].[CustomerGroupSubAccount] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [CustomerGroupId] INT           NOT NULL,
    [SubAccountUid]   INT           NOT NULL,
    [UpdatedAt]       DATETIME2 (2) CONSTRAINT [DF_CustomerGroupSubAccount_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Deleted]         BIT           CONSTRAINT [DF_CustomerGroupSubAccount_Deleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CustomerGroupSubAccount] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_CustomerGroupSubAccount_CustomerGroupSubAccount] FOREIGN KEY ([CustomerGroupId]) REFERENCES [rt].[CustomerGroup] ([CustomerGroupId]),
    CONSTRAINT [UIX_CustomerGroupSubAccount] UNIQUE NONCLUSTERED ([CustomerGroupId] ASC, [SubAccountUid] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_CustomerGroupSubAccount_SubAccount]
    ON [rt].[CustomerGroupSubAccount]([SubAccountUid] ASC) WHERE ([Deleted]=(0));

