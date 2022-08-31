import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  filterOpen(event) {
    // get values for filter
    let target = event.target.closest('.filter-button');
    let filterInputId = `${target.dataset.gridName}_${target.dataset.columnName}`;

    // Create filter input
    let header = document.createElement('div');
    header.classList.add('d-flex', 'justify-content-between', 'align-items-center');

    let title = document.createElement('span');
    title.innerText = I18n.datagrid.filters.title;
    header.appendChild(title);

    let actionsWrapper = document.createElement('div');
    actionsWrapper.classList.add('d-flex', 'filter-header-actions');
    header.appendChild(actionsWrapper);

    let clearButton = document.createElement('i');
    clearButton.classList.add('fa-solid', 'fa-arrow-rotate-left');
    clearButton.dataset.action = 'click->datagrid#filterReset';
    actionsWrapper.appendChild(clearButton);

    let closeButton = document.createElement('i');
    closeButton.classList.add('filter-close-button', 'fa-solid', 'fa-times');
    closeButton.dataset.action = 'click->datagrid#filterClose';
    actionsWrapper.appendChild(closeButton);

    let wrapper = document.createElement('div');
    wrapper.classList.add('input-group');

    let input = document.createElement('input');
    input.classList.add('form-control');
    input.dataset.action = 'keydown->datagrid#inputKeyDown';
    input.type = 'text';
    input.placeholder = target.dataset.label;
    let filterInput = document.getElementById(filterInputId);
    input.value = filterInput.value;
    wrapper.appendChild(input);

    let button = document.createElement('a');
    button.role = 'button';
    button.dataset.action = 'click->datagrid#searchButtonClick';
    button.dataset.filterInputId = filterInputId;
    button.classList.add('btn', 'btn-outline-primary');
    wrapper.appendChild(button);

    let icon = document.createElement('i');
    icon.classList.add('fa-solid', 'fa-magnifying-glass');
    button.appendChild(icon);

    // Show filter popup
    let options = {
      title: header,
      content: wrapper,
      placement: 'bottom',
      html: true,
      trigger: 'focus',
      container: target.parentElement
    };

    let popover = new bootstrap.Popover(target, options);
    popover.show();
  }

  inputKeyDown(event) {
    console.log(event.keyCode);
    // keyCode == 13 => ENTER Key
    if(event.keyCode == 13) {
      let target = event.target.parentElement.querySelector('a');
      this.search(target);
    }
    // keyCode == 13 => ESC Key
    if(event.keyCode == 27) {
      this.filterClose(event);
    }
  }

  searchButtonClick(event) {
    let target = event.target;
    if(event.target.tagName != 'A') {
      target = target.closest('a');
    }
    this.search(target);
  }

  search(target) {
    let filterValue = target.closest('.popover').querySelector('input').value;
    let filterInput = document.getElementById(target.dataset.filterInputId);
    filterInput.value = filterValue;
    filterInput.closest('form').submit();
  }

  filterReset(event) {
    let target = event.target.closest('.popover').querySelector('a');
    let filterInput = document.getElementById(target.dataset.filterInputId);
    filterInput.value = '';
    filterInput.closest('form').submit();
  }

  filterClose(event) {
    let popover = bootstrap.Popover.getInstance(event.target.closest('.popover'));
    popover.dispose();
  }
}
