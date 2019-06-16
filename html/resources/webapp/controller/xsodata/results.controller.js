sap.ui.define([
  "movielens/html/controller/demo.controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/FilterType",
  "movielens/html/model/formatter"
], function(Controller, Filter, FilterOperator, FilterType, formatter) {
  "use strict";

  return Controller.extend("movielens.html.controller.xsodata.results", {
    onInit: function() {
      if (!this.getView().getModel()) {
        this.getView().setModel(new sap.ui.model.json.JSONModel());
      }
      this.selectItem(null, null);
    },
    selectItem: function(type, value) {
      var filters = [];
      // only allow numeric direct input
      var itemId = -1;
      // get the current model and clear details
      var oModel = this.getView().getModel();
      if (formatter.isNumeric(value)) {
        // get the odata model
        var oDataModel = this.getView().getModel("odata");
        var item = oDataModel.getProperty("/ratings_" + type + "(" + value + ")", this, true);
        if (item !== "undefined") {
          if (type === "user") {
            itemId = item.USERID;
            filters = [
              new Filter([
                new Filter("USERID", FilterOperator.EQ, itemId)
              ], false)
            ];
          } else if (type === "movie") {
            itemId = item.MOVIEID;
            filters = [
              new Filter([
                new Filter("MOVIEID", FilterOperator.EQ, itemId)
              ], false)
            ];
          }
          oModel.setProperty("/selectedItemId", itemId);
          oModel.setProperty("/selectedItem", item);
          oModel.setProperty("/itemType", type);
          var searchFilters = new Filter({
            filters: filters,
            and: false
          });
          var history = this.getView().byId("history");
          if (typeof history !== "undefined" && typeof history.getBinding("rows") !== "undefined") {
            history.getBinding("rows").filter(searchFilters, FilterType.Application);
          }
          var resultsAPL = this.getView().byId(type + "_results_apl");
          if (typeof resultsAPL !== "undefined" && typeof resultsAPL.getBinding("rows") !== "undefined") {
            resultsAPL.getBinding("rows").filter(searchFilters, FilterType.Application);
          }
          var resultsPAL = this.getView().byId(type + "_results_pal");
          if (typeof resultsPAL !== "undefined" && typeof resultsPAL.getBinding("rows") !== "undefined") {
            resultsPAL.getBinding("rows").filter(searchFilters, FilterType.Application);
          }
        }
      } else {
        oModel.setProperty("/selectedItemId", null);
        oModel.setProperty("/selectedItem", null);
        oModel.setProperty("/itemType", null);
      }
    }
  });
});
