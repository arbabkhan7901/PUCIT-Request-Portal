CREATE PROCEDURE [dbo].[SaveRoles]
	@RoleId int,
	@Name varchar(50),
	@Description varchar(50),
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	if (@RoleId > 0)
	BEGIN
		Update dbo.Roles
			SET 
			Name = @Name, 
			Description = @Description,
			ModifiedBy=@ActivityBy,
			ModifiedOn=@ActivityTime
		WHERE Id = @RoleId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Roles(Name ,Description,CreatedBy,CreatedOn,IsActive)
		VALUES( @Name ,@Description,@ActivityBy,@ActivityTime,1)
		
		Select @RoleId = SCOPE_IDENTITY()
	END

	Select @RoleId
END












