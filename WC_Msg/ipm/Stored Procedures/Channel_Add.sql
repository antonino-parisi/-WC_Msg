-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-02-05
-- Description:	Add IPM Channel for AccountUid
-- =============================================
CREATE PROCEDURE [ipm].[Channel_Add]	
	@ChannelId UNIQUEIDENTIFIER,
	@AccountUid UNIQUEIDENTIFIER,
	@ChannelType VARCHAR(20),
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

    DECLARE @Type CHAR(2)
	SET @Type = (SELECT TOP 1 ChannelType FROM ipm.ChannelType WHERE ChannelTypeName = @ChannelType);
	
    INSERT INTO ipm.Channel 
	   (ChannelId, AccountUid, ChannelType, StatusId, 
	   [Name], Comment, AccountName, 
	   PhoneNumber, [Address], Email, 
	   [Description], IconUrl, AccountUrl)
	VALUES
	   (@ChannelId, @AccountUid, @Type, 'P', 
	   @Name, @Comment, @AccountName, 
	   @PhoneNumber, @Address, @Email, 
	   @Description, @IconUrl, @AccountUrl)
	
END
