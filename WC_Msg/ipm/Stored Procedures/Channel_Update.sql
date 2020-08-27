
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-02-05
-- Description:	Update IPM Channel
-- =============================================
CREATE PROCEDURE [ipm].[Channel_Update]	
	@ChannelId UNIQUEIDENTIFIER,
	@Status VARCHAR(20),
	@Name NVARCHAR(36),
	@Comment NVARCHAR(1024),
	@AccountName NVARCHAR(50),
	@PhoneNumber BIGINT,
	@Address NVARCHAR(1024),
	@Email NVARCHAR(250),
	@Description NVARCHAR(1024),
	@IconUrl NVARCHAR(1024),
	@AccountUrl NVARCHAR(1024)
AS
BEGIN

	DECLARE @StatusId CHAR(1)
	SET @StatusId = (SELECT TOP 1 StatusId FROM ipm.ChannelStatus WHERE [Status] = @Status)

	UPDATE ipm.Channel
	SET
		StatusId = @StatusId,
		[Name] = @Name,
		Comment = @Comment,
		AccountName = @AccountName,
		PhoneNumber = @PhoneNumber,
		[Address] = @Address,
		Email = @Email,
		[Description] = @Description,
		IconUrl = @IconUrl,
		AccountUrl = @AccountUrl
	WHERE ChannelId = @ChannelId
	
END
