// ici on definie les structure de type grower


class BirdComu extends Community {
  BirdComu(ComunityList _c) { super(_c); init(); }
  Bird build() { return new Bird(this); }
}

sInt SPEED = new sInt(10);

class Bird extends Entity {
  PVector pos = new PVector();
  PVector ppos = new PVector();
  PVector cible = new PVector();
  
  int nodeToSkipId = -1;
  int cibleId = -1;
  
  Node cnode;

  Bird(BirdComu c) { super(c); }
  
  Bird init() {
    for (int i = 0 ; i < nodec.list.size() ; i++) {
      Node n = (Node) nodec.list.get(i);
      if (random(1.0) < 0.1 && n.active) {
        pos.x = n.pos.x;
        pos.y = n.pos.y;
        cibleId = n.id;
        cnode = n;
        break;
      }
    }
    cible.x = pos.x;
    cible.y = pos.y;
    return this;
  }
  Bird run() {
    if (cibleId >= 0) {
      cnode = (Node)nodec.list.get(cibleId);
      cible.x = cnode.pos.x;
      cible.y = cnode.pos.y;
    }
    PVector m = new PVector(cible.x - pos.x, cible.y - pos.y);
    
    //choosing cible
    if (m.mag() < SPEED.get()) {
      int prevCible = cibleId;
      float cible_d = 1000000;
      for (int i = 0 ; i < nodec.list.size() ; i++) {
        Node n = (Node) nodec.list.get(i);
        if (n.active && n.id != nodeToSkipId) {
          float d = distancePointToPoint(n.pos, pos);
          if (d < cible_d && d > SPEED.get() && random(1.0) < 0.5) {
            cible_d = d;
            //cible.x = n.pos.x;
            //cible.y = n.pos.y;
            cnode = n;
            cibleId = n.id;
          }
        }
      }
      nodeToSkipId = prevCible;
    }
    
    m.setMag( min( SPEED.get(), m.mag() ) );
    ppos.x = pos.x; ppos.y = pos.y;
    pos.add(m);
    
    //drawing on image
    //canvas_croix(pos.x, pos.y, 150);
    canvas_line(pos, ppos, 150);
    
    return this;
  }
  Bird drawing() {
    stroke(255);
    strokeWeight(2);
    noFill();
    //line(pos.x, pos.y, cible.x, cible.y);
    //println(pos.x + " " + pos.y);
    ellipse(pos.x, pos.y, 5, 5);
    return this;
  }
  Bird clear() { return this; }
}
