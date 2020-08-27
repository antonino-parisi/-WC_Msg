-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2016-04-20
-- Description:	Update dictionaries from MessageSphere
-- =============================================
CREATE PROCEDURE [mno].[job_UpdateDataFromMessageSphere_v1]
AS
BEGIN
	
	/*** SYNC mno.Route ***/
 --   MERGE mno.Country AS target
 --   USING (SELECT CountryISO2alpha,CountryISO3alpha,CountryName,CountryNameFormal,ISO3166numeric,MCCDefault,DialCode,MNPSupport,Currency,CurrencyName,CurrencyMinorUnit,Continent,TimeZoneIdDefault,JsonData FROM WC_MNO.mno.Country) AS source (CountryISO2alpha,CountryISO3alpha,CountryName,CountryNameFormal,ISO3166numeric,MCCDefault,DialCode,MNPSupport,Currency,CurrencyName,CurrencyMinorUnit,Continent,TimeZoneIdDefault,JsonData)
 --   ON (target.CountryISO2alpha = source.CountryISO2alpha)
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (CountryISO2alpha,CountryISO3alpha,CountryName,CountryNameFormal,ISO3166numeric,MCCDefault,DialCode,MNPSupport,Currency,CurrencyName,CurrencyMinorUnit,Continent,TimeZoneIdDefault,JsonData) VALUES (CountryISO2alpha,CountryISO3alpha,CountryName,CountryNameFormal,ISO3166numeric,MCCDefault,DialCode,MNPSupport,Currency,CurrencyName,CurrencyMinorUnit,Continent,TimeZoneIdDefault,JsonData);

	--/*** SYNC mno.Operator ***/
 --   MERGE mno.Operator AS target
 --   USING (
	--		SELECT CAST(o.OperatorId AS INT) AS OperatorId, o.OperatorName, c.CountryISO2alpha,
	--			CAST(o.OperatorId AS INT) / 1000 AS MCC_Default, CAST(o.OperatorId AS INT) % 1000 AS MNC_Default
	--		FROM dbo.Operator o 
	--			INNER JOIN mno.Country c ON c.CountryName = o.Country 
	--	) AS source (OperatorId, OperatorName, CountryISO2alpha, MCC_Default, MNC_Default)
 --   ON (target.OperatorId = source.OperatorId)
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (OperatorId, CountryISO2alpha, OperatorName, MCC_Default, MNC_Default) VALUES (source.OperatorId, source.CountryISO2alpha, source.OperatorName, source.MCC_Default, source.MNC_Default)
	--WHEN MATCHED AND (target.OperatorName <> source.OperatorName OR target.CountryISO2alpha <> source.CountryISO2alpha)THEN
	--	UPDATE SET OperatorName = source.OperatorName, CountryISO2alpha = source.CountryISO2alpha, MCC_Default = source.MCC_Default, MNC_Default = source.MNC_Default;

	/*** SYNC dbo.Operator ***/
    MERGE dbo.Operator AS target
    USING (
			SELECT o.OperatorId, o.OperatorName, c.CountryName
			FROM mno.Operator o 
				INNER JOIN mno.Country c ON c.CountryISO2alpha = o.CountryISO2alpha
		) AS source (OperatorId, OperatorName, CountryName)
    ON (target.OperatorId = source.OperatorId)
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (OperatorId, OperatorName, Details, Country) VALUES (source.OperatorId, source.OperatorName, source.OperatorName, source.CountryName)
	WHEN MATCHED AND (target.OperatorName <> source.OperatorName OR target.Country <> source.CountryName)THEN
		UPDATE SET OperatorName = source.OperatorName, Country = source.CountryName;

	/*** SYNC mno.OperatorIdLookup ***/
 --   MERGE mno.OperatorIdLookup AS target
 --   USING (
	--		SELECT CAST(MCC as smallint) AS MCC, CAST(MNC as smallint) AS MNC, CAST(o.OperatorId AS INT) AS OperatorId
	--		FROM dbo.OperatorIdLookup o
	--	) AS source (MCC, MNC, OperatorId)
 --   ON (target.MCC = source.MCC AND target.MNC = source.MNC)
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (MCC, MNC, OperatorId) VALUES (source.MCC, source.MNC, source.OperatorId)
	--WHEN MATCHED AND target.OperatorId <> source.OperatorId THEN
	--	UPDATE SET OperatorId = source.OperatorId;

	/*** update precalculated MCC_List, MNC_List in mno.Operator ***/
	UPDATE o SET MCC_List = mcc.MCCs, MNC_List = mnc.MNCs
	--SELECT *--o.OperatorId, o.MNC_List, mnc.MNCs
	FROM mno.Operator o
		LEFT JOIN 
		(
			SELECT OperatorId, MNCs = STUFF((
				SELECT N', ' + CAST(MNC AS varchar(3))
				FROM mno.OperatorIdLookup AS p2
				WHERE p2.OperatorId = p.OperatorId /*and p.MCC = p2.MCC*/
				ORDER BY CAST(MNC as int)
				FOR XML PATH(N'')), 1, 2, N'')
			FROM mno.OperatorIdLookup AS p
			GROUP BY OperatorId /*, MCC*/
		) mnc
		ON o.OperatorId = mnc.OperatorId
		LEFT JOIN 
		(
			SELECT OperatorId, MCCs = STUFF((
				SELECT DISTINCT N', ' + CAST(MCC AS varchar(3))
				FROM mno.OperatorIdLookup AS p2
				WHERE p2.OperatorId = p.OperatorId 
				FOR XML PATH(N'')), 1, 2, N'')
			FROM mno.OperatorIdLookup AS p
			GROUP BY OperatorId
		) mcc
		ON o.OperatorId = mcc.OperatorId
	WHERE	
		ISNULL(o.MNC_List,'') <> mnc.MNCs OR ISNULL(o.MCC_List,'') <> mcc.MCCs

	/*** Auto-disable operators with missing configuration ***/
	UPDATE o SET Active = 0
	FROM mno.Operator o
		LEFT JOIN mno.OperatorIdLookup AS oil ON o.OperatorId = oil.OperatorId
		LEFT JOIN WC_MNO.mno.NumberingPlan AS np ON o.OperatorId = np.OperatorId
	WHERE o.Active = 1 AND oil.OperatorId IS NULL AND np.Prefix IS NULL

	/*** SYNC mno.NumberingPlan ***/
 --   MERGE mno.NumberingPlan AS target
 --   USING (
	--		SELECT CAST(np.Prefix AS VARCHAR(16)) AS Prefix, o.OperatorId, tz.TimeZoneId, tz.GMTOffset
	--		FROM dbo.NumberingPlan np
	--			INNER JOIN mno.Operator o ON o.OperatorId = CAST(np.OperatorId AS INT)
	--			INNER JOIN mno.Country c ON c.CountryISO2alpha = o.CountryISO2alpha
	--			INNER JOIN mno.TimeZone tz ON tz.TimeZoneId = c.TimeZoneIdDefault
	--		WHERE ISNUMERIC(np.OperatorId) = 1
	--	) AS source (Prefix, OperatorId, TimeZoneId, GMTOffset)
 --   ON (target.Prefix = source.Prefix)
	--WHEN NOT MATCHED BY SOURCE THEN
	--	DELETE
	--WHEN NOT MATCHED BY TARGET THEN
	--	INSERT (Prefix, OperatorId, TimeZoneId, GMTOffset) VALUES (source.Prefix, source.OperatorId, source.TimeZoneId, source.GMTOffset)
	--WHEN MATCHED AND target.OperatorId <> source.OperatorId THEN
	--	UPDATE SET OperatorId = source.OperatorId;
END