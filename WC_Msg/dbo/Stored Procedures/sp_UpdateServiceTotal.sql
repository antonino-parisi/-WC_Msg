CREATE PROCEDURE [dbo].[sp_UpdateServiceTotal]
			@SubAccountId VARCHAR(50),
			@Date VARCHAR(50),
			@MessageType VARCHAR(50)

AS

--if exists (select * from AccountTotals 
--			where SubAccountId=@SubAccountId and [Date]=@Date and MessageType = @MessageType)
--	begin
--		UPDATE AccountTotals SET Total = Total+1 WHERE SubAccountId = @SubAccountId
--		AND [Date] = @Date AND MessageType = @MessageType
--	end
--else
--	begin
--	BEGIN TRY
--		INSERT INTO AccountTotals (SubAccountId, [Date], MessageType, Total)
--			VALUES (@SubAccountId, @Date, @MessageType, 1)
--	END TRY
--	BEGIN CATCH
--	UPDATE AccountTotals SET Total = Total+1 WHERE SubAccountId = @SubAccountId
--		AND [Date] = @Date AND MessageType = @MessageType
--	END CATCH
--	end
