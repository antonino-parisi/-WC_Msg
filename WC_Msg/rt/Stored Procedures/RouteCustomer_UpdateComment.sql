
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-02-17
-- Description:	Update Comment field
-- =============================================
CREATE PROCEDURE [rt].[RouteCustomer_UpdateComment]
	@SubAccountId varchar(50),
	@Country char(2),
	@OperatorId int  = NULL,
	@Comment nvarchar(500)
AS
BEGIN

	-- Request from Raymond T., cause his golang lib doesn't support NULL values
	IF @OperatorId = 0 SET @OperatorId = NULL
	IF @Comment = '' SET @Comment = NULL

	IF (@Comment IS NOT NULL)
	BEGIN 
		UPDATE rt.RoutingMeta
		SET InfoMessage = @Comment
		WHERE SubAccountId = @SubAccountId AND Country = @Country AND ISNULL(OperatorId, -999) = ISNULL(@OperatorId, -999)

		-- insert new record if it's not exists yet
		IF @@ROWCOUNT = 0
			INSERT INTO rt.RoutingMeta (SubAccountId, Country, OperatorId, InfoMessage)
			VALUES (@SubAccountId, @Country, @OperatorId, @Comment)
	END
	ELSE
	BEGIN
		DELETE FROM rt.RoutingMeta
		WHERE SubAccountId = @SubAccountId AND Country = @Country AND ISNULL(OperatorId, -999) = ISNULL(@OperatorId, -999)
	END
	
	UPDATE rt.RoutingView_Customer
	SET Comment = @Comment
	WHERE SubAccountId = @SubAccountId AND Country = @Country AND ISNULL(OperatorId, -999) = ISNULL(@OperatorId, -999)

END
