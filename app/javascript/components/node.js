export default class Node {

  constructor(layoutConfig, id, tag, parent, name, nullId, parentIndex = null) {
    this.layoutConfig = layoutConfig;

    this.id = id;
    this.tag = tag;

    this.parent = parent;
    this.name = name;
    if (this.parent) {
      this.parentId = parent.id;
    } else {
      this.parentId = nullId;
    }

    this.parentIndex = parentIndex;

    this.children = [];
    this.spouses = [];
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
      this.drawRect(this.x + (index + 1) * (this.layoutConfig.nodeWidth + this.layoutConfig.spouseGap), this.y, spouse);

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
    const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");

    rect.setAttribute("x", x);
    rect.setAttribute("y", y);
    rect.setAttribute("width", this.layoutConfig.nodeWidth);
    rect.setAttribute("height", this.layoutConfig.nodeHight);
    rect.setAttribute("fill", this.layoutConfig.nodeColor);

    Object.assign(rect.dataset, data);

    document.getElementById("family-tree").appendChild(rect);

    const textBox = document.createElementNS("http://www.w3.org/2000/svg", "text");
    textBox.setAttribute("x", x + this.layoutConfig.nodeWidth / 2);
    textBox.setAttribute("y", y + this.layoutConfig.nodeHight / 2);
    textBox.setAttribute("dominant-baseline", "middle");
    textBox.setAttribute("text-anchor", "middle");
    textBox.textContent = text;
    textBox.style.fill = this.layoutConfig.pathColor;

    document.getElementById("family-tree").appendChild(textBox);

    return rect;
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
}
