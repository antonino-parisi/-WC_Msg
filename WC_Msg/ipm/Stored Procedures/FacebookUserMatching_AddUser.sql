-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-10-18
-- Description:	Add Facebook user matching
-- =============================================
-- exec ipm.FacebookUserMatching_AddUser @SubAccountUid=18287,@PageId=280027322614447,@ChannelUserId=N'1952843448135111'
CREATE PROCEDURE [ipm].[FacebookUserMatching_AddUser]
	@SubAccountUid int,
	@PageId bigint,
	@ChannelUserId varchar(50),
	@UserId bigint = NULL,
	@Msisdn bigint = NULL	
AS
BEGIN
	
	IF NOT EXISTS (
		SELECT TOP (1) 1 FROM ipm.FacebookUserMatching
		WHERE SubAccountUid = @SubAccountUid AND ChannelUserId = @ChannelUserId AND PageId = @PageId
	)
	BEGIN
		-- Potential 'Violation of PRIMARY KEY constraint' error is correctly handled by APP
		--BEGIN TRY
			INSERT INTO ipm.FacebookUserMatching 
				(SubAccountUid, PageId, ChannelUserId, UserId, Msisdn)
			VALUES 
				(@SubAccountUid, @PageId, @ChannelUserId, @UserId, @Msisdn)
		--END TRY
		--BEGIN CATCH
		--	-- ignore only 'Violation of PRIMARY KEY constraint', keep throwing other error types
		--	IF @@ERROR <> 2627 THROW
		--END CATCH
	END 
END
