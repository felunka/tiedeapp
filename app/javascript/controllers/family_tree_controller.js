import { Controller } from '@hotwired/stimulus'
import Tree from 'components/tree';

export default class extends Controller {

  async connect() {
    const treeData = {};

    const svg = document.getElementById("family-tree");
    let viewBox = { x: 0, y: 0, width: svg.clientWidth, height: svg.clientHeight };
    let isPanning = false;
    let startX = 0, startY = 0;
    let zoomFactor = 1.1; // Zoom in/out factor

    // Apply initial viewBox
    svg.setAttribute("viewBox", `${viewBox.x} ${viewBox.y} ${viewBox.width} ${viewBox.height}`);

    // Mouse wheel zooming
    svg.addEventListener("wheel", (event) => {
      event.preventDefault();

      const scale = event.deltaY < 0 ? 1 / zoomFactor : zoomFactor; // Zoom in or out
      const mouseX = event.offsetX / svg.clientWidth * viewBox.width + viewBox.x;
      const mouseY = event.offsetY / svg.clientHeight * viewBox.height + viewBox.y;

      // Adjust the viewBox to zoom in or out
      viewBox.width *= scale;
      viewBox.height *= scale;
      viewBox.x = mouseX - (mouseX - viewBox.x) * scale;
      viewBox.y = mouseY - (mouseY - viewBox.y) * scale;

      svg.setAttribute("viewBox", `${viewBox.x} ${viewBox.y} ${viewBox.width} ${viewBox.height}`);
    });

    // Mouse drag panning
    svg.addEventListener("mousedown", (event) => {
      event.preventDefault();
      isPanning = true;
      startX = event.clientX;
      startY = event.clientY;
    });

    svg.addEventListener("mousemove", (event) => {
      if (!isPanning) return;

      const dx = (event.clientX - startX) * (viewBox.width / svg.clientWidth);
      const dy = (event.clientY - startY) * (viewBox.height / svg.clientHeight);

      viewBox.x -= dx;
      viewBox.y -= dy;

      svg.setAttribute("viewBox", `${viewBox.x} ${viewBox.y} ${viewBox.width} ${viewBox.height}`);

      startX = event.clientX;
      startY = event.clientY;
    });

    svg.addEventListener("mouseup", () => {
      isPanning = false;
    });

    svg.addEventListener("mouseleave", () => {
      isPanning = false;
    });

    const layoutConfig = {
      xGap: 100,
      yGap: 100,
      nodeWidth: 200,
      nodeHight: 50,
      spouseGap: 20,
      nodeColor: "red",
      nodeSelectedColor: "blue",
      nodePathColor: "lightblue",
      pathColor: "white",
      pathHighlightColor: "red"
    };
    const tree = new Tree(treeData, layoutConfig);
  }
}
