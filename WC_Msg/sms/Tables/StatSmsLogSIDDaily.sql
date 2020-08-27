CREATE TABLE [sms].[StatSmsLogSIDDaily] (
    [StatDate]            DATE            NOT NULL,
    [StatEntryId]         INT             NOT NULL,
    [SubAccountUid]       INT             NULL,
    [Country]             CHAR (2)        NULL,
    [OperatorId]          INT             NULL,
    [ConnUid]             SMALLINT        NULL,
    [SenderId_In]         VARCHAR (20)    NOT NULL,
    [SenderId_Out]        VARCHAR (20)    NOT NULL,
    [Cost_EUR]            DECIMAL (18, 6) NOT NULL,
    [Price_EUR]           DECIMAL (18, 6) NOT NULL,
    [SmsCountAccepted]    INT             NULL,
    [SmsCountDelivered]   INT             NULL,
    [SmsCountUndelivered] INT             NULL,
    [SmsCountRejected]    INT             NULL,
    [MsgCountAccepted]    INT             NULL,
    [MsgCountDelivered]   INT             NULL,
    [MsgCountUndelivered] INT             NULL,
    [MsgCountRejected]    INT             NULL,
    [LastUpdatedAt]       DATETIME2 (2)   CONSTRAINT [DF_StatSmsLogSIDDaily_LastUpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [UQ_smsStatSmsLogSIDDaily_Cluster] UNIQUE CLUSTERED ([StatDate] ASC, [StatEntryId] ASC),
    CONSTRAINT [UQ_smsStatSmsLogSIDDaily_Date_SubAccount_Country_Operator_Conn] UNIQUE NONCLUSTERED ([StatDate] ASC, [SubAccountUid] ASC, [Country] ASC, [OperatorId] ASC, [ConnUid] ASC, [SenderId_In] ASC, [SenderId_Out] ASC)
);

