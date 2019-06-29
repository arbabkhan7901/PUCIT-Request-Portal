CREATE PROCEDURE [dbo].[GetFormCategoriesByRoleID]
@UserId int,
@flag int
AS
if (@flag=0)
BEGIN
	-- Get Role ID
	Declare @roleId int
	SELECT distinct @roleId = RoleId from dbo.UserRoles Where UserId = @UserId

	--Get Forms against role	 
	Select * from dbo.FormCategories where CategoryID IN(Select FormID from dbo.FormRoleMapping where RoleId = @roleId)
END
else if (@flag=1)
BEGIN
	--Get Form Categories
	Select * from dbo.FormCategories where CategoryID IN(Select CategoryID from dbo.RequestMainData rmd, dbo.ReqWorkflow rwf where rmd.RequestID = rwf.RequestID and rwf.UserID = @UserId)
END

else if (@flag=2)
BEGIN
	--Get Forms	 
	Select * from dbo.FormCategories
END









