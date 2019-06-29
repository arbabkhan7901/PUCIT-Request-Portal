MyWebApp.namespace("UI.ApplicationWorkflow");
var id = null;
var isAciveUser1 = false;
var olength;
MyWebApp.UI.ApplicationWorkflow = (function () {
    "use strict";
    var _isInitialized = false;
    var mainAutocompleteObj1;

    function initialisePage() {
        //debugger;
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            LoadAllForms();
        }
    }
    function BindEvents() {

        $("#Save").unbind("click").bind("click", function (e) {
            e.preventDefault();
            //var ApproverID = $("#Add_Contributor option:selected").val();
            //var ForNewCampus = $('#ForNewCampus').prop("checked");
            SaveDesignation(id);
            $('#DesignationModals').modal('hide');
            //$.bsmodal.hide("#DesignationModals");

        }); //End of Cancel Click

        mainAutocompleteObj1 = new JQUIAutoCompleteWrapper({
            inputSelector: "#txtTextToSearch",
            dataSource: "ApplicationView/SearchContributor",
            queryString: "",
            listItemClass: ".listitem",
            searchParameterName: "key",
            maxItemsToDisplay: "1",
            minCharsToTypeForSearch: "2",

            watermark: "Type Name/Designation",
            dropdownHTML: "<a href='#'>Desg (NME)</a>",
            fields: {
                ValueField: 'ID', DisplayField: 'NME', DescriptionField: 'Desg'
            },
            enableCache: false,
            onClear: function () {
            }
               , displayTextFormat: "Desg (NME)"
               , itemOnClick: function (item) {
                   var dname = item.Desg + " (" + item.NME + ")";
                   var obj = {};
                   obj.FormContributersList = [];
                   obj.FormContributersList.push({ ApproverID: item.ID, IsForNewCampus: false, IsForOldCampus: true, DesigWithName: dname });

                   MyWebApp.UI.Common.setHandlebarTemplate("#changeContributors12", "#sortable22 tbody", obj, true, function () {
                       $("#sortable22 .icon-minus-sign").unbind('click').bind('click', function () {
                           $(this).closest("tr").remove();
                       });
                   });

                   ReSetOrderInTable();

               }
        });

        mainAutocompleteObj1.InitializeControl();

    }//End of Bind Events

    function ViewFormContributers(formID) {

        var url = "Admin/getFormContributers?pFormID=" + formID;

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {

                displayFormContributers(result.data, formID);
                $("#hdFormId").val(formID);
                $('#DesignationModals').modal('show');
                //$.bsmodal.show("#DesignationModals", { top: "5%", left: "15%", width: "500px", closeid: "#closeedit,#Cancel" });


            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Users: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });

    }
    function displayFormContributers(FormContributersList, formId) {

        MyWebApp.UI.Common.setHandlebarTemplate("#changeContributors12", "#sortable22 tbody", FormContributersList, false, function () {
            $("#sortable22 .icon-minus-sign").unbind('click').bind('click', function () {
                $(this).closest("tr").remove();
            });
        });

        $("#sortable22 tbody").sortable({
            revert: false,
            stop: function () {
                ReSetOrderInTable();
            }
        });


        olength = $('ul#sortable22 li').length;

    }

    function ReSetOrderInTable() {
        var counter = 1;
        $("#sortable22 tbody tr").each(function () {
            $(this).find("td:first").text(counter);
            counter++;
        });
    }
    function SaveDesignation(id) {

        var formID = $("#hdFormId").val();
        var contrList = [];
        var counter = 1
        $("#sortable22 tbody tr").each(function () {

            var order = counter;
            var approverId = $(this).attr("aid");
            var isoldcampus = $(this).find("input.isoldcampus").is(":checked");
            var isnewcampus = $(this).find("input.isnewcampus:checked").is(":checked");

            contrList.push({ ApproverID: approverId, ApprovalOrder: order, IsForNewCampus: isnewcampus, IsForOldCampus: isoldcampus });

            counter++;
        });


        var dataToSend = { FormID: formID, ContributorList: contrList };

        var url = "Admin/SaveContributorsForForm";
        dataToSend = JSON.stringify(dataToSend);

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh('Contributors saved successfully.');
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });

        
    }

    function LoadAllForms() {
        var url = "Admin/getAllApplications";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                //debugger;
                console.log(result);
                displayAllApplications(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Users: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });

    }
    function displayAllApplications(AppList) {

        MyWebApp.UI.Common.setHandlebarTemplate("#ApplicationsTemplate", "#Applications", AppList, false, function () {
            $(".lnkManageWorkflows").unbind("click").bind("click", function (e) {
                e.preventDefault();
                var formid = $(this).closest("tr").attr("pid");
                ViewFormContributers(formid);
            }); //End of Cancel Click
        });
    }
    return {

        readyMain: function () {
            //debugger;
            initialisePage();

        }
    };
}
());