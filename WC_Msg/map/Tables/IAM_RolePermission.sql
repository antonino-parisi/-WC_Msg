CREATE TABLE [map].[IAM_RolePermission] (
    [AccessRole]       VARCHAR (20) NOT NULL,
    [AccessPermission] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_mapIAM_RolePermission] PRIMARY KEY CLUSTERED ([AccessRole] ASC, [AccessPermission] ASC),
    CONSTRAINT [FK_IAM_RolePermission_IAM_Permission] FOREIGN KEY ([AccessPermission]) REFERENCES [map].[IAM_Permission] ([AccessPermission]),
    CONSTRAINT [FK_IAM_RolePermission_IAM_RolePermission] FOREIGN KEY ([AccessRole]) REFERENCES [map].[IAM_Role] ([AccessRole])
);

