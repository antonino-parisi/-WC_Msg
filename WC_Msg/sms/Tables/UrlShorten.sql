CREATE TABLE [sms].[UrlShorten] (
    [UrlId]           INT              IDENTITY (1, 1) NOT NULL,
    [DomainId]        SMALLINT         NOT NULL,
    [OriginalUrl]     NVARCHAR (1000)  NOT NULL,
    [SubAccountUid]   INT              NOT NULL,
    [UMID]            UNIQUEIDENTIFIER NULL,
    [Pin]             SMALLINT         NULL,
    [Hits]            SMALLINT         CONSTRAINT [DF_smsUrlShorten_Hits] DEFAULT ((0)) NOT NULL,
    [CreatedAt]       DATETIME2 (2)    CONSTRAINT [DF_smsUrlShorten_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [FirstAccessedAt] DATETIME2 (2)    NULL,
    [LastAccessedAt]  DATETIME2 (2)    NULL,
    [BaseUrlId]       INT              NOT NULL,
    CONSTRAINT [PK_smsUrlShorten] PRIMARY KEY CLUSTERED ([UrlId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_smsUrlShorten_UMID]
    ON [sms].[UrlShorten]([UMID] ASC);

