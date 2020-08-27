CREATE TABLE [ms].[AccountProductMeta] (
    [AccountId]           VARCHAR (50)  NOT NULL,
    [Product]             CHAR (2)      NOT NULL,
    [OnboardingStatus]    VARCHAR (20)  NOT NULL,
    [UsageStartTest]      DATE          NULL,
    [UsageStartLive]      DATE          NULL,
    [UpdatedAt]           DATETIME2 (2) CONSTRAINT [DF_AccountProductMeta_LastUpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UsageStartFY]        AS            (datepart(year,dateadd(month,(-3),[UsageStartLive]))),
    [UsageStartFYCurrent] AS            (case when [UsageStartLive] IS NULL then NULL when datepart(year,dateadd(month,(-3),[UsageStartLive]))=datepart(year,dateadd(month,(-3),sysutcdatetime())) then CONVERT([bit],(1)) else CONVERT([bit],(0)) end),
    CONSTRAINT [PK_AccountProductMeta] PRIMARY KEY CLUSTERED ([AccountId] ASC, [Product] ASC),
    CONSTRAINT [CK_AccountProductMeta_OnboardingStatus] CHECK ([OnboardingStatus]='CREATED' OR [OnboardingStatus]='TRIAL' AND [UsageStartTest] IS NOT NULL OR [OnboardingStatus]='LIVE' AND [UsageStartLive] IS NOT NULL OR [OnboardingStatus]='DEACTIVATE' OR [OnboardingStatus]='EXPIRED'),
    CONSTRAINT [CK_AccountProductMeta_Product] CHECK ([Product]='CA' OR [Product]='VI' OR [Product]='VO' OR [Product]='SM')
);

