CREATE TABLE [dbo].[TrafficRecordArchive] (
    [UMID]               VARCHAR (50)    NOT NULL,
    [SubAccountId]       NVARCHAR (50)   NOT NULL,
    [RouteIdUsed]        NVARCHAR (50)   NULL,
    [MessageType]        VARCHAR (50)    NOT NULL,
    [Destination]        VARCHAR (50)    NOT NULL,
    [Source]             VARCHAR (50)    NOT NULL,
    [Body]               NVARCHAR (MAX)  NULL,
    [OriginalBody]       NVARCHAR (MAX)  NULL,
    [Encoding]           VARCHAR (50)    NOT NULL,
    [Tariff]             DECIMAL (18, 5) CONSTRAINT [DF_TrafficRecordArchive_Tariff] DEFAULT ((0)) NOT NULL,
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
    [ProtocolSource]     NVARCHAR (4)    CONSTRAINT [DF_TrafficRecordArchive_ProtocolSource] DEFAULT ('HTTP') NOT NULL,
    [messageClass]       SMALLINT        CONSTRAINT [DF_TrafficRecordArchive_messageClass] DEFAULT ('1') NULL,
    [ErrorCode]          NVARCHAR (MAX)  NULL,
    [OriginalSource]     VARCHAR (50)    NULL
);


GO
CREATE CLUSTERED INDEX [PK_TrafficRecordArchive_SubAccountId_UMID]
    ON [dbo].[TrafficRecordArchive]([SubAccountId] ASC, [UMID] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_TrafficRecord_datetimestamp]
    ON [dbo].[TrafficRecordArchive]([DateTimeStamp] DESC);


GO
CREATE STATISTICS [_dta_stat_1525580473_15_3]
    ON [dbo].[TrafficRecordArchive]([OperatorId], [RouteIdUsed]);


GO
CREATE STATISTICS [_dta_stat_1525580473_4_6_12]
    ON [dbo].[TrafficRecordArchive]([MessageType], [Source], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_2_4_6_12]
    ON [dbo].[TrafficRecordArchive]([SubAccountId], [MessageType], [Source], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_6_5_2_12]
    ON [dbo].[TrafficRecordArchive]([Source], [Destination], [SubAccountId], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_5_12_4_6]
    ON [dbo].[TrafficRecordArchive]([Destination], [DateTimeStamp], [MessageType], [Source]);


GO
CREATE STATISTICS [_dta_stat_1525580473_22_4_6_12]
    ON [dbo].[TrafficRecordArchive]([Status], [MessageType], [Source], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_5_2_12_4_6]
    ON [dbo].[TrafficRecordArchive]([Destination], [SubAccountId], [DateTimeStamp], [MessageType], [Source]);


GO
CREATE STATISTICS [_dta_stat_1525580473_22_2_4_6_12]
    ON [dbo].[TrafficRecordArchive]([Status], [SubAccountId], [MessageType], [Source], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_12_5_2_4_6_22]
    ON [dbo].[TrafficRecordArchive]([DateTimeStamp], [Destination], [SubAccountId], [MessageType], [Source], [Status]);


GO
CREATE STATISTICS [_dta_stat_1525580473_1_2]
    ON [dbo].[TrafficRecordArchive]([UMID], [SubAccountId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_2_6]
    ON [dbo].[TrafficRecordArchive]([SubAccountId], [Source]);


GO
CREATE STATISTICS [_dta_stat_1525580473_21_2_1]
    ON [dbo].[TrafficRecordArchive]([CorrelationId], [SubAccountId], [UMID]);


GO
CREATE STATISTICS [_dta_stat_1525580473_12_3_15]
    ON [dbo].[TrafficRecordArchive]([DateTimeStamp], [RouteIdUsed], [OperatorId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_1_6_2]
    ON [dbo].[TrafficRecordArchive]([UMID], [Source], [SubAccountId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_2_5_12_22_4_3]
    ON [dbo].[TrafficRecordArchive]([SubAccountId], [Destination], [DateTimeStamp], [Status], [MessageType], [RouteIdUsed]);


GO
CREATE STATISTICS [_dta_stat_1525580473_22_5_2]
    ON [dbo].[TrafficRecordArchive]([Status], [Destination], [SubAccountId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_4_3_12_22_2]
    ON [dbo].[TrafficRecordArchive]([MessageType], [RouteIdUsed], [DateTimeStamp], [Status], [SubAccountId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_12_3]
    ON [dbo].[TrafficRecordArchive]([DateTimeStamp], [RouteIdUsed]);


GO
CREATE STATISTICS [_dta_stat_1525580473_16_12]
    ON [dbo].[TrafficRecordArchive]([IsEncrypted], [DateTimeStamp]);


GO
CREATE STATISTICS [_dta_stat_1525580473_15_3_22_4_2]
    ON [dbo].[TrafficRecordArchive]([OperatorId], [RouteIdUsed], [Status], [MessageType], [SubAccountId]);


GO
CREATE STATISTICS [_dta_stat_1525580473_15_2_1_3_22]
    ON [dbo].[TrafficRecordArchive]([OperatorId], [SubAccountId], [UMID], [RouteIdUsed], [Status]);

