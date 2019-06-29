CREATE TABLE [dbo].[ForgotPasswordLog] (
    [ID]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [Login]     VARCHAR (100) NULL,
    [Token]     VARCHAR (100) NULL,
    [IPAddress] VARCHAR (20)  NULL,
    [Found]     BIT           NULL,
    [URL]       VARCHAR (100) NULL,
    [EntyDate]  DATETIME      NULL,
    [IsUsed]    BIT           NULL,
    [UpdatedOn] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

