
//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


String trimStringFloat(float f) {
  String s;
  if (f%1.0 == 0.0) s = nfc(int(f)); else s = str(f);
  String end = "";
  for (int i = s.length()-1; i > 0 ; i--) {
    if (s.charAt(i) == 'E') {
      end = s.substring(i, s.length());
    }
  }
  for (int i = 0; i < s.length() ; i++) {
    if (s.charAt(i) == '.' && s.length() - i > 4) {
      int m = 4;
      if (f >= 10) m -= 1;
      if (f >= 100) m -= 1;
      if (f >= 1000) m -= 2;
      s = s.substring(0, i+m);
      s = s + end;
      return s;
    }
  }
  return s;
}

float soothedcurve(float rad, float dst) {
  float val = max(0, rad*rad - dst*dst);
  return val * val * val;
}

float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

float crandom(float d) { return pow(random(1.0), d); }

float crandom(float min, float max, float d) { return min + (max-min)*pow(random(1.0), d); }

// auto indexing
int used_index = 0;
int get_free_id() { used_index++; return used_index - 1; }

// gestion des polices de caractére
ArrayList<myFont> existingFont = new ArrayList<myFont>();
class myFont { PFont f; int st; }
PFont getFont(int st) {
  for (myFont f : existingFont) if (f.st == st) return f.f;
  myFont f = new myFont();
  f.f = createFont("Arial",st); f.st = st;
  return f.f; }
//for (String s : PFont.list()) println(s); // liste toute les police de text qui existe




//#######################################################################
//##          ROTATING TO ANGLE CIBLE BY SHORTEST DIRECTION            ##
//#######################################################################


float mapToCircularValues(float current, float cible, float increment, float start, float stop) {
  if (start > stop) {float i = start; start = stop; stop = i;}
  increment = abs(increment);
  
  while (cible > stop) {cible -= (stop - start);}
  while (current > stop) {current -= (stop - start);}
  while (cible < start) {cible += (stop - start);}
  while (current < start) {current += (stop - start);}
  
  if (cible < current) {
    if ( (current - cible) <= (stop - current + cible - start) ) {
      if (increment >= current - cible) {return cible;}
      else                              {return current - increment;}
    } else {
      if (increment >= stop - current + cible - start) {return cible;}
      else if (current + increment < stop)             {return current + increment;}
      else                                             {return start + (increment - (stop - current));}
    }
  } else if (cible > current) {
    if ( (cible - current) <= (stop - cible + current - start) ) {
      if (increment >= cible - current) {return cible;}
      else                              {return current + increment;}
    } else { 
      if (increment >= stop - cible + current - start) {return cible;}
      else if (current - increment > start)            {return current - increment;}
      else                                             {return stop - (increment - (current - start));}
    }
  }
  return cible;
}




//#######################################################################
//##                              CANVAS                               ##
//#######################################################################


Canvas can;

void init_canvas() {
  can = new Canvas(0, 0, int((width) / cam.cam_scale.get()), int((height) / cam.cam_scale.get()), 4);
}

class Canvas extends Callable {
  PVector pos = new PVector(0, 0);
  float canvas_scale = 1.0;
  PImage can1,can2;
  
  int active_can = 0;
  int can_div = 4;
  int can_st = can_div-1;
  
  sBoo show_canvas = new sBoo(simval, false);
  sBoo show_canvas_bound = new sBoo(simval, true);
  
  sGrabable can_grab;
  
  Canvas() { construct(0, 0, width, height, 1); }
  Canvas(float x, float y, int w, int h, float s) { construct(x, y, w, h, s); }
  
  void construct(float x, float y, int w, int h, float s) {
    w /= s; h /= s;
    can1 = createImage(w, h, RGB);
    init(can1);
    can2 = createImage(w, h, RGB);
    init(can2);
    pos.x = x - int(w) / 2;
    pos.y = y - int(h) / 2;
    can_grab = new sGrabable(cp5, x, y + 20);
    addChannel(frame_chan);
    if (show_canvas.get()) can_grab.show(); else can_grab.hide();
    canvas_scale = s;
  }
  
  
  void answer(Channel chan, float value) {
    if (chan == frame_chan) {
      pos = cam.screen_to_cam(can_grab.getP());
      pos.y -= 20 / cam.cam_scale.get();
    }
  }
  
  void drawHalo(Community com) {
    if (active_can == 0) {
      for (int i = can_st ; i < com.list.size() ; i += can_div)
        if (com.list.get(i).active) {
          com.list.get(i).draw_halo(this, can2);
      }
      if (can_st == 0) {
        active_can = 1;
        clear(can1);
        can_st = can_div - 1;
      } else can_st--;
    }
    else if (active_can == 1) {
      for (int i = can_st ; i < com.list.size() ; i += can_div)
        if (com.list.get(i).active) {
          com.list.get(i).draw_halo(this, can1);
      }
      if (can_st == 0) {
        active_can = 0;
        clear(can2);
        can_st = can_div - 1;
      } else can_st--;
    }
  }
  
