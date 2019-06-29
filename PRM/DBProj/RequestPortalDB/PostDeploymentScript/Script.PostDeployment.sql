/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/*
IF $(DeployDefaultValues) = 0
	SET NOEXEC ON

:r ".\DataScripts\dbo_users_data.sql"
:r ".\DataScripts\dbo_form_categories.sql"
:r ".\DataScripts\dbo_designations.sql"
:r ".\DataScripts\dbo_approvers.sql"
:r ".\DataScripts\dbo_ApproverHierarchy.sql"
:r ".\DataScripts\dbo_AttachmentTypes.sql"
:r ".\DataScripts\dbo_Permissions.sql"
:r ".\DataScripts\dbo_Roles.sql"
:r ".\DataScripts\dbo_PermissionsMapping.sql"
:r ".\DataScripts\dbo_StatusTypes.sql"
:r ".\DataScripts\dbo_UserRoles.sql"

SET NOEXEC OFF
*/

/*
Following solution will not work if any script has GO
statement in it. You can't have GO in IF Begin/End block. 
For those cases, use above NoEXEC solution
*/

IF $(DeployDefaultValues) = 1
BEGIN
	:r ".\DataScripts\dbo_users_data.sql"
	:r ".\DataScripts\dbo_form_categories.sql"
	:r ".\DataScripts\dbo_designations.sql"
	:r ".\DataScripts\dbo_approvers.sql"
	:r ".\DataScripts\dbo_ApproverHierarchy.sql"
	:r ".\DataScripts\dbo_AttachmentTypes.sql"
	:r ".\DataScripts\dbo_Permissions.sql"
	:r ".\DataScripts\dbo_Roles.sql"
	:r ".\DataScripts\dbo_PermissionsMapping.sql"
	:r ".\DataScripts\dbo_StatusTypes.sql"
	:r ".\DataScripts\dbo_UserRoles.sql"
	:r ".\DataScripts\dbo_FormRoleMapping.sql"
	:r ".\DataScripts\dbo_Items.sql"
	:r ".\DataScripts\dbo_TypeForCreator.sql"
	:r ".\DataScripts\dbo_TypesForContributor.sql"

END
