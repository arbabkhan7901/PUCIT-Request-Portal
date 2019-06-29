


CREATE Procedure [dbo].[ItemSearchReport]
@login varchar(50),
@item varchar(50), 
@startDate date,
@endDate date,
@searchType int
AS 
BEGIN
	if @item!=''
	begin
	-- hardware form
	SELECT SUM(h.IssuedQty)as IssuedQty,h.ItemName,n.Login,n.Name  From dbo.HardwareForm h
	
	INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%'))) as n
	ON h.RequestID = n.RequestID AND h.ItemName = @item AND h.IssuedQty != 0 
		group by h.ItemName,n.Login,n.Name 

	UNION 
	--demand form
	SELECT SUM(d.IssuedQty)as IssuedQty,d.ItemName,n.Login,n.Name From dbo.DemandForm d 
INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%'))) as n
	ON d.RequestID = n.RequestID AND d.ItemName = @item AND d.IssuedQty != 0 
		group by d.ItemName,n.Login,n.Name 
	end
	
	else if @item=''
	begin
	-- hardware form
	SELECT SUM(h.IssuedQty)as IssuedQty,h.ItemName,n.Login,n.Name  From dbo.HardwareForm h
	
	INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%'))) as n
	ON h.RequestID = n.RequestID AND h.IssuedQty != 0 
		group by h.ItemName,n.Login,n.Name 

	UNION 
	--demand form
	SELECT SUM(d.IssuedQty)as IssuedQty,d.ItemName,n.Login,n.Name From dbo.DemandForm d 
INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%'))) as n
	ON d.RequestID = n.RequestID AND d.IssuedQty != 0 
		group by d.ItemName,n.Login,n.Name 
	end
	
	if @login='' AND @item!=''
	begin
	-- hardware form
	SELECT SUM(h.IssuedQty)as IssuedQty,h.ItemName,n.Login,n.Name  From dbo.HardwareForm h
	
	INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3) as n
	ON h.RequestID = n.RequestID AND h.ItemName = @item AND h.IssuedQty != 0 
		group by h.ItemName,n.Login,n.Name 

	UNION 
	--demand form
	SELECT SUM(d.IssuedQty)as IssuedQty,d.ItemName,n.Login,n.Name From dbo.DemandForm d 
INNER JOIN
	
	(Select u.Login,u.Name, u.Title,t.*

	FROM dbo.Users 	u 
	INNER JOIN 
(select UserId,RequestStatus,RequestID
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId,RequestStatus,RequestID) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and t.RequestStatus=3) as n
	ON d.RequestID = n.RequestID AND d.ItemName = @item AND d.IssuedQty != 0 
		group by d.ItemName,n.Login,n.Name 
	end
	
END






