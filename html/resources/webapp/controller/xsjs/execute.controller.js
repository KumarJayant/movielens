sap.ui.define([
  "movielens/html/controller/demo.controller",
  "sap/m/MessageBox"
], function(Controller, MessageBox) {
  "use strict";

  return Controller.extend("movielens.html.controller.xsjs.execute", {
    onInit: function() {
      this.getView().setModel(new sap.ui.model.json.JSONModel(), "results");
    },
    ajaxCallCompleted: function(status, message) {
      MessageBox.show(message, {
        title: status
      });
      this.oBusyIndicator.close();
    },
    onPress: function(oEvent) {
      var oController = this;
      oController.oBusyIndicator = new sap.m.BusyDialog();
      oController.oBusyIndicator.open();

      var algorithm = oEvent.getSource().data("algorithm");

      var results = oController.getView().getModel("results");
      var configData = oController.getView().getModel("config").getData();
      var service = null;
      var method = oEvent.getSource().data("method");
      if (method === "execute") {
        service = configData.services[algorithm].execute;
      } else if (method === "results") {
        service = configData.services[algorithm].results;
        service.data.resultType = oEvent.getSource().data("resultType");
        results.setProperty("/resultType", oEvent.getSource().data("resultType"));
      }

      var ajaxSuccess = function(response, status) {
        oController.ajaxCallCompleted(status, response.message);
        results.setProperty("/items", response.results);
        results.setProperty("/hasResult", true);
      };
      var ajaxError = function(xhr, status, error) {
        var msg = error;
        if (error.message) {
          msg = error.message;
        }
        oController.ajaxCallCompleted(status, msg);
      };
      $.ajax({
        method: service.method,
        url: service.url,
        async: true,
        timeout: 3000000,
        headers: {
          "content-type": "application/json",
          "accept": "application/json"
        },
        data: JSON.stringify(service.data),
        success: ajaxSuccess,
        error: ajaxError
      });
    }
  });
});
