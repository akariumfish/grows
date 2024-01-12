

void saving() {
  String[] sl = new String[sintlist.size() + sfltlist.size() + sboolist.size()];
  for (String s : sl) s = new String();
  for (sInt i : sintlist) {
    sl[i.id] = str(i.get());
  }
  for (sFlt i : sfltlist) {
    sl[sintlist.size() + i.id] = str(i.get());
  }
  for (sBoo i : sboolist) {
    sl[sintlist.size() + sfltlist.size() + i.id] = str(i.get());
  }
  saveStrings("save.txt", sl);
}
void loading() {
  String[] sl = loadStrings("save.txt");
  if (sl.length != sintlist.size() + sfltlist.size() + sboolist.size()) return;
  for (sInt i : sintlist) {
    i.set(int(sl[i.id]));
  }
  for (sFlt i : sfltlist) {
    i.set(float(sl[sintlist.size() + i.id]));
  }
}

class sInt {
  private int val = 0;
  int id = 0;
  sInt(int v) { val = v; id = sintlist.size(); sintlist.add(this); }
  int get() { return val; }
  void set(int v) { val = v; }
  
}

class sFlt {
  private float val = 0;
  int id = 0;
  sFlt(float v) { val = v; id = sfltlist.size(); sfltlist.add(this); }
  float get() { return val; }
  void set(float v) { val = v; }
}

class sBoo {
  private boolean val = false;
  int id = 0;
  sBoo(boolean v) { val = v; id = sboolist.size(); sboolist.add(this); }
  boolean get() { return val; }
  void set(boolean v) { val = v; }
}





class debugText {
  
}



PImage canvas;

void init_canvas() {
  canvas = createImage(width, height, RGB);
  for(int i = 0; i < canvas.pixels.length; i++) {
    //float a = map(i, 0, img.pixels.length, 255, 0);
    //img.pixels[i] = color(0, 153, 204, a); 
    canvas.pixels[i] = color(0); 
  }
}

color getpix(PVector v) { return getpix(v.x, v.y); }
color getpix(float x, float y) {
  color co = 0;
  int pi = canvas.width * int(y + height / 2) + int(x + width/2);
  if (pi >= 0 && pi < canvas.pixels.length) {
    co = canvas.pixels[pi];
  }
  return co;
}
void setpix(PVector v, color c) { setpix(v.x, v.y, c); }
void setpix(float x, float y, color c) {
  int pi = canvas.width * int(y + height / 2) + int(x + width/2);
  if (pi >= 0 && pi < canvas.pixels.length) {
    canvas.pixels[pi] = c;
  }
}

void canvas_croix(float x, float y, int c) {
  color co = getpix(x, y);
  setpix(x, y, color(c + red(co)) );
  setpix(x + 1, y, color(c/2 + red(co)) );
  setpix(x - 1, y, color(c/2 + red(co)) );
  setpix(x, y + 1, color(c/2 + red(co)) );
  setpix(x, y - 1, color(c/2 + red(co)) );
}

void canvas_line(PVector v1, PVector v2, int c) {
  PVector m = new PVector(v1.x - v2.x, v1.y - v2.y);
  int l = int(m.mag());
  m.setMag(-1);
  PVector p = new PVector(v1.x, v1.y);
  for (int i = 0 ; i < l ; i++) {
    color co = getpix(p.x, p.y);
    setpix(p.x, p.y, color(c + red(co)) );
    p.add(m);
  }
}
