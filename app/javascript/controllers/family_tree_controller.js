import { Controller } from '@hotwired/stimulus'
import Tree from 'components/tree';
import panzoom from 'panzoom'

export default class extends Controller {

  async connect() {
    this.svg = document.querySelector("svg#family-tree g#scene");
    panzoom(this.svg);

    const windowStyle = window.getComputedStyle(document.body);
    const layoutConfig = {
      xGap: 100,
      yGap: 100,
      nodeWidth: 200,
      nodeHight: 100,
      spouseGap: 20,
      pathColor: windowStyle.getPropertyValue("--bs-gray-100"),
      pathHighlightColor: windowStyle.getPropertyValue("--bs-info")
    };
    this.tree = new Tree(layoutConfig);
  }

  search(event) {
    event.preventDefault();
    const searchString = document.querySelector("#search-wrapper input").value;
    this.tree.search(searchString);
  }
}
