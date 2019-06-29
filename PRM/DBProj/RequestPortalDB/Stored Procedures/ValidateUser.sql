
CREATE Procedure [dbo].[ValidateUser]
	@Login varchar(50),
	@Password varchar(50),
	@CurrTime datetime,
	@MachineIP varchar(20),
	@IgnorePassword bit,
	@LoggerLoginID varchar(50),
	@pLoginType varchar(20)
AS 
BEGIN

	--DECLARE @Login varchar(50) = ''
	--DECLARE @Password varchar(50) = '123'
	--DECLARE @CurrTime datetime = getdate()
	--DECLARE @MachineIP varchar(20) = ''
	--DECLARE @IgnorePassword bit = 0
	--DECLARE @LoggerLoginID varchar(50) = ''

	Declare @UserId int = 0
	Declare @iscontributor bit =0
	Declare @isActive bit =0
	Declare @isDisabled bit =0

	if(@IgnorePassword = 0)
	BEGIN
		SELECT @UserId=UserId, @iscontributor=IsContributor, @isActive = IsActive ,@isDisabled =Isnull(IsDisabledForLogin,0)
		from dbo.Users u where (Login = @Login OR Email = @Login) and Password = @Password 
	END
	else
	BEGIN	
		SELECT @UserId=UserId, @iscontributor=IsContributor, @isActive = IsActive ,@isDisabled =Isnull(IsDisabledForLogin,0)
		from dbo.Users u where Login = @Login OR Email = @Login 	
	END
	Select UserId, Login, Password, Name, Title, Email, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus, CreatedBy, CreatedOn, Modifiedby, ModifiedOn, IsActive, isnull(IsDisabledForLogin,0) as IsDisabledForLogin, ResetToken 
	from dbo.Users where UserID = @UserId

	if @UserId > 0  AND @isActive = 1 AND @isDisabled = 0
	BEGIN
		
		if @iscontributor = 1
		begin

			Declare @approvers table (ApproverID int,Designation varchar(50),UserID int,IsActive bit)
			Declare @approverid int

			insert into @approvers
			Select ApproverID,Designation,UserID,1 from dbo.vwApproverWithDesig Where UserID = @UserId

			select * from @approvers
			
			select top 1 @approverid = ApproverId from @approvers

			select @approverid

		end

		Select distinct r.* 
			from dbo.Roles r INNER JOIN 
			dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @UserId 
			
			Select distinct p.*,pm.RoleId from dbo.Permissions p 
			INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
			INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @UserId 
			
	END
		IF @LoggerLoginID != ''
			SET @Login = @Login + '_By_' + @LoggerLoginID

		INSERT INTO dbo.LoginHistory(UserID, LoginID, MachineIP, LoginTime,LoginType)
		Select @UserId,@Login,@MachineIP,@CurrTime,@pLoginType

		
END








