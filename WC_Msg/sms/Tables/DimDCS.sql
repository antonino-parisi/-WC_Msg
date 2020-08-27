CREATE TABLE [sms].[DimDCS] (
    [DCS]              TINYINT      NOT NULL,
    [CharacterSet]     TINYINT      NOT NULL,
    [MessageClass]     TINYINT      NOT NULL,
    [CharacterSetText] VARCHAR (50) NOT NULL,
    [MessageClassText] VARCHAR (50) NOT NULL,
    [EncodingTypeId]   TINYINT      NULL,
    CONSTRAINT [PK_DimDCS] PRIMARY KEY CLUSTERED ([DCS] ASC),
    CONSTRAINT [FK_DimDCS_DimEncodingType] FOREIGN KEY ([EncodingTypeId]) REFERENCES [sms].[DimEncodingType] ([EncodingTypeId])
);

