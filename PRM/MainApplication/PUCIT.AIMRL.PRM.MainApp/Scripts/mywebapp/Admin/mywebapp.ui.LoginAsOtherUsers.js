
MyWebApp.namespace("UI.LoginAsOtherUsers");

MyWebApp.UI.LoginAsOtherUsers = (function () {
    "use strict";
    var _isInitialized = false;
    var mainAutocompleteObj1;

    function initialisePage() {

        if (_isInitialized == false) {
            _isInitialized = true;
            ClearFields();
            BindEvents();
            mainAutocompleteObj1 = new JQUIAutoCompleteWrapper({
                inputSelector: "#txtUserName",
                dataSource: "Admin/SearchUser",
                queryString: "",
                listItemClass: ".listitem",
                searchParameterName: "key",
                maxItemsToDisplay: "1",
                minCharsToTypeForSearch: "2",
                watermark: "Type Login/Name",
                dropdownHTML: "<a><table><tr><td>Login(Name)</td></tr></table></a>",
                fields: {
                    ValueField: 'ID', DisplayField: 'Login', DescriptionField: 'Name'
                },
                enableCache: false,
                onClear: function () {
                }
               , displayTextFormat: "Login"
            });

            mainAutocompleteObj1.InitializeControl();
        }
    }
    function BindEvents() {

        $('#lnkLogin').unbind('click').bind('click',function () {
            LoginAsOtherUsers();
            return false;
        });

        $('#txtUserName').bind('keypress', function (e) {
            var code = (e.keyCode ? e.keyCode : e.which);
            if (code == 13) {
                LoginAsOtherUsers();
                e.preventDefault();
                return false;
            }
        });

    }//End of BindEvents

    function ClearFields() {

    }//End of ClearFields


    function LoginAsOtherUsers() {

        var userName = $('#txtUserName').val();

        if ($.trim(userName) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter a user name.", Enums.MessageType.Error);
            $('#txtUserName').focus();
            return;
        }

        var login = {
            UserName: userName
        };

        var data = JSON.stringify(login);

        var url = "Admin/ValidateUser";

        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {
            console.log(result);
            if (result.success === true) {

                MyWebApp.UI.showRoasterMessage("Login is successful, entering into the application...", Enums.MessageType.Success);

                var returnUrl = MyWebApp.UI.getURLParameterByName("ReturnURL");

                if (returnUrl != "")
                    window.location.href = returnUrl;
                else
                    window.location.href = MyWebApp.Globals.baseURL + result.data.redirect;

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error, 5000);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            //debugger;
            MyWebApp.UI.showRoasterMessage('There was a problem in login "' + xhr.responseText + '". Please try again.', Enums.MessageType.Error);
        });
    }//End of LoginAsOtherUsers function

    return {

        readyMain: function () {
            initialisePage();
        }
    };
}());