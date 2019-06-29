CREATE PROCEDURE [dbo].[GetRolesByUserID]
@UserID int
AS
BEGIN
	SELECT distinct RoleId from dbo.UserRoles Where UserId = @UserID 
END










