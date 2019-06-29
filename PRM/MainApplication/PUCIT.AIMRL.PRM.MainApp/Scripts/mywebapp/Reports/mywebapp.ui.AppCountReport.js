MyWebApp.namespace("UI.Reports");

MyWebApp.UI.Reports = (function () {
    "use strict";
    var _isInitialized = false;
    var StatusList;

    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            SearchApplicationStatuses();
        }
    }

    function BindEvents() {
        $("#search").unbind("click").bind("click", function (e) {
            //debugger
            e.preventDefault();           
            SearchApplicationStatuses();
            return false;
        });
        $("#selectType").change(function (e) {
            e.preventDefault();
            
            var selected_dropdownindex1 = parseInt($(this).val());

            var data = {};
            data.StatusList = [];

            if (selected_dropdownindex1 == 1) {
                data.StatusList = StatusList.StatusList.filter(p=> p.IsContributor === "Approver");
            }
            else if (selected_dropdownindex1 == 2) {
                data.StatusList = StatusList.StatusList.filter(p=> p.IsContributor === "Not Approver");
            }
            else {
                data = StatusList;
            }

            displayAllAppStatuses(data);

        }); //End of Save Click

    }
    function SearchApplicationStatuses() {

        var searchObject = {
            Login: $("#login").val().trim(),
            Status: $("#status").val(),
            IsApprover: $("#IsApprover").val(),
            SDate: $("#sdate").val(),
            EDate: $("#edate").val()
        };

        var url = "Reports/SearchApplicationStatuses";
        var Data = JSON.stringify(searchObject);
        debugger;
        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            debugger;
            if (result.success === true) {
                StatusList = result.data;
                console.log(result.data);
                displayAllAppStatuses(StatusList);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            console.log(thrownError);
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting records: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    //function viewAllApplicationStatuses() {

    //    var url = "Reports/GetAppStatuses";
    //    MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
    //        if (result.success === true) {
    //            StatusList = result.data;
    //            displayAllAppStatuses(StatusList);
    //        } else {
    //            MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
    //        }
    //    }, function (xhr, ajaxOptions, thrownError) {
    //        MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Report "' + thrownError + '". Please try again.', Enums.MessageType.Error);
    //    }, false);

    //}

    function displayAllAppStatuses(StatusList) {

        $("#AppStatuses_table").html("");

        if (!StatusList)
            return;

        try {
            var source = $("#ApplicationStatusesTemplate").html();
            var template = Handlebars.compile(source);
            var html = template(StatusList);
        } catch (e) {
            debugger;
        }

        $("#AppStatuses_table").append(html);
    }
    
    return {
        readyMain: function () {
            initialisePage();
        }
    };
}
());