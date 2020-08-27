CREATE TABLE [sms].[DimConnType] (
    [ConnTypeId]        TINYINT      NOT NULL,
    [ConnectionType]    VARCHAR (20) NOT NULL,
    [OldProtocolSource] VARCHAR (4)  NOT NULL,
    CONSTRAINT [PK_DimConnType] PRIMARY KEY CLUSTERED ([ConnTypeId] ASC),
    CONSTRAINT [UIX_DimConnType_OldProtocolSource] UNIQUE NONCLUSTERED ([OldProtocolSource] ASC)
);

