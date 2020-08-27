CREATE TABLE [mno].[Country] (
    [CountryISO2alpha]  CHAR (2)       NOT NULL,
    [CountryISO3alpha]  CHAR (3)       NOT NULL,
    [CountryName]       NVARCHAR (50)  NOT NULL,
    [CountryNameFormal] NVARCHAR (50)  NULL,
    [ISO3166numeric]    SMALLINT       NULL,
    [MCCDefault]        SMALLINT       NULL,
    [DialCode]          VARCHAR (10)   NULL,
    [MNPSupport]        BIT            NOT NULL,
    [Currency]          CHAR (3)       NOT NULL,
    [CurrencyName]      VARCHAR (50)   NOT NULL,
    [CurrencyMinorUnit] TINYINT        NOT NULL,
    [Continent]         CHAR (2)       NOT NULL,
    [TimeZoneIdDefault] SMALLINT       NOT NULL,
    [JsonData]          NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([CountryISO2alpha] ASC),
    CONSTRAINT [IX_Country_3alpha] UNIQUE NONCLUSTERED ([CountryISO3alpha] ASC),
    CONSTRAINT [IX_Country_Name] UNIQUE NONCLUSTERED ([CountryName] ASC)
);

