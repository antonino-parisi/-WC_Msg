CREATE TABLE [sms].[DlrLog] (
    [DlrLogId]  BIGINT           IDENTITY (1, 1) NOT NULL,
    [UMID]      UNIQUEIDENTIFIER NOT NULL,
    [StatusId]  TINYINT          NOT NULL,
    [EventTime] DATETIME         CONSTRAINT [DF_DlrLog_DatetimeStamp] DEFAULT (getutcdate()) NOT NULL,
    [Latency]   INT              NOT NULL,
    [Hostname]  VARCHAR (25)     NULL,
    CONSTRAINT [PK_DlrLog] PRIMARY KEY CLUSTERED ([DlrLogId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_DlrLog_EventTime_Status]
    ON [sms].[DlrLog]([EventTime] ASC, [StatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DlrLog_UMID_StatusId]
    ON [sms].[DlrLog]([UMID] ASC, [StatusId] ASC);

