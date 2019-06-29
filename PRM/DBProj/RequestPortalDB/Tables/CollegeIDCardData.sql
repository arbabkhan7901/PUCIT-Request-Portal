CREATE TABLE [dbo].[CollegeIDCardData] (
    [RequestID]   INT          NOT NULL,
    [serialNo]    INT          NULL,
    [issueDate]   DATETIME     NULL,
    [ExpiryDate]  DATETIME     NULL,
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [ChallanForm] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CollegeIDCardData] PRIMARY KEY CLUSTERED ([ID] ASC)
);

