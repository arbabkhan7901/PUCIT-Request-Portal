
CREATE Procedure [dbo].[GetEmailRequestsByUniqueID]
	@UniqueID varchar(40)
AS 
BEGIN
	
	Select EmailRequestID, Subject, MessageBody, MessageParameters, EmailTo, EmailCC, EmailBCC, EmailTemplate, 
	ScheduleType, ScheduleTime, EmailRequestStatus, EntryTime, UniqueID, isnull(RequestID,0) as RequestID , EmailDetails
	from dbo.EmailRequests
	Where UniqueID = @UniqueID

END










