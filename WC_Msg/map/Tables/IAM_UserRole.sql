CREATE TABLE [map].[IAM_UserRole] (
    [UserId]     SMALLINT     NOT NULL,
    [AccessRole] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_mapUserRole] PRIMARY KEY CLUSTERED ([UserId] ASC, [AccessRole] ASC),
    CONSTRAINT [FK_IAM_UserRole_IAM_Role] FOREIGN KEY ([AccessRole]) REFERENCES [map].[IAM_Role] ([AccessRole]),
    CONSTRAINT [FK_UserRole_User] FOREIGN KEY ([UserId]) REFERENCES [map].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [IX_mapUserRole]
    ON [map].[IAM_UserRole]([UserId] ASC);

