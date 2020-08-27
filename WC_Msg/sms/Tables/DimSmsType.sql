CREATE TABLE [sms].[DimSmsType] (
    [SmsTypeId] TINYINT      NOT NULL,
    [SmsType]   VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_DimSmsType] PRIMARY KEY CLUSTERED ([SmsTypeId] ASC),
    CONSTRAINT [UIX_DimSmsType] UNIQUE NONCLUSTERED ([SmsType] ASC)
);

