CREATE TABLE [dbo].[LeaveApplicationForm] (
    [RequestID] INT      NOT NULL,
    [startDate] DATETIME NOT NULL,
    [endDate]   DATETIME NOT NULL,
    [ID]        INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_LeaveApplicationForm] PRIMARY KEY CLUSTERED ([ID] ASC)
);

