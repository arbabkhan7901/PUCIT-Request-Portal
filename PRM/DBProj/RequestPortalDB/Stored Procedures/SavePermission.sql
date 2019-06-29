CREATE PROCEDURE [dbo].[SavePermission]
	@Id int,
	@Name varchar(50),
	@Description varchar(50),
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	if (@Id > 0)
	BEGIN
		Update dbo.Permissions
			SET 
			Name = @Name, 
			Description = @Description,
			ModifiedOn = @ActivityTime,
			Modifiedby = @ActivityBy
			where Id=@Id
	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Permissions(Name ,Description,CreatedOn,CreatedBy,IsActive)
		VALUES( @Name ,@Description,@ActivityTime,@ActivityBy,1)
		
		Select @Id = SCOPE_IDENTITY()
	END

	Select @Id
END












