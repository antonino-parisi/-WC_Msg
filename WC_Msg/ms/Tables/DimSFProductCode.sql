CREATE TABLE [ms].[DimSFProductCode] (
    [ProductCode] VARCHAR (20)  NOT NULL,
    [ProductName] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_DimSFProductCode] PRIMARY KEY CLUSTERED ([ProductCode] ASC)
);

