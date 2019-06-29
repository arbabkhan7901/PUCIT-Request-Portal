using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PUCIT.PRM.TaskManagement
{
    public class ScheduleHandler
    {
        public static void LoadAndProcess()
        {
            var list = new List<long>();
            PRMDataService dataService = new PRMDataService();
            var emails = dataService.GetEmailRequestsForProcessing();
            foreach (var email in emails)
            {
                GlobalDataManager._emailhandler.SendEmail(new EmailMessageParam()
                {
                    ToIDs = email.EmailTo,
                    Subject = email.Subject,
                    Body = email.MessageBody
                });
                //EmailHandler.SendEmail(email.EmailTo, email.Subject, email.MessageBody);
                list.Add(email.EmailRequestID);
            }

            dataService.ProcessEmailRequests(list);
        }

    }
}
