export default class Node {

  constructor(layoutConfig, id, parent, name, birthDate, deathDate, nullId, parentSpouse = null) {
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

    this.spouseNodes = [];
    this.children = [];

    this.spouseVPlitMap = new Map();
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

    const span = document.createElement("span");
    span.innerText = text;
    div.appendChild(span);

    Object.assign(div.dataset, data);

    const ul = document.createElement("ul");
    ul.classList.add("list-group");
    ul.classList.add("list-group-flush");
    div.appendChild(ul);

    if(this.birthDate) {
      ul.appendChild(this.iconRow("fa-cake-candles", this.birthDate));
    }
    if(this.deathDate) {
      ul.appendChild(this.iconRow("fa-cross", this.deathDate));
    }

    wrapper.appendChild(div);
    document.querySelector("svg#family-tree g#scene").appendChild(wrapper);

    return div;
  }

  getVSplitFor(spouse, child) {
    if(this.spouseVPlitMap.has(spouse)) {
      return this.spouseVPlitMap.get(spouse);
    } else {
      const startX = spouse.centerX() - (this.layoutConfig.nodeWidth+this.layoutConfig.spouseGap)/2;
      const parentIndex = this.spouseNodes.indexOf(spouse);
      let vSplit = (this.centerY() + child.centerY()) / 2;
      if(startX < child.centerX()) {
        vSplit -= parentIndex * this.layoutConfig.spouseGap;
      } else {
        vSplit += parentIndex * this.layoutConfig.spouseGap;
      }

      this.spouseVPlitMap.set(spouse, vSplit);

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
    li.classList.add("py-0");

    const row = document.createElement("div");
    row.classList.add("row");
    li.appendChild(row);

    const colIcon = document.createElement("div");
    colIcon.classList.add("col-2");
    colIcon.appendChild(this.icon(iconName));
    row.appendChild(colIcon);

    const colText = document.createElement("div");
    colText.classList.add("col");
    colText.innerText = text;
    row.appendChild(colText);

    return li;
  }

  icon(name, type = "fa-solid") {
    const icon = document.createElement("i");
    icon.classList.add(type);
    icon.classList.add(name);
    return icon;
  }
}
