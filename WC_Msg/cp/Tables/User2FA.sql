CREATE TABLE [cp].[User2FA] (
    [UserId]        UNIQUEIDENTIFIER NOT NULL,
    [MSISDN]        BIGINT           NULL,
    [TOTP_Encoding] VARCHAR (30)     NULL,
    [TOTP_Secret]   VARCHAR (300)    NULL,
    [Preferred]     CHAR (1)         NOT NULL,
    [RememberUntil] DATETIME2 (2)    NULL,
    [CreatedAt]     DATETIME2 (2)    CONSTRAINT [DF_User2FA_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]     DATETIME2 (2)    CONSTRAINT [DF_User2FA_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [MSISDN_Masked] AS               (left(CONVERT([varchar](16),[msisdn]),(6))+'XX..'),
    CONSTRAINT [PK_User2FA_UserId] PRIMARY KEY CLUSTERED ([UserId] ASC)
);

