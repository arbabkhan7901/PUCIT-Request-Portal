CREATE TABLE [dbo].[ContactUs] (
    [ID]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (100) NULL,
    [Email]       VARCHAR (100) NULL,
    [MachineIP]   VARCHAR (20)  NULL,
    [Description] VARCHAR (500) NULL,
    [EntryTime]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

