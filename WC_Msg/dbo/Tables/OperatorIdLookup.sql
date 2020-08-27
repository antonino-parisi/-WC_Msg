CREATE TABLE [dbo].[OperatorIdLookup] (
    [MCC]        NVARCHAR (50) NOT NULL,
    [MNC]        NVARCHAR (50) NOT NULL,
    [OperatorId] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_OperatorIdLookup] PRIMARY KEY CLUSTERED ([MCC] ASC, [MNC] ASC, [OperatorId] ASC),
    CONSTRAINT [CK_OperatorIdLookup_MCC] CHECK (len([MCC])<=(3)),
    CONSTRAINT [CK_OperatorIdLookup_MNC] CHECK (len([MNC])<=(3)),
    CONSTRAINT [CK_OperatorIdLookup_OperatorId] CHECK ([OperatorId] like '[0-9][0-9][0-9][0-9][0-9][0-9]')
);

