
CREATE Procedure [dbo].[SaveContributorsForForm]
@pFormID int,
@pList ArrayIntFlags READONLY -- ApproverID, Order, IsNewCampus,IsOldCampus
AS
BEGIN

	--Declare @pFormID int = 2
	--Declare @pList ArrayInt
	--insert into @pList Select 1
	--insert into @pList Select 3

	
	Delete from [dbo].[ApproverHierarchy] Where FormID = @pFormID and ApproverID NOT IN (select ID1 from @pList)

	Update t1 SET t1.ApprovalOrder = p.ID2, 
		   t1.IsForNewCampus = p.Flag1, 
		   t1.IsForOldCampus = p.Flag2
	From [dbo].[ApproverHierarchy] t1
	INNER JOIN @pList p ON t1.ApproverID = p.ID1 and t1.FormID = @pFormID

	Insert into [dbo].[ApproverHierarchy](FormID, ApproverID, ApprovalOrder, IsForNewCampus, IsForOldCampus)
	select @pFormID, ID1,ID2,Flag1,Flag2 from @pList 
	where ID1 not IN (select ApproverID from [dbo].[ApproverHierarchy] Where FormID = @pFormID)

	Select @pFormID

END











