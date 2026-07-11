export default class Node {

  constructor(layoutConfig, id, parent, name, birthDate, deathDate, comment, nullId, parentSpouse = null) {
    this.layoutConfig = layoutConfig;

    this.id = id;

    this.parent = parent;
    this.parentSpouse = parentSpouse;
    
    if (this.parent) {
      this.parentId = parent.id;
    } else {
      this.parentId = nullId;
    }

    this.name = name;
    this.birthDate = birthDate;
    this.deathDate = deathDate;
    this.comment = comment;

    this.spouseNodes = [];
    this.children = [];

    this.spouseVSplitMap = new Map();

    // Safari has special needs to allow the elements to pan correctly
    this.isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  }

  centerX() {
    return this.x + this.layoutConfig.nodeWidth / 2;
  }

  centerY() {
    return this.y + this.layoutConfig.nodeHight / 2;
  }

  getGroupWidth() {
    return this.layoutConfig.nodeWidth + (this.spouseNodes.length + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap);
  }

  shiftPos(minX, minY) {
    this.x -= minX;
    this.y -= minY;

    this.children.forEach(child => child.shiftPos(minX, minY));
  }

  render() {
    this.rect = this.drawRect(this.x, this.y, this.name, { nodeId: this.id });

    this.spouseNodes.forEach((spouseNode, index) => {
      spouseNode.render();
      spouseNode.drawTag(`Partner ${index+1}`);
    });

    // Link to parents
    if (this.parent) {
      this.drawConnector();
    }

    this.children.forEach(child => child.render());
  }

  drawTag(text) {
    const tagHeight = 24;
    const tagOverlap = 6;

    const wrapper = document.createElementNS("http://www.w3.org/2000/svg", "foreignObject");
    
    wrapper.setAttribute("x", this.x);
    wrapper.setAttribute("y", this.y-tagHeight+tagOverlap);
    wrapper.setAttribute("width", this.layoutConfig.nodeWidth);
    wrapper.setAttribute("height", tagHeight);

    const div = document.createElement("div");
    div.classList.add("badge");
    div.classList.add("bg-secondary");
    div.innerText = text;
    wrapper.appendChild(div);
    document.querySelector("svg#family-tree g#scene").appendChild(wrapper);

    return div;
  }

  drawRect(x, y, text, data = {}) {
    const wrapper = document.createElementNS("http://www.w3.org/2000/svg", "foreignObject");
    
    wrapper.setAttribute("x", x);
    wrapper.setAttribute("y", y);
    wrapper.setAttribute("width", this.layoutConfig.nodeWidth);
    wrapper.setAttribute("height", this.layoutConfig.nodeHight);
    
    const div = document.createElement("div");
    div.classList.add("node");
    if(this.isSafari) {
      div.style.position = "unset";
    }

    const span = document.createElement("span");
    span.innerText = text;
    div.appendChild(span);

    Object.assign(div.dataset, data);

    const ul = document.createElement("ul");
    ul.classList.add("list-group");
    ul.classList.add("list-group-flush");
    div.appendChild(ul);

    if(this.comment) {
      ul.appendChild(this.iconRow("bi-chat-left-fill", this.comment));
    }
    if(this.birthDate) {
      ul.appendChild(this.iconRow("bi-cake-fill", this.birthDate));
    }
    if(this.deathDate) {
      ul.appendChild(this.iconRow("bi-plus", this.deathDate));
    }

    wrapper.appendChild(div);
    document.querySelector("svg#family-tree g#scene").appendChild(wrapper);

    return div;
  }

  // Returns the Y coordinate of the horizontal segment used by connector lines
  // from a specific marriage to its children. Each marriage gets a distinct Y level
  // so that connector lines from different marriages don't overlap.
  // The result is cached per spouse so all children of the same marriage share
  // the same horizontal routing level.
  getVSplitFor(spouse, child) {
    if(this.spouseVSplitMap.has(spouse)) {
      return this.spouseVSplitMap.get(spouse);
    } else {
      // X position of the gap between parent and spouse (where the connector starts)
      const startX = spouse.centerX() - (this.layoutConfig.nodeWidth+this.layoutConfig.spouseGap)/2;
      // Which marriage this is (0 = first spouse, 1 = second, etc.)
      const parentIndex = this.spouseNodes.indexOf(spouse);
      // Base split: starting point between parent and child vertically
      let vSplit = (this.centerY() + child.centerY()) / 2;
      // Offset each marriage's routing level so lines don't overlap.
      // Direction depends on whether the child is left or right of the
      // connection point, so lines fan outward cleanly in both directions.
      if(startX < child.centerX()) {
        vSplit -= parentIndex * this.layoutConfig.spouseGap;
      } else {
        vSplit += parentIndex * this.layoutConfig.spouseGap;
      }

      this.spouseVSplitMap.set(spouse, vSplit);

      return vSplit;
    }
  }

  drawConnector(path = null, color = this.layoutConfig.pathColor, data = {}) {
    if(path == null) {
      if(this.y == this.parent.y) {
        path = `
          M${this.centerX()},${this.centerY()}
          L${this.parent.centerX()},${this.parent.centerY()}
        `;
      } else {
        const vSplit = this.parent.getVSplitFor(this.parentSpouse, this);
        const startX = this.parentSpouse.centerX() - (this.layoutConfig.nodeWidth+this.layoutConfig.spouseGap)/2

        path = `
          M${startX},${this.parent.centerY()}
          V${vSplit}
          H${this.centerX()}
          V${this.centerY()}
        `;
      }
    }

    const connector = document.createElementNS("http://www.w3.org/2000/svg", "path");
    connector.setAttribute("stroke", color);
    connector.setAttribute("fill", "none");
    connector.setAttribute("stroke-width", "2");
    connector.setAttribute("d", path);

    Object.assign(connector.dataset, data);

    document.getElementById("connector-lines").appendChild(connector);

    return connector;
  }

  iconRow(iconName, text) {
    const li = document.createElement("li");
    li.classList.add("list-group-item");
    if(this.isSafari) {
      li.style.position = "unset";
    }
    li.classList.add("py-0");

    const row = document.createElement("div");
    row.classList.add("row");
    li.appendChild(row);

    const colIcon = document.createElement("div");
    colIcon.classList.add("col-2");
    colIcon.appendChild(this.icon(iconName));
    row.appendChild(colIcon);

    const colText = document.createElement("div");
    colText.classList.add("col-10");
    colText.innerText = text;
    row.appendChild(colText);

    return li;
  }

  icon(name, type = "bi") {
    const icon = document.createElement("i");
    icon.classList.add(type);
    icon.classList.add(name);
    return icon;
  }
}
