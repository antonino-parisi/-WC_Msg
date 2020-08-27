CREATE TABLE [dbo].[Operator] (
    [OperatorId]   NVARCHAR (50)  NOT NULL,
    [OperatorName] NVARCHAR (200) NOT NULL,
    [Details]      NVARCHAR (500) NOT NULL,
    [Country]      NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_Operator] PRIMARY KEY CLUSTERED ([OperatorId] ASC),
    CONSTRAINT [CK_Operator_OperatorId] CHECK (len([OperatorId])=(6))
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_Operator_5_738101670__K1_2_4]
    ON [dbo].[Operator]([OperatorId] ASC)
    INCLUDE([OperatorName], [Country]);


GO
CREATE TRIGGER updateServer_Operator ON
 dbo.Operator
 FOR INSERT,UPDATE,DELETE
 AS
 EXECUTE  sp_configurationChanged;
