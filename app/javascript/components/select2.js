import jQuery from "jquery"
import 'select2'

export default class Select2 {
  static setup() {
    $('.js-states').each(function() {
      let options = {};
      let modal = $(this).closest('.modal');
      if (modal.length) {
        options.dropdownParent = modal;
      }
      $(this).select2(options);
    });
    $('.js-states-autocomplete').each(function() {
      Select2.initSelectAutocomplete(this);
    });
  }

  static initSelectAutocomplete(element) {
    let url = $(element).data('url');
    let options = {
      minimumInputLength: 2,
      allowClear: true,
      ajax: {
        url: url,
        processResults: function(data) {
          return {
            results: data
          };
        }
      }
    };
    let modal = $(element).closest('.modal');
    if (modal.length) {
      options.dropdownParent = modal;
    }
    $(element).select2(options);
  }
};
