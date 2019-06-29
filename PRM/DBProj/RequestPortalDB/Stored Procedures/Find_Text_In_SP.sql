CREATE Procedure [dbo].[Find_Text_In_SP]
@StringToSearch varchar(100)
AS
BEGIN
SET @StringToSearch = '%' +@StringToSearch + '%'
SELECT Distinct SO.Name
FROM sysobjects SO (NOLOCK)
INNER JOIN syscomments SC (NOLOCK) on SO.Id = SC.ID
AND SO.Type = 'P'
AND SC.Text LIKE @stringtosearch
ORDER BY SO.Name

END












