-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-03-21
-- Description:	get MessageBodyPrefix from MessageBodyPrefixMapping table by SubAccountId + OperatorId
-- =============================================
-- EXEC [optimus].[MessageBodyPrefixMapping_GetBySubAccountIdOperatorId] @SubAccountId = 'wavecell_mon_2', @OperatorId = 250001
CREATE PROCEDURE [optimus].[MessageBodyPrefixMapping_GetBySubAccountIdOperatorId_Deprecated]
	@SubAccountId varchar(50),
	@OperatorId int
AS
BEGIN
	SET NOCOUNT ON;

    SELECT MessageBodyPrefix
	FROM optimus.MessageBodyPrefixMapping
	WHERE SubAccountId = @SubAccountId AND OperatorId = @OperatorId

END
