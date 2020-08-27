CREATE TABLE [cp].[UiNews] (
    [NewsId]   INT             IDENTITY (1, 1) NOT NULL,
    [Title]    NVARCHAR (200)  NOT NULL,
    [Message]  NVARCHAR (1000) NULL,
    [Url]      VARCHAR (200)   NULL,
    [UrlText]  NVARCHAR (100)  NULL,
    [NewsDate] DATE            CONSTRAINT [DF_UiNews_NewsDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_UiNews] PRIMARY KEY CLUSTERED ([NewsId] ASC)
);

