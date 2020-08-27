CREATE TABLE [map].[IAM_PermissionAction] (
    [AccessPermission] VARCHAR (50) NOT NULL,
    [Action]           VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_mapIAM_PermissionAction] PRIMARY KEY CLUSTERED ([AccessPermission] ASC, [Action] ASC),
    CONSTRAINT [FK_IAM_PermissionAction_IAM_Permission] FOREIGN KEY ([AccessPermission]) REFERENCES [map].[IAM_Permission] ([AccessPermission])
);

