CREATE TABLE [sms].[StatUrlShorten] (
    [StatEntryId]   INT           IDENTITY (1, 1) NOT NULL,
    [TimeFrom]      SMALLDATETIME NOT NULL,
    [SubAccountUid] INT           NOT NULL,
    [BaseUrlId]     INT           NOT NULL,
    [MsgTotal]      INT           CONSTRAINT [DF_StatUrlShorten_MsgTotal] DEFAULT ((0)) NOT NULL,
    [MsgDelivered]  INT           CONSTRAINT [DF_StatUrlShorten_MsgDelivered] DEFAULT ((0)) NOT NULL,
    [UrlCreated]    INT           CONSTRAINT [DF_StatUrlShorten_UrlCreated] DEFAULT ((0)) NOT NULL,
    [UrlClicked]    INT           CONSTRAINT [DF_StatUrlShorten_UrlClicked] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_StatUrlShorten] PRIMARY KEY CLUSTERED ([StatEntryId] ASC),
    CONSTRAINT [UIX_StatUrlShorten_TimeFrom_SubAccountId_BaseUrlId] UNIQUE NONCLUSTERED ([TimeFrom] ASC, [SubAccountUid] ASC, [BaseUrlId] ASC)
);