  void drawCanvas() {
    if (show_canvas.get()) {
      if (show_canvas_bound.get()) {
        stroke(255);
        strokeWeight(3 / cam.cam_scale.get());
        noFill();
        rect(pos.x, pos.y, can1.width * canvas_scale, can1.height * canvas_scale);
      }
      if (active_can == 0) draw(can1);
      else if (active_can == 1) draw(can2);
    }
  }
  
  private void init(PImage canvas) {
    for(int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(0); 
    }
  }
  
  void clear(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      canvas.pixels[i] = color(0);
    }
  }
  
  void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(pos.x, pos.y);
    scale(canvas_scale);
    image(canvas, 0, 0);
    popMatrix();
  }
  
  void addpix(PImage canvas, float x, float y, color nc) {
    x += canvas_scale/2;
    y += canvas_scale/2;
    x -= pos.x;
    y -= pos.y;
    x /= canvas_scale;
    y /= canvas_scale;
    if (x < 0 || y < 0 || x > canvas.width || y > canvas.height) return;
    int pi = canvas.width * int(y) + int(x);
    if (pi >= 0 && pi < canvas.pixels.length) {
      color oc = canvas.pixels[pi];
      canvas.pixels[pi] = color(min(255, red(oc) + red(nc)), min(255, green(oc) + green(nc)), min(255, blue(oc) + blue(nc)));
    }
  }
  //color getpix(PImage canvas, PVector v) { return getpix(canvas, v.x, v.y); }
  //color getpix(PImage canvas, float x, float y) {
  //  color co = 0;
  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
  //  if (pi >= 0 && pi < canvas.pixels.length) {
  //    co = canvas.pixels[pi];
  //  }
  //  return co;
  //}
  //void setpix(PImage canvas, PVector v, color c) { setpix(canvas, v.x, v.y, c); }
  //void setpix(PImage canvas, float x, float y, color c) {
  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
  //  if (pi >= 0 && pi < canvas.pixels.length) {
  //    canvas.pixels[pi] = c;
  //  }
  //}
  
  //void canvas_croix(PImage canvas, float x, float y, int c) {
  //  color co = getpix(canvas, x, y);
  //  setpix(canvas, x, y, color(c + red(co)) );
  //  setpix(canvas, x + 1, y, color(c/2 + red(co)) );
  //  setpix(canvas, x - 1, y, color(c/2 + red(co)) );
  //  setpix(canvas, x, y + 1, color(c/2 + red(co)) );
  //  setpix(canvas, x, y - 1, color(c/2 + red(co)) );
  //}
  
  //void canvas_line(PImage canvas, PVector v1, PVector v2, int c) {
  //  PVector m = new PVector(v1.x - v2.x, v1.y - v2.y);
  //  int l = int(m.mag());
  //  m.setMag(-1);
  //  PVector p = new PVector(v1.x, v1.y);
  //  for (int i = 0 ; i < l ; i++) {
  //    color co = getpix(canvas, p.x, p.y);
  //    setpix(canvas, p.x, p.y, color(c + red(co)) );
  //    p.add(m);
  //  }
  //}
}




//#######################################################################
//##                        CALLABLE CLASS V2                          ##
//#######################################################################


void callChannel(Channel chan, float val) {
  for (Callable c : chan.calls) c.answer(chan, val); }
void callChannel(Channel chan) { callChannel(chan, 0); }
class Channel { ArrayList<Callable> calls = new ArrayList<Callable>(); }
abstract class Callable {
  Callable() {}   Callable(Channel c) {addChannel(c);}
  void addChannel(Channel c) { c.calls.add(this); }
  public abstract void answer(Channel channel, float value); }
  
//Channel test_chan = new Channel();
//new Callable(test_chan) { public void answer(Channel c, float v) { print("test"); }};




//#######################################################################
//##                         SPECIAL VALUE                             ##
//#######################################################################


class SpecialValue {
  ArrayList<sInt> sintlist = new ArrayList<sInt>();
  ArrayList<sFlt> sfltlist = new ArrayList<sFlt>();
  ArrayList<sBoo> sboolist = new ArrayList<sBoo>();
  ArrayList<sVec> sveclist = new ArrayList<sVec>();
  ArrayList<sStr> sstrlist = new ArrayList<sStr>();
  void unFlagChange() {
    for (sInt i : sintlist) i.has_changed = false;
    for (sFlt i : sfltlist) i.has_changed = false;
    for (sBoo i : sboolist) i.has_changed = false;
    for (sVec i : sveclist) i.has_changed = false; 
    for (sStr i : sstrlist) i.has_changed = false; }
}


