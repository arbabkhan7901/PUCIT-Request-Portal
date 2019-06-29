using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.Common.Logger;
using PUCIT.AIMRL.IMS.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities.Enum;
using PUCIT.AIMRL.PRM.Entities.Security;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;

namespace PUCIT.AIMRL.PRM.DAL
{
    public class PRMDataService
    {
        public static TimeZoneInfo tzi = TimeZoneInfo.FindSystemTimeZoneById("Pakistan Standard Time");

        #region Stored Procedures

        private const String SP_DBO_SAVESTUDENT = "dbo.SaveStudent";
        private const String SP_DBO_DEACTIVATESTUDENT = "[dbo].[DeactivateStudent]";
        private const String SP_DBO_SEARCHSTUDENTS = "dbo.SearchStudents";

        private const String SP_DBO_GETAPPROVERHERIRACHYS = "dbo.GetApproverHerirachy";


        #endregion

        public PRMDataService()
        {
            Database.SetInitializer<PRMDataContext>(null);
        }

        /* ------------------------Save/Update Approaches-------------------------- */
        public DateTime ConvertfromUTC(DateTime d)
        {
            return d.ToTimeZoneTime(tzi);
        }
        public int SaveSampleStudentLINQ(SampleStudent pStudent, String pModifier, DateTime pModifiedOn)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var studentToUpdate = new SampleStudent();

                    if (pStudent.StudentId > 0)
                    {
                        pStudent.ModifiedBy = pModifier;
                        pStudent.ModifiedOn = pModifiedOn;

                        db.SampleStudents.Attach(pStudent);
                        var entry = db.Entry(pStudent);
                        entry.Property(e => e.FirstName).IsModified = true;
                        entry.Property(e => e.LastName).IsModified = true;
                        entry.Property(e => e.ModifiedBy).IsModified = true;
                        entry.Property(e => e.ModifiedOn).IsModified = true;

                        /* ----------------------Other approach to update a record --------------------------*/
                        /*studentToUpdate = db.SampleStudents.Where(s => s.StudentId.Equals(pStudent.StudentId)).FirstOrDefault();

                        if (studentToUpdate != null)
                        {
                            studentToUpdate.FirstName = pStudent.FirstName;
                            studentToUpdate.LastName = pStudent.LastName;
                            studentToUpdate.DateOfBirth = pStudent.DateOfBirth;
                            studentToUpdate.Gender = pStudent.Gender;
                            studentToUpdate.Education = pStudent.Education;
                            studentToUpdate.ModifiedBy = pModifier;
                            studentToUpdate.ModifiedOn = pModifiedOn;
                            studentToUpdate.IsActive = pStudent.IsActive;
                        }
                         
                         */
                    }
                    else
                    {
                        pStudent.IsActive = true;
                        pStudent.CreatedBy = pModifier;
                        pStudent.CreatedOn = pModifiedOn;

                        db.SampleStudents.Add(pStudent);

                    }

