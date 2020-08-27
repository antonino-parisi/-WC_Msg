CREATE ROLE [role_team_fin]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_fin] ADD MEMBER [user_fin_HV];


GO
ALTER ROLE [role_team_fin] ADD MEMBER [user_FIN];

