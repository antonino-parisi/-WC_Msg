CREATE TABLE [mno].[TimeZone] (
    [TimeZoneId]   SMALLINT     NOT NULL,
    [Country]      CHAR (2)     NOT NULL,
    [TimeZoneName] VARCHAR (35) NOT NULL,
    [Abbreviation] VARCHAR (6)  NULL,
    [GMTOffset]    INT          NULL,
    [Dst]          BIT          NULL,
    CONSTRAINT [PK_TimeZone] PRIMARY KEY CLUSTERED ([TimeZoneId] ASC)
);

