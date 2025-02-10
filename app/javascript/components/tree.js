import Node from 'components/node';
import _initWasm, { Tidy } from 'tidy_layout/wasm';

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

    // Build tree from JSON
    this.root = this.addToTree(treeData, null);

    // Wait for wasm init to be completed
    await promise;
    this.tidy = Tidy.with_layered_tidy(this.layoutConfig.yGap, this.layoutConfig.xGap);

    // Calculate layout using tidy algorithm
    this.idToNode = this.buildLayout();

    // Assign position to nodes
    const positions = this.tidy.get_pos();
    for (let i = 0; i < positions.length; i += 3) {
      const id = positions[i] | 0;
      const node = this.idToNode.get(id);
      node.x = positions[i + 1];
      node.y = positions[i + 2];

      // Assign spouse nodes
      node.spouseNodes.forEach((spouseNode, index) => {
        spouseNode.x = node.x + (index + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap);
        spouseNode.y = node.y;
      });
    }

    // Render tree
    this.render();
  }

  addToTree(member, parent, parentIndex = 0) {
    const node = new Node(
      this.layoutConfig,
      member.id,
      parent,
      member.name,
      member.date_of_birth,
      member.date_of_death,
      Tidy.null_id(),
      parentIndex = parentIndex
    );

    let children = [];
    member.marriages.forEach((marriage, index) => {
      const spouseNode = new Node(
        this.layoutConfig,
        marriage.id,
        parent,
        marriage.name,
        marriage.date_of_birth,
        marriage.date_of_death,
        Tidy.null_id()
      );
      node.spouseNodes.push(spouseNode);

      node.spouses.push(marriage.spouse.name);
      marriage.children.forEach(child => {
        children.push(this.addToTree(child, node, index));
      });
    });
    node.children = children;

    return node;
  }

  buildLayout() {
    const idToNode = new Map();
    const stack = [this.root];
    const ids = [];
    const width = [];
    const height = [];
    const parents = [];
    while (stack.length) {
      const node = stack.pop();

      ids.push(node.id);
      width.push(node.getGroupWidth());
      height.push(this.layoutConfig.nodeHight);
      parents.push(node.parentId);
      idToNode.set(node.id, node);
      for (const child of node.children.concat().reverse()) {
        if (child.parentId == null) {
          child.parentId = node.id;
        }

        stack.push(child);
      }
    }

    // Pass data to wasm tidy layout algorithm and calculate positions
    this.tidy.data(
      new Uint32Array(ids),
      new Float64Array(width),
      new Float64Array(height),
      new Uint32Array(parents),
    );
    this.tidy.layout();

    return idToNode;
  }

  render() {
    this.root.render();

    document.querySelectorAll("#family-tree .node").forEach((nodeEl) => {
      const id = parseInt(nodeEl.dataset.nodeId);
      if (id) {
        nodeEl.addEventListener("click", (_) => {
          this.nodeClick(id);
        });
      }
    });

    document.querySelector("#family-tree-wrapper i.loading").remove();
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

      node.spouses.forEach((spouseName, index) => {
        if (spouseName.toLowerCase().includes(searchString)) {
          node.spouseElements[index].classList.add("selected");
        }
      })
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
            if (pathNode.parent) {
              pathNode.parent.spouseElements[pathNode.parentIndex].classList.add("in-path");
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
