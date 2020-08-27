CREATE TABLE [ms].[DimHttpContentType] (
    [ContentType] VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    CONSTRAINT [PK_DimHttpContentType] PRIMARY KEY CLUSTERED ([ContentType] ASC)
);

