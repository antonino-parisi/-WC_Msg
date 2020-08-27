CREATE TABLE [cp].[UserRole] (
    [RoleId]   TINYINT      NOT NULL,
    [RoleName] VARCHAR (50) NOT NULL,
    [Product]  VARCHAR (3)  NOT NULL,
    CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED ([RoleId] ASC),
    CONSTRAINT [UIX_UserRole_RoleName] UNIQUE NONCLUSTERED ([RoleName] ASC)
);

