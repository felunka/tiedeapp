import { Controller } from '@hotwired/stimulus'
import _ from "lodash";
window._ = _;
import dTree from "d3-dtree";

import FamilyGraph from 'components/family_graph'

export default class extends Controller {

  connect() {
    const treeData = [{
      "name": "Niclas Superlongsurname",
      "extra": {
        "db_id": 1
      },
      "marriages": [{
        "spouse": {
          "name": "Iliana",
          "extra": {
            "db_id": 2
          },
        },
        "children": [{
          "name": "James",
          "extra": {
            "db_id": 3
          },
          "marriages": [{
            "spouse": {
              "name": "Alexandra",
              "extra": {
                "db_id": 4
              },
            },
            "children": [{
              "name": "Eric",
              "extra": {
                "db_id": 11
              },
              "marriages": [{
                "spouse": {
                  "name": "Eva",
                  "extra": {
                    "db_id": 5
                  },
                },
                "children": [{
                  "name": "Oliver",
                  "extra": {
                    "db_id": 20
                  },
                  "marriages": [{
                    "spouse": {
                      "name": "Lily",
                      "extra": {
                        "db_id": 21
                      }
                    },
                    "children": [{
                      "name": "Ethan",
                      "extra": {
                        "db_id": 30
                      }
                    }, {
                      "name": "Sophia",
                      "extra": {
                        "db_id": 31
                      }
                    }]
                  }]
                }, {
                  "name": "Isla",
                  "extra": {
                    "db_id": 22
                  }
                }]
              }]
            }, {
              "name": "Jane",
              "extra": {
                "db_id": 6
              },
              "marriages": [{
                "spouse": {
                  "name": "Thomas",
                  "extra": {
                    "db_id": 23
                  }
                },
                "children": [{
                  "name": "Henry",
                  "extra": {
                    "db_id": 32
                  }
                }, {
                  "name": "Alice",
                  "extra": {
                    "db_id": 33
                  }
                }]
              }]
            }, {
              "name": "Jasper",
              "extra": {
                "db_id": 7
              },
              "marriages": [{
                "spouse": {
                  "name": "Chloe",
                  "extra": {
                    "db_id": 24
                  }
                },
                "children": [{
                  "name": "Lucas",
                  "extra": {
                    "db_id": 34
                  }
                }, {
                  "name": "Amelia",
                  "extra": {
                    "db_id": 35
                  }
                }]
              }]
            }, {
              "name": "Emma",
              "extra": {
                "db_id": 8
              },
              "marriages": [{
                "spouse": {
                  "name": "Benjamin",
                  "extra": {
                    "db_id": 25
                  }
                },
                "children": [{
                  "name": "Daniel",
                  "extra": {
                    "db_id": 36
                  }
                }, {
                  "name": "Grace",
                  "extra": {
                    "db_id": 37
                  }
                }]
              }]
            }, {
              "name": "Julia",
              "extra": {
                "db_id": 9
              },
              "marriages": [{
                "spouse": {
                  "name": "Michael",
                  "extra": {
                    "db_id": 26
                  }
                },
                "children": [{
                  "name": "Emily",
                  "extra": {
                    "db_id": 38
                  }
                }, {
                  "name": "Hannah",
                  "extra": {
                    "db_id": 39
                  }
                }]
              }]
            }, {
              "name": "Jessica",
              "extra": {
                "db_id": 10
              },
              "marriages": [{
                "spouse": {
                  "name": "David",
                  "extra": {
                    "db_id": 27
                  }
                },
                "children": [{
                  "name": "Jacob",
                  "extra": {
                    "db_id": 40
                  }
                }, {
                  "name": "Ella",
                  "extra": {
                    "db_id": 41
                  }
                }]
              }]
            }]
          }]
        }]
      }]
    }];


    const family_graph = new FamilyGraph(treeData);

    let nodesToDbMapping = {};
    let dbToNodeMapping = {}
    let selectedNodes = [];

    dTree.init(treeData, {
      target: "#family-tree",
      callbacks: {
        nodeClick: function (name, extra, id) {
          const element = document.getElementById(`node${id}`);
          element.classList.toggle("selected");

          // Add the selected node in to the list of selected ids, only keep the 2 newest ids
          selectedNodes.push(id);
          if (selectedNodes.length > 2) {
            const unselectElement = document.getElementById(`node${selectedNodes.shift()}`);
            unselectElement.classList.remove("selected");
          }

          if (selectedNodes.length === 2) {
            // Clear any old path
            document.querySelectorAll("#family-tree foreignObject div").forEach(nodeElement => {
              nodeElement.classList.remove("in-path");
            });
            // Find new path
            const shortestPath = family_graph.bfs(nodesToDbMapping[selectedNodes[0]], nodesToDbMapping[selectedNodes[1]]);
            // Highlight new path nodes
            shortestPath.forEach(db_id => {
              let nodeId = dbToNodeMapping[db_id];
              if (!selectedNodes.includes(nodeId)) {
                const pathElement = document.getElementById(`node${nodeId}`);
                pathElement.classList.add("in-path");
              }
            });
          }
        },
        textRenderer: function (name, extra) {
          return `<p class="text-center">${name}</p>`;
        },
        nodeRenderer: function (name, x, y, height, width, extra, id, nodeClass, textClass, textRenderer) {
          nodesToDbMapping[id] = extra.db_id;
          dbToNodeMapping[extra.db_id] = id;

          let node = `
            <div id="node${id}" class="${nodeClass}">
              ${textRenderer(name, extra)}
            </div>
          `;

          return node;
        }
      }
    });
  }
}
