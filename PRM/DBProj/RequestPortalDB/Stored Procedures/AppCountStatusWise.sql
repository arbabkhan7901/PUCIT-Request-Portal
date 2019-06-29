
Create Procedure [dbo].[AppCountStatusWise]
	
AS 
BEGIN

	Declare @usercount int =0 
	Declare @TempID int=1

	Select @usercount=count(*) from dbo.Users
	
	Declare @useridtable Table (ID Int Identity (1,1),userId INT)

	INSERT INTO @useridtable(userId)
	Select UserId From [dbo].[Users] 

	DECLARE @TempTable TABLE (ID INT Identity(1,1), userId INT,LoginName varchar(100),UserName varchar(100),Role varchar(50),Designation varchar(100),ApproverId INT)

	While @TempID <= @usercount
	BEGIN
		Declare @userid int=0
		
		select @userid=UserID from @useridtable where ID=	@TempID
		
		DECLARE @TempApproverTable TABLE (ID INT , ApproverID INT,Designation varchar(100),UserId INT default 0)
	
		INSERT INTO @TempApproverTable(ID,ApproverID , Designation,UserId)
		Select Row_Number() Over ( Order By ApproverID ), a.ApproverID , d.Designation,a.UserID  from [dbo].[Approvers] a Join [dbo].[Designations] d  on a.DesignationID= d.DesignationID where UserID=@userid

		Declare @Approvercount int =0
		
		Select @Approvercount=count(*) from @TempApproverTable
		
		Declare @tempId2 int=1
		
		IF(@Approvercount>0)
		BEGIN
			While @tempId2 <= @Approvercount
			BEGIN

				Declare @ApproverID int = 0
				
				Select @ApproverID=ApproverID from @TempApproverTable where ID=@tempId2
				
				INSERT INTO @TempTable(userId,UserName,LoginName,Role,Designation,ApproverId)
				Select UserId,Name,Login,case IsContributor when 1 then 'Approver' else 'Not Approver' end ,case Title when '' then 'N/A' else (select Designation from @TempApproverTable where ApproverID=@ApproverID) end, @ApproverID From [dbo].[Users] where UserId=@userid

				SET @tempId2 = @tempId2 + 1
	
			END
			DELETE @TempApproverTable 
			
		END
		ELSE
		BEGIN
			
			INSERT INTO @TempTable(userId,UserName,LoginName,Role,Designation,ApproverId)
			Select UserId,Name,Login,case IsContributor when 1 then 'Approver' else 'Not Approver' end ,case Title when '' then 'N/A' else Title end ,0 From [dbo].[Users] where UserId=@userid

		END
			SET @TempID = @TempID + 1

	END

	SELECT * from @TempTable
	
	SELECT @usercount=count(*) from @TempTable
	
	SET @tempId2=1
	
	WHILE @tempId2 <= @usercount
	BEGIN
		Declare @appid int=0
		
		Select @appid=ApproverId from @TempTable where  ID=@tempId2
		
		IF(@appid >0)
		BEGIN
			EXEC dbo.GetAppCountByStatus 2,@appid
		END
		ELSE
		BEGIN
			
			SELECT @appid=userId from @TempTable where ID=@tempId2
			
			EXEC dbo.GetAppCountByStatus 1,@appid
		END
		
		SET @tempId2 = @tempId2 + 1
	END
END









