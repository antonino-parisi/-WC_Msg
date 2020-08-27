CREATE TABLE [sms].[StatSmsLog] (
    [TimeFrom]                   SMALLDATETIME    NOT NULL,
    [StatEntryId]                INT              IDENTITY (1, 1) NOT NULL,
    [TimeTill]                   SMALLDATETIME    NOT NULL,
    [AccountUid]                 UNIQUEIDENTIFIER NOT NULL,
    [SubAccountUid]              INT              NOT NULL,
    [Country]                    CHAR (2)         NULL,
    [OperatorId]                 INT              NULL,
    [SmsTypeId]                  TINYINT          NOT NULL,
    [ConnUid]                    SMALLINT         NULL,
    [CostCurrency]               CHAR (3)         NOT NULL,
    [Cost]                       REAL             NOT NULL,
    [PriceCurrency]              CHAR (3)         NOT NULL,
    [Price]                      REAL             NOT NULL,
    [SmsCountTotal]              INT              NOT NULL,
    [SmsCountDelivered]          INT              NOT NULL,
    [SmsCountUndelivered]        INT              NOT NULL,
    [SmsCountRejected]           INT              NOT NULL,
    [SmsCountProcessingWavecell] INT              NOT NULL,
    [SmsCountProcessingSupplier] INT              NOT NULL,
    [MsgCountTotal]              INT              NOT NULL,
    [MsgCountDelivered]          INT              NOT NULL,
    [MsgCountUndelivered]        INT              NOT NULL,
    [MsgCountRejected]           INT              NOT NULL,
    [MsgCountProcessingWavecell] INT              NOT NULL,
    [MsgCountProcessingSupplier] INT              NOT NULL,
    [LastUpdatedAt]              DATETIME2 (2)    CONSTRAINT [DF_StatSmsLog_LastUpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [PriceContract]              DECIMAL (18, 6)  NULL,
    [PriceContractCurrency]      CHAR (3)         NULL,
    [PriceEUR]                   DECIMAL (18, 6)  NULL,
    [CostContract]               DECIMAL (18, 6)  NULL,
    [CostContractCurrency]       CHAR (3)         NULL,
    [CostEUR]                    DECIMAL (18, 6)  NULL,
    [MsgCountConverted]          INT              NULL,
    [SmsCountConverted]          INT              NULL,
    CONSTRAINT [PK_smsStatSmsLog] PRIMARY KEY NONCLUSTERED ([StatEntryId] ASC),
    CONSTRAINT [UIX_smsStatSmsLog_TimeFrom_SubAccount_Country_Operator_Conn_Currency] UNIQUE NONCLUSTERED ([TimeFrom] ASC, [SubAccountUid] ASC, [SmsTypeId] ASC, [Country] ASC, [OperatorId] ASC, [ConnUid] ASC, [PriceContractCurrency] ASC, [CostContractCurrency] ASC),
    CONSTRAINT [UIX_StatSmsLog_Cluster] UNIQUE CLUSTERED ([TimeFrom] ASC, [StatEntryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_smsStatSmsLog_Account_TimeFrom]
    ON [sms].[StatSmsLog]([AccountUid] ASC, [SmsTypeId] ASC, [TimeFrom] ASC)
    INCLUDE([SubAccountUid], [Country], [OperatorId]);

