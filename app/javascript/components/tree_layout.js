import { Tidy } from 'tidy_layout/wasm';

export default class TreeLayout {

  constructor(layoutConfig) {
    this.layoutConfig = layoutConfig;
  }

  buildLayout(root) {
    // Step 1: Identify house roots
    const houseRoots = this.identifyHouseRoots(root);
    console.log(houseRoots)

    // Step 2: For each house, layout the subtree
    const houseSubtrees = new Map();
    for (const [house, houseRoot] of houseRoots) {
      houseSubtrees.set(house, this.layoutHouseSubtree(houseRoot));
    }

    // Step 3: Layout main tree (excluding members that aren't house roots or non-housed)
    const mainIdToNode = new Map();
    const ids = [];
    const widths = [];
    const heights = [];
    const parents = [];
    const visited = new Set();

    const buildMainTree = (node) => {
      if (visited.has(node.id)) return;
      visited.add(node.id);

      // Skip non-root house members (they'll be positioned in house subtrees)
      if (node.house && houseRoots.get(node.house) !== node) {
        return;
      }

      ids.push(node.id);

      // If this is a house root, use the house subtree dimensions
      if (node.house) {
        const houseDims = houseSubtrees.get(node.house);
        widths.push(houseDims.width);
        heights.push(houseDims.height);
      } else {
        widths.push(node.getGroupWidth());
        heights.push(this.layoutConfig.nodeHight);
      }

      parents.push(node.parentId);
      mainIdToNode.set(node.id, node);

      // Add children to tree, but skip non-root house members
      for (const child of node.children) {
        if (child.house && houseRoots.get(child.house) !== child) {
          continue;
        }
        if (child.parentId == null) {
          child.parentId = node.id;
        }
        buildMainTree(child);
      }
    };

    buildMainTree(root);

    // Run tidy on main tree
    const tidy = Tidy.with_layered_tidy(this.layoutConfig.yGap, this.layoutConfig.xGap);
    const positions = this.runTidy(tidy, ids, widths, heights, parents);
    for (let i = 0; i < positions.length; i += 3) {
      const id = positions[i] | 0;
      const node = mainIdToNode.get(id);
      if (node) {
        const tidyWidth = node.house ? houseSubtrees.get(node.house).width : node.getGroupWidth();
        node.x = positions[i + 1] - tidyWidth / 2;
        node.y = positions[i + 2];

        // Position spouse nodes relative to the main node
        // But skip if this node is a house root (spouses will be positioned via house layout)
        if (!node.house) {
          this.positionSpouses(node);
        }
      }
    }

    // Step 4: Collect all nodes and create final map
    const idToNode = this.collectAllNodes(root);

    // Step 5: Apply house subtree positions with offset from house root position
    const houseAreas = this.applyHousePositions(houseRoots, houseSubtrees, idToNode);

    return { idToNode, houseAreas };
  }

  layoutHouseSubtree(houseRoot) {
    const idToNode = new Map();
    const ids = [];
    const widths = [];
    const heights = [];
    const parents = [];
    const visited = new Set();

    const buildSubtree = (node) => {
      if (visited.has(node.id)) return;
      visited.add(node.id);

      ids.push(node.id);
      widths.push(node.getGroupWidth());
      heights.push(this.layoutConfig.nodeHight);
      parents.push(node.parentId);
      idToNode.set(node.id, node);

      // Add children that have the same house
      for (const child of node.children) {
        if (child.house === houseRoot.house) {
          buildSubtree(child);
        }
      }
    };

    buildSubtree(houseRoot);

    // Run tidy on house subtree
    const tidy = Tidy.with_layered_tidy(this.layoutConfig.yGap, this.layoutConfig.xGap);
    const positions = this.runTidy(tidy, ids, widths, heights, parents);

    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;

    for (let i = 0; i < positions.length; i += 3) {
      const id = positions[i] | 0;
      const node = idToNode.get(id);
      if (node) {
        node.x = positions[i + 1] - node.getGroupWidth() / 2;
        node.y = positions[i + 2];

        this.positionSpouses(node);
        node.spouseNodes.forEach(spouseNode => idToNode.set(spouseNode.id, spouseNode));

        minX = Math.min(minX, node.x);
        minY = Math.min(minY, node.y);
        maxX = Math.max(maxX, node.x + node.getGroupWidth());
        maxY = Math.max(maxY, node.y + this.layoutConfig.nodeHight);
      }
    }

    // Handle case where there's only one node
    if (minX === Infinity) {
      minX = 0;
      minY = 0;
      maxX = houseRoot.getGroupWidth();
      maxY = this.layoutConfig.nodeHight;
    }

    return {
      idToNode,
      width: maxX - minX,
      height: maxY - minY,
      offsetX: minX,
      offsetY: minY,
      rootX: houseRoot.x,
      rootY: houseRoot.y,
    };
  }

  // --- Shared helpers ---

  runTidy(tidy, ids, widths, heights, parents) {
    tidy.data(
      new Uint32Array(ids),
      new Float64Array(widths),
      new Float64Array(heights),
      new Uint32Array(parents),
    );
    tidy.layout();
    return tidy.get_pos();
  }

  positionSpouses(node) {
    node.spouseNodes.forEach((spouseNode, index) => {
      spouseNode.x = node.x + (index + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap);
      spouseNode.y = node.y;
    });
  }

  collectAllNodes(root) {
    const idToNode = new Map();
    const collect = (node) => {
      idToNode.set(node.id, node);
      node.spouseNodes.forEach(spouse => idToNode.set(spouse.id, spouse));
      node.children.forEach(child => collect(child));
    };
    collect(root);
    return idToNode;
  }

  identifyHouseRoots(root) {
    const houseRoots = new Map();
    const walk = (node) => {
      if (node.house && !houseRoots.has(node.house)) {
        houseRoots.set(node.house, node);
      }
      node.spouseNodes.forEach(spouse => {
        if (spouse.house && !houseRoots.has(spouse.house)) {
          houseRoots.set(spouse.house, spouse);
        }
      });
      node.children.forEach(child => walk(child));
    };
    walk(root);
    return houseRoots;
  }

  applyHousePositions(houseRoots, houseSubtrees, idToNode) {
    const houseAreas = [];
    for (const [house, houseLayout] of houseSubtrees) {
      const houseRoot = houseRoots.get(house);
      // houseRoot.x/y is the top-left of the bounding box allocated by the main tree.
      // Save it before we overwrite the house root's position.
      const anchorX = houseRoot.x;
      const anchorY = houseRoot.y;

      // Track house area for debugging
      houseAreas.push({
        house: house,
        x: anchorX,
        y: anchorY,
        width: houseLayout.width,
        height: houseLayout.height,
      });

      for (const [nodeId, subNode] of houseLayout.idToNode) {
        const node = idToNode.get(nodeId);
        if (node) {
          if (nodeId === houseRoot.id) {
            // House root's subtree position was overwritten by the main tree layout,
            // so use the saved rootX/rootY from the subtree layout.
            node.x = anchorX + (houseLayout.rootX - houseLayout.offsetX);
            node.y = anchorY + (houseLayout.rootY - houseLayout.offsetY);
          } else {
            // Other house members still have their subtree positions on subNode.
            node.x = anchorX + (subNode.x - houseLayout.offsetX);
            node.y = anchorY + (subNode.y - houseLayout.offsetY);
          }
        }
      }
    }
    return houseAreas;
  }
}
