CREATE PROCEDURE [dbo].[SaveQty]
	@ItemId int,
	@ItemName varchar(50),
	@Quantity int,
	@InQuantity int,
	@Login varchar(50),
	@Date date,
	@Name varchar(50)
	
	
AS
BEGIN
	
	if (@ItemId > 0)
	BEGIN
		Update dbo.Items
			SET 
			ItemName = @ItemName, 
			Quantity = @Quantity+@InQuantity
					
		WHERE ItemId = @ItemId
		INSERT INTO dbo.InQuantityRec(LoginId,Name,ItemName,Date,InQty)
		VALUES( @Login,@Name ,@ItemName,@Date,@InQuantity)

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Items(ItemName ,Quantity)
		VALUES( @Name ,@Quantity)
		
		Select @ItemId = SCOPE_IDENTITY()
	END

	Select @ItemId
END








