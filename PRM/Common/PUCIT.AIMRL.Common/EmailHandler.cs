using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace PUCIT.AIMRL.Common
{
    public interface IEmailHandler
    {
        String SMTPHost { get; set; }
        String Port { get; set; }
        String FromEmailAddress { get; set; }
        String FromDisplayName { get; set; }
        Boolean SendEmail(EmailMessageParam param);
    }

    public class GmailEmailHandler : IEmailHandler
    {
        public String SMTPHost { get; set; }
        public String Port { get; set; }
        public String FromEmailAddress { get; set; }
        public String FromDisplayName { get; set; }
        public String UserLogin { get; set; }
        public String Password { get; set; }

        public GmailEmailHandler(String pSMTPHost, String pPort, String pUserLogin, String pPassword, String pFromEmailAddress, String pFromDisplayName)
        {
            this.SMTPHost = pSMTPHost;
            this.Port = pPort;
            this.FromEmailAddress = pFromEmailAddress;
            this.FromDisplayName = pFromDisplayName;
            this.UserLogin = pUserLogin;
            this.Password = pPassword;
        }

        //public bool SendEmail(EmailMessageParam param)
        //{
        //    try
        //    {
        //        //String SMTPServer = System.Configuration.ConfigurationManager.AppSettings["SMTPServer"];
        //        //String SMTPPort = System.Configuration.ConfigurationManager.AppSettings["SMTPPort"];
        //        //String UserLogin = System.Configuration.ConfigurationManager.AppSettings["SMTPUser"];
        //        //String UserPassword = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];

        //        //String fromEmailAddress = System.Configuration.ConfigurationManager.AppSettings["FromAddress"];

        //        //String fromDisplayName = "Student Request Portal";

        //        MailAddress fromAddress = new MailAddress(this.FromEmailAddress, this.FromDisplayName);

        //        MailAddress toAddress = new MailAddress(param.ToIDs);

        //        System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient
        //        {
        //            Host = this.SMTPHost,
        //            Port = Convert.ToInt32(this.Port),
        //            EnableSsl = true,
        //            DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network,
        //            UseDefaultCredentials = true,
        //            Credentials = new NetworkCredential(this.UserLogin, this.Password)
        //        };

        //        using (var message = new MailMessage(fromAddress, toAddress)
        //        {
        //            Subject = param.Subject,
        //            Body = param.Body,
        //            IsBodyHtml = true
        //        })
        //        {
        //            smtp.Send(message);
        //        }
        //        return true;
        //    }
        //    catch (Exception ex)
        //    {
        //        return false;
        //    }
        //}

        public Boolean SendEmail(EmailMessageParam param)
        {
            try
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(this.FromEmailAddress, this.FromDisplayName);

                if (String.IsNullOrEmpty(param.ToIDs))
                {
                    param.ToIDs = "request.portal@pucit.edu.pk";
                }

                if (!String.IsNullOrEmpty(param.ToIDs))
                {
                    var tos = param.ToIDs.Split(";".ToCharArray());

                    foreach (var to in tos)
                    {
                        MailAddress toadd = new MailAddress(to);
                        mail.To.Add(toadd);
                    }
                }

                /* CC Email Ids */
                if (!String.IsNullOrEmpty(param.CCIds))
                {
                    var ids = param.CCIds.Split(";".ToCharArray());

                    foreach (var cc in ids)
                    {
                        MailAddress ccadd = new MailAddress(cc);
                        mail.CC.Add(ccadd);
                    }
                }
                /* BCC Email Ids */
                if (!String.IsNullOrEmpty(param.BCCIds))
                {
                    var ids = param.BCCIds.Split(";".ToCharArray());

                    foreach (var bcc in ids)
                    {
                        MailAddress bccadd = new MailAddress(bcc);
                        mail.Bcc.Add(bccadd);
                    }
                }

                if (param.AlternateView != null)
                    mail.AlternateViews.Add(param.AlternateView);
                else
                {
                    mail.Body = param.Body;
                }

                //Configure the address we are sending the mail from
                mail.Subject = param.Subject;
                mail.IsBodyHtml = param.IsBodyHTML;


                System.Net.Mail.SmtpClient client = new System.Net.Mail.SmtpClient
                {
                    Host = this.SMTPHost,
                    Port = Convert.ToInt32(this.Port),
                    EnableSsl = true,
                    DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = true,
                    Credentials = new NetworkCredential(this.UserLogin, this.Password)
                };

                client.Send(mail);//Send the msg
                //Task.Factory.StartNew(() =>
                //{
                //    client.Send(mail);//Send the msg
                //});

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

    }

    public class GoDaddyEmailHandler : IEmailHandler
    {
        public String SMTPHost { get; set; }
        public String Port { get; set; }
        public String FromEmailAddress { get; set; }
        public String FromDisplayName { get; set; }


        public GoDaddyEmailHandler(String pSMTPHost, String pPort, String pFromEmailAddress, String pFromDisplayName)
        {
            this.SMTPHost = pSMTPHost;
            this.Port = pPort;
            this.FromEmailAddress = pFromEmailAddress;
            this.FromDisplayName = pFromDisplayName;
        }

        public Boolean SendEmail(EmailMessageParam param)
        {
            try
            {
                //String SMTPServer = System.Configuration.ConfigurationManager.AppSettings["SMTPServer"];
                //String SMTPPort = System.Configuration.ConfigurationManager.AppSettings["SMTPPort"];
                //String UserLogin = System.Configuration.ConfigurationManager.AppSettings["SMTPUser"];
                //String UserPassword = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];

                //String fromEmailAddress = System.Configuration.ConfigurationManager.AppSettings["FromAddress"];

                //String fromDisplayName = "Student Request Portal";

                MailAddress fromAddress = new MailAddress(this.FromEmailAddress, this.FromDisplayName);

                MailAddress toAddress = new MailAddress(param.ToIDs);


                MailMessage msg = new MailMessage();
                //Add your email address to the recipients
                msg.To.Add(toAddress);

                //Configure the address we are sending the mail from
                msg.From = fromAddress;
                msg.Subject = param.Subject;
                msg.Body = param.Body;
                msg.IsBodyHtml = true;

                SmtpClient client = new SmtpClient();
                //client.Host = "relay-hosting.secureserver.net";
                //client.Port = 25;

                client.Host = this.SMTPHost;
                client.Port = Convert.ToInt32(this.Port);

                Task.Factory.StartNew(() =>
                {
                    //Send the msg
                    client.Send(msg);
                });

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }


        }

        //public Boolean SendEmail2(EmailMessageParam param)
        //{
        //    try
        //    {
        //        MailAddress fromAddress = new MailAddress(this.FromEmailAddress, this.FromDisplayName);
        //        MailMessage mail = new MailMessage();

        //        if (String.IsNullOrEmpty(param.ToIDs))
        //        {
        //            param.ToIDs = "request.portal@pucit.edu.pk";
        //        }

        //        if (!String.IsNullOrEmpty(param.ToIDs))
        //        {
        //            var tos = param.ToIDs.Split(";".ToCharArray());

        //            foreach (var to in tos)
        //            {
        //                MailAddress toadd = new MailAddress(to);
        //                mail.To.Add(toadd);
        //            }
        //        }

        //        /* CC Email Ids */
        //        if (!String.IsNullOrEmpty(param.CCIds))
        //        {
        //            var ids = param.CCIds.Split(";".ToCharArray());

        //            foreach (var cc in ids)
        //            {
        //                MailAddress ccadd = new MailAddress(cc);
        //                mail.CC.Add(ccadd);
        //            }
        //        }
        //        /* BCC Email Ids */
        //        if (!String.IsNullOrEmpty(param.BCCIds))
        //        {
        //            var ids = param.BCCIds.Split(";".ToCharArray());

        //            foreach (var bcc in ids)
        //            {
        //                MailAddress bccadd = new MailAddress(bcc);
        //                mail.Bcc.Add(bccadd);
        //            }
        //        }

        //        if(param.AlternateView != null)
        //            mail.AlternateViews.Add(param.AlternateView);
        //        else
        //        {
        //            mail.Body = param.Body;
        //        }

        //        //Configure the address we are sending the mail from
        //        mail.Subject = param.Subject;
        //        mail.IsBodyHtml = param.IsBodyHTML;

        //        SmtpClient client = new SmtpClient();
        //        //client.Host = "relay-hosting.secureserver.net";
        //        //client.Port = 25;

        //        client.Host = this.SMTPHost;
        //        client.Port = Convert.ToInt32(this.Port);

        //        Task.Factory.StartNew(() =>
        //        {
        //            //Send the msg
        //            client.Send(mail);
        //        });

        //        return true;
        //    }
        //    catch (Exception ex)
        //    {
        //        return false;
        //    }
        //}
    }

    /*
     public class EmailHandler
     {
         private String _SMTPHost;
         private String _defaultCCIds;
         private String _defaultBCCIds;

         public String SMTPHost
         {
             get
             {
                 return _SMTPHost;
             }
         }

         public EmailHandler(String pSMTPHost)
         {
             this._SMTPHost = pSMTPHost;
         }
         public EmailHandler(String pSMTPHost, String defaultCCIds, String defaultBCCIds)
         {
             this._SMTPHost = pSMTPHost;
             this._defaultCCIds = defaultCCIds;
             this._defaultBCCIds = defaultBCCIds;
         }
         public static Boolean SendEmail(String toEmailAddress, String subject, String body)
         {
             try
             {
                 String SMTPServer = System.Configuration.ConfigurationManager.AppSettings["SMTPServer"];
                 String SMTPPort = System.Configuration.ConfigurationManager.AppSettings["SMTPPort"];
                 String UserLogin = System.Configuration.ConfigurationManager.AppSettings["SMTPUser"];
                 String UserPassword = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];

                 String fromEmailAddress = System.Configuration.ConfigurationManager.AppSettings["FromAddress"];

                 String fromDisplayName = "Student Request Portal";
                 MailAddress fromAddress = new MailAddress(fromEmailAddress, fromDisplayName);

                 MailAddress toAddress = new MailAddress(toEmailAddress);

                 System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient
                 {
                     Host = SMTPServer,
                     Port = Convert.ToInt32(SMTPPort),
                     EnableSsl = true,
                     DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network,
                     UseDefaultCredentials = false,
                     Credentials = new NetworkCredential(UserLogin, UserPassword)
                 };

                 using (var message = new MailMessage(fromAddress, toAddress)
                 {
                     Subject = subject,
                     Body = body
                 })
                 {
                     smtp.Send(message);
                 }
                 return true;
             }
             catch (Exception ex)
             {
                 return false;
             }


         }

         public static Boolean SendEmail1(String toEmailAddress, String subject, String body)
         {
             try
             {
                 String SMTPServer = System.Configuration.ConfigurationManager.AppSettings["SMTPServer"];
                 String SMTPPort = System.Configuration.ConfigurationManager.AppSettings["SMTPPort"];
                 String UserLogin = System.Configuration.ConfigurationManager.AppSettings["SMTPUser"];
                 String UserPassword = System.Configuration.ConfigurationManager.AppSettings["SMTPPassword"];

                 String fromEmailAddress = System.Configuration.ConfigurationManager.AppSettings["FromAddress"];

                 String fromDisplayName = "Student Request Portal";
                 MailAddress fromAddress = new MailAddress(fromEmailAddress, fromDisplayName);

                 MailAddress toAddress = new MailAddress(toEmailAddress);


                 MailMessage msg = new MailMessage();
                 //Add your email address to the recipients
                 msg.To.Add(toAddress);

                 //Configure the address we are sending the mail from
                 //MailAddress address = new MailAddress("mr@abc.net");
                 //msg.From = address;
                 msg.From = fromAddress;
                 msg.Subject = subject;
                 msg.Body = body;

                 SmtpClient client = new SmtpClient();
                 client.Host = "relay-hosting.secureserver.net";
                 client.Port = 25;

                 //Send the msg
                 client.Send(msg);

                 //System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient
                 //{
                 //    Host = SMTPServer,
                 //    Port = Convert.ToInt32(SMTPPort),
                 //    EnableSsl = true,
                 //    DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network,
                 //    UseDefaultCredentials = false,
                 //    Credentials = new NetworkCredential(UserLogin, UserPassword)
                 //};

                 //using (var message = new MailMessage(fromAddress, toAddress)
                 //{
                 //    Subject = subject,
                 //    Body = body
                 //})
                 //{
                 //    smtp.Send(message);
                 //}
                 return true;
             }
             catch (Exception ex)
             {
                 return false;
             }


         }
     }

     */
    //public Boolean SendEmail(EmailMessageParam emailMessage)
    //    {
    //        try
    //        {
    //            if (emailMessage == null)
    //                throw new Exception("Message object can't be null");

    //            if (String.IsNullOrEmpty(emailMessage.ToIDs))
    //                throw new Exception("To IDs can't be empty");

    //            System.Net.Mail.MailMessage mail = new System.Net.Mail.MailMessage();

    //            mail.IsBodyHtml = emailMessage.IsBodyHTML;
    //            mail.Subject = emailMessage.Subject;

    //            mail.From = new MailAddress(emailMessage.FromID, emailMessage.FromName);

    //            var tos = emailMessage.ToIDs.Split(";".ToCharArray());

    //            foreach (var to in tos)
    //            {
    //                MailAddress toadd = new MailAddress(to);
    //                mail.To.Add(toadd);
    //            }

    //            /* CC Email Ids */
    //            if (!String.IsNullOrEmpty(emailMessage.CCIds))
    //            {
    //                var ids = emailMessage.CCIds.Split(";".ToCharArray());

    //                foreach (var cc in ids)
    //                {
    //                    MailAddress ccadd = new MailAddress(cc);
    //                    mail.CC.Add(ccadd);
    //                }
    //            }
    //            else if (!String.IsNullOrEmpty(this._defaultCCIds))
    //            {
    //                var ids = this._defaultCCIds.Split(";".ToCharArray());

    //                foreach (var cc in ids)
    //                {
    //                    MailAddress ccadd = new MailAddress(cc);
    //                    mail.CC.Add(ccadd);
    //                }
    //            }



    //            /* BCC Email Ids */
    //            if (!String.IsNullOrEmpty(emailMessage.BCCIds))
    //            {
    //                var ids = emailMessage.BCCIds.Split(";".ToCharArray());

    //                foreach (var bcc in ids)
    //                {
    //                    MailAddress bccadd = new MailAddress(bcc);
    //                    mail.Bcc.Add(bccadd);
    //                }
    //            }
    //            else if (!String.IsNullOrEmpty(this._defaultBCCIds))
    //            {
    //                var ids = this._defaultBCCIds.Split(";".ToCharArray());

    //                foreach (var bcc in ids)
    //                {
    //                    MailAddress bccadd = new MailAddress(bcc);
    //                    mail.Bcc.Add(bccadd);
    //                }
    //            }

    //            if (emailMessage.AlternateView != null)
    //                mail.AlternateViews.Add(emailMessage.AlternateView);


    //            if (emailMessage.Attachments != null)
    //            {
    //                foreach (var atch in emailMessage.Attachments)
    //                {
    //                    mail.Attachments.Add(atch);
    //                }
    //            }

    //            SmtpClient sc = new SmtpClient(this.SMTPHost);
    //            sc.Send(mail);
    //        }
    //        catch (Exception ex)
    //        {
    //            throw new Exception("PUCIT.AIMRL.Common.SendEmail()", ex);
    //        }

    //        return true;
    //    }


    //    /*
    //    To display images in an email, images are embeded as 'LinkedResource'
    //    First parameter of dictionary is 'ImagePath' & Second Parameter is tag string where resource will be replaced
    //     */
    //    public static List<LinkedResource> GetLinkedResourcesForImages(ref String pBodyHtml, Dictionary<String, String> imagePaths_Tags)
    //    {
    //        List<LinkedResource> linkedResources = new List<LinkedResource>();
    //        foreach (var item in imagePaths_Tags)
    //        {
    //            var uniqueId = Guid.NewGuid().ToString();
    //            LinkedResource logo = new LinkedResource(item.Value);
    //            logo.ContentId = uniqueId;

    //            pBodyHtml = pBodyHtml.Replace(item.Key, "cid:" + uniqueId);

    //            linkedResources.Add(logo);
    //        }

    //        return linkedResources;
    //    }

    //    public static AlternateView GetLogoAlternateView(String pBodyHtml, List<LinkedResource> linkedResources)
    //    {

    //        AlternateView av1 = AlternateView.CreateAlternateViewFromString(pBodyHtml, null, MediaTypeNames.Text.Html);
    //        foreach (var rsrc in linkedResources)
    //        {
    //            av1.LinkedResources.Add(rsrc);
    //        }
    //        return av1;

    //    }

    // }

    public class EmailMessageParam
    {
        public String FromID { get; set; }
        public String FromName { get; set; }
        public String ToIDs { get; set; }
        public String Subject { get; set; }

        public String Body { get; set; }

        public String CCIds { get; set; }

        public String BCCIds { get; set; }

        public List<Attachment> Attachments { get; set; }

        public Boolean IsBodyHTML { get; set; }

        public AlternateView AlternateView { get; set; }

        public EmailMessageParam()
        {
            this.IsBodyHTML = false;
        }

    }
}
