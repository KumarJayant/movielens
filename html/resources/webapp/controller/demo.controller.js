sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/FilterType",
  "movielens/html/model/formatter"
], function(Controller, Filter, FilterOperator, FilterType, formatter) {
  "use strict";
  return Controller.extend("movielens.html.controller.demo", {
    formatter: formatter,

    handlePressOpenMenu: function(oEvent) {
      var oButton = oEvent.getSource();
      // create menu only once
      if (!this._menu) {
        this._menu = sap.ui.xmlfragment("movielens.html.fragment.view_menu", this);
        this.getView().addDependent(this._menu);
      }
      var eDock = sap.ui.core.Popup.Dock;
      this._menu.open(this._bKeyboard, oButton, eDock.BeginTop, eDock.BeginBottom, oButton);
    },
    handleMenuItemPress: function(oEvent) {
      if (oEvent.getParameter("item").getSubmenu()) {
        return;
      }
      var to = oEvent.getParameter("item").data("to");
      if (to) {
        this.getOwnerComponent().getTargets().display(to);
      }

    },
    onSuggestionSubmit: function(oEvent) {
      var type = oEvent.getSource().data("type");
      this.selectItem(type, oEvent.getParameter("value"));
    },
    onSuggestionItemSelected: function(oEvent) {
      if (oEvent.getParameter("selectedItem") !== null) {
        var type = oEvent.getSource().data("type");
        this.selectItem(type, oEvent.getParameter("selectedItem").getKey());
      }
    },
    onSuggestionSuggest: function(oEvent) {
      var type = oEvent.getSource().data("type");
      var value = oEvent.getSource().getValue();
      var searchFilters = [];
      if (value) {
        // don"t search numeric field if the input is not numerci
        if (formatter.isNumeric(value)) {
          if (type === "user") {
            searchFilters.push(new Filter("USERID", FilterOperator.EQ, value));
          } else if (type === "movie") {
            searchFilters.push(new Filter("MOVIEID", FilterOperator.EQ, value));
          }
          searchFilters.push(new Filter("RATING_COUNT", FilterOperator.EQ, value));
        }
        if (type === "movie") {
          searchFilters.push(new Filter("tolower(TITLE)", FilterOperator.Contains, "'" + value.toLowerCase() + "'"));
        }
        searchFilters.push(new Filter("tolower(DESCRIPTION)", FilterOperator.Contains, "'" + value.toLowerCase() + "'"));
      }
      this.getView().byId(type + "_input").getBinding("suggestionItems").filter(new Filter({
        filters: searchFilters,
        and: false
      }), FilterType.Application);
    }
  });
});
