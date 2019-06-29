CREATE Procedure [dbo].[SaveRolePermissionMapping]
@pRoleID int,
@pList ArrayInt READONLY --Here ArrayInt is user defined type
AS
BEGIN

	--Declare @pRoleID int = 2
	--Declare @pList ArrayInt
	--insert into @pList Select 1
	--insert into @pList Select 3

	Delete from [dbo].[PermissionsMapping] Where RoleId = @pRoleID and PermissionId NOT IN (select ID from @pList)

	Insert into [dbo].[PermissionsMapping](RoleId,PermissionId)
	select @pRoleID, ID from @pList 
	where ID not IN (select PermissionID from [dbo].[PermissionsMapping] Where RoleId = @pRoleID)

	Select @pRoleID

END











