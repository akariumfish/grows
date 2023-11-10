import java.util.Map;


/*

APPLET
  Cam
    drawable_pile:
      world ref
      screen ref

  GUI
    hoverable


fenetre:
  deplacable
  collapse
  closing
  drawer function
  
widget:
boutton
  auto svalue control

text
  auto updatable

input field
  auto change svalue

macro in/out


*/


Channel GUI_Call = new Channel();
Drawing_pile drawing_pile = new Drawing_pile();
Hoverable_pile hoverable_pile = new Hoverable_pile();


void mysetup() {
  
  nGrab gr = new nGrab(drawing_pile, hoverable_pile, "", 24, 100, 400, 50, 50);
  
  nRect pan = (nRect)new nRect(drawing_pile, 0, 0, 200, 200)
    .setParent(gr)
    .setPY(50)
    .setStandbyColor(color(150, 80));
  
  new nButton(drawing_pile, hoverable_pile, "TEST", 24, 100, 100, 100, 30)
    .setParent(pan)
    ;
  new nRect(drawing_pile, 100, 140, 100, 3)
    .setParent(pan)
    ;
  new nLabel(drawing_pile, "TEST2", 24, 100, 150)
    .setParent(pan)
    ;
}


void mydraw() {
  hoverable_pile.search(cam.getCamMouse());
  callChannel(GUI_Call);
  
  // apply camera view
  cam.pushCam();
  
  
  drawing_pile.drawing();
  
  ellipse(cam.getCamMouse().x, cam.getCamMouse().y, 10, 10);
  
  cam.popCam();
  
}

class nButton extends nWidget {
  Hoverable_pile hpile; Hoverable hover;
  String label;
  int text_font;
  boolean isClicked = false;
  
  //mode switch
  //mode value ctrl
  //mode runnable
  
  nButton(Drawing_pile _dpile, Hoverable_pile _hpile, String _label, int _text_font, float x, float y, float w, float h) {
    super(_dpile, x, y, w, h);
    hpile = _hpile;
    label = _label; text_font = _text_font;
    setDrawer(new Drawer(dpile) { void drawing() {
      if (isClicked) { fill(clickedColor); } else if (hover.mouseOver) { fill(hoveredColor); } else { fill(standbyColor); }
      noStroke(); rect(getX(), getY(), getSX(), getSY());
      textAlign(CENTER);
      textFont(getFont(text_font));
      stroke(labelColor); text(label, getX() + getSX() / 2, getY() + text_font / 2 + getSY() / 2);
    } } );
    hover = new Hoverable(hpile, getRect());
    addChannel(GUI_Call);
  }
  
  void customLayerChange() { if (hover != null) hover.setLayer(getLayer()); }
  
  // answer GUI_Call to update
  void answer(Channel chan, float val) {
    if (kb.mouseUClick[0]) {
      isClicked = false;
    }
    if (kb.mouseClick[0] && hover.mouseOver) {
      isClicked = true;
    }
  }
}

class nLabel extends nWidget {
  String label;
  int text_font;
  
  nLabel(Drawing_pile _dpile, String _label, int _text_font, float x, float y) {
    super(_dpile, x, y, 0, 0);
    label = _label;
    text_font = _text_font;
    setDrawer(new Drawer(dpile) { void drawing() {
      textAlign(LEFT);
      textFont(getFont(text_font));
      stroke(labelColor); text(label, getX(), getY() + text_font);
    } } );
  }
}

class nRect extends nWidget {
  nRect(Drawing_pile _dpile, float x, float y, float w, float h) {
    super(_dpile, x, y, w, h);
    setDrawer(new Drawer(dpile) { void drawing() {
      fill(standbyColor);  noStroke();
      rect(getX(), getY(), getSX(), getSY());
    } } );
  }
}

class nGrab extends nWidget {
  Hoverable_pile hpile; Hoverable hover;
  String label;
  int text_font;
  boolean isClicked = false;
  float mx = 0; float my = 0;
  
  nGrab(Drawing_pile _dpile, Hoverable_pile _hpile, String _label, int _text_font, float x, float y, float w, float h) {
    super(_dpile, x, y, w, h);
    hpile = _hpile;
    label = _label; text_font = _text_font;
    setDrawer(new Drawer(dpile) { void drawing() {
      if (isClicked) { fill(clickedColor); } else if (hover.mouseOver) { fill(hoveredColor); } else { fill(standbyColor); }
      noStroke(); getRect().draw();
      textAlign(CENTER);
      textFont(getFont(text_font));
      stroke(labelColor); text(label, getX() + getSX() / 2, getY() + text_font / 2 + getSY() / 2);
    } } );
    hover = new Hoverable(hpile, getRect());
    addChannel(GUI_Call);
  }
  
