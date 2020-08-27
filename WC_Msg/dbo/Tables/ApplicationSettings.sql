CREATE TABLE [dbo].[ApplicationSettings] (
    [ParameterName]  NVARCHAR (50)  NOT NULL,
    [ParameterValue] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_ApplicationSettings] PRIMARY KEY CLUSTERED ([ParameterName] ASC)
);

