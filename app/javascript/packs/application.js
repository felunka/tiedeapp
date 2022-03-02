// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('channels')
require('jquery')

// cocoon nested form
require('@nathanvda/cocoon')
// bootstrap
require('bootstrap')
// select 2
import 'select2'
import 'select2/dist/css/select2.css'
// icons
import '@fortawesome/fontawesome-free/css/all'

// application styles
import '../stylesheets/application';

document.addEventListener('turbolinks:load', function() {
  // init pooperjs
  $(function () {
    $('[data-bs-toggle="tooltip"]').tooltip({
      container: 'body'
    });
    $('[data-toggle="popover"]').popover();
  })
  // init select 2
  $('.js-states').select2();
  $('.js-states-autocomplete').each(function() {
    initSelectAutocomplete(this);
  });
  $(document).on('cocoon:after-insert', function(e, insertedItem) {
    console.log(insertedItem)
    initSelectAutocomplete(insertedItem.find('.js-states-autocomplete'));
  });
  // generic ajax error handler
  $(document).on('ajax:error', function(xhr, status, error) {
    let alert = document.createElement('div');
    alert.className = 'alert alert-dissmissible mt-3 alert-danger';
    alert.innerText = xhr.detail[0];
    $('#flashbox').append(alert);
  });
})

function initSelectAutocomplete(element) {
  let url = $(element).data('url');
  $(element).select2({
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
  });
}

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
