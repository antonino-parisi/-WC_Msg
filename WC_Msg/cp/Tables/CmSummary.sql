CREATE TABLE [cp].[CmSummary] (
    [AccountUid]          UNIQUEIDENTIFIER NOT NULL,
    [TotalContacts]       INT              CONSTRAINT [DF__CmSummary__TotalContacts] DEFAULT ((0)) NULL,
    [TotalContactsActive] INT              CONSTRAINT [DF__CmSummary__TotalContactsActive] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_cpCmSummary] PRIMARY KEY CLUSTERED ([AccountUid] ASC)
);

