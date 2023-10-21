class BoxComu extends Community {
  
  BoxComu(ComunityList _c) { super(_c, "Box", 1000); init();
    
    initial_entity.set(1);
    
  }
  void custom_tick() {
          
  }
  
  Box build() { return new Box(this); }
  Box initialEntity() { return newEntity(); }
  Box newEntity() {
    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
}

class Box extends Entity {
  PVector pos1 = new PVector(0, 0);
  PVector pos2 = new PVector(0, 0);
  boolean top = false, right = false, left = false, down = false;
  
  Box(BoxComu c) { super(c); }
  
  Box init() {
    pos1 = new PVector(-10, -10);
    pos2 = new PVector(10, 10);
    top = false; right = false; left = false; down = false;
    return this;
  }
  Box tick() {
    if (true) {
      if (!top && random(1.0) > 0.99) {
        Box nb = com().newEntity();
        if (nb != null) {
          top = true;
          nb.pos2.y = pos1.y;
          nb.pos1.y = pos1.y - (pos2.y - pos1.y);
          nb.pos1.x = pos1.x;
          nb.pos2.x = pos2.x;
        }
      }
      if (!down && random(1.0) > 0.99) {
        Box nb = com().newEntity();
        if (nb != null) {
          down = true;
          nb.pos1.y = pos2.y;
          nb.pos2.y = pos2.y + (pos2.y - pos1.y);
          nb.pos1.x = pos1.x;
          nb.pos2.x = pos2.x;
        }
      }
      if (!right && random(1.0) > 0.99) {
        Box nb = com().newEntity();
        if (nb != null) {
          right = true;
          nb.pos1.x = pos2.x;
          nb.pos2.x = pos2.x + (pos2.x - pos1.x);
          nb.pos1.y = pos1.y;
          nb.pos2.y = pos2.y;
        }
      }
      if (!left && random(1.0) > 0.99) {
        Box nb = com().newEntity();
        if (nb != null) {
          left = true;
          nb.pos2.x = pos1.x;
          nb.pos1.x = pos1.x - (pos2.x - pos1.x);
          nb.pos1.y = pos1.y;
          nb.pos2.y = pos2.y;
        }
      }
    }
    return this;
  }
  Box drawing() {
    //fill(255);
    noFill();
    stroke(255);
    strokeWeight(2/cam.cam_scale.get());
    line(pos1.x, pos1.y, pos1.x, pos2.y);
    line(pos2.x, pos1.y, pos2.x, pos2.y);
    line(pos1.x, pos1.y, pos2.x, pos1.y);
    line(pos1.x, pos2.y, pos2.x, pos2.y);
    return this;
  }
  Box clear() { return this; }
  BoxComu com() { return ((BoxComu)com); }
}
