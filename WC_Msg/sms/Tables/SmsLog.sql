CREATE TABLE [sms].[SmsLog] (
    [UMID]                    UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [SubAccountId]            VARCHAR (50)     NOT NULL,
    [ConnId]                  VARCHAR (50)     NULL,
    [SmsTypeId]               TINYINT          NOT NULL,
    [Country]                 CHAR (2)         NULL,
    [OperatorId]              INT              NULL,
    [StatusId]                TINYINT          NOT NULL,
    [MSISDN]                  BIGINT           NOT NULL,
    [SourceOriginal]          VARCHAR (20)     NULL,
    [Source]                  VARCHAR (20)     NOT NULL,
    [BodyOriginal]            NVARCHAR (1600)  NULL,
    [Body]                    NVARCHAR (1600)  NOT NULL,
    [EncodingTypeId]          TINYINT          NOT NULL,
    [DCS]                     TINYINT          NULL,
    [CreatedTime]             DATETIME         NOT NULL,
    [UpdatedTime]             DATETIME         NOT NULL,
    [AdditionalInfo]          VARCHAR (100)    NULL,
    [ConnTypeId]              TINYINT          NOT NULL,
    [ConnMessageId]           VARCHAR (50)     NULL,
    [ConnErrorCode]           VARCHAR (20)     NULL,
    [Cost]                    REAL             NOT NULL,
    [CostCurrency]            CHAR (3)         NOT NULL,
    [Price]                   REAL             NOT NULL,
    [PriceCurrency]           CHAR (3)         NOT NULL,
    [SegmentsReceived]        TINYINT          NOT NULL,
    [SegmentsSent]            TINYINT          NULL,
    [SegmentsDelivered]       TINYINT          NULL,
    [ClientMessageId]         VARCHAR (50)     NULL,
    [ClientBatchId]           VARCHAR (50)     NULL,
    [BatchId]                 UNIQUEIDENTIFIER NULL,
    [ClientDeliveryRequested] BIT              CONSTRAINT [DF_SmsLog_DeliveryRequested] DEFAULT ((1)) NOT NULL,
    [ScheduledTime]           DATETIME         NULL,
    [ExpiryTime]              DATETIME         NULL,
    [SubAccountUid]           INT              NULL,
    [ConnUid]                 SMALLINT         NULL,
    [PriceContractCurrency]   CHAR (3)         NULL,
    [PriceContractPerSms]     DECIMAL (12, 6)  NULL,
    [PriceEURPerSms]          DECIMAL (12, 6)  NULL,
    [CostContractCurrency]    CHAR (3)         NULL,
    [CostContractPerSms]      DECIMAL (12, 6)  NULL,
    [CostEURPerSms]           DECIMAL (12, 6)  NULL,
    CONSTRAINT [PK_SmsLog] PRIMARY KEY CLUSTERED ([UMID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SmsLog_CreatedTime]
    ON [sms].[SmsLog]([CreatedTime] ASC)
    INCLUDE([SubAccountId], [ConnId], [Country], [OperatorId], [StatusId], [ConnTypeId]);


GO
CREATE NONCLUSTERED INDEX [IX_SmsLog_SubAccount_CreatedTime]
    ON [sms].[SmsLog]([SubAccountId] ASC, [CreatedTime] ASC)
    INCLUDE([StatusId], [Price], [PriceCurrency], [SegmentsReceived], [ClientMessageId]);


GO
CREATE NONCLUSTERED INDEX [IX_SmsLog_MSISDN_SubAccountId]
    ON [sms].[SmsLog]([MSISDN] ASC, [SubAccountId] ASC);

