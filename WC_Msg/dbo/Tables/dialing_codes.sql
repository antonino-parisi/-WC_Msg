CREATE TABLE [dbo].[dialing_codes] (
    [Country]     VARCHAR (128) NOT NULL,
    [Code]        VARCHAR (64)  NOT NULL,
    [codeCountry] NCHAR (2)     NULL,
    PRIMARY KEY CLUSTERED ([Country] ASC),
    CONSTRAINT [IX_dialing_codes_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);

