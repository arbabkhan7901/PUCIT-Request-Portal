CREATE TABLE [dbo].[LoginHistory] (
    [LoginHistoryID] BIGINT       IDENTITY (1, 1) NOT NULL,
    [UserID]         INT          NOT NULL,
    [LoginID]        VARCHAR (50) NOT NULL,
    [MachineIP]      VARCHAR (20) NOT NULL,
    [LoginTime]      DATETIME     NOT NULL,
    [LoginType]      VARCHAR (20) NULL,
    CONSTRAINT [PK_LoginHistory] PRIMARY KEY CLUSTERED ([LoginHistoryID] ASC)
);

