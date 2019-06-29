CREATE PROCEDURE [dbo].[getItems] 
	
AS
BEGIN
	

    -- Insert statements for procedure here
	SELECT * from dbo.Items where Type = 11 and IsActive=1;
END






