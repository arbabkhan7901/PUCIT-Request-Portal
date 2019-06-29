using System.Linq;
using System.Web;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using System;
using PUCIT.AIMRL.PRM.UI.Common;
using System.Collections.Generic;
using System.IO;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.PRM.Entities.Enum;
using System.Net.Http;

namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class FormDataRepository
    {
        private PRMDataService _dataService;
        public FormDataRepository()
        {

        }

        private PRMDataService DataService
        {
            get
            {
                if (_dataService == null)
                    _dataService = new PRMDataService();

                return _dataService;
            }
        }
        public ResponseResult SaveClearanceForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {

                CustomClearanceForm clearance = new CustomClearanceForm();

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Photograph"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        clearance.Photograph.FileName = SaveFile(file);
                    }
                }

                clearance.request.Reason = HttpContext.Current.Request["Reason"];
                clearance.request.RollNo = SessionManager.GetUserLogin();
                clearance.request.UserId = SessionManager.GetLoggedInUserId();
                clearance.request.CreationDate = DateTime.UtcNow;
                clearance.request.TargetDate = DateTime.UtcNow;
                clearance.request.RequestStatus = 2;
                clearance.request.CategoryID = 1;
                clearance.request.ReqUniqueId = Guid.NewGuid().ToString();

                clearance.Photograph.UploadDate = DateTime.UtcNow;
                clearance.Photograph.AttachmentTypeID = 8;

                clearance.clearanceFormData.LibraryID = HttpContext.Current.Request["libraryID"];
                //requestData.RollNo = SessionManager.GetUserLogin();
                //requestData.UserId = SessionManager.GetLoggedInUserId();
                //requestData.CreationDate = DateTime.UtcNow;
                //requestData.RequestStatus = 2;


                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.CLEARANCE_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                var id = DataService.SaveClearanceForm(clearance);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult getInstructions()
        {
            try
            {

                List<FormCategories> details = DataService.getInstructions();

                return ResponseResult.GetSuccessObject(details, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveGeneralRequest()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }

            var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.GENERAL_REQUEST_FORM, SessionManager.GetLoggedInUserId());

            if (verifResult != null) //It means there is already an application of same type in pending state.
                return verifResult;

            customGeneralRequest general_request = new customGeneralRequest();
            try
            {
                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Attachment1"];
                    if (file != null)
                    {
                        general_request.attach1.FileName = SaveFile(file);

                    }
                    file = HttpContext.Current.Request.Files["Attachment2"];
                    if (file != null)
                    {
                        general_request.attach2.FileName = SaveFile(file);
                    }
                }

                general_request.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["semester"]);
                //general_request.request.Section = HttpContext.Current.Request["section"];
                general_request.request.Subject = HttpContext.Current.Request["subject"];
                general_request.request.Reason = HttpContext.Current.Request["Reason"];
                general_request.request.RollNo = SessionManager.GetUserLogin();
                general_request.type1.typeName = HttpContext.Current.Request["A1_type"];
                general_request.type2.typeName = HttpContext.Current.Request["A2_type"];


                general_request.request.UserId = SessionManager.GetLoggedInUserId();

                general_request.request.RequestStatus = 2;
                general_request.request.CategoryID = 13;
                general_request.request.CreationDate = DateTime.UtcNow;
                general_request.request.TargetDate = DateTime.UtcNow;
                general_request.attach1.UploadDate = DateTime.UtcNow;
                general_request.attach2.UploadDate = DateTime.UtcNow;


                var id = DataService.Savegeneral(general_request);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveLeaveForm(CustomLeaveApplication leaveData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.LEAVE_APPLICATION_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;
                    
                leaveData.request.RollNo = SessionManager.GetUserLogin();
                leaveData.request.UserId = SessionManager.GetLoggedInUserId();
                leaveData.request.CreationDate = DateTime.UtcNow;
                leaveData.request.TargetDate = DateTime.UtcNow;
                leaveData.request.RequestStatus = 2;
                var id = DataService.SaveLeaveForm(leaveData);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        private string SaveFile(HttpPostedFile file)
        {
            try
            {
                var ext = Path.GetExtension(file.FileName);
                //Generate a unique name using Guid
                var uniqueName = Guid.NewGuid().ToString() + ext;
                //Get physical path of our folder where we want to save images
                var rootPath = HttpContext.Current.Server.MapPath("~/UploadedFiles");

                var fileSavePath = System.IO.Path.Combine(rootPath, uniqueName);
                // Save the uploaded file to "UploadedFiles" folder
                file.SaveAs(fileSavePath);

                return uniqueName;
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return "";
            }
        }
        public ResponseResult SaveBScForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            CustomBscApplication BScObj = new CustomBscApplication();
            try
            {

                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.OPTION_FOR_BSc_DEGREE, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["FatherCNIC"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        BScObj.FatherCNIC.FileName = SaveFile(file);
                    }

                    file = HttpContext.Current.Request.Files["ApplicationCNIC"];
                    if (file != null)
                    {
                        //STR2 = SaveFile(file);
                        BScObj.AppLicantCNIC.FileName = SaveFile(file);

                    }
                }

                BScObj.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["SemesterNo"]);
                BScObj.bsc.CNIC = HttpContext.Current.Request["CNIC"];
                //BScObj.request.FatherName = HttpContext.Current.Request["fname"];
                BScObj.bsc.PUreg = HttpContext.Current.Request["PUreg"];
                BScObj.bsc.dateOfBirth =DateTime.ParseExact(HttpContext.Current.Request["DOB"],"mm-dd-yyyy",null);
                BScObj.request.Reason = HttpContext.Current.Request["Reason"];
                BScObj.FatherCNIC.AttachmentTypeID = 10;
                BScObj.AppLicantCNIC.AttachmentTypeID = 5;
                BScObj.request.RollNo = SessionManager.GetUserLogin();

                //BScObj.request.RollNo = SessionManager.GetUserLogin();
                BScObj.request.UserId = SessionManager.GetLoggedInUserId();

                BScObj.request.RequestStatus = 2;
                BScObj.request.CategoryID = 3;
                BScObj.request.CreationDate = DateTime.UtcNow;
                BScObj.request.TargetDate = DateTime.UtcNow;
                BScObj.FatherCNIC.UploadDate = DateTime.UtcNow;
                BScObj.AppLicantCNIC.UploadDate = DateTime.UtcNow;
                BScObj.bsc.fathersign = "Marked";

                var id = DataService.SaveBScForm(BScObj);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }
        public ResponseResult SaveFinalAcadTrans()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            CustomFinalAcad Final = new CustomFinalAcad();
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.FINAL_ACADAEMIC_TRANSCRIPT_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;


                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["ClearanceCopy"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        Final.ClearanceFrom.FileName = SaveFile(file);
                    }
                }
                Final.finalTranscript.PUreg = HttpContext.Current.Request["PUreg"];
                Final.finalTranscript.FYPtitle = HttpContext.Current.Request["FYPTitle"];
                Final.request.Reason = HttpContext.Current.Request["Reason"];
                Final.ClearanceFrom.AttachmentTypeID = 6;
                //Final.request.FatherName = HttpContext.Current.Request["fname"];
                Final.request.RollNo = SessionManager.GetUserLogin();

                Final.request.UserId = SessionManager.CurrentUser.UserId;
                Final.request.RequestStatus = 2;
                Final.request.CategoryID = 4;
                Final.request.CreationDate = DateTime.UtcNow;
                Final.request.TargetDate = DateTime.UtcNow;
                Final.ClearanceFrom.UploadDate = DateTime.UtcNow;
                var id = DataService.SaveFinalAcadTrans(Final);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }
        public ResponseResult SaveIdCardForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            CustomCollegeIDCard IDCard = new CustomCollegeIDCard();
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.COLLEGE_IDCARD_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Challan"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        IDCard.Challan.FileName = SaveFile(file);
                    }
                }

                IDCard.request.Reason = HttpContext.Current.Request["Reason"];
                IDCard.request.TargetDate = DateTime.UtcNow;
                IDCard.request.RollNo = SessionManager.GetUserLogin();
                IDCard.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["SemesterNo"]);
                IDCard.request.UserId = SessionManager.CurrentUser.UserId;
                IDCard.request.RequestStatus = 2;
                IDCard.request.CategoryID = 5;
                IDCard.request.CreationDate = DateTime.UtcNow;

                IDCard.IDCard.ChallanForm = HttpContext.Current.Request["ChallanNO"];

                IDCard.Challan.UploadDate = DateTime.UtcNow;
                IDCard.Challan.AttachmentTypeID = 2;


                var id = DataService.SaveIdCardForm(IDCard);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }
        public ResponseResult SaveVehicalTokenForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            CustomVehicalTokenData VehicalToken = new CustomVehicalTokenData();
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.MOTORCYCLE_TOKEN_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Photo"];
                    if (file != null)
                    {
                        VehicalToken.Photo.FileName = SaveFile(file);
                    }
                    file = HttpContext.Current.Request.Files["Reg"];
                    if (file != null)
                    {
                        VehicalToken.Registration.FileName = SaveFile(file);
                    }
                    file = HttpContext.Current.Request.Files["IdCard"];
                    if (file != null)
                    {
                        VehicalToken.IDCard.FileName = SaveFile(file);
                    }
                }

                VehicalToken.request.Reason = HttpContext.Current.Request["Reason"];
                VehicalToken.request.RollNo = SessionManager.GetUserLogin();
                VehicalToken.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["SemesterNo"]);
                //VehicalToken.request.Section = HttpContext.Current.Request["section"];

                VehicalToken.Photo.AttachmentTypeID = 8;
                VehicalToken.IDCard.AttachmentTypeID = 1;
                VehicalToken.Registration.AttachmentTypeID = 7;

                VehicalToken.vehical.Model = HttpContext.Current.Request["Model"];
                VehicalToken.vehical.VehicalRegNo = HttpContext.Current.Request["regNum"];
                VehicalToken.vehical.manufacturer = HttpContext.Current.Request["Manufacturer"];
                VehicalToken.vehical.ownerName = HttpContext.Current.Request["owner"];

                VehicalToken.request.UserId = SessionManager.GetLoggedInUserId();
                VehicalToken.request.RequestStatus = 2;
                VehicalToken.request.CategoryID = 6;
                VehicalToken.request.CreationDate = DateTime.UtcNow;
                VehicalToken.request.TargetDate = DateTime.UtcNow;
                VehicalToken.Photo.UploadDate = DateTime.UtcNow;
                VehicalToken.IDCard.UploadDate = DateTime.UtcNow;
                VehicalToken.Registration.UploadDate = DateTime.UtcNow;

                var id = DataService.SaveVehicalTokenForm(VehicalToken);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }
        public ResponseResult receiptOfOriginal()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            customReceiptOfOrignalDocument doc = new customReceiptOfOrignalDocument();
            var isClearanceDone = DataService.ClearanceFormCreatedOrNot(SessionManager.CurrentUser.UserId);
            if (isClearanceDone.status == 2) {
                bool pendingFlag = true;
                return ResponseResult.GetErrorObject("Your Clearance is not completed yet!", pendingFlag);
            }
            if (isClearanceDone.status == 3) {
                ApplicationViewRepository app = new ApplicationViewRepository();
                var pdf_attach = (HttpResponseMessage)app.GenerateReqeuestPDF(isClearanceDone.clearanceReqId,isClearanceDone.clearanceUniqueReqId,true);
                
                //File Move from one folder to another
                String fileName = pdf_attach.Content.Headers.ContentDisposition.FileName;
                String srcFolder = HttpContext.Current.Server.MapPath("~/TempFiles");
                String srcFile = System.IO.Path.Combine(srcFolder, fileName);
                String destFolder = HttpContext.Current.Server.MapPath("~/UploadedFiles");
                String destFile = System.IO.Path.Combine(destFolder, fileName);
                System.IO.File.Move(srcFile, destFile);

                doc.ClearanceForm.FileName = fileName;
                doc.ClearanceForm.AttachmentTypeID = 6;
                doc.ClearanceForm.UploadDate = DateTime.UtcNow;
            }
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.RECEIPT_OF_ORIG_EDU_DOCS_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {

                    HttpPostedFile file = HttpContext.Current.Request.Files["clearanceForm"];
                    if (isClearanceDone.status == 0 && file != null)
                    {
                        doc.ClearanceForm.FileName = SaveFile(file);
                        doc.ClearanceForm.AttachmentTypeID = 6;
                        doc.ClearanceForm.UploadDate = DateTime.UtcNow;
                    }
                    else if (isClearanceDone.status == 0 && file == null) {
                        return ResponseResult.GetErrorObject("You can't create this application");
                    }
                    file = HttpContext.Current.Request.Files["idCard"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        doc.IDCard.FileName = SaveFile(file);
                    }
                }
                doc.request.RequestStatus = 2;
                doc.request.Reason = HttpContext.Current.Request["Reason"];
                doc.IDCard.AttachmentTypeID = 1;
                doc.request.RollNo = SessionManager.GetUserLogin();
                //doc.request.Section = HttpContext.Current.Request["section"];
                //doc.request.FatherName = HttpContext.Current.Request["fname"];
                doc.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["SemesterNo"]);
                doc.request.CategoryID = 7;

                doc.request.UserId = SessionManager.CurrentUser.UserId;
                doc.request.CreationDate = DateTime.UtcNow;
                doc.request.TargetDate = DateTime.UtcNow;
                doc.IDCard.UploadDate = DateTime.UtcNow;
                String list = HttpContext.Current.Request["document"];
                String[] list_name = list.Split(',');
                foreach (var name in list_name)
                {
                    ReceiptOfOrignalEducationalDocuments documentObj = new ReceiptOfOrignalEducationalDocuments();
                    documentObj.DocumentName = name + "";
                    doc.documents.Add(documentObj);
                }
                var id = DataService.receiptOfOriginal(doc);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveBonafideForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            customBonafide Certificate = new customBonafide();
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.BONAFIDE_CHARACTER_CERTIFICATE_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["ChallanCopy"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        Certificate.challan.FileName = SaveFile(file);
                    }
                }
                Certificate.request.RequestStatus = 2;
                Certificate.request.Reason = HttpContext.Current.Request["Reason"];
                Certificate.challan.AttachmentTypeID = 2;
                Certificate.request.RollNo = SessionManager.GetUserLogin();
                Certificate.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["SemesterNo"]);
                Certificate.bonafide.CGPA = Convert.ToDouble(HttpContext.Current.Request["CGPA"]);
                Certificate.bonafide.PUreg = HttpContext.Current.Request["PUreg"];
                Certificate.bonafide.ChallanForm = HttpContext.Current.Request["Challan"];
                //Certificate.request.FatherName = HttpContext.Current.Request["fname"];

                Certificate.request.UserId = SessionManager.CurrentUser.UserId;
                Certificate.request.CategoryID = 8;
                Certificate.request.CreationDate = DateTime.UtcNow;
                Certificate.request.TargetDate = DateTime.UtcNow;
                Certificate.challan.UploadDate = DateTime.UtcNow;

                var id = DataService.SaveBonafideForm(Certificate);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveSemesterFreezeForm(RequestMainData request)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.SEMESTER_FREEZE_WITHDRAWAL_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                request.RollNo = SessionManager.GetUserLogin();
                request.UserId = SessionManager.GetLoggedInUserId();
                request.CreationDate = DateTime.UtcNow;
                request.RequestStatus = 2;

                request.TargetDate = DateTime.UtcNow;

                var id = DataService.SaveApplicationRequest(request);

                //var id = DataService.SaveSemesterFreezeForm(request);
                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveSemesterRejoinForm(RequestMainData request)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.SEMESTER_REJOIN_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                request.RollNo = SessionManager.GetUserLogin();
                request.UserId = SessionManager.GetLoggedInUserId();
                request.CreationDate = DateTime.UtcNow;
                request.TargetDate = DateTime.UtcNow;
                request.RequestStatus = 2;

                var id = DataService.SaveApplicationRequest(request);


                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();

            }
        }
        public ResponseResult SaveWithDraw(customCourseWithdraw course_with)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");

            }
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.COURSE_WITHDRAWAL_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                course_with.request.RollNo = SessionManager.GetUserLogin();
                course_with.request.UserId = SessionManager.GetLoggedInUserId();
                course_with.request.CreationDate = DateTime.UtcNow;
                course_with.request.TargetDate = DateTime.UtcNow;
                course_with.request.RequestStatus = 2;
                var id = DataService.SaveWithDraw(course_with);
                return ResponseResult.GetSuccessObject(id, "");

            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveSemesterAcadTranscriptForm()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");

            }
            customSemesterAcademic transcript = new customSemesterAcademic();
            try
            {
                var verifResult = this.ValidateUserRequestCreationState(ApplicationCategoryEnum.SEMESTER_ACADAEMIC_TRANSCRIPT_FORM, SessionManager.GetLoggedInUserId());

                if (verifResult != null) //It means there is already an application of same type in pending state.
                    return verifResult;

                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["ChallanCopy"];
                    if (file != null)
                    {
                        //STR = SaveFile(file);
                        transcript.challan.FileName = SaveFile(file);
                    }
                }

                transcript.request.Reason = HttpContext.Current.Request["Reason"];
                transcript.challan.AttachmentTypeID = 2;
                transcript.request.RollNo = SessionManager.GetUserLogin();
                transcript.semesterAcad.ChallanNo = HttpContext.Current.Request["Challan"];
                transcript.request.CurrentSemester = Convert.ToInt32(HttpContext.Current.Request["current"]);
                //transcript.request.FatherName = HttpContext.Current.Request["fname"];
                //transcript.request.Section = HttpContext.Current.Request["section"];
                transcript.request.TargetSemester = Convert.ToInt32(HttpContext.Current.Request["targetSemester"]);

                transcript.request.UserId = SessionManager.CurrentUser.UserId;
                transcript.request.RequestStatus = 2;
                transcript.request.CategoryID = 11;
                transcript.request.CreationDate = DateTime.UtcNow;
                transcript.request.TargetDate = DateTime.UtcNow;
                transcript.challan.UploadDate = DateTime.UtcNow;
                var id = DataService.SaveSemesterAcadTranscriptForm(transcript);

                return ResponseResult.GetSuccessObject(id, "");

            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
      public ResponseResult SaveRoomReservationForm(CustomRoomReservation roomRes)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                roomRes.request.RollNo = SessionManager.GetUserLogin();
                roomRes.request.UserId = SessionManager.GetLoggedInUserId();
                roomRes.request.CreationDate = DateTime.UtcNow;
                roomRes.request.TargetDate = DateTime.UtcNow;
                roomRes.request.RequestStatus = 2;
                var id = DataService.SaveRoomReservation(roomRes);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveLabReservationForm(CustomLabReservationForm labReservation) {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                labReservation.request.RollNo = SessionManager.GetUserLogin();
                labReservation.request.UserId = SessionManager.GetLoggedInUserId();
                labReservation.request.CreationDate = DateTime.UtcNow;
                labReservation.request.TargetDate = DateTime.UtcNow;
                labReservation.request.RequestStatus = 2;
                
                var id = DataService.SaveLabReservationForm(labReservation);

                return ResponseResult.GetSuccessObject(id, "Form Submitted Successfully");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UploadSignature()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (!PermissionManager.perCanProvideSignature)
                {
                    return ResponseResult.GetErrorObject("Unauthorized activity");
                }

                string attachment = "";
                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Signature"];
                    if (file != null)
                    {
                        attachment = SaveFile(file);
                        if (!String.IsNullOrEmpty(attachment))
                        {
                            SessionManager.CurrentUser.SignatureName = attachment;
                        }
                    }
                }

                var upload = DataService.UploadSignature(SessionManager.CurrentUser.UserId, attachment);
                var data = new {
                    id = upload
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }


        public ResponseResult UploadAttachment()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                //if (!PermissionManager.perCanProvideSignature)
                //{
                //    return (new
                //    {
                //        success = false,
                //        error = "Unauthorized activity"
                //    });
                //}

                string attachment = "";
                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Attachment"];
                    if (file != null)
                    {
                        attachment = SaveFile(file);
                    }
                }

                var appid = Convert.ToInt32(HttpContext.Current.Request["AppId"]);
                var fileName = HttpContext.Current.Request["Name"];
                String ReqUniqueId = HttpContext.Current.Request["ReqUniqueId"];
                var upload = DataService.SaveAttachment(appid, ReqUniqueId, fileName, attachment, DateTime.UtcNow, SessionManager.CurrentUser.UserId);

                if (upload == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    id = upload
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult RemoveAttachment()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                //if (!PermissionManager.perCanProvideSignature)
                //{
                //    return (new
                //    {
                //        success = false,
                //        error = "Unauthorized activity"
                //    });
                //}

                string attachment = HttpContext.Current.Request["Attachment"];
                var appid = Convert.ToInt32(HttpContext.Current.Request["AppId"]);
                String ReqUniqueId = HttpContext.Current.Request["ReqUniqueId"];
                var remove = DataService.RemoveAttachment(appid, ReqUniqueId, attachment, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (remove == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    id = remove
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult getItemsName()
        {
            var itemName = DataService.getItemsName();
            return ResponseResult.GetSuccessObject(itemName, "");
        }

        public ResponseResult getHardwareItemsName()
        {
            var hwItemName = DataService.getHardwareItemsName();
            return ResponseResult.GetSuccessObject(hwItemName, "");
        }

        public ResponseResult SaveHardwareForm(CustomHardwareForm requestData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                requestData.request.RollNo = SessionManager.GetUserLogin();
                requestData.request.UserId = SessionManager.GetLoggedInUserId();
                requestData.request.CreationDate = DateTime.UtcNow;
                requestData.request.TargetDate = DateTime.UtcNow;
                requestData.request.RequestStatus = 2;
                var id = DataService.SaveHardwareForm(requestData);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SaveStoreDemandVoucher(CustomStoreDemandVoucher requestData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                requestData.request.RollNo = SessionManager.GetUserLogin();
                requestData.request.UserId = SessionManager.GetLoggedInUserId();
                requestData.request.CreationDate = DateTime.UtcNow;
                requestData.request.TargetDate = DateTime.UtcNow;
                requestData.request.RequestStatus = 2;
                var id = DataService.SaveStoreDemandVoucher(requestData);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult SaveDemandVoucher(CustomDemandVoucher requestData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                requestData.request.RollNo = SessionManager.GetUserLogin();
                requestData.request.UserId = SessionManager.GetLoggedInUserId();
                requestData.request.CreationDate = DateTime.UtcNow;
                requestData.request.TargetDate = DateTime.UtcNow;
                requestData.request.RequestStatus = 2;
                var id = DataService.SaveDemandVoucher(requestData);

                return ResponseResult.GetSuccessObject(id, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult SaveDemandForm(CustomDemandForm requestData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                requestData.request.RollNo = SessionManager.GetUserLogin();
                requestData.request.UserId = SessionManager.GetLoggedInUserId();
                requestData.request.CreationDate = DateTime.UtcNow;
                requestData.request.TargetDate = DateTime.UtcNow;
                requestData.request.RequestStatus = 2;
                var id = DataService.SaveDemandForm(requestData);

                return ResponseResult.GetSuccessObject(id, "");

            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult FillDropDown()
        {
            try
            {
                int UserID = SessionManager.GetLoggedInUserId();
                List<FormCategories> details = DataService.FillDropDown(UserID,0);

                return ResponseResult.GetSuccessObject(details, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UpdateAttachment()
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                //if (!PermissionManager.perCanProvideSignature)
                //{
                //    return (new
                //    {
                //        success = false,
                //        error = "Unauthorized activity"
                //    });
                //}

                string attachment = "";
                if (HttpContext.Current.Request.Files.Count > 0)
                {
                    HttpPostedFile file = HttpContext.Current.Request.Files["Attachment"];
                    if (file != null)
                    {
                        attachment = SaveFile(file);
                    }
                }

                var appid = Convert.ToInt32(HttpContext.Current.Request["AppId"]);
                var oldAttachment = HttpContext.Current.Request["OldAttachment"];
                String ReqUniqueId = HttpContext.Current.Request["ReqUniqueId"];
                var update = DataService.UpdateAttachment(appid, ReqUniqueId, attachment, DateTime.UtcNow, SessionManager.CurrentUser.UserId, oldAttachment);
                if (update == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    id = update
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        private ResponseResult ValidateUserRequestCreationState(ApplicationCategoryEnum pFormID, int pUserID)
        {
            if (DataService.GetPendingRequestsCountByCategoryID_UserID((int)pFormID, pUserID) <= 0)
            {
                return ResponseResult.GetErrorObject("Request is not created. You already have application/s of same type in pending state.");
            }
            else
                return null;
        }
        public ResponseResult SearchContributor(string key)
        {
            try
            {
                var list = DataService.SearchContributor(key);

                var result = (from p in list
                              select new
                              {
                                  ID = p.ApproverID,
                                  NME = p.Name,
                                  Desg = p.Designation
                              }).ToList();
                return ResponseResult.GetSuccessObject(result, ""); ;
            }
            catch (Exception ex)
            {
                return ResponseResult.GetErrorObject();
            }
        }
    }
}