

CREATE Procedure [dbo].[Swap_Approvers]
@RequestID int,
@pFirstApproverID int,
@pSecondApproverID int,
@ActivityDateTime datetime,
@Remarks varchar(500),
@UniqueId varchar(40),
@ReqUniqueId varchar (40)
AS
BEGIN
		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			SELECT cast(0 as bit) as success, 'Invalid Access' As error
			Return;
		END

		Declare @result bit = 0
		Declare @message varchar(100) =''

		Declare @IsParallel bit
	
		Select @IsParallel = IsParalApprovalAllowed from dbo.FormCategories fm INNER JOIN dbo.RequestMainData rm
		ON fm.CategoryID = rm.CategoryID And rm.RequestID = @RequestID
	
		IF(@IsParallel = 1)
		BEGIN
			SELECT cast(0 as bit) as success, 'Not Allowed for Parallel Approval Forms' As error
			Return;
		END 


		Declare @FirstApproverWFID int
		Declare @SecondApproverWFID int

		Declare @FirstApproverWFStatus int
		Declare @SecondApproverWFStatus int
	
		Declare @FirstApproverWFOrder int
		Declare @SecondApproverWFOrder int

		Declare @FirstIsCurrentApprover bit
		Declare @SecondIsCurrentApprover bit

		Select @FirstApproverWFID = rf.ID, 
			   @FirstApproverWFStatus = rf.Status, 
			   @FirstApproverWFOrder = rf.ApprovalOrder,
			   @FirstIsCurrentApprover = IsCurrApprover
		from dbo.ReqWorkflow rf Where RequestID = @RequestID And ApproverID = @pFirstApproverID

		Select @SecondApproverWFID = rf.ID, 
			   @SecondApproverWFStatus = rf.Status, 
			   @SecondApproverWFOrder = rf.ApprovalOrder,
			   @SecondIsCurrentApprover = IsCurrApprover
		from dbo.ReqWorkflow rf Where RequestID = @RequestID And ApproverID = @pSecondApproverID

		IF (@FirstApproverWFStatus =2  AND @SecondApproverWFStatus = 1) --First Approver is Assigned, Second Approver is Not-Assigned
		BEGIN
			
			BEGIN Transaction 
				BEGIN TRY  
					Declare @username varchar(100)
					Declare @username2 varchar(100)

					-- Update Data of First Approver with data of second approver
					Update dbo.ReqWorkflow 
					SET Status = @SecondApproverWFStatus, ApprovalOrder = @SecondApproverWFOrder, IsCurrApprover = @SecondIsCurrentApprover
					Where ID = @FirstApproverWFID

					exec dbo.AddEmailRequestToApprover 5, @RequestID,0, @UniqueId, '', @Remarks, '',@pFirstApproverID
					SELECT @username = DesigWithName 
					FROM dbo.vwApproverWithDesig WHERE ApproverID = @pFirstApproverID

					-- Update Data of Second Approver with data of first approver
					Update dbo.ReqWorkflow 
					SET Status = @FirstApproverWFStatus, ApprovalOrder = @FirstApproverWFOrder, IsCurrApprover = @FirstIsCurrentApprover
					Where ID = @SecondApproverWFID

					exec dbo.AddEmailRequestToApprover 6, @RequestID, 0, @UniqueId, '', @Remarks, '',@pSecondApproverID
					SELECT @username2 = DesigWithName 
					FROM dbo.vwApproverWithDesig WHERE ApproverID = @pSecondApproverID
		
					INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
					Values(@RequestID, @pFirstApproverID, @Remarks, 'Request Approval Order is Swapped By ' + @username + ' with ' + @username2 ,@ActivityDateTime)

					INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
					Values(@RequestID, @pFirstApproverID, 'Swapped', 'Request is un-assigned from ' + @username ,@ActivityDateTime)

					INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
					Values(@RequestID, @pFirstApproverID, 'Swapped', 'Request is assigned to ' + @username2 ,@ActivityDateTime)
					COMMIT; -- commit transaction
					SELECT cast(1 as bit) as success, 'Swap is completed.' As error
					Return;
				END TRY
				BEGIN CATCH
					Rollback; -- rollback the transaction
					SELECT cast(0 as bit) as success, 'Some problem has occurred during transaction.' As error
					Return;
				END CATCH
		END
		ELSE
		BEGIN
			SELECT cast(0 as bit) as success, 'Swap is only allowed if First Approver Status is Assigned & Second Approver Status is Pending.' As error
			Return;
		END
	

END






