CREATE PROCEDURE [dbo].[SaveItems]
	@ItemId int,
	@Name varchar(50),
	@Description varchar(50),
	@Quantity int,
	@Type int,
	@ActivityTime datetime,
	@ActivityBy int
	
AS
BEGIN
	
	if (@ItemId > 0)
	BEGIN
		Update dbo.Items
			SET 
			ItemName = @Name, 
			Description= @Description,
			Type = @Type,
			ModifiedOn = @ActivityTime,
			Modifiedby = @ActivityBy
			
		WHERE ItemId = @ItemId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Items(ItemName ,Description,Quantity,Type,IsActive, CreatedOn,CreatedBy)
		VALUES( @Name ,@Description,0,@Type,1,@ActivityTime,@ActivityBy)
		
		Select @ItemId = SCOPE_IDENTITY()
	END

	Select @ItemId
END








