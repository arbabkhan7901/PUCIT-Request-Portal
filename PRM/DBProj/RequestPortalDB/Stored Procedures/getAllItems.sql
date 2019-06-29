CREATE PROCEDURE [dbo].[getAllItems] 
	
AS
BEGIN
	

    -- Insert statements for procedure here
	SELECT * from dbo.Items where Type = 11 or Type=22;
END






