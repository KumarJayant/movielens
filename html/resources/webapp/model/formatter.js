sap.ui.define([], function() {
  "use strict";
  var isNumeric = function(oValue) {
    var tmp = oValue && oValue.toString();
    return !jQuery.isArray(oValue) && (tmp - parseFloat(tmp) + 1) >= 0;
  };
  return {
    formatEpoch: function(value) {
      var result = "";
      if (value !== "undefined" && isNumeric(value)) {
        result = new Date(value * 1000).toDateString();
      }
      return result;
    },
    formatNumber: function(value) {
      var result = "";
      if (value !== "undefined" && isNumeric(value)) {
        result = Number(value).toFixed(2);
      }
      return result;
    },
    formatPercent: function(value) {
      var result = "";
      if (value !== "undefined" && isNumeric(value)) {
        result = Number(value * 100).toFixed(2) + "%";
      }
      return result;
    },
    isNumeric: isNumeric
  };
});