                    db.SaveChanges();
                }
                return pStudent.StudentId;
            }
            catch (Exception ex)
            {
                //LogHandler.WriteLog(SessionManager.CurrentUser.Login, ex.Message, Common.Logger.LogType.ErrorMsg, ex);
                throw;
            }
        }




        public bool DeactivateSampleStudentSP(int pStudentId, string pModifiedBy, DateTime pModifiedOn)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var query = String.Format("Execute {0} '{1}','{2}','{3}'", SP_DBO_DEACTIVATESTUDENT, pStudentId, pModifiedBy, pModifiedOn);
                    db.Database.SqlQuery<Int32>(query).FirstOrDefault();
                    return true;
                }
            }
            catch (Exception ex)
            {
                LogHandler.WriteLog("loggedinuserloginid", ex.Message, PUCIT.AIMRL.Common.Logger.LogType.ErrorMsg, ex);
                throw;
            }
        }

        public List<SampleStudent> SearchSampleStudents(Int32? pStudentId, string pFirstName, string pLastName, DateTime? pDateOfBirth)
        {
            using (var db = new PRMDataContext())
            {
                var query = (from stu in db.SampleStudents
                             select
                                 stu).Distinct();

                if (pStudentId.HasValue)
                {
                    query = query.Where(p => p.StudentId == pStudentId);
                }

                if (!String.IsNullOrWhiteSpace(pFirstName))
                {
                    query = query.Where(p => p.FirstName == pFirstName);
                }

                if (!String.IsNullOrWhiteSpace(pLastName))
                {
                    query = query.Where(p => p.LastName == pLastName);
                }

                if (pDateOfBirth.HasValue)
                {
                    query = query.Where(p => p.DateOfBirth == pDateOfBirth);
                }

                return query.ToList();
            }
        }

        public List<SampleStudent> SearchSampleStudentsForAuto(String prefixText)
        {
            using (var db = new PRMDataContext())
            {
                var result = (from stu in db.SampleStudents
                              where stu.FirstName.Contains(prefixText) || stu.LastName.Contains(prefixText)
                              select stu).ToList();



                return result;
            }
        }

        /*------------------- Search Approaches------------------------------*/


        public List<CustomAttachments> GetAttachment(int RequestID, String reqUniqueId)
        {
            List<CustomAttachments> Attach = new List<CustomAttachments>();
            CustomAttachments tempAttach = new CustomAttachments();
            using (var db = new PRMDataContext())
            {
                var query = from rmd in db.RequestMainData
                            join attach in db.Attachments on rmd.RequestID equals attach.RequestID
                            where rmd.ReqUniqueId == reqUniqueId && attach.IsActive == 1 && attach.RequestID == RequestID
                            select new { attach.FileName,attach.AttachmentTypeID,attach.Description, attach.UploadDate,attach.IsActive, rmd.RequestID,rmd.ReqUniqueId}; 
                
//                var query = db.Attachments.Where(x => (x.RequestID == RequestID) && x.IsActive == 1);
                foreach (var p in query)
                {
                    tempAttach = new CustomAttachments();
                    tempAttach.attachment.FileName = p.FileName;
                    tempAttach.attachment.AttachmentTypeID = p.AttachmentTypeID;
                    tempAttach.attachment.Description = p.Description;
                    tempAttach.attachment.UploadDate = p.UploadDate;
                    tempAttach.attachment.IsActive = p.IsActive;
                    tempAttach.type = getType(p.AttachmentTypeID);

                    Attach.Add(tempAttach);
                }
            }
            return Attach;
        }
        public AttachmentTypes getType(int typeID)
        {
            using (var db = new PRMDataContext())
            {
                return db.AttachmentTypes.Where(x => (x.AttachmentTypeID == typeID)).First();
            }
        }
        public List<FormCategories> getInstructions()
        {
            using (var db = new PRMDataContext())
            {
                return db.FormCategories.ToList();
            }

        }

        public List<string> getDocuments(int RequestId)
        {
            List<string> docs = new List<string>();
            using (var db = new PRMDataContext())
            {
                var query = db.ReceiptOfOrignalEducationalDocuments.Where(x => x.RequestID == RequestId).Select(x => x.DocumentName);
                foreach (string q in query)
                {
                    docs.Add(q);
                }

                return docs;
            }
        }

        //public int changePassword(PasswordEntity pass)
        //{
        //    var username = SessionManager.GetUserLogin();

        //    using (var db = new PRMDataContext())
        //    {
        //        var query = db.Users.Where(x => (x.Login == username) && (x.Password == pass.CurrentPassword)).FirstOrDefault();

        //        if (query != null)
        //        {
        //            query.Password = pass.NewPassword;

        //            db.SaveChanges();
        //            return 1;

        //        }
        //        else return 0;

        //    }
        //}

        public Boolean UpdatePassword(String emailAddress_login, String currentPassword, String Newpassword, int pModifiedBy, DateTime pModifiedOn, Boolean IsChangePassword)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var query = String.Format("Execute dbo.UpdatePassword '{0}','{1}','{2}','{3}','{4}','{5}'", emailAddress_login, currentPassword, Newpassword, pModifiedOn, pModifiedBy, IsChangePassword);
                    var result = db.Database.SqlQuery<Boolean>(query).FirstOrDefault();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
        public String UpdateResetToken(String emailAddress_login, String pGuid, String pIPAddress, DateTime pCurrTime, string pUrl)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var query = String.Format("Execute dbo.UpdateResetPasswordToken '{0}','{1}','{2}','{3}','{4}'", emailAddress_login, pGuid, pIPAddress, pCurrTime, pUrl);
                    var result = db.Database.SqlQuery<String>(query).FirstOrDefault();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
        public Boolean IsValidResetToken(String pReset_Token)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var query = String.Format("Execute dbo.IsValidResetToken '{0}'", pReset_Token);
                    var result = db.Database.SqlQuery<Boolean>(query).FirstOrDefault();
                    return result;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public int SaveApplicationRequest(RequestMainData reqData)
        {
            if (reqData.Reason == null)
                reqData.Reason = "";
            if (reqData.Subject == null)
                reqData.Subject = "";

            if (reqData.CurrentSemester == null)
                reqData.CurrentSemester = 0;

            using (var ctx = new PRMDataContext())
            {
                String ReqUniqueId = Guid.NewGuid().ToString();
                String guid = Guid.NewGuid().ToString();


                string query = "execute dbo.SaveRequest @0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12";

                var args = new DbParameter[] {
                        new SqlParameter { ParameterName = "@0", Value = reqData.RequestID },
                        new SqlParameter { ParameterName = "@1", Value = reqData.CategoryID },
                        new SqlParameter { ParameterName = "@2", Value = reqData.UserId },
                        new SqlParameter { ParameterName = "@3", Value = reqData.RollNo },
                        new SqlParameter { ParameterName = "@4", Value = reqData.CreationDate.YYYYMMDD() },
                        new SqlParameter { ParameterName = "@5", Value =  reqData.TargetSemester },
                        new SqlParameter { ParameterName = "@6", Value = reqData.Reason  },
                        new SqlParameter { ParameterName = "@7", Value = reqData.TargetDate.Value.YYYYMMDD() },
                        new SqlParameter { ParameterName = "@8", Value = reqData.CurrentSemester },
                        new SqlParameter { ParameterName = "@9", Value = reqData.RequestStatus },
                        new SqlParameter { ParameterName = "@10", Value = reqData.Subject },
                        new SqlParameter { ParameterName = "@11", Value = guid },
                        new SqlParameter { ParameterName = "@12", Value = ReqUniqueId}

                };

                var requestId = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails

                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);
                FillEmailTemplatesAndProcess(emailRequests);
                return requestId;

            }

        }

        public void FillEmailTemplatesAndProcess(List<EmailRequest> emailRequests)
        {
            try {

                foreach (var email in emailRequests)
                {
                    String app_url = "";
                    if (email.RequestID == 0)
                    {
                        app_url = PUCIT.AIMRL.PRM.UI.Common.Resources.GetCompletePath("~");
                    }
                    else
                    {
                        app_url = PUCIT.AIMRL.PRM.UI.Common.Resources.GetCompletePath("~/Home/ApplicationView/") + email.RequestID;
                    }

                    if (email.RequestID >= 0 )
                    {
                        // FillEmailTemplates(email);
                        String mailTemp = "";
                        if (email.EmailTemplate == null)
                        {
                            int i = 0;
                        }
                        else
                        {
                            String pagePath = WebUtility.GetPhysicalPathByVirtualPath("~/EmailTemplates/" + email.EmailTemplate + ".html");
                            String baseMailTemp = System.IO.File.ReadAllText(pagePath);
                            mailTemp = baseMailTemp;

                            Dictionary<String, String> emailDetails = email.EmailDetails.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                .Select(x => x.Split(':')).ToDictionary(x => x[0], y => y[1]);

                            foreach (var eDetail in emailDetails)
                            {
                                if (eDetail.Key == "TAG_URL")
                                {
                                    mailTemp = mailTemp.Replace(eDetail.Key, app_url);
                                }
                                mailTemp = mailTemp.Replace(eDetail.Key, eDetail.Value);
                            }
                            List<System.Net.Mail.LinkedResource> linkedResources = new List<System.Net.Mail.LinkedResource>();
                            System.Net.Mail.AlternateView av = EmailTemplateManager.GetLogoAlternateView(mailTemp, linkedResources);
                            email.av = av;
                        }


                    }
                }
                ProcessEmails(emailRequests);
            }
            catch (Exception ex) {
                throw;
            }
        }


        public object UploadSignature(int userId, string attachment)
        {
            using (var ctx = new PRMDataContext())
            {
                var dto = new User() { UserId = userId, SignatureName = attachment };
                ctx.Users.Attach(dto);
                var entry = ctx.Entry(dto);
                entry.State = EntityState.Unchanged;
                entry.Property(e => e.SignatureName).IsModified = true;

                ctx.SaveChanges();
                return 1;

            }
        }

        public int SaveWithDraw(customCourseWithdraw course)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(course.request);
                for (int i = 0; i < course.course.Count; i++)
                {
                    course.course[i].RequestID = requestId;
                    db.CourseWithdrawalData.Add(course.course[i]);

                }
                db.SaveChanges();

                String guid = Guid.NewGuid().ToString();
                string query = "execute dbo.AddContributorInWithDraw @0, @1";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = guid }
                };
                var data = db.Database.ExecuteSqlCommand(query, args);
                var emailRequests = GetEmailRequestsByUniqueID(db, guid);
                FillEmailTemplatesAndProcess(emailRequests);
                
                return requestId;

            }

            //Save in Requestflow table

            //List<ApproverHierarchy> approver = getApprovers(reqData.CategoryID);

            //ReqWorkflow requestworkflow = new ReqWorkflow();
            //requestworkflow.RequestID = reqData.RequestID;
            //requestworkflow.EntryTime = reqData.Date;
            //insertDefaultWorkflow(requestworkflow, approver);
            //return 1;


        }

        public int SaveLeaveForm(CustomLeaveApplication leaveData)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(leaveData.request);

                leaveData.leave.RequestID = requestId;
                db.LeaveApplicationForm.Add(leaveData.leave);
                db.SaveChanges();

                return requestId;

            }
        }
        public int Savegeneral(customGeneralRequest general)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var requestId = SaveApplicationRequest(general.request);
                    //db.RequestMainData.Add(general.request);
                    //db.SaveChanges();

                    //request ID

                    general.attach2.RequestID = requestId;
                    if (general.attach1.FileName != null)
                    {
                        db.AttachmentTypes.Add(general.type1);
                        db.SaveChanges();
                        general.attach1.RequestID = requestId;
                        general.attach1.AttachmentTypeID = general.type1.AttachmentTypeID;
                        general.attach1.IsActive = 1;
                        db.Attachments.Add(general.attach1);
                    }
                    if (general.attach2.FileName != null)
                    {
                        db.AttachmentTypes.Add(general.type2);
                        db.SaveChanges();
                        general.attach2.RequestID = requestId;
                        general.attach2.AttachmentTypeID = general.type2.AttachmentTypeID;
                        general.attach2.IsActive = 1;

                        db.Attachments.Add(general.attach2);

                    }
                    db.SaveChanges();

                    return requestId;

                }
            }
            catch (Exception e)
            {
                throw;
            }
        }
        public int SaveBScForm(CustomBscApplication Bsc)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(Bsc.request);

                //db.RequestMainData.Add(Bsc.request);
                //db.SaveChanges();

                //request ID
                Bsc.bsc.RequestID = requestId;
                Bsc.AppLicantCNIC.RequestID = requestId;
                Bsc.AppLicantCNIC.IsActive = 1;

                Bsc.FatherCNIC.RequestID = requestId;
                Bsc.FatherCNIC.IsActive = 1;

                db.OptionForBscDegree.Add(Bsc.bsc);

                db.Attachments.Add(Bsc.AppLicantCNIC);
                db.Attachments.Add(Bsc.FatherCNIC);
                db.SaveChanges();

                //createApplicationActivity(requestId);

                //GetApprovers of form.
                //List<ApproverHierarchy> approver = getApprovers(Bsc.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = Bsc.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new OPTION FOR BSc DEGREE APPLICATION From Roll no: " + Bsc.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your OPTION FOR BSc DEGREE APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(Bsc.request.RollNo, subject, Msg);

                return requestId;

            }
        }
        public int SaveVehicalTokenForm(CustomVehicalTokenData vehical)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(vehical.request);

                //db.RequestMainData.Add(vehical.request);
                //db.SaveChanges();

                //request ID
                vehical.vehical.RequestID = requestId;

                vehical.Photo.RequestID = requestId;
                vehical.Photo.IsActive = 1;

                vehical.IDCard.RequestID = requestId;
                vehical.IDCard.IsActive = 1;

                vehical.Registration.RequestID = requestId;
                vehical.Registration.IsActive = 1;


                db.VehicalTokenData.Add(vehical.vehical);

                db.Attachments.Add(vehical.Photo);
                db.Attachments.Add(vehical.IDCard);
                db.Attachments.Add(vehical.Registration);

                db.SaveChanges();

                //createApplicationActivity(requestId);

                //GetApprovers of form.
                //List<ApproverHierarchy> approver = getApprovers(vehical.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = vehical.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new MOTOR CYCLE TOKEN APPLICATION From Roll no: " + vehical.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your MOTOR CYCLE TOKEN APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(vehical.request.RollNo, subject, Msg);


                return requestId;
            }
        }
        public int receiptOfOriginal(customReceiptOfOrignalDocument doc)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(doc.request);

                //db.RequestMainData.Add(doc.request);
                //db.SaveChanges();

                //request ID
                doc.IDCard.RequestID = requestId;
                for (int i = 0; i < doc.documents.Count; i++)
                {
                    doc.documents[i].RequestID = requestId;
                    db.ReceiptOfOrignalEducationalDocuments.Add(doc.documents[i]);
                }

                doc.IDCard.IsActive = 1;
                db.Attachments.Add(doc.IDCard);
                if (doc.ClearanceForm != null) {
                    doc.ClearanceForm.RequestID = requestId;
                    doc.ClearanceForm.IsActive = 1;
                    db.Attachments.Add(doc.ClearanceForm);
                }
                db.SaveChanges();

                //createApplicationActivity(requestId);

                //GetApprovers of form.
                //List<ApproverHierarchy> approver = getApprovers(doc.request.CategoryID);
                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = doc.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new RECEIPT OF ORIGINAL EDUCATIONAL DOCUMENT APPLICATION From Roll no: " + doc.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your RECEIPT OF ORIGINAL EDUCATIONAL DOCUMENT APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(doc.request.RollNo, subject, Msg);


                return requestId;
            }
        }
        public int SaveFinalAcadTrans(CustomFinalAcad final)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(final.request);

                //db.RequestMainData.Add(final.request);
                //db.SaveChanges();

                //request ID
                final.finalTranscript.RequestID = requestId;
                final.ClearanceFrom.RequestID = requestId;
                db.FinalTranscriptData.Add(final.finalTranscript);

                final.ClearanceFrom.IsActive = 1;
                db.Attachments.Add(final.ClearanceFrom);
                db.SaveChanges();

                //createApplicationActivity(requestId);

                //GetApprovers of form.
                //List<ApproverHierarchy> approver = getApprovers(final.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = final.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new FINAL ACADEMIC TRANSCRIPT APPLICATION From Roll no: " + final.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your FINAL ACADEMIC TRANSCRIPT APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(final.request.RollNo, subject, Msg);


                return requestId;
            }

        }
        public int SaveBonafideForm(customBonafide certificate)
        {
            try
            {
                using (var db = new PRMDataContext())
                {
                    var requestId = SaveApplicationRequest(certificate.request);

                    //db.RequestMainData.Add(certificate.request);
                    //db.SaveChanges();

                    //createApplicationActivity(requestId);

                    //request ID
                    certificate.bonafide.RequestID = requestId;
                    db.BonafideCertificateData.Add(certificate.bonafide);
                    db.SaveChanges();

                    if (!String.IsNullOrEmpty(certificate.challan.FileName))
                    {
                        certificate.challan.RequestID = requestId;
                        certificate.challan.IsActive = 1;
                        db.Attachments.Add(certificate.challan);
                        db.SaveChanges();
                    }

                    //List<ApproverHierarchy> approver = getApprovers(certificate.request.CategoryID);

                    //ReqWorkflow requestworkflow = new ReqWorkflow();
                    //requestworkflow.RequestID = requestId;
                    //requestworkflow.EntryTime = certificate.request.CreationDate;
                    //insertDefaultWorkflow(requestworkflow, approver);

                    return requestId;
                }
            }
            catch (Exception e)
            {
                throw;
            }
        }
        public int SaveSemesterAcadTranscriptForm(customSemesterAcademic transcript)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(transcript.request);

                //db.RequestMainData.Add(transcript.request);
                //db.SaveChanges();

                //request ID
                transcript.semesterAcad.RequestID = requestId;
                transcript.challan.RequestID = requestId;
                db.SemesterAcademicTranscript.Add(transcript.semesterAcad);
                db.SaveChanges();

                transcript.challan.IsActive = 1;
                db.Attachments.Add(transcript.challan);
                db.SaveChanges();

                //createApplicationActivity(requestId);

                //List<ApproverHierarchy> approver = getApprovers(transcript.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = transcript.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);

                return requestId;
            }
        }

        public int SaveClearanceForm(CustomClearanceForm clearance)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(clearance.request);

                //db.RequestMainData.Add(ID.request);
                //db.SaveChanges();

                //request ID
                clearance.Photograph.RequestID = requestId;
                //db.SaveChanges();

                clearance.Photograph.IsActive = 1;
                db.Attachments.Add(clearance.Photograph);
                db.SaveChanges();


                clearance.clearanceFormData.RequestId = requestId;
                db.ClearanceFormData.Add(clearance.clearanceFormData);
                db.SaveChanges();
                //List<ApproverHierarchy> approver = getApprovers(ID.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = ID.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new ID-CARD APPLICATION From Roll no: " + ID.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your ID-CARD APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(ID.request.RollNo, subject, Msg);

                //createApplicationActivity(requestId);

                return requestId;
            }
        }

        public int SaveIdCardForm(CustomCollegeIDCard ID)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(ID.request);

                //db.RequestMainData.Add(ID.request);
                //db.SaveChanges();

                //request ID
                ID.Challan.RequestID = requestId;
                ID.IDCard.RequestID = requestId;
                db.CollegeIDCardData.Add(ID.IDCard);
                db.SaveChanges();

                ID.Challan.IsActive = 1;
                db.Attachments.Add(ID.Challan);
                db.SaveChanges();

                //List<ApproverHierarchy> approver = getApprovers(ID.request.CategoryID);

                //ReqWorkflow requestworkflow = new ReqWorkflow();
                //requestworkflow.RequestID = requestId;
                //requestworkflow.EntryTime = ID.request.CreationDate;
                //insertDefaultWorkflow(requestworkflow, approver);
                ////sending email..
                //var loginid = getSpecificApprover(requestId, 1);
                //string Msg, subject;
                //subject = "NEW APPLICATION ALERT - ACAD/" + requestId;
                //Msg = "You have received a new ID-CARD APPLICATION From Roll no: " + ID.request.RollNo + " , please login to Student Request Portal";
                //SendEmailToApprover(loginid, subject, Msg);
                //subject = "APPLICATION SUBMITTED - ACAD/" + requestId;
                //Msg = "Your ID-CARD APPLICATION has been send successfully, please login Student Request Portal for further information";
                //SendEmailToStudent(ID.request.RollNo, subject, Msg);

                //createApplicationActivity(requestId);

                return requestId;
            }

        }

        public User GetUserByEmail(string emailAddress)
        {
            using (var db = new PRMDataContext())
            {
                var result = (from data in db.Users
                              where data.Email == emailAddress || data.Login == emailAddress
                              where data.IsActive == true && data.IsDisabledForLogin == false
                              select data).FirstOrDefault();
                return result;
            }
        }

        public RequestMainData GetRequestMainDataByID(int RequestId, String requestUniqueId)
        {
            using (var db = new PRMDataContext())
            {
                var result = (from r in db.RequestMainData
                              join u in db.Users on r.UserId equals u.UserId
                              where r.RequestID == RequestId && r.ReqUniqueId == requestUniqueId
                              select new { r, u.Name, u.StdFatherName, u.Section,u.Title }).FirstOrDefault();

                if (result != null)
                {
                    result.r.ApplicantName = result.Name;
                    result.r.FatherName = result.StdFatherName;
                    result.r.Section = result.Section;
                    result.r.Title = result.Title;
                    return result.r;
                }

                return null;
            }

        }

        public List<Approver> GetFormApprovers(int pApplicationId, String reqUniqueId)
        {
            //return list;

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetApproversByRequestId @0,@1";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pApplicationId },
                    new SqlParameter { ParameterName = "@1", Value = reqUniqueId}
                };

                var list = ctx.Database.SqlQuery<Approver>(query, args).ToList();
                return list;
            }
        }

        public List<Approver> SearchContributor(string key)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SearchApprover @0";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = key }
                };

                var list = ctx.Database.SqlQuery<Approver>(query, args).ToList();
                return list;
            }
        }
        public List<CourseWithdrawal> getCourseWithdrawData(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.CourseWithdrawalData.Where(x => x.RequestID == RequestId).Select(x => x);
                return query.ToList();
            }
        }
        public ClearanceFormData getClearance(int RequestId) {
            using (var db = new PRMDataContext()) {
                var query = db.ClearanceFormData.Where(x => x.RequestId== RequestId).FirstOrDefault();
                return query;
            }
        }
        public LeaveApplicationForm getLeave(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.LeaveApplicationForm.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public CollegeIDCardData getCollegeIdCard(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.CollegeIDCardData.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public BonafideCertificateData getBonafideCertificate(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.BonafideCertificateData.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public FinalTranscriptData getFinalTranscript(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.FinalTranscriptData.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public OptionForBscDegree getOptionForBsc(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.OptionForBscDegree.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public SemesterAcademicTranscript getSemesterAcadamicTranscript(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.SemesterAcademicTranscript.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public SemesterRejoinData getSmesterRejoin(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.SemesterRejoinData.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }
        public VehicalTokenData getVehicalToken(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.VehicalTokenData.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }

        public List<DemandForm> getItemDemandFormData(int RequestId) {
            using (var db = new PRMDataContext())
            {
                var query = db.DemandForm.Where(x => x.RequestID == RequestId);
                return query.ToList();
            }
        }

        public List<HardwareForm> getHardwareFormItems(int RequestId) {
            using (var db = new PRMDataContext())
            {
                var query = db.HardwareForm.Where(x => x.RequestID == RequestId);
                return query.ToList();
            }
        }

        public List<DemandVoucher> getDemandVoucher(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.DemandVoucher.Where(x => x.RequestID == RequestId);
                return query.ToList();
            }
        }
        public List<StoreDemandVoucher> getStoreDemandVoucher(int RequestId) {
            using (var db = new PRMDataContext())
            {
                var query = db.StoreDemandVoucher.Where(x => x.RequestID == RequestId);
                return query.ToList();
            }
        }

    
         public RoomReservation getRoomReservationData(int RequestId)
        {
            using (var db = new PRMDataContext())
            {
                var query = db.RoomReservation.Where(x => x.RequestID == RequestId).FirstOrDefault();
                return query;
            }
        }


        public LabReservationData getLabReservationFormData(int RequestId) {
            using (var db = new PRMDataContext()) {
                var query = db.LabReservationData.Where(x => x.RequestId == RequestId).FirstOrDefault();
                return query;
            }
        }
        public List<CustomApplicationStatusReport> SearchApplicationStatuses(AppStatusesSearchParam a)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.AppCountStatusWiseReport @0, @1,@2,@3,@4";

                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =a.Login},                    
                    new SqlParameter { ParameterName = "@1", Value =a.Status} ,
                    new SqlParameter { ParameterName = "@2", Value =a.IsApprover},  
                    new SqlParameter { ParameterName = "@3", Value =a.SDate},                   
                    new SqlParameter { ParameterName = "@4", Value =a.EDate}                    
               };
                var list = ctx.Database.SqlQuery<CustomApplicationStatusReport>(query, args).ToList();
                return list;
            }
        }
        //    List<User> u = db.Users.ToList();
        //    foreach (var e in u)
        //    {

        //        List<Approvers> app = db.Approvers.Where(x => x.UserID == e.UserId).ToList();
        //        if (app.Count > 0)
        //        {
        //            foreach (var a in app)
        //            {
        //                int tempapproverid = 0;
        //                CustomApplicationStatusReport cus = new CustomApplicationStatusReport();
        //                cus.UserName = e.Name;
        //                cus.userId = e.UserId;
        //                cus.LoginName = e.Login;
        //                cus.Role = "Approver";
        //                //cus.Designation = a.Designation;
        //                tempapproverid = a.ApproverID;

        //                string query = "execute dbo.GetAppCountByStatus @0, @1";
        //                var args = new DbParameter[] {
        //                    new SqlParameter { ParameterName = "@0", Value = 2},
        //                    new SqlParameter { ParameterName = "@1", Value = tempapproverid}
        //                };
        //                cus.appcount = db.Database.SqlQuery<AppCountDataStatusWise>(query, args).FirstOrDefault();
        //                list.Add(cus);
        //            }
        //        }
        //        else
        //        {
        //            CustomApplicationStatusReport cus = new CustomApplicationStatusReport();
        //            cus.UserName = e.Name;
        //            cus.userId = e.UserId;
        //            cus.LoginName = e.Login;
        //            cus.Role = "Student";
        //            cus.Designation = "N/A";

        //            string query = "execute dbo.GetAppCountByStatus @0, @1";
        //            var args = new DbParameter[] {
        //                    new SqlParameter { ParameterName = "@0", Value = 1},
        //                    new SqlParameter { ParameterName = "@1", Value = e.UserId}
        //                };
        //            cus.appcount = db.Database.SqlQuery<AppCountDataStatusWise>(query, args).FirstOrDefault();

        //            list.Add(cus);
        //        }
        //    }






        public List<FormCategories> getAllApplications()
        {
            using (var db = new PRMDataContext())
            {
                return db.FormCategories.ToList();
            }
        }

        public List<Approvers> getAllContributers()
        {
            using (var db = new PRMDataContext())
            {
                var query = db.Approvers.ToList();
                return query;
            }
        }
        public List<ApproverHeirachyDTO> GetApproverHerirachyByFormID(int pFormID)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetApproversByFormID @0";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pFormID},                    
                };

                var data = ctx.Database.SqlQuery<ApproverHeirachyDTO>(query, args).ToList();
                return data;
            }
        }


        public int AddContributers(ApproverHierarchy u)
        {
            using (var context = new PRMDataContext())
            {
                var student = (from d in context.ApproverHierarchy
                               where d.FormID == u.FormID && d.ApproverID == u.ApproverID
                               select d).ToList();
                foreach (var x in student)
                {
                    x.ApprovalOrder = u.ApprovalOrder;
                }
                if (student.Count > 0)
                {
                    context.SaveChanges();
                    return 1;

                }

                else if (student.Count == 0)
                {
                    u.AltApproverID = 1;
                    if (u.IsForNewCampus == true)
                        u.IsForOldCampus = false;
                    else
                        u.IsForOldCampus = true;
                    using (var ctx = new PRMDataContext())
                    {
                        string query = "execute dbo.AddContributers @0, @1, @2,@3,@4,@5";
                        var args = new DbParameter[] {
                        new SqlParameter { ParameterName = "@0", Value = u.FormID},
                        new SqlParameter { ParameterName = "@1", Value = u.ApproverID },
                        new SqlParameter { ParameterName = "@2", Value = u.AltApproverID },
                        new SqlParameter { ParameterName = "@3", Value = u.ApprovalOrder },
                        new SqlParameter { ParameterName = "@4", Value = u.IsForNewCampus},
                        new SqlParameter { ParameterName = "@5", Value = u.IsForOldCampus}
                    };
                        var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                        return data;
                    }
                }
                return 1;
            }
        }


        #region Functions using SPs


        public int SaveRemarks(ActivityLogTable pLog)
        {
            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();

                string query = "execute dbo.AddRemarks @0, @1, @2, @3,@4, @5,@6,@7,@8";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pLog.RequestId },
                    new SqlParameter { ParameterName = "@1", Value = pLog.UserId},
                    new SqlParameter { ParameterName = "@2", Value = pLog.ActivityTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pLog.Comments },
                    new SqlParameter { ParameterName = "@4", Value = pLog.IsPrintable},
                    new SqlParameter { ParameterName = "@5", Value = pLog.VisibleToUserID },
                    new SqlParameter { ParameterName = "@6", Value = pLog.CanReplyUserID },
                    new SqlParameter { ParameterName = "@7", Value = guid },
                    new SqlParameter { ParameterName = "@8" , Value = pLog.ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails

                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);

                FillEmailTemplatesAndProcess(emailRequests);

                return data;
            }
        }

        public int SaveReview(ActivityLogTable pLog)
        {
            
            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();

                string query = "execute dbo.AddReview @0, @1, @2, @3,@4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pLog.RequestId },
                    new SqlParameter { ParameterName = "@1", Value = pLog.UserId},
                    new SqlParameter { ParameterName = "@2", Value = pLog.ActivityTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pLog.Comments },
                    new SqlParameter { ParameterName = "@4", Value = guid },
                    new SqlParameter { ParameterName = "@5" , Value = pLog.ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails

                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);

                FillEmailTemplatesAndProcess(emailRequests);
                return data;
            }
        }

        public int HandleRecieving(ActivityLogTable pLog)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.HandleRecieving @0, @1, @2, @3,@4";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pLog.RequestId },
                    new SqlParameter { ParameterName = "@1", Value = pLog.UserId},
                    new SqlParameter { ParameterName = "@2", Value = pLog.ActivityTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pLog.Comments },
                    new SqlParameter { ParameterName = "@4", Value = pLog.ReqUniqueId}
                };

                //var query = String.Format("execute [dbo].HandleRecieving '{0}','{1}','{2}','{3}' ", pLog.RequestId, pLog.UserId, pLog.ActivityTime.YYYYMMDD(), pLog.Comments);
                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public List<InboxApplication> SearchApplications(SearchEntity entity, ApplicationAccessType accessType, int pCurrentlyLoggedInUser)
        {
            using (var ctx = new PRMDataContext())
            {
                var sd = entity.SDate.ToString("yyyy-MM-dd");
                var ed = entity.EDate.ToString("yyyy-MM-dd");

                string query = "execute dbo.SearchApplications @0, @1, @2, @3, @4, @5, @6, @7";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = entity.RollNO },
                    new SqlParameter { ParameterName = "@1", Value = entity.Name },
                    new SqlParameter { ParameterName = "@2", Value = sd },
                    new SqlParameter { ParameterName = "@3", Value = ed },
                    new SqlParameter { ParameterName = "@4", Value = entity.Status },
                    new SqlParameter { ParameterName = "@5", Value =  entity.Type },
                    new SqlParameter { ParameterName = "@6", Value = (int)accessType  },
                    new SqlParameter { ParameterName = "@7", Value = pCurrentlyLoggedInUser }
                };

                //var query = String.Format("execute dbo.SearchApplications '{0}','{1}','{2}','{3}','{4}','{5}',{6},{7} ", entity.RollNO, entity.Name, sd, ed, entity.Status, entity.Type, (int)accessType, pCurrentlyLoggedInUser);
                var list = ctx.Database.SqlQuery<InboxApplication>(query, args).ToList();
                return list;
            }
        }

        public AppCountDataStatusWise GetAppCountStatusWise(ApplicationAccessType accessType, int pCurrentlyLoggedInUser)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetAppCountByStatus @0, @1";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = (int)accessType },
                    new SqlParameter { ParameterName = "@1", Value = pCurrentlyLoggedInUser }
                };

                //var query = String.Format("execute dbo.GetAppCountByStatus '{0}','{1}' ", (int)accessType, pCurrentlyLoggedInUser);
                var data = ctx.Database.SqlQuery<AppCountDataStatusWise>(query, args).FirstOrDefault();
                return data;
            }
        }

        public int ApproveRejectRequest(ReqWorkflow pData)
        {

            using (var ctx = new PRMDataContext())
            {

                String guid = Guid.NewGuid().ToString();

                string query = "execute dbo.ApproveRequest @0, @1, @2, @3, @4,@5,@6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pData.RequestID },
                    new SqlParameter { ParameterName = "@1", Value = pData.ApproverID},
                    new SqlParameter { ParameterName = "@2", Value = DateTime.UtcNow.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pData.Remarks },
                    new SqlParameter { ParameterName = "@4", Value = pData.Status },
                    new SqlParameter { ParameterName = "@5", Value = guid },
                    new SqlParameter { ParameterName = "@6", Value = pData.ReqUniqueId }
                };

                int result = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails

                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);

                FillEmailTemplatesAndProcess(emailRequests);
                return result;
            }

        }

        public int RouteBack(ReqWorkflow pData)
        {

            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();

                string query = "execute dbo.RouteBack @0, @1, @2, @3, @4,@5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pData.RequestID },
                    new SqlParameter { ParameterName = "@1", Value = pData.ApproverID},
                    new SqlParameter { ParameterName = "@2", Value = DateTime.UtcNow.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pData.Remarks },
                    new SqlParameter { ParameterName = "@4", Value = guid },
                    new SqlParameter { ParameterName = "@5", Value = pData.ReqUniqueId }
                };

                var result = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails
                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);

                FillEmailTemplatesAndProcess(emailRequests);
                return result;
            }

        }

        public List<EmailRequest> GetEmailRequestsForProcessing()
        {

            try
            {
                using (var ctx = new PRMDataContext())
                {
                    var list = ctx.EmailRequests.Where(p => p.EmailRequestStatus == (int)EmailRequestStatus.Pending).OrderBy(p => p.EmailRequestID).ToList();
                    return list;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public void ProcessEmailRequests(List<long> list)
        {
            using (var ctx = new PRMDataContext())
            {
                foreach (var id in list)
                {
                    var dto = new EmailRequest() { EmailRequestID = id, EmailRequestStatus = (int)EmailRequestStatus.Processed };
                    ctx.EmailRequests.Attach(dto);
                    var entry = ctx.Entry(dto);
                    entry.State = EntityState.Unchanged;
                    entry.Property(e => e.EmailRequestStatus).IsModified = true;
                }

                ctx.SaveChanges();

            }
        }

        public List<FormCategories> GetAllFormCategories()
        {

            using (var ctx = new PRMDataContext())
            {
                try
                {
                    return ctx.FormCategories.ToList();
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
        }
        public List<ActivityLogTable> GetActivityLogData(int requestId,String reqUniqueId, ApplicationAccessType accessType, int userId)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetActivityLogData @0, @1,@2,@3";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = userId },
                    new SqlParameter { ParameterName = "@2", Value = (int)accessType },
                    new SqlParameter { ParameterName = "@3", Value = reqUniqueId}
                };
                var data = ctx.Database.SqlQuery<ActivityLogTable>(query, args).ToList();

                foreach (var d in data)
                {
                    d.ActivityTime = d.ActivityTime.ToTimeZoneTime(tzi);
                }

                return data;
            }
        }
        public ActivityLogReportSearchResult GetActivityLogDataForReport(ApplicationAccessType accessType, int userId, ActivityLogSearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                ActivityLogReportSearchResult result = new Entities.DBEntities.ActivityLogReportSearchResult();
                string query = "execute dbo.GetActivityLogDataForReport @0, @1, @2, @3";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = userId });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = (int)accessType });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();
                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<ActivityLogTable>(reader).ToList();

                foreach (var d in result.Result)
                {
                    d.ActivityTime = d.ActivityTime.ToTimeZoneTime(tzi);
                }
                return result;
            }
        }
        public long SaveActivityLogConverstation(ActivityLogConversation data, ApplicationAccessType accessType, int pCurrentApproverId)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute [dbo].SaveLogConversation @0, @1, @2, @3, @4, @5, @6,@7";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = data.RequestId },
                    new SqlParameter { ParameterName = "@1", Value = data.ActivityLogID },
                    new SqlParameter { ParameterName = "@2", Value = data.UserID},
                    new SqlParameter { ParameterName = "@3", Value = (int)accessType },
                    new SqlParameter { ParameterName = "@4", Value = data.MessageTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@5", Value = data.Message},
                    new SqlParameter { ParameterName = "@6", Value = pCurrentApproverId},
                    new SqlParameter { ParameterName = "@7", Value = data.ReqUniqueId}
                };

                var data1 = ctx.Database.SqlQuery<long>(query, args).FirstOrDefault();
                return data1;
            }
        }

        public List<ActivityLogConversation> GetActivityLogConverstations(int requestId,String ReqUniqueId, long activityLogId, ApplicationAccessType accessType, int userId, int pCurrentApproverId)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetActivityLogConversationData @0, @1,@2,@3,@4,@5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = activityLogId },
                    new SqlParameter { ParameterName = "@2", Value = userId },
                    new SqlParameter { ParameterName = "@3", Value = (int)accessType },
                    new SqlParameter { ParameterName = "@4", Value = pCurrentApproverId},
                    new SqlParameter { ParameterName = "@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<ActivityLogConversation>(query, args).ToList();
                foreach (var d in data)
                {
                    d.MessageTime = d.MessageTime.ToTimeZoneTime(tzi);

                }
                return data;
            }
        }

        public int insertNewFlowSP(ChangeContributors obj)
        {
            using (var ctx = new PRMDataContext())
            {
                var str = string.Join(",", obj.addContrList);

                string query = "execute dbo.UpdateWorkFlow @0, @1, @2, @3,@4";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = str },
                    new SqlParameter { ParameterName = "@1", Value = obj.requestId },
                    new SqlParameter { ParameterName = "@2", Value = obj.CurrentUserId },
                    new SqlParameter { ParameterName = "@3", Value = DateTime.UtcNow.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@4", Value =SessionManager.ActualUserLoginID }
               
                };

                var id = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return id;
            }
        }

        public SecUserDTO ValidateUserSP(String pLogin, String pPassword, DateTime pCurrTime, String pMachineIP, Boolean pIgnorePassword, String pLoggerLoginID, LoginType pLoginType)
        {

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.ValidateUser @0, @1, @2, @3,@4,@5,@6";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = pLogin });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = pPassword });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = pCurrTime.YYYYMMDD() });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = pMachineIP });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@4", Value = pIgnorePassword });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@5", Value = pLoggerLoginID });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@6", Value = pLoginType.ToString() });
                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();


                // Read User from the first result set
                var user = ((IObjectContextAdapter)ctx)
                    .ObjectContext
                    .Translate<User>(reader).FirstOrDefault();

                if (user != null)
                {
                    var secUserForSession = new SecUserDTO();
                    if (user.IsActive == false || user.IsDisabledForLogin == true)
                    {
                        secUserForSession.IsActive = user.IsActive;
                        secUserForSession.IsDisabledForLogin = user.IsDisabledForLogin;
                    }
                    else
                    {
                        var appDesigs = new List<ApproverDesignation>();
                        int currApproverId = 0;

                        if (user.IsContributor)
                        {
                            reader.NextResult();
                            appDesigs = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<ApproverDesignation>(reader).ToList();

                            reader.NextResult();
                            currApproverId = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<int>(reader).FirstOrDefault();

                        }

                        reader.NextResult();
                        var roles = ((IObjectContextAdapter)ctx)
                            .ObjectContext
                            .Translate<Roles>(reader).ToList();

                        reader.NextResult();
                        var permissions = ((IObjectContextAdapter)ctx)
                            .ObjectContext
                            .Translate<PermissionsWithRoleID>(reader).ToList();

                        reader.Close();

                        secUserForSession.Login = user.Login;
                        secUserForSession.UserFullName = user.Name;
                        secUserForSession.UserId = user.UserId;
                        secUserForSession.SignatureName = user.SignatureName;
                        secUserForSession.Email = user.Email;
                        secUserForSession.Title = user.Title;
                        secUserForSession.StdFatherName = user.StdFatherName;
                        secUserForSession.Section = user.Section;
                        secUserForSession.IsContributor = user.IsContributor;
                        secUserForSession.IsActive = user.IsActive;
                        secUserForSession.Permissions = new List<string>();
                        secUserForSession.Roles = new List<string>();
                        secUserForSession.ApproverDesignations = new List<ApproverDesignation>();

                        if (user.IsContributor)
                        {
                            foreach (var r in appDesigs)
                            {
                                secUserForSession.ApproverDesignations.Add(r);
                            }

                            if (secUserForSession.ApproverDesignations.Count > 0)
                            {
                                var desig = secUserForSession.ApproverDesignations.Where(p => p.ApproverID == currApproverId).FirstOrDefault();
                                secUserForSession.CurrentApproverID = desig.ApproverID;
                                secUserForSession.Title = desig.Designation;
                            }
                        }

                        foreach (var r in roles)
                        {
                            secUserForSession.Roles.Add(r.Name);
                        }

                        foreach (var p in permissions)
                        {
                            secUserForSession.Permissions.Add(p.Name.ToUpper());
                        }
                    }
                    return secUserForSession;
                }

                reader.Close();
                return null;
            }
        }

        public List<String> GetRolePermissionById(int ApproverId, out List<String> pRoles)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetRolePermissionById @0";
                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = ApproverId });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();


                var roles = ((IObjectContextAdapter)ctx)
                        .ObjectContext
                        .Translate<Roles>(reader).ToList();

                reader.NextResult();
                var permissions = ((IObjectContextAdapter)ctx)
                    .ObjectContext
                    .Translate<PermissionsWithRoleID>(reader).ToList();

                reader.Close();

                var rolesList = new List<String>();
                var permList = new List<String>();

                foreach (var r in roles)
                {
                    rolesList.Add(r.Name);
                }

                foreach (var p in permissions)
                {
                    permList.Add(p.Name.ToUpper());
                }

                pRoles = rolesList;

                return permList;
            }
        }


        public int SaveAttachment(int requestId,String ReqUniqueId, String fileName, String attachment, DateTime pCreatedOn, int pUserId)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveAttachment @0, @1, @2, @3,@4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = fileName},
                    new SqlParameter { ParameterName = "@2", Value = attachment},
                    new SqlParameter { ParameterName = "@3", Value = pCreatedOn.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@4", Value = pUserId},
                    new SqlParameter { ParameterName = "@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }
        public List<FormCategories> FillDropDown(int UserID,int flag)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetFormCategoriesByRoleID @0,@1";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = UserID},
                    new SqlParameter { ParameterName = "@1", Value = flag}
                };
                var data = ctx.Database.SqlQuery<FormCategories>(query, args).ToList();
                return data;
            }
        }

        public int SaveDemandForm(CustomDemandForm Items)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(Items.request);

                for (int i = 0; i < Items.Items.Count; i++)
                {
                    Items.Items[i].RequestID = requestId;
                    db.DemandForm.Add(Items.Items[i]);

                }
                db.SaveChanges();
                return requestId;
            }
        }
        public int SaveRoomReservation(CustomRoomReservation roomRes)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(roomRes.request);
                roomRes.roomReservationData.RequestID= requestId;
                db.RoomReservation.Add(roomRes.roomReservationData);
                db.SaveChanges();
                return requestId;
            }
        }
        public int SaveDemandVoucher(CustomDemandVoucher Items)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(Items.request);

                for (int i = 0; i < Items.Items.Count; i++)
                {

                    Items.Items[i].RequestID = requestId;
                    db.DemandVoucher.Add(Items.Items[i]);
                }
                db.SaveChanges();
                return requestId;
            }
        }

        public int SaveStoreDemandVoucher(CustomStoreDemandVoucher Items)
        {
            using (var db = new PRMDataContext())
            {

                var requestId = SaveApplicationRequest(Items.request);

                for (int i = 0; i < Items.Items.Count; i++)
                {
                    Items.Items[i].RequestID = requestId;
                    db.StoreDemandVoucher.Add(Items.Items[i]);
                }
                db.SaveChanges();
                return requestId;
            }

        }

        public int SaveHardwareForm(CustomHardwareForm Items)
        {
            using (var db = new PRMDataContext())
            {
                var requestId = SaveApplicationRequest(Items.request);

                for (int i = 0; i < Items.Items.Count; i++)
                {
                    Items.Items[i].RequestID = requestId;
                    db.HardwareForm.Add(Items.Items[i]);
                }
                db.SaveChanges();
                return requestId;
            }
        }

        public int SaveLabReservationForm(CustomLabReservationForm labReservation) {
            using (var db = new PRMDataContext()) {
                var requestId = SaveApplicationRequest(labReservation.request);
                labReservation.labReservationData.RequestId = requestId;
                db.LabReservationData.Add(labReservation.labReservationData);
                db.SaveChanges();
                return requestId;
            }
            
        }

        public List<Items> getItemsName()
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.getItems";
                var data = ctx.Database.SqlQuery<Items>(query).ToList();
                return data;
            }
        }

        public List<HardwareItems> getHardwareItemsName()
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.getHardwareItems";
                var data = ctx.Database.SqlQuery<HardwareItems>(query).ToList();
                return data;
            }
        }

        public int RemoveAttachment(int requestId,String ReqUniqueId, String attachment, DateTime pDateTime, int pUserId)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.RemoveAttachment @0, @1, @2, @3, @4";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = attachment},
                    new SqlParameter { ParameterName = "@2", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                    new SqlParameter { ParameterName = "@4", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public int UpdateAttachment(int requestId, String ReqUniqueId, String attachment, DateTime pCreatedOn, int pUserId, String oldAttachment)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.UpdateAttachment @0, @1, @2, @3,@4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = attachment},
                    new SqlParameter { ParameterName = "@2", Value = pCreatedOn.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                    new SqlParameter { ParameterName = "@4", Value = oldAttachment},
                    new SqlParameter { ParameterName = "@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public int EnableDisableRequestEdit(int requestId,String ReqUniqueId, DateTime pDateTime, int pUserId, Boolean CanStudentEdit, String pRemarks)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.EnableDisableRequestEdit @0, @1, @2, @3, @4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@2", Value = pUserId},
                    new SqlParameter { ParameterName = "@3", Value = CanStudentEdit},
                    new SqlParameter { ParameterName = "@4", Value = pRemarks},
                    new SqlParameter { ParameterName = "@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }


        public int UpdateActivityLogActionItem(int requestId,String ReqUniqueId, int actId, DateTime pDateTime, int pUserId, int type, int value)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.UpdateActivityLogActionItem @0, @1, @2, @3, @4,@5,@6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = actId },
                    new SqlParameter { ParameterName = "@2", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                    new SqlParameter { ParameterName = "@4", Value = type},
                    new SqlParameter { ParameterName = "@5", Value = value},
                    new SqlParameter { ParameterName = "@6", Value = ReqUniqueId }
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public int UpdateCGPA(int requestId, String ReqUniqueId, double cgpa, DateTime pDateTime, int pUserId, String otheruserlogin)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.UpdateCGPA @0, @1, @2, @3,@4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = cgpa },
                    new SqlParameter { ParameterName = "@2", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                     new SqlParameter { ParameterName = "@4", Value = otheruserlogin},
                     new SqlParameter { ParameterName = "@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public ApplicationAccessData GetApplicationAccessData(int requestId, ApplicationAccessType accessType, int pCurrentlyLoggedInUser, Boolean pOnlyValidateRequest)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetRequestAccessParams @0, @1, @2, @3";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId},
                    new SqlParameter { ParameterName = "@1", Value = (int)accessType },
                    new SqlParameter { ParameterName = "@2", Value = pCurrentlyLoggedInUser },
                    new SqlParameter { ParameterName = "@3", Value = pOnlyValidateRequest },
                };

                var data = ctx.Database.SqlQuery<ApplicationAccessData>(query, args).FirstOrDefault();
                return data;
            }
        }


        public List<EmailRequest> GetEmailRequestsByUniqueID(PRMDataContext ctx, String pUniqueID)
        {
            try
            {
                var data = new List<EmailRequest>();
                string query = "execute dbo.GetEmailRequestsByUniqueID @0";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pUniqueID}
                    };

                if (ctx != null)
                {
                    data = ctx.Database.SqlQuery<EmailRequest>(query, args).ToList();
                }
                else
                {
                    using (ctx = new PRMDataContext())
                    {
                        data = ctx.Database.SqlQuery<EmailRequest>(query, args).ToList();

                    }
                }
                return data;
            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion

        private void ProcessEmails(List<EmailRequest> pEmails)
        {
            System.Threading.Thread th = new System.Threading.Thread(delegate(Object a)
            {

                try
                {
                    var pEmailRequests = (List<EmailRequest>)a;
                    var list = new List<long>();
                    foreach (var email in pEmailRequests)
                    {
                        GlobalDataManager._emailhandler.SendEmail(new EmailMessageParam()
                        {
                            ToIDs = email.EmailTo,
                            Subject = email.Subject,
                            AlternateView = email.av,
                            Body = email.MessageBody,
                            IsBodyHTML = true
                        });
                        //EmailHandler.SendEmail(email.EmailTo, email.Subject, email.MessageBody);
                        list.Add(email.EmailRequestID);
                    }
                    ProcessEmailRequests(list);
                }
                catch (Exception ex)
                {
                    throw;
                }
            });

            th.Start(pEmails);

        }

        public bool deleteContributor(ApproverHierarchy u)
        {
            bool rowDeleted = false;
            try
            {

                using (var context = new PRMDataContext())
                {
                    var Approvers = (from d in context.ApproverHierarchy
                                     where d.ApproverID == u.ApproverID && d.FormID == u.FormID
                                     select d).ToList();
                    for (int a = 0; a < Approvers.Count; a++)
                        context.ApproverHierarchy.Remove(Approvers[a]);
                    context.SaveChanges();
                    rowDeleted = context.SaveChanges() > 0;
                }
            }
            catch (Exception ex)
            {
                LogHandler.WriteLog("loggedinuserloginid", ex.Message, PUCIT.AIMRL.Common.Logger.LogType.ErrorMsg, ex);
                throw;
            }

            return rowDeleted;
        }



        #region Roles
        public int SaveRole(Roles role, DateTime pActivityTime, int pActivityBy)
        {

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveRoles @0, @1, @2,@3,@4";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = role.Id },
                    new SqlParameter { ParameterName = "@1", Value = role.Name},
                    new SqlParameter { ParameterName = "@2", Value = role.Description},
                    new SqlParameter { ParameterName = "@3", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@4", Value = pActivityBy}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }
        public bool EnableDisableRole(int pRoleID, Boolean pIsActiv, DateTime pActivityTime, int pActivityBy)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.EnableDisableRole @0, @1, @2, @3";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pRoleID},
                     new SqlParameter { ParameterName = "@1", Value = pIsActiv},
                    new SqlParameter { ParameterName = "@2", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@3", Value = pActivityBy}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return true;
            }
        }
        public List<Roles> GetAllRoles()
        {
            using (var db = new PRMDataContext())
            {
                return db.Roles.ToList();
            }
        }

        public List<int> GetRolesByUserID(int pUserID)
        {
            using (var db = new PRMDataContext())
            {
                var result = db.UserRoles.Where(p => p.UserId == pUserID).Select(p => p.RoleId).ToList();
                return result;
            }
        }

        public int SaveUserRoleMapping(int pUserID, List<int> pRoles)
        {
            using (var db = new PRMDataContext())
            {

                DataTable dt = new DataTable();
                dt.Columns.Add("ID");

                foreach (var p in pRoles)
                {
                    DataRow row = dt.NewRow();
                    dt.Rows.Add(p);
                }

                string query = "execute dbo.SaveUserRoleMapping @0, @1";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pUserID},
                     new SqlParameter { ParameterName = "@1", Value = dt, SqlDbType = SqlDbType.Structured, TypeName = "dbo.ArrayInt" },
                };

                var data = db.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return data;
            }
        }

        #endregion

        #region Permission
        public int SavePermission(PermissionsWithRoleID per, DateTime pActivityTime, int pActivityBy)
        {

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SavePermission @0, @1,@2,@3,@4";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = per.Id},
                    new SqlParameter { ParameterName = "@1", Value = per.Name},
                    new SqlParameter { ParameterName = "@2", Value = per.Description},
                    new SqlParameter { ParameterName = "@3", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@4", Value = pActivityBy}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }
        public bool EnableDisablePermission(int pPermissionID, Boolean pIsActiv, DateTime pActivityTime, int pActivityBy)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.EnableDisablePermission @0, @1, @2, @3";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pPermissionID},
                     new SqlParameter { ParameterName = "@1", Value = pIsActiv},
                    new SqlParameter { ParameterName = "@2", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@3", Value = pActivityBy}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return true;
            }

        }
        public List<Permissions> GetAllPermissions()
        {
            using (var db = new PRMDataContext())
            {
                string query = "execute dbo.GetAllPermissions ";
                var list = db.Database.SqlQuery<Permissions>(query).ToList();
                return list;
            }
        }

        public List<int> GetPermissionsByRoleID(int pRoleID)
        {
            using (var db = new PRMDataContext())
            {
                var result = db.PermissionsMapping.Where(p => p.RoleId == pRoleID).Select(p => p.PermissionId).ToList();
                return result;
            }
        }

        public int SaveRolePermissionMapping(int pRoleID, List<int> pPermissionsList)
        {
            using (var db = new PRMDataContext())
            {

                DataTable dt = new DataTable();
                dt.Columns.Add("ID");

                foreach (var p in pPermissionsList)
                {
                    DataRow row = dt.NewRow();
                    dt.Rows.Add(p);
                }

                string query = "execute dbo.SaveRolePermissionMapping @0, @1";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pRoleID},
                     new SqlParameter { ParameterName = "@1", Value = dt, SqlDbType = SqlDbType.Structured, TypeName = "dbo.ArrayInt" },
                };

                var data = db.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return data;
            }
        }

        #endregion

        #region Users
        public int SaveUsers(User u, DateTime pActivityTime, int pActivityBy)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ID1");
            dt.Columns.Add("ID2");

            foreach (var p in u.ApprDesignations)
            {
                DataRow row = dt.NewRow();
                dt.Rows.Add(p.ApproverID, p.DesignationID);
            }

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveUsers @0, @1, @2, @3,@4, @5,@6,@7,@8,@9,@10,@11,@12";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = u.UserId },
                    new SqlParameter { ParameterName = "@1", Value = u.Login},
                    new SqlParameter { ParameterName = "@2", Value = u.Password },
                    new SqlParameter { ParameterName = "@3", Value = u.Name },
                    new SqlParameter { ParameterName = "@4", Value = u.Email },
                    new SqlParameter { ParameterName = "@5", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@6", Value = pActivityBy},
                    new SqlParameter { ParameterName = "@7", Value =u.Title},
                    new SqlParameter { ParameterName = "@8", Value = u.StdFatherName },
                    new SqlParameter { ParameterName = "@9", Value = u.Section },
                    new SqlParameter { ParameterName = "@10", Value = u.IsContributor},
                    new SqlParameter { ParameterName = "@11", Value = u.IsOldCampus},
                    new SqlParameter { ParameterName = "@12", Value = dt, SqlDbType = SqlDbType.Structured, TypeName = "dbo.ArrayInt2" },
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }
        public void SaveUsersBulk(List<User> u)
        {
            using (var ctx = new PRMDataContext())
            {
                ctx.Users.AddRange(u);
                ctx.SaveChanges();
            }
        }
        public bool EnableDisableUser(int pUserID, Boolean pIsActiv, DateTime pActivityTime, int pActivityBy)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.EnableDisableUser @0, @1, @2, @3";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pUserID},
                     new SqlParameter { ParameterName = "@1", Value = pIsActiv},
                    new SqlParameter { ParameterName = "@2", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@3", Value = pActivityBy}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return true;
            }
        }
        public List<User> GetAllUsers()
        {
            using (var db = new PRMDataContext())
            {
                return db.Users.ToList();
            }
        }


        public UserSearchResult SearchUsers(UserSearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                UserSearchResult result = new Entities.DBEntities.UserSearchResult();

                string query = "execute dbo.SearchUsers @0, @1, @2,@3,@4,@5";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = entity.TextToSearch });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = entity.IsOldCampus });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.IsContributor });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.IsActive });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@4", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@5", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();

                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<UserSearchResultObj>(reader).ToList();

                return result;
            }
        }

        public LoginHistorySearchResult SearchLoginHistory(LoginHistorySearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                LoginHistorySearchResult result = new Entities.DBEntities.LoginHistorySearchResult();

                string query = "execute dbo.SearchLoginHistory @0, @1, @2,@3,@4,@5";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = entity.Login });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = entity.MachineIp });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.SDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.EDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@4", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@5", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();

                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<LoginHistory>(reader).ToList();
                foreach (var d in result.Result)
                {
                    d.LoginTime = d.LoginTime.ToTimeZoneTime(tzi);
                }
                return result;
            }
        }

        public List<UserDTOForAutoComplete> SearchUser(string key)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SearchUserForAutoComplete @0";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = key }
                };

                var list = ctx.Database.SqlQuery<UserDTOForAutoComplete>(query, args).ToList();
                return list;
            }
        }
        #endregion

        #region Items

        public List<Items> getVoucherItemsName()
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.getVoucherItems";



                var data = ctx.Database.SqlQuery<Items>(query).ToList();
                return data;
            }
        }

        public object SaveItems(Items r, DateTime pActivityTime, int pActivityBy)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveItems @0, @1, @2, @3, @4,@5,@6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = r.ItemId },
                    new SqlParameter { ParameterName = "@1", Value = r.ItemName},
                    new SqlParameter { ParameterName = "@2", Value = r.Description},
                    new SqlParameter { ParameterName = "@3", Value = r.Quantity},
                    new SqlParameter { ParameterName = "@4", Value = r.Type},
                     new SqlParameter { ParameterName = "@5", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@6", Value = pActivityBy}

                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }

        }
      
        public object SaveQuantity(customManageQty qty)
        {

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveQty @0, @1, @2, @3,@4,@5,@6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = qty.ItemId },
                    new SqlParameter { ParameterName = "@1", Value = qty.ItemName},
                     new SqlParameter { ParameterName = "@2", Value = qty.Quantity},
                     new SqlParameter { ParameterName = "@3", Value = qty.InQuantity},
                     new SqlParameter { ParameterName = "@4", Value = SessionManager.GetUserLogin()},
                     new SqlParameter { ParameterName = "@5", Value =DateTime.UtcNow.YYYYMMDD()},
                     new SqlParameter { ParameterName = "@6", Value = SessionManager.GetUserFullName()}

                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }

        }
       
        public List<Items> getItems()
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.getAllItems";



                var data = ctx.Database.SqlQuery<Items>(query).ToList();
                //hello
                return data;
            }
        }
        
        public bool EnableDisbaleItem(int id, Boolean pIsActive, DateTime pActivityTime, int pActivityBy)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.EnableDisableItem @0,@1,@2,@3";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = id },
                    new SqlParameter { ParameterName = "@1", Value = pActivityTime.YYYYMMDD()},
                    new SqlParameter { ParameterName = "@2", Value = pActivityBy},
                    new SqlParameter { ParameterName = "@3", Value = pIsActive}
                 };
                 


                var data = ctx.Database.SqlQuery<bool>(query, args).FirstOrDefault();
                return data;
            }
        }
     
        public int UpdateItems(customUpdateItems Items)
        {

            using (var db = new PRMDataContext())
            {
                for (var j = 0; j < Items.ItemID.Length; j++)
                {
                    var query1 = "execute dbo.getItemQuantityFromItemsTable @0";
                    var args1 = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.ItemID[j] },};
                    var b = db.Database.SqlQuery<int>(query1, args1).FirstOrDefault();
                    if (b < Items.ItemQtyIssued[j])
                    {
                        return 0;
                    }


                }
                for (int i = 0; i < Items.ItemID.Length; i++)
                {
                    var query = "execute dbo.UpdateItemsinMainItemsForm @0, @1";
                    var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.ItemQtyIssued[i] },
                    new SqlParameter { ParameterName = "@1", Value = Items.ItemID[i]} };
                    db.Database.ExecuteSqlCommand(query, args);
                }
                return 1;
            }
        }

        public void UpdateIssuedQty(customUpdateIssuedQty Items)
        {
            var requestId = Items.request.RequestID;
            for (int i = 0; i < Items.DemandId.Length; i++)
            {
                using (var db = new PRMDataContext())
                {
                    var query = "execute dbo.UpdateDemandFormIssuedQty @0, @1";
                    var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.isssuedQty[i] },
                    new SqlParameter { ParameterName = "@1", Value = Items.DemandId[i]} };
                    db.Database.ExecuteSqlCommand(query, args);
                    db.SaveChanges();
                }

            }
        }
        public List<CustomItemReport> SearchItemReport(AppItemSearchParam a)
        {
            List<CustomItemReport> list = new List<CustomItemReport>();

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.ItemSearchReport @0, @1,@2,@3,@4";

                    var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = a.Login},
                    new SqlParameter { ParameterName = "@1", Value = a.Item},
                     new SqlParameter { ParameterName = "@2", Value =a.SDate},
                    new SqlParameter { ParameterName = "@3", Value =a.EDate},
                     new SqlParameter { ParameterName = "@4", Value =a.searchType}

                };
                list = ctx.Database.SqlQuery<CustomItemReport>(query, args).ToList();              
                return list;
            }
        }
        #endregion

        #region ApproverDesignation

        public List<DesignationDTO> GetDesignations()
        {
            using (var db = new PRMDataContext())
            {
                string query = "execute dbo.GetAllDesignations ";
                var list = db.Database.SqlQuery<DesignationDTO>(query).ToList();
                return list;
            }
        }

        public List<Approvers> GetDesignationsByUserID(int pUserID)
        {
            using (var db = new PRMDataContext())
            {
                return db.Approvers.Where(x => x.UserID == pUserID && x.IsActive == true).ToList();
            }
        }

        #endregion

        public int SaveContributorsForForm(int pFormID, List<ApproverHeirachyDTO> pContributorList)
        {
            using (var db = new PRMDataContext())
            {

                DataTable dt = new DataTable();
                dt.Columns.Add("ID1");
                dt.Columns.Add("ID2");
                dt.Columns.Add("Flag1");
                dt.Columns.Add("Flag2");

                foreach (var p in pContributorList)
                {
                    DataRow row = dt.NewRow();
                    dt.Rows.Add(p.ApproverID, p.ApprovalOrder, p.IsForNewCampus, p.IsForOldCampus);
                }

                string query = "execute dbo.SaveContributorsForForm @0, @1";

                var args = new DbParameter[] {
                     new SqlParameter { ParameterName = "@0", Value = pFormID},
                     new SqlParameter { ParameterName = "@1", Value = dt, SqlDbType = SqlDbType.Structured, TypeName = "dbo.ArrayIntFlags" },
                };

                var data = db.Database.SqlQuery<int>(query, args).FirstOrDefault();

                return data;
            }
        }

        public ContactUsSearchResult SearchContactUs(ContactUsSearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                ContactUsSearchResult result = new Entities.DBEntities.ContactUsSearchResult();

                string query = "execute dbo.SearchContactUs @0, @1, @2,@3,@4,@5";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = entity.Name });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = entity.Email });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.SDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.EDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@4", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@5", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();

                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<ContactUsDTO>(reader).ToList();
                foreach (var d in result.Result)
                {
                    d.EntryTime = d.EntryTime.ToTimeZoneTime(tzi);
                }
                return result;
            }
        }

        public long SaveContactUs(ContactUsDTO per, DateTime pActivityTime)
        {

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.SaveContactUs @0, @1,@2,@3,@4,@5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = per.ID},
                    new SqlParameter { ParameterName = "@1", Value = per.Name},
                    new SqlParameter { ParameterName = "@2", Value = per.Email},
                    new SqlParameter { ParameterName = "@3", Value = per.MachineIP},
                    new SqlParameter { ParameterName = "@4", Value = per.Description},
                    new SqlParameter { ParameterName = "@5", Value = pActivityTime.YYYYMMDD()},
                    
                };

                var data = ctx.Database.SqlQuery<long>(query, args).FirstOrDefault();
                return data;
            }
        }
        public ClearanceDetails ClearanceFormCreatedOrNot( int pUserId) {
            using (var db = new PRMDataContext()) {
                ClearanceDetails clearanceDataObj = new ClearanceDetails();
                var data = from clearanceData in db.RequestMainData
                           where clearanceData.CategoryID == 1 && clearanceData.UserId == pUserId
                           select new {
                               Id = clearanceData.RequestID,
                               uniqueId = clearanceData.ReqUniqueId,
                               status = clearanceData.RequestStatus

                           };
                foreach (var d in data) {
                    clearanceDataObj.clearanceReqId = d.Id;
                    clearanceDataObj.clearanceUniqueReqId = d.uniqueId;
                    clearanceDataObj.status = d.status;
                }
                return clearanceDataObj;
            }
        }
        public int RemoveContributor(int requestId,String ReqUniqueId, int wfId, int approverIdToRemove, DateTime pDateTime, int pUserId, String otheruserlogin)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.RemoveContributor @0, @1, @2, @3,@4,@5, @6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = wfId },
                    new SqlParameter { ParameterName = "@2", Value = approverIdToRemove },
                    new SqlParameter { ParameterName = "@3", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@4", Value = pUserId},
                     new SqlParameter { ParameterName = "@5", Value = otheruserlogin},
                     new SqlParameter { ParameterName = "@6", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }
        public int AddContributor(int requestId,String ReqUniqueId, int approverIdToAdd, DateTime pDateTime, int pUserId, String otheruserlogin)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.AddContributor @0, @1, @2, @3,@4,@5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = approverIdToAdd },
                    new SqlParameter { ParameterName = "@2", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                     new SqlParameter { ParameterName = "@4", Value = otheruserlogin},
                     new SqlParameter { ParameterName = "@5", Value= ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public int UpdateContributorsOrder(int requestId,String ReqUniqueId, List<ReqWorkFlowShort> pReqWorkFlowList, DateTime pDateTime, int pUserId, String otheruserlogin)
        {

            DataTable dt = new DataTable();
            dt.Columns.Add("ID1");
            dt.Columns.Add("ID2");
            dt.Columns.Add("ID3");

            foreach (var p in pReqWorkFlowList)
            {
                DataRow row = dt.NewRow();
                dt.Rows.Add(p.ID, p.ApproverID, p.ApprovalOrder);
            }

            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.UpdateContributorsOrder @0, @1, @2, @3,@4, @5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = dt, SqlDbType = SqlDbType.Structured, TypeName = "dbo.ArrayInt3" },
                    new SqlParameter { ParameterName = "@2", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@3", Value = pUserId},
                     new SqlParameter { ParameterName = "@4", Value = otheruserlogin}, 
                     new SqlParameter { ParameterName ="@5", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public ForgotPasswordSearchResult SearchForgotPasswordLog(ForgotPasswordSearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                ForgotPasswordSearchResult result = new Entities.DBEntities.ForgotPasswordSearchResult();

                string query = "execute dbo.SearchForgotPasswordLog @0, @1, @2,@3,@4";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = entity.Login });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = entity.SDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.EDate });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@4", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();

                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<ForgotPasswordLogDTO>(reader).ToList();
                foreach (var d in result.Result)
                {
                    d.EntyDate = d.EntyDate.ToTimeZoneTime(tzi);
                }
                return result;
            }
        }

        public int GetPendingRequestsCountByCategoryID_UserID(int pFormID, int pUserID)
        {
            using (var ctx = new PRMDataContext())
            {
                string query = "execute dbo.GetPendingRequestsCountByCategoryID_UserID @0,@1";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pFormID},
                    new SqlParameter { ParameterName = "@1", Value = pUserID},
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();
                return data;
            }
        }

        public ResponseResult SwapContributor(int requestId,String ReqUniqueId, int currentApproverId, int approverIdTo, DateTime pDateTime, String pRemarks)
        {
            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();
                string query = "execute dbo.Swap_Approvers @0, @1, @2, @3,@4,@5,@6";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = requestId },
                    new SqlParameter { ParameterName = "@1", Value = currentApproverId },
                    new SqlParameter { ParameterName = "@2", Value = approverIdTo },
                    new SqlParameter { ParameterName = "@3", Value = pDateTime.YYYYMMDD() },
                    new SqlParameter { ParameterName = "@4", Value = pRemarks},
                     new SqlParameter { ParameterName = "@5", Value = guid},
                     new SqlParameter { ParameterName = "@6", Value = ReqUniqueId}
                };

                var data = ctx.Database.SqlQuery<ResponseResult>(query, args).FirstOrDefault();
                if (data.success == false) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                if (data == null)
                {
                    return ResponseResult.GetErrorObject();
                }

                if (data.success == true)
                {
                    //Get Email Data & Send emails
                    var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);

                    FillEmailTemplatesAndProcess(emailRequests);
                }

                return data;
            }
        }

        public int UpdateItems(CustomUpdateItems Items)
        {

            using (var db = new PRMDataContext())
            {
                for (var j = 0; j < Items.ItemID.Length; j++)
                {
                    var query1 = "execute dbo.getItemQuantityFromItemsTable @0";
                    var args1 = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.ItemID[j] },};
                    var b = db.Database.SqlQuery<int>(query1, args1).FirstOrDefault();
                    if (b < Items.ItemQtyIssued[j])
                    {
                        return 0;
                    }


                }
                for (int i = 0; i < Items.ItemID.Length; i++)
                {
                    var query = "execute dbo.UpdateItemsinMainItemsForm @0, @1";
                    var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.ItemQtyIssued[i] },
                    new SqlParameter { ParameterName = "@1", Value = Items.ItemID[i]} };
                    db.Database.ExecuteSqlCommand(query, args);
                }
                return 1;
            }
        }

        public void UpdateIssuedQty(CustomUpdateIssuedQty Items)
        {
            var requestId = Items.request.RequestID;
            for (int i = 0; i < Items.DemandId.Length; i++)
            {
                using (var db = new PRMDataContext())
                {
                    var query = "execute dbo.UpdateDemandFormIssuedQty @0, @1, @2";
                    var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value =Items.isssuedQty[i] },
                    new SqlParameter { ParameterName = "@1", Value = Items.DemandId[i]},
                    new SqlParameter { ParameterName = "@2", Value = Items.request.CategoryID}
                    };
                    db.Database.ExecuteSqlCommand(query, args);
                    db.SaveChanges();
                }

            }
        }

        #region Apps

        public List<PendingRequestsForNotification> GetPendingRequestsForNotifications()
        {
            try
            {
                using (var ctx = new PRMDataContext())
                {
                    String guid = Guid.NewGuid().ToString();
                    string query = "execute dbo.GetPendingRequestsForNotifications ";
                    var args = new DbParameter[] {
                    
                };

                    return ctx.Database.SqlQuery<PendingRequestsForNotification>(query, args).ToList();

                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        #endregion

        public long SaveGmailLoginRequest(String pEmail, String pName, String pGmail_Id, String pGmail_Pic, DateTime pCreatedOn)
        {
            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();
                string query = "execute dbo.SaveGmailLoginRequest @0,@1,@2,@3,@4,@5";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pEmail},
                    new SqlParameter { ParameterName = "@1", Value = pName},
                    new SqlParameter { ParameterName = "@2", Value = pGmail_Id},
                    new SqlParameter { ParameterName = "@3", Value = pGmail_Pic},
                    new SqlParameter { ParameterName = "@4", Value = pCreatedOn},
                    new SqlParameter { ParameterName = "@5", Value = guid},
                };

                var data = ctx.Database.SqlQuery<long>(query, args).FirstOrDefault();

                //Get Email Data & Send emails
                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);
                FillEmailTemplatesAndProcess(emailRequests);

                //ProcessEmails(emailRequests);

                return data;
            }
        }
        public int CreateUserFromGmailRequest(String pEmail, int pRoleId, DateTime pCreatedOn)
        {
            using (var ctx = new PRMDataContext())
            {
                String guid = Guid.NewGuid().ToString();
                string query = "execute dbo.CreateUserFromGmailRequest @0,@1,@2,@3";
                var args = new DbParameter[] {
                    new SqlParameter { ParameterName = "@0", Value = pEmail},
                    new SqlParameter { ParameterName = "@1", Value = pRoleId},
                    new SqlParameter { ParameterName = "@2", Value = pCreatedOn},
                    new SqlParameter { ParameterName = "@3", Value = guid},
                };

                var data = ctx.Database.SqlQuery<int>(query, args).FirstOrDefault();

                //Get Email Data & Send emails
                var emailRequests = GetEmailRequestsByUniqueID(ctx, guid);
                FillEmailTemplatesAndProcess(emailRequests);
                return data;
            }
        }
        public GoogleUserSearchResult SearchGoogleLoginRequests(UserSearchParam entity)
        {
            using (var ctx = new PRMDataContext())
            {
                GoogleUserSearchResult result = new Entities.DBEntities.GoogleUserSearchResult();

                string query = "execute dbo.SearchGoogleLoginRequests @0, @1, @2,@3";

                var cmd = ctx.Database.Connection.CreateCommand();
                cmd.CommandText = query;

                cmd.Parameters.Add(new SqlParameter { ParameterName = "@0", Value = entity.TextToSearch });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@1", Value = entity.IsActive });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@2", Value = entity.PageSize });
                cmd.Parameters.Add(new SqlParameter { ParameterName = "@3", Value = entity.PageIndex });

                ctx.Database.Connection.Open();
                var reader = cmd.ExecuteReader();

                result.ResultCount = ((IObjectContextAdapter)ctx)
                   .ObjectContext
                   .Translate<int>(reader).FirstOrDefault();

                reader.NextResult();
                result.Result = ((IObjectContextAdapter)ctx)
                                .ObjectContext
                                .Translate<GoogleUserSearchResultObj>(reader).ToList();

                foreach (var d in result.Result)
                {
                    d.EntryTime = d.EntryTime.ToTimeZoneTime(tzi);
                    if (d.IsUsed)
                        d.UserCreatedOn = d.UserCreatedOn.ToTimeZoneTime(tzi);
                }

                return result;
            }
        }
    }
}
