CREATE TABLE [dbo].[UserRoles] (
    [UserRoleID] INT IDENTITY (1, 1) NOT NULL,
    [UserId]     INT NOT NULL,
    [RoleId]     INT NOT NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED ([UserRoleID] ASC)
);