class sInt {
  boolean has_changed = false;
  SpecialValue save;
  int val = 0;
  int id = 0;
  String name = "int";
  sInt(SpecialValue s, int v) { save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  sInt(SpecialValue s, int v, String n) { name = n; save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  int get() { return val; }
  void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  String name = "flt";
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  sFlt(SpecialValue s, float v, String n) { name = n; save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  float get() { return val; }
  void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  String name = "boo";
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  sBoo(SpecialValue s, boolean v, String n) { name = n; save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}

class sVec {
  boolean has_changed = false;
  SpecialValue save;
  PVector val = new PVector();
  int id = 0;
  String name = "vec";
  sVec(SpecialValue s, PVector v) { save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  sVec(SpecialValue s, PVector v, String n) { name = n; save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  PVector get() { return new PVector(val.x, val.y); }
  void set(PVector v) { if (v.x != val.x || v.y != val.y) { has_changed = true; val.x = v.x; val.y = v.y; } }
}

class sStr {
  boolean has_changed = false;
  SpecialValue save;
  String val = new String();
  int id = 0;
  String name = "str";
  sStr(SpecialValue s, String v) { save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  sStr(SpecialValue s, String v, String n) { name = n; save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  String get() { return new String(val); }
  void set(String v) { if (!v.equals(val)) { has_changed = true; val = v; } }
}



//#######################################################################
//##                        RANDOM TRY PARAM                           ##
//#######################################################################


class RandomTryParam extends Callable {
  //constructeur avec param values
  sFlt DIFFICULTY = new sFlt(simval, 4);
  sBoo ON = new sBoo(simval, true);
  sFlt test_by_tick = new sFlt(simval, 0);
  int count = 0;
  RandomTryParam(float d, boolean b) { DIFFICULTY.set(d); ON.set(b); addChannel(frameend_chan); }
  boolean test() { if(ON.get()) count++; test_by_tick.set(count / sim.tick_by_frame.get()); return ON.get() && crandom(DIFFICULTY.get()) > 0.5; }
  void answer(Channel chan, float v) { count = 0; test_by_tick.set(0); }
}



//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


int SV_start_bloc = 3;

void saving(SpecialValue sv, String file) {
  String[] sl = new String[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + sv.sboolist.size()];
  sl[0] = str(sv.sintlist.size());
  sl[1] = str(sv.sfltlist.size());
  sl[2] = str(sv.sboolist.size());
  for (sInt i : sv.sintlist) {
    sl[SV_start_bloc + i.id] = str(i.get());
  }
  for (sFlt i : sv.sfltlist) {
    sl[SV_start_bloc + sv.sintlist.size() + i.id] = str(i.get());
  }
  for (sBoo i : sv.sboolist) {
    sl[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + i.id] = str(i.get());
  }
  saveStrings(file, sl);
}
void loading(SpecialValue s, String file) {
  
  String[] sl = loadStrings(file);
  if (sl != null && sl.length < 4) return;
  int intlsize = int(sl[0]);
  int fltlsize = int(sl[1]);
  int boolsize = int(sl[2]);
  
  if (intlsize != s.sintlist.size()) return;
  if (fltlsize != s.sfltlist.size()) return;
  if (boolsize != s.sboolist.size()) return;
  if (sl.length < SV_start_bloc + intlsize + fltlsize + boolsize) return;
  
  for (sInt i : s.sintlist) {
    i.set(int(sl[SV_start_bloc + i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(float(sl[SV_start_bloc + s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(boolean(sl[SV_start_bloc + s.sintlist.size() + s.sfltlist.size() + i.id]));
  }
}





//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################


class sGraph {
  int larg =             1200;
  int[] graph  = new int[larg];
  int[] graph2 = new int[larg];
  int gc = 0;
  int max = 10;
  
  sBoo SHOW_GRAPH = new sBoo(simval, false);// affichage du graph a un bp
  
  void init() {
    //initialisation des array des graph
    for (int i = 0; i < larg; i++) { 
      graph[i] = 0; 
      graph2[i] = 0;
    }
    max = 10;
    //addChannel(c);
  }
  
  void draw() {
    if (SHOW_GRAPH.get() && !cp5.getTab("default").isActive()) {
      strokeWeight(0.5);
      stroke(255);
      for (int i = 1; i < larg; i++) if (i != gc) {
        stroke(255);
        line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000), 
          i, height - 10 - (graph[i] * (height-20) / 5000) );
        stroke(255, 255, 0);
        line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / max), 
          i, height - 10 - (graph2[i] * (height-20) / max) );
      }
      stroke(255, 0, 0);
      strokeWeight(7);
      if (gc != 0) {
        point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
        point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / max) );
      }
    }
  }
  
  void update(int val1, int val2) {
    //enregistrement des donner dans les array
    graph[gc] = val1;
  
    int g = val2;
    if (max < g) max = g;
    if (graph2[gc] == max) {
      max = 10;
      for (int i = 0; i < graph2.length; i++) if (i != gc && max < graph2[i]) max = graph2[i];
    }
    graph2[gc] = g;
  
    if (gc < larg-1) gc++; 
    else gc = 0;
  }
}





  
