
CREATE PROCEDURE [dbo].[EnableDisablePermission]
    @PermissionId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Permissions SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where ID = @PermissionId
	
	Select @PermissionId
END











