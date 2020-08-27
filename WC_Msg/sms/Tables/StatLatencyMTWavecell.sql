CREATE TABLE [sms].[StatLatencyMTWavecell] (
    [StatEntryId] INT           IDENTITY (1, 1) NOT NULL,
    [TimeFrom]    SMALLDATETIME NOT NULL,
    [Host]        VARCHAR (20)  NOT NULL,
    [Qty]         INT           NOT NULL,
    [Avg]         INT           NOT NULL,
    [Median]      INT           NOT NULL,
    CONSTRAINT [PK_StatLatencyMTWavecell] PRIMARY KEY NONCLUSTERED ([StatEntryId] ASC),
    CONSTRAINT [UIX_StatLatencyMTWavecell] UNIQUE CLUSTERED ([TimeFrom] ASC, [Host] ASC)
);

