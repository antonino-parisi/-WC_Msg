-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-02-14
-- Description:	Inserting 1 record with all columns to table cp.SecurityEventLog
-- =============================================
-- EXEC [cp].[SecurityEventLog_Insert] @EventTime='2018-02-14T19:58:47.1234567', @EventType='MyType', @Login='MyLogin', @UserId='6F9619FF-8B86-D011-B42D-00C04FC964FF', @SourceIP='192.168.0.13', @SourceUserAgent='HackerBrowser', @Payload='Two bee or not two bee'
CREATE PROCEDURE [cp].[SecurityEventLog_Insert] 
	@EventTime datetime2(7),
	@EventType varchar(50),
	@Login nvarchar(255),
	@UserId uniqueidentifier = NULL,
	@SourceIP varchar(50),
	@SourceUserAgent nvarchar(1000) = NULL,
	@Payload nvarchar(4000) = NULL,
	@MapLogin nvarchar(255) = NULL
AS
BEGIN
	INSERT INTO [cp].[SecurityEventLog] (EventTime, EventType, Login, UserId, SourceIP, SourceUserAgent, Payload, MapLogin)
	VALUES (@EventTime, @EventType, @Login, @UserId, @SourceIP, @SourceUserAgent, @Payload, @MapLogin)
END
