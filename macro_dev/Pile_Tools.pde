



//utiliser par le hovering
class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  void draw() { rect(pos.x, pos.y, size.x, size.y); }
}

boolean rectCollide(Rect rect1, Rect rect2) {
  return (rect1.pos.x < rect2.pos.x + rect2.size.x &&
          rect1.pos.x + rect1.size.x > rect2.pos.x &&
          rect1.pos.y < rect2.pos.y + rect2.size.y &&
          rect1.pos.y + rect1.size.y > rect2.pos.y   );
}

boolean rectCollide(Rect rect1, Rect rect2, float s) {
  Rect r1 = new Rect(rect1); r1.pos.x -= s; r1.pos.y -= s; r1.size.x += 2*s; r1.size.y += 2*s;
  Rect r2 = new Rect(rect2); r2.pos.x -= s; r2.pos.y -= s; r2.size.x += 2*s; r2.size.y += 2*s;
  return (r1.pos.x < r2.pos.x + r2.size.x &&
          r1.pos.x + r1.size.x > r2.pos.x &&
          r1.pos.y < r2.pos.y + r2.size.y &&
          r1.pos.y + r1.size.y > r2.pos.y   );
}

boolean rectCollide(PVector p, Rect rect) {
  return (p.x >= rect.pos.x && p.x <= rect.pos.x + rect.size.x &&
          p.y >= rect.pos.y && p.y <= rect.pos.y + rect.size.y );
}



// systemes pour organiser l'ordre d'execution de different trucs en layer:

//drawing
class Drawer {
  Drawing_pile pile = null;
  int layer;
  boolean active = true;
  Drawer() {}
  Drawer(Drawing_pile p) {
    layer = 0;
    pile = p;
    pile.drawables.add(this);
  }
  Drawer(Drawing_pile p, int l) {
    layer = l;
    pile = p;
    pile.drawables.add(this);
  }
  void clear() { if (pile != null) pile.drawables.remove(this); }
  void toLayerTop() { pile.drawables.remove(this); pile.drawables.add(0, this); }
  void toLayerBottom() { pile.drawables.remove(this); pile.drawables.add(this); }
  Drawer setLayer(int l) {
    layer = l;
    return this;
  }
  void drawing() {}
}

class Drawing_pile {
  ArrayList<Drawer> drawables = new ArrayList<Drawer>();
  //ArrayList<Drawer> top_drawables = new ArrayList<Drawer>();
  Drawing_pile() { }
  void drawing() {
    int layer = 0;
    int run_count = 0;
    while (run_count < drawables.size()) {
      for (int i = drawables.size() - 1; i >= 0 ; i--) {
        Drawer r = drawables.get(i);
        if (r.layer == layer) {
          if (r.active) r.drawing();
          run_count++;
        }
      }
      layer++;
    }
  }
  int getHighestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawer r : drawables) if (r.layer > l) l = r.layer;
      return l;
    } else return 0; }
  int getLowestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawer r : drawables) if (r.layer < l) l = r.layer;
      return l;
    } else return 0; }
}








//parmi une list de rect en layer lequel est en collision avec un point en premier
class Hoverable_pile {
  ArrayList<Hoverable> hoverables = new ArrayList<Hoverable>();
  ArrayList<Runnable> eventsNotFound = new ArrayList<Runnable>();
  Hoverable_pile() { }
  void addEventNotFound(Runnable r) { eventsNotFound.add(r); }
  void removeEventNotFound(Runnable r) { eventsNotFound.remove(r); }
  void search(PVector pointer) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    boolean found = false;
    int count = 0;
    
    if (hoverables.size() > 0) while (count < hoverables.size() && !found) {
      for (int i = 0; i < hoverables.size() ; i++) {
        Hoverable h = hoverables.get(i);
        if (h.layer == layer) {
          count++;
          if (!found && h.active && h.rect != null && rectCollide(pointer, h.rect)) {
            h.mouseOver = true;
            found = true;
          }
        }
      }
      layer--;
    }
    if (!found) runEvents(eventsNotFound);
  }
}

class Hoverable {
  Hoverable_pile pile = null;
  int layer;
  Rect rect = null;
  boolean mouseOver = false;
  boolean active = true;
  Hoverable(Hoverable_pile p, Rect r) {
    layer = 0;
    pile = p;
    pile.hoverables.add(this);
    rect = r;
  }
  Hoverable(Hoverable_pile p, Rect r, int l) {
    layer = l;
    pile = p;
    pile.hoverables.add(this);
    rect = r;
  }
  void clear() { if (pile != null) pile.hoverables.remove(this); }
  void toLayerTop() { pile.hoverables.remove(this); pile.hoverables.add(0, this); }
  void toLayerBottom() { pile.hoverables.remove(this); pile.hoverables.add(this); }
  Hoverable setLayer(int l) {
    layer = l;
    return this;
  }
}



//execution ordonné en layer et timer
class Tickable {
  Ticking_pile pile = null;
  int layer;
  boolean active = true;
  Tickable() {}
  Tickable(Ticking_pile p) {
    layer = 0;
    pile = p;
    pile.tickables.add(this);
  }
  Tickable(Ticking_pile p, int l) {
    layer = l;
    pile = p;
    pile.tickables.add(this);
  }
  void clear() { if (pile != null) pile.tickables.remove(this); }
  Tickable setLayer(int l) {
    layer = l;
    return this;
  }
  void tick(float time) {}
}

class Ticking_pile {
  ArrayList<Tickable> tickables = new ArrayList<Tickable>();
  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;
  Ticking_pile() { }
  void tick() {
    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;
    int layer = 0;
    int run_count = 0;
    while (run_count < tickables.size()) {
      for (Tickable r : tickables) {
        if (r.layer == layer) {
          if (r.active) r.tick(frame_length);
          run_count++;
        }
      }
      layer++;
    }
  }
}
