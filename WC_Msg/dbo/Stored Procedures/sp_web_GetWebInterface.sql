CREATE PROCEDURE [dbo].[sp_web_GetWebInterface]
	@InterfaceName VARCHAR(50)		
AS
BEGIN
	SELECT InterfaceName, AssemblyName, ClassName, RouteId 
	FROM dbo.WebInterfaceMapping 
	WHERE InterfaceName = @InterfaceName
END