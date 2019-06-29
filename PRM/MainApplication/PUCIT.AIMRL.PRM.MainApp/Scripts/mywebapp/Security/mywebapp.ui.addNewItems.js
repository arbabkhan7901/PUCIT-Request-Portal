MyWebApp.namespace("UI.AddNewItems");

MyWebApp.UI.AddNewItems = (function () {
    "use strict";
    var _isInitialized = false;

    var itemData;
    var temp_perdata;

    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            getAllItems();
            BindGridEvents();
            //debugger;
            //getActivePermissions();
            //saveItems(itemData);
        }
    }

    function BindEvents() {
        debugger;
        $("#selectType1").change(function (e) {
            e.preventDefault();
            debugger;
            var selected_dropdownindex1 = parseInt($('#selectType1').val());
            var data = {};
            //data.ItemList = [];

            if (selected_dropdownindex1 == -1) {
                data = itemData;
            }
            else {
                data.ItemsList = itemData.ItemsList.filter(p => p.IsActive == Boolean(selected_dropdownindex1));
            }
            //change5 
            displayAllItems(data);

        }); //End of Save Click

        $("#newItem").click(function (e) {
            e.preventDefault();
            clearFeilds();
            $('#modal-form').modal('show');
            //$.bsmodal.show("#modal-form");
        });

        $("#Save").unbind('click').bind('click', function (e) {
            e.preventDefault();

            if ($("#Itemname").val() == "" || $('#ItemDescription').val() == "") {
                MyWebApp.UI.showRoasterMessage("Empty Field(s)", Enums.MessageType.Error, 2000);
            }
            if ($("#generalItem").is(':checked') == false && $("#hardwareItem").is(':checked') == false) {
                //$('#item_category').text("Reason is required");
                //$('#item_category').css("color", "red");
                MyWebApp.UI.showRoasterMessage("Please select category", Enums.MessageType.Error, 2000);

            }
            else {
                var type;
                if ($("#generalItem").is(':checked') == true) {
                    type = 11;
                }
                else if ($("#hardwareItem").is(':checked') == true) {
                    type = 22;
                }

                $('#modal-form').modal('hide');
                //$.bsmodal.hide("#modal-form");
                debugger;
                MyWebApp.Globals.ShowYesNoPopup({
                    headerText: "Save",
                    bodyText: 'Do you want to Save this record?',
                    dataToPass: {
                        ItemId: $("#hiddenid").val(),
                        ItemName: $("#Itemname").val(),
                        Description: $('#ItemDescription').val(),
                        Type: type
                    },
                    fnYesCallBack: function ($modalObj, dataObj) {

                        saveItem(dataObj);
                        $modalObj.hideMe()
                    }
                });
            }
            return false;
        });
        $("#SaveQty").unbind('click').bind('click', function (e) {
            e.preventDefault();

            if ($("#ItemnameQty").val() == "" || $('#ItemInQuantity').val() == "") {
                MyWebApp.UI.showRoasterMessage("Empty Field(s)", Enums.MessageType.Error, 2000);
            }
            else {
                $('#modal-form-qty').modal('hide');
                //$.bsmodal.hide("#modal-form");
                debugger;
                MyWebApp.Globals.ShowYesNoPopup({
                    headerText: "Save",
                    bodyText: 'Do you want to Save this record?',
                    dataToPass: {
                        ItemId: $("#hiddenidQty").val(),
                        ItemName: $("#ItemnameQty").val(),
                        Quantity: $('#ItemQuantity').val()
                    },
                    fnYesCallBack: function ($modalObj, dataObj) {
                        var inQty = $('#ItemInQuantity').val();
                        saveQuantity(dataObj, inQty);
                        $modalObj.hideMe()
                    }
                });
            }
            return false;
        });


        $("#ModalClose, #Cancel").click(function (e) {
            e.preventDefault();
            $('#modal-form').modal('hide');
            //$.bsmodal.hide("#modal-form");
            return false;
        });
        $("#ModalClose1, #Cancel1").click(function (e) {
            debugger;
            e.preventDefault();
            $('#modal-form-qty').modal('hide');
            return false;
        });

        $("#SaveMappings").unbind('click').bind('click', function () {
            SavePermissionMapping();
            return false;
        });

    }

    function saveItem(dataObj) {
        debugger;
        var ItemObjToSend = {
            ItemId: dataObj.ItemId,
            ItemName: dataObj.ItemName,
            Description: dataObj.Description,
            Type: dataObj.Type
        }

        var dataToSend = JSON.stringify(ItemObjToSend);
        var url = "Security/Saveitems";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh(result.error);
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
            $('#modal-form').modal('hide');
            //$.bsmodal.hide("#modal-form");
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Item: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }

    function saveQuantity(dataObj, inQty) {
        debugger;
        var QtyObjToSend = {
            ItemId: dataObj.ItemId,
            ItemName: dataObj.ItemName,
            Quantity: dataObj.Quantity,
            InQuantity: inQty
        }

        var dataOfQtyToSend = JSON.stringify(QtyObjToSend);
        var url = "Security/SaveQuantity";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataOfQtyToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh(result.error);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                clearFeilds();
            }
            $('#modal-form-qty').modal('hide');
            //$.bsmodal.hide("#modal-form");
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Item: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }


    function clearFeilds() {

        $("#hiddenid").val("");
        $("#Itemname").val("");
        $("#ItemDescription").val("");
        $("#generalItem").val(":unchecked");
        $("#hardwareItem").val(":unchecked");
        $("#ItemInQuantity").val("");

    }

    function EnableDisableItem(dataObj) {
        debugger;
        var ItemDataObj = {
            ItemId: dataObj.ItemId,
            IsActive: !dataObj.IsActive
        }

        var dataToSend = JSON.stringify(ItemDataObj);
        var url = "Security/EnableDisbaleItem";

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                debugger;
                var ItemObj = itemData.ItemsList.find(p => p.ItemId == ItemDataObj.ItemId);
                ItemObj.IsActive = ItemDataObj.IsActive;

                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);

                //$("#selectType1").trigger("change");
                displayAllItems(itemData);
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Item: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function getAllItems() {
        //change2
        debugger;
        var url = "Security/getItems";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                //change4 
                console.log(result.data);
                displayAllItems(result.data);
                itemData = result.data;               

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Items: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        }, false);

    }

    function displayAllItems(ItemList) {

        MyWebApp.UI.Common.setHandlebarTemplate("#RoleTemplate", "#simple-table-Item", ItemList, false, BindGridEvents);
    }


    function BindGridEvents() {
        debugger;
        $("#simple-table-Item .lnkEditItem").click(function () {
            var id = $(this).closest('tr').attr('id');
            HandleEditItem(id);
            debugger;
            return false;
        });

        $("#simple-table-Item .lnkQtyItem").unbind('click').bind('click', function () {
            var id = $(this).closest('tr').attr('id');
            HandleEditQty(id);
            return false;
        });

        $("#simple-table-Item .lnkDeleteItem").unbind('click').bind('click', function () {
            debugger;
            var id = $(this).closest('tr').attr('id');
            HandleEnableDisableItem(id);
            return false;
        });
    }
    function HandleEditItem(ItemId) {
        debugger;
        if (itemData) {
            var ItemObj = itemData.ItemsList.find(p => p.ItemId == ItemId);
            if (ItemObj) {
                if (ItemObj.IsActive == false) {
                    MyWebApp.UI.showRoasterMessage("Editing is not allowed as record is disabled", Enums.MessageType.Error);
                    return false;
                }
                $("#hiddenid").val(ItemObj.ItemId);
                $("#Itemname").val(ItemObj.ItemName);
                $("#ItemDescription").val(ItemObj.Description);

                var type = ItemObj.Type;

                if (type == 11) {
                    var radiobtn = document.getElementById("generalItem");
                    radiobtn.setAttribute("checked", "checked");
                }
                else if (type == 22) {
                    var radiobtn = document.getElementById("hardwareItem");
                    radiobtn.setAttribute("checked", "checked");
                }
                $('#modal-form').modal('show');
                debugger;
                //$.bsmodal.show("#modal-form");
            }//end of ItemObj
        }//end of itemData
    }
    function HandleEditQty(ItemId) {

        if (itemData) {
            var qtyObj = itemData.ItemsList.find(p => p.ItemId == ItemId);
            if (qtyObj) {
                if (qtyObj.IsActive == false) {
                    MyWebApp.UI.showRoasterMessage("Editing is not allowed as record is disabled", Enums.MessageType.Error);
                    return false;
                }

                $("#hiddenidQty").val(qtyObj.ItemId);
                $("#ItemnameQty").val(qtyObj.ItemName);
                $("#ItemQuantity").val(qtyObj.Quantity);

                $('#modal-form-qty').modal('show');
                debugger;
                //$.bsmodal.show("#modal-form-qty");
            }//end of qtyObj
        }//end of itemData
    }


    function HandleEnableDisableItem(ItemId) {
        debugger;
        if (itemData) {    
            var ItemObj = itemData.ItemsList.find(p => p.ItemId == ItemId);
            if (ItemObj) {

                var header = (ItemObj.IsActive == false ? "Enable" : "Disable");

                MyWebApp.Globals.ShowYesNoPopup({
                    headerText: header,
                    bodyText: 'Do you want to ' + header + ' this record?',
                    dataToPass: { "ItemId": ItemObj.ItemId, "IsActive": ItemObj.IsActive },
                    fnYesCallBack: function ($modalObj, ItemObj) {
                        debugger;
                        EnableDisableItem(ItemObj);
                        $modalObj.hideMe();
                    }
                });
            }//end of ItemObj
        }//end of itemData
    }
    function deleteItems(ItemId) {

        var url = "Security/deleteItems?id=" + ItemId;
        MyWebApp.Globals.MakeAjaxCall("POST", url, "{}", function (result) {
            debugger;
            if (result.success === true) {
                MyWebApp.UI.ShowLastMsgAndRefresh("items deleted");


            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Permissions: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        }, false);
    }

    return {

        readyMain: function () {
            initialisePage();

        }
    };
}
    ());