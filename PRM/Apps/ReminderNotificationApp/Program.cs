using ReminderNotificationHelper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReminderNotificationApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Boolean UseGmailSMTP = false;
            Boolean.TryParse(System.Configuration.ConfigurationManager.AppSettings["UseGmailSMTP"], out UseGmailSMTP);

            String FromAddress = System.Configuration.ConfigurationManager.AppSettings["FromAddress"];
            String FromDisplayName = System.Configuration.ConfigurationManager.AppSettings["FromDisplayName"];
            String SMTPServer = System.Configuration.ConfigurationManager.AppSettings["SMTPServer"];
            String SMTPPort = System.Configuration.ConfigurationManager.AppSettings["SMTPPort"];
            String SMTPUser = System.Configuration.ConfigurationManager.AppSettings["SMTPUser"];
            String SMTPPassword = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];

            if (UseGmailSMTP)
            {
                ReminderNotificationManager._emailhandler = new PUCIT.AIMRL.Common.GmailEmailHandler(
                    pSMTPHost: SMTPServer,
                    pPort: SMTPPort,
                    pUserLogin: SMTPUser,
                    pPassword: SMTPPassword,
                    pFromEmailAddress: FromAddress,
                    pFromDisplayName: FromDisplayName
                );
            }
            //else
            //{
            //    ReminderNotificationManager._emailhandler = new PUCIT.AIMRL.Common.GoDaddyEmailHandler(
            //        pSMTPHost: SMTPServer,
            //        pPort: SMTPPort,
            //        pFromEmailAddress: FromAddress,
            //        pFromDisplayName: FromDisplayName
            //    );
            //}

            ReminderNotificationManager.CheckAndSendNotifications();
        }
    }
}
