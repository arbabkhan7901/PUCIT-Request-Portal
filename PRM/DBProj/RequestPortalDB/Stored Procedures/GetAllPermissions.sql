CREATE Procedure [dbo].[GetAllPermissions]
AS 
BEGIN
		-- User Permissions
		Select distinct p.* from dbo.Permissions p
END












