
CREATE Procedure [dbo].[GetAllDesignations]
AS 
BEGIN
		Select DesignationID,Designation 
		from dbo.Designations
		Where IsActive = 1
END












