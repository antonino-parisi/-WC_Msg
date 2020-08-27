
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-09
-- =============================================
-- EXEC cp.[CmSummary_Recalculate]
-- SELECT * FROM cp.CmSummary
CREATE PROCEDURE [cp].[CmSummary_Recalculate]
AS
BEGIN
	
	-- Update CmSummary
	MERGE cp.CmSummary AS target
    USING (
		SELECT AccountUid, COUNT(1) AS TotalContacts, 
			--COUNT(1) - COUNT(DeletedAt) AS TotalContactsActive
			SUM(CASE WHEN DeletedAt IS NULL THEN 1 ELSE 0 END) AS TotalContactsActive
		FROM cp.CmContact
		GROUP BY AccountUid
	) AS source (AccountUid, TotalContacts, TotalContactsActive)
    ON (target.AccountUid = source.AccountUid)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (AccountUid, TotalContacts, TotalContactsActive) VALUES (source.AccountUid, source.TotalContacts, source.TotalContactsActive)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	WHEN MATCHED THEN
		UPDATE SET TotalContacts = source.TotalContacts, TotalContactsActive = source.TotalContactsActive;

	-- Update ContactsCount for Groups
	UPDATE g SET ContactsCount = gc.ContactsCount
	FROM cp.CmGroup g
		INNER JOIN 
		(SELECT gc.GroupId, COUNT(gc.ContactId) AS ContactsCount
		FROM cp.CmGroupContact gc
			INNER JOIN cp.CmContact c ON c.ContactId = gc.ContactId AND c.DeletedAt IS NULL
		GROUP BY gc.GroupId) gc ON g.GroupId = gc.GroupId
END
