CREATE TABLE [sms].[SmsLogConnMessageId] (
    [Id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [ConnUid]       INT              NOT NULL,
    [ConnMessageId] VARCHAR (50)     NOT NULL,
    [UMID]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_SmsLogConnMessageId] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SmsLogConnMessageId_ConnUid_ConnMessageId]
    ON [sms].[SmsLogConnMessageId]([ConnUid] ASC, [ConnMessageId] ASC);

