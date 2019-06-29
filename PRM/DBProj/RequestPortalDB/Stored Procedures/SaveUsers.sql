
CREATE PROCEDURE [dbo].[SaveUsers]
		@UserId int,
	   @Login varchar(50)
	  ,@Password varchar(100)
      ,@Name varchar(100)
      ,@Email varchar(100),
	  @ActivityTime datetime,
	  @ActivityBy int
      ,@Title varchar(100)
      ,@StdFatherName varchar(100)
      ,@Section varchar(100)
      ,@IsContributor bit
      ,@IsOldCampus bit
	  ,@ApprDesignations ArrayInt2 READONLY
AS
BEGIN
	
	if (@UserId > 0)
	BEGIN

		Update dbo.Users 
			SET Login = @Login, 
			Password = @Password, 
			Name = @Name, 
			Email=@Email, 
			ModifiedOn = @ActivityTime,
			Modifiedby = @ActivityBy,
			Title=@Title, 
			StdFatherName = @StdFatherName,
			Section=@Section, 
			IsOldCampus = @IsOldCampus
			WHERE UserId = @UserId

			if(@IsContributor = 1)
			BEGIN
				Update dbo.Approvers SET IsActive = 0
				Where UserId = @UserId and DesignationID NOT IN (Select ID2 From @ApprDesignations)

				Update dbo.Approvers SET IsActive = 1
				Where UserId = @UserId and DesignationID IN (Select ID2 From @ApprDesignations)

				INSERT INTO dbo.Approvers(UserID,DesignationID,IsActive)
				Select @UserId, ID2,1 
				from @ApprDesignations Where ID2 NOT IN (Select DesignationID from dbo.Approvers 
				Where UserId = @UserId)		

			END
	END
	ELSE
	BEGIN
		INSERT INTO dbo.Users(Login , Password , Name ,Email, CreatedOn,CreatedBy,IsActive,Title, 
			StdFatherName ,
			Section, 
			IsContributor, 
			IsOldCampus)
		VALUES(@Login , @Password , @Name ,@Email,@ActivityTime,@ActivityBy,1,@Title,@StdFatherName,@Section,@IsContributor,@IsOldCampus)
		
		Select @UserId = SCOPE_IDENTITY()

		if(@IsContributor = 1)
		BEGIN
			INSERT INTO dbo.Approvers(UserID,DesignationID,IsActive)
			Select @UserId, ID2,1 from @ApprDesignations
		END
		
	END

	Select @UserId
END











