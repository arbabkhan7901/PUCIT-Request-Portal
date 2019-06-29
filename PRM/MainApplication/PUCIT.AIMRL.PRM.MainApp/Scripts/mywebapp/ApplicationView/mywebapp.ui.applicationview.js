
﻿MyWebApp.namespace("UI.ApplicationView");

MyWebApp.UI.ApplicationView = (function () {
    "use strict";
    var _isInitialized = false;
    var formData;
    var applicationId;
    var applicationUniqueId;
    var mainAutocompleteObj1;
    var rollNum;
    var appStatus = "";
    var contributorsList = [];
    var isLogLoaded = false;
    var areContributorsLoaded = false;
    var _changeMadeInManageContrPopup = false;

    //test
    function initialisePage() {
        ////debugger;
        if (_isInitialized == false) {
            _isInitialized = true;
            applicationId = $("#ApplicationId").text();
            applicationUniqueId = $("#ApplicationUniqueId").text();
            BindEvents();
            getFormData();
            getLogList();
            getContributors();

            mainAutocompleteObj1 = new JQUIAutoCompleteWrapper({
                inputSelector: "#search",
                dataSource: "ApplicationView/SearchContributor",
                queryString: "",
                listItemClass: ".listitem",
                searchParameterName: "key",
                maxItemsToDisplay: "1",
                minCharsToTypeForSearch: "2",
                watermark: "Type Name/Designation",
                dropdownHTML: "<a><table><tr><td>Desg (NME)</td></tr></table></a>",
                fields: {
                    ValueField: 'ID', DisplayField: 'Desg', DescriptionField: 'NME'
                },
                enableCache: false,
                onClear: function () {

                }
               , displayTextFormat: "NME(Desg)"
               , itemOnClick: function (item) {

                   var textToDisplay = item.Desg + ' (' + item.NME + ')';
                   var workflowEntry = {
                       ApproverID: item.ID,
                       Designation: item.Desg,
                       Name: item.NME,
                       WorkFlowStatus: 1
                   };

                   if (confirm("Do you want to add " + textToDisplay + " in this workflow?")) {
                       AddContributorInWorkFlow(workflowEntry.ApproverID, function (wfid) {
                           _changeMadeInManageContrPopup = true;
                           workflowEntry.WFID = wfid;
                           var obj = {};
                           obj.ContributorList = [];
                           obj.ContributorList.push(workflowEntry);
                           DisplayContributorsInAddContrPopup(obj, true);
                           MyWebApp.UI.showRoasterMessage("Contributor has been added", Enums.MessageType.Success);
                       });
                   }
               }
            });

            mainAutocompleteObj1.InitializeControl();
        }
    }

    function BindEvents() {
        //Approve Popup
        $("#approve").click(function (e) {
            e.preventDefault();
            $(".popuptitler").text("Approve the Request");
            $("span#spSubmit").text("Approve");
            $("#divCustomPopup").attr("type", "AP");
            $("#divCheckboxes").hide();

            $('#divCustomPopup').modal('show');
            return false;
        });

        //Reject Popup
        $("#reject").click(function (e) {
            e.preventDefault();

            $(".popuptitler").text("Reject the Request");
            $("span#spSubmit").text("Reject");
            $("#divCustomPopup").attr("type", "RJ");
            $("#divCheckboxes").hide();

            $('#divCustomPopup').modal('show');
            //$.bsmodal.show("#divCustomPopup");

        });


        $("#PrintButton").click(function () {
            downloadApplication();
        });

        $("#remarks").click(function () {
            $(".popuptitler").text("Remarks");
            $("span#spSubmit").text("Save");
            $("#txtCustomPopupRemarks").attr("placeholder", "Give your remarks here");
            $("#divCustomPopup").attr("type", "RM");
            $("#divCheckboxes").show();

            $('#divCustomPopup').modal('show');

            //$.bsmodal.show("#divCustomPopup", { top: "5%" });
        });

        $("#review").click(function () {            
            if (isValidforReview()) {
                $(".popuptitler").text("Review");
                $("span#spSubmit").text("Save");
                $("#txtCustomPopupRemarks").attr("placeholder", "Give your review here");
                $("#divCustomPopup").attr("type", "CR");
                $("#divCheckboxes").hide();

                $('#divCustomPopup').modal('show');
            }
            else
                MyWebApp.UI.showRoasterMessage("you can not ask for review now!", Enums.MessageType.Warning);

            //$.bsmodal.show("#divCustomPopup", { top: "5%" });
        });

        //Recieving Modal Handling
        $("#btnRecieve").click(function (e) {
            e.preventDefault();

            $(".popuptitler").text("Recieving");
            $("span#spSubmit").text("Confirm Recieving");
            $("#divCustomPopup").attr("type", "HC");
            $("#divCheckboxes").hide();

            $('#divCustomPopup').modal('show');

            //$.bsmodal.show("#divCustomPopup");
            return false;
        });

        //End

        $('#contributorModal').on('hidden.bs.modal', function () {
            if (_changeMadeInManageContrPopup) {
                MyWebApp.UI.ShowLastMsgAndRefresh('Going to reload the page');
            }
        })

        $("#addContributor").click(function () {
            _changeMadeInManageContrPopup = false;
            $("#saveButton").hide();
            mainAutocompleteObj1.ClearSelectedItems();

            DisplayContributorsInAddContrPopup({ ContributorList: contributorsList }, false);

            $('#contributorModal').modal('show');

            //$.bsmodal.show("#contributorModal", { top: "5%", left: "5%", closeid: "#contributorModalClose,#CancelButton" });
            return false;
        });

        $("#btnSwapRequest").click(function () {

            $("#cmbContributorToSwapWith").val('0');
            $('#swapContributorModal').modal('show');

            return false;
        });

        $("#saveSwapButton").click(function () {
            //debugger;
            var aid = $("#cmbContributorToSwapWith").val();
            if (aid <= 0) {
                MyWebApp.UI.showRoasterMessage('Approver is not selected for swap.', Enums.MessageType.Error);
                return false;
            }
            var remarks = $("#txtCustomPopupRemarksForSwapCase").val().trim();
            if (remarks == "") {
                MyWebApp.UI.showRoasterMessage('Remarks are required', Enums.MessageType.Error);
                return false;
            }

            var RequestData = {
                RequestID: applicationId,
                ReqUniqueId : applicationUniqueId,
                ToApproverID: aid,
                Remarks: remarks
            };

            var url = "ApplicationView/SwapContributor";
            var dataToSend = JSON.stringify(RequestData);

            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success === true) {
                    MyWebApp.UI.ShowLastMsgAndRefresh(result.error);
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
            });


            return false;
        });

        $("#saveButton").click(function () {
            //$.bsmodal.hide("#contributorModal");
            $('#contributorModal').modal('hide');

            UpdateContributorsOrder(function () {
                MyWebApp.UI.ShowLastMsgAndRefresh('Changes are saved, reloading the page.');
            });

            //insertNewFlow();
        });

        $("#btnAddMessage").unbind("click").bind("click", function () {
            var msg = $("#txtConvMessage").val().trim();
            if (msg == "") {
                MyWebApp.UI.showRoasterMessage("Please add Message", Enums.MessageType.Warning);
                return false;
            }
            SaveConversation(msg);
            $("#txtConvMessage").val("");
            return false;
        });
        $("#btnCloseConvPopup").unbind("click").bind("click", function () {
            $('#divConvPopup').modal('hide');

            //$.bsmodal.hide("#divConvPopup");
            return false;
        });
        /* END Conversations Handling */


        $("#lnkAddAttachment").unbind("click").bind("click", function (e) {
            e.preventDefault();
            ClearUploadPopup();
            $('#divFileUploadPopup').modal('show');

            //$.bsmodal.show("#divFileUploadPopup");
            return false;
        });

        $("#btnUploadFile").unbind("click").bind("click", function (e) {
            e.preventDefault();

            var fname = $("#divFileUploadPopup").attr("fname");
            if (fname) {
                UpdateAttachment(fname);
            }
            else {
                UploadAttachment();
            }

            $('#divFileUploadPopup').modal('hide');

            //$.bsmodal.hide("#divFileUploadPopup");

            return false;
        });

        $("#btnCloseFileUploadPopup").unbind("click").bind("click", function (e) {
            e.preventDefault();
            ClearUploadPopup();
            $('#divFileUploadPopup').modal('hide');

            //$.bsmodal.hide("#divFileUploadPopup");
            return false;
        });

        $("#btnEnableDisable").click(function () {

            var msg = "Enable";
            var s = $("#trEnableDisableEdit").attr("status");

            if (s == "1")
                msg = "Disable"

            $(".popuptitler").text(msg + " Attachments Changes ");
            $("span#spSubmit").text("Confirm");
            $("#divCustomPopup").attr("type", "ED");
            $("#divCheckboxes").hide();

            $('#divCustomPopup').modal('show');
            //$.bsmodal.show("#divCustomPopup");

            return false;
        });


        $("#btnRouteBack").click(function (e) {
            e.preventDefault();

            $(".popuptitler").text("Route Back to Previous Approver");
            $("span#spSubmit").text("Confirm");
            $("#divCustomPopup").attr("type", "RB");
            $("#divCheckboxes").hide();

            $('#divCustomPopup').modal('show');

            //$.bsmodal.show("#divCustomPopup");
        });

        $("#btnCustomModalClose").unbind("click").bind("click", function (e) {
            e.preventDefault();
            $('#divCustomPopup').modal('hide');

            //$.bsmodal.hide("#divCustomPopup");
            return false;
        });

        $("#btnSubmitCustomPopup").click(function () {

            var type = $(this).closest("#divCustomPopup").attr("type");
            var remarks = $("#txtCustomPopupRemarks").val().trim();
            var issued = [];
            var required = [];

            if (remarks == "" && type == "RM") {
                MyWebApp.UI.showRoasterMessage('Remarks are required', Enums.MessageType.Error);
                return false;
            }
            if (remarks == "" && type == "CR") {
                MyWebApp.UI.showRoasterMessage('Review is required', Enums.MessageType.Error);
                return false;
            }
            if (type == "RB") {
                RouteBack(remarks);
            }
            else if (type == "AP") {

                if (formData.StudentList.MainData.CategoryID === 15 || formData.StudentList.MainData.CategoryID === 14) {

                    if (formData.StudentList.MainData.CategoryID === 15) {
                        $("#HardwareData tbody tr").each(function () {
                            var quantity = $(this).find('.qtyiss').text();
                            issued.push(quantity);
                        });
                        debugger;
                        $("#HardwareData tbody tr").each(function () {

                            var req = $(this).find('.qtyreq').text();
                            required.push(req);
                        });
                    }

                    if (formData.StudentList.MainData.CategoryID === 14) {
                        $("#ItemData tbody tr").each(function () {
                            var quantity = $(this).find('.qtyiss').text();
                            issued.push(quantity);
                        });
                        debugger;
                        $("#ItemData tbody tr").each(function () {

                            var req = $(this).find('.qtyreq').text();
                            required.push(req);
                        });
                    }

                    for (var i = 0; i < issued.length; i++) {
                        if (issued[i] == "") {
                            MyWebApp.UI.showRoasterMessage('Please Fill All Entries of Item Issued', Enums.MessageType.Error);
                            return false;
                        }
                        var reg = new RegExp('^[0-9]+$');
                        if (!(issued[i].match(reg))) {
                            MyWebApp.UI.showRoasterMessage('Quantity can only in Numbers', Enums.MessageType.Error);
                            return false;
                        }
                    }
                    if (remarks == "") {
                        MyWebApp.UI.showRoasterMessage('Remarks are required', Enums.MessageType.Error);
                        return false;
                    }
                    for (var i = 0; i < issued.length; i++) {
                        debugger;
                        if (required[i] < Number(issued[i])) {
                            MyWebApp.UI.showRoasterMessage('Issued Quantity can not be greater than Required Quantity', Enums.MessageType.Error);
                            return false;
                        }
                    }
                    UpdateItems(remarks, issued, formData);
                }
                else {
                    ApproveRequest(remarks);
                }
                
            }
            else if (type == "RJ") {
                RejectRequest(remarks);
            }
            else if (type == "HC") {
                HandleRecieving(remarks);
            }
            else if (type == "RM") {
                SaveRemarks(remarks,type);
            }
            else if (type == "CR") {
                SaveRemarks(remarks,type);
            }
            else if (type == "ED") {
                HandleEnableDisable(remarks);
            }
            $('#divCustomPopup').modal('hide');

            //$.bsmodal.hide("#divCustomPopup");
            return false;
        });

        $("#btnUpdateCGPA").click(function (e) {
            e.preventDefault();
            UpdateCGPA();
            return false;
        });


        $(function () {
            $("#sortable").sortable({
                items: "li:not(.nondrag)",
                revert: true,
                change: function (e) {
                    //console.log('X:' + e.screenX, 'Y:' + e.screenY);
                    $("#saveButton").show();
                }
            });
        });
    }

    function hasExtension(inputID, exts) {
        var fileName = (document.getElementById(inputID).value).toLowerCase();
        //alert((new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName))
        return (new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName);
    }

    function clearAttachment(id) {
        document.getElementById(id).value = "";
    }

    function downloadApplication() {
        //debugger;
        var url = window.MyWebAppBasePath + "aapi/ApplicationView/DownloadRequestPdf/?requestId=" + applicationId + "&reqUniqueId=" + applicationUniqueId;
        window.open(url);

        //MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
        //    if (result) {
        //       // alert(result);
        //        window.open(result);
        //    } else {
        //        MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
        //    }
        //}, function (xhr, ajaxOptions, thrownError) {
        //    console.warn(xhr.responseText);
        //    MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        //});

    }

    function ClearUploadPopup() {
        $("#divFileUploadPopup").removeAttr("fname");
        $("#txtAttachmentName").val("");
        $("#txtAttachmentName").removeAttr("disabled");
    }

    function BindEventAfterDataIsLoaded() {
        /* Conversations Handling */
        $("#timeline .lnkShowConversation").unbind("click").bind("click", function () {

            var id = $(this).attr("alogid");
            getConversation(id);
            return false;
        });

        if (areContributorsLoaded == true && isLogLoaded == true) {
            ManageActionPanelInLog();
        }

    }

    //Get data to display in fields
    function getFormData() {
        //debugger;
        var url = "ApplicationView/GetFormData/?requestId=" + applicationId + "&requestUniqueId=" + applicationUniqueId;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                console.log(result);
                formData = result.data;
                if (result.data.StudentList.MainData.CanStudentEdit) {
                    $("#trEnableDisableEdit button span").text("Disable Attachments Editing");
                    $("#trEnableDisableEdit").attr("status", 1);
                }
                else {
                    $("#trEnableDisableEdit button span").text("Enable Attachments Editing");
                    $("#trEnableDisableEdit").attr("status", 0);
                }
                displayFormData(result.data);
                getAttachment();
                GetPreviousApplications(result.data.StudentList.MainData.RollNo);              
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }//End of getFormData

    function isValidforReview() {
        debugger;
        var first = new Date();
        var second = Date.parse(formData.StudentList.MainData.ActionDateStr);
        if (Math.round((first - second) / (86400000)) >= 3)
            return true;
        else
            return false;
    }

    function GetPreviousApplications(rnm) {
        //  var Roll = rollNum;
        var name = "";
        var sdate = "";
        var edate = "";
        var type = "0";
        var status = "0";

        var searchObject = {
            RollNO: rnm,
            Name: name,
            SDate: sdate,
            EDate: edate,
            Type: type,
            Status: status
        };
        var url = "ApplicationView/searchApplications";
        var Data = JSON.stringify(searchObject);
        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            
            if (result.success === true) {
                console.log(result);
                displayPreviousApplications(result.data);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function displayPreviousApplications(data) {
        //////debugger;

        MyWebApp.UI.Common.setHandlebarTemplate("#PreviousAppsTemplate", "#PreviousApplications", data);

        //$("#PreviousApplications").html("");

        //if (!data)
        //    return;

        //try {
        //    var source = $("#PreviousAppsTemplate").html();
        //    var template = Handlebars.compile(source);
        //    var html = template(data);
        //} catch (e) {
        //    //////debugger;
        //}

        //$("#PreviousApplications").append(html);
    }

    function getAttachment(flag) {
        //debugger;

        var url = "ApplicationView/GetAttachment/?requestId=" + applicationId +"&reqUniqueId="+ applicationUniqueId;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {

                displayAttachment(result.data);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }


    function displayAttachment(attachment) {

        MyWebApp.UI.Common.setHandlebarTemplate("#showAttachmentTemplate", "#attachments", attachment, false, BindEventsOnAttachmentAfterDisplay);

        //$("#attachments").html("");
        //if (!attachment) {
        //    return;
        //}
        //try {
        //    $("#AttachmentsDiv").show();
        //    var source = $("#showAttachment").html();
        //    var template = Handlebars.compile(source);
        //    var html = template(attachment);
        //} catch (e) {
        //}

        //$("#attachments").append(html);

        //BindEventsOnAttachmentAfterDisplay();

    }

    function BindEventsOnAttachmentAfterDisplay() {
        $(".attRemove").click(function (e) {

            var fname = $("#filenametobeedited").val();

            MyWebApp.Globals.ShowYesNoPopup({
                headerText: 'Remove',
                bodyText: 'Do you want to remove this Attachment?',
                dataToPass: { "fname": $("#filenametobeedited").val() },
                fnYesCallBack: function ($modalObj, dataObj) {

                    RemoveAttachment(dataObj.fname);
                    $($modalObj.selector).modal('hide');

                    //$.bsmodal.hide($modalObj.selector);
                }
            });
        });

        $(".attReplace").click(function (e) {

            var fname = $("#filenametobeedited").val();
            var attName = $(this).closest("li").find(".attachmentname").text().trim();

            MyWebApp.Globals.ShowYesNoPopup({
                headerText: 'Replace',
                bodyText: 'Do you want to replace this attachment?',
                dataToPass: { "fname": $("#filenametobeedited").val(), "attName": attName },
                fnYesCallBack: function ($modalObj, dataObj) {

                    var fname = dataObj.fname;
                    var type = dataObj.attName;

                    $("#divFileUploadPopup").attr("fname", fname);
                    $("#txtAttachmentName").val(type);
                    $("#txtAttachmentName").attr("disabled", "disabled");

                    $($modalObj.selector).modal('hide');
                    //$.bsmodal.hide($modalObj.selector);

                    $('#divFileUploadPopup').modal('show');
                    //$.bsmodal.show("#divFileUploadPopup");
                }
            });
        });
    }
    function displayDocuments(documents) {

        MyWebApp.UI.Common.setHandlebarTemplate("#showDocsListTemplate", "#DocsList", documents);

        //$("#DocsList").html("");

        //if (!documents)
        //    return;
        //try {
        //    var source = $("#showDocsListTemplate").html();
        //    var template = Handlebars.compile(source);
        //    var html = template(documents);
        //} catch (e) {
        //}


        //$("#DocsList").append(html);
    }

    function displayFormData(data) {

        //Common Data of froms
        displayOverallStatus(data.StudentList.MainData.RequestStatus);
        debugger;
        if (data.StudentList.MainData.Reason != "") {
            $("#reason_all").show();
            $("#reasonDisplay").html(data.StudentList.MainData.Reason);
            $("#reasonDisplay").show();
        }
        //Specific data of a form
        if (data.StudentList.MainData.CategoryID == 1) {
            $("#myname1").html(data.StudentName);
            $("#rollno1").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo1").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate1").html(data.StudentList.MainData.DateStr);

            $("#clearance").show();
            $("#formViewtitle").html("CLEARANCE APPLICATION")
            $("#clearance #finalResultDate_clearance").html(data.StudentList.MainData.TargetDateStr)
            $("#clearance #libraryid_clearance").html(data.StudentList.ClearanceFormData.LibraryID)
        }
        if (data.StudentList.MainData.CategoryID == 12) {
            $("#myname12").html(data.StudentName);
            $("#rollno12").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo12").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate12").html(data.StudentList.MainData.DateStr);


            $("#formViewtitle").html("Course Withdraw")
            $("#CourseData").show()
            $("#CourseData #coursename").html(data.StudentList.CourseWithdrawdata.CourseTitle)
            $("#CourseData #courseid").html(data.StudentList.CourseWithdrawdata.CourseID)
            $("#CourseData #credithours").html(data.StudentList.CourseWithdrawdata.CreditHours)
            $("#CourseData #teachername").html(data.StudentList.CourseWithdrawdata.TeacherName)

            displayCourses(data);
        }
        if (data.StudentList.MainData.CategoryID == 13) {
            $("#myname13").html(data.StudentName);
            $("#rollno13").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo13").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate13").html(data.StudentList.MainData.DateStr);


            $("#formViewtitle").html("GENERAL REQUEST FORM")
            $("#general_request").show()
            $("#general_request #general_Subject").html(data.StudentList.MainData.Subject)
            $("#general_request #general_semester").html(data.StudentList.MainData.CurrentSemester)
            $("#general_request #general_section").html(data.StudentList.MainData.Section)
        }

        if (data.StudentList.MainData.CategoryID == 11) {
            $("#myname11").html(data.StudentName);
            $("#rollno11").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo11").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate11").html(data.StudentList.MainData.DateStr);

            $("#SemTranscript").show()
            $("#formViewtitle").html("SEMESTER ACADAEMIC TRANSCRIPT")
            $("#SemTranscript #challanNumber").html(data.StudentList.SemesterAcadamicTranscript.ChallanNo)
            $("#SemTranscript #Currentsemester").html(data.StudentList.MainData.CurrentSemester)
            $("#SemTranscript #targetsemester").html(data.StudentList.MainData.TargetSemester)
            $("#SemTranscript #section").html(data.StudentList.MainData.Section)
            $("#SemTranscript #fathername").html(data.StudentList.MainData.FatherName)
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 2) {
            $("#myname2").html(data.StudentName);
            $("#rollno2").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo2").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate2").html(data.StudentList.MainData.DateStr);


            $("#formViewtitle").html("LEAVE APPLICATION")
            $("#Leave").show()
            $("#Leave #leave_semester").html(data.StudentList.MainData.CurrentSemester);
            $("#Leave #leave_fname").html(data.StudentList.MainData.FatherName);
            $("#Leave #fromdate").html(data.StudentList.LeaveApplication.startDateStr);
            $("#Leave #todate").html(data.StudentList.LeaveApplication.endDateStr);
        }

        if (data.StudentList.MainData.CategoryID == 3) {
            $("#myname3").html(data.StudentName);
            $("#rollno3").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo3").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate3").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("OPTION FOR BSc DEGREE")
            $("#BSc").show();
            $("#BSc #bsc_cnic").html(data.StudentList.OptionForBsc.CNIC);
            $("#BSc #bsc_dob").html(data.StudentList.OptionForBsc.DobStr);
            $("#BSc #Bsc_semester").html(data.StudentList.MainData.CurrentSemester);
            $("#BSc #bsc_fname").html(data.StudentList.MainData.FatherName);
            $("#BSc #bsc_PuRegistrationNo").html(data.StudentList.OptionForBsc.PUreg);
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 4) {
            $("#myname4").html(data.StudentName);
            $("#rollno4").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo4").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate4").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("FINAL ACADEMIC TRANSCRIPT");
            $("#finalAcademicTranscript").show();
            $("#finalAcademicTranscript #finalacad_PuRegistrationNo").html(data.StudentList.FinalTranscript.PUreg);
            $("#finalAcademicTranscript #finalacad_fname").html(data.StudentList.MainData.FatherName);
            $("#finalAcademicTranscript #finalacad_fyp").html(data.StudentList.FinalTranscript.FYPtitle);
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 5) {
            $("#myname5").html(data.StudentName);
            $("#rollno5").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo5").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate5").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("COLLEGE ID CARD");
            $("#collegeID").show();
            $("#collegeID #ID_challan").html(data.StudentList.CollegeIdCard.ChallanForm);
            $("#collegeID #ID_semester").html(data.StudentList.MainData.CurrentSemester);
            $("#collegeID #ID_section").html(data.StudentList.MainData.Section);
            $("#collegeID #ID_date").html(data.StudentList.MainData.TargetDateStr);
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 6) {
            $("#myname6").html(data.StudentName);
            $("#rollno6").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo6").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate6").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("MOTORCYCLE TOKEN")
            $("#VehicleData").show()
            ////debugger;
            $("#V_CurrentSemester").html(data.StudentList.MainData.CurrentSemester)
            $("#VehicleModel").html(data.StudentList.VehicalToken.Model)
            $("#VehicleReg").html(data.StudentList.VehicalToken.VehicalRegNo)
            $("#VehicleManufacturer").html(data.StudentList.VehicalToken.manufacturer)
            $("#VehicleOwner").html(data.StudentList.VehicalToken.ownerName)
            $("#V_section").html(data.StudentList.MainData.Section)
            $("#heading_attachment").show();
        }
        if (data.StudentList.MainData.CategoryID == 7) {
            $("#myname7").html(data.StudentName);
            $("#rollno7").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo7").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate7").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("RECEIPT OF ORIGINAL EDUCATIONAL DOCUMENT");
            $("#receiptOriginalDocs").show();
            $("#receiptOriginalDocs #doc_fname").html(data.StudentList.MainData.FatherName);
            $("#receiptOriginalDocs #doc_semester").html(data.StudentList.MainData.CurrentSemester);
            $("#receiptOriginalDocs #doc_section").html(data.StudentList.MainData.Section);
            displayDocuments(data);
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 8) {
            $("#myname8").html(data.StudentName);
            $("#rollno8").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo8").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate8").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("BONAFIDE/CHARACTER CERTIFICATE");
            $("#bonafide").show();
            $("#bonafide_cgpa_show").text(data.StudentList.BonafideCertificate.CGPA);

            $("#txtUpdatedCGPA").val(data.StudentList.BonafideCertificate.CGPA);

            $("#bonafide_PuRegistrationNo").html(data.StudentList.BonafideCertificate.PUreg);
            $("#bonafide_challan").text(data.StudentList.BonafideCertificate.ChallanForm);
            $("#bonafide_fname").html(data.StudentList.MainData.FatherName);
            $("#bonafide_semester").html(data.StudentList.MainData.CurrentSemester);
            $("#heading_attachment").show();
        }

        if (data.StudentList.MainData.CategoryID == 9) {
            $("#myname9").html(data.StudentName);
            $("#rollno9").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo9").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate9").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("SEMESTER FREEZE/WITHDRAW")
            $("#Freeze_Withdrawal").show();
            $("#ToFreeze").html(data.StudentList.MainData.TargetSemester)
            $("#Freeze_Currentsemester").html(data.StudentList.MainData.CurrentSemester)
        }

        if (data.StudentList.MainData.CategoryID == 10) {
            $("#myname10").html(data.StudentName);
            $("#rollno10").html(data.StudentList.MainData.RollNo);
            $("#DiaryNo10").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate10").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("SEMESTER REJOIN")
            $("#semesterRejoin").show()
            //$("#semesterRejoin #FreezeApplicationNo").html(data.StudentList.SemesterRejoin.withDrawApplicationNo)
            $("#semesterRejoin #semestertoRejoin").html(data.StudentList.MainData.TargetSemester);
        }
        if (data.StudentList.MainData.CategoryID == 14)
        {
            $("#myname14").html(data.StudentName);
            $("#rollno14").html(data.StudentList.MainData.Title);
            $("#DiaryNo14").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate14").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("ITEM DEMAND REQUISITION FORM")
            $("#demand_request").show();
            
            if (formData.StudentList.MainData.RequestStatus == 3) {
                $("#demand_request #ItemDataForAccepted").show();
                displayItems("#ItemDemandTemplate", "#ItemTableForAccepted", data);
            }
            else {
                $("#demand_request #ItemData").css("display", "block");
                displayItems("#ItemDemandTemplate", "#ItemData #ItemTable", data);
            }
        }
        if (data.StudentList.MainData.CategoryID == 15) {
            $("#myname15").html(data.StudentName);
           $("#rollno15").html(data.StudentList.MainData.Title);
            $("#DiaryNo15").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate15").html(data.StudentList.MainData.DateStr);

            $("#formViewtitle").html("HARDWARE REQUEST FORM")
            $("#hardware_request").show();
            if (formData.StudentList.MainData.RequestStatus === 3) {
                $("#hardware_request #hwItemDataForAccepted").show();
                displayItems("#HardwareTemplate", "#hwItemDataForAccepted #hwItemTableForAccepted", data);
            }
            else {
                $("#hardware_request #HardwareData").show();
                displayItems("#HardwareTemplate", "#HardwareData #HardwareTable", data);
            }
        }
        if (data.StudentList.MainData.CategoryID == 16) {
            $("#myname16").html(data.StudentName);
            $("#rollno16").html(data.StudentList.MainData.Title);
            $("#DiaryNo16").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate16").html(data.StudentList.MainData.DateStr);
            $("#budgetDisplay").html(data.demandItems[0].Budget);
            $("#formViewtitle").html("DEMAND VOUCHER FORM")
            $("#demand_Voucher").show();
            displayItems("#DemandVoucherTemplate", "#VoucherData #VoucherTable", data);
        }
        if (data.StudentList.MainData.CategoryID == 17) {
            $("#myname17").html(data.StudentName);
            $("#rollno17").html(data.StudentList.MainData.Title);
            $("#DiaryNo17").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#mydate17").html(data.StudentList.MainData.DateStr);
            $("#budgetDisplay17").html(data.storeDemand[0].Budget);
            debugger;
            $("#formViewtitle").html("STORE DEMAND VOUCHER FORM")
            $("#store_Demand").show();
            displayItems("#StoreDemandVoucherTemplate", "#StoreVoucherData #StoreVoucherTable", data);
        }
        if (data.StudentList.MainData.CategoryID == 18) {
            $("#myname18").html(data.StudentName);
            $("#DiaryNo18").html("Acad/" + data.StudentList.MainData.RequestID);
            $("#rollno18").html(data.StudentList.MainData.Title);
            $("#mydate18").html(data.StudentList.MainData.DateStr);
            $("#formViewtitle").html("LAB RESERVATION FORM")
            $("#labReservation_request").show();
            $("#suggestedLab").html(data.StudentList.LabReservation.SuggestedLab);
            $("#noOfComps").html(data.StudentList.LabReservation.noOfComputer);
            if (data.StudentList.LabReservation.IsPermanent === true) {
                $("#permanent_LabApp").show();
                $("#labTypeDiv").html("Permanent");
                $("#perDayApp").html(data.StudentList.LabReservation.Day);
                $("#perTimeApp").html(data.StudentList.LabReservation.PerTimeFromStr + " <b>-</b> " + data.StudentList.LabReservation.PerTimeToStr);
            }
            else if (data.StudentList.LabReservation.IsTemporary === true) {
                $("#temporary_LabApp").show();
                $("#labTypeDiv").html("Temporary");
                $("#tempDateApp").html(data.StudentList.LabReservation.TempDateFromStr + " <b>to</b> " + data.StudentList.LabReservation.TempDateToStr);
                $("#tempTimeApp").html(data.StudentList.LabReservation.TempTimeFromStr + " <b>-</b> " + data.StudentList.LabReservation.TempTimeToStr);
            }
        }
       if (data.StudentList.MainData.CategoryID == 19) {
            debugger;
            $("#myname19").html(data.StudentName);
           $("#DiaryNo19").html("Acad/" + data.StudentList.MainData.RequestID);
           $("#rollno19").html(data.StudentList.MainData.Title);
            $("#mydate19").html(data.StudentList.MainData.DateStr);
            $("#formViewtitle").html("Room Reservation Form");
            $("#RoomReservation_request").show();
            $('#totalStudents').html(data.StudentList.RoomReservation.TotalStudents);
            var multimedia =data.StudentList.RoomReservation.isMultimediaRequired;
            if (multimedia == true)
            {
                $('#multimediaReq').html("Yes");
            }
            else
            {
                $('#multimediaReq').html("No");
            }
            $('#RoomDay').html(data.StudentList.RoomReservation.RoomResDateStr);
            $('#RoomPurpose').html(data.StudentList.RoomReservation.Purpose);
            $("#RoomDay").html(data.StudentList.RoomReservation.Day);
            $("#RoomTime").html(data.StudentList.RoomReservation.TimeFromStr + " - " + data.StudentList.RoomReservation.TimeToStr);
       }
         

    }

    function displayOverallStatus(status) {
        appStatus = "";
        if (status == 2 || status == 6)
            appStatus = "Pending"
        else if (status == 3)
            appStatus = "Approved"
        else if (status == 4)
            appStatus = "Rejected"

        $("#OverallStatus").text(appStatus);

        var i = $("<i class='ace-icon fa'>");

        if (status == 1 || status == 2)
            i.addClass("fa-clock-o").addClass("bigger-125").addClass("orange");
        else if (status == 3)
            i.addClass("fa-check").addClass("bigger-130").addClass("green");
        else if (status == 4)
            i.addClass("fa-times").addClass("bigger-110").addClass("red2");

        $("#OverallStatus").closest("div").append(i);

    }

    //Get Contributoers against application Id
    function getContributors() {
      //  debugger;
        var url = "ApplicationView/GetFormApprovers/?pApplicationId=" + applicationId +"&reqUniqueId="+applicationUniqueId;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {

                contributorsList = result.data.ContributorList;
                displayContributorsInRightPanel(result.data);
                //DisplayContributorsInAddContrPopup(result.data);
                LoadContributorsInRemarksPopup();

                LoadContributorsInSwapDropdown(contributorsList);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function LoadContributorsInSwapDropdown(contributorsList) {
        var $cmb3 = $("#cmbContributorToSwapWith");

        if ($cmb3.length > 0) {
            
            for (var i = 0; i < contributorsList.length; i++) {
                var obj = contributorsList[i];
                if (obj.WorkFlowStatus == 1) {
                    var $opt = $("<option>").attr('value', obj.ApproverID).text(obj.Designation + ' (' + obj.Name + ')');
                    $cmb3.append($opt);
                }
            }
            if ($cmb3.find("option").length > 1) {
                $("#trSwapRequest").show();
            }
            else {
                $("#trSwapRequest").remove();
            }
        }
    }

    //Display contributors in right panel with status
    function displayContributorsInRightPanel(Contributors) {

        if (!Contributors)
            return;

        try {

            $("#ContributorStatus").html("");
            //  $("#statusIcons").html("");
            var ul = $("#ContributorStatus");
            //   var ul2 = $("#statusIcons");
            for (var j = 0; j < Contributors.ContributorList.length; j++) {
                var item = Contributors.ContributorList[j];
                var li = $("<li>").attr("id", item.ApproverID).text(item.Designation + '(' + item.Name + ')');
                var d = $("<div class='col-sm-1'>").css("float", "right");
                var i = $("<i class='ace-icon fa'>");

                if (item.WorkFlowStatus == 1 || item.WorkFlowStatus == 2)
                    i.addClass("fa-clock-o").addClass("bigger-125").addClass("orange");
                else if (item.WorkFlowStatus == 3)
                    i.addClass("fa-check").addClass("bigger-130").addClass("green");
                else if (item.WorkFlowStatus == 4)
                    i.addClass("fa-times").addClass("bigger-110").addClass("red2");
                d.append(i);
                li.append(d);
                ul.append(li);
            }
            return;
        }
        catch (e) {
            ////debugger;
        }
    }

    //Approve Request
    function ApproveRequest(remarks) {
        debugger;
        var RequestData = {
            RequestID: applicationId,
            ReqUniqueId: applicationUniqueId,
            Remarks: remarks
        };

        var url = "ApplicationView/ApproveRequest";
        var ApproveRequestData = JSON.stringify(RequestData);

        //var ApproveRequestData = new FormData();
        //ApproveRequestData.append("RequestID", applicationId);
        //ApproveRequestData.append("ReqUniqueId", applicationUniqueId);
        //ApproveRequestData.append("Remarks", remarks);

        MyWebApp.Globals.MakeAjaxCall("POST", url, ApproveRequestData, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh('Your approval is marked.');
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });

    }

    //Reject Request
    function RejectRequest(remarks) {
 
        var RequestData = {
            RequestID: applicationId,
            ReqUniqueId : applicationUniqueId,
            Remarks: remarks
        };

        var url = "ApplicationView/RejectRequest";
        var dataToSend = JSON.stringify(RequestData);

        //var RejectRequestData = new FormData();
        //RejectRequestData.append("RequestID", applicationId);
        //RejectRequestData.append("ReqUniqueId", applicationUniqueId);
        //RejectRequestData.append("Remarks", remarks);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh('Request is rejected.');
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }

    //Save WorkFlow changes
    function insertNewFlow() {


        var contrList = [];
        $("#sortable li").each(function () {
            contrList.push($(this).attr("uid"));
        });

        var Cobject = {
            addContrList: contrList,
            requestId: applicationId,
        };

        var url = "ApplicationView/insertNewFlow";
        var dataToSend = JSON.stringify(Cobject);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh("Changes are saved");
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred: "' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });

    }

    //Display Contributors in "Add Contributor" popup
    function DisplayContributorsInAddContrPopup(Contributors, appendOnly) {
        MyWebApp.UI.Common.setHandlebarTemplate("#changeContributorsTemplate", "#sortable", Contributors, appendOnly, function () {
            $("#sortable .removeContributor").click(function () {
                var $li = $(this).closest('li');
                if (confirm("Do you want to remove this contributor from workflow?")) {
                    var uid = $li.attr('uid');
                    var wfid = $li.attr('wfid');
                    RemoveContributorFromWorkFlow(uid, wfid, function () {
                        _changeMadeInManageContrPopup = true;
                        $li.remove();
                        MyWebApp.UI.showRoasterMessage("Contributor has been removed", Enums.MessageType.Success);
                    })
                }

            });
        });


    }

    function RemoveContributorFromWorkFlow(uid, wfid, callbackFn) {
        
        var data = {
            RequestId: applicationId,
            ReqUniqueId: applicationUniqueId,
            WFID: Number(wfid),
            ApproverIDToRemove: Number(uid)
        };
        var dataToSend = JSON.stringify(data);

        var url = "ApplicationView/RemoveContributor";

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
            if (result.success === true) {
                callbackFn();
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function AddContributorInWorkFlow(uid, callbackFn) {
        //debugger;
        var data = {
            RequestId: applicationId,
            ReqUniqueId: applicationUniqueId,
            ApproverIDToAdd: Number(uid)
        };
        var dataToSend = JSON.stringify(data);

        var url = "ApplicationView/AddContributor";

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
            if (result.success === true) {
                callbackFn(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function UpdateContributorsOrder(callbackFn) {
        var contrList = [];
        var counter = 1;
        $("#sortable li").each(function () {
            contrList.push({
                ID: Number($(this).attr("wfid")),
                ApproverID: Number($(this).attr("uid")),
                ApprovalOrder: counter
            });
            counter++;
        });

        var data = {
            RequestId: applicationId,
            ReqUniqueId: applicationUniqueId,
            ReqWorkFlowList: contrList
        };
        var dataToSend = JSON.stringify(data);

        var url = "ApplicationView/UpdateContributorsOrder";

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
            if (result.success === true) {
                callbackFn(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    //Get Activity Log Data to display in Activity Log

    function getLogList() {
       // debugger;
        var url = "ApplicationView/GetLogList/?requestId=" + applicationId+"&reqUniqueId="+applicationUniqueId;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                displayLog(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    //Save Student/Contributor Conversation
    function SaveConversation(message) {
        debugger;
        var data = {
            RequestId: applicationId,
            ReqUniqueId: applicationUniqueId,
            ActivityLogID: $("#divConvMessages").attr("actlogid"),
            Message: message
        };

        //var dataToSend = new FormData();
        //dataToSend.append("RequestId", applicationId);
        //dataToSend.append("ReqUniqueId", applicationUniqueId);
        //dataToSend.append("ActivityLogID", $("#divConvMessages").attr("actlogid"));
        //dataToSend.append("Message", message);

        var url = "ApplicationView/SaveActivityLogConverstation";
        var dataToSend = JSON.stringify(data);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                var arr = [];
                arr.push(result.data);
                console.log(result.data);
                DisplayConverstation({ 'ConversationList': arr });

                MyWebApp.UI.showRoasterMessage('Messaged added successfully.', Enums.MessageType.Success);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }

    //Get Converstation against an activity log id
    function getConversation(actlogid) {

        $("#divConvMessages").attr("actlogid", actlogid);
        debugger;
        var url = "ApplicationView/GetActivityLogConverstations/?requestId=" + applicationId + "&activityLogId=" + actlogid+"&ReqUniqueId="+applicationUniqueId;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {

                $("#divConvMessages").html("");
                DisplayConverstation(result.data);

                $('#divConvPopup').modal('show');

                //$.bsmodal.show("#divConvPopup");

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    //Display Conversation in popup
    function DisplayConverstation(data) {

        if (!data)
            return;
        try {
            var source = $("#ConversationTemplate").html();
            var template1 = Handlebars.compile(source);
            var html1 = template1(data);

        } catch (e) {
        }
        $("#divConvMessages").prepend(html1);
    }

    //Save Remarks
    function SaveRemarks(remarks, type) {
        var RequestData;
        debugger;
        if (type == "CR") {

            RequestData = {
                RequestId: applicationId,
                ReqUniqueId: applicationUniqueId,
                Comments: remarks,
            };

            var url = "ApplicationView/SaveReview";
            var dataToSend = JSON.stringify(RequestData);
            debugger;
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success === true) {
                    MyWebApp.UI.ShowLastMsgAndRefresh('Review added successfully.');
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
            });
        }

        else {
            RequestData = {
                RequestId: applicationId,
                ReqUniqueId: applicationUniqueId,
                Comments: remarks,
                IsPrintable: $("#chkIsPrintAllowed").is(":checked"),
                VisibleToUserID: $("#cmbVisibleTo").val(),
                CanReplyUserID: $("#cmbWhoCanReply").val()
            };


            //var dataTosend = new FormData();
            //dataTosend.append("RequestId", applicationId);
            //dataTosend.append("ReqUniqueId", applicationUniqueId);
            //dataTosend.append("Comments", remarks);
            //dataTosend.append("IsPrintable", $("#chkIsPrintAllowed").is(":checked"));
            //dataTosend.append("VisibleToUserID", $("#cmbVisibleTo").val());
            //dataTosend.append("CanReplyUserID", $("#cmbWhoCanReply").val());

            var url = "ApplicationView/SaveRemarks";
            var dataToSend = JSON.stringify(RequestData);
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success === true) {
                    MyWebApp.UI.ShowLastMsgAndRefresh('Remarks added successfully.');
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
            });
        }
    }
    //Handle Recieving part
    function HandleRecieving(remarks) {
        debugger;
        var RequestData = {
            RequestId: applicationId,
            ReqUniqueId: applicationUniqueId,
            ReqUniqueId: applicationUniqueId,
            Comments: remarks
        };

        //var datatosend = new formdata();
        //datatosend.append("requestid", applicationid);
        //datatosend.append("requniqueid", applicationuniqueid);
        //datatosend.append("comments", remarks);

        var url = "ApplicationView/HandleRecieving";
        var dataToSend = JSON.stringify(RequestData);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh('Recieving is done successfully.');
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }
    //Display Activity Log on main form
    function displayLog(data) {
        ////debugger;
        //$("#timeline").html("");

        if (!data)
            return;

        for (var i = 0; i < data.LogList.length; i++) {
            data.LogList[i].SrNo = data.LogList.length - i;
        }

        MyWebApp.UI.Common.setHandlebarTemplate("#LogListTemplate", "#timeline", data);

        //try {
        //    var source = $("#LogListTemplate").html();
        //    var template1 = Handlebars.compile(source);
        //    var html1 = template1(data);

        //} catch (e) {
        //    ////debugger;
        //}

        //$("#timeline").append(html1);

        isLogLoaded = true;

        BindEventAfterDataIsLoaded();
    }

    function displayCourses(data) {
        debugger;

        MyWebApp.UI.Common.setHandlebarTemplate("#CoursesTemplate", "#courseTable", data);

        //$("#courseTable").html("");

        //if (!data)
        //    return;

        //try {
        //    var source = $("#Courses").html();
        //    var template = Handlebars.compile(source);
        //    var html = template(data);

        //} catch (e) {
        //    ////debugger;
        //}
        //$("#courseTable").append(html);
    }
    function displayItems(templateId, tableId, data) {
        debugger;
        MyWebApp.UI.Common.setHandlebarTemplate(templateId, tableId, data);
    }

    function UploadAttachment() {
        //debugger;
        var data = new FormData();

        var val = $("#txtAttachmentName").val();

        if (val.trim() == "") {
            alert("File Name can't be empty!");
            return false;
        }

        var attach1 = $("#fileControl").get(0).files;

        if (!hasExtension('fileControl', ['.jpg', '.gif', '.png'])) {
            clearAttachment('fileControl');
        }

        if (attach1.length == 0) {
            $('#fileError').text("Please upload a valid file");
            $('#fileError').css("color", "red");
        }

        if (attach1.length > 0) {
            data.append("Attachment", attach1[0]);


            data.append("AppId", applicationId);
            data.append("Name", val);
            data.append("ReqUniqueId", applicationUniqueId);


            var url = "Forms/UploadAttachment";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                MyWebApp.UI.ShowLastMsgAndRefresh('File has been uploaded');

            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            });

        }
    }

    //Route Back Request
    function RouteBack(remarks) {
        debugger;
        var RequestData = {
            RequestID: applicationId,
            ReqUniqueId: applicationUniqueId,
            Remarks: remarks
        };

        var url = "ApplicationView/RouteBack";
        var data = JSON.stringify(RequestData);

        //var data = new FormData();
        //data.append("RequestID", applicationId);
        //data.append("Remarks", remarks);
        //data.append("reqUniqueId", applicationUniqueId);

        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {

            if (result.success === true) {
                if (result.data.data == -1) {
                    MyWebApp.UI.showRoasterMessage("Invalid Request", Enums.MessageType.Error);
                }
                else {
                    MyWebApp.UI.ShowLastMsgAndRefresh('Request is re-assigned to last approver.');
                }
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }


    function RemoveAttachment(attachment) {

        var data = new FormData();

        data.append("Attachment", attachment);
        data.append("AppId", applicationId);
        data.append("ReqUniqueId", applicationUniqueId);

        var url = "Forms/RemoveAttachment";
        MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
            MyWebApp.UI.ShowLastMsgAndRefresh("File has been removed");
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
        });

    }
    function UpdateAttachment(oldattachment) {

        var data = new FormData();

        var attach1 = $("#fileControl").get(0).files;
        if (attach1.length > 0) {
            data.append("Attachment", attach1[0]);
        }

        data.append("AppId", applicationId);
        data.append("OldAttachment", oldattachment);
        data.append("ReqUniqueId", applicationUniqueId);

        var url = "Forms/UpdateAttachment";
        MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
            MyWebApp.UI.ShowLastMsgAndRefresh("File has been replaced");
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
        });
    }

    function HandleEnableDisable(remarks) {
        //debugger;

        var s = $("#trEnableDisableEdit").attr("status");
        var flag = false;

        if (s == "0")
            flag = true;

        var RequestData = {
            RequestId: applicationId,
            CanStudentEdit: flag,
            Remarks: remarks,
            ReqUniqueId: applicationUniqueId
        };

        var msg = "Disabled";

        if (flag == true)
            msg = "Enabled";

        var url = "ApplicationView/EnableDisableRequestEdit";
        var dataToSend = JSON.stringify(RequestData);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh("Access is " + msg + ' successfully.');

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }

    function UpdateActivityLogActionItem(id, value, type) {

        var RequestData = {
            RequestId: applicationId,
            ActLogId: id,
            type: type,
            value: value,
            ReqUniqueId: applicationUniqueId
        };

        var url = "ApplicationView/UpdateActivityLogActionItem";
        var dataToSend = JSON.stringify(RequestData);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage("Updated successfully.", Enums.MessageType.Success);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }

    function LoadContributorsInRemarksPopup() {

        var cmb1 = $("#cmbVisibleTo");
        var cmb2 = $("#cmbWhoCanReply");

        var arr = [];
        for (var t = 0; t < contributorsList.length; t++) {
            var obj = contributorsList[t];
            //debugger;

            if (arr.indexOf(obj.ApproverID) >= 0)
                continue;

            arr.push(obj.ApproverID);

            var txt = obj['Designation'] + '(' + obj['Name'] + ')'
            var opt = $("<option value='" + obj['ApproverID'] + "'>" + txt + "</option>");
            cmb1.append(opt.clone());
            cmb2.append(opt);


        }

        areContributorsLoaded = true;

        if (areContributorsLoaded == true && isLogLoaded == true) {
            ManageActionPanelInLog();
        }

    }

    function ManageActionPanelInLog() {

        var cmb1 = $("#cmbVisibleTo");
        var cmb2 = $("#cmbWhoCanReply");

        $("#timeline .actionpanels").each(function () {

            var st = $(this).attr("ast");
            $(this).removeAttr("ast");

            var c = cmb1.clone().removeAttr('id');
            if (st == 3 || st == 4) {
                c.attr("disabled", "disabled");
            }
            else {
                c.change(function () {
                    var aid = $(this).closest(".timeline-item").attr("aid");
                    var value = $(this).val();
                    UpdateActivityLogActionItem(aid, value, 1);
                });
            }

            c.val($(this).attr("vid"));
            $(this).removeAttr("vid");
            $(this).append("<span>Visible To:</span>")
            $(this).append(c);
            $(this).append("<br>")

            c = cmb2.clone().removeAttr('id');;

            if (st == 3 || st == 4) {
                c.attr("disabled", "disabled");
            }
            else {
                c.change(function () {
                    var aid = $(this).closest(".timeline-item").attr("aid");
                    var value = $(this).val();
                    UpdateActivityLogActionItem(aid, value, 2);
                });
            }

            c.val($(this).attr("rid"));
            $(this).removeAttr("rid");
            $(this).append("<span>Who Can Reply:</span>")
            $(this).append(c);


        });
    }

    function UpdateCGPA() {

       // debugger;
        var UpdatedCGPA = $("#txtUpdatedCGPA").val()
        var isValid = true;

        //CGPA not entered
        if (UpdatedCGPA == '') {
            $('#b_gpa').text("Please enter CGPA");
            $('#b_gpa').css("color", "red");
            isValid = false;
        }

        //CGPA not valid
        var patt1 = /^[0]|[0-3]\.[0-9][0-9]|[4].[0][0]$/;
        var result = patt1.test(UpdatedCGPA);
        if (result == false) {
            $('#b_gpa').text("Please enter valid CGPA");
            $('#b_gpa').css("color", "red");
            isValid = false;
        }

        if (isValid) {

            UpdatedCGPA = $("#txtUpdatedCGPA").val().replace(/(\.[0-9][0-9])([0-9])/, "$1");
            var RequestData = {
                RequestId: applicationId,
                ReqUniqueId: applicationUniqueId,
                //CGPA: $("#txtUpdatedCGPA").val()                
                CGPA: UpdatedCGPA
            };

            var url = "ApplicationView/UpdateCGPA";
            var dataToSend = JSON.stringify(RequestData);

            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
                if (result.success === true) {
                    MyWebApp.UI.ShowLastMsgAndRefresh("Updated successfully.");
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
            });
        }
    }
    function UpdateItems(remarks, issued, data) {
        debugger;
        var Items = [];
        if (data.StudentList.MainData.CategoryID === 14) {
            Items = data.items;
        }
        else if (data.StudentList.MainData.CategoryID === 15) {
            Items = data.hardItems;
        }
        var store = Items[0].ItemName + " = " + issued[0];
        for (var i = 1; i < Items.length; i++) {
            store = store + " & " + Items[i].ItemName + " = " + issued[i];
        }
        debugger;
        var rem = remarks + "     " + "  Items Issued-> " + store;

        var itemid = [];
        for (var i = 0; i < Items.length; i++) {
            itemid.push(Items[i].ItemId);
        }
        var RequestData = {
            ItemID: itemid,
            ItemQtyIssued: issued
        };

        var url = "ApplicationView/UpdateItems";
        var ApproveRequestData = JSON.stringify(RequestData);

        (MyWebApp.Globals.MakeAjaxCall("POST", url, ApproveRequestData, function (result) {

            if (result.success == true) {
                UpdateIssuedQty(issued, data);
                ApproveRequest(rem);

            } else {

                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                return false;

            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        }))();
    }

    function UpdateIssuedQty(issued, data) {
        var demandid = [];
        var Items = [];
        if (data.StudentList.MainData.CategoryID === 14) {
            Items = data.items;
        }
        else if (data.StudentList.MainData.CategoryID === 15) {
            Items = data.hardItems;
        }
        for (var i = 0; i < Items.length; i++) {
            demandid.push(Items[i].demandId);

        }
        var objItem = {
            isssuedQty: issued,
            DemandId: demandid,
            request: {
                RequestID: data.StudentList.MainData.RequestID,
                CategoryID: data.StudentList.MainData.CategoryID
            }
        }

        var dataToSend = JSON.stringify(objItem);
        var url = "ApplicationView/UpdateIssuedQty";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend);
    }



    //function ShowYesNoPopup(settings) {

    //    var $modal = $("#divYesNoCustomModal");

    //    if (settings.attrObj)
    //        $modal.attr(settings.attrObj);

    //    $modal.find(".yesnoheader").text(settings.headerText);
    //    $modal.find(".yesnotext").text(settings.bodyText);

    //    $modal.find("#btnDivYesNoCustomYes").unbind("click").bind('click', function () {

    //        if (settings.fnYesCallBack)
    //            settings.fnYesCallBack($modal);
    //    });

    //    $modal.find("#btnDivYesNoCustomNo").unbind("click").bind('click', function () {
    //        if (settings.fnNoCallBack)
    //            settings.fnNoCallBack($modal);
    //        $.bsmodal.hide("#divYesNoCustomModal");

    //    });

    //    $.bsmodal.show("#divYesNoCustomModal");

    //}

    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
    ());