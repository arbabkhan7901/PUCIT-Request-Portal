CREATE TABLE [dbo].[Attachments] (
    [AttachmentID]     INT           IDENTITY (1, 1) NOT NULL,
    [RequestID]        INT           NOT NULL,
    [AttachmentTypeID] INT           NOT NULL,
    [UploadDate]       DATETIME      NOT NULL,
    [IsActive]         INT           NULL,
    [FileName]         VARCHAR (200) NOT NULL,
    [Description]      VARCHAR (500) NULL,
    CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED ([AttachmentID] ASC)
);

