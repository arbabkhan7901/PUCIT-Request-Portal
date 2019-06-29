
CREATE PROCEDURE [dbo].[SearchForgotPasswordLog]
	@Login varchar(100),
	@startDate date,
	@endDate date,
	@pageSize int,
	@pageIndex int
AS
	BEGIN
		Select count(*) 
		from dbo.ForgotPasswordLog rmd
		where (rmd.Login like '%'+@Login + '%'
			  and (cast(rmd.EntyDate as date) Between @startDate and @endDate) )
			

	Select ID, Login, Token, IPAddress as MachineIP, Found, URL, EntyDate, IsUsed
		from dbo.ForgotPasswordLog rmd
		where (rmd.Login like '%'+@Login + '%'
			  and (cast(rmd.EntyDate as date) Between @startDate and @endDate) )
		 Order by rmd.ID DESC	  
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
END







