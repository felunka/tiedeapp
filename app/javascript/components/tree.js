import Node from 'components/node';
import _initWasm, { Tidy } from 'wasm_dist/wasm';

export default class Tree {

  constructor(treeData, layoutConfig) {
    this.layoutConfig = layoutConfig;
    this.init(treeData);
  }

  async init(treeData) {
    let promise = _initWasm();

    this.root = this.addToTree(treeData, null);

    await promise;
    this.tidy = Tidy.with_layered_tidy(this.layoutConfig.yGap, this.layoutConfig.xGap);

    this.idToNode = new Map();
    this.buildLayout();

    this.tidy.layout();
    const positions = this.tidy.get_pos();
    let minX = 0;
    let minY = 0;
    for (let i = 0; i < positions.length; i += 3) {
      const id = positions[i] | 0;
      const node = this.idToNode.get(id);
      node.x = positions[i + 1];
      node.y = positions[i + 2];

      if (node.x < minX) {
        minX = node.x;
      }
      if (node.y < minY) {
        minY = node.y;
      }
    }

    this.root.shiftPos(minX, minY);

    this.render();
  }

  addToTree(member, parent, parentIndex = 0) {
    const id = member.id.charCodeAt(0) * 100 + parseInt(member.id.substring(2));
    const node = new Node(this.layoutConfig, id, member.id, parent, member.name, 1, parentIndex = parentIndex);

    let children = [];
    member.marriages.forEach((marriage, index) => {
      node.spouses.push(marriage.spouse.name);
      marriage.children.forEach(child => {
        children.push(this.addToTree(child, node, index));
      })
    });
    node.children = children;

    return node;
  }

  buildLayout() {
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
      this.idToNode.set(node.id, node);
      for (const child of node.children.concat().reverse()) {
        if (child.parentId == null) {
          child.parentId = node.id;
        }

        stack.push(child);
      }
    }

    this.tidy.data(
      new Uint32Array(ids),
      new Float64Array(width),
      new Float64Array(height),
      new Uint32Array(parents),
    );
  }

  render() {
    this.root.render();

    let selectedNodes = [];

    document.querySelectorAll("#family-tree rect").forEach((nodeEl) => {
      const id = parseInt(nodeEl.dataset.nodeId);
      const element = nodeEl;
      if (id) {
        nodeEl.addEventListener("click", (_) => {
          element.setAttribute("fill", this.layoutConfig.nodeSelectedColor);

          // Add the selected node in to the list of selected ids, only keep the 2 newest ids
          selectedNodes.push(id);
          if (selectedNodes.length > 2) {
            const unselectElement = this.idToNode.get(selectedNodes.shift()).rect;
            unselectElement.setAttribute("fill", this.layoutConfig.nodeColor);
          }

          if (selectedNodes.length === 2) {
            // Clear any old path
            document.querySelectorAll("#family-tree rect").forEach(nodeElement => {
              nodeElement.setAttribute("fill", this.layoutConfig.nodeColor);
            });
            document.querySelectorAll("#connector-lines path").forEach(nodeElement => {
              if (nodeElement.dataset.highlight) {
                nodeElement.remove();
              }
            });
            // Find new path
            const shortestPath = this.bfs(this.idToNode.get(selectedNodes[0]), this.idToNode.get(selectedNodes[1]));
            // Highlight new path nodes
            if (shortestPath) {
              shortestPath.forEach(pathNode => {
                pathNode.rect.setAttribute("fill", this.layoutConfig.nodePathColor);
                if (shortestPath.includes(pathNode.parent)) {
                  pathNode.drawConnector(null, this.layoutConfig.pathHighlightColor, { highlight: true });
                }
              });
            }
          }
        });
      }
    });
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
