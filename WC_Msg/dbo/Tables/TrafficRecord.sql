CREATE TABLE [dbo].[TrafficRecord] (
    [UMID]               VARCHAR (50)    NOT NULL,
    [SubAccountId]       NVARCHAR (50)   NOT NULL,
    [RouteIdUsed]        NVARCHAR (50)   NULL,
    [MessageType]        VARCHAR (50)    NOT NULL,
    [Destination]        VARCHAR (50)    NOT NULL,
    [Source]             VARCHAR (50)    NOT NULL,
    [Body]               NVARCHAR (MAX)  NULL,
    [OriginalBody]       NVARCHAR (MAX)  NULL,
    [Encoding]           VARCHAR (50)    NOT NULL,
    [Tariff]             DECIMAL (18, 5) CONSTRAINT [DF_TrafficRecord_Tariff_2] DEFAULT ((0)) NOT NULL,
    [RegisteredDelivery] INT             NOT NULL,
    [DateTimeStamp]      DATETIME        NOT NULL,
    [DateTimeUpdated]    DATETIME        NULL,
    [ScheduledDateTime]  DATETIME        NULL,
    [OperatorId]         VARCHAR (50)    NULL,
    [IsEncrypted]        BIT             NOT NULL,
    [Attempt]            INT             NOT NULL,
    [WapUrl]             NVARCHAR (MAX)  NULL,
    [DeliveryMethod]     VARCHAR (50)    NOT NULL,
    [AdditionalInfo]     NVARCHAR (MAX)  NOT NULL,
    [CorrelationId]      NVARCHAR (50)   NULL,
    [Status]             VARCHAR (50)    NULL,
    [Cost]               DECIMAL (18, 5) NULL,
    [Price]              DECIMAL (18, 5) NULL,
    [ProtocolSource]     NVARCHAR (4)    CONSTRAINT [DF_TrafficRecord_protocolSource] DEFAULT ('HTTP') NOT NULL,
    [messageClass]       SMALLINT        CONSTRAINT [DF_TrafficRecord_messageClass] DEFAULT ('1') NULL,
    [ErrorCode]          NVARCHAR (MAX)  NULL,
    [OriginalSource]     VARCHAR (50)    NULL
);


GO
CREATE CLUSTERED INDEX [IX_TrafficRecord_SubAccountId_UMID]
    ON [dbo].[TrafficRecord]([SubAccountId] ASC, [UMID] ASC);


GO
CREATE NONCLUSTERED INDEX [_corelationUMIDIndex_2]
    ON [dbo].[TrafficRecord]([CorrelationId] ASC, [UMID] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_TrafficRecord_5_1525580473__K12_K22_K2_K5_K4_K3_23_24_2]
    ON [dbo].[TrafficRecord]([DateTimeStamp] ASC, [Status] ASC, [SubAccountId] ASC, [Destination] ASC, [MessageType] ASC, [RouteIdUsed] ASC)
    INCLUDE([Cost], [Price]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_TrafficRecord_5_1525580473__K12_K5_K2_K4_K6_22_2]
    ON [dbo].[TrafficRecord]([DateTimeStamp] ASC, [Destination] ASC, [SubAccountId] ASC, [MessageType] ASC, [Source] ASC)
    INCLUDE([Status]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_TrafficRecord_datetimestamp]
    ON [dbo].[TrafficRecord]([DateTimeStamp] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_TrafficRecord_Status_DateTimeStamp]
    ON [dbo].[TrafficRecord]([Status] ASC, [DateTimeStamp] ASC)
    INCLUDE([UMID], [SubAccountId]);


GO
CREATE NONCLUSTERED INDEX [IX_TrafficRecord_Covering]
    ON [dbo].[TrafficRecord]([SubAccountId] ASC, [RouteIdUsed] ASC, [Status] ASC, [MessageType] ASC, [DateTimeStamp] ASC)
    INCLUDE([OperatorId]);


GO
CREATE NONCLUSTERED INDEX [IX_TrafficRecord_SUBACCOUNT_DESTINATION_MESSAGETYPE]
    ON [dbo].[TrafficRecord]([SubAccountId] ASC, [Destination] ASC, [MessageType] ASC);


GO
CREATE TRIGGER [dbo].[ArchiveTF] on [dbo].[TrafficRecord] for delete
AS
begin
	insert into dbo.trafficRecordArchive
	select * from deleted
end

GO
DISABLE TRIGGER [dbo].[ArchiveTF]
    ON [dbo].[TrafficRecord];

