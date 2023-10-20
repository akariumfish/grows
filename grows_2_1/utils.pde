
//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


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

float crandom(float d) {
  return pow(random(1.0), d) ;
}

/*

crandom results :
difficulty   nb > 0.5 pour 1000
       0.04 999
       0.08 999
       0.16 986
       0.32 885
       0.64 661
       1.28 418
       2.56 236
       5.12 126
      10.24 65
      20.48 33
      40.96 16
      81.92 8
     163.84 4
     327.68 2
     655.36 1
    1310.72 0
    2621.44 0

*/

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
  void addChannel(Channel c) { c.calls.add(this); }
  abstract void answer(Channel channel, float value); }
  





//#######################################################################
//##                         SPECIAL VALUE                             ##
//#######################################################################


class SpecialValue {
  ArrayList<sInt> sintlist = new ArrayList<sInt>();
  ArrayList<sFlt> sfltlist = new ArrayList<sFlt>();
  ArrayList<sBoo> sboolist = new ArrayList<sBoo>();
  void unFlagChange() {
    for (sInt i : sintlist) i.has_changed = false;
    for (sFlt i : sfltlist) i.has_changed = false;
    for (sBoo i : sboolist) i.has_changed = false; }
}


class sInt {
  boolean has_changed = false;
  SpecialValue save;
  int val = 0;
  int id = 0;
  sInt(SpecialValue s, int v) { save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  int get() { return val; }
  void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  float get() { return val; }
  void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}




//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


void saving(SpecialValue sv, String file) {
  String[] sl = new String[sv.sintlist.size() + sv.sfltlist.size() + sv.sboolist.size()];
  //for (String s : sl) s = new String(); //??maybe useless?
  for (sInt i : sv.sintlist) {
    sl[i.id] = str(i.get());
  }
  for (sFlt i : sv.sfltlist) {
    sl[sv.sintlist.size() + i.id] = str(i.get());
  }
  for (sBoo i : sv.sboolist) {
    sl[sv.sintlist.size() + sv.sfltlist.size() + i.id] = str(i.get());
  }
  saveStrings(file, sl);
}
void loading(SpecialValue s, String file) {
  String[] sl = loadStrings(file);
  if (sl.length != s.sintlist.size() + s.sfltlist.size() + s.sboolist.size()) return;
  for (sInt i : s.sintlist) {
    i.set(int(sl[i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(float(sl[s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(boolean(sl[s.sintlist.size() + s.sfltlist.size() + i.id]));
  }
}





//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################


class sGraph {
  //permet l'enregistrement de donné pour le graphique
  int larg =             1200;
  int[] graph  = new int[1200];
  int[] graph2 = new int[1200];
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





  
