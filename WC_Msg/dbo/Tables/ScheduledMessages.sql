CREATE TABLE [dbo].[ScheduledMessages] (
    [UMID]               VARCHAR (50)    NOT NULL,
    [SubAccountId]       NVARCHAR (50)   NOT NULL,
    [RouteId]            NVARCHAR (50)   NULL,
    [Destination]        VARCHAR (50)    NOT NULL,
    [Source]             VARCHAR (50)    NOT NULL,
    [Body]               NVARCHAR (MAX)  NULL,
    [Encoding]           VARCHAR (50)    NOT NULL,
    [DateTimeStamp]      DATETIME        NOT NULL,
    [OperatorId]         VARCHAR (50)    NULL,
    [RegisteredDelivery] INT             NOT NULL,
    [Tariff]             DECIMAL (18, 5) NOT NULL,
    [IsEncrypted]        BIT             NOT NULL,
    [ScheduledDateTime]  DATETIME        NULL,
    [DeliveryMethod]     VARCHAR (50)    NOT NULL,
    [WapUrl]             NVARCHAR (MAX)  NULL,
    [Attempt]            INT             NOT NULL,
    [AccountId]          NVARCHAR (50)   NOT NULL,
    [transmitting]       BIT             CONSTRAINT [DF_ScheduledMessages_transmitting] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ScheduledMessages] PRIMARY KEY CLUSTERED ([UMID] ASC, [SubAccountId] ASC)
);

