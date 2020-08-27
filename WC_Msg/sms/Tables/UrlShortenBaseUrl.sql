CREATE TABLE [sms].[UrlShortenBaseUrl] (
    [BaseUrlId] INT            IDENTITY (1, 1) NOT NULL,
    [BaseUrl]   NVARCHAR (450) NOT NULL,
    CONSTRAINT [PK_smsUrlShortenBaseUrl] PRIMARY KEY CLUSTERED ([BaseUrlId] ASC),
    CONSTRAINT [UIX_smsUrlShortenBaseUrl_BaseUrl] UNIQUE NONCLUSTERED ([BaseUrl] ASC)
);

