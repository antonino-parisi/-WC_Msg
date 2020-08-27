CREATE TABLE [dbo].[QueueConfig] (
    [Queue]       NVARCHAR (100) NOT NULL,
    [Status]      BIT            NOT NULL,
    [Throttle]    INT            NOT NULL,
    [pause]       BIT            CONSTRAINT [DF_QueueConfig_pause] DEFAULT ((0)) NOT NULL,
    [masterQueue] BIT            CONSTRAINT [DF_QueueConfig_masterQueue] DEFAULT ((0)) NOT NULL,
    [MessageType] NVARCHAR (5)   CONSTRAINT [DF_QueueConfig_MessageType] DEFAULT (N'MT') NOT NULL,
    CONSTRAINT [PK_QueueConfig] PRIMARY KEY CLUSTERED ([Queue] ASC)
);

