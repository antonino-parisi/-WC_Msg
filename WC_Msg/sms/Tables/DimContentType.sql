CREATE TABLE [sms].[DimContentType] (
    [ContentTypeId]      INT          NOT NULL,
    [ContentType]        VARCHAR (20) NOT NULL,
    [ContentTypePricing] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED ([ContentTypeId] ASC)
);

