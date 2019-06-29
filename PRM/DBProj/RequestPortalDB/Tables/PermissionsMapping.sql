CREATE TABLE [dbo].[PermissionsMapping] (
    [Id]           INT IDENTITY (1, 1) NOT NULL,
    [RoleId]       INT NOT NULL,
    [PermissionId] INT NOT NULL,
    CONSTRAINT [PK_PermissionsMapping] PRIMARY KEY CLUSTERED ([Id] ASC)
);

