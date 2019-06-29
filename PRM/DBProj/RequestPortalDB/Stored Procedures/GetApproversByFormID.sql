CREATE Procedure [dbo].[GetApproversByFormID]
@pFormID int
AS
BEGIN
	
	Select ah.ApproverID,ah.IsForNewCampus,ah.IsForOldCampus, d.DesigWithName,
	cast(ROW_NUMBER() OVER (Order by ApprovalOrder) as int) AS ApprovalOrder
	from [dbo].[ApproverHierarchy] ah 
	INNER JOIN [dbo].[vwApproverWithDesig] d ON ah.ApproverID = d.ApproverID
	Where FormID = @pFormID
	
END











