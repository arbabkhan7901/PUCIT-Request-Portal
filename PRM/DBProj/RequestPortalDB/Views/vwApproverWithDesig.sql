CREATE VIEW [dbo].[vwApproverWithDesig]
AS
SELECT a.ApproverID,a.UserID,u.Name,d.Designation,u.Email, d.Designation + ' (' + u.Name + ')' AS DesigWithName,u.Login 
from dbo.Approvers a
INNER JOIN dbo.Users u on a.UserId = u.UserId and a.IsActive = 1 and u.IsActive = 1 and u.IsContributor = 1
INNER JOIn dbo.Designations d on a.DesignationID = d.DesignationID and d.IsActive = 1









