using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace ReminderNotificationHelper
{
    public class ReminderNotificationManager
    {
        public static PUCIT.AIMRL.Common.IEmailHandler _emailhandler;
        public static void CheckAndSendNotifications()
        {
            PRMDataService dataService = new PRMDataService();
            List<CustomApplicationStatusReport> pStatusData = new List<CustomApplicationStatusReport>();
            try
            {
                AppStatusesSearchParam param = new AppStatusesSearchParam()
                {
                    IsApprover = 1,
                    Login = "",
                    Status = 0,
                    SDate = DateTime.Now.AddYears(-5),
                    EDate = DateTime.Now.AddYears(10),
                };
                pStatusData = dataService.SearchApplicationStatuses(param);

                //SendNotificationIfSupDidnotRespond(list);
            }
            catch (Exception ex)
            {
            }


            try
            {
                var notifications = dataService.GetPendingRequestsForNotifications();
                SendNotificationForPendingRequests(pStatusData,notifications);
            }
            catch (Exception ex)
            {
            }
        }

        public static Boolean SendNotificationIfSupDidnotRespond(List<CustomApplicationStatusReport> pData)
        {
            String subjectPrefix = System.Configuration.ConfigurationManager.AppSettings["EmailSubjectPrefix"];

            String emailSubject = subjectPrefix + " Daily Status Wise Report - " + DateTime.Now.ToString("dd/MM/yyyy hh:mm tt");

            String pagePath = WinUtility.GetPhysicalPathByRelativePath(@"Email_Templates\NotifyIfNotResponded.html");
            String logoPath = WinUtility.GetPhysicalPathByRelativePath(@"Email_Templates\pucit_logo.png");
            String baseMailTemp = System.IO.File.ReadAllText(pagePath);
            var appPath = System.Configuration.ConfigurationManager.AppSettings["AppPath"];

            String mailTemp = "";

            var uniqueEmails = pData.Select(p => p.Email).Distinct().ToList();

            foreach (var email in uniqueEmails)
            {
                var requestForAUser = pData.Where(p => p.Email == email).ToList();
                String tBodyContent = "";
                mailTemp = baseMailTemp;
                mailTemp = mailTemp.Replace("TAG_RECIPIENTNAME", requestForAUser[0].Name);

                foreach (var request in requestForAUser)
                {
                    tBodyContent += String.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td></tr>",
                        request.Title,
                        request.All,
                        request.Pending,
                        request.Accepted,
                        request.Rejected,
                        request.NotAssigned);
                }

                mailTemp = mailTemp.Replace("TAG_BODY", tBodyContent);

                List<LinkedResource> listRsrcs = new List<LinkedResource>();
                var r2 = EmailTemplateManager.GetLinkedResource(ref mailTemp, logoPath, "LOGO_PATH");
                listRsrcs.Add(r2);

                AlternateView av = EmailTemplateManager.GetLogoAlternateView(mailTemp, listRsrcs);

                var cc = System.Configuration.ConfigurationManager.AppSettings["CCID"];
                var bcc = System.Configuration.ConfigurationManager.AppSettings["BCCID"];

                _emailhandler.SendEmail(new EmailMessageParam()
                {
                    Subject = emailSubject,
                    ToIDs = email,
                    CCIds = cc,
                    BCCIds = bcc,
                    AlternateView = av,
                    IsBodyHTML = true
                });
            }

            return true;
        }

        public static Boolean SendNotificationForPendingRequests(List<CustomApplicationStatusReport> pDataStatus, List<PendingRequestsForNotification> pData)
        {
            String subjectPrefix = System.Configuration.ConfigurationManager.AppSettings["EmailSubjectPrefix"];

            String emailSubject = subjectPrefix + " Pending Requests Report - " + DateTime.Now.ToString("dd/MM/yyyy hh:mm tt");

            String pagePath = WinUtility.GetPhysicalPathByRelativePath(@"Email_Templates\NotifyForPendingRequests.html");
            //String logoPath = WinUtility.GetPhysicalPathByRelativePath(@"Email_Templates\pucit_logo.png");
            String baseMailTemp = System.IO.File.ReadAllText(pagePath);
            var appPath = System.Configuration.ConfigurationManager.AppSettings["AppPath"];

            String mailTemp = "";
            var uniqueEmails = pData.Select(p => p.Email).Distinct().ToList();

            foreach (var email in uniqueEmails)
            {

                String tBodyContent = "";
                mailTemp = baseMailTemp;

                var pendingRequestForAUser = pData.Where(p => p.Email == email).ToList();
                var dailStatusForAUser = pDataStatus.Where(p => p.Email == email).ToList();
                
                mailTemp = mailTemp.Replace("TAG_RECIPIENTNAME", dailStatusForAUser[0].Name);
                foreach (var request in dailStatusForAUser)
                {
                    tBodyContent += String.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td></tr>",
                        request.Title,
                        request.All,
                        request.Pending,
                        request.Accepted,
                        request.Rejected,
                        request.NotAssigned);
                }

                mailTemp = mailTemp.Replace("TAG_STATUS_BODY", tBodyContent);

                tBodyContent = "";
                
                foreach (var record in pendingRequestForAUser)
                {
                    var reqUrl = String.Format("{0}/Home/ApplicationView/{1}", appPath, record.RequestID);
                    var diaryNo = String.Format("Acad/{0}", record.RequestID);
                    tBodyContent += String.Format(@"
                        <tr>
                        <td>{0}</td>
                        <td>{1}</td>
                        <td><a href='{5}'>{2}</a></td>
                        <td>{3}</td>
                        <td>{4}</td>
                        </tr>",
                        record.Designation,
                        record.PendingDays,
                        diaryNo,
                        record.RollNo,
                        record.Category,
                        reqUrl);
                }

                mailTemp = mailTemp.Replace("TAG_PENDING_BODY", tBodyContent);

                List<LinkedResource> listRsrcs = new List<LinkedResource>();
                //var r2 = EmailTemplateManager.GetLinkedResource(ref mailTemp, logoPath, "LOGO_PATH");
                //listRsrcs.Add(r2);

                AlternateView av = EmailTemplateManager.GetLogoAlternateView(mailTemp, listRsrcs);

                var cc = System.Configuration.ConfigurationManager.AppSettings["PendingRequestsCCId"];
                var bcc = System.Configuration.ConfigurationManager.AppSettings["BCCID"];

                _emailhandler.SendEmail(new EmailMessageParam()
                {
                    Subject = emailSubject,
                    ToIDs = email,
                    CCIds = cc,
                    BCCIds = bcc,
                    AlternateView = av,
                    IsBodyHTML = true
                });
            }


            return true;
        }
    }
}
