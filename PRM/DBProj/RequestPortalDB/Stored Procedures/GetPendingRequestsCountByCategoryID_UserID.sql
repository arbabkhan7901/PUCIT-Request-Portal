
CREATE Procedure [dbo].[GetPendingRequestsCountByCategoryID_UserID]
@pFormID int,
@pUserID int
AS
BEGIN
	
	Declare @CurrentPendingCount int = 0;
	Select @CurrentPendingCount = count(*) 
	FROM dbo.RequestMainData r
	Where r.UserId = @pUserID AND r.CategoryID = @pFormID And RequestStatus NOT IN (3,4)

	-- Return count of possible new requests
	Select cast((MaxPendingRequets - @CurrentPendingCount) as int) 
	from dbo.FormCategories Where CategoryID = @pFormID

END








