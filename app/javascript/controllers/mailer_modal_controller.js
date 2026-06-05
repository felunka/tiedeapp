import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.selectChanged();
  }

  selectChanged() {
    if( document.getElementById('mail_job_template_custom').checked ) {
      document.querySelector('.mailer-modal-custom-text-block').classList.remove('d-none');
    } else {
      document.querySelector('.mailer-modal-custom-text-block').classList.add('d-none');
    }

    if( document.getElementById('mail_job_recipient_selection_strategy_select_members').checked ) {
      document.querySelector('.mailer-modal-member-select').classList.remove('d-none');
      document.querySelector('.mailer-modal-group-select').classList.add('d-none');
    } else {
      document.querySelector('.mailer-modal-member-select').classList.add('d-none');
      document.querySelector('.mailer-modal-group-select').classList.remove('d-none');
    }
  }
}
