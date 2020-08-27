CREATE TABLE [costprov].[EmailParser] (
    [Email]    VARCHAR (50) NOT NULL,
    [ParserId] VARCHAR (50) NOT NULL,
    [IsActive] BIT          CONSTRAINT [DF_EmailParser_IsActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EmailParser] PRIMARY KEY CLUSTERED ([Email] ASC)
);

