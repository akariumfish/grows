// ici on definie les structure de type grower


class NodeComu extends Community {
  NodeComu(ComunityList _c) { super(_c); init(); }
  Node build() { return new Node(this); }
}

class Node extends Entity {
  PVector pos = new PVector();
  float r = 0;
  
  Node(NodeComu c) { super(c); }
  
  Node init() {
    pos.x = random(width - 100) - (width - 100) / 2;
    pos.y = random(height - 100) - (height - 100) / 2;
    return this;
  }
  Node run() {
    PVector mlocal = new PVector(mouseX, mouseY);
    mlocal = to_cam_view(mlocal);
    float d = distancePointToPoint(mlocal.x, mlocal.y, pos.x, pos.y);
    if (mouseButtons[0] && d < 20) {
      GRAB = false;
      pos.x = mlocal.x;
      pos.y = mlocal.y;
    }
    if (mouseUClick[0]) GRAB = true;
    pos.x += random(2) * cos(r);
    pos.y += random(2) * sin(r);
    r = (r+random(1.0) - 0.5) % ( 2 * PI );
    if (pos.mag() > min(width - 100, height - 100)/2) {
      PVector g = new PVector(pos.x, pos.y);
      g.mult(-1);
      g.setMag(1);
      pos.add(g);
    }
    return this;
  }
  Node drawing() {
    stroke(255);
    strokeWeight(1);
    noFill();
    //println(pos.x + " " + pos.y);
    ellipse(pos.x, pos.y, 20, 20);
    //text(id, pos.x + 10, pos.y);
    return this;
  }
  Node clear() { return this; }
}
