CREATE TABLE [ipm].[WhatsAppMedia] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [ChannelId]      UNIQUEIDENTIFIER NOT NULL,
    [Url]            NVARCHAR (1000)  NOT NULL,
    [CreatedAt]      DATETIME2 (2)    CONSTRAINT [DF_WhatsAppMedia_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [SetInProcessAt] DATETIME2 (2)    NULL,
    CONSTRAINT [PK_WhatsAppMedia] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_WhatsAppMedia_Channel] FOREIGN KEY ([ChannelId]) REFERENCES [ipm].[Channel] ([ChannelId])
);


GO
CREATE NONCLUSTERED INDEX [IX_WhatsAppMedia_CreatedAt_SetInProcessAt]
    ON [ipm].[WhatsAppMedia]([CreatedAt] ASC, [SetInProcessAt] ASC);

