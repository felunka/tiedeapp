// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("jquery")

require("bootstrap")
import "../stylesheets/application";

import "@fortawesome/fontawesome-free/css/all"

import 'select2'
import 'select2/dist/css/select2.css'

import * as Credential from "credential";

document.addEventListener("turbolinks:load", function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
    $('[data-toggle="popover"]').popover()
    $('.js-states').select2()
  })
  $("#registration_form").on('ajax:success', function(event, data){
    let credentialOptions = event.detail[0]
    console.log(event.detail[0])

    if (credentialOptions["user"]) {
      let callback_url = `/registration/callback`
      
      Credential.create(encodeURI(callback_url), credentialOptions);
    }
  })
  $("#session_form").on('ajax:success', function(event, data){
    let credentialOptions = event.detail[0]
    console.log(event.detail[0])

    Credential.get(credentialOptions);
  })
  $(document).on('ajax:error', function(xhr, status, error) {
    let alert = document.createElement('div');
    alert.className = 'alert alert-dissmissible mt-3 alert-danger';
    alert.innerText = xhr.detail[0];
    $('#flashbox').append(alert);
  });
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
