CREATE TABLE [ms].[ClusterGroup] (
    [ClusterGroupId] VARCHAR (20) NOT NULL,
    [Host]           VARCHAR (50) NULL,
    CONSTRAINT [IX_ClusterGroup_Host] UNIQUE NONCLUSTERED ([Host] ASC)
);

