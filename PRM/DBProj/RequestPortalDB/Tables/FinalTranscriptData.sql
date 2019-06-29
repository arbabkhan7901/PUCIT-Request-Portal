CREATE TABLE [dbo].[FinalTranscriptData] (
    [RequestID] INT           NOT NULL,
    [FYPtitle]  VARCHAR (100) NOT NULL,
    [PUreg]     VARCHAR (50)  NOT NULL,
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_FinalTranscriptData] PRIMARY KEY CLUSTERED ([ID] ASC)
);

