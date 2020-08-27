

-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-05-12
-- Description:	Insert log record to gtn.CSG_Log
-- =============================================
CREATE PROCEDURE [gtn].[CSG_Log_Insert]
	@TransactionID uniqueidentifier,
	@RouteId varchar(50),
	@OperatorId int,
	@TestCase varchar(50),
	@StatusId smallint,
	@TestResultJson nvarchar(4000) = NULL,
	@TestResultRawJson nvarchar(4000) = NULL,
	@ClientPayload nvarchar(4000) = NULL,
	@TestBatchID int = NULL,
	@SMSTemplateID smallint = NULL,
	@SentTimeUtc datetime = NULL,
	@DeliveredSenderId varchar(50) = NULL,
	@DeliveredMessageText nvarchar(1000) = NULL,
	@DeliveredTimeUtc datetime = NULL
AS
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM gtn.CSG_Log WHERE TransactionID = @TransactionID)
	BEGIN
		INSERT INTO gtn.CSG_Log
			   (TransactionID
			   ,RouteId
			   ,OperatorId
			   ,TestCase
			   ,StatusId
			   ,CreatedTimeUtc
			   ,TestResultJson
			   ,TestResultRawJson
			   ,ClientPayload)
		 VALUES
			   (@TransactionID
			   ,@RouteId
			   ,@OperatorId
			   ,@TestCase
			   ,@StatusId
			   ,GETUTCDATE()
			   ,@TestResultJson
			   ,@TestResultRawJson
			   ,@ClientPayload
			   /*,@SentTimeUtc
			   ,@DeliveredSenderId
			   ,@DeliveredMessageText
			   ,@DeliveredTimeUtc*/)

	END
	ELSE
	BEGIN
		UPDATE gtn.CSG_Log
		SET  RouteId = ISNULL(@RouteId, RouteId)
			,OperatorId = ISNULL(@OperatorId, OperatorId)
			,TestCase = ISNULL(@TestCase, TestCase)
			,StatusId = ISNULL(@StatusId, StatusId)
			,TestResultJson = ISNULL(@TestResultJson, TestResultJson)
			,TestResultRawJson = ISNULL(@TestResultRawJson, TestResultRawJson)
			,ClientPayload = ISNULL(@ClientPayload, ClientPayload)
		 WHERE TransactionID = @TransactionID
	END
END


