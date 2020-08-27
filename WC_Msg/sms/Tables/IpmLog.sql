CREATE TABLE [sms].[IpmLog] (
    [UMID]                UNIQUEIDENTIFIER CONSTRAINT [DF_IpmLog_UMID] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [ChannelUid]          TINYINT          NOT NULL,
    [SubAccountUid]       INT              NOT NULL,
    [Direction]           BIT              NOT NULL,
    [Step]                TINYINT          NOT NULL,
    [StatusId]            TINYINT          NOT NULL,
    [Country]             CHAR (2)         NULL,
    [MSISDN]              BIGINT           NOT NULL,
    [ChannelUserId]       VARCHAR (50)     NULL,
    [ContentTypeId]       TINYINT          NOT NULL,
    [Content]             NVARCHAR (1600)  NULL,
    [CreatedAt]           DATETIME2 (2)    NOT NULL,
    [DeliveredAt]         DATETIME2 (2)    NULL,
    [ReadAt]              DATETIME2 (2)    NULL,
    [UpdatedAt]           DATETIME2 (2)    NOT NULL,
    [ConnMessageId]       VARCHAR (50)     NULL,
    [ConnErrorCode]       VARCHAR (20)     NULL,
    [Cost]                DECIMAL (12, 6)  NULL,
    [CostCurrency]        CHAR (3)         NULL,
    [Price]               DECIMAL (12, 6)  NULL,
    [PriceCurrency]       CHAR (3)         NULL,
    [ClientMessageId]     VARCHAR (50)     NULL,
    [ClientBatchId]       VARCHAR (50)     NULL,
    [BatchId]             UNIQUEIDENTIFIER NULL,
    [ChannelCostEUR]      DECIMAL (12, 6)  CONSTRAINT [DF_IpmLog_ChannelCostEUR] DEFAULT ((0)) NULL,
    [MessageFeeEUR]       DECIMAL (12, 6)  CONSTRAINT [DF_IpmLog_MessageFeeEUR] DEFAULT ((0)) NULL,
    [ChannelCostContract] DECIMAL (12, 6)  CONSTRAINT [DF_IpmLog_ChannelCostContract] DEFAULT ((0)) NULL,
    [MessageFeeContract]  DECIMAL (12, 6)  CONSTRAINT [DF_IpmLog_MessageFeeContract] DEFAULT ((0)) NULL,
    [ContractCurrency]    CHAR (3)         NULL,
    [InitSession]         BIT              CONSTRAINT [DF_IpmLog_InitSession] DEFAULT ((1)) NULL,
    [Chargable]           AS               (case when [Direction]=(1) AND ([StatusId]=(40) OR [StatusId]=(50)) AND ([ChannelUid]=(1) AND [InitSession]=(1) AND [ContentTypeId]=(10) OR [ChannelUid]=(5) OR [ChannelUid]=(6)) then CONVERT([bit],(1)) else CONVERT([bit],(0)) end),
    [ChannelId]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_IpmLog] PRIMARY KEY CLUSTERED ([UMID] ASC, [ChannelUid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_ChannelId_ConnMessageId]
    ON [sms].[IpmLog]([ChannelUid] ASC, [ConnMessageId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_CreatedTime]
    ON [sms].[IpmLog]([CreatedAt] ASC)
    INCLUDE([UMID], [ChannelUid], [StatusId], [MSISDN], [SubAccountUid]);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_MSISDN_CreatedAt_SubAccount]
    ON [sms].[IpmLog]([SubAccountUid] ASC, [CreatedAt] ASC, [MSISDN] ASC)
    INCLUDE([UMID]);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_SubAccount_CreatedAt]
    ON [sms].[IpmLog]([SubAccountUid] ASC, [CreatedAt] ASC)
    INCLUDE([UMID]);

