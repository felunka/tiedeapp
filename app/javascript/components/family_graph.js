export default class FamilyGraph {
  constructor(treeData) {
    this.graph = {};

    treeData.forEach(person => this.traverseTree(person));
  }

  addConnection(person1, person2) {
    const id1 = person1.extra.db_id;
    const id2 = person2.extra.db_id;
    
    if (!this.graph[id1]) this.graph[id1] = [];
    if (!this.graph[id2]) this.graph[id2] = [];
    
    this.graph[id1].push(id2);
    this.graph[id2].push(id1);
  }

  traverseTree(node) {
    if (!node || !node.extra || !node.extra.db_id) return;

    // Traverse marriages
    if (node.marriages && node.marriages.length > 0) {
      node.marriages.forEach(marriage => {
        const spouse = marriage.spouse;
        if (spouse && spouse.extra && spouse.extra.db_id) {
          this.addConnection(node, spouse);
        }

        // Traverse children
        if (marriage.children && marriage.children.length > 0) {
          marriage.children.forEach(child => {
            this.addConnection(node, child);
            this.traverseTree(child);  // Recursively traverse the children
          });
        }
      });
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
        const neighbors = this.graph[node] || [];
        neighbors.forEach(neighbor => {
          const newPath = [...path, neighbor];
          queue.push(newPath);
        });
      }
    }

    return null;  // Return null if no path is found
  };

};
