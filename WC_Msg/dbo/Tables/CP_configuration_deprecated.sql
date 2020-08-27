CREATE TABLE [dbo].[CP_configuration_deprecated] (
    [ParameterName]  NVARCHAR (50)  NOT NULL,
    [ParameterValue] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CP_configuration] PRIMARY KEY CLUSTERED ([ParameterName] ASC)
);

