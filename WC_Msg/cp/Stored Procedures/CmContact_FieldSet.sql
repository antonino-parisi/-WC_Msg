-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-01-30
-- =============================================
-- EXEC cp.CmContact_FieldSet @ContactId = 2, @FieldName = 'Firstname', @FieldValue = 'Anton'
CREATE PROCEDURE [cp].[CmContact_FieldSet]
	@ContactId int,
	@FieldName varchar(50),
	@FieldValue nvarchar(200) 
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM cp.CmContactField WHERE ContactId = @ContactId AND FieldName = @FieldName)
		INSERT INTO cp.CmContactField (ContactId, FieldName, Fieldvalue, CreatedAt, UpdatedAt)
		VALUES (@ContactId, @FieldName, @FieldValue, GETUTCDATE(), GETUTCDATE())
	ELSE
		UPDATE cp.CmContactField
		SET FieldValue = @FieldValue, UpdatedAt = GETUTCDATE(), DeletedAt = NULL
		WHERE ContactId = @ContactId AND FieldName = @FieldName
			AND (FieldValue <> @FieldValue OR DeletedAt IS NOT NULL)
END

