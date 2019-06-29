
CREATE PROCEDURE [dbo].[EnableDisableUser]
    @UserId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Users SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where UserID = @UserId
	
	Select @UserId
END












