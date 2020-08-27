CREATE TABLE [cp].[BillingAutoTopup] (
    [AccountUid]           UNIQUEIDENTIFIER NOT NULL,
    [Currency]             CHAR (3)         NOT NULL,
    [ChargeAmount]         DECIMAL (14, 5)  NOT NULL,
    [ThresholdAmount]      DECIMAL (14, 5)  NOT NULL,
    [StripeSourceId]       VARCHAR (50)     NULL,
    [CustomerStripeId]     VARCHAR (50)     NULL,
    [CreatedAt]            DATETIME2 (2)    NOT NULL,
    [UpdatedAt]            DATETIME2 (2)    CONSTRAINT [DF_BillingAutoTopup_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedBy]            UNIQUEIDENTIFIER NULL,
    [FailedAttempts]       TINYINT          CONSTRAINT [DF_BillingAutoTopup_FailedAttempts] DEFAULT ((0)) NOT NULL,
    [SuspendCheckUntil]    DATETIME2 (2)    NULL,
    [LastPaymentStartedAt] DATETIME2 (2)    NULL,
    CONSTRAINT [PK_BillingAutoTopup] PRIMARY KEY CLUSTERED ([AccountUid] ASC),
    CONSTRAINT [FK_BillingAutoTopup_AccountUid] FOREIGN KEY ([AccountUid]) REFERENCES [cp].[Account] ([AccountUid]),
    CONSTRAINT [FK_BillingAutoTopup_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [cp].[User] ([UserId])
);

