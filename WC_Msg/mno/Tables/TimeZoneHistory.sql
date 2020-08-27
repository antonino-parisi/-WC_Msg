CREATE TABLE [mno].[TimeZoneHistory] (
    [TimeZoneId]    SMALLINT    NOT NULL,
    [Abbreviation]  VARCHAR (6) NOT NULL,
    [TimeStartUnix] INT         NOT NULL,
    [GMTOffset]     INT         NOT NULL,
    [Dst]           TINYINT     NOT NULL,
    CONSTRAINT [PK_TimeZoneHistory] PRIMARY KEY CLUSTERED ([TimeZoneId] ASC, [TimeStartUnix] ASC)
);

