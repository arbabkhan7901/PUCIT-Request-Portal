MyWebApp.namespace("UI.ItemsDataReport");

MyWebApp.UI.ItemsDataReport = (function () {
    "use strict";
    var _isInitialized = false;
    var LoginList;
    var StatusList;
    var current_page = 0;
    function initialisePage() {
        debugger;
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            fillItemdropdown();
            SearchItem();
           // $("#loginIdDiv").show();
            //$("#nameDiv").show();
            

        }
    }
    function BindEvents() {

        $("#search").unbind("click").bind("click", function (e) {
            debugger
            e.preventDefault();
            SearchItem();
            //validate();
            return false;
        });
       
        //$("#selectType").change(function (e) {
        //    e.preventDefault();
        //    var data = {};
        //    data.StatusList = [];
        //    data = StatusList;
        //    displayAllAppStatuses(data);

        //}); //End of Save Click




    }


    function SearchItem() {

        var dropdown = $('#item_select :selected').text()
        var searchT = 1;
        if ($("#login").val() == "" && $("#sdate").val() == "" && $("#edate").val()=="" && $("#edate").val()=="" && dropdown == "") {
            searchT = 0;
        }
        if (dropdown == "--Select--") {
            dropdown = "";        
        }
        var searchObject = {
            Login: $("#login").val().trim(),
            SDate: $("#sdate").val(),
            EDate: $("#edate").val(),
            Item: dropdown,
            searchType: searchT
        };
        debugger;

        var url = "Reports/SearchItemReport";
        var Data = JSON.stringify(searchObject);
        debugger;
        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
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

    function displayAllAppStatuses(StatusList) {
        debugger;
        $("#ItemSearch_table").html("");

        if (!StatusList)
            return;

        try {
            var source = $("#ItemSearchTemplate").html();
            var template = Handlebars.compile(source);
            var html = template(StatusList);
        } catch (e) {
            debugger;
        }

        $("#ItemSearch_table").append(html);
    }


    //function validate() {
    //    debugger;
    //    var login = $("#login").val().trim()
    //    var dropdown = $('#item_select :selected').text()
    //    if (dropdown == "--Select--") {
    //        dropdown = "";
    //    }

    //    if (login != "") {
    //        if (isNaN(login) == false) {
    //            MyWebApp.UI.showRoasterMessage('Please enter a String in Name', Enums.MessageType.Error);
    //        }
    //    }

    //     if (login == "" && dropdown == "") {
    //        MyWebApp.UI.showRoasterMessage("Please Select either Name or Item Name", Enums.MessageType.Error);
    //    }

    //    else {
    //        SearchItem();
    //    }





    //}




    function fillItemdropdown() {
        debugger;
        var url = "Reports/getVoucherItemsName";
        MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {
            if (result != null) {
                console.log(result);
            }
            else {
                console.log("data is not there");
            }
            Utilities.LoadDropDown($("#item_select"), result.data, "ItemId", "ItemName");

        });

    }

    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
());