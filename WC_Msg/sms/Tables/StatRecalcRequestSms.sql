CREATE TABLE [sms].[StatRecalcRequestSms] (
    [id]   INT              IDENTITY (1, 1) NOT NULL,
    [UMID] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_StatRecalcRequestSms] PRIMARY KEY CLUSTERED ([id] ASC)
);

