-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-08-10
-- =============================================
-- EXEC cp.UiActivity_Create ....
CREATE PROCEDURE [cp].[UiActivity_Create]
	@AccountUid uniqueidentifier,
	@Message nvarchar(1000),
	@CreatedBy uniqueidentifier = NULL,	-- UserId who created this activity (optional)
	@CreatedAt datetime = NULL			-- Time when activity was created (optional, default - NowUtc)
AS
BEGIN
	
	INSERT INTO cp.UiActivity (AccountUid, Message, CreatedBy, CreatedAt)
	OUTPUT inserted.ActivityId
	VALUES (@AccountUid, @Message, @CreatedBy, ISNULL(@CreatedAt, GETUTCDATE()))
END
