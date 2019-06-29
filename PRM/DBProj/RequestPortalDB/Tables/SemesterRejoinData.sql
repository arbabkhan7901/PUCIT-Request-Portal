CREATE TABLE [dbo].[SemesterRejoinData] (
    [RequestID]             INT          NOT NULL,
    [withDrawApplicationNo] VARCHAR (50) NOT NULL,
    [ID]                    INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_SemesterRejoinData] PRIMARY KEY CLUSTERED ([ID] ASC)
);

