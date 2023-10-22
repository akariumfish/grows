
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





  
