CREATE ROLE [role_team_product]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [role_team_product] ADD MEMBER [WAVECELL\Product Team];


GO
ALTER ROLE [role_team_product] ADD MEMBER [user_MM];


GO
ALTER ROLE [role_team_product] ADD MEMBER [user_SH];


GO
ALTER ROLE [role_team_product] ADD MEMBER [user_BK];

