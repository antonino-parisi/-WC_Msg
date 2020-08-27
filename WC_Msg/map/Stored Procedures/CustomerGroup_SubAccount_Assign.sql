-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-10-12
-- =============================================
CREATE PROCEDURE [map].[CustomerGroup_SubAccount_Assign]
	@SubAccountUid int,
	@CustomerGroupIdNew int,
	@MigrationPlan varchar(20) = 'reset_all',	-- Supported values: 'keep_all', 'keep_customonly', 'reset_all' 
	@UpdatedBy smallint
AS
BEGIN			
	-- remove identical records of subaccount that matches with new group
	UPDATE cgc SET Deleted = 1, UpdatedBy = @UpdatedBy
	FROM rt.CustomerGroupCoverage cgc
	WHERE cgc.CustomerGroupId = @CustomerGroupIdNew AND cgc.Deleted = 0
		AND SubAccountUid = @SubAccountUid
		-- filter similar rules matching with new group
		AND EXISTS (
			SELECT 1 FROM rt.CustomerGroupCoverage 
			WHERE CustomerGroupId = cgc.CustomerGroupId AND Deleted = 0
				AND SubAccountUid IS NULL
				AND Country = cgc.Country
				AND ISNULL(OperatorId,0) = ISNULL(cgc.OperatorId,0)
				-- if all values are same ...
				AND (	   ISNULL(RoutingGroupId, 0) = ISNULL(cgc.RoutingGroupId, 0)
						AND ISNULL(PricingPlanId, 0) = ISNULL(cgc.PricingPlanId, 0)
						AND Price = cgc.Price
						AND ISNULL(MarginRate, -999) = ISNULL(cgc.MarginRate, -999)) )

	PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - rules marked as duplicates (soft deleted)')

	BEGIN TRY
		BEGIN TRANSACTION
	
		DECLARE @CustomerGroupIdPrev int = NULL
		-- Check if this sub-account belongs to a group
		-- As per Ben, a member can be re-assign to another group without deleting it first from its current group
		-- So, no need for Deleted = 1 in the WHERE clause
		IF NOT EXISTS (SELECT 1 FROM [rt].[CustomerGroupSubAccount] WHERE SubAccountUid = @SubAccountUid)
		BEGIN
			-- command moved to relevant SP map.CustomerGroup_SubAccount_Add
			--INSERT INTO rt.CustomerGroupSubAccount (CustomerGroupId, SubAccountUid)
			--VALUES (@CustomerGroupIdNew, @SubAccountUid)
			EXEC map.CustomerGroup_SubAccount_Add @CustomerGroupId = @CustomerGroupIdNew, @SubAccountUid = @SubAccountUid
		
			PRINT dbo.Log_ROWCOUNT('CustomerGroupSubAccount inserted')
		END
		ELSE
		BEGIN
			-- read prev CustomerGroupId for futher migration
			SELECT @CustomerGroupIdPrev = CustomerGroupId 
			FROM rt.CustomerGroupSubAccount 
			WHERE SubAccountUid = @SubAccountUid AND Deleted = 0 AND CustomerGroupId <> @CustomerGroupIdNew
	
			-- Re-assign to new customer group
			UPDATE TOP (1) rt.CustomerGroupSubAccount
			SET CustomerGroupId = @CustomerGroupIdNew, Deleted = 0, UpdatedAt = SYSUTCDATETIME()
			WHERE SubAccountUid = @SubAccountUid AND (
				--priority of update to un-deleted record
				(@CustomerGroupIdPrev IS NOT NULL AND Deleted = 0) OR @CustomerGroupIdPrev IS NULL)

			PRINT dbo.Log_ROWCOUNT('CustomerGroupSubAccount updated')
		END

		--- mistery operations with CustomerGroupCoverage
		IF @MigrationPlan ='keep_all'
		BEGIN
			-- hard delete soft deleted custom rules
            DELETE FROM rt.CustomerGroupCoverage
			WHERE CustomerGroupId = @CustomerGroupIdNew AND Deleted = 1 and SubAccountUid = @SubAccountUid

			-- move custom rules
			UPDATE rt.CustomerGroupCoverage
			SET CustomerGroupId = @CustomerGroupIdNew, UpdatedBy = @UpdatedBy
			WHERE SubAccountUid = @SubAccountUid AND Deleted = 0

			PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - CustomerGroupId changed')
			
			-- duplicate rules that differs from new group
			-- very long logic here :`(
			-- STATUS: NOT FINISHED YET : START ---
			
			-- TODO: Custom RoutingGroupId have to be duplicated as well
			
			-- debug
			--select * FROM rt.CustomerGroupCoverage cgc
			--WHERE cgc.CustomerGroupId = @CustomerGroupIdPrev AND cgc.Deleted = 0 AND SubAccountUid IS NULL

			--select * FROM rt.CustomerGroupCoverage cgc
			--WHERE cgc.CustomerGroupId = @CustomerGroupIdNew AND cgc.Deleted = 0 and SubAccountUid = @SubAccountUid

			-- create new custom rules
			DELETE FROM rt.CustomerGroupCoverage
			WHERE CustomerGroupId = @CustomerGroupIdNew AND Deleted = 1 and SubAccountUid = @SubAccountUid

			INSERT INTO rt.CustomerGroupCoverage (
				CustomerGroupId, SubAccountUid, Country, OperatorId, TrafficCategory, 
				RoutingPlanId, RoutingGroupId, 
				PricingPlanId, PriceCurrency, Price, MarginRate, 
				CompanyCurrency, CompanyPrice,
				CostCurrency, CostCalculated, 
				CreatedAt, CreatedBy, 
				UpdatedAt, UpdatedBy)
			SELECT @CustomerGroupIdNew, @SubAccountUid, 
				Country, OperatorId, TrafficCategory, 
				RoutingPlanId, 
				RoutingGroupId /* !!! not fully implemented yet !!!, have to be duplicated value for custom RoutingGroupId too */, 
				PricingPlanId, PriceCurrency, Price, MarginRate, 
				CompanyCurrency, CompanyPrice,
				CostCurrency, CostCalculated, 
				SYSUTCDATETIME() AS CreatedAt, @UpdatedBy AS CreatedBy, 
				SYSUTCDATETIME() AS UpdatedAt, @UpdatedBy AS UpdatedBy
			FROM rt.CustomerGroupCoverage cgc
			WHERE cgc.CustomerGroupId = @CustomerGroupIdPrev AND cgc.Deleted = 0
				AND cgc.SubAccountUid IS NULL
				-- exclude similar rules from new group
				AND NOT EXISTS (
					SELECT 1 FROM rt.CustomerGroupCoverage 
					WHERE CustomerGroupId = @CustomerGroupIdNew AND Deleted = 0
						AND (SubAccountUid IS NULL OR SubAccountUid = @SubAccountUid)
						AND Country = cgc.Country
						AND ISNULL(OperatorId,0) = ISNULL(cgc.OperatorId,0)
						---- if any of following values differ ...
						--AND (	   ISNULL(RoutingGroupId, 0) = ISNULL(cgc.RoutingGroupId, 0)
						--		OR ISNULL(PricingPlanId, 0)  = ISNULL(cgc.PricingPlanId, 0)
						--		OR Price = cgc.Price 
						--		OR ISNULL(MarginRate, -999)  = ISNULL(cgc.MarginRate, -999)) 
				)

			PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - new custom rules added')
			-- STATUS: NOT FINISHED YET : END---
		END
		-- move member to new group, retaining it custom rules only. The rest will come from new group
		ELSE IF @MigrationPlan = 'keep_customonly'
		BEGIN
            -- hard delete soft deleted custom rules
            DELETE FROM rt.CustomerGroupCoverage
			WHERE CustomerGroupId = @CustomerGroupIdNew AND Deleted = 1 and SubAccountUid = @SubAccountUid

			UPDATE rt.CustomerGroupCoverage
			SET CustomerGroupId = @CustomerGroupIdNew, UpdatedBy = @UpdatedBy
			WHERE SubAccountUid = @SubAccountUid AND Deleted = 0

			PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - CustomerGroupId changed')

		END
		-- move member to new group, disregard any previous coverage, drop all to new defaults
		ELSE IF @MigrationPlan = 'reset_all' 
		BEGIN
			UPDATE rt.CustomerGroupCoverage
			SET Deleted = 1, UpdatedBy = @UpdatedBy
			WHERE SubAccountUid = @SubAccountUid

			PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - soft deleted custom rules')
		END
		ELSE
		BEGIN
			PRINT dbo.CURRENT_TIMESTAMP_STR() + 'WARNING! Not supported MigrationPlan'
			-- throw error?
		END

		-- remove identical records of subaccount that matches with new group
		UPDATE cgc SET Deleted = 1, UpdatedBy = @UpdatedBy
		FROM rt.CustomerGroupCoverage cgc
		WHERE cgc.CustomerGroupId = @CustomerGroupIdNew AND cgc.Deleted = 0
			AND SubAccountUid = @SubAccountUid
			-- filter similar rules matching with new group
			AND EXISTS (
				SELECT 1 FROM rt.CustomerGroupCoverage 
				WHERE CustomerGroupId = cgc.CustomerGroupId AND Deleted = 0
					AND SubAccountUid IS NULL
					AND Country = cgc.Country
					AND ISNULL(OperatorId,0) = ISNULL(cgc.OperatorId,0)
					-- if all values are same ...
					AND (	   ISNULL(RoutingGroupId, 0) = ISNULL(cgc.RoutingGroupId, 0)
							AND ISNULL(PricingPlanId, 0) = ISNULL(cgc.PricingPlanId, 0)
							AND Price = cgc.Price
							AND ISNULL(MarginRate, -999) = ISNULL(cgc.MarginRate, -999)) )

		PRINT dbo.Log_ROWCOUNT('CustomerGroupCoverage - rules marked as duplicates (soft deleted)')

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 		

		PRINT dbo.CURRENT_TIMESTAMP_STR() + 'Transaction aborted. Error occured: ' + ERROR_MESSAGE();
		
		THROW;
	END CATCH
END
