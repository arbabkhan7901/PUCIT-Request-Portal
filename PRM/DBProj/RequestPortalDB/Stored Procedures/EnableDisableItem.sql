CREATE PROCEDURE [dbo].[EnableDisableItem]
		@ItemId int,
		@ActivityTime datetime,
		@ActivityBy int,
		@IsActive bit
AS
BEGIN
	
	Update dbo.Items SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy	
	WHERE ItemId = @ItemId
	--Select @ItemId
	select cast(1 as bit)

END