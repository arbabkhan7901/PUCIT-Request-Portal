

Create procedure [dbo].[GetPendingRequestsForNotifications]

AS
Begin
	Select d.ApproverID,d.UserID,d.Name,d.Designation,d.Email,
	Datediff(day,Isnull(StatusTime,EntryTime), getdate()) As PendingDays,
	rm.RequestID,rm.RollNo,fm.Category
	FROM [dbo].[ReqWorkflow] rw INNER JOIN dbo.vwApproverWithDesig d ON d.ApproverID = rw.ApproverID
	INNER JOIN dbo.RequestMainData rm on rw.RequestID = rm.RequestID
	INNER JOIN dbo.FormCategories fm on rm.CategoryID = fm.CategoryID
	Where Status = 2
	Order by Name, PendingDays DESC
End











