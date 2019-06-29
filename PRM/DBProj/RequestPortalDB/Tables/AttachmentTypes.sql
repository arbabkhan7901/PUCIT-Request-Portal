CREATE TABLE [dbo].[AttachmentTypes] (
    [AttachmentTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [typeName]         VARCHAR (50) NOT NULL,
    [description]      TEXT         NULL,
    CONSTRAINT [PK_AttachmentTypes] PRIMARY KEY CLUSTERED ([AttachmentTypeID] ASC)
);

