import Node from 'components/node';
import _initWasm, { Tidy } from 'tidy_layout/wasm';
import TreeLayout from 'components/tree_layout';

function parseDate(dateStr) {
  if (!dateStr) return null;
  const dotMatch = dateStr.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
  if (dotMatch) return new Date(dotMatch[3], dotMatch[2] - 1, dotMatch[1]);
  const parsed = new Date(dateStr);
  return isNaN(parsed) ? null : parsed;
}

function compareDates(a, b) {
  if (a === null && b === null) return 0;
  if (a === null) return 1;
  if (b === null) return -1;
  return a - b;
}

function marriageSortDate(marriage) {
  let earliest = null;
  for (const child of marriage.children) {
    const d = parseDate(child.date_of_birth);
    if (d && (earliest === null || d < earliest)) earliest = d;
  }
  return earliest || parseDate(marriage.spouse.date_of_birth);
}

function preprocessData(data) {
  for (const marriage of data.marriages) {
    marriage.children.sort((a, b) =>
      compareDates(parseDate(a.date_of_birth), parseDate(b.date_of_birth))
    );
    marriage.children.forEach(child => preprocessData(child));
  }

  data.marriages.sort((a, b) => {
    const da = marriageSortDate(a);
    const db = marriageSortDate(b);
    if (da === null || db === null) return 0;
    return da - db;
  });
}

export default class Tree {

  constructor(layoutConfig) {
    this.layoutConfig = layoutConfig;
    this.selectedNodes = [];
    this.init();
  }

  async init() {
    let promise = _initWasm();

    const response = await fetch("family-tree/data");
    const treeData = await response.json();

    // Wait for wasm init to be completed
    await promise;
    // Preprocess: sort marriages and children by birth date
    preprocessData(treeData);
    // Build tree from JSON
    this.root = this.addToTree(treeData, null);

    // Calculate layout using tidy algorithm
    const layout = new TreeLayout(this.layoutConfig);
    const layoutResult = layout.buildLayout(this.root);
    this.idToNode = layoutResult.idToNode;
    this.houseAreas = layoutResult.houseAreas;

    // Render tree
    this.render();
  }

  addToTree(member, parent, parentSpouse = null) {
    const node = new Node(
      this.layoutConfig,
      member.id,
      parent,
      member.name,
      member.date_of_birth,
      member.date_of_death,
      member.comment,
      Tidy.null_id(),
      parentSpouse = parentSpouse
    );

    // Assign house: use member's house if present, otherwise inherit from parent
    if (member.house) {
      node.house = member.house;
    } else if (parent && parent.house) {
      node.house = parent.house;
    }

    let children = [];
    member.marriages.forEach((marriage) => {
      const spouseNode = new Node(
        this.layoutConfig,
        marriage.spouse.id,
        node,
        marriage.spouse.name,
        marriage.spouse.date_of_birth,
        marriage.spouse.date_of_death,
        marriage.spouse.comment,
        Tidy.null_id()
      );
      if (node.house) spouseNode.house = node.house;
      node.spouseNodes.push(spouseNode);

      marriage.children.forEach(child => {
        children.push(this.addToTree(child, node, spouseNode));
      });
    });
    node.children = children;

    return node;
  }

