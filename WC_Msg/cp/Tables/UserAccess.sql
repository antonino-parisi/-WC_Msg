CREATE TABLE [cp].[UserAccess] (
    [UserRoleId] INT              IDENTITY (1, 1) NOT NULL,
    [UserId]     UNIQUEIDENTIFIER NOT NULL,
    [RoleId]     TINYINT          NOT NULL,
    [UpdatedAt]  DATETIME2 (2)    CONSTRAINT [DF_UserAccess_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_UserAccess] PRIMARY KEY NONCLUSTERED ([UserRoleId] ASC),
    CONSTRAINT [FK_UserAccess_User] FOREIGN KEY ([UserId]) REFERENCES [cp].[User] ([UserId]),
    CONSTRAINT [FK_UserAccess_UserRole] FOREIGN KEY ([RoleId]) REFERENCES [cp].[UserRole] ([RoleId]),
    CONSTRAINT [UIX_UserAccess_UserId_RoleId_Clustered] UNIQUE CLUSTERED ([UserId] ASC, [RoleId] ASC)
);

