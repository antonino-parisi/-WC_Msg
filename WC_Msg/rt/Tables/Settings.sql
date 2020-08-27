CREATE TABLE [rt].[Settings] (
    [SchemaId] VARCHAR (50)   NOT NULL,
    [Value]    NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED ([SchemaId] ASC)
);

