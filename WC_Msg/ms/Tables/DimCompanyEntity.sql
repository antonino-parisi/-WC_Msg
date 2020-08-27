CREATE TABLE [ms].[DimCompanyEntity] (
    [CompanyEntity] VARCHAR (10)  NOT NULL,
    [Country]       CHAR (2)      NOT NULL,
    [CompanyName]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_DimCompanyEntity] PRIMARY KEY CLUSTERED ([CompanyEntity] ASC)
);