  render() {
    // Draw house areas
    const xPadding = Math.floor(this.layoutConfig.xGap / 3);
    const yPadding = Math.floor(this.layoutConfig.yGap / 4);
    this.houseAreas.forEach((houseArea) => {
      const scene = document.querySelector("svg#family-tree g#scene");
      const x = houseArea.x - xPadding;
      const y = houseArea.y - yPadding;
      const width = houseArea.width + (2 * xPadding);
      const height = houseArea.height + (2 * yPadding);

      const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
      rect.setAttribute("x", x);
      rect.setAttribute("y", y);
      rect.setAttribute("width", width);
      rect.setAttribute("height", height);
      rect.setAttribute("rx", 6);
      rect.setAttribute("ry", 6);
      rect.setAttribute("fill", "none");
      rect.setAttribute("stroke", this.layoutConfig.houseAreaBorderColor);
      rect.setAttribute("stroke-width", 3);
      scene.appendChild(rect);

      const label = document.createElementNS("http://www.w3.org/2000/svg", "text");
      label.textContent = window.I18n.simple_form.options.defaults.family_house_origin[houseArea.house];
      label.setAttribute("x", x + width - 12);
      label.setAttribute("y", y + height - 12);
      label.setAttribute("text-anchor", "end");
      label.setAttribute("fill", "white");
      label.setAttribute("font-size", "2.5rem");
      scene.appendChild(label);
    });

    this.root.render();

    document.querySelectorAll("#family-tree .node").forEach((nodeEl) => {
      const id = parseInt(nodeEl.dataset.nodeId);
      if (id) {
        nodeEl.addEventListener("click", (_) => {
          this.nodeClick(id);
        });
        // Touch tap detection: only trigger if touch is short and no movement
        let touchStartTime = 0;
        let touchMoved = false;
        let touchStartX = 0;
        let touchStartY = 0;

        nodeEl.addEventListener("touchstart", (e) => {
          if (e.touches.length === 1) {
            touchStartTime = Date.now();
            touchMoved = false;
            touchStartX = e.touches[0].clientX;
            touchStartY = e.touches[0].clientY;
          }
        }, { passive: true });

        nodeEl.addEventListener("touchmove", (e) => {
          if (e.touches.length === 1) {
            const dx = e.touches[0].clientX - touchStartX;
            const dy = e.touches[0].clientY - touchStartY;
            if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
              touchMoved = true;
            }
          }
        }, { passive: true });

        nodeEl.addEventListener("touchend", (e) => {
          const touchDuration = Date.now() - touchStartTime;
          if (!touchMoved && touchDuration < 300) {
            e.preventDefault();
            this.nodeClick(id);
          }
        }, { passive: false });
      }
    });

    document.querySelector("#family-tree-wrapper .spinner-border").remove();
  }

  resetHighlights() {
    document.querySelectorAll("#family-tree .node").forEach((nodeEl) => {
      nodeEl.classList.remove("selected");
      nodeEl.classList.remove("in-path");
    });

    document.querySelectorAll("#connector-lines path").forEach(nodeElement => {
      if (nodeElement.dataset.highlight) {
        nodeElement.remove();
      }
    });
  }

  search(searchString) {
    searchString = searchString.toLowerCase();

    this.selectedNodes = [];
    this.resetHighlights();

    this.idToNode.forEach((node, _) => {
      if (node.name.toLowerCase().includes(searchString)) {
        node.rect.classList.add("selected");
      }
    })
  }

  nodeClick(id) {
    this.resetHighlights();

    // Add the selected node in to the list of selected ids, only keep the 2 newest ids
    this.selectedNodes.push(id);
    if (this.selectedNodes.length > 2) {
      this.selectedNodes.shift();
    }
    this.selectedNodes.forEach((selectedId) => {
      this.idToNode.get(selectedId).rect.classList.add("selected");
    });

    if (this.selectedNodes.length === 2) {
      // Find new path
      const shortestPath = this.bfs(this.idToNode.get(this.selectedNodes[0]), this.idToNode.get(this.selectedNodes[1]));
      // Highlight new path nodes
      if (shortestPath) {
        shortestPath.forEach(pathNode => {
          if (this.selectedNodes.includes(pathNode.id)) {
            pathNode.rect.classList.add("selected");
          } else {
            pathNode.rect.classList.add("in-path");
          }

          if (shortestPath.includes(pathNode.parent)) {
            // Color correct partner if present
            if (pathNode.parentSpouse) {
              pathNode.parentSpouse.rect.classList.add("in-path");
            }
            pathNode.drawConnector(null, this.layoutConfig.pathHighlightColor, { highlight: true });
          }
        });
      }
    }
  }

  bfs(start, end) {
    const queue = [[start]];
    const visited = new Set();

    while (queue.length > 0) {
      const path = queue.shift();
      const node = path[path.length - 1];

      if (node === end) {
        return path;
      }

      if (!visited.has(node)) {
        visited.add(node);
        const neighbors = node.children || [];
        if (node.parent) {
          neighbors.push(node.parent);
        }
        neighbors.forEach(neighbor => {
          const newPath = [...path, neighbor];
          queue.push(newPath);
        });
      }
    }

    return null;
  }
}
