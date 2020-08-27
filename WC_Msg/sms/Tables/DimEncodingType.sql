CREATE TABLE [sms].[DimEncodingType] (
    [EncodingTypeId] TINYINT      NOT NULL,
    [EncodingType]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_DimEncodingType] PRIMARY KEY CLUSTERED ([EncodingTypeId] ASC),
    CONSTRAINT [UIX_DimEncodingType_Name] UNIQUE NONCLUSTERED ([EncodingType] ASC)
);

