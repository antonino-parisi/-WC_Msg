CREATE TABLE [ms].[DimVirtualNumberType] (
    [VNType]     CHAR (1)     NOT NULL,
    [VNTypeName] VARCHAR (30) NOT NULL,
    CONSTRAINT [PK_DimVirtualNumberType] PRIMARY KEY CLUSTERED ([VNType] ASC)
);

