export default class Node {

  constructor(layoutConfig, id, tag, parent, name, birthDate, deathDate, nullId, parentIndex = null) {
    this.layoutConfig = layoutConfig;

    this.id = id;
    this.tag = tag;

    this.parent = parent;
    this.name = name;
    this.birthDate = birthDate;
    this.deathDate = deathDate;
    if (this.parent) {
      this.parentId = parent.id;
    } else {
      this.parentId = nullId;
    }

    this.parentIndex = parentIndex;

    this.children = [];
    this.spouses = [];
    this.spouseElements = [];
  }

  centerX() {
    return this.x + this.layoutConfig.nodeWidth / 2;
  }

  centerY() {
    return this.y + this.layoutConfig.nodeHight / 2;
  }

  getGroupWidth() {
    return this.layoutConfig.nodeWidth + (this.spouses.length + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap);
  }

  shiftPos(minX, minY) {
    this.x -= minX;
    this.y -= minY;

    this.children.forEach(child => child.shiftPos(minX, minY));
  }

  render() {
    this.rect = this.drawRect(this.x, this.y, this.name, { nodeId: this.id });

    this.spouses.forEach((spouse, index) => {
      this.spouseElements.push(
        this.drawRect(
          this.x + (index + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap),
          this.y,
          spouse
        )
      );

      // Draw connector to partner
      this.drawConnector(`
        M${this.centerX()},${this.centerY()}
        L${this.centerX() + (index + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap)},${this.centerY()}
      `);
    });

    // Link to parents
    if (this.parent) {
      this.drawConnector();
    }

    this.children.forEach(child => child.render());
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
    document.getElementById("family-tree").appendChild(wrapper);

    return div;
  }

  drawConnector(path = null, color = this.layoutConfig.pathColor, data = {}) {
    if(path == null) {
      let vSplit = (this.parent.centerY() + this.centerY()) / 2;
      if(this.parent.centerX() < this.centerX()) {
        vSplit -= this.parentIndex * this.layoutConfig.spouseGap;
      } else {
        vSplit += this.parentIndex * this.layoutConfig.spouseGap;
      }
      path = `
        M${this.parent.centerX() + this.layoutConfig.spouseGap / 2 + this.layoutConfig.nodeWidth / 2 + this.parentIndex * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap)},${this.parent.centerY()}
        V${vSplit}
        H${this.centerX()}
        V${this.centerY()}
      `;
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
