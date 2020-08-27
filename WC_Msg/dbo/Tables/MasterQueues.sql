CREATE TABLE [dbo].[MasterQueues] (
    [AccountId]   NVARCHAR (50)  NOT NULL,
    [MessageType] NVARCHAR (50)  NOT NULL,
    [Queuename]   NVARCHAR (MAX) NOT NULL,
    [nbThreads]   INT            NOT NULL,
    CONSTRAINT [PK_MasterQueues] PRIMARY KEY CLUSTERED ([AccountId] ASC, [MessageType] ASC)
);

