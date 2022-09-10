import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'
import DatagridStringFilter from 'components/datagrid_string_filter';
import DatagridEnumFilter from 'components/datagrid_enum_filter';

export default class extends Controller {
  filterOpen(event) {
    // get values for filter
    let target = event.target.closest('.filter-button');

    if(target.popover) {
      target.popover.dispose();
      target.popover = null;
    } else {
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
      closeButton.dataset.action = 'click->datagrid#filterCloseButtonClick';
      actionsWrapper.appendChild(closeButton);

      let filterInputId = `${target.dataset.gridName}_${target.dataset.columnName}`;

      let wrapper = null;
      let filter = null;
      switch (target.dataset.filterType) {
        case 'string':
          filter = new DatagridStringFilter(target, filterInputId);
          wrapper = filter.generateFilter();
          break;
        case 'enum':
          filter = new DatagridEnumFilter(target, filterInputId);
          wrapper = filter.generateFilter();
          break;
      }
      target.filter = filter;

      // Show filter popup
      let options = {
        title: header,
        content: wrapper,
        placement: 'bottom',
        html: true,
        container: target.parentElement
      };

      let popover = new bootstrap.Popover(target, options);
      popover.show();

      target.popover = popover;
    }
  }

  inputKeyDown(event) {
    // keyCode == 13 => ENTER Key
    if(event.keyCode == 13) {
      let target = event.target.closest('th').querySelector('.filter-button');
      target.filter.search();
    }
    // keyCode == 13 => ESC Key
    if(event.keyCode == 27) {
      let target = event.target.closest('th').querySelector('.filter-button');
      target.popover.dispose();
      target.popover = null;
    }
  }

  searchButtonClick(event) {
    let target = event.target.closest('th').querySelector('.filter-button');
    target.filter.search();
  }

  filterReset(event) {
    let target = event.target.closest('th').querySelector('.filter-button');
    target.filter.reset();
  }

  filterCloseButtonClick(event) {
    let target = event.target.closest('th').querySelector('.filter-button');
    target.popover.dispose();
  }
}
