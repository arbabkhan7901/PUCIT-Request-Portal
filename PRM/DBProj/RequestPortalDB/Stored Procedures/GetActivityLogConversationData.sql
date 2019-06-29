
CREATE Procedure [dbo].[GetActivityLogConversationData]
	@RequestId int,
	@activityLogID int,
	@UserID int,
	@accessType int,
	@ApproverId int,
	@ReqUniqueId varchar (40)
As 
Begin

		declare @id int = @UserID
		if @accessType =2 --Assigned
		begin
			Set @id = @ApproverId
		end
		
		if dbo.IsValidLogId(@RequestId,@ActivityLogID,@id,@accessType,@ReqUniqueId) = 1
		begin
			Select al.*,u.Name as UserName 
			from [dbo].[ActivityLogConversations] al inner join dbo.Users u on al.UserID = u.UserId
			and al.ActivityLogID = @activityLogID
			Order by al.MessageTime desc
		end
		else 
		begin
			Select al.*,'' as UserName 
			from [dbo].[ActivityLogConversations] al where ConversationID =-1
		end
		
End






