CREATE TABLE [sms].[SmsLogClientMessageId] (
    [UMID]            UNIQUEIDENTIFIER NOT NULL,
    [ClientMessageId] VARCHAR (350)    NOT NULL,
    CONSTRAINT [PK_SmsLogClientMessageId] PRIMARY KEY CLUSTERED ([UMID] ASC)
);

