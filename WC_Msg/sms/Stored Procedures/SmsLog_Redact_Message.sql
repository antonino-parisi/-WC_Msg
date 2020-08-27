﻿-- =============================================
-- Author: Tony Ivanov
-- Create date: 2020-07-14
-- Description:	Procedure for redacting the PII
-- =============================================
CREATE PROCEDURE [sms].[SmsLog_Redact_Message]
    @UMID UNIQUEIDENTIFIER,
    @SubAccountUId INT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM [sms].[SmsLog] WHERE UMID = @UMID AND SubAccountUid = @SubAccountUid)
    BEGIN
        SELECT -1;
        RETURN;
    END

    IF  EXISTS(SELECT 1 FROM [sms].ETL_Reprocess WHERE UMID = @UMID)
    BEGIN
        SELECT 0;
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE sms.SmsLog
        SET
            MSISDN = MSISDN / 10000,
            Body = '**REDACTED**',
			BodyOriginal = IIF(BodyOriginal IS NULL, NULL, '**REDACTED**')
        WHERE UMID = @UMID
          AND SubAccountUid = @SubAccountUid;

        INSERT INTO sms.ETL_Reprocess (UMID, SubAccountUid, CreatedAt, UpdatedAt, Status, LogType)
        VALUES (@UMID, @SubAccountUid, SYSUTCDATETIME(), NULL, 0, 'sms');

        COMMIT TRANSACTION;
        SELECT 1;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN ERROR_MESSAGE();
    END CATCH
END
