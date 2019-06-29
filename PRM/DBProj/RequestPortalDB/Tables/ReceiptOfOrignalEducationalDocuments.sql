CREATE TABLE [dbo].[ReceiptOfOrignalEducationalDocuments] (
    [RequestID]    INT           NOT NULL,
    [DocumentName] VARCHAR (100) NOT NULL,
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_ReceiptOfOrignalEducationalDocuments] PRIMARY KEY CLUSTERED ([ID] ASC)
);