  void customLayerChange() { if (hover != null) hover.setLayer(getLayer()); }
  
  // answer GUI_Call to update
  void answer(Channel chan, float val) {
    if (kb.mouseUClick[0]) {
      isClicked = false;
    }
    if (kb.mouseClick[0] && hover.mouseOver) {
      isClicked = true;
    }
    if (hover.mouseOver) {
      if (kb.mouseClick[0]) {
        mx = getLocalX() - cam.getCamMouse().x;
        my = getLocalY() - cam.getCamMouse().y;
        cam.GRAB = false; //deactive le deplacement camera
      } else if (kb.mouseUClick[0]) {
        cam.GRAB = true;
      }
    }
    if (isClicked) {
      setPX(cam.getCamMouse().x + mx); setPY(cam.getCamMouse().y + my);
    }
  }
}

class nWidget extends Callable { //groupable, extends callable
  Drawing_pile dpile;
  private Drawer drawer;
  private int layer = 0;
  private Rect rect;
  private nWidget parent = null;
  private ArrayList<nWidget> childs = new ArrayList<nWidget>();
  
  nWidget(Drawing_pile _dpile, float x, float y, float w, float h) {
    dpile = _dpile;
    rect = new Rect(x, y, w, h);
  }
  
  nWidget setDrawer(Drawer d) { drawer = d; return this; }
  
  nWidget setParent(nWidget p) { parent = p; p.childs.add(this); return this; }
  nWidget clearParent() { parent.childs.remove(this); parent = null; return this; }
  
  nWidget setLayer(int l) { layer = l; if (drawer != null) drawer.setLayer(layer); customLayerChange(); return this; }
  
  nWidget setPX(float v) { if (v != rect.pos.x) { rect.pos.x = v; changePosition(); return this; } return this; }
  nWidget setPY(float v) { if (v != rect.pos.y) { rect.pos.y = v; changePosition(); return this; } return this; }
  nWidget setSX(float v) { if (v != rect.size.x) { rect.size.x = v; customShapeChange(); return this; } return this; }
  nWidget setSY(float v) { if (v != rect.size.y) { rect.size.y = v; customShapeChange(); return this; } return this; }
  
  color standbyColor = color(80);
  color hoveredColor = color(130);
  color clickedColor = color(180);
  color labelColor = color(255);
  
  nWidget setStandbyColor(color c) { standbyColor = c; return this; }
  nWidget setHoveredColor(color c) { hoveredColor = c; return this; }
  nWidget setClickedColor(color c) { clickedColor = c; return this; }
  nWidget setLabelColor(color c) { labelColor = c; return this; }
  
  Rect getRect() { return rect; }
  int getLayer() { return layer; }
  float getX() { if (parent != null) return rect.pos.x + parent.getX(); else return rect.pos.x; }
  float getY() { if (parent != null) return rect.pos.y + parent.getY(); else return rect.pos.y; }
  float getLocalX() { return rect.pos.x; }
  float getLocalY() { return rect.pos.y; }
  float getSX() { return rect.size.x; }
  float getSY() { return rect.size.y; }
  
  void customLayerChange() {}
  void customPositionChange() {}
  void customShapeChange() {}
  void answer(Channel chan, float val) {}
  
  private void changePosition() { customPositionChange(); for (nWidget w : childs) w.changePosition(); }
}









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
  Drawer setLayer(int l) {
    layer = l;
    return this;
  }
  void drawing() {}
}

class Drawing_pile {
  ArrayList<Drawer> drawables = new ArrayList<Drawer>();
  Drawing_pile() { }
  void drawing() {
    int layer = 0;
    int run_count = 0;
    while (run_count < drawables.size()) {
      for (Drawer r : drawables) {
        if (r.layer == layer) {
          if (r.active) r.drawing();
          run_count++;
        }
      }
      layer++;
    }
  }
}









class Hoverable_pile {
  ArrayList<Hoverable> hoverables = new ArrayList<Hoverable>();
  Hoverable_pile() { }
  void search(PVector pointer) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    boolean found = false;
    int count = 0;
    while (count < hoverables.size() && !found) {
      for (Hoverable h : hoverables) if (h.layer == layer) {
        count++;
        if (!found && h.active && h.rect != null && rectCollide(pointer, h.rect)) {
          h.mouseOver = true;
          found = true;
        }
      }
      layer--;
    }
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
  Hoverable setLayer(int l) {
    layer = l;
    return this;
  }
}








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
