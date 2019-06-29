
CREATE PROCEDURE [dbo].[EnableDisableRole]
    @RoleId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Roles SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where ID = @RoleId
	
	Select @RoleId
END











