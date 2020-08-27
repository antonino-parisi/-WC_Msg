CREATE TABLE [map].[SupplierCostUploaderFileData] (
    [RecordId]      INT             IDENTITY (1, 1) NOT NULL,
    [FileId]        INT             NOT NULL,
    [IsValid]       BIT             NOT NULL,
    [ConnId]        VARCHAR (50)    NOT NULL,
    [ConnUid]       INT             NULL,
    [MCC]           SMALLINT        NULL,
    [MNC]           SMALLINT        NULL,
    [Country]       CHAR (2)        NULL,
    [OperatorId]    INT             NULL,
    [SmsType]       VARCHAR (10)    NULL,
    [SmsTypeId]     TINYINT         NULL,
    [Currency]      VARCHAR (3)     NULL,
    [Cost]          DECIMAL (12, 6) NULL,
    [EffectiveFrom] DATETIME2 (2)   NULL,
    [Active]        BIT             NULL,
    [Saved]         BIT             CONSTRAINT [DF_SupplierCostUploaderFileData_Saved] DEFAULT ((0)) NOT NULL,
    [ErrorCode]     VARCHAR (500)   NULL,
    CONSTRAINT [PK_SupplierCostUploaderFileData] PRIMARY KEY CLUSTERED ([RecordId] ASC),
    CONSTRAINT [FK_SupplierCostUploaderFileData_SupplierCostUploaderFile] FOREIGN KEY ([FileId]) REFERENCES [map].[SupplierCostUploaderFile] ([FileId])
);

