
CREATE PROCEDURE [dbo].[DeleteUsers]
		@UserId int,
	    @ModifiedBy varchar(100),
	    @ModifiedOn DateTime
AS
BEGIN
	
	Update dbo.Users
		SET 
		IsActive = 0
		
	WHERE UserId = @UserId

	
	select @UserId
END













