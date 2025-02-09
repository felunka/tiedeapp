import { Controller } from '@hotwired/stimulus'
import Tree from 'components/tree';

export default class extends Controller {

  async connect() {
    const treeData = ;

    this.svg = document.getElementById("family-tree");
    this.viewBox = { x: 0, y: 0, width: this.svg.clientWidth, height: this.svg.clientHeight };
    this.isPanning = false;
    this.startX = 0
    this.startY = 0;
    this.zoomFactor = 1.1; // Zoom in/out factor

    // Apply initial viewBox
    this.updateSvg();

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
    this.tree = new Tree(treeData, layoutConfig);
  }

  zoom(event) {
    event.preventDefault();

    const scale = event.deltaY < 0 ? 1 / this.zoomFactor : this.zoomFactor; // Zoom in or out
    const mouseX = event.offsetX / this.svg.clientWidth * this.viewBox.width + this.viewBox.x;
    const mouseY = event.offsetY / this.svg.clientHeight * this.viewBox.height + this.viewBox.y;

    // Adjust the viewBox to zoom in or out
    this.viewBox.width *= scale;
    this.viewBox.height *= scale;
    this.viewBox.x = mouseX - (mouseX - this.viewBox.x) * scale;
    this.viewBox.y = mouseY - (mouseY - this.viewBox.y) * scale;

    this.updateSvg();
  }

  dragStart(event) {
    event.preventDefault();
    this.isPanning = true;
    this.startX = event.clientX;
    this.startY = event.clientY;
  }

  pan(event) {
    if (!this.isPanning) return;

    const dx = (event.clientX - this.startX) * (this.viewBox.width / this.svg.clientWidth);
    const dy = (event.clientY - this.startY) * (this.viewBox.height / this.svg.clientHeight);

    this.viewBox.x -= dx;
    this.viewBox.y -= dy;

    this.updateSvg();

    this.startX = event.clientX;
    this.startY = event.clientY;
  }

  dragStop(_) {
    this.isPanning = false;
  }

  updateSvg() {
    this.svg.setAttribute("viewBox", `${this.viewBox.x} ${this.viewBox.y} ${this.viewBox.width} ${this.viewBox.height}`);
  }

  search(event) {
    event.preventDefault();
    const searchString = document.querySelector("#search-wrapper input").value;
    this.tree.search(searchString);
  }
}
