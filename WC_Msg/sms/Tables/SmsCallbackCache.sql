CREATE TABLE [sms].[SmsCallbackCache] (
    [UMID]        UNIQUEIDENTIFIER NOT NULL,
    [CallbackUrl] VARCHAR (2000)   NOT NULL,
    CONSTRAINT [PK_SmsCallbackCache] PRIMARY KEY CLUSTERED ([UMID] ASC)
);

