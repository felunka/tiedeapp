import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  accept() {
    Cookies.set('allow_cookies', 'yes', {
      expires: 365
    });
    document.getElementById('cookie-banner').classList.add('d-none');
  }
}
