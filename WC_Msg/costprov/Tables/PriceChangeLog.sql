CREATE TABLE [costprov].[PriceChangeLog] (
    [PacketId]         UNIQUEIDENTIFIER NULL,
    [RouteId]          VARCHAR (50)     NOT NULL,
    [MCC]              SMALLINT         NOT NULL,
    [MNC]              SMALLINT         NOT NULL,
    [OperatorId]       INT              NULL,
    [Currency]         CHAR (3)         NOT NULL,
    [NewCost]          REAL             NOT NULL,
    [RouteStatus]      CHAR (1)         NULL,
    [CreatedTimeUtc]   DATETIME         CONSTRAINT [DF_PriceChangeLog_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [EffectiveTimeUtc] DATETIME         NULL,
    [Comments]         VARCHAR (500)    NULL
);

