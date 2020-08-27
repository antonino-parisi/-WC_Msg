-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmContact_FieldDelete @ContactId = 2, @FieldName = 'Firstname'
CREATE PROCEDURE [cp].[CmContact_FieldDelete]
	@ContactId int,
	@FieldName varchar(50)
AS
BEGIN
	UPDATE cp.CmContactField
	SET DeletedAt = GETUTCDATE()
	WHERE ContactId = @ContactId AND FieldName = @FieldName AND DeletedAt IS NULL
END

