
SET IDENTITY_INSERT dbo.Permissions ON

MERGE INTO dbo.Permissions AS Target 
USING (
	Select '1','canWriteApplication','can write application' UNION ALL
	Select '2','canEditApplication','can edit application before submission' UNION ALL
	Select '3','canApproveApplication','can approve application' UNION ALL
	Select '4','canRejectApplication','can reject application' UNION ALL
	Select '5','canAddContributor','can add contributor' UNION ALL
	Select '6','canPrintApplication','can print application' UNION ALL
	Select '7','canGiveRemarks','can give remarks/comments on application' UNION ALL
	Select '8','perCanProvideSignature','A user can upload signture file if he has this per' UNION ALL
	Select '9','perCanForwardApplication','A user can use "forward" button to send/forward ap' UNION ALL
	Select '10','perCanAccessAttachedDocs','A user can access the documents attached with an a' UNION ALL
	Select '11','perAccessToAppsOtherThanSelfAssigned','A user can access applications which are neither c' UNION ALL
	Select '13','perAccessToAssignedApps','A user can access applications assigned to him' UNION ALL
	Select '15','perAccessToSelfCreatedApps','A user can access applications created by himself' UNION ALL
	Select '16','PerCanHandleRecieving','Can do reciecing activity' UNION ALL
	Select '17','PerCanAllowApplicationEditing','PerCanAllowApplicationEditing' UNION ALL
	Select '18','PerCanRouteBack','PerCanRouteBack' UNION ALL
	Select '19','PerUpdateBonaFiedCGPA','PerUpdateBonaFiedCGPA' UNION ALL
	SELECT 26, N'perAccessToAllApps', N'Admin can access all apps' UNION ALL
	SELECT 27, N'perCanAccessAdminViews', N'Admin can access its views' UNION ALL
	SELECT 28, N'perCanLoginAsOtherUser', N'Admin can login as other user' UNION ALL
	Select '29','perManageSecurityUsers','' UNION ALL
	Select '30','perManageSecurityRoles','' UNION ALL
	Select '31','perManageSecurityPermissions','' UNION ALL
	Select '32','perViewLoginHistoryReport','' UNION ALL
	Select '33','perManageWorkFlows','' UNION ALL
	Select '34','perViewApplicationCountStatuswise','' UNION ALL
	Select '35','perDecideBehalfOnOtherUser','' UNION ALL
	Select 36, 'perCanSwapRequestAssignmentWithApprover','' UNION ALL
	SELECT 37, 'perCanAccessSelfAndAssigned','' UNION ALL
	Select 38, 'perManageSecurityInventory', '' UNION ALL
	Select 41, 'perViewItemsReport', ''
) 
AS Source (Id, Name, Description) 
ON Target.Id = Source.Id
WHEN MATCHED THEN 
UPDATE SET 
	Name = Source.Name,
	Description = Source.Description

WHEN NOT MATCHED BY TARGET THEN 
INSERT (Id, Name, Description) 
VALUES (Id, Name, Description);
--WHEN NOT MATCHED BY SOURCE THEN 
--DELETE;

SET IDENTITY_INSERT dbo.Permissions OFF
