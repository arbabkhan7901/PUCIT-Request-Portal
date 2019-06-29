
CREATE PROCEDURE [dbo].[SearchLoginHistory]
	@login varchar(20),
	@machineip varchar(20),
	@startDate date,
	@endDate date,
	@pageSize int,
	@pageIndex int
AS
	BEGIN
		Select count(*) 
		from [dbo].[LoginHistory] rmd
		where (rmd.LoginID like '%'+@login + '%'
			  and rmd.MachineIP like '%'+ @machineip + '%'
			  and (cast(rmd.LoginTime as date) Between @startDate and @endDate) )
			

	Select LoginHistoryID,UserID,LoginID,MachineIP,LoginTime 
		from [dbo].[LoginHistory] rmd
		where (rmd.LoginID like '%'+@login + '%'
			  and rmd.MachineIP like '%'+ @machineip + '%'
			  and (cast(rmd.LoginTime as date) Between @startDate and @endDate))
		 Order by rmd.LoginHistoryID	  
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
END









