CREATE TABLE [cp].[CmContactField] (
    [ContactId]  INT            NOT NULL,
    [FieldName]  VARCHAR (50)   NOT NULL,
    [FieldValue] NVARCHAR (200) NOT NULL,
    [CreatedAt]  DATETIME       CONSTRAINT [DF_cpCmContactField_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    [UpdatedAt]  DATETIME       CONSTRAINT [DF_cpCmContactField_UpdatedAt] DEFAULT (getutcdate()) NOT NULL,
    [DeletedAt]  DATETIME       NULL,
    CONSTRAINT [PK_cpCmContactField] PRIMARY KEY CLUSTERED ([ContactId] ASC, [FieldName] ASC),
    CONSTRAINT [FK_cpCmContactField_cpCmContact] FOREIGN KEY ([ContactId]) REFERENCES [cp].[CmContact] ([ContactId])
);

