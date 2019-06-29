MyWebApp.namespace("UI.ShowActivityLog");

MyWebApp.UI.ShowActivityLog = (function () {
    "use strict";
    var _isInitialized = false;
    var current_page = 0;
    var create_pages = false;
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            create_pages = true;
            getLogList();
        }
    }

    function BindEvents() {
        $("#cmbPageSizeSearch").change(function (e) {
            e.preventDefault();
            create_pages = true;
            current_page == 0;
            getLogList();
            return false;
        });
    }


    //For get ActivityLog Data 
    function getLogList() {
        if (current_page == 0)
            current_page = 1;
        var searchObject = {
            PageSize: $("#cmbPageSizeSearch").val(),
            PageIndex: current_page - 1
        };
        var Data = JSON.stringify(searchObject);
        var url = "Reports/GetActivityLogList";
        console.log(Data);
        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            if (result.success === true) {
                CreatePages(result.data.Count);
                $("#spResultsFound").text("(" + result.data.Count + " Records are found)");
                displayLogData(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function CreatePages(recordCount) {
        var pageSize = Number($("#cmbPageSizeSearch").val());

        if (create_pages == true) {
            MyWebApp.UI.Common.ApplyPagination("ul.pagination", recordCount, pageSize, function (pageNumber) {
                current_page = pageNumber;
                getLogList();
            });
            create_pages = false;
        }
    }

    //for Display Activity Logs
    function displayLogData(data) {
        $("#timeline").html("");
        if (!data)
            return;
        for (var i = 0; i < data.LogList.length; i++) {
            data.LogList[i].SrNo = data.LogList.length - i;
        }

            try {
                var source = $("#LogListDisplayTemplate").html();
                var template = Handlebars.compile(source);
                var html = template(data);
            } catch (e) {
                debugger;
            }

            $("#timeline").append(html);

       // MyWebApp.UI.Common.setHandlebarTemplate("#LogListDisplayTemplate", "#timeline", data);
    }
    return {
      
        readyMain: function () {
            initialisePage();
        }
    };
}
());