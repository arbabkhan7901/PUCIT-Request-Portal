


CREATE Procedure [dbo].[GetRolePermissionById]
	@ApproverId int
AS 
BEGIN
		Declare @UserID int = 0
		select @UserID= UserID from dbo.Approvers Where ApproverID = @ApproverId

		Select distinct r.* from dbo.Roles r 
		INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @UserID 

		Select distinct p.*,pm.RoleId from dbo.Permissions p 
		INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
		INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @UserID 

END

/*
declare @date datetime = getdate()
execute dbo.ValidateUser 'BITF13M005','123',@date,'123'
select * from dbo.LoginHistory
*/














