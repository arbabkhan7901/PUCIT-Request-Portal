
CREATE Procedure [dbo].[SaveUserRoleMapping]
@pUserID int,
@pList ArrayInt READONLY --Here ArrayInt is user defined type
AS
BEGIN

	--Declare @pUserID int = 7
	--Declare @pList ArrayInt
	--insert into @pList Select 1
	--insert into @pList Select 3

	Delete from [dbo].[UserRoles] Where UserId = @pUserID and RoleId NOT IN (select ID from @pList)

	Insert into [dbo].[UserRoles](UserId,RoleId)
	select @pUserID, ID from @pList 
	where ID not IN (select RoleId from [dbo].[UserRoles] Where UserId = @pUserID)

	Select @pUserID

END











