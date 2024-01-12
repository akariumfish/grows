import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Map; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class grows_2_8 extends PApplet {

/*



  see top of sheet constructor for detailed notes





PApplet
  Log
    DEBUG_SAVE
    DEBUG_SCREEN_INFO
    log(string)
    logln()

  void setup()
    Interface
    Simulation(Interface)

  void draw()
    Interface.frame  >  frame events, drawing
*/

boolean DEBUG_HOVERPILE = false;
boolean DEBUG_NOFILL = false;
boolean DEBUG_MACRO = true;

boolean DEBUG = true;

int global_frame_count = 0;

public void log(String s) {
  if (DEBUG) print(s);
}
public void logln(String s) {
  if (DEBUG) println(global_frame_count+":"+s);
}
public void mlog(String s) {
  if (DEBUG_MACRO) print(s);
}
public void mlogln(String s) {
  if (DEBUG_MACRO) println(s);
}

sInterface interf;

////BoxComu bcom;
//GrowerComu gcom;
//FlocComu fcom;


public void setup() {//executé au demarage
  //size(1600, 900);//taille de l'ecran
  
  //pas d'antialiasing
  //smooth();//anti aliasing
  
  interf = new sInterface(40);
  
  Simulation simul = (Simulation)interf.addUniqueSheet(new SimPrint());
  Canvas canv = (Canvas)interf.addUniqueSheet(new CanvasPrint(simul));
  interf.addSpecializedSheet(new OrganismPrint(simul));
  interf.addSpecializedSheet(new GrowerPrint(simul));
  interf.addSpecializedSheet(new FlocPrint(simul));
  
  
  //logln("end models: "+interf.gui_theme.models.size());
  background(0);//fond noir
  
  //File file = new File(sketchPath());
  //if (file.isDirectory()) { String names[] = file.list(); } // all files in sketch directory
  interf.addEventNextFrame(new Runnable() { 
    public void run() { interf.addEventNextFrame(new Runnable() { 
      public void run() { interf.setup_load(); } } ); } } );
  
}


public void draw() {//executé once by frame
  interf.frame();
  global_frame_count++;
  if (global_frame_count < 4) { fill(0); noStroke(); rect(0, 0, width, height); }
}


public void mouseWheel(MouseEvent event) { 
  interf.input.mouseWheelEvent(event);
}  
public void keyPressed() { 
  interf.input.keyPressedEvent();
}  
public void keyReleased() { 
  interf.input.keyReleasedEvent();
}
public void mousePressed() { 
  interf.input.mousePressedEvent();
}
public void mouseReleased() { 
  interf.input.mouseReleasedEvent();
}
public void mouseDragged() { 
  //interf.input.mouseDraggedEvent();
}
public void mouseMoved() { 
  //interf.input.mouseMovedEvent();
}




//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################



public String copy(String s) { if (s != null) return s.substring(0, s.length()); else return null; }
public String str_copy(String s) { if (s != null) return s.substring(0, s.length()); else return null; }

public String trimStringFloat(float f) { return trimStringFloat(f, 3); }
public String trimStringFloat(float f, int p) {
  String s;
  if (f%1.0f == 0.0f) s = nfc(PApplet.parseInt(f)); else s = str(f);
  String end = "";
  for (int i = s.length()-1; i > 0 ; i--) {
    if (s.charAt(i) == 'E') {
      end = s.substring(i, s.length());
    }
  }
  for (int i = 0; i < s.length() ; i++) {
    if (s.charAt(i) == '.' && s.length() - i > p) {
      int m = p;
      for (int c = 0 ; c < p ; c++) {
        if (f >= pow(10, c+1)) m -= 1;
        if (f >= pow(10, c+1) && (c+1)%3 == 0) m -= 1;
      }
      //if (f >= 10) m -= 1;
      //if (f >= 100) m -= 1;
      //if (f >= 1000) m -= 2;
      s = s.substring(0, i+m);
      s = s + end;
      return s;
    }
  }
  return s;
}

public float soothedcurve(float rad, float dst) {
  float val = max(0, rad*rad - dst*dst);
  return val * val * val;
}

public float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

public float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

public float crandom(float d) { return pow(random(1.0f), d); }

// auto indexing
int used_index = 0;
public int get_free_id() { used_index++; return used_index - 1; }

// gestion des polices de caractére
ArrayList<myFont> existingFont = new ArrayList<myFont>();
class myFont { PFont f; int st; }
public PFont getFont(int st) {
  st = PApplet.parseInt(st / 2) * 2;
  if (st > 40) st = 40;
  if (st < 6) st = 6;
  for (myFont f : existingFont) if (f.st == st) return f.f;
  myFont f = new myFont();
  f.f = createFont("Arial",st); f.st = st;
  return f.f; }
//for (String s : PFont.list()) println(s); // liste toute les police de text qui existe




//#######################################################################
//##                        CALLABLE CLASS V2                          ##
//#######################################################################


//void callChannel(Channel chan, float val) {
//  for (int i = 0; i < chan.calls.size() ; i++) chan.calls.get(i).answer(chan, val); }
//void callChannel(Channel chan) { callChannel(chan, 0); }
//class Channel { ArrayList<Callable> calls = new ArrayList<Callable>(); }
//abstract class Callable {
//  Callable() {}   Callable(Channel c) {addChannel(c);}
//  void addChannel(Channel c) { c.calls.add(this); }
//  void removeChannel(Channel c) { c.calls.remove(this); }
//  public abstract void answer(Channel channel, float value); }
  
//Channel test_chan = new Channel();
//new Callable(test_chan) { public void answer(Channel c, float v) { print("test"); }};










//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################


//class sGraph {
//  int larg =             1200;
//  int[] graph  = new int[larg];
//  int[] graph2 = new int[larg];
//  int gc = 0;
//  int max = 10;
  
//  sBoo SHOW_GRAPH = new sBoo(simval, false);// affichage du graph a un bp
  
//  void init() {
//    //initialisation des array des graph
//    for (int i = 0; i < larg; i++) { 
//      graph[i] = 0; 
//      graph2[i] = 0;
//    }
//    max = 10;
//    //addChannel(c);
//  }
  
//  void draw() {
//    if (SHOW_GRAPH.get()) { // && !cp5.getTab("default").isActive()) {
//      strokeWeight(0.5);
//      stroke(255);
//      for (int i = 1; i < larg; i++) if (i != gc) {
//        stroke(255);
//        line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000), 
//          i, height - 10 - (graph[i] * (height-20) / 5000) );
//        stroke(255, 255, 0);
//        line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / max), 
//          i, height - 10 - (graph2[i] * (height-20) / max) );
//      }
//      stroke(255, 0, 0);
//      strokeWeight(7);
//      if (gc != 0) {
//        point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
//        point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / max) );
//      }
//    }
//  }
  
//  void update(int val1, int val2) {
//    //enregistrement des donner dans les array
//    graph[gc] = val1;
  
//    int g = val2;
//    if (max < g) max = g;
//    if (graph2[gc] == max) {
//      max = 10;
//      for (int i = 0; i < graph2.length; i++) if (i != gc && max < graph2[i]) max = graph2[i];
//    }
//    graph2[gc] = g;
  
//    if (gc < larg-1) gc++; 
//    else gc = 0;
//  }
//}





  




   







//#############    RUNNABLE    #############
abstract class Runnable {
  Object builder = null; Runnable() {} Runnable(Object p) { builder = p; } 
  public void run() {}
  public void run(float v) {} }
  
public void runEvents(ArrayList<Runnable> e) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(); }
public void runEvents(ArrayList<Runnable> e, float v) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(v); }

//execution ordonné en layer et timer


class EventPile {
  public void addEvent(Runnable r, int l) { events.add(new Event(r, l)); }
  //execution order
  public void addEventFirst(Runnable r)       { events.add(0, new Event(r, 0)); }
  public void addEventMiddleFirst(Runnable r) { events.add(0, new Event(r, 1)); }
  public void addEventMiddleLast(Runnable r)  { events.add(new Event(r, 1)); }
  public void addEventLast(Runnable r)        { events.add(new Event(r, 2)); }
  
  class Event { Runnable r; int layer; Event(Runnable _r, int l) { r = _r; layer = l; } }
  ArrayList<Event> events = new ArrayList<Event>();
  
  EventPile() { }
  public void run() {
    int layer = 0, run_count = 0;
    while (run_count < events.size()) {
      for (Event r : events) if (r.layer == layer) { r.r.run(); run_count++; } 
      layer++; } }
  public void run(float v) {
    int layer = 0, run_count = 0;
    while (run_count < events.size()) {
      for (Event r : events) if (r.layer == layer) { r.r.run(v); run_count++; } 
      layer++; } }
  
}


/*
  class special value : svalue
    ref, type, val, changeevents(call one by changing frame)
    can has limits (min max, float precision, vect mag or angle ...)
    
    for bool int float string vector color(is int?)
    
    
   
*/

abstract class sValue {
  public sValueBloc getBloc() { return bloc; }
  public abstract String getString();
  public void clear() { 
    clean();
    bloc.values.remove(ref, this); 
  }
  public void clean() { 
    if (doevent) runEvents(eventsDelete);
    if (bloc.doevent) runEvents(bloc.eventsDelVal);
  }
  public sValue doEvent(boolean v) { doevent = v; return this; }
  public sValue addEventDelete(Runnable r) { eventsDelete.add(r); return this; }
  public sValue addEventChange(Runnable r) { eventsChange.add(r); return this; }
  public sValue removeEventChange(Runnable r) { eventsChange.remove(r); return this; }
  public sValue addEventAllChange(Runnable r) { eventsAllChange.add(r); return this; }
  public void doChange() { if (doevent) runEvents(eventsAllChange); has_changed = true; }
  sValueBloc bloc;
  boolean has_changed = false, doevent = true;
  String ref, type, shrt;
  //abstract Object def;
  sValue(sValueBloc b, String t, String r, String s) { 
    bloc = b; 
    while (bloc.values.get(r) != null) r = r + "'";
    type = t; ref = r; shrt = s;
    bloc.values.put(ref, this); 
    if (bloc.doevent) bloc.last_created_value = this; 
    if (bloc.doevent) runEvents(bloc.eventsAddVal); }
  public void frame() { if (has_changed) { if (doevent) runEvents(eventsChange); } has_changed = false; }
  ArrayList<Runnable> eventsChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsAllChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelete = new ArrayList<Runnable>();
  public void save_to_bloc(Save_Bloc sb) {
    vlogln("sv save " + ref);
    sb.newData("ref", ref);
    sb.newData("typ", type);
    sb.newData("shr", shrt);
  }
  public void load_from_bloc(Save_Bloc svb) {
    vlogln("sv load " + ref);
    ref = svb.getData("ref");
    type = svb.getData("typ");
    shrt = svb.getData("shr");
    has_changed = true;
  }
}


class sInt extends sValue {
  boolean limited_min = false, limited_max = false; int min, max;
  public sInt set_limit(int mi, int ma) { limited_min = true; limited_max = true; min = mi; max = ma; return this; }
  public sInt set_min(int mi) { limited_min = true; min = mi; return this; }
  public sInt set_max(int ma) { limited_max = true; max = ma; return this; }
  public int getmin() { return min; }
  public int getmax() { return max; }
  public String getString() { return str(val); }
  public void clear() { super.clear(); val = def; }
  int val = 0, def;
  float ctrl_factor = 2;
  sInt(sValueBloc b, int v, String n, String s) { super(b, "int", n, s); val = v; def = val; }
  public int get() { return val; }
  public void set(int v) { 
    if (limited_max && v > max) v = max; if (limited_min && v < min) v = min;
    if (v != val) { val = v; doChange(); } }
  public void add(int v) { set(get()+v); }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getInt("val"));
  }
}

class sFlt extends sValue {
  boolean limited_min = false, limited_max = false; float min, max;
  public sFlt set_limit(float mi, float ma) { limited_min = true; limited_max = true; min = mi; max = ma; return this; }
  public sFlt set_min(float mi) { limited_min = true; min = mi; return this; }
  public sFlt set_max(float ma) { limited_max = true; max = ma; return this; }
  public float getmin() { return min; }
  public float getmax() { return max; }
  public String getString() { return trimStringFloat(val); }
  public void clear() { super.clear(); val = def; }
  float val = 0, def;
  float ctrl_factor = 2;
  sFlt(sValueBloc b, float v, String n, String s) { super(b, "flt", n, s); val = v; def = val; }
  public float get() { return val; }
  public void set(float v) { 
    if (limited_max && v > max) v = max; if (limited_min && v < min) v = min;
    if (v != val) { val = v; doChange(); } }
  public void add(float v) { set(get()+v); }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getFloat("val"));
  }
}

class sBoo extends sValue {
  public String getString() { return str(val); }
  public void clear() { super.clear(); val = def; }
  boolean val = false, def;
  sBoo(sValueBloc b, boolean v, String n, String s) { super(b, "boo", n, s); val = v; def = val; }
  public boolean get() { return val; }
  public void set(boolean v) { if (v != val) { val = v; doChange(); } }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getBoolean("val"));
  }
}

class sStr extends sValue {
  boolean limited; int max;
  public sStr set_limit(int ma) { limited = true; max = ma; return this; }
  public sStr clear_limit() { limited = false; return this; }
  public String getString() { return copy(val); }
  public void clear() { super.clear(); val = copy(def); }
  String val = null, def;
  sStr(sValueBloc b, String v, String n, String s) { super(b, "str", n, s); val = copy(v); def = copy(val); }
  public String get() { return copy(val); }
  public void set(String v) { if (!v.equals(val)) { 
    if (limited && v.length() > max) val = v.substring(0, max); else val = copy(v); doChange(); } }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getData("val"));
  }
}

class sVec extends sValue {
  public String getString() { return trimStringFloat(val.x) + "," + trimStringFloat(val.y); }
  public void clear() { super.clear(); val.x = def.x; val.y = def.y; }
  private PVector val = new PVector(), def = new PVector();
  sVec(sValueBloc b, String n, String s) { super(b, "vec", n, s); }
  public float x() { return val.x; }
  public float y() { return val.y; }
  public PVector get() { return new PVector(val.x, val.y); }
  public sVec setx(float v) { if (v != val.x) { val.x = v; doChange(); } return this; }
  public sVec sety(float v) { if (v != val.y) { val.y = v; doChange(); } return this; }
  public sVec set(float _x, float _y) { 
    if (_x != val.x || _y != val.y) {
      val.x = _x; 
      val.y = _y; 
      doChange(); 
    } 
    return this;
  }
  public sVec set(PVector v) { set(v.x, v.y); return this; }
  public sVec addx(float _x) { setx(val.x+_x); return this; }
  public sVec addy(float _y) { sety(val.y+_y); return this; }
  public sVec add(float _x, float _y) { set(val.x+_x, val.y+_y); return this; }
  public sVec add(PVector v) { add(v.x, v.y); return this; }
  public sVec add(sVec v) { add(v.x(), v.y()); return this; }
  public sVec mult(float m) { set(val.x*m, val.y*m); return this; }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("x", val.x);
    svb.newData("y", val.y); }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getFloat("x"), svb.getFloat("y")); }
}

class sCol extends sValue {
  public String getString() { return trimStringFloat(red(val)) + "," + 
                              trimStringFloat(green(val)) + "," + 
                              trimStringFloat(blue(val)); }
  public void clear() { super.clear(); val = def; }
  private int val = color(255), def = color(255);
  sCol(sValueBloc b, String n, String s) { super(b, "col", n, s); }
  public float getred() { return red(val); }
  public float getgreen() { return green(val); }
  public float getblue() { return blue(val); }
  public int get() { return val; }
  public sCol set(int c) { 
    if (c != val) {
      val = c;  
      doChange(); 
    } 
    return this;
  }
  public sCol set(int r, int g, int b) { 
    set(color(r,g,b));
    return this;
  }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("c", val); }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getInt("c")); }
}

class sRun extends sValue {
  public String getString() { return ref; }
  public void clear() { super.clear(); }
  private Runnable val;
  sRun(sValueBloc b, String n, String s, Runnable r) { super(b, "run", n, s);  val = r; }
  public sRun run() { val.run(); doChange(); return this; }
  public sRun set(Runnable v) { val = v; return this; }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb); }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb); }
}

class sObj extends sValue {
  public String getString() { return ref; }
  public void clear() { super.clear(); }
  private Object val = null;
  sObj(sValueBloc b, String n, Object r) { super(b, "obj", n, "obj");  val = r; }
  public sObj set(Object r) { val = r; return this; }
  public Object get() { return val; }
  public void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb); }
  public void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb); }
}

//class sBlc extends sValue {
//  String getString() { return ref; }
//  void clear() { super.clear(); }
//  private Save_Bloc val;
//  sBlc(sValueBloc b, String n, String s) { super(b, "blc", n, s); val = new Save_Bloc(n); }
//  void set(Save_Bloc r) { if (r != null) { val = new Save_Bloc(ref); val.copy_from(r); } }
//  Save_Bloc get() { Save_Bloc b = new Save_Bloc(""); if (val != null) b.copy_from(val); return b; }
//  void save_to_bloc(Save_Bloc svb) { 
//    super.save_to_bloc(svb); 
//    if (val != null) svb.newBloc("bloc").copy_from(val);
//  }
//  void load_from_bloc(Save_Bloc svb) { 
//    super.load_from_bloc(svb); 
//    //if (svb.getBloc("bloc") != null) val.copy_from(svb.getBloc("bloc"));
//  }
//}


/*
  class svalue bloc : svaluebloc
    string ref
    svalbloc parent
    svalbloc map child bloc
    svalue map<string name, svalue>
*/


boolean DEBUG_SVALUE = false;
public void vlog(String s) {
  if (DEBUG_SVALUE) print(s);
}
public void vlogln(String s) {
  if (DEBUG_SVALUE) println(s);
}


class Iterator<T> { 
  Object builder;
  Iterator() {}
  Iterator(Object _b) { builder = _b; }
  public void run(T t) {} 
  public void run(T t, int c) {} 
}


class sValueBloc {
  public void runIterator(Iterator<sValue> i) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      i.run(v);
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      vb.runIterator(i);
    }
  }
  public void runValueIterator(Iterator<sValue> i) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      i.run(v);
    }
  }
  public void runBlocIterator(Iterator<sValueBloc> i) { 
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      i.run(vb); } }
  public int runIterator_Counted(Iterator<sValue> i) { return runIterator_Counted(i, 0); }
  public int runIterator_Counted(Iterator<sValue> i, int c) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      i.run(v, c); c++;
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.runIterator_Counted(i, c);
    }
    return c;
  }
  public void runIterator_Filter(String t, Iterator<sValue> i) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) i.run(v);
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      vb.runIterator_Filter(t, i);
    }
  }
  public int runIterator_Filter_Counted(String t, Iterator<sValue> i) { return runIterator_Filter_Counted(t, i, 0); }
  public int runIterator_Filter_Counted(String t, Iterator<sValue> i, int c) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) { i.run(v, c); c++; }
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.runIterator_Filter_Counted(t, i, c);
    }
    return c;
  }
  public sValue searchValue(String t) { 
    sValue e = values.get(t);
    if (e != null) return e;
    for (Map.Entry me : blocs.entrySet()) {
      e = ( (sValueBloc)(me.getValue()) ).searchValue(t);
      if (e != null) return e; }
    return null;
  }
  public int getCountOfType(String t) { return getCountOfType(t, 0); }
  public int getCountOfType(String t, int c) {
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) c++;
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.getCountOfType(t, c);
    }
    return c;
  }
  
  /*
   bloc event
      add val
      add bloc
      delete val
      delete bloc
      delete
      
    val event
      change 
      delete
  */
  
  public sValueBloc doEvent(boolean t) { doevent = t; return this; }
  public sValueBloc addEventAddValue_Builder(Runnable r) { r.builder = this; eventsAddVal.add(r); return this; }
  public sValueBloc addEventAddBloc_Builder(Runnable r) { r.builder = this; eventsAddBloc.add(r); return this; }
  public sValueBloc addEventDelValue_Builder(Runnable r) { r.builder = this; eventsDelVal.add(r); return this; }
  public sValueBloc addEventDelBloc_Builder(Runnable r) { r.builder = this; eventsDelBloc.add(r); return this; }
  public sValueBloc addEventDelete_Builder(Runnable r) { r.builder = this; eventsDelete.add(r); return this; }
  ArrayList<Runnable> eventsAddVal = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsAddBloc = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelVal = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelBloc = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelete = new ArrayList<Runnable>();
  
  public sValueBloc getBloc(String r) { return blocs.get(r); }
  public sValueBloc getLastBloc() { return last_created_bloc; }
  public sValue getValue(String r) { return values.get(r); }
  public sValueBloc newBloc(String n) { return new sValueBloc(this, n); }
  public sInt newInt(String n, String s, int v)       { return new sInt(this, v, n, s); }
  public sFlt newFlt(String n, String s, float v)     { return new sFlt(this, v, n, s); }
  public sBoo newBoo(String n, String s, boolean v)   { return new sBoo(this, v, n, s); }
  public sInt newInt(int v, String n, String s)       { return new sInt(this, v, n, s); }
  public sFlt newFlt(float v, String n, String s)     { return new sFlt(this, v, n, s); }
  public sBoo newBoo(boolean v, String n, String s)   { return new sBoo(this, v, n, s); }
  public sStr newStr(String n, String s, String v)    { return new sStr(this, v, n, s); }
  public sVec newVec(String n, String s, PVector v)   { return new sVec(this, n, s).set(v); }
  public sVec newVec(String n, String s)              { return new sVec(this, n, s); }
  public sCol newCol(String n, String s, int v)     { return new sCol(this, n, s).set(v); }
  public sCol newCol(String n, String s)              { return new sCol(this, n, s); }
  public sRun newRun(String n, String s, Runnable v)  { return new sRun(this, n, s, v); }
  //sBlc newBlc(String n, String s) { return new sBlc(this, n, s); }
  public sObj newObj(String n, Object v) { return new sObj(this, n, v); }
  
  DataHolder data; sValueBloc parent = null, last_created_bloc = null; 
  sValue last_created_value = null;
  String ref, base_ref, type = "def", use = "";
  HashMap<String, sValue> values = new HashMap<String, sValue>();
  HashMap<String, sValueBloc> blocs = new HashMap<String, sValueBloc>();
  String adress; boolean doevent = true;
  sValueBloc() {}    //only for superclass dataholder and saving
  sValueBloc(DataHolder d, String r) { base_ref = r;
    while (d.blocs.get(r) != null) r = r + "_";
    d.blocs.put(r, this); data = d; parent = d; ref = r; adress = "data/";}
  sValueBloc(sValueBloc b, String r) { base_ref = r;
    while (b.blocs.get(r) != null) r = r + "'";
    b.blocs.put(r, this); data = b.data; parent = b; 
    ref = r; adress = b.adress + b.ref + "/"; 
    if (parent.doevent) parent.last_created_bloc = this; 
    if (parent.doevent) runEvents(parent.eventsAddBloc); }
  public void frame() {
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.frame(); }
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.frame(); } }
  public void clear() {
    clean();
    parent.blocs.remove(ref, this);
  }
  public void clean() {
    //parent.blocs.remove(ref, this);
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.clean(); } 
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.clean(); } 
    blocs.clear(); values.clear();
    if (doevent) runEvents(eventsDelete); 
    if (parent.doevent) runEvents(parent.eventsDelBloc);
  }
  
  public void load_from_bloc(Save_Bloc sb) {
    vlogln("svb load " + ref + "  /svb " + sb.blocs.size() + " /sv " + sb.datas.size());
    
    for (Map.Entry b : blocs.entrySet()) { 
      sValueBloc s = (sValueBloc)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
    
    for (Map.Entry b : values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
  }
  
  public void load_values_from_bloc(Save_Bloc sb) {
    vlogln("svb load " + ref + "  /svb " + sb.blocs.size() + " /sv " + sb.datas.size());
    
    for (Map.Entry b : values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
  }
  public void preset_value_to_save_bloc(Save_Bloc sb) {
    dlog("valuebloc " + ref + " saving to savebloc > clearing savebloc >");
    sb.clear();
    dlogln(" saving ref typ >");
    sb.newData("__bloc_type", type);
    sb.newData("__bloc_ref", ref);
    sb.newData("__bloc_bas", base_ref);
    sb.newData("__bloc_use", use);
    
    dlogln("saving under values >");
    for (Map.Entry me : values.entrySet()) { 
      sValue s = (sValue)me.getValue(); 
      Save_Bloc sbv = sb.newBloc((String)me.getKey());
      sbv.newData("__bloc_type", "val");
      s.save_to_bloc(sbv); } 
    
    dlogln("done saving " + ref + " to savebloc");
  }
  
  public String getHierarchy(boolean print_ref) {
    String struct = "<bloc_"+type;
    if (print_ref) struct += "_"+ref;
    struct += ":"+"values<";
    for (Map.Entry me : values.entrySet()) { 
      sValue v = (sValue)me.getValue(); 
      struct += "<val_"+v.type;
      if (print_ref) struct += "_"+v.ref;
      struct += ">";
    } 
    struct += ">blocs<";
    for (Map.Entry me : blocs.entrySet()) { 
      sValueBloc vb = (sValueBloc)me.getValue(); 
      struct += vb.getHierarchy(print_ref);
      struct += "-";
    } 
    struct += ">>";
    return struct;
  }
  public String getValueHierarchy(boolean print_ref) {
    String struct = "<bloc_"+type;
    if (print_ref) struct += "_"+ref;
    struct += ":"+"values<";
    for (Map.Entry me : values.entrySet()) { 
      sValue v = (sValue)me.getValue(); 
      struct += "<val_"+v.type;
      if (print_ref) struct += "_"+v.ref;
      struct += ">";
    } 
    struct += ">>";
    return struct;
  }
  
  
  
  public int preset_to_save_bloc(Save_Bloc sb) { return preset_to_save_bloc(sb, 0); }
  public int preset_to_save_bloc(Save_Bloc sb, int cnt) {
    dlog("valuebloc " + ref + " saving to savebloc > val counter: " + cnt + " > clearing savebloc >");
    sb.clear();
    dlogln(" saving ref typ >");
    sb.newData("__bloc_type", type);
    sb.newData("__bloc_ref", ref);
    sb.newData("__bloc_bas", base_ref);
    sb.newData("__bloc_use", use);
    
    dlogln("saving under blocs >");
    for (Map.Entry me : blocs.entrySet()) { 
      sValueBloc svb = (sValueBloc)me.getValue(); 
      Save_Bloc sb2 = sb.newBloc(svb.ref);
      cnt = svb.preset_to_save_bloc(sb2, cnt); 
    } 
    dlogln("saving under values >");
    for (Map.Entry me : values.entrySet()) { 
      sValue s = (sValue)me.getValue(); 
      Save_Bloc sbv = sb.newBloc((String)me.getKey());
      sbv.newData("__bloc_type", "val");
      cnt++;
      s.save_to_bloc(sbv); } 
    
    dlogln("done saving " + ref + " to savebloc");
    return cnt;
  }

  
  public sValue newValue(Save_Bloc sb) {
    sValue nv = null;
    if (sb.getData("__bloc_type") != null && sb.getData("__bloc_type").equals("val")) {
      String n = sb.getData("ref");
      String s = sb.getData("shr");
      String t = sb.getData("typ");
      if (t.equals("int")) { nv = new sInt(this, 0, n, s);      nv.load_from_bloc(sb); }
      if (t.equals("flt")) { nv = new sFlt(this, 0, n, s);      nv.load_from_bloc(sb); }
      if (t.equals("boo")) { nv = new sBoo(this, false, n, s);  nv.load_from_bloc(sb); }
      if (t.equals("str")) { nv = new sStr(this, "", n, s);     nv.load_from_bloc(sb); }
      if (t.equals("vec")) { nv = new sVec(this, n, s);         nv.load_from_bloc(sb); }
      if (t.equals("col")) { nv = new sCol(this, n, s);         nv.load_from_bloc(sb); }
      if (t.equals("run")) { nv = new sRun(this, n, s, null);   nv.load_from_bloc(sb); }
      //if (t.equals("blc")) { nv = new sBlc(this, n, s);      nv.load_from_bloc(sb); }
      if (t.equals("obj")) { nv = new sObj(this, n, null);   nv.load_from_bloc(sb); }
    }
    return nv;
  }
  
  public sValueBloc newBloc(Save_Bloc sb) {
    dlogln("newbloc");
    if (sb.getData("__bloc_type") != null && sb.getData("__bloc_ref") != null && 
        sb.getData("__bloc_bas") != null && sb.getData("__bloc_use") != null && 
        sb.getData("__bloc_type").equals("def")) {
      dlogln("got it");
      String b = sb.getData("__bloc_bas");
      String u = sb.getData("__bloc_use");
      sValueBloc vb = new sValueBloc(this, b);
      vb.use = u;
      for (Save_Bloc csb : sb.blocs) {
        String type = csb.getData("__bloc_type");
        if      (type != null && type.equals("def")) { vb.newBloc(csb); } 
        else if (type != null && type.equals("val")) { vb.newValue(csb); }
      }
      return vb;
    }
    return null;
  }
  
  public sValueBloc newBloc(Save_Bloc sb, String n) {
    dlogln("newbloc");
    if (sb.getData("__bloc_type") != null && sb.getData("__bloc_ref") != null && 
        sb.getData("__bloc_bas") != null && sb.getData("__bloc_use") != null && 
        sb.getData("__bloc_type").equals("def")) {
      dlogln("got it");
      //String b = sb.getData("__bloc_bas");
      String u = sb.getData("__bloc_use");
      sValueBloc vb = new sValueBloc(this, n);
      vb.use = u;
      for (Save_Bloc csb : sb.blocs) {
        String type = csb.getData("__bloc_type");
        if      (type != null && type.equals("def")) { vb.newBloc(csb); } 
        else if (type != null && type.equals("val")) { vb.newValue(csb); }
      }
      return vb;
    }
    return null;
  }
  
}
/*
  
DataHolding
  svalue bloc map<string name, bloc>   each bloc loaded and saved independently
  runnables map<string name, run>      string-referanced runnables for saving
  
  frame()
    for bloc : map runFrameEventsIf() unFlagChanges()
*/

boolean DEBUG_DATA = false;
public void dlog(String s) {
  if (DEBUG_DATA) print(s);
}
public void dlogln(String s) {
  if (DEBUG_DATA) println(s);
}

class DataHolder extends sValueBloc {
  
  DataHolder() {
    super(); ref = "data"; parent = this; 
  }
  String[] types = {"flt", "int", "boo", "str", "vec", "col", "run", "obj"};
  
  public int to_save_bloc(Save_Bloc sb) { 
    dlogln("DataHolder saving to savebloc");
    int cnt = super.preset_to_save_bloc(sb); 
    dlogln("saved " + cnt + " values");
    return cnt;
  }
}

public boolean values_match(sValueBloc b1, sValueBloc b2) {
  return b1.getValueHierarchy(true).equals(b2.getValueHierarchy(true)); }
  
public boolean values_found(sValueBloc from, sValueBloc in) {
  boolean all_found = true;
  for (Map.Entry me1 : from.values.entrySet()) { 
    sValue v1 = (sValue)me1.getValue(); 
    boolean found = false;
    for (Map.Entry me2 : in.values.entrySet()) { 
      sValue v2 = (sValue)me2.getValue(); 
      found = found || v1.ref.equals(v2.ref);
    } 
    all_found = all_found && found;
  } 
  return all_found; }
  

public boolean full_match(sValueBloc b1, sValueBloc b2) {
  return b1.getHierarchy(true).equals(b2.getHierarchy(true)); }


public void copy_bloc(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    to.newBloc(b, from.base_ref);
  } 
}
public sValueBloc copy_bloc(sValueBloc from, sValueBloc to, String n) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    return to.newBloc(b, n);
  } return null;
}
public sValue copy_value(sValue from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc(from.ref);
    from.save_to_bloc(b);
    return to.newValue(b);
  } return null;
}
public void transfer_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null &&
      from.getHierarchy(true).equals(to.getHierarchy(true))) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    to.load_from_bloc(b);
  } 
}

public void copy_bloc_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_value_to_save_bloc(b);
    to.newBloc(b, "copy");
  } 
}
public void copy_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_value_to_save_bloc(b);
    for (Save_Bloc bl : b.blocs) to.newValue(bl);
  } 
}
public void transfer_bloc_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_value_to_save_bloc(b);
    to.load_values_from_bloc(b);
  } 
}




//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


boolean DEBUG_SAVE_FULL = false;
public void slog(String s) {
  if (DEBUG_SAVE_FULL) print(s);
}
public void slogln(String s) {
  if (DEBUG_SAVE_FULL) println(s);
}

/*
  class sdata
    string ref data
  class sdatabloc
    string ref
    list<sdata>
    list<sbloc>
  save and load sdatabloc from file methods
  svaluebloc To sdatabloc  /  svaluebloc From sdatabloc()
*/


class Save_List {
  String[] list;
  int index = 0;
  
  public void put(String log, String s) { 
    list[index] = copy(s); 
    slog("put " + log + " " + index + " " + s); 
    index++; }
  public String get(String log) { 
    slog("get " + log + " " + index + " " + list[index]); 
    index++; 
    return list[index-1]; }
  public int getInt(String log) { return PApplet.parseInt(get(log)); }
  
  public void init(int size) { list = new String[size]; index = 0; }
  public void init(String[] l) { list = l; index = 0; }
}


class Save_Data {
  String name, data;
  Save_Data(String n, String d) { name = copy(n); data = copy(d); }
  public int size() { return 2; }
  public String get() { return data; }
  public void set(String d) { data = copy(d); }
  public void clear() { }
}



class Save_Bloc {
  
  public void runIterator(Iterator<Save_Bloc> i) { 
    int count = 0;
    for (Save_Bloc b : blocs) { count++; i.run(b); i.run(b, count); }
  }
  
  public Save_Data newData(String n, String d) {
    Save_Data sd = new Save_Data(n, d); datas.add(sd); return sd; }
    
  public Save_Data newData(String n, int d) { return newData(n, str(d)); } 
  public Save_Data newData(String n, float d) { return newData(n, str(d)); } 
  public Save_Data newData(String n, boolean d) { if (d) return newData(n, "1"); else return newData(n, "0"); } 
  
  public Save_Bloc newBloc(String n) {
    Save_Bloc sd = new Save_Bloc(n); blocs.add(sd); return sd; }//, blocs.size()
  public Save_Bloc addBloc(Save_Bloc n) {
    blocs.add(n); return n; }
  
  public void setData(String n, String d) { for (Save_Data sd : datas) if (sd.name.equals(n)) { sd.set(d); return; } }
  
  public String getData(String n) { for (Save_Data sd : datas) if (sd.name.equals(n)) return sd.get(); return null; }
  public int getInt(String n) { return PApplet.parseInt(getData(n)); }
  public float getFloat(String n) { return PApplet.parseFloat(getData(n)); }
  public boolean getBoolean(String n) { if (getData(n).equals("1")) return true; else return false; }
  
  public Save_Bloc getBloc(String n) { for (Save_Bloc sd : blocs) if (sd.name.equals(n)) return sd; return null; }
  
  public void clear() {
    for (Save_Data d : datas) d.clear();
    datas.clear();
    for (Save_Bloc b : blocs) b.clear();
    blocs.clear();
  }
  
  
  public void copy_from(Save_Bloc svb) { 
    slog("bloc - copy from");
    clear();
    name = copy(svb.name); index = svb.index; 
    Save_List sl = new Save_List();
    sl.init(svb.size());
    svb.to_list(sl);
    from_list(sl);
  }
  
  public void save_to(String savepath) { 
    slog("bloc - save to");
    Save_List sl = new Save_List();
    sl.init(size());
    to_list(sl);
    saveStrings(savepath, sl.list);
  }
  public void load_from(String savepath) { 
    slog("bloc - load from");
    clear();
    String[] load = loadStrings(savepath);
    Save_List sl = new Save_List();
    sl.init(load);
    from_list(sl);
  }
  
  //Save_Bloc(String n, int i) { name = copy(n); index = i; }
  Save_Bloc(String n) { name = copy(n); index = 0; }
  
  String name;
  int index;
  ArrayList<Save_Data> datas = new ArrayList<Save_Data>();
  ArrayList<Save_Bloc> blocs = new ArrayList<Save_Bloc>();
  
  
  public void to_list(Save_List sl) {
    slog("Bloc - to string - start");
    sl.put("name", name);
    sl.put("total size", str(size()));
    
    sl.put("datas nb", str(datas.size()));
    int leng = 0;
    for (Save_Data sd : datas) leng += sd.size();
    sl.put("datas total size", str(leng));
    slog("datas to string start");
    for (Save_Data sd : datas) { sl.put("name", sd.name); sl.put("data", sd.data); }
    slog("datas to string end");
    
    sl.put("child blocs nb", str(blocs.size()));
    leng = 0;
    for (Save_Bloc sd : blocs) leng += sd.size();
    sl.put("child blocs total size", str(leng));
    slog("child blocs to string start");
    for (Save_Bloc sb : blocs) sb.to_list(sl);
    slog("child blocs to string end");
    
    slog("Bloc - to string - end");
  }
  
  int total_size = 0;
  int datas_nb = 0;
  int data_size = 0;
  int bloc_nb = 0;
  int blocs_total_size = 0;
  
  public void from_list(Save_List sl) {
    slog("Bloc - from string - start");
    
    name = sl.get("name");
    total_size = sl.getInt("total size");
    
    datas_nb = sl.getInt("datas nb");
    data_size = sl.getInt("datas total size");
    slog("datas from string start");
    for (int i = 0; i < datas_nb ; i++) newData(sl.get("name"), sl.get("data"));
    slog("datas from string end");
    
    bloc_nb = sl.getInt("blocs nb");
    blocs_total_size = sl.getInt("child blocs total size");
    slog("child blocs from string start");
    for (int i = 0; i < bloc_nb ; i++) {
      Save_Bloc sb = newBloc("");
      sb.from_list(sl);
    }
    slog("child blocs from string end");
    
    slog("Bloc - from string - end");
  }
  public int size() { 
    int s = 6;
    for (Save_Data sd : datas) s += sd.size();
    for (Save_Bloc sb : blocs) s += sb.size();
    return s; 
  }
}







//void mysetup() {
//  Save_List sl = new Save_List();
//  Save_Bloc sb = new Save_Bloc("save data");
  
//  int a = 0, b = 1, c = 2;
//  println("start: a " + a + " b " + b + " c " + c);
  
//  //gather datas
//  sb.newData("a",str(a));
//  sb.newData("b",str(b));
//  sb.newData("c",str(c));
  
//  //change data
//  sb.setData("b",str(5));
  
//  //save
//  sb.save_to("savetest.txt");
  
//  //load
//  sb.load_from("savetest.txt");
  
//  //retrieve data
//  a = int(sb.getData("a"));
//  b = int(sb.getData("b"));
//  c = int(sb.getData("c"));
  
//  println("end: a " + a + " b " + b + " c " + c);
//}

/*
 //* Listing files in directories and subdirectories
 //* by Daniel Shiffman.  
 //* 
 //* This example has three functions:<br />
 //* 1) List the names of files in a directory<br />
 //* 2) List the names along with metadata (size, lastModified)<br /> 
 //*    of files in a directory<br />
 //* 3) List the names along with metadata (size, lastModified)<br />
 //*    of files in a directory and all subdirectories (using recursion) 



import java.util.Date;

void setup() {

  // Using just the path of this sketch to demonstrate,
  // but you can list any directory you like.
  String path = sketchPath();

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  printArray(filenames);

  println("\nListing info about all files in a directory: ");
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    println("Name: " + f.getName());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  println("\nListing info about all files in a directory and all subdirectories: ");
  ArrayList<File> allFiles = listFilesRecursive(path);

  for (File f : allFiles) {
    println("Name: " + f.getName());
    println("Full path: " + f.getAbsolutePath());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  noLoop();
}

// Nothing is drawn in this program and the draw() doesn't loop because
// of the noLoop() in setup()
void draw() {
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

// Function to get a list of all files in a directory and all subdirectories
ArrayList<File> listFilesRecursive(String dir) {
  ArrayList<File> fileList = new ArrayList<File>(); 
  recurseDir(fileList, dir);
  return fileList;
}

// Recursive function to traverse subdirectories
void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    // If you want to include directories in the list
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      // Call this function on all files in this directory
      recurseDir(a, subfiles[i].getAbsolutePath());
    }
  } else {
    a.add(file);
  }
}
*/





 
/*
 Interface
   Inputs, DataHolding
   class CameraView 
     name
     pos and scale as svalue
     map<name, CameraView> : views
     name of current view as svalue
   
   drawing_pile screen_draw, cam_draw
   hover_pile screen and cam
   
   event hoverpilesearch both no find
   
   list<runnable> frameEvents
   
   frame()
     hover_pile.search() if screen found dont do cam
     run frameEvents
     update cam view from inputs
     clear screen
     draw grid if needed
     draw cam then screen from their pov
     to control when to screenshot maybe do it in a Drawer
 
 
 
 */

class User {
  String access = "admin";
  User() {}
  User(String a) { access = copy(a); }
}

class sInterface {

  public void filesManagement() {
    if (files_panel == null) {
      files_panel = new nWindowPanel(screen_gui, taskpanel, "Files");
      files_panel.setSpace(0.25f);
      files_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(0.6f)
          .addModel("Label-S4", "Select File :                                   ").setPY(-0.2f*ref_size).getShelf()
        .addDrawer(0.75f)
          .addLinkedModel("Field-SS4", savepath).setLinkedValue(savepath_value).getShelf()
        .addDrawer(1)
          .addModel("Label-S4", "File datas :                                   ").getDrawer()
          .addCtrlModel("Button_Outline-S2", "Save")
            .setRunnable(new Runnable() { public void run() { file_explorer_save(); } } )
            .setPX(ref_size*4)
            .getDrawer()
          .addCtrlModel("Button_Outline-S2", "Load")
            .setRunnable(new Runnable() { public void run() { file_explorer_load(); } } )
            .setPX(ref_size*7)
            .getShelf()
            ;
        
      
      files_panel.addShelf()
        .addSeparator(0.5f)
        .addDrawer(1)
          .addCtrlModel("Button_Small_Text_Outline-S3-P1", "close file")
            .setRunnable(new Runnable() { public void run() { 
              if (explored_bloc != null) explored_bloc.clear();
              explored_bloc.clear(); explored_bloc = null;
              file_explorer.setStrtBloc(null);
              file_explorer.update(); data_explorer.update(); update_list(); 
            } } )
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3-P2", "go to /")
            .setRunnable(new Runnable() { public void run() { 
              data_explorer.setStrtBloc(interface_bloc); 
              data_explorer.update(); update_list(); 
            } } )
            .getShelf()
        .addDrawer(10, 1)
          .addCtrlModel("Button_Small_Text_Outline-S3-P1", "delete file bloc")
            .setRunnable(new Runnable() { public void run() { 
              if (file_explorer.selected_bloc != null) { file_explorer.selected_bloc.clear(); }
              file_explorer.update();
            } } )
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3-P2", "dump data")
            .setRunnable(new Runnable() { public void run() { full_data_save(); } } ) //full_data_load();
            .getShelf()
        ;
        
      
      files_panel.getShelf(0)
        .addSeparator(0.25f)
        .addDrawer(2)
          .addCtrlModel("Button_Small_Text_Outline-S3", "COPY BLOC\nINTO DATA")
            .setRunnable(new Runnable() { public void run() { copy_file_to_data(); } } )
            .setPX(ref_size*0).setSY(ref_size*2)
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "TRANSFER\nFILE VALUES\nTO DATA")
            .setRunnable(new Runnable() { public void run() { transfer_file_to_data(); } } )
            .setPX(ref_size*4).setSY(ref_size*2)
            ;
            
      match_flag = files_panel.getShelf(0)
        .getLastDrawer()
          .addModel("Label_DownLight_Back_Downlight_Outline-S3", "MATCHING\nBLOCS PRINT")
            .setPX(ref_size*8).setSY(ref_size*2);
      
      files_panel.getShelf(0)
        .getLastDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "TRANSFER\nDATA VALUES\nTO FILE")
            .setRunnable(new Runnable() { public void run() { transfer_data_to_file(); } } )
            .setPX(ref_size*12).setSY(ref_size*2)
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "COPY BLOC\nINTO FILE")
            .setRunnable(new Runnable() { public void run() { copy_data_to_file(); } } )
            .setPX(ref_size*16).setSY(ref_size*2)
            .getShelf()
        ;
        
      file_explorer = files_panel.getShelf(0)
        .addExplorer()
          .addEventChange(new Runnable() { public void run() { update_list(); } } )
          ;
          
      data_explorer = files_panel.getShelf(1)
        .addSeparator(2.375f)
        .addExplorer()
          .setStrtBloc(data)
          .addEventChange(new Runnable() { public void run() { update_list(); } } )
          ;
      //files_panel.collapse();
      files_panel.addEventClose(new Runnable(this) { public void run() { files_panel = null; }});
      addEventSetup(new Runnable() { public void run() { data_explorer.update(); file_explorer.update(); } } );
    } else files_panel.popUp();
  }
  
  public void copy_file_to_data() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null) {
      file_savebloc.clear();
      file_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      data_explorer.explored_bloc.newBloc(file_savebloc, "copy");
      data_explorer.update();
      //update_list();
    } 
  }
  public void copy_data_to_file() {
    if (data_explorer.selected_bloc != null && explored_bloc != null) {
      file_savebloc.clear();
      data_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      explored_bloc.newBloc(file_savebloc, "copy");
      file_explorer.update();
      //update_list();
    } 
  }
  public void transfer_file_to_data() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null &&
        file_explorer.selected_bloc.getHierarchy(true)
          .equals(data_explorer.selected_bloc.getHierarchy(true))) {
      file_savebloc.clear();
      file_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      data_explorer.selected_bloc.load_from_bloc(file_savebloc);
      data_explorer.update();
      //update_list();
    } 
  }
  public void transfer_data_to_file() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null &&
        file_explorer.selected_bloc.getHierarchy(true)
          .equals(data_explorer.selected_bloc.getHierarchy(true))) {
      file_savebloc.clear();
      data_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      file_explorer.selected_bloc.load_from_bloc(file_savebloc);
      file_explorer.update();
      //update_list();
    } 
  }

  public void update_list() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null) {
      if (file_explorer.selected_bloc.getHierarchy(true)
            .equals(data_explorer.selected_bloc.getHierarchy(true))) {
        match_flag.setLook(screen_gui.theme, "Label_HightLight_Back_Highlight_Outline-S3");
      } else match_flag.setLook(screen_gui.theme, "Label_DownLight_Back_Downlight_Outline-S3");
    } else match_flag.setLook(screen_gui.theme, "Label_DownLight_Back_Downlight_Outline-S3");
  }
  
  public void full_data_save() {
    file_savebloc.clear(); 
    interface_bloc.preset_to_save_bloc(file_savebloc); 
    file_savebloc.save_to(savepath); }
  public void full_data_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    interface_bloc.load_from_bloc(file_savebloc);
    file_explorer.update(); data_explorer.update(); }
  
  public void file_explorer_save() {
    if (explored_bloc != null) {
      file_savebloc.clear();
      explored_bloc.preset_to_save_bloc(file_savebloc);
      file_savebloc.save_to(savepath);
    }
  }
  public void file_explorer_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    if (explored_bloc != null) explored_bloc.clear();
    explored_bloc = data.newBloc(file_savebloc, "file");
    file_explorer.setStrtBloc(explored_bloc);
  }
  
  public void build_default_ui(float ref_size) {
    taskpanel = new nTaskPanel(screen_gui, ref_size, 0.125f);
    
    if (!show_taskpanel.get()) taskpanel.reduc();
    taskpanel.addEventReduc(new Runnable() { public void run() { 
      show_taskpanel.set(!taskpanel.hide); }});
      
    savepath_value = new sStr(interface_bloc, savepath, "savepath", "spath");
    file_savebloc = new Save_Bloc(savepath);
    //filesManagement();
  }
  
  nWidget match_flag;
  nWindowPanel files_panel;
  String savepath = "save.sdata";
  sStr savepath_value;
  sBoo auto_load;
  Save_Bloc file_savebloc;
  sValueBloc explored_bloc, setup_bloc;
  nExplorer file_explorer, data_explorer;
  nTaskPanel taskpanel;
  float ref_size;
  
  sBoo show_taskpanel;
  
  

  sInput input;
  private DataHolder data; 
  sValueBloc interface_bloc;

  nTheme gui_theme;
  nGUI screen_gui, cam_gui;

  Camera cam;
  sFramerate framerate;

  Macro_Main macro_main;
  
  User user;
  /*
  method for sStr : pack unpack
    get string list + token > convert to string
    inversement
  
  */

  sInterface(float s) {
    ref_size = s;
    user = new User("user");
    input = new sInput();
    data = new DataHolder();
    interface_bloc = new sValueBloc(data, "Interface");
    gui_theme = new nTheme(ref_size);
    screen_gui = new nGUI(input, gui_theme, ref_size);
    cam_gui = new nGUI(input, gui_theme, ref_size);
    
    show_taskpanel = interface_bloc.newBoo("show_taskpanel", "taskpanel", true);
    show_taskpanel.addEventChange(new Runnable(this) { public void run() { 
      if (taskpanel != null && taskpanel.hide == show_taskpanel.get()) taskpanel.reduc();
    }});
    
    build_default_ui(ref_size);
    
    macro_main = new Macro_Main(this);
    
    framerate = new sFramerate(macro_main.value_bloc, 60);
    
    cam = new Camera(input, macro_main.value_bloc)
      .addEventZoom(new Runnable() { public void run() { cam_gui.updateView(); } } )
      .addEventMove(new Runnable() { public void run() { cam_gui.updateView(); } } );
    
    screen_gui.addEventFound(new Runnable() { public void run() { 
      cam.GRAB = false; cam_gui.hoverpile_passif = true; } } )
    .addEventNotFound(new Runnable() { public void run() { 
      cam.GRAB = true; cam_gui.hoverpile_passif = false; } } );
    
    cam_gui.setMouse(cam.mouse).setpMouse(cam.pmouse)
      .setView(cam.view)
      .addEventFound(new Runnable() { public void run() { cam.GRAB = false; } } )
      .addEventNotFound(new Runnable() { public void run() { 
        if (!screen_gui.hoverable_pile.found) { cam.GRAB = true; runEvents(eventsHoverNotFound); } } } );
    
    auto_load = macro_main.newBoo(false, "auto_load", "autoload");
    
    quicksave_run = macro_main.newRun("quicksave", "qsave", 
      new Runnable() { public void run() { full_data_save(); } } );
    quickload_run = macro_main.newRun("quickload", "qload", 
      new Runnable() { public void run() { addEventNextFrame(new Runnable() { 
      public void run() { setup_load(); } } ); } } );
    filesm_run = macro_main.newRun("files_management", "filesm", 
      new Runnable() { public void run() { filesManagement(); } } );
    
  }
  
  sRun quicksave_run, quickload_run, filesm_run;

  public sInterface addToCamDrawerPile(Drawable d) { d.setPile(cam_gui.drawing_pile); return this; }
  public sInterface addToScreenDrawerPile(Drawable d) { d.setPile(screen_gui.drawing_pile); return this; }
  
  public sInterface addEventHoverNotFound(Runnable r) { eventsHoverNotFound.add(r); return this; }
  public sInterface addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  public sInterface removeEventFrame(Runnable r) { eventsFrame.remove(r); return this; }
  public sInterface addEventNextFrame(Runnable r) { 
    if (active_nxtfrm_pile) eventsNextFrame1.add(r); else eventsNextFrame2.add(r); return this; }
  public sInterface addEventSetup(Runnable r) { eventsSetup.add(r); return this; }
  
  public String getAccess() { return user.access; }
  public boolean canAccess(String a) { 
    if (getAccess().equals("admin") || getAccess().equals(a) || a.equals("all")) return true; 
    else return false; }
  
  public sInterface addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  public void setup_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    if (setup_bloc != null) setup_bloc.clear();
    setup_bloc = data.newBloc(file_savebloc, "setup");
    if (setup_bloc.getValue("auto_load") == null || 
        (setup_bloc.getValue("auto_load") != null && ((sBoo)setup_bloc.getValue("auto_load")).get())) {
      for (Runnable r : eventsSetupLoad) r.builder = setup_bloc;
      runEvents(eventsSetupLoad);
      macro_main.setup_load(setup_bloc);
      
      if (setup_bloc.getValue("show_taskpanel") != null) 
        show_taskpanel.set(((sBoo)setup_bloc.getValue("show_taskpanel")).get());
      
    }
    if (setup_bloc.getValue("auto_load") != null) 
      auto_load.set(((sBoo)setup_bloc.getValue("auto_load")).get());
    //setup_bloc.clear();
  }
  
  
  public void addSpecializedSheet(Sheet_Specialize s) {
    macro_main.addSpecializedSheet(s); }
  public Macro_Sheet addUniqueSheet(Sheet_Specialize s) {
    return macro_main.addUniqueSheet(s); }


  public sValueBloc getTempBloc() {
    return new sValueBloc(data, "temp"); }


  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNextFrame1 = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNextFrame2 = new ArrayList<Runnable>();
  boolean active_nxtfrm_pile = false;
  ArrayList<Runnable> eventsHoverNotFound = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsSetup = new ArrayList<Runnable>();
  boolean is_starting = true;
  boolean show_info = true;
  public void frame() {
    input.frame_str(); // track mouse
    framerate.frame(); // calc last frame
    background(0);

    if (is_starting) { 
      is_starting = false; 
      runEvents(eventsSetup);
    }
    runEvents(eventsFrame); // << sim runs here
    if (!active_nxtfrm_pile) { runEvents(eventsNextFrame1); eventsNextFrame1.clear(); } 
    else { runEvents(eventsNextFrame2); eventsNextFrame2.clear(); } 
    active_nxtfrm_pile = !active_nxtfrm_pile;
    
    screen_gui.frame();
    cam.pushCam(); // matrice d'affichage
    cam_gui.frame();
    cam_gui.draw();
    cam.popCam();
    screen_gui.draw();

    //info:
    if (show_info) {
      fill(255); 
      textSize(18); 
      textAlign(LEFT);
      text(framerate.get() + " C " + trimStringFloat(cam.mouse.x) + 
        "," + trimStringFloat(cam.mouse.y), 10, 24 );
      text("S " + trimStringFloat(input.mouse.x) + 
        "," + trimStringFloat(input.mouse.y), 250, 24 );
    }
    
    data.frame(); // reset flags
    input.frame_end(); // reset flags
  }
}







//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


class Camera {
  sInput input;
  Rect view;
  sVec cam_pos; //position de la camera
  sFlt cam_scale; //facteur de grossicement
  float ZOOM_FACTOR = 1.1f; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true, grabbed = false;
  sBoo grid; //show grid
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
  boolean matrixPushed = false; //track if in or out of the cam matrix

  Camera(sInput i, sValueBloc d) { 
    grid = new sBoo(d, true, "show grid", "grid");
    cam_scale = new sFlt(d, 1.0f, "cam scale", "scale");
    cam_scale.addEventChange(new Runnable() { public void run() {
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos)); 
      runEvents(eventsZoom);
      runEvents(eventsMove); }});
    cam_pos = new sVec(d, "cam pos", "pos");
    cam_pos.addEventChange(new Runnable() { public void run() {
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos)); 
      runEvents(eventsZoom);
      runEvents(eventsMove); }});
    view = new Rect(0, 0, width, height);
    view.pos.set(screen_to_cam(new PVector(0, 0)));
    view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
    input = i;
  }

  ArrayList<Runnable> eventsZoom = new ArrayList<Runnable>();
  public Camera addEventZoom(Runnable r) { 
    eventsZoom.add(r); 
    return this;
  }
  ArrayList<Runnable> eventsMove = new ArrayList<Runnable>();
  public Camera addEventMove(Runnable r) { 
    eventsMove.add(r); 
    return this;
  }

  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement

  public void pushCam(float x, float y) {
    cam_pos.add(x*cam_scale.get(), y*cam_scale.get());
  }

  public void pushCam() {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale.get());
    translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));
    matrixPushed = true;

    if (grid.get() && cam_scale.get() > 0.0008f) {
      int spacing = 200;
      if (cam_scale.get() > 2) spacing /= 5;
      if (cam_scale.get() < 0.2f) spacing *= 5;
      if (cam_scale.get() < 0.04f) spacing *= 5;
      if (cam_scale.get() < 0.008f) spacing *= 5;
      stroke(100);
      strokeWeight(2.0f / cam_scale.get());
      PVector s = screen_to_cam(new PVector(-spacing * cam_scale.get(), -spacing * cam_scale.get()));
      s.x -= s.x%spacing; 
      s.y -= s.y%spacing;
      PVector m = screen_to_cam( new PVector(width, height) );
      for (float x = s.x; x < m.x; x += spacing) {
        if ( ( (x-(x%spacing)) / spacing) % 5 == 0 ) stroke(100); 
        else stroke(70);
        if (x == 0) stroke(150, 0, 0);
        line(x, s.y, x, m.y);
      }
      for (float y = s.y; y < m.y; y += spacing) {
        if ( ( (y-(y%spacing)) / spacing) % 5 == 0 ) stroke(100); 
        else stroke(70);
        if (y == 0) stroke(150, 0, 0);
        line(s.x, y, m.x, y);
      }
    }
  }

  public void popCam() {
    popMatrix();
    matrixPushed = false;
    if (screenshot) { 
      saveFrame("image/shot-########.png");
    }
    screenshot = false;

    PVector tm = screen_to_cam(input.mouse);
    PVector tpm = screen_to_cam(input.pmouse);
    PVector tmm = screen_to_cam(input.mmouse);
    mouse.x = tm.x; 
    mouse.y = tm.y;
    pmouse.x = tpm.x; 
    pmouse.y = tpm.y;
    mmouse.x = tmm.x; 
    mmouse.y = tmm.y;

    //permet le cliquer glisser le l'ecran
    if (input.getClick("MouseLeft") && GRAB) grabbed = true; 
    if (!input.getState("MouseLeft") && grabbed) grabbed = false; 
    if (input.getState("MouseLeft") && grabbed) { 
      cam_pos.add((mouse.x - pmouse.x)*cam_scale.get(), (mouse.y - pmouse.y)*cam_scale.get());
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
    }

    //permet le zoom
    if (input.mouseWheelUp && GRAB) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); 
      cam_pos.mult(1/ZOOM_FACTOR); 
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
      runEvents(eventsZoom);
    }
    if (input.mouseWheelDown && GRAB) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); 
      cam_pos.mult(ZOOM_FACTOR); 
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
      runEvents(eventsZoom);
    }
  }

  public PVector cam_to_screen(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
    } else {
      pushMatrix();
      translate(width / 2, height / 2);
      scale(cam_scale.get());
      translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);

      popMatrix();
    }
    return r;
  }

  public PVector screen_to_cam(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      pushMatrix();
      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    } else {
      pushMatrix();
      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    }
    return r;
  }
}


//#######################################################################
//##                           FRAMERATE                               ##
//#######################################################################

/*
framerate
 median and current framerate
 frame duration
 frame and time counter total and resetable
 get frame number for delay of(ms)
 */

class sFramerate {
  int frameRate_cible = 60;
  float[] frameR_history;
  int hist_it = 0;
  int frameR_update_rate = 10; // frames between update 
  int frameR_update_counter = frameR_update_rate;

  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;

  float frame_median = 0;

  float reset_time = 0;
  int frame_counter = 0;

  sFlt median_framerate, current_framerate, frame_duration;
  sInt sec_since_reset, frame_since_reset;

  public int frameNbForMsDelay(int d) { 
    return PApplet.parseInt(d * median_framerate.get() / 1000);
  }

  public int get() { 
    return PApplet.parseInt(median_framerate.get());
  }

  sFramerate(sValueBloc d, int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    frameR_history = new float[frameRate_cible];
    for (int i = 0; i < frameR_history.length; i++) frameR_history[i] = 1000/frameRate_cible;

    sec_since_reset = new sInt(d, 0, "sec_since_reset", "sec");
    frame_since_reset = new sInt(d, 0, "frame_since_reset", "frsr");
    median_framerate = new sFlt(d, 0, "median_framerate", "mfr");
    current_framerate = new sFlt(d, 0, "current_framerate", "cfr");
    frame_duration = new sFlt(d, 0, "frame_duration", "fdur");
  }
  public void reset() { 
    sec_since_reset.set(0); 
    reset_time = millis(); 
    frame_counter = 0;
  }

  public void frame() {
    frame_counter++;
    frame_since_reset.set(frame_counter);

    current_time = millis();
    frame_length = current_time - prev_time;
    frame_duration.set(frame_length);
    current_framerate.set(frame_length / 1000);
    prev_time = current_time;

    sec_since_reset.set(PApplet.parseInt((current_time - reset_time) / 1000));

    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { 
      hist_it = 0;
    }

    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0; i < frameR_history.length; i++)  frame_median += frameR_history[i];
      frame_median /= frameR_history.length;
      median_framerate.set(1000/frame_median);

      frameR_update_counter = 0;
    }
    frameR_update_counter++;
  }
}


//#######################################################################
//##                             INPUT                                 ##
//#######################################################################

/*
Inputs
 information disponible as variable / get methods / svalue
 keyboard
 getbool for each key state and triggers
 mouse
 getbool for each key state and triggers
 double click (delay set in real time)
 getWheel  getPointerPos  getPointerLastMove
 getbool for pointer movement state and trigger
 joystick / manette 
 frame()
 */

class sInput_Button {
  boolean state = false, trigClick = false, trigUClick = false;
  //boolean trigJClick = false, trigJUClick = false;
  char key_char;
  String ref;
  sInput_Button(String r, char c) { 
    ref = copy(r); 
    key_char = c;
  }
  sInput_Button(String r) { 
    ref = copy(r);
  }
  public void eventPress() {
    state=true;
    trigClick=true;
  }
  public void eventRelease() {
    state=false;
    trigUClick=true;
  }
  public void frame() {
    trigClick = false; 
    trigUClick = false;
  }
}

public class sInput {

  //keyboard letters
  public boolean getState(char k) { 
    return getKeyboardButton(k).state;
  }
  public boolean getClick(char k) { 
    return getKeyboardButton(k).trigClick;
  }
  public boolean getUnClick(char k) { 
    return getKeyboardButton(k).trigUClick;
  }

  //mouse n specials
  public boolean getState(String k) { 
    return getButton(k).state;
  }
  public boolean getClick(String k) { 
    return getButton(k).trigClick;
  }
  public boolean getUnClick(String k) { 
    return getButton(k).trigUClick;
  }

  public char getLastKey() { 
    return last_key;
  }

  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    mouseLeft = getButton("MouseLeft");
    mouseRight = getButton("MouseRight");
    mouseCenter = getButton("MouseCenter");
    keyBackspace = getButton("Backspace"); 
    keyEnter = getButton("Enter");
    keyLeft = getButton("Left"); 
    keyRight = getButton("Right");
    keyUp = getButton("Up"); 
    keyDown = getButton("Down");
    keyAll = getButton("All"); //any key
  }

  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement
  boolean mouseWheelUp, mouseWheelDown;
  ArrayList<sInput_Button> pressed_keys = new ArrayList<sInput_Button>();
  char last_key = ' ';

  ArrayList<sInput_Button> buttons = new ArrayList<sInput_Button>();
  sInput_Button mouseLeft, mouseRight, mouseCenter, 
    keyBackspace, keyEnter, keyLeft, keyRight, keyUp, keyDown, keyAll;

  public sInput_Button getButton(String r) {
    for (sInput_Button b : buttons) if (b.ref.equals(r)) return b;
    sInput_Button n = new sInput_Button(r); 
    buttons.add(n);
    return n;
  }
  public sInput_Button getKeyboardButton(char k) {
    for (sInput_Button b : buttons) if (b.ref.equals("k") && k == b.key_char) return b;
    sInput_Button n = new sInput_Button("k", k); 
    buttons.add(n);
    return n;
  }

  public void frame_str() {
    mouse.x = mouseX; 
    mouse.y = mouseY; 
    pmouse.x = pmouseX; 
    pmouse.y = pmouseY;
    mmouse.x = mouseX - pmouseX; 
    mmouse.y = mouseY - pmouseY;
  }
  public void frame_end() {
    mouseWheelUp = false; 
    mouseWheelDown = false;
    for (sInput_Button b : buttons) b.frame();
  }

  public void mouseWheelEvent(MouseEvent event) {
    float e = event.getAmount();
    if (e>0) { 
      mouseWheelUp =true; 
      mouseWheelDown =false;
    }
    if (e<0) { 
      mouseWheelDown = true; 
      mouseWheelUp=false;
    }
  }  

  public void keyPressedEvent() { 
    for (sInput_Button b : buttons) 
      if (b.ref.equals("k") && b.key_char == key) { b.eventPress(); pressed_keys.add(b); }
    if (key == CODED) {
      if (keyCode == LEFT) keyLeft.eventPress();
      if (keyCode == RIGHT) keyRight.eventPress();
      if (keyCode == UP) keyUp.eventPress();
      if (keyCode == DOWN) keyDown.eventPress();
    } else {
      if (key == BACKSPACE) keyBackspace.eventPress();
      if (key == ENTER) keyEnter.eventPress();
      keyAll.eventPress();
      last_key = key;
    }
  }

  public void keyReleasedEvent() { 
    for (sInput_Button b : buttons) 
      if (b.ref.equals("k") && b.key_char == key) { b.eventRelease(); pressed_keys.remove(b); }
    if (key == CODED) {
      if (keyCode == LEFT) keyLeft.eventRelease();
      if (keyCode == RIGHT) keyRight.eventRelease();
      if (keyCode == UP) keyUp.eventRelease();
      if (keyCode == DOWN) keyDown.eventRelease();
    } else {
      if (key == BACKSPACE) keyBackspace.eventRelease();
      if (key == ENTER) keyEnter.eventRelease();
      boolean ks = false;
      for (sInput_Button b : buttons) ks = ks && b.state;
      if (!ks) keyAll.eventRelease();
    }
  }

  public void mousePressedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventPress();
    if (mouseButton==RIGHT) mouseRight.eventPress();
    if (mouseButton==CENTER) mouseCenter.eventPress();
  }

  public void mouseReleasedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventRelease();
    if (mouseButton==RIGHT) mouseRight.eventRelease();
    if (mouseButton==CENTER) mouseCenter.eventRelease();
  }
}


//class MTemplate extends Macro_Bloc { 
//  MTemplate(Macro_Sheet _sheet, sValueBloc _bloc) { 
//    super(_sheet, "tmpl", "tmpl", _bloc); 
//  }
//  MTemplate clear() {
//    super.clear(); return this; }
//}

class MCursor extends Macro_Bloc { 
  sStr val_txt; 
  nLinkedWidget txt_field; nLinkedWidget show_widg;
  //Macro_Connexion in_p, in_d, out_p, out_d;
  nCursor cursor;
  MCursor(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "cursor", "cursor", _bloc); 
    cursor = new nCursor(gui, sheet, "cursor", "curs");
    if (sheet.sheet_viewer != null) sheet.sheet_viewer.update();
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "cursor");
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      cursor.clear(); 
      cursor = new nCursor(gui, sheet, val_txt.get(), "curs");
      cursor.show.set(show_widg.isOn());
      show_widg.setLinkedValue(cursor.show);
    } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    //out = addOutput(0, "load");
    show_widg = addEmptyS(0).addLinkedModel("MC_Element_SButton").setLinkedValue(cursor.show);
  }
  public MCursor clear() {
    cursor.clear();
    if (sheet.sheet_viewer != null) sheet.sheet_viewer.update();
    super.clear(); return this; }
}


class MPreset extends Macro_Bloc { 
  sStr val_txt; 
  nLinkedWidget txt_field; nCtrlWidget load_widg;
  Macro_Connexion in;
  MPreset(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "prst", "prst", _bloc); 
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    in = addInput(0, "load").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) { load_prst(); }
    } });
    load_widg = addEmptyS(1).addCtrlModel("MC_Element_SButton")
      .setRunnable(new Runnable() { public void run() { load_prst(); }});
  }
  public void load_prst() {
    for (Map.Entry me : mmain().saved_preset.blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      if (vb.ref.equals(val_txt.get())) {
        transfer_bloc_values(vb, sheet.value_bloc);
        break;
      }
    }
  }
  public MPreset clear() {
    super.clear(); return this; }
}




class MNumCtrl extends Macro_Bloc { 
  public void setValue(sValue v) {
    if (v.type.equals("flt") || v.type.equals("int")) {
      if (val_run != null && cible != null) cible.removeEventChange(val_run);
      if (in1_run != null) in1.removeEventReceive(in1_run);
      if (in2_run != null) in2.removeEventReceive(in2_run);
      val_cible.set(v.ref);
      cible = v; val_field.setLinkedValue(cible);
      if (cible.type.equals("flt")) setValue((sFlt)cible);
      if (cible.type.equals("int")) setValue((sInt)cible);
    }
  }
  public void setValue(sFlt v) {
    fval = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(fval.get())); }};
    in1_run = new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
        if (valFAC.get()) fval.set(fval.get()*mod); 
        if (valINC.get()) fval.set(fval.get()+mod); }
    } };
    in2_run = new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
        if (valINC.get()) fval.set(fval.get()-mod); 
        if (valFAC.get() && mod != 0) fval.set(fval.get()/mod); }
    } };
    v.addEventChange(val_run);
    in1.addEventReceive(in1_run);
    in2.addEventReceive(in2_run);
  }
  public void setValue(sInt v) {
    ival = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(ival.get())); }};
    in1_run = new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
        if (valFAC.get()) ival.set(PApplet.parseInt(ival.get()*mod)); 
        if (valINC.get()) ival.set(PApplet.parseInt(ival.get()+mod)); }
    } };
    in2_run = new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
        if (valINC.get()) ival.set(PApplet.parseInt(ival.get()-mod)); 
        if (valFAC.get() && mod != 0) ival.set(PApplet.parseInt(ival.get()/mod)); }
    } };
    v.addEventChange(val_run);
    in1.addEventReceive(in1_run);
    in2.addEventReceive(in2_run);
  }
  Runnable val_run, in1_run, in2_run;
  sInt ival; sFlt fval;
  Macro_Connexion in1, in2, in_m, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field, val_field;
  nLinkedWidget widgFAC, widgINC; 
  sBoo valFAC, valINC;
  float mod = 0;
  nLinkedWidget mod_view;
  sStr val_mod; 
  MNumCtrl(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "numCtrl", "numCtrl", _bloc); 
    
    val_cible = newStr("cible", "cible", "");
    
    val_mod = newStr("mod", "mod", "2");
    String t = val_mod.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod = 0; }
      else if (PApplet.parseFloat(t) != 0) { mod = PApplet.parseFloat(t); }
    }
    
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addLinkedModel("MC_Element_Field");
    val_cible.addEventChange(new Runnable(this) { public void run() { 
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible); } } );
    
    addEmpty(1); addEmpty(1);
    
    in1 = addInput(0, "+/x").setFilterBang();
    in2 = addInput(0, "-//").setFilterBang();
    in_m = addInput(0, "modifier").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && in_m.getLastPacket().isFloat() && 
          in_m.getLastPacket().asFloat() != mod) {
        mod = in_m.getLastPacket().asFloat(); mod_view.setText(trimStringFloat(mod)); } } });
    
    
    out = addOutput(1, "out");
    
    mod_view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod);
    mod_view.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod = 0; }
        else if (PApplet.parseFloat(t) != 0) { mod = PApplet.parseFloat(t); }
      }
    } });
    
    valFAC = newBoo("valFAC", "valFAC", false);
    valINC = newBoo("valINC", "valINC", false);
    
    Macro_Element e = addEmptyS(1);
    widgFAC = e.addLinkedModel("MC_Element_Button_Selector_1", "x /").setLinkedValue(valFAC);
    widgINC = e.addLinkedModel("MC_Element_Button_Selector_2", "+ -").setLinkedValue(valINC);
    widgFAC.addExclude(widgINC);
    widgINC.addExclude(widgFAC);
    
    if (v != null) setValue(v);
    else {
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible);
    }
  }
  public MNumCtrl clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}







class MToolNCtrl extends MToolRow {  
  nDrawer dr;
  
  public void build_front_panel(nToolPanel front_panel) {
    if (front_panel != null) {
      
      dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1);
      
      if (cible != null) {
        dr.addCtrlModel("Button-S1-P2", "<<").setLinkedValue(cible).setFactor(0.5f).getDrawer()
          .addCtrlModel("Button-S1-P3", "<").setLinkedValue(cible).setFactor(0.8f).getDrawer()
          .addWatcherModel("Label_Back-S2-P2", "--").setLinkedValue(cible).getDrawer()
          .addCtrlModel("Button-S1-P7", ">").setLinkedValue(cible).setFactor(1.25f).getDrawer()
          .addCtrlModel("Button-S1-P8", ">>").setLinkedValue(cible).setFactor(2).getDrawer();
      }
    }
  }
  public void setValue(sValue v) {
    if (v.type.equals("flt") || v.type.equals("int")) {
      if (val_run != null && cible != null) cible.removeEventChange(val_run);
      val_cible.set(v.ref);
      cible = v; val_field.setLinkedValue(cible);
      if (cible.type.equals("flt")) setValue((sFlt)cible);
      if (cible.type.equals("int")) setValue((sInt)cible);
    }
  }
  public void setValue(sFlt v) {
    fval = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(fval.get())); }};
    v.addEventChange(val_run);
    if (mtool != null && mtool.front_panel != null) mtool.rebuild();
  }
  public void setValue(sInt v) {
    ival = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(ival.get())); }};
    v.addEventChange(val_run);
    if (mtool != null && mtool.front_panel != null) mtool.rebuild();
  }
  Runnable val_run, in1_run, in2_run;
  sInt ival; sFlt fval;
  Macro_Connexion in_m, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field, val_field;
  nLinkedWidget widgFAC, widgINC; 
  sBoo valFAC, valINC;
  float mod = 0;
  nLinkedWidget mod_view;
  sStr val_mod; 
  
  MToolNCtrl(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "toolNC", "toolNC", _bloc); 
    
    val_cible = newStr("cible", "cible", "");
    
    val_mod = newStr("mod", "mod", "2");
    String t = val_mod.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod = 0; }
      else if (PApplet.parseFloat(t) != 0) { mod = PApplet.parseFloat(t); }
    }
    
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addLinkedModel("MC_Element_Field");
    val_cible.addEventChange(new Runnable(this) { public void run() { 
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible); } } );
    
    addEmpty(1); addEmpty(1);
    
    in_m = addInput(0, "modifier").setFilterFloat().setLastFloat(mod).addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && in_m.getLastPacket().isFloat() && 
          in_m.getLastPacket().asFloat() != mod) {
        mod = in_m.getLastPacket().asFloat(); mod_view.setText(trimStringFloat(mod)); } } });
    
    
    out = addOutput(1, "out");
    
    mod_view = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod);
    mod_view.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod = 0; }
        else if (PApplet.parseFloat(t) != 0) { mod = PApplet.parseFloat(t); }
      }
    } });
    
    valFAC = newBoo("valFAC", "valFAC", false);
    valINC = newBoo("valINC", "valINC", false);
    
    Macro_Element e = addEmptyS(1);
    widgFAC = e.addLinkedModel("MC_Element_Button_Selector_1", "x /").setLinkedValue(valFAC);
    widgINC = e.addLinkedModel("MC_Element_Button_Selector_2", "+ -").setLinkedValue(valINC);
    widgFAC.addExclude(widgINC);
    widgINC.addExclude(widgFAC);
    
    if (v != null) setValue(v);
    else {
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible);
    }
  }
  public MToolNCtrl clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}

class MToolBin extends MToolRow {  
  nDrawer dr;
  nWidget trig1, trig2, trig3; 
  nWatcherWidget pan_label;
  
  Runnable trig1_run, trig2_run, trig3_run;
  
  public void build_front_panel(nToolPanel front_panel) {
    if (front_panel != null) {
      dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1);
      pan_label = dr.addWatcherModel("Label-S3");
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      
      trig2 = dr.addModel("Button-S2-P2").setSwitch()
        .addEventSwitchOn(trig2_run)
        .addEventSwitchOff(trig2_run);
      if (val_txt2 != null && trig2 != null) trig2.setText(val_txt2.get());
      
      param();
    }
  }
  
  nLinkedWidget widgWTRIG1, widgWTRIG2; 
  sBoo          valTRIG1,   valTRIG2;
  Macro_Connexion in1, in2, in3, out1, out2, out3;
  
  sStr val_lbl1, val_txt1, val_txt2, val_txt3; 
  String msg = "";
  nLinkedWidget txt1_field, txt2_field, txt3_field; 
  
  MToolBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "toolbin", "toolbin", _bloc); 
    
    valTRIG1 = newBoo("valTRIG1", "valTRIG1", false);
    valTRIG2 = newBoo("valTRIG2", "valTRIG2", false);
    
    val_lbl1 = newStr("lbl1", "lbl1", "");
    val_txt1 = newStr("txt1", "txt1", "");
    val_txt2 = newStr("txt2", "txt2", "");
    val_txt3 = newStr("txt3", "txt3", "");
    
    valTRIG1.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valTRIG2.addEventChange(new Runnable(this) { public void run() { param(); } } );
    
    txt1_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_txt1);
    txt1_field.setInfo("label / trig 1");
    txt2_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_txt2);
    txt2_field.setInfo("trig 2");
    txt3_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_txt3);
    txt3_field.setInfo("trig 3");
    val_txt1.addEventChange(new Runnable(this) { public void run() { 
      val_lbl1.set(val_txt1.get() + " " + msg); 
      if (trig1 != null) trig1.setText(val_txt1.get()); } });
    val_txt2.addEventChange(new Runnable(this) { public void run() { 
      if (trig2 != null) trig2.setText(val_txt2.get()); } });
    val_txt3.addEventChange(new Runnable(this) { public void run() { 
      if (trig3 != null) trig3.setText(val_txt3.get()); } });
    
    
    in1 = addInput(0, "in1/val").addEventReceive(new Runnable(this) { public void run() { 
      if (in1.getLastPacket() != null && !in1.getLastPacket().isBool()) { 
        msg = in1.getLastPacket().getText();
        val_lbl1.set(val_txt1.get() + " " + msg); 
        if (trig1 != null) trig1.setText(val_txt1.get()); } 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBool() && trig1 != null) { 
        trig1.setSwitchState(in1.getLastPacket().asBool()); }
    } });
    in2 = addInput(0, "in2").addEventReceive(new Runnable(this) { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBool() && trig2 != null) { 
        trig2.setSwitchState(in2.getLastPacket().asBool()); }
    } });
    in3 = addInput(0, "in3").addEventReceive(new Runnable(this) { public void run() { 
      if (in3.getLastPacket() != null && in3.getLastPacket().isBool() && trig3 != null) { 
        trig3.setSwitchState(in3.getLastPacket().asBool()); }
    } });
    
    Macro_Element e2 = addEmptyS(2);
    widgWTRIG1 = e2.addLinkedModel("MC_Element_Button_Selector_1", "").setLinkedValue(valTRIG1);
    widgWTRIG2 = e2.addLinkedModel("MC_Element_Button_Selector_2", "").setLinkedValue(valTRIG2);
    
    out1 = addOutput(2, "out 1").setDefBang();
    out2 = addOutput(2, "out 2").setDefBang();
    out3 = addOutput(2, "out 3").setDefBang();
    
    trig1_run = new Runnable(this) { public void run() { 
      if (trig1 != null) out1.send(newPacketBool(trig1.isOn())); } };
    
    trig2_run = new Runnable(this) { public void run() { 
      if (trig2 != null) out2.send(newPacketBool(trig2.isOn())); } };
    
    trig3_run = new Runnable(this) { public void run() { 
      if (trig3 != null) out3.send(newPacketBool(trig3.isOn())); } };
    
    param();
    
  }
  public void param() {
    if (pan_label != null) pan_label.setLinkedValue(val_lbl1);
    
     if (valTRIG1.get()) {
      if (trig1 != null) trig1.show();
    } 
    
    if (valTRIG2.get()) {
      if (trig2 != null) trig2.show();
      if (trig1 != null) trig1.clear();
      if (trig3 != null) trig3.clear();
      if (dr != null) trig1 = dr.addModel("Button-S2-P1").setSwitch()
        .addEventSwitchOn(trig1_run)
        .addEventSwitchOff(trig1_run);
      if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
      if (dr != null) trig3 = dr.addModel("Button-S2-P3").setSwitch()
        .addEventSwitchOn(trig3_run)
        .addEventSwitchOff(trig3_run);
      if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
    } else { 
      if (trig2 != null) trig2.hide();
      if (valTRIG1.get()) {
        if (trig1 != null) trig1.clear();
        if (trig3 != null) trig3.clear();
        if (dr != null) trig1 = dr.addModel("Button-S3-P1").setSwitch()
          .addEventSwitchOn(trig1_run)
          .addEventSwitchOff(trig1_run);
        if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
        if (dr != null) trig3 = dr.addModel("Button-S3-P2").setSwitch()
          .addEventSwitchOn(trig3_run)
          .addEventSwitchOff(trig3_run);
        if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
      } else {
      if (trig1 != null) trig1.clear();
        if (trig3 != null) trig3.clear();
        if (dr != null) trig1 = dr.addModel("Button-S2-P1").setSwitch()
          .addEventSwitchOn(trig1_run)
          .addEventSwitchOff(trig1_run);
        if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
        if (dr != null) trig3 = dr.addModel("Button-S2-P3").setSwitch()
          .addEventSwitchOn(trig3_run)
          .addEventSwitchOff(trig3_run);
        if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
      }
    }
    
    if (valTRIG1.get()) {
      if (trig1 != null) trig1.show();
    } else if (trig1 != null) trig1.hide();
    
    if (trig3 != null) trig3.show();
  }
  public MToolBin clear() {
    super.clear(); return this; }
}
class MToolTri extends MToolRow {  
  nDrawer dr;
  nWidget trig1, trig2, trig3; 
  nWatcherWidget pan_label;
  
  Runnable trig1_run, trig2_run, trig3_run;
  
  public void build_front_panel(nToolPanel front_panel) {
    if (front_panel != null) {
      
      dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1);
      pan_label = dr.addWatcherModel("Label-S3");
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      trig1 = dr.addModel("Button-S2-P1").setTrigger()
        .addEventTrigger(trig1_run);
      trig2 = dr.addModel("Button-S2-P2").setTrigger()
        .addEventTrigger(trig2_run);
      trig3 = dr.addModel("Button-S2-P3").setTrigger()
        .addEventTrigger(trig3_run);
      
      if (val_txt1 != null) trig1.setText(val_txt1.get());
      if (val_txt2 != null) trig2.setText(val_txt2.get());
      if (val_txt3 != null) trig3.setText(val_txt3.get());
      
      param();
      
      //front_panel.addEventClose(new Runnable(this) { public void run() { 
      //  pan_label = null; pan_button = null; } } );
    }
  }
  
  nLinkedWidget widgWTRIG1, widgWTRIG2; 
  sBoo          valTRIG1,   valTRIG2;
  Macro_Connexion in, out1, out2, out3;
  
  sStr val_lbl1, val_txt1, val_txt2, val_txt3; 
  String msg = "";
  nLinkedWidget txt1_field, txt2_field, txt3_field; 
  
  MToolTri(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "tooltri", "tooltri", _bloc); 
    
    valTRIG1 = newBoo("valTRIG1", "valTRIG1", false);
    valTRIG2 = newBoo("valTRIG2", "valTRIG2", false);
    
    val_lbl1 = newStr("lbl1", "lbl1", "");
    val_txt1 = newStr("txt1", "txt1", "");
    val_txt2 = newStr("txt2", "txt2", "");
    val_txt3 = newStr("txt3", "txt3", "");
    
    valTRIG1.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valTRIG2.addEventChange(new Runnable(this) { public void run() { param(); } } );
    
    trig1_run = new Runnable(this) { public void run() { out1.send(newPacketBang()); } };
    trig2_run = new Runnable(this) { public void run() { out2.send(newPacketBang()); } };
    trig3_run = new Runnable(this) { public void run() { out3.send(newPacketBang()); } };
    
    addEmptyS(1);
    txt1_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt1);
    txt1_field.setInfo("label / trig 1");
    txt2_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_txt2);
    txt2_field.setInfo("trig 2");
    txt3_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_txt3);
    txt3_field.setInfo("trig 3");
    val_txt1.addEventChange(new Runnable(this) { public void run() { 
      val_lbl1.set(val_txt1.get() + " " + msg); 
      if (trig1 != null) trig1.setText(val_txt1.get()); } });
    val_txt2.addEventChange(new Runnable(this) { public void run() { 
      if (trig2 != null) trig2.setText(val_txt2.get()); } });
    val_txt3.addEventChange(new Runnable(this) { public void run() { 
      if (trig3 != null) trig3.setText(val_txt3.get()); } });
    
    
    in = addInput(0, "val").addEventReceive(new Runnable(this) { public void run() { 
      if (in.getLastPacket() != null) { 
        msg = in.getLastPacket().getText();
        val_lbl1.set(val_txt1.get() + " " + msg); 
        if (trig1 != null) trig1.setText(val_txt1.get()); } 
    } });
    
    Macro_Element e2 = addEmptyS(0);
    widgWTRIG1 = e2.addLinkedModel("MC_Element_Button_Selector_1", "").setLinkedValue(valTRIG1);
    widgWTRIG2 = e2.addLinkedModel("MC_Element_Button_Selector_2", "").setLinkedValue(valTRIG2);
    
    addEmptyS(2);
    out1 = addOutput(2, "out 1").setDefBang();
    out2 = addOutput(2, "out 2").setDefBang();
    out3 = addOutput(2, "out 3").setDefBang();
    
    param();
    
  }
  public void param() {
    if (pan_label != null) pan_label.setLinkedValue(val_lbl1);
    
     if (valTRIG1.get()) {
      if (trig1 != null) trig1.show();
    } 
    
    if (valTRIG2.get()) {
      if (trig2 != null) trig2.show();
      if (trig1 != null) trig1.clear();
      if (trig3 != null) trig3.clear();
      if (dr != null) trig1 = dr.addModel("Button-S2-P1").setTrigger()
        .addEventTrigger(trig1_run);
      if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
      if (dr != null) trig3 = dr.addModel("Button-S2-P3").setTrigger()
        .addEventTrigger(trig3_run);
      if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
    } else { 
      if (trig2 != null) trig2.hide();
      if (valTRIG1.get()) {
        if (trig1 != null) trig1.clear();
        if (trig3 != null) trig3.clear();
        if (dr != null) trig1 = dr.addModel("Button-S3-P1").setTrigger()
          .addEventTrigger(trig1_run);
        if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
        if (dr != null) trig3 = dr.addModel("Button-S3-P2").setTrigger()
          .addEventTrigger(trig3_run);
        if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
      } else {
      if (trig1 != null) trig1.clear();
        if (trig3 != null) trig3.clear();
        if (dr != null) trig1 = dr.addModel("Button-S2-P1").setTrigger()
          .addEventTrigger(trig1_run);
        if (val_txt1 != null && trig1 != null) trig1.setText(val_lbl1.get());
        if (dr != null) trig3 = dr.addModel("Button-S2-P3").setTrigger()
          .addEventTrigger(trig3_run);
        if (val_txt3 != null && trig3 != null) trig3.setText(val_txt3.get());
      }
    }
    
    if (valTRIG1.get()) {
      if (trig1 != null) trig1.show();
    } else if (trig1 != null) trig1.hide();
    
    if (trig3 != null) trig3.show();
  }
  public MToolTri clear() {
    super.clear(); return this; }
}
abstract class MToolRow extends Macro_Bloc {  
  public abstract void build_front_panel(nToolPanel front_panel);
  
  MTool mtool;
  
  sStr val_pan_title; 
  nLinkedWidget title_field; 
  
  MToolRow(Macro_Sheet _sheet, String r, String s, sValueBloc _bloc) { 
    super(_sheet, r, s, _bloc); 
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "");
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      search_panel();
    } });
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("tool cible title");
    
    mmain().inter.addEventNextFrame(new Runnable(this) { public void run() { 
      search_panel();
    } });
  }
  public void search_panel() {
    if (mtool != null) mtool.tool_macros.remove(this);
    if (mtool != null) mtool.rebuild();
    if (val_pan_title.get().length() > 0) {
      for (MTool m : mmain().tool_macros) 
        if (m.val_pan_title.get().equals(val_pan_title.get())) {
          mtool = m;
          mtool.tool_macros.add(this);
          mtool.rebuild();
          break;
        }
    }
  }
  public MToolRow clear() {
    if (mtool != null) mtool.tool_macros.remove(this);
    if (mtool != null && mtool.front_panel != null) mtool.rebuild();
    super.clear(); return this; }
}

class MTool extends Macro_Bloc {  
  nToolPanel front_panel = null;  
  
  nLinkedWidget stp_view, title_field; 
  Runnable reduc_run;
  sBoo setup_send, menu_reduc, menu_top; 
  sInt menu_pos;
  sStr val_pan_title; 
  Macro_Connexion in;
  
  ArrayList<MToolRow> tool_macros = new ArrayList<MToolRow>();
  
  MTool(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "tool", "tool", _bloc); 
    setup_send = newBoo("stp_send", "stp_send", false);
    menu_reduc = newBoo("menu_reduc", "menu_reduc", false);
    menu_top = newBoo("menu_top", "menu_top", true);
    menu_pos = newInt("y_pos", "y_pos", 1);
    
    reduc_run = new Runnable() { public void run() {
      if (front_panel != null) { menu_reduc.set(front_panel.hide); 
      if (!front_panel.hide) rebuild(); } } };
    
    addEmptyS(1);
    Macro_Element e = addEmptyL(0);
    e.addCtrlModel("MC_Element_Button", "tool").setRunnable(new Runnable() { public void run() { 
      open_menu(); 
      setup_send.set(true); } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "tool_"+mmain().tool_nb);
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("tool title");
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      if (front_panel != null) front_panel.clear();
      for (MToolRow m : tool_macros) m.val_pan_title.set(val_pan_title.get());
      rebuild();
    } });
    
    mmain().tool_macros.add(this);
    mmain().tool_nb++;
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() { if (setup_send.get()) open_menu(); } });
    
    addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(menu_pos).getDrawer()
      .addLinkedModel("MC_Element_MiniButton", "t").setLinkedValue(menu_top);
    menu_pos.addEventChange(new Runnable(this) { public void run() { 
      rebuild();
    } });
    menu_top.addEventChange(new Runnable(this) { public void run() { 
      rebuild();
    } });
    addEmptyS(1).addCtrlModel("MC_Element_SButton", "close").setRunnable(new Runnable() { public void run() { 
      if (front_panel != null) front_panel.clear(); 
      front_panel = null;
      setup_send.set(false); } });
    
    in = addInput(0, "open").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      open_menu(); setup_send.set(true);
    } });
    
  }
  public void rebuild() {
    boolean st = setup_send.get();
    boolean op = front_panel != null;
    if (op) { front_panel.clear(); front_panel = null; open_menu(); }
    setup_send.set(st);
  }
  public void open_menu() {
    if (front_panel == null) {
      front_panel = new nToolPanel(mmain().screen_gui, mmain().ref_size, 0.125f, false, true);
      
      front_panel.addShelf().addDrawer(4, 0);
      
      for (MToolRow m : tool_macros) m.build_front_panel(front_panel);
      
      if (menu_top.get()) front_panel.panel.setPY(ref_size*menu_pos.get());
      else front_panel.panel.setPY(front_panel.gui.view.pos.y + front_panel.gui.view.size.y - (front_panel.panel.getLocalSY() + ref_size*menu_pos.get()) );
      
      if (menu_reduc.get()) front_panel.closeit();
      else front_panel.openit();
      
      front_panel.addEventReduc(reduc_run); 
      
    } else front_panel.openit();
  }
  public MTool clear() {
    if (front_panel != null) front_panel.clear();
    mmain().pan_macros.remove(this);
    super.clear(); return this; }
}



class MPanGrph extends MPanTool { 
  
  nWatcherWidget pan_label;
  nWidget graph;
  public void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 10.25f);
      
      graph = dr.addModel("Field");
      graph.setPosition(ref_size * 2 / 16, ref_size * 2 / 16)
        .setSize(ref_size * 10, ref_size * 10);
        
      larg = PApplet.parseInt(graph.getLocalSX());
      graph_data = new float[larg];
      for (int i = 0; i < larg; i++) { 
        graph_data[i] = 0; 
      }
      gc = 0;
      max = 10;
      
      graph.setDrawable(new Drawable(front_panel.gui.drawing_pile, 0) { public void drawing() {
        fill(graph.look.standbyColor);
        noStroke();
        rect(graph.getX(), graph.getY(), graph.getSX(), graph.getSY());
        strokeWeight(ref_size / 40);
        stroke(255);
        for (int i = 1; i < larg; i++) if (i != gc) {
          //stroke(255);
          line( graph.getX() + (i-1), 
                graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[(i-1)] * (graph.getSY()-ref_size*5/4) / max), 
                graph.getX() + i, 
                graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[i] * (graph.getSY()-ref_size*5/4) / max) );
        }
        stroke(255, 0, 0);
        strokeWeight(ref_size / 6);
        if (gc != 0) {
          point(graph.getX() + gc-1, graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[gc-1] * (graph.getSY()-ref_size*5/4) / max) );
        }
      } });
      
      pan_label = dr.addWatcherModel("Label-S3").setLinkedValue(val_label);
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; graph = null; } } );
      front_panel.toLayerTop();
    }
  }
  Macro_Connexion in_val, in_tick;
  
  sStr val_txt, val_label;
  nLinkedWidget txt_field; float flt;
  
  int larg = 0, gc = 0;
  float[] graph_data = null;
  float max = 10;
  
  MPanGrph(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pangrph", "pangrph", _bloc); 
    
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + trimStringFloat(flt)); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    
    in_val = addInput(0, "val").addEventReceive(new Runnable(this) { public void run() { 
      if (in_val.getLastPacket() != null && in_val.getLastPacket().isFloat()) {
        flt = in_val.getLastPacket().asFloat();
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
      }
      if (in_val.getLastPacket() != null && in_val.getLastPacket().isInt()) {
        flt = in_val.getLastPacket().asInt();
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
      }
    } });
    in_tick = addInput(0, "tick").addEventReceive(new Runnable(this) { public void run() { 
      if (in_tick.getLastPacket() != null && in_tick.getLastPacket().isBang() && 
          mpanel != null && mpanel.front_panel != null && graph_data != null) {
        //enregistrement des donner dans les array
        float g = flt;
        if (max < g) max = g;
        if (graph_data[gc] == max) {
          max = 10;
          for (int i = 0; i < graph_data.length; i++) if (i != gc && max < graph_data[i]) max = graph_data[i];
        }
        graph_data[gc] = g;
      
        if (gc < larg-1) gc++; 
        else gc = 0;
      }
    } });
  }
  public MPanGrph clear() {
    super.clear(); return this; }
}


class MPanSld extends MPanTool { 
  
  nWatcherWidget pan_label;
  nSlide slide;
  public void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1);
      pan_label = dr.addWatcherModel("Label-S3").setLinkedValue(val_label);
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      
      slide = (nSlide)(dr.addWidget(new nSlide(front_panel.gui, ref_size * 6, ref_size * 0.75f)));
      slide.setPosition(4*ref_size, ref_size * 2 / 16);
      
      slide.addEventSlide(new Runnable(this) { public void run(float c) { 
        flt = val_min.get() + c * (val_max.get() - val_min.get()); 
        
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
        out.send(newPacketFloat(flt));
      } } );
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; slide = null; } } );
    }
  }
  Macro_Connexion in, out;
  
  sStr val_txt, val_label;
  sFlt val_min, val_max;
  nLinkedWidget txt_field, min_field, max_field; 
  float flt = 0;
  
  MPanSld(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pansld", "pansld", _bloc); 
    
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_min = newFlt("min", "min", 0);
    val_max = newFlt("max", "max", 1);
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + flt); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    min_field = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_min);
    min_field.setInfo("min");
    max_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_max);
    max_field.setInfo("max");
    
    in = addInput(0, "in");
    out = addOutput(1, "out");
    
    in.addEventReceive(new Runnable(this) { public void run() { 
      if (slide != null && !slide.curs.isGrabbed() && 
          in.getLastPacket() != null && in.getLastPacket().isFloat() && 
          in.getLastPacket().asFloat() != flt) {
        flt = in.getLastPacket().asFloat();
        if (flt < val_min.get()) flt = val_min.get();
        if (flt > val_max.get()) flt = val_max.get();
        
        slide.setValue((flt - val_min.get()) / (val_max.get() - val_min.get()));
        
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
        out.send(newPacketFloat(flt));
      }
    } });
  }
  public MPanSld clear() {
    super.clear(); return this; }
}

class MPanBin extends MPanTool {  
  nWidget pan_button; 
  nWatcherWidget pan_label;
  
  Runnable wtch_in_run, trig_widg_run, trig_in_run, swch_widg_run, swch_in_run;
  
  public void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1);
      pan_label = dr.addWatcherModel("Label-S3");
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      pan_button = dr.addModel("Button-S2-P3");
      
      if (val_butt_txt != null) pan_button.setText(val_butt_txt.get());
      
      param();
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; pan_button = null; } } );
    }
  }
  
  nLinkedWidget widgWTCH, widgSWCH, widgTRIG; 
  sBoo valWTCH, valSWCH, valTRIG;
  Macro_Connexion in, out;
  
  sStr val_txt, val_butt_txt, val_label; 
  String msg = "";
  nLinkedWidget txt_field, butt_txt_field; 
  
  MPanBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "panbin", "panbin", _bloc); 
    
    valWTCH = newBoo("valWTCH", "valWTCH", false);
    valSWCH = newBoo("valSWCH", "valSWCH", false);
    valTRIG = newBoo("valTRIG", "valTRIG", false);
    
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_butt_txt = newStr("b_txt", "b_txt", "");
    
    valWTCH.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valSWCH.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valTRIG.addEventChange(new Runnable(this) { public void run() { param(); } } );
    
    trig_widg_run = new Runnable(this) { public void run() { out.send(newPacketBang()); } };
    
    trig_in_run = new Runnable(this) { public void run() { ; } };
    
    swch_widg_run = new Runnable(this) { public void run() { 
      if (pan_button != null) out.send(newPacketBool(pan_button.isOn())); } };
    
    swch_in_run = new Runnable(this) { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool() && pan_button != null) { 
        pan_button.setSwitchState(in.getLastPacket().asBool()); }
    } };
    
    wtch_in_run = new Runnable(this) { public void run() { 
      if (in.getLastPacket() != null) { 
        msg = in.getLastPacket().getText();
        val_label.set(val_txt.get() + " " + msg); } } };
    
    addEmptyS(1);
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + msg); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    
    addEmptyS(1);
    val_butt_txt.addEventChange(new Runnable(this) { public void run() { 
      if (pan_button != null) pan_button.setText(val_butt_txt.get()); } });
    butt_txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_butt_txt);
    butt_txt_field.setInfo("button text");
    
    addEmptyS(1);
    Macro_Element e2 = addEmptyL(0);
    widgWTCH = e2.addLinkedModel("MC_Element_Button_Selector_1", "W").setLinkedValue(valWTCH);
    widgSWCH = e2.addLinkedModel("MC_Element_Button_Selector_2", "S").setLinkedValue(valSWCH);
    widgTRIG = e2.addLinkedModel("MC_Element_Button_Selector_3", "T").setLinkedValue(valTRIG);
    //widgWTCH.addExclude(widgSWCH).addExclude(widgTRIG);
    widgSWCH.addExclude(widgTRIG);
    widgTRIG.addExclude(widgSWCH);
    
    in = addInput(0, "in");
    
    out = addOutput(1, "out");
    
    param();
    
  }
  public void param() {
    if (valWTCH.get()) {
      if (pan_label != null) pan_label.setLinkedValue(val_label);
      val_label.set(val_txt.get());
      in.addEventReceive(wtch_in_run);
    } else {
      if (pan_label != null) pan_label.setLinkedValue(val_txt);
      in.removeEventReceive(wtch_in_run);
    }
    if (valSWCH.get()) {
      if (pan_button != null) pan_button
        .setSwitch()
        .clearEventTrigger()
        .addEventSwitchOn(swch_widg_run)
        .addEventSwitchOff(swch_widg_run)
        .show();
      in.addEventReceive(swch_in_run);
      in.removeEventReceive(trig_in_run);
      
    } else if (valTRIG.get()) {
      if (pan_button != null) pan_button
        .setTrigger()
        .clearEventSwitchOn()
        .clearEventSwitchOff()
        .addEventTrigger(trig_widg_run)
        .show();
      //in.setFilterBang().addEventReceive(trig_in_run);
      in.removeEventReceive(swch_in_run);
    } else {
      if (pan_button != null) pan_button.hide();
    }
  }
  public MPanBin clear() {
    super.clear(); return this; }
}
abstract class MPanTool extends Macro_Bloc {  
  public abstract void build_front_panel(nWindowPanel front_panel);
  
  MPanel mpanel;
  
  sStr val_pan_title; 
  nLinkedWidget title_field; 
  
  MPanTool(Macro_Sheet _sheet, String r, String s, sValueBloc _bloc) { 
    super(_sheet, r, s, _bloc); 
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "");
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      search_panel();
    } });
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("panel cible title");
    
    mmain().inter.addEventNextFrame(new Runnable(this) { public void run() { 
      search_panel();
    } });
  }
  public void search_panel() {
    if (mpanel != null) mpanel.tool_macros.remove(this);
    if (mpanel != null) mpanel.rebuild();
    if (val_pan_title.get().length() > 0) {
      for (MPanel m : mmain().pan_macros) 
        if (m.val_pan_title.get().equals(val_pan_title.get())) {
          mpanel = m;
          mpanel.tool_macros.add(this);
          mpanel.rebuild();
          break;
        }
    }
  }
  public MPanTool clear() {
    if (mpanel != null) mpanel.tool_macros.remove(this);
    if (mpanel != null && mpanel.front_panel != null) mpanel.rebuild();
    super.clear(); return this; }
}

class MPanel extends Macro_Bloc {  
  nWindowPanel front_panel = null;  
  
  nLinkedWidget stp_view, title_field; 
  Runnable grab_run, reduc_run;
  sBoo setup_send, menu_reduc; 
  sVec menu_pos;
  sStr val_pan_title; 
  Macro_Connexion in;
  
  ArrayList<MPanTool> tool_macros = new ArrayList<MPanTool>();
  
  MPanel(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pan", "pan", _bloc); 
    setup_send = newBoo("stp_send", "stp_send", false);
    menu_reduc = newBoo("menu_reduc", "menu_reduc", false);
    menu_pos = newVec("menu_pos", "menu_pos");
    
    grab_run = new Runnable() { public void run() {
      if (front_panel != null) 
        menu_pos.set(front_panel.grabber.getLocalX(), front_panel.grabber.getLocalY()); } };
    reduc_run = new Runnable() { public void run() {
      if (front_panel != null) menu_reduc.set(front_panel.collapsed); } };
    
    addEmptyS(1);
    Macro_Element e = addEmptyL(0);
    e.addCtrlModel("MC_Element_Button", "panel").setRunnable(new Runnable() { public void run() { 
      open_menu(); 
      setup_send.set(true); } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "pan_"+mmain().pan_nb);
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("panel title");
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      if (front_panel != null) front_panel.clear();
      for (MPanTool m : tool_macros) m.val_pan_title.set(val_pan_title.get());
      rebuild();
      //if (front_panel != null) front_panel.grabber.setPosition(menu_pos.get());
    } });
    
    mmain().pan_macros.add(this);
    mmain().pan_nb++;
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() { if (setup_send.get()) open_menu(); } });
    
    in = addInput(0, "open").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      open_menu(); setup_send.set(true);
    } });
  }
  public void rebuild() {
    boolean st = setup_send.get();
    boolean op = front_panel != null;
    if (op) { front_panel.clear(); open_menu(); }
    setup_send.set(st);
  }
  public void open_menu() {
    if (front_panel == null) {
      front_panel = new nWindowPanel(mmain().screen_gui, mmain().inter.taskpanel, val_pan_title.get());
      front_panel.getShelf(0).addDrawer(4, 0);
      
      //if (setup_send.get()) 
        front_panel.grabber.setPosition(menu_pos.get());
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        front_panel = null; setup_send.set(false); } } );
      
      for (MPanTool m : tool_macros) m.build_front_panel(front_panel);
      
      front_panel.grabber.addEventDrag(grab_run); 
      front_panel.addEventCollapse(reduc_run); 
      
      if (menu_reduc.get()) front_panel.collapse();
      else front_panel.popUp();
      
    } else front_panel.popUp();
  }
  public MPanel clear() {
    if (front_panel != null) front_panel.clear();
    mmain().pan_macros.remove(this);
    super.clear(); return this; }
}

class MMenu extends Macro_Bloc {  
  Macro_Connexion in;
  nLinkedWidget stp_view; sBoo setup_send, menu_reduc; sVec menu_pos; sInt menu_tab;
  Runnable grab_run, reduc_run, close_run, tab_run;
  MMenu(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "menu", "menu", _bloc); 
    setup_send = newBoo("stp_snd", "stp_snd", false);
    menu_reduc = newBoo("menu_reduc", "menu_reduc", false);
    menu_tab = newInt("menu_tab", "menu_tab", 0);
    menu_pos = newVec("menu_pos", "menu_pos");
    //addEmptyS(1);
    Macro_Element e = addEmptyS(0);
    e.addCtrlModel("MC_Element_SButton", "menu").setRunnable(new Runnable() { public void run() {
      menu(); } }).setInfo("open sheet general menu");
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    grab_run = new Runnable() { public void run() {
      if (sheet.sheet_front != null) 
        menu_pos.set(sheet.sheet_front.grabber.getLocalX(), sheet.sheet_front.grabber.getLocalY());
    } };
    reduc_run = new Runnable() { public void run() {
      if (sheet.sheet_front != null) 
        menu_reduc.set(sheet.sheet_front.collapsed);
    } };
    tab_run = new Runnable() { public void run() {
      if (sheet.sheet_front != null) 
        menu_tab.set(sheet.sheet_front.current_tab_id);
    } };
    close_run = new Runnable() { public void run() { setup_send.set(false); } };
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      menu();
    } });
    in = addInput(0, "open").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      menu(); setup_send.set(true);
    } });
  }
  public void menu() {
    sheet.build_sheet_menu();
    if (sheet.sheet_front != null) { 
      if (setup_send.get()) sheet.sheet_front.grabber.setPosition(menu_pos.get());
      if (setup_send.get() && menu_reduc.get()) sheet.sheet_front.collapse();
      if (setup_send.get() && !menu_reduc.get()) sheet.sheet_front.popUp();
      if (setup_send.get()) sheet.sheet_front.setTab(menu_tab.get());
      setup_send.set(true);
      sheet.sheet_front.grabber.addEventDrag(grab_run); 
      sheet.sheet_front.addEventCollapse(reduc_run);  
      sheet.sheet_front.addEventClose(close_run);  
      sheet.sheet_front.addEventTab(tab_run); 
    }
  }
  public MMenu clear() {
    if (sheet.sheet_front != null) sheet.sheet_front.grabber.removeEventDrag(grab_run);
    if (sheet.sheet_front != null) sheet.sheet_front.removeEventCollapse(reduc_run); 
    if (sheet.sheet_front != null) sheet.sheet_front.removeEventClose(close_run); 
    if (sheet.sheet_front != null) sheet.sheet_front.clear();
    super.clear(); return this; }
}




class MVecCtrl extends Macro_Bloc { 
  public void setValue(sValue v) {
    if (v.type.equals("vec")) {
      if (val_run != null && cible != null) cible.removeEventChange(val_run);
      if (in1_run != null) in1.removeEventReceive(in1_run);
      if (in2_run != null) in2.removeEventReceive(in2_run);
      val_cible.set(v.ref);
      cible = v; val_field.setLinkedValue(cible);
      vval = (sVec)cible;
      out.send(newPacketVec(vval.get()));
      val_run = new Runnable() { public void run() { out.send(newPacketVec(vval.get())); }};
      in1_run = new Runnable() { public void run() { 
        if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
          if (valMAG.get()) {
            PVector p = new PVector().set(vval.get());
            p.setMag(p.mag() + mod_f);
            vval.set(p);
          } else if (valROT.get()) {
            PVector p = new PVector(vval.get().mag(), 0);
            p.rotate(vval.get().heading() + mod_f);
            vval.set(p);
          } else if (valADD.get()) {
            PVector p = new PVector().set(vval.get());
            p.x += mod_vec.x; p.y += mod_vec.y;
            vval.set(p);
          } 
        }
      } };
      in2_run = new Runnable() { public void run() { 
        if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
          if (valMAG.get()) {
            PVector p = new PVector().set(vval.get());
            p.setMag(p.mag() - mod_f);
            vval.set(p);
          } else if (valROT.get()) {
            PVector p = new PVector(vval.get().mag(), 0);
            p.rotate(vval.get().heading() - mod_f);
            vval.set(p);
          } else if (valADD.get()) {
            PVector p = new PVector().set(vval.get());
            p.x -= mod_vec.x; p.y -= mod_vec.y;
            vval.set(p);
          } 
        }
      } };
      v.addEventChange(val_run);
      in1.addEventReceive(in1_run);
      in2.addEventReceive(in2_run);
    }
  }
  Runnable val_run, in1_run, in2_run;
  sVec vval;
  Macro_Connexion in1, in2, in_m, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field;
  nWatcherWidget val_field;
  nLinkedWidget widgMAG, widgROT, widgADD; 
  sBoo valMAG, valROT, valADD;
  float mod_f = 0; PVector mod_vec;
  nLinkedWidget mod_view1, mod_view2;
  sStr val_mod1, val_mod2; 
  MVecCtrl(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "vecCtrl", "vecCtrl", _bloc); 
    
    val_cible = newStr("cible", "cible", "");
    mod_vec = new PVector();
    val_mod1 = newStr("mod1", "mod1", "0");
    String t = val_mod1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod_f = 0; mod_vec.x = 0; }
      else if (PApplet.parseFloat(t) != 0) { mod_f = PApplet.parseFloat(t); mod_vec.x = mod_f; }
    }
    val_mod2 = newStr("mod2", "mod2", "0");
    t = val_mod2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod_vec.y = 0; }
      else if (PApplet.parseFloat(t) != 0) { mod_vec.y = PApplet.parseFloat(t); }
    }
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_cible.addEventChange(new Runnable(this) { public void run() { 
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible); } } );
    
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Field");
    addEmpty(1); addEmpty(1);
    
    in1 = addInput(0, "+").setFilterBang();
    in2 = addInput(0, "-").setFilterBang();
    in_m = addInput(0, "modifier").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && in_m.getLastPacket().isFloat() && 
          in_m.getLastPacket().asFloat() != mod_f) {
        mod_f = in_m.getLastPacket().asFloat(); 
        mod_view1.setText(trimStringFloat(mod_f)); 
        mod_view2.setText("-"); 
      } else if (in_m.getLastPacket() != null && in_m.getLastPacket().isVec() && 
          !in_m.getLastPacket().equalsVec(mod_vec)) {
        mod_vec.set(in_m.getLastPacket().asVec()); 
        mod_view1.setText(trimStringFloat(mod_vec.x)); 
        mod_view2.setText(trimStringFloat(mod_vec.y)); 
      }
    } });
    
    
    out = addOutput(1, "out");
    
    mod_view1 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod1);
    mod_view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view1.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod_f = 0; mod_vec.x = 0; }
        else if (PApplet.parseFloat(t) != 0) { mod_f = PApplet.parseFloat(t); mod_vec.x = mod_f; }
      }
    } });
    mod_view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod2);
    mod_view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view2.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod_vec.y = 0; }
        else if (PApplet.parseFloat(t) != 0) { mod_vec.y = PApplet.parseFloat(t); }
      }
    } });
    
    valMAG = newBoo("valMAG", "valMAG", false);
    valROT = newBoo("valROT", "valROT", false);
    valADD = newBoo("valADD", "valADD", false);
    
    Macro_Element e = addEmptyL(0);
    widgMAG = e.addLinkedModel("MC_Element_Button_Selector_1", "Mag").setLinkedValue(valMAG);
    widgROT = e.addLinkedModel("MC_Element_Button_Selector_2", "Rot").setLinkedValue(valROT);
    widgADD = e.addLinkedModel("MC_Element_Button_Selector_4", "Add").setLinkedValue(valADD);
    widgMAG.addExclude(widgROT).addExclude(widgADD);
    widgROT.addExclude(widgMAG).addExclude(widgADD);
    widgADD.addExclude(widgROT).addExclude(widgMAG);
    
    if (v != null) setValue(v);
    else {
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible);
    }
  }
  public MVecCtrl clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}

class MComp extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgSUP, widgINF, widgEQ; 
  sBoo valSUP, valINF, valEQ;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MComp(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "comp", "comp", _bloc); 
    
    valSUP = newBoo("valSUP", "valSUP", false);
    valINF = newBoo("valINF", "valINF", false);
    valEQ = newBoo("valEQ", "valEQ", false);
    
    valSUP.addEventChange(new Runnable() { public void run() { if (valSUP.get()) receive(); } });
    valINF.addEventChange(new Runnable() { public void run() { if (valINF.get()) receive(); } });
    valEQ.addEventChange(new Runnable() { public void run() { if (valEQ.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterNumber().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
          in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); 
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isInt() && 
                 in1.getLastPacket().asInt() != pin1) {
        pin1 = in1.getLastPacket().asInt(); receive(); 
      } 
    } });
    in2 = addInput(0, "in").setFilterNumber().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
          in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); 
      } else if (in2.getLastPacket() != null && in2.getLastPacket().isInt() && 
                 in2.getLastPacket().asInt() != pin2) {
        pin2 = in2.getLastPacket().asInt(); receive(); 
      } 
    } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = newStr("val", "val", "");
    
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (PApplet.parseFloat(t) != 0) { pin2 = PApplet.parseFloat(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    
    Macro_Element e = addEmptyL(0);
    widgSUP = e.addLinkedModel("MC_Element_Button_Selector_1", ">").setLinkedValue(valSUP);
    widgINF = e.addLinkedModel("MC_Element_Button_Selector_2", "<").setLinkedValue(valINF);
    widgEQ = e.addLinkedModel("MC_Element_Button_Selector_4", "=").setLinkedValue(valEQ);
    widgSUP.addExclude(widgINF);
    widgINF.addExclude(widgSUP);
    
  }
  public void receive() { 
    if      (valSUP.get() && (pin1 > pin2)) out.send(newPacketBool(true));
    else if (valINF.get() && (pin1 < pin2)) out.send(newPacketBool(true));
    else if (valEQ.get() && (pin1 == pin2)) out.send(newPacketBool(true));
    else                                    out.send(newPacketBool(false));
  }
  public MComp clear() {
    super.clear(); return this; }
}
class MData extends Macro_Bloc {
  public void setValue(sValue v) {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    if (in_run != null) in.removeEventReceive(in_run);
    val_cible.set(v.ref);
    cible = v; val_field.setLinkedValue(cible);
    if (cible.type.equals("flt")) setValue((sFlt)cible);
    if (cible.type.equals("int")) setValue((sInt)cible);
    if (cible.type.equals("boo")) setValue((sBoo)cible);
    if (cible.type.equals("str")) setValue((sStr)cible);
    if (cible.type.equals("run")) setValue((sRun)cible);
    if (cible.type.equals("vec")) setValue((sVec)cible);
  }
  public void setValue(sFlt v) {
    fval = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(fval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isFloat()) { 
        fval.set(in.getLastPacket().asFloat()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  public void setValue(sInt v) {
    ival = v;
    out.send(newPacketInt(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketInt(ival.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isInt()) { 
        ival.set(in.getLastPacket().asInt()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  public void setValue(sBoo v) {
    bval = v;
    out.send(newPacketBool(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketBool(bval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) { 
        bval.set(in.getLastPacket().asBool()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  public void setValue(sStr v) {
    sval = v;
    out.send(newPacketStr(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketStr(sval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isStr()) { 
        sval.set(in.getLastPacket().asStr()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  public void setValue(sRun v) {
    rval = v;
    val_run = new Runnable() { public void run() { out.send(newPacketBang()); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) { 
        rval.doEvent(false); 
        rval.run(); 
        rval.doEvent(true); 
      }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  public void setValue(sVec v) {
    vval = v;
    out.send(newPacketVec(v.get()));
    
    val_run = new Runnable() { public void run() { out.send(newPacketVec(vval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isVec()) { 
        vval.set(in.getLastPacket().asVec()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  Runnable val_run, in_run;
  sBoo bval; sInt ival; sFlt fval; sStr sval; sVec vval; sRun rval;
  Macro_Connexion in, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field; 
  nWatcherWidget val_field;
  MData(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "data", "data", _bloc); 
    val_cible = newStr("cible", "cible", "");
    init();
    if (v != null) setValue(v);
  }
  public void init() {
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Text");
    val_cible.addEventChange(new Runnable(this) { public void run() { get_cible(); } } );
    addEmpty(1); addEmpty(1);
    in = addInput(0, "in");
    out = addOutput(1, "out");
    get_cible();
  }
  public void get_cible() {
    cible = sheet.value_bloc.getValue(val_cible.get());
    if (cible != null) setValue(cible);
  }
  public MData clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}

class MVecXY extends Macro_Bloc {
  Macro_Connexion in1,in2,out1,out2;
  float x = 0, y = 0;
  PVector vec;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MVecXY(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "vecXY", "vecXY", _bloc); 
    
    in1 = addInput(0, "v/x").addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isVec() && 
          (in1.getLastPacket().asVec().x != vec.x || in1.getLastPacket().asVec().y != vec.y)) {
        vec.set(in1.getLastPacket().asVec());
        float m = vec.x; float d = vec.y;
        if (m != x) { x = m; out1.send(newPacketFloat(m)); }
        if (d != y) { y = d; out2.send(newPacketFloat(d)); }
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
                 in1.getLastPacket().asFloat() != x) {
        x = in1.getLastPacket().asFloat();
        view1.changeText(trimStringFloat(x)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    in2 = addInput(0, "y").addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
                 in2.getLastPacket().asFloat() != y) {
        y = in2.getLastPacket().asFloat();
        view2.changeText(trimStringFloat(y)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    out1 = addOutput(1, "v/x");
    out2 = addOutput(1, "y");
    
    vec = new PVector(1, 0);
    
    val_view1 = newStr("x", "x", "0");
    val_view2 = newStr("y", "y", "0");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { x = 0; }
      else if (PApplet.parseFloat(t) != 0) { x = PApplet.parseFloat(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { y = 0; }
      else if (PApplet.parseFloat(t) != 0) { y = PApplet.parseFloat(t); }
    }
    vec.set(x, y);
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("x");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      float a = x;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { x = 0; }
        else if (PApplet.parseFloat(t) != 0) { x = PApplet.parseFloat(t); }
      }
      if (x != a) {
        //view1.changeText(trimStringFloat(x)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("y");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      float a = y;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { y = 0; }
        else if (PApplet.parseFloat(t) != 0) { y = PApplet.parseFloat(t); }
      }
      if (y != a) {
        //view2.changeText(trimStringFloat(y)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out1.send(newPacketVec(vec));
    } });
  }
  public MVecXY clear() {
    super.clear(); return this; }
}
class MVecMD extends Macro_Bloc {
  Macro_Connexion in1,in2,out1,out2;
  float mag = 1, dir = 0;
  PVector vec;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MVecMD(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "vecMD", "vecMD", _bloc); 
    
    in1 = addInput(0, "v/mag").addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isVec() && 
          (in1.getLastPacket().asVec().x != vec.x || in1.getLastPacket().asVec().y != vec.y)) {
        vec.set(in1.getLastPacket().asVec());
        float m = vec.mag(); float d = vec.heading();
        if (m != mag) { mag = m; out1.send(newPacketFloat(m)); }
        if (d != dir) { dir = d; out2.send(newPacketFloat(d)); }
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
                 in1.getLastPacket().asFloat() != mag) {
        mag = in1.getLastPacket().asFloat();
        view1.changeText(trimStringFloat(mag)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    in2 = addInput(0, "dir").addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
                 in2.getLastPacket().asFloat() != dir) {
        dir = in2.getLastPacket().asFloat();
        view2.changeText(trimStringFloat(dir)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    out1 = addOutput(1, "v/mag");
    out2 = addOutput(1, "dir");
    
    vec = new PVector(1, 0);
    
    val_view1 = newStr("mag", "mag", "1");
    val_view2 = newStr("dir", "dir", "0");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mag = 0; }
      else if (PApplet.parseFloat(t) != 0) { mag = PApplet.parseFloat(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { dir = 0; }
      else if (PApplet.parseFloat(t) != 0) { dir = PApplet.parseFloat(t); }
    }
    vec.set(mag, 0).rotate(dir);
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("mag");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      float a = mag;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mag = 0; }
        else if (PApplet.parseFloat(t) != 0) { mag = PApplet.parseFloat(t); }
      }
      if (mag != a) {
        //view1.changeText(trimStringFloat(mag)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("dir");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      float a = dir;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { dir = 0; }
        else if (PApplet.parseFloat(t) != 0) { dir = PApplet.parseFloat(t); }
      }
      if (dir != a) {
        //view2.changeText(trimStringFloat(dir)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out1.send(newPacketVec(vec));
    } });
  }
  public MVecMD clear() {
    super.clear(); return this; }
}

class MRandom extends Macro_Bloc { 
  Macro_Connexion in, out;
  float min = 0, max = 1;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MRandom(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "rng", "rng", _bloc); 
    
    in = addInput(0, "bang").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        out.send(newPacketFloat(random(min, max))); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view1 = newStr("min", "min", "0");
    val_view2 = newStr("max", "max", "1");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { min = 0; }
      else if (PApplet.parseFloat(t) != 0) { min = PApplet.parseFloat(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { max = 0; }
      else if (PApplet.parseFloat(t) != 0) { max = PApplet.parseFloat(t); }
    }
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("min");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { min = 0; }
        else if (PApplet.parseFloat(t) != 0) { min = PApplet.parseFloat(t); }
      }
      if (min > max) { float a = min; min = max; max = a; }
      //view1.setText(trimStringFloat(min)); 
      //view2.setText(trimStringFloat(max)); 
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("max");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { max = 0; }
        else if (PApplet.parseFloat(t) != 0) { max = PApplet.parseFloat(t); }
      }
      if (min > max) { float a = min; min = max; max = a; }
      //view1.setText(trimStringFloat(min)); 
      //view2.setText(trimStringFloat(max)); 
    } });
  }
  public MRandom clear() {
    super.clear(); return this; }
}

class MMouse extends Macro_Bloc { 
  Macro_Connexion out1, out2, out3;
  Runnable run;
  PVector m, pm, mm, v;
  MMouse(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "mouse", "mouse", _bloc); 
    out1 = addOutput(0, "pos"); out2 = addOutput(0, "ppos"); out3 = addOutput(0, "mouv");
    m = new PVector(0, 0); pm = new PVector(0, 0); mm = new PVector(0, 0); v = new PVector(0, 0);
    run = new Runnable() { public void run() { 
      if (m.x != gui.mouseVector.x || m.y != gui.mouseVector.y) { 
        out1.send(newPacketVec(gui.mouseVector));
        m.set(gui.mouseVector); }
      if (pm.x != gui.pmouseVector.x || pm.y != gui.pmouseVector.y) { 
        out2.send(newPacketVec(gui.pmouseVector));
        pm.set(gui.pmouseVector); }
      v.set(gui.mouseVector);
      v = v.sub(gui.pmouseVector);
      if (mm.x != v.x || mm.y != v.y) { 
        out3.send(newPacketVec(v));
        mm.set(v); }
    } };
    mmain().inter.addEventFrame(run);
  }
  public MMouse clear() {
    mmain().inter.removeEventFrame(run);
    super.clear(); return this; }
}
class MComment extends Macro_Bloc { 
  sStr val_com, val_screen; 
  nLinkedWidget com_field, screen_field; 
  nWatcherWidget screen_txt;
  MComment(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "com", "com", _bloc); 
    val_com = newStr("val_com", "val_com", "");
    val_screen = newStr("screen_field", "screen_field", "");
    com_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_com);
    screen_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_screen);
    screen_txt = mmain().screen_gui.theme.newWatcherWidget(mmain().screen_gui, "Label-S1")
      .setLinkedValue(val_screen);
    screen_txt.setFont(PApplet.parseInt(ref_size/1.4f))
      .setTextAlignment(CENTER, CENTER).setPX(mmain()
      .screen_gui.view.size.x/2);
    addEmpty(1); 
  }
  public MComment clear() {
    screen_txt.clear();
    super.clear(); return this; }
}
/*
channel call / listen : 
  packet whormhole
  each channel is linked to his creating sheet
  can be accessed with sheet name + channel name from anywhere
*/

class MChan extends Macro_Bloc { 
  Macro_Connexion in, out;
  sStr val_cible; 
  nLinkedWidget ref_field; 
  MChan(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "chan", "chan", _bloc); 
    val_cible = newStr("cible", "cible", "");
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    addEmpty(1); 
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) receive(in.getLastPacket());
    } });
    out = addOutput(1, "out");
    
    mmain().chan_macros.add(this);
  }
  public void receive(Macro_Packet p) {
    out.send(p);
    for (MChan m : mmain().chan_macros) 
      if (m != this && m.val_cible.get().equals(val_cible.get())) m.out.send(p);
  }
  public MChan clear() {
    super.clear(); 
    mmain().chan_macros.remove(this); return this; }
}

class MFrame extends Macro_Bloc { 
  Macro_Connexion in, out;
  Macro_Packet packet1, packet2;
  boolean pack_balance = false;
  MFrame(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "frame", "frame", _bloc); 
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) { 
        if (pack_balance) { 
          pack_balance = false;
          packet1 = in.getLastPacket();
          mmain().inter.addEventNextFrame(new Runnable() { public void run() { out.send(packet1); }});
        } else {
          pack_balance = true;
          packet2 = in.getLastPacket();
          mmain().inter.addEventNextFrame(new Runnable() { public void run() { out.send(packet2); }});
        }
      } 
    } });
        
    out = addOutput(1, "out");
  }
  public MFrame clear() {
    super.clear(); return this; }
}



class MPulse extends Macro_Bloc { //let throug only 1 bang every <delay> bang
  Macro_Connexion in, out;
  sInt delay;
  nLinkedWidget del_field;
  int count = 0;
  MPulse(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pulse", "pulse", _bloc); 
    
    delay = newInt("delay", "delay", 100);
    
    addEmptyS(1);
    del_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(delay);
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        count++;
        if (count > delay.get()) { count = 0; out.send(newPacketBang()); }
      } else if (in.getLastPacket() != null && in.getLastPacket().isFloat()) {
        count = 0;
        delay.set(PApplet.parseInt(in.getLastPacket().asFloat()));
      } else if (in.getLastPacket() != null && in.getLastPacket().isInt()) {
        count = 0;
        delay.set(in.getLastPacket().asInt());
      } 
    } });
        
    out = addOutput(1, "out")
      .setDefBool();
  }
  public MPulse clear() {
    super.clear(); return this; }
}






class MCalc extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgADD, widgSUB, widgMUL, widgDEV; 
  sBoo valADD, valSUB, valMUL, valDEV;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MCalc(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "calc", "calc", _bloc); 
    
    valADD = newBoo("valADD", "valADD", false);
    valSUB = newBoo("valSUB", "valSUB", false);
    valMUL = newBoo("valMUL", "valMUL", false);
    valDEV = newBoo("valDEV", "valDEV", false);
    
    valADD.addEventChange(new Runnable() { public void run() { if (valADD.get()) receive(); } });
    valSUB.addEventChange(new Runnable() { public void run() { if (valSUB.get()) receive(); } });
    valMUL.addEventChange(new Runnable() { public void run() { if (valMUL.get()) receive(); } });
    valDEV.addEventChange(new Runnable() { public void run() { if (valDEV.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); } } });
    in2 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = newStr("val", "val", "");
    
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (PApplet.parseFloat(t) != 0) { pin2 = PApplet.parseFloat(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    String t = view.getText();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); }
      else if (PApplet.parseFloat(t) != 0) { pin2 = PApplet.parseFloat(t); in2.setLastFloat(pin2); }  }
    Macro_Element e = addEmptyL(0);
    widgADD = e.addLinkedModel("MC_Element_Button_Selector_1", "+").setLinkedValue(valADD);
    widgSUB = e.addLinkedModel("MC_Element_Button_Selector_2", "-").setLinkedValue(valSUB);
    widgMUL = e.addLinkedModel("MC_Element_Button_Selector_3", "X").setLinkedValue(valMUL);
    widgDEV = e.addLinkedModel("MC_Element_Button_Selector_4", "/").setLinkedValue(valDEV);
    widgADD.addExclude(widgDEV).addExclude(widgSUB).addExclude(widgMUL);
    widgSUB.addExclude(widgADD).addExclude(widgDEV).addExclude(widgMUL);
    widgMUL.addExclude(widgADD).addExclude(widgSUB).addExclude(widgDEV);
    widgDEV.addExclude(widgADD).addExclude(widgSUB).addExclude(widgMUL);
    
  }
  public void receive() { 
    if      (valADD.get()) out.send(newPacketFloat(pin1 + pin2));
    else if (valSUB.get()) out.send(newPacketFloat(pin1 - pin2));
    else if (valMUL.get()) out.send(newPacketFloat(pin1 * pin2));
    else if (valDEV.get() && pin2 != 0) out.send(newPacketFloat(pin1 / pin2));
  }
  public MCalc clear() {
    super.clear(); return this; }
}

class MBool extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgAND, widgOR; 
  sBoo valAND, valOR;
  boolean pin1 = false, pin2 = false;
  MBool(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bool", "bool", _bloc); 
    
    valAND = newBoo("valAND", "valAND", false);
    valOR = newBoo("valOR", "valOR", false);
    
    in1 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBool() && in1.getLastPacket().asBool() != pin1) {
        pin1 = in1.getLastPacket().asBool(); receive(); } } });
    in2 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBool() && in2.getLastPacket().asBool() != pin2) {
        pin2 = in2.getLastPacket().asBool(); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefBool();
    
    Macro_Element e = addEmptyS(1);
    widgAND = e.addLinkedModel("MC_Element_Button_Selector_1", "&&").setLinkedValue(valAND);
    widgOR = e.addLinkedModel("MC_Element_Button_Selector_2", "||").setLinkedValue(valOR);
    widgAND.addExclude(widgOR);
    widgOR.addExclude(widgAND);
    
  }
  public void receive() { 
    if (valAND.get() && (pin1 && pin2)) 
        out.send(newPacketBool(true));
    else if (valOR.get() && (pin1 || pin2)) 
      out.send(newPacketBool(true));
    else if (valAND.get() || valOR.get()) 
      out.send(newPacketBool(false));
  }
  public MBool clear() {
    super.clear(); return this; }
}


class MBin extends Macro_Bloc {
  Macro_Connexion in, out;
  MBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bin", "bin", _bloc); 
    
    in = addInput(0, "in").setFilterBin().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool() && 
          in.getLastPacket().asBool()) out.send(newPacketBang()); 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) out.send(newPacketBool(true)); } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  public MBin clear() {
    super.clear(); return this; }
}

class MNot extends Macro_Bloc {
  Macro_Connexion in, out;
  MNot(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "not", "not", _bloc); 
    
    in = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) {
        if (in.getLastPacket().asBool()) out.send(newPacketBool(false)); 
        else out.send(newPacketBool(true)); } } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  public MNot clear() {
    super.clear(); return this; }
}

class MGate extends Macro_Bloc {
  Macro_Connexion in_m, in_b, out;
  nLinkedWidget swtch; 
  sBoo state;
  MGate(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "gate", "gate", _bloc); 
    
    state = newBoo("state", "state", false);
    
    in_m = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && state.get()) out.send(in_m.getLastPacket());
    } });
    in_b = addInput(0, "gate").addEventReceive(new Runnable() { public void run() { 
      if (in_b.getLastPacket() != null && in_b.getLastPacket().isBool()) 
        state.set(in_b.getLastPacket().asBool()); 
    } });
    out = addOutput(1, "out");
    
    swtch = addEmptyS(1).addLinkedModel("MC_Element_SButton").setLinkedValue(state);
    
  }
  public MGate clear() {
    super.clear(); return this; }
}

class MVar extends Macro_Bloc {
  Macro_Connexion in, out;
  Macro_Packet packet;
  nLinkedWidget view, stp_view;
  sStr val_view; sBoo setup_send;
  MVar(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "var", "var", _bloc); 
    packet = newPacketFloat(0); 
    
    val_view = newStr("val", "val", "0");
    String t = val_view.get();
    if (t.length() > 0) {
      if (t.equals("true")) packet = newPacketBool(true);
      else if (t.equals("false")) packet = newPacketBool(false);
      else if (t.equals("0")) packet = newPacketFloat(0);
      else if (t.equals("0.0")) packet = newPacketFloat(0);
      else if (PApplet.parseFloat(t) != 0) packet = newPacketFloat(PApplet.parseFloat(t));
    }
    
    setup_send = newBoo("stp_snd", "stp_snd", true);
    
    Macro_Element e = addEmptyS(1);
    e.addCtrlModel("MC_Element_SButton")
      .setRunnable(new Runnable() { public void run() { if (packet != null) out.send(packet); } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    view = addEmptyS(0).addLinkedModel("MC_Element_SField");
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("true")) packet = newPacketBool(true);
        else if (t.equals("false")) packet = newPacketBool(false);
        else if (t.equals("0")) packet = newPacketFloat(0);
        else if (t.equals("0.0")) packet = newPacketFloat(0);
        else if (PApplet.parseFloat(t) != 0) packet = newPacketFloat(PApplet.parseFloat(t));
      }
    } });
    view.setLinkedValue(val_view);
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) {
        if (in.getLastPacket().isBang() && packet != null) out.send(packet);
        else { packet = in.getLastPacket(); view.setText(packet.getText()); } }
    } });
    out = addOutput(1, "out");
    
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      if (packet != null) out.send(packet);
    } });
  }
  public MVar clear() {
    super.clear(); return this; }
}
class MTrig extends Macro_Bloc {
  Macro_Connexion out_t;
  nCtrlWidget trig; 
  nLinkedWidget stp_view; sBoo setup_send;
  MTrig(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "trig", "trig", _bloc); 
    setup_send = newBoo("stp_snd", "stp_snd", false);
    
    Macro_Element e = addEmptyS(0);
    trig = e.addCtrlModel("MC_Element_SButton").setRunnable(new Runnable() { public void run() {
      out_t.send(newPacketBang());
    } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    out_t = addOutput(1, "trig")
      .setDefBang();
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out_t.send(newPacketBang());
    } });
  }
  public MTrig clear() {
    super.clear(); return this; }
}
class MSwitch extends Macro_Bloc {
  Macro_Connexion in, out_t;
  nLinkedWidget swtch; 
  sBoo state;
  MSwitch(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "switch", "switch", _bloc); 
    
    state = newBoo("state", "state", false);
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        swtch.setSwitchState(!swtch.isOn());
      } 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) {
        swtch.setSwitchState(in.getLastPacket().asBool());
      } 
    } });
    
    swtch = addEmptyS(1).addLinkedModel("MC_Element_SButton").setLinkedValue(state);
    
    state.addEventChange(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
    out_t = addOutput(2, "out")
      .setDefBool();
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
  }
  public MSwitch clear() {
    super.clear(); return this; }
}

class MKeyboard extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget key_field; 
  sStr val_cible; 
  sBoo v1, v2;
  MKeyboard(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "keyb", "keyb", _bloc); 
    val_cible = newStr("cible", "cible", "");
    init();
  }
  public void init() {
    key_field = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_cible);
    
    v1 = newBoo("v1", true);
    v2 = newBoo("v2", false);
    
    addSelectS(0, v1, v2, "P", "T");
    
    out_t = addOutput(1, "trig")
      .setDefBang();
    key_field.addEventFrame(new Runnable() { public void run() {
      if ( v1.get() && key_field.getText().length() > 0 && 
           mmain().inter.input.getState(key_field.getText().charAt(0)) ) 
        out_t.send(newPacketBang());
      if ( v2.get() && mmain().inter.input.keyAll.trigClick && key_field.getText().length() > 0 && 
          key_field.getText().charAt(0) == mmain().inter.input.getLastKey()) 
        out_t.send(newPacketBang());
    } } );
  }
  public MKeyboard clear() {
    super.clear(); return this; }
  
}




class MSheetIn extends Macro_Bloc {
  Macro_Element elem;
  MSheetIn(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "in", "in", _bloc); 
    init();
  }
  public void init() {
    elem = addSheetInput(0, "in");
    val_title.addEventChange(new Runnable() { public void run() { 
    if (elem.sheet_connect != null) elem.sheet_connect.setInfo(val_title.get()); } });
  }
  public MSheetIn clear() {
    super.clear(); return this; }
}

class MSheetOut extends Macro_Bloc {
  Macro_Element elem;
  MSheetOut(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "out", "out", _bloc); 
    init();
  }
  public void init() {
    elem = addSheetOutput(0, "out");
    val_title.addEventChange(new Runnable() { public void run() { 
    if (elem.sheet_connect != null) elem.sheet_connect.setInfo(val_title.get()); } });
  }
  public MSheetOut clear() {
    super.clear(); return this; }
}


/*

 bloc extend abstract
 shelfpanel of element
 methods to add and manipulate element for easy macro building
 
 */
class Macro_Bloc extends Macro_Abstract {
  Macro_Bloc(Macro_Sheet _sheet, String t, String n, sValueBloc _bloc) {
    super(_sheet, t, n, _bloc);
    addShelf(); 
    addShelf();
  }

  public Macro_Element addSelectS(int c, sBoo v1, sBoo v2, String s1, String s2) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    nWidget w1 = m.addLinkedModel("MC_Element_Button_Selector_1", s1).setLinkedValue(v1);
    nWidget w2 = m.addLinkedModel("MC_Element_Button_Selector_2", s2).setLinkedValue(v2);
    w1.addExclude(w2);
    w2.addExclude(w1);
    return m;
  }
  
  
  
  public Macro_Element addEmptyS(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m;
  }
  public Macro_Element addEmptyL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  public Macro_Element addEmptyB(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Big", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  public nWidget addEmpty(int c) { 
    Macro_Element m = new Macro_Element(this, "", "mc_ref", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  public nWidget addFillR(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillright", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }
  public nWidget addFillL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillleft", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  public nWidget addLabelS(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m.back;
  }
  public nWidget addLabelL(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  public Macro_Connexion addInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m.connect;
  }
  public Macro_Connexion addOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
  }
  public Macro_Element addSheetInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m;
  }
  public Macro_Element addSheetOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m;
  }


  public Macro_Element addElement(int c, Macro_Element m) {
    if (c >= 0 && c < 3) {
      if (c == 2 && shelfs.size() < 3) addShelf();
      elements.add(m);
      getShelf(c).insertDrawer(m);
      if (c == 0 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(-ref_size*0.0f);
      if (c == 1 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size*0.5f);
      if (c == 2 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size);
      if (openning.get() == OPEN) for (Macro_Element e : elements) e.show();
      toLayerTop();
      return m;
    } else return null;
  }
  
  public String resum_link() { 
    String r = "";
    for (Macro_Element m : elements) {
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_inputs) 
        r += co.descr + INFO_TOKEN + m.connect.descr + OBJ_TOKEN;
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_outputs) 
        r += m.connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_inputs) 
      //  r += co.descr + INFO_TOKEN + m.sheet_connect.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_outputs) 
      //  r += m.sheet_connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
    }
    return r; 
  }
  
  ArrayList<Macro_Element> elements = new ArrayList<Macro_Element>();
  public Macro_Bloc toLayerTop() { 
    super.toLayerTop(); 
    for (Macro_Element e : elements) e.toLayerTop(); 
    grabber.toLayerTop(); 
    return this;
  }

  public Macro_Bloc open() {
    super.open();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  public Macro_Bloc reduc() {
    super.reduc();
    for (Macro_Element m : elements) m.reduc();
    toLayerTop();
    return this;
  }
  public Macro_Bloc show() {
    super.show();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  public Macro_Bloc hide() {
    super.hide(); 
    for (Macro_Element m : elements) m.hide();
    //toLayerTop();
    return this;
  }
}





public Macro_Packet newPacketBang() { return new Macro_Packet("bang"); }

public Macro_Packet newPacketFloat(float f) { return new Macro_Packet("float").addMsg(str(f)); }
public Macro_Packet newPacketFloat(String f) { return new Macro_Packet("float").addMsg(f); }

public Macro_Packet newPacketInt(int f) { return new Macro_Packet("int").addMsg(str(f)); }

public Macro_Packet newPacketVec(PVector p) { return new Macro_Packet("vec").addMsg(str(p.x)).addMsg(str(p.y)); }

public Macro_Packet newPacketCol(int p) { return new Macro_Packet("col")
  .addMsg(str(red(p))).addMsg(str(green(p))).addMsg(str(blue(p))); }

public Macro_Packet newPacketStr(String p) { return new Macro_Packet("str").addMsg(copy(p)); }

public Macro_Packet newPacketBool(boolean b) { 
  String r; 
  if (b) r = "T"; else r = "F"; 
  return new Macro_Packet("bool").addMsg(r); }

class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  public Macro_Packet addMsg(String m) { messages.add(m); return this; }
  
  public boolean isBang()  { return def.equals("bang"); }
  public boolean isFloat() { return def.equals("float"); }
  public boolean isInt()   { return def.equals("int"); }
  public boolean isBool()  { return def.equals("bool"); }
  public boolean isVec()   { return def.equals("vec"); }
  public boolean isCol()   { return def.equals("col"); }
  public boolean isStr()   { return def.equals("str"); }
  
  public boolean equalsVec(PVector v)   { return isVec() && v.x == asVec().x && v.y == asVec().y; }
  public boolean equalsCol(int v)   { return isCol() && v == asCol(); }
  
  public PVector asVec()   { 
    if (isVec()) return new PVector(PApplet.parseFloat(messages.get(0)), PApplet.parseFloat(messages.get(1))); else return null; }
  public int asCol()   { 
    if (isCol()) return color(PApplet.parseFloat(messages.get(0)), PApplet.parseFloat(messages.get(1)), PApplet.parseFloat(messages.get(2))); else return 0; }
  public float   asFloat()   { if (isFloat()) return PApplet.parseFloat(messages.get(0)); else return 0; }
  public int     asInt()   { if (isInt()) return PApplet.parseInt(messages.get(0)); else return 0; }
  public String  asStr()   { if (isStr()) return messages.get(0); else return ""; }
  public boolean asBool()   {
    if (isBool() && messages.get(0).equals("T")) return true; else return false; }
    
  public String getText() {
    if (isBang()) return "bang";
    else if (isFloat()) return trimStringFloat(asFloat());
    else if (isInt()) return str(asInt());
    else if (isBool() && messages.get(0).equals("T")) return "true";
    else if (isBool() && !messages.get(0).equals("T")) return "false";
    else if (isVec()) return trimStringFloat(asVec().x)+","+trimStringFloat(asVec().y);
    else if (isCol()) return trimStringFloat(red(asCol()))+","+
                             trimStringFloat(green(asCol()))+","+
                             trimStringFloat(blue(asCol()));
    else if (isStr()) return asStr();
    return "";
  }
}





/*
connexion 
 circle, hard outline, transparent, mode in or out, exist in a sheet, has an unique number
 has a label with no back for a short description and a field acsessible or not for displaying values
 the label and values are aligned, either of them can be on the left or right
 the connexion circle is on the left right top or down side center of
 the rectangle formed by the label and values
 priority button
 2 round button on top of eachother on left top corner of the connect
 1 round widget covering half of each button with the priority layer
 highlight connectable in when creating link
 package info on top of connections
 
 */
class Macro_Connexion extends nBuilder implements Macro_Interf {
  public Macro_Element getElement() { return elem; }

  public Macro_Connexion toLayerTop() { 
    super.toLayerTop(); 
    msg_view.toLayerTop(); 
    lens.toLayerTop(); 
    ref.toLayerTop();
    return this;
  }
  //ArrayList<nWidget> elem_widgets = new ArrayList<nWidget>();
  public nWidget customBuild(nWidget w) { 
    //if (elem_widgets != null) elem_widgets.add(w); 
    if ( (!is_sheet_co && sheet.openning.get() != DEPLOY) || 
    (is_sheet_co && (sheet.openning.get() != DEPLOY || elem.spot == null)) )w.hide();
    return w; 
  }
  
  nWidget ref, lens, msg_view;
  Macro_Element elem; Macro_Sheet sheet; sObj val_self;
  int type = INPUT;
  String descr; boolean is_sheet_co = false;
  Macro_Connexion(Macro_Element _elem, Macro_Sheet _sheet, int _type, String _info, boolean isc) {
    super(_elem.gui, _elem.ref_size); 
    type = _type; elem = _elem; sheet = _sheet; is_sheet_co = isc;
    descr = elem.descr+"_co";
    if      (!is_sheet_co && type == INPUT) descr += "_IN";
    else if (!is_sheet_co && type == OUTPUT) descr += "_OUT";
    else if (is_sheet_co && type == INPUT) descr += "_sheet_IN";
    else if (is_sheet_co && type == OUTPUT) descr += "_sheet_OUT";
    val_self = ((sObj)(elem.bloc.setting_bloc.getValue(descr))); 
    if (val_self == null) val_self = elem.bloc.setting_bloc.newObj(descr, this);
    else val_self.set(this);
    lens = addModel("MC_Connect_Default").setTrigger()
      .setSize(ref_size*14/16, ref_size*14/16)
      .setPosition(-ref_size*5/16, -ref_size*5/16)
      .addEventTrigger(new Runnable(this) { public void run() {
        if (buildingLine) {
          buildingLine = false; elem.bloc.mmain().buildingLine = false;
          for (Macro_Connexion i : sheet.child_connect) 
            i.lens.setLook(gui.theme.getLook("MC_Connect_Default")).setTrigger();  
        }
        else if (!elem.bloc.mmain().buildingLine && !buildingLine && sheet.mmain().selected_sheet == sheet) {
          if (type == OUTPUT) {
            buildingLine = true; elem.bloc.mmain().buildingLine = true;
            for (Macro_Connexion i : sheet.child_connect) 
              if (i.type == INPUT) i.lens.setLook(gui.theme.getLook("MC_Connect_In_Actif")).setTrigger(); 
              else if (i.type == OUTPUT && i != (Macro_Connexion)builder) 
                i.lens.setLook(gui.theme.getLook("MC_Connect_Out_Passif")).setBackground(); 
              else if (i.type == OUTPUT && i == (Macro_Connexion)builder) 
                i.lens.setLook(gui.theme.getLook("MC_Connect_Out_Passif")); 
          }
          else if (type == INPUT) {
            buildingLine = true; elem.bloc.mmain().buildingLine = true;
            for (Macro_Connexion i : sheet.child_connect) 
              if (i.type == OUTPUT) i.lens.setLook(gui.theme.getLook("MC_Connect_Out_Actif")).setTrigger(); 
              else if (i.type == INPUT && i != (Macro_Connexion)builder) 
                i.lens.setLook(gui.theme.getLook("MC_Connect_In_Passif")).setBackground(); 
              else if (i.type == INPUT && i == (Macro_Connexion)builder) 
                i.lens.setLook(gui.theme.getLook("MC_Connect_In_Passif")); 
          }
        }
      } } )
      .addEventFrame(new Runnable(this) { public void run() {
        sending = false;
        if (buildingLine) {
          newLine.x = elem.bloc.mmain().gui.mouseVector.x;
          newLine.y = elem.bloc.mmain().gui.mouseVector.y;
          if (elem.bloc.mmain().gui.in.getClick("MouseRight")) { 
            buildingLine = false; elem.bloc.mmain().buildingLine = false;
            for (Macro_Connexion i : sheet.child_connect) 
              i.lens.setLook(gui.theme.getLook("MC_Connect_Default")).setTrigger(); 
          }
          if (elem.bloc.mmain().gui.in.getClick("MouseLeft")) {
            boolean found = false;
            for (Macro_Connexion m : sheet.child_connect) { 
              if (type != m.type && m.lens.isHovered()) {
                connect_to(m);
                buildingLine = false; 
                elem.bloc.mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
                  elem.bloc.mmain().buildingLine = false; }});
                for (Macro_Connexion i : sheet.child_connect) 
                  i.lens.setLook(gui.theme.getLook("MC_Connect_Default")).setTrigger(); 
                found = true;
              }
            }
            if (!found && !lens.isHovered()) {
              buildingLine = false; elem.bloc.mmain().buildingLine = false;
              for (Macro_Connexion i : sheet.child_connect) 
                i.lens.setLook(gui.theme.getLook("MC_Connect_Default")).setTrigger();  
            }
          }
        }
        if (!buildingLine && elem.bloc.mmain().gui.in.getClick("MouseRight")) for (Macro_Connexion m : connected_inputs) {
          if (distancePointToLine(elem.bloc.mmain().gui.mouseVector.x, elem.bloc.mmain().gui.mouseVector.y, 
              getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < ref.look.outlineWeight) {
            disconnect_from(m);
            break;
          }
        }
      } } )
      ;
    ref = addModel("MC_Connect_Link")
      .setSize(ref_size*4/16, ref_size*4/16)
      .setPosition(-ref_size*6/16, ref_size*6/16)
      .setDrawable(new Drawable(gui.drawing_pile, 0) { 
      public void drawing() {
        if (elem.bloc.openning.get() == OPEN || elem.bloc.openning.get() == REDUC 
        
            || (is_sheet_co && sheet.openning.get() != HIDE) //
            
            ) {
          if (lens.isClicked) fill(ref.look.pressColor);
          else if (lens.isHovered) fill(ref.look.hoveredColor);
          else if (sending || hasSend > 0 || hasReceived > 0) fill(ref.look.outlineColor);
          else fill(ref.look.standbyColor);
          noStroke(); ellipseMode(CENTER);
          ellipse(getCenterX(), getCenterY(), ref.getLocalSX(), ref.getLocalSY());
          if (lens.isClicked) stroke(ref.look.pressColor);
          else if (lens.isHovered) stroke(ref.look.hoveredColor);
          else if (sending || hasSend > 0 || hasReceived > 0) stroke(ref.look.outlineColor);
          else noStroke();
          noFill(); strokeWeight(ref.look.outlineWeight/4);
          ellipse(getCenterX(), getCenterY(), 
            ref.getLocalSX() + ref.look.outlineWeight * 2, ref.getLocalSY() + ref.look.outlineWeight * 2);
            
          if (buildingLine) {
            stroke(ref.look.outlineColor);
            strokeWeight(ref.look.outlineWeight/2);
            PVector l = new PVector(newLine.x - getCenterX(), newLine.y - getCenterY());
            PVector lm = new PVector(l.x, l.y);
            lm.setMag(getSize()/2);
            line(getCenterX()+lm.x, getCenterY()+lm.y, 
                 getCenterX()+l.x-lm.x, getCenterY()+l.y-lm.y);
            fill(255, 0);
            ellipseMode(CENTER);
            ellipse(getCenterX(), getCenterY(), 
                    getSize(), getSize() );
            ellipse(newLine.x, newLine.y, 
                    getSize(), getSize() );
          }
          for (Macro_Connexion m : connected_inputs) {
            if (m.elem.bloc.openning.get() == OPEN || m.elem.bloc.openning.get() == REDUC 
            
                || (m.is_sheet_co && m.sheet.openning.get() != HIDE) // && m.sheet.openning.get() == OPEN
                
                ) {
              if (distancePointToLine(elem.bloc.mmain().gui.mouseVector.x, elem.bloc.mmain().gui.mouseVector.y, 
                  getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < ref.look.outlineWeight ) { 
                if (pack_info != null && hasSend > 0) elem.bloc.mmain().info.showText(pack_info);
                fill(ref.look.outlineSelectedColor); stroke(ref.look.outlineSelectedColor); } 
              else if (sending || hasSend > 0) { fill(ref.look.outlineColor); stroke(ref.look.outlineColor); }
              else { fill(ref.look.standbyColor); stroke(ref.look.standbyColor); }
              strokeWeight(ref.look.outlineWeight);
              PVector l = new PVector(m.getCenterX() - getCenterX(), m.getCenterY() - getCenterY());
              PVector lm = new PVector(l.x, l.y);
              lm.setMag(getSize()/2);
              line(getCenterX()+lm.x, getCenterY()+lm.y, 
                   getCenterX()+l.x-lm.x, getCenterY()+l.y-lm.y);
            }
          }
          if (hasSend > 0) hasSend--;
          if (hasReceived > 0) hasReceived--;
        }
      }
    });
    if (_info != null) lens.setInfo(_info);
    infoText = copy(_info);
    ref.setParent(elem.back);
    msg_view = addModel("MC_Connect_View").clearParent();
    msg_view.setParent(ref);
    if (type == OUTPUT) { 
      msg_view.stackLeft();
      elem.back.setTextAlignment(LEFT, CENTER);
      ref.alignRight().setPX(-ref.getLocalX()); 
    } 
    else {
      msg_view.stackRight();
      elem.back.setTextAlignment(RIGHT, CENTER);
    }
    lens.setParent(ref);
    sheet.child_connect.add(this);
  }
  public float getCenterX() { 
    //if (is_sheet_co && elem.bloc.sheet.openning.get() == REDUC) 
    //  return elem.bloc.sheet.grabber.getX()+elem.bloc.sheet.grabber.getLocalSX()/2;
    //else if (is_sheet_co && elem.bloc.sheet.openning.get() == OPEN) 
    //  return ref.getX()+ref.getLocalSX()/2;
    //else 
    if (elem.bloc.openning.get() == REDUC && !is_sheet_co) 
      return elem.bloc.grabber.getX()+elem.bloc.grabber.getLocalSX()/2;
    else if (elem.bloc.openning.get() == OPEN) return ref.getX()+ref.getLocalSX()/2;
    
    return ref.getX()+ref.getLocalSX()/2;
  }
  public float getCenterY() { 
    //if (is_sheet_co && elem.bloc.sheet.openning.get() == REDUC) 
    //  return elem.bloc.sheet.grabber.getY()+elem.bloc.sheet.grabber.getLocalSY()/2;
    //else if (is_sheet_co && elem.bloc.sheet.openning.get() == OPEN) 
    //  return ref.getY()+ref.getLocalSY()/2;
    //else 
    if (elem.bloc.openning.get() == REDUC && !is_sheet_co) 
      return elem.bloc.grabber.getY()+elem.bloc.grabber.getLocalSY()/2;
    else if (elem.bloc.openning.get() == OPEN) return ref.getY()+ref.getLocalSY()/2;
    
    return ref.getY()+ref.getLocalSY()/2;
  }
  public float getSize() { return ref.getLocalSY() * 2; }
  
  String infoText = "";
  
  public Macro_Connexion setInfo(String t) { 
    infoText = t; lens.setInfo(infoText+" "+last_def+filter); return this; }
  
  public Macro_Connexion clear() {
    super.clear();
    for (int i = connected_inputs.size() - 1 ; i >= 0 ; i--) disconnect_from(connected_inputs.get(i));
    for (int i = connected_outputs.size() - 1 ; i >= 0 ; i--) disconnect_from(connected_outputs.get(i));
    return this;
  }
  
  
  public boolean connect_to(Macro_Connexion m) {
    if (m != null) {
      if (type == OUTPUT && m.type == INPUT && !connected_inputs.contains(m)) {
        connected_inputs.add(m);
        m.connected_outputs.add(this); 
        sheet.add_link(descr, m.descr);
        elem.bloc.mmain().last_link_sheet = sheet;
        elem.bloc.mmain().last_created_link = descr + INFO_TOKEN + m.descr;
        return true;
      } else if (type == INPUT && m.type == OUTPUT && !connected_outputs.contains(m)) {
        connected_outputs.add(m);
        m.connected_inputs.add(this); 
        sheet.add_link(m.descr, descr);
        elem.bloc.mmain().last_link_sheet = sheet;
        elem.bloc.mmain().last_created_link = m.descr + INFO_TOKEN + descr;
        return true;
      } 
    }
    return false;
  }
  public void disconnect_from(Macro_Connexion m) {
    if (m != null && connected_inputs.contains(m)) {
      connected_inputs.remove(m);
      m.connected_outputs.remove(this); 
      sheet.remove_link(descr, m.descr);
    } 
    else if (m != null && connected_outputs.contains(m)) {
      connected_outputs.remove(m);
      m.connected_inputs.remove(this); 
      sheet.remove_link(m.descr, descr);
    }
  }
  
  boolean buildingLine = false;
  PVector newLine = new PVector();
  
  ArrayList<Macro_Connexion> connected_inputs = new ArrayList<Macro_Connexion>();
  ArrayList<Macro_Connexion> connected_outputs = new ArrayList<Macro_Connexion>();
  
  public void end_packet_process() {
    last_packet = null;
  }
  
  boolean sending = false;
  int hasSend = 0, hasReceived = 0;
  
  String last_def = "";
  
  String pack_info = null;
  
  public Macro_Connexion send(Macro_Packet p) {
    msg_view.setText(p.getText());
    last_def = copy(p.def);
    lens.setInfo(infoText+" "+last_def);
    pack_info = copy(p.def);
    for (String m : p.messages) pack_info = pack_info + " " + m;
    sending = true;
    hasSend = 15;
    packet_to_send.add(p);
    sheet.ask_packet_process();
    return this;
  }
  ArrayList<Macro_Packet> packet_to_send = new ArrayList<Macro_Packet>();
  
  public boolean process_send() {
    process_resum = ""; 
    boolean flag = packet_to_send.size() == 0;
    if (!flag) process_resum += descr+" send ";
    for (Macro_Packet p : packet_to_send) {
      process_resum = process_resum + p.getText() + " ";
      for (Macro_Connexion m : connected_inputs) m.receive(p);
      if (direct_co != null && direct_co.type == OUTPUT) direct_co.send(p);
      if (direct_co != null && direct_co.type == INPUT) direct_co.receive(p);
    }
    packet_to_send.clear();
    return flag;
  }
  
  public Macro_Connexion sendBang() { send(newPacketBang()); return this; }
  public Macro_Connexion sendFloat(float v) { send(newPacketFloat(v)); return this; }
  public Macro_Connexion sendInt(int v) { send(newPacketInt(v)); return this; }
  public Macro_Connexion sendBool(boolean v) { send(newPacketBool(v)); return this; }
  public Macro_Connexion setDefBang() { last_def = "bang"; return this; }
  public Macro_Connexion setDefBool() { last_def = "bool"; return this; }
  public Macro_Connexion setDefBin() { last_def = "bin"; return this; }
  public Macro_Connexion setDefInt() { last_def = "int"; return this; }
  public Macro_Connexion setDefFloat() { last_def = "float"; return this; }
  public Macro_Connexion setDefNumber() { last_def = "num"; return this; }
  public Macro_Connexion setDefVal() { last_def = "val"; return this; }
  public Macro_Connexion setDefVec() { last_def = "vec"; return this; }
  
  
  
  public Macro_Connexion setLastBang() { 
    last_packet = newPacketBang(); msg_view.setText(last_packet.getText()); return this; }
  public Macro_Connexion setLastBool(boolean v) { 
    last_packet = newPacketBool(v); msg_view.setText(last_packet.getText()); return this; }
  public Macro_Connexion setLastFloat(float v) { 
    last_packet = newPacketFloat(v); msg_view.setText(last_packet.getText()); return this; }
  

  Macro_Packet last_packet = null;
  
  public Macro_Packet getLastPacket() { return last_packet; }
  
  public void receive(Macro_Packet p) {
    if (filter == null || p.def.equals(filter) || 
        (filter.equals("bin") && (p.def.equals("bool") || p.def.equals("bang"))) ||
        (filter.equals("num") && (p.def.equals("float") || p.def.equals("int"))) ||
        (filter.equals("val") && (p.def.equals("float") || p.def.equals("int") || p.def.equals("bool"))) ) {
      packet_received.add(p);
      sheet.ask_packet_process();
    }
  }
  ArrayList<Macro_Packet> packet_received = new ArrayList<Macro_Packet>();
  
  String process_resum = "";
  public boolean process_receive() {
    process_resum = "";
    boolean flag = packet_received.size() == 0;
    if (!flag) process_resum += descr+" receive ";
    for (Macro_Packet p : packet_received) {
      last_packet = p;
      process_resum = process_resum + p.getText() + " ";
      for (Runnable r : eventReceiveRun) r.run();
      if (direct_co != null && direct_co.type == OUTPUT) direct_co.send(p);
      if (direct_co != null && direct_co.type == INPUT) direct_co.receive(p);
      msg_view.setText(p.getText());
      hasReceived = 15;
    }
    packet_received.clear();
    //last_packet = null; //done by sheet after processing all packets
    return flag;
  }
  
  ArrayList<Runnable> eventReceiveRun = new ArrayList<Runnable>();
  public Macro_Connexion addEventReceive(Runnable r)    { eventReceiveRun.add(r); return this; }
  public Macro_Connexion removeEventReceive(Runnable r) { eventReceiveRun.remove(r); return this; }
  
  Macro_Connexion direct_co = null;
  public void direct_connect(Macro_Connexion o) { direct_co = o; }
  
  String filter = null;
  
  public Macro_Connexion setFilter(String f) {
    filter = copy(f);
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion clearFilter() {
    lens.setInfo(infoText);
    filter = null;
    return this; }
  public Macro_Connexion setFilterBang() {
    filter = "bang";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterInt() {
    filter = "int";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterFloat() {
    filter = "float";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterNumber() { //int and float
    filter = "num";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterBool() {
    filter = "bool";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterBin() {
    filter = "bin";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterValue() { //bool int and float
    filter = "val";
    lens.setInfo(infoText+" "+filter);
    return this; }
  public Macro_Connexion setFilterVec() { //bool int and float
    filter = "vec";
    lens.setInfo(infoText+" "+filter);
    return this; }
  
  public Macro_Connexion hide() { 
    lens.hide(); msg_view.hide(); ref.hide(); 
    return this;
  }
  
  public Macro_Connexion reduc() { 
    if (elem.bloc.sheet.openning.get() == OPEN) ref.show(); 
    lens.hide(); msg_view.hide();
    return this;
  }

  public Macro_Connexion show() { 
    ref.show(); lens.show(); msg_view.show();
    return this;
  }

}

/*

 element > drawer
 has a text pour l'info bulle
 is a rectangle without back who can hold different function :
 button trigger / switch > runnable
 label for info or values > element has method to set
 selector : multi switch exclusives or not > runnable
 slide?
 jauge and graph? 
 connexions 4 places possible
 
 */
class Macro_Element extends nDrawer implements Macro_Interf {
  public Macro_Bloc getBloc() { return bloc; }

  nWidget back = null, spot = null;
  Macro_Connexion connect = null, sheet_connect = null;
  Macro_Bloc bloc;
  boolean sheet_viewable = false, was_viewable = false;
  String descr;
  sObj val_self;
  Macro_Element(Macro_Bloc _bloc, String _ref, String _model, String _info, int co_side, int sco_side, boolean sheet_view) {
    super(_bloc.getShelf(), _bloc.ref_size*1.375f, _bloc.ref_size);
    bloc = _bloc; sheet_viewable = sheet_view; was_viewable = sheet_view; 
    back = addModel(_model).setText(_ref).setPassif(); 
    
    //elem_widgets.remove(back);
    
    descr = BLOC_TOKEN+bloc.value_bloc.ref+BLOC_TOKEN+"_elem_"+bloc.elements.size();
    val_self = ((sObj)(bloc.setting_bloc.getValue(descr+"_self"))); 
    if (val_self == null) val_self = bloc.setting_bloc.newObj(descr+"_self", this);
    else val_self.set(this);
    
    back.addEventTrigger(new Runnable(this) { public void run() { 
          bloc.sheet.selecting_element((Macro_Element)builder); } });
    
    if (sheet_view) bloc.sheet.child_elements.add(this);
    if (back != null && sco_side != NO_CO && bloc.sheet != bloc.mmain()) 
      sheet_connect = new Macro_Connexion(this, bloc.sheet.sheet, sco_side, _info, true); //_info
    if (back != null && co_side != NO_CO) 
      connect = new Macro_Connexion(this, bloc.sheet, co_side, _info, false); //_info
    //if (sheet_connect != null) sheet_connect.hide(); 
    //if (connect != null) connect.hide(); 
  }
  
  public void set_spot(nWidget _spot) { 
    spot = _spot; spot.setLook("MC_Element_At_Spot").setPassif(); back.setLook("MC_Element_At_Spot").setPassif(); 
    spot.setText(bloc.value_bloc.base_ref);
    sheet_viewable = false; //if (sheet_connect != null) sheet_connect.show(); 
  }
  public void clear_spot() { 
    if (spot != null) spot.setText("");
    spot = null; back.setLook("MC_Element").setPassif(); 
    sheet_viewable = was_viewable; //if (sheet_connect != null) sheet_connect.hide(); 
  }
    
  public Macro_Element show() {
    
    back.clearParent(); back.setParent(ref); 
    back.setPX(-ref_size*0.5f);
    if (bloc.openning.get() == OPEN) {
      back.show(); 
      for (nWidget w : elem_widgets) w.show();
    }
    
    if (sheet_connect != null && spot != null)  { sheet_connect.show(); sheet_connect.toLayerTop(); }
    //if (sheet_connect != null && spot == null) sheet_connect.hide(); 
    if (connect != null && bloc.openning.get() == OPEN) { connect.show(); connect.toLayerTop(); }
    if (connect != null && bloc.openning.get() == REDUC) { connect.reduc(); connect.toLayerTop(); }
    
    toLayerTop();
    return this;
  }
  public Macro_Element reduc() {
    back.hide(); 
    for (nWidget w : elem_widgets) w.hide();
    
      //if (connect != null)  { connect.hide(); }
      //if (sheet_connect != null) { sheet_connect.hide(); }
    if (connect != null) connect.reduc(); 
    if (sheet_connect != null && spot != null) sheet_connect.reduc(); 
    //if (sheet_connect != null && spot == null) sheet_connect.hide(); 
    return this;
  }
  
  public Macro_Element hide() {
      //if (connect != null)  { connect.hide(); }
      //if (sheet_connect != null) { sheet_connect.hide(); }
    if (bloc.sheet.openning.get() == OPEN && spot != null) {
      
      back.clearParent(); back.setParent(spot).show(); 
      back.setPX(0);
      for (nWidget w : elem_widgets) w.show();
      
      if (sheet_connect != null && spot != null) { sheet_connect.show(); sheet_connect.toLayerTop(); }
      //else if (sheet_connect != null && spot == null) { sheet_connect.hide(); }
      toLayerTop();
    }
    return this;
  }
  
  public Macro_Element toLayerTop() { 
    super.toLayerTop(); 
    for (nWidget w : elem_widgets) w.toLayerTop();
    if (sheet_connect != null) sheet_connect.toLayerTop(); 
    if (connect != null) connect.toLayerTop(); 
    return this;
  }
  ArrayList<nWidget> elem_widgets = new ArrayList<nWidget>();
  public nWidget customBuild(nWidget w) { 
    if (elem_widgets != null) elem_widgets.add(w); 
    if (bloc != null && bloc.sheet.openning.get() != DEPLOY) w.hide();
    if (w != back) w.setParent(back);
    return w.setDrawer(this); 
  }
  
  public Macro_Element clear() { 
    if (spot != null) bloc.sheet.remove_spot(descr);
    super.clear(); 
    if (connect != null) connect.clear(); if (sheet_connect != null) sheet_connect.clear(); 
    if (connect != null) bloc.sheet.child_connect.remove(connect);
    if (sheet_connect != null) bloc.sheet.sheet.child_connect.remove(sheet_connect);
    bloc.sheet.child_elements.remove(this);
    return this;
  }
}
/*


  

connexion > element has method to send + runnable for receive
  circle, hard outline, transparent, mode in or out, exist in a sheet, has an unique number
  has a label with no back for a short description and a field acsessible or not for displaying values
  the label and values are aligned, either of them can be on the left or right
  the connexion circle is on the left right top or down side center of
    the rectangle formed by the label and values
  priority button
    2 round button on top of eachother on left top corner of the connect
    1 round widget covering half of each button with the priority layer
  highlight connectable in when creating link
  package info on top of connections

element > drawer
  has a text pour l'info bulle
  is a rectangle without back who can hold different function :
    button trigger / switch > runnable
    label for info or values > element has method to set
    selector : multi switch exclusives or not > runnable
    jauge and graph? 
    connexion
    
abstract extend shelfpanel
  can be selected and group dragged copy/pasted > template or deleted

bloc extend abstract
  shelfpanel of element
  methods to add and manipulate element for easy macro building
  show directly connected in/out to detect loop more easily 
    (cad show that an in will directly send through an out of his bloc when receiving)
    use 2 axis aligned lines following elements outlines from connexions to connexions
  
sheet extend abstract
  extended to make Simulation and communitys
  methods for creating blocs inside
    create in grid around center
  can build a menu with all value manipulable with easy drawer
    can choose drawer type when creating value
    can set value limits
  has spot for blocs to display when reducted

main
  is a sheet without grabber and with panel snapped to camera all time
  is extended to interface ? so work standalone with UI
  dont show soft back
  sheet on the main sheet can be snapped to camera, 
    they will keep their place and size and show panel content
    only work when not deployed
  dedicted toolpanel on top left of screen



Template :
  -save to template sValueBloc
    popup for name with field and ok button ?
  -paste last template (or one selected in menu) in selected sheet, 
    if no macro group was selected when created it will copy sheet selected at creation, 
    otherwise it will copy the group of blocs and sheets who was selected
  bloc for auto saving/loading template by name?
    macro can create macro !!!! > basic bloc create

preset :
  -save to preset sValueBloc
    popup for name with field and ok button ?
  bloc for auto saving/loading preset by name?
  saving partial preset, some value marqued as unsavable
    some value choosen to be ignored

basic bloc :
  data, var, random,
  calc, comp, bool, not, bin,
  trigg, switch, keyboard, gate, delay/pulse

complexe bloc : ( in another menu ? )
  template management
    template choosen by name added to selected sheet on bang
  preset save / load
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  setreset, counter, sequance, multigate 
  
MData : sValue access : only hold a string ref, search for corresponding svalue inside current sheet at creation
  ?? if no value is found create one ??
  has in and out
  out can send on change or when receiving bang
  if it cible a vec, the bloc can follow the corresponding position 

MDataCtrl : sValue ctrl : only in + value view
  in can change value multiple way
    bool : set / switch
    num : set / mult / add
    vec : set / mult / add for values rotation and magnitude
    tmpl : in bang > build in same sheet / parent sheet
  
MVar : when a packet is received, display and store it, send it when a bang is received
  can as disable bool input
  
*/
/*

 
             DESIGN
     !! MACRO ARE CRYSTALS !!
 
   hide labels! 
   forme carre > plus petit possible
   overlapp rectangles with those under them to show solidarity
 
 
   GUI to build
     widget jauge / graph
 
     text asking popup
       build it
       call it.popup
       will respond with a runnable
       
 */



public void myTheme_MACRO(nTheme theme, float ref_size) {
  theme.addModel("mc_ref", new nWidget()
    .setPassif()
    .setLabelColor(color(200, 200, 220))
    .setFont(PApplet.parseInt(ref_size/1.6f))
    .setOutlineWeight(0)
    .setOutlineColor(color(255, 0))
    );
  theme.addModel("MC_Panel", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(105))
    .setOutlineWeight(ref_size * 2.0f / 16.0f)
    .setOutline(true)
    );
  
  theme.addModel("MC_Title", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(80))
    .setOutlineSelectedColor(color(160))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setFont(PApplet.parseInt(ref_size/1.6f))
    .setText("--")
    .setSize(ref_size*2, ref_size*0.75f).setPosition(ref_size*1.0f, ref_size*0.5f)
    );
  theme.addModel("MC_Front", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(200))
    .setOutlineWeight(ref_size * 1.0f / 16.0f)
    .setPassif()
    );
  theme.addModel("MC_Front_Sheet", theme.newWidget("MC_Front")
    .setOutlineColor(color(200, 200, 0))
    .setOutlineWeight(ref_size * 2.0f / 16.0f)
    );
  theme.addModel("MC_Panel_Spot_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(60))
    .setOutlineColor(color(105, 105, 80))
    .setOutlineWeight(ref_size * 1.0f / 16.0f)
    .setSize(ref_size*2, ref_size)
    .setFont(PApplet.parseInt(ref_size/2))
    .setOutline(true)
    );
  theme.addModel("MC_Add_Spot_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(120, 70, 0))
    .setHoveredColor(color(180, 90, 10))
    .setSize(ref_size*2, ref_size*0.5f)
    );
  theme.addModel("MC_Add_Spot_Passif", theme.newWidget("MC_Add_Spot_Actif")
    .setStandbyColor(color(50))
    );
  theme.addModel("MC_Sheet_Soft_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(180, 60))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Sheet_Hard_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(45))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Element", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setOutlineColor(color(90))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setPosition(-ref_size*0.5f, 0)
    );
  theme.addModel("MC_Element_For_Spot", theme.newWidget("MC_Element")
    .setStandbyColor(color(120, 70, 0))
    .setOutlineColor(color(150, 150, 0))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  theme.addModel("MC_Element_At_Spot", theme.newWidget("MC_Element")
    .setOutlineColor(color(120, 70, 0))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    );
  theme.addModel("MC_Element_Single", theme.newWidget("MC_Element")
    .setSize(ref_size*2, ref_size)
    );
  theme.addModel("MC_Element_Double", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125f, ref_size)
    );
  theme.addModel("MC_Element_Big", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125f, ref_size*4.125f)
    );
  theme.addModel("MC_Element_Fillright", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5f, ref_size*1.625f)
    .setPosition(ref_size*1.25f, -ref_size*0.25f)
    );
  theme.addModel("MC_Element_Fillleft", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5f, ref_size*1.625f)
    .setPosition(-ref_size*2.875f, -ref_size*0.25f)
    );
  theme.addModel("MC_Element_Field", theme.newWidget("mc_ref")
    .setStandbyColor(color(10, 40, 80))
    .setOutlineColor(color(10, 110, 220))
    .setOutlineSelectedColor(color(130, 230, 240))
    .setOutlineWeight(ref_size / 16)
    .setFont(PApplet.parseInt(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*3.125f, ref_size*0.875f)
    );
  theme.addModel("MC_Element_SField", theme.newWidget("MC_Element_Field")
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*1.375f, ref_size*0.875f)
    );
  theme.addModel("MC_Element_Text", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(140))
    .setOutlineSelectedColor(color(200))
    .setOutlineWeight(ref_size / 16)
    .setFont(PApplet.parseInt(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_SText", theme.newWidget("MC_Element_Text")
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*1.375f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_Button", theme.newWidget("mc_ref")
    .setStandbyColor(color(10, 40, 80))
    .setHoveredColor(color(10, 110, 220))
    .setClickedColor(color(10, 90, 180))
    .setOutlineColor(color(10, 50, 100))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setFont(PApplet.parseInt(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_SButton", theme.newWidget("MC_Element_Button")
    //.setPX(-ref_size*0.25)
    .setSize(ref_size*1.375f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_MiniButton", theme.newWidget("MC_Element_Button")
    .setPosition(ref_size*1 / 16, ref_size * 4 / 16)
    .setSize(ref_size*6 / 16, ref_size*0.5f)
    .setFont(PApplet.parseInt(ref_size/3))
    );
  theme.addModel("MC_Element_Button_Selector_1", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 1 / 16)
    .setSize(ref_size*0.875f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_Button_Selector_2", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 17 / 16)
    .setSize(ref_size*0.875f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_Button_Selector_3", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 35 / 16)
    .setSize(ref_size*0.875f, ref_size*0.75f)
    );
  theme.addModel("MC_Element_Button_Selector_4", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 51 / 16)
    .setSize(ref_size*0.875f, ref_size*0.75f)
    );
  theme.addModel("MC_Grabber", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setHoveredColor(color(100))
    .setClickedColor(color(130))
    .setOutlineWeight(ref_size / 9)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setSize(ref_size*1, ref_size*0.75f)
    .setGrabbable()
    );
  theme.addModel("MC_Grabber_Deployed", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(70, 70, 0))
    .setOutlineColor(color(150, 150, 0))
    );
  theme.addModel("MC_Grabber_Selected", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(220, 220, 0))
    .setOutlineColor(color(150, 150, 0))
    );
  theme.addModel("MC_Basic", theme.newWidget("mc_ref")
    .setStandbyColor(color(100))
    .setHoveredColor(color(125))
    .setClickedColor(color(150))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setTrigger()
    .setSize(ref_size*0.75f, ref_size*0.75f)
    .setPosition(-ref_size*0.375f, -ref_size*0.375f)
    );
  theme.addModel("MC_Reduc", theme.newWidget("MC_Basic")
    .setStandbyColor(color(60))
    .setHoveredColor(color(120))
    .setClickedColor(color(160))
    .setOutlineWeight(ref_size / 12)
    .setSX(ref_size*0.5f).setPosition(-ref_size*1.0f, ref_size*0.375f)
    );
  theme.addModel("MC_Deploy", theme.newWidget("MC_Reduc")
    .setSize(ref_size*0.75f, ref_size*0.5f).setPosition(-ref_size*0.375f, -ref_size*0.5f)
    );
  theme.addModel("MC_Connect_Default", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(100))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Out_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_Out_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    );
  theme.addModel("MC_Connect_Link", theme.newWidget("mc_ref")
    .setStandbyColor(color(200))
    .setHoveredColor(color(205, 205, 200))
    .setClickedColor(color(220, 220, 200))
    .setOutlineColor(color(200, 100, 100))
    .setOutlineSelectedColor(color(200, 200, 0))
    .setOutlineWeight(ref_size / 10)
    .setOutline(true)
    .setRound(true)
    );
  theme.addModel("MC_Connect_View", theme.newWidget("mc_ref")
    .setFont(PApplet.parseInt(ref_size/2))
    .setStandbyColor(color(40))
    .setOutline(false)
    .setPosition(0, -ref_size*4/16)
    .setSize(ref_size*1.5f, ref_size*0.75f)
    );
}



/*
abstract extend shelfpanel
 can be selected and group dragged copy/pasted > template or deleted
 
 */
class Macro_Abstract extends nShelfPanel implements Macro_Interf {
  
  public Macro_Abstract deploy() { open(); return this; }
  public Macro_Abstract open() {
    if (openning.get() != OPEN) {
      openning.set(OPEN);
      grabber.show(); grab_front.show(); panel.show(); back.hide(); 
      front.show(); title.show(); reduc.show(); 
      reduc.setPosition(-ref_size, ref_size*0.375f);
      moving();
    }
    toLayerTop();
    return this;
  }
  public Macro_Abstract reduc() {
    if (openning.get() != REDUC) {
      openning.set(REDUC);
      grabber.show(); grab_front.show(); panel.hide(); back.hide(); 
      front.hide(); title.hide(); reduc.show(); 
      reduc.show().setPosition(ref_size * 0.75f, ref_size*0.75f);
      moving();
    }
    return this;
  }
  public Macro_Abstract show() {
    if (openning.get() == HIDE) { 
      if (openning_pre_hide.get() == REDUC) reduc();
      else if (openning_pre_hide.get() == OPEN) open();
      else if (openning_pre_hide.get() == DEPLOY) deploy();
      //else reduc();
    }
    return this;
  }
  public Macro_Abstract hide() {
    if (openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
    }
    grabber.hide(); grab_front.hide(); panel.hide(); back.hide(); 
    front.hide(); title.hide(); reduc.hide(); 
    return this;
  }
  public Macro_Abstract changeOpenning() {
    if (openning.get() == OPEN) { reduc(); }
    else if (openning.get() == REDUC) { open(); }
    else if (openning.get() == DEPLOY) { open(); }
    return this; }
  
  public void moving() { sheet.movingChild(this); }
  public void group_move(float x, float y) { 
    grabber.setPY(grabber.getLocalY() + y); grabber.setPX(grabber.getLocalX() + x); }
  public Macro_Abstract setPosition(float x, float y) { 
    grab_pos.doEvent(false);
    grabber.setPosition(x, y); grab_pos.set(x, y);
    grab_pos.doEvent(true);
    return this; }
  public Macro_Abstract setParent(Macro_Sheet s) { grabber.clearParent(); grabber.setParent(s.grabber); return this; }
  public Macro_Abstract toLayerTop() { 
    super.toLayerTop(); panel.toLayerTop(); title.toLayerTop(); grabber.toLayerTop(); 
    reduc.toLayerTop(); front.toLayerTop(); grab_front.toLayerTop(); return this; }

  public Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }
  
  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false, title_fixe = false, unclearable = false, pos_given = false;
  float ref_size = 40;
  sVec grab_pos; sStr val_type, val_descr, val_title;
  sInt openning, openning_pre_hide; sObj val_self;
  float prev_x, prev_y; //for group dragging
  nLinkedWidget grabber, title;
  nWidget reduc, front, grab_front, back;
  sValueBloc value_bloc = null, setting_bloc;
  Runnable szone_st, szone_en;
Macro_Abstract(Macro_Sheet _sheet, String ty, String n, sValueBloc _bloc) {
    super(_sheet.gui, _sheet.ref_size, 0.25f);
    gui = _sheet.gui; ref_size = _sheet.ref_size; sheet = _sheet; 
    sheet_depth = sheet.sheet_depth + 1;
    
    if (_bloc == null) {
      if (n == null) value_bloc = sheet.value_bloc.newBloc(sheet.child_macro.size()+"_"+ty);
      else value_bloc = sheet.value_bloc.newBloc(sheet.child_macro.size()+"_"+n);
    } else value_bloc = _bloc;
    
    setting_bloc = value_bloc.getBloc("settings");
    if (setting_bloc == null) setting_bloc = value_bloc.newBloc("settings");
    
    val_type = ((sStr)(setting_bloc.getValue("type"))); 
    val_descr = ((sStr)(setting_bloc.getValue("description"))); 
    val_title = ((sStr)(setting_bloc.getValue("title"))); 
    grab_pos = ((sVec)(setting_bloc.getValue("position"))); 
    openning = ((sInt)(setting_bloc.getValue("open"))); 
    openning_pre_hide = ((sInt)(setting_bloc.getValue("pre_open"))); 
    val_self = ((sObj)(setting_bloc.getValue("self"))); 
    
    if (val_type == null) val_type = setting_bloc.newStr("type", "type", ty);
    if (val_descr == null) val_descr = setting_bloc.newStr("description", "descr", "macro");
    //if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", n);
    if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", value_bloc.base_ref);
    if (grab_pos == null) grab_pos = setting_bloc.newVec("position", "pos");
    else pos_given = true;
    if (openning == null) openning = setting_bloc.newInt("open", "op", OPEN);
    if (openning_pre_hide == null) openning_pre_hide = setting_bloc.newInt("pre_open", "pop", OPEN);
    if (val_self == null) val_self = setting_bloc.newObj("self", this);
    else val_self.set(this);
    build_ui();
  }
  Macro_Abstract(sInterface _int) { // FOR MACRO_MAIN ONLY
    super(_int.cam_gui, _int.ref_size, 0.125f);
    gui = _int.cam_gui; 
    ref_size = _int.ref_size; 
    sheet = (Macro_Main)this;
    myTheme_MACRO(gui.theme, ref_size); 
    panel.copy(gui.theme.getModel("mc_ref"));
    grabber = addLinkedModel("mc_ref");
    grabber.clearParent();
    reduc = addModel("mc_ref");
    panel.hide(); 
    grabber.setSize(0, 0).setPassif().setOutline(false);
    front = addModel("mc_ref");
    title = addLinkedModel("mc_ref");
    back = addModel("mc_ref");
    grab_front = addModel("mc_ref");
    
    value_bloc = _int.interface_bloc.newBloc("Main_Sheet");
    setting_bloc = value_bloc.newBloc("settings");
    val_type = setting_bloc.newStr("type", "type", "main");
    val_descr = setting_bloc.newStr("description", "descr", "macro main");
    val_title = setting_bloc.newStr("title", "ttl", "macro main");
    grab_pos = setting_bloc.newVec("position", "pos");
    openning = setting_bloc.newInt("open", "op", DEPLOY);
    openning_pre_hide = setting_bloc.newInt("pre_open", "pop", DEPLOY);
    val_self = setting_bloc.newObj("self", this);
  }
  public void build_ui() {
    grabber = addLinkedModel("MC_Grabber")
      .setLinkedValue(grab_pos);
      
    grabber.clearParent().addEventDrag(new Runnable(this) { public void run() { 
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5f));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5f));
      
      if (mmain().selected_macro.contains(((Macro_Abstract)builder)))
        for (Macro_Abstract m : mmain().selected_macro) if (m != ((Macro_Abstract)builder))
          m.group_move(grabber.getLocalX() - prev_x, grabber.getLocalY() - prev_y);
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY();
      moving(); } });
    grabber.addEventGrab(new Runnable() { public void run() { 
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY(); toLayerTop(); } });
    
    panel.copy(gui.theme.getModel("MC_Panel"));
    panel.setParent(grabber).setPassif();
    panel.setPosition(-grabber.getLocalSX()/4, grabber.getLocalSY()/2 + ref_size * 1 / 8)
      .addEventShapeChange(new Runnable() { public void run() {
        front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } )
      .addEventVisibilityChange(new Runnable() { public void run() {
      if (panel.isHided()) front.setSize(0, 0);
      else front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } );
    
    back = addModel("MC_Sheet_Soft_Back");
    back.clearParent().setPassif();
    back.setParent(grabber).hide();
    
    reduc = addModel("MC_Reduc").clearParent();
    reduc.setParent(panel);
    reduc.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { changeOpenning(); } });
    
    title = addLinkedModel("MC_Title").setLinkedValue(val_title);
    title.addEventFieldChange(new Runnable() { public void run() { title.setOutline(true); } });
    title.clearParent().setParent(panel);
    title.alignDown().stackLeft();
    grabber.addEventMouseEnter(new Runnable() { public void run() { 
      if (openning.get() == REDUC) title.show(); } });
    grabber.addEventMouseLeave(new Runnable() { public void run() { 
      if (openning.get() == REDUC && !title_fixe) title.hide(); } });
    
    front = addModel("MC_Front")
      .setParent(panel).setPassif()
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() != REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(front)) front.setOutline(true);
          else front.setOutline(false); } } } )
      ;
    grab_front = addModel("MC_Front")
      .setParent(grabber).setPassif()
      .setSize(grabber.getLocalSX(), grabber.getLocalSY())
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(grab_front)) grab_front.setOutline(true);
          else grab_front.setOutline(false); } } } )
      ;
    szone_st = new Runnable() { public void run() { 
      szone_selected = false;
      front.setOutline(false); grab_front.setOutline(false); } } ;
    szone_en = new Runnable(this) { public void run() { 
      if (mmain().selected_sheet == sheet && 
          ((openning.get() != REDUC && mmain().szone.isUnder(front) ) || 
           (openning.get() == REDUC && mmain().szone.isUnder(grab_front) )) )  {
        mmain().selected_macro.add(((Macro_Abstract)builder));
        szone_selected = true; toLayerTop(); } } } ;
    if (mmain() != this) {
      mmain().szone.addEventStartSelect(szone_st);
      mmain().szone.addEventEndSelect(szone_en);
    }
    
    setParent(sheet); 
    sheet.child_macro.add(this); 
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
      if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
      else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
      else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
      else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
      if (!mmain().show_macro.get()) hide();
      if (mmain().sheet_explorer != null) mmain().sheet_explorer.update(); 
      if (!pos_given) find_place(); 
      //if (mmain().show_macro.get()) sheet.updateBack(); 
      runEvents(eventsSetupLoad); 
      toLayerTop(); 
    } } );
  }
  public void find_place() {
    int adding_v = 0;
    boolean found = false;
    while (!found) {
      if (adding_v > 0) setPosition(grabber.getLocalX() + ref_size * 6, grabber.getLocalY());
      adding_v++; 
      if (adding_v == 4) { 
        adding_v = 0; setPosition(grabber.getLocalX() - ref_size * 18, grabber.getLocalY() + ref_size * 6); }
      boolean col = false;
      for (Macro_Abstract c : sheet.child_macro) 
        if (c != this && c.openning.get() == DEPLOY 
            && rectCollide(panel.getRect(), c.back.getRect())) col = true;
        else if (c != this && c.openning.get() == REDUC 
                 && rectCollide(panel.getRect(), c.grabber.getRect())) col = true;
        else if (c != this && c.openning.get() == OPEN 
                 && rectCollide(panel.getRect(), c.panel.getRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == DEPLOY
                 && rectCollide(panel.getPhantomRect(), c.back.getPhantomRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == REDUC
                 && rectCollide(panel.getPhantomRect(), c.grabber.getPhantomRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == OPEN
                 && rectCollide(panel.getPhantomRect(), c.panel.getPhantomRect())) col = true;
      if (sheet != mmain() && openning.get() == HIDE 
          && rectCollide(panel.getPhantomRect(), sheet.panel.getPhantomRect())) col = true;
      if (sheet != mmain() && openning.get() != HIDE 
          && rectCollide(panel.getRect(), sheet.panel.getRect())) col = true;
      if (!col) found = true;
    }
    sheet.updateBack();
  }
  public Macro_Abstract clear() {
    if (!unclearable) {
      super.clear();
      val_type.clear(); val_descr.clear(); val_title.clear(); grab_pos.clear();
      openning.clear(); openning_pre_hide.clear(); val_self.clear();
      value_bloc.clear(); 
      sheet.child_macro.remove(this);
      sheet.updateBack();
      if (mmain() != this) {
        mmain().szone.removeEventStartSelect(szone_st);
        mmain().szone.removeEventEndSelect(szone_en);
      }
    }
    return this;
  }
  
  public String resum_link() { return ""; }
  
  
  public sBoo newBoo(boolean d, String r, String s) { return newBoo(r, s, d); }
  public sBoo newBoo(boolean d, String r) { return newBoo(r, r, d); }
  public sBoo newBoo(String r, boolean d) { return newBoo(r, r, d); }
  public sInt newInt(int d, String r, String s) { return newInt(r, s, d); }
  public sFlt newFlt(float d, String r, String s) { return newFlt(r, s, d); }
  public sRun newRun(Runnable d, String r, String s) { return newRun(r, s, d); }
  
  public sBoo newBoo(String r, String s, boolean d) {
    sBoo v = ((sBoo)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newBoo(r, s, d);
    return v; }
  public sInt newInt(String r, String s, int d) {
    sInt v = ((sInt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newInt(r, s, d);
    return v; }
  public sFlt newFlt(String r, String s, float d) {
    sFlt v = ((sFlt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newFlt(r, s, d);
    return v; }
  public sStr newStr(String r, String s, String d) {
    sStr v = ((sStr)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newStr(r, s, d);
    return v; }
  public sVec newVec(String r, String s) {
    sVec v = ((sVec)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newVec(r, s);
    return v; }
  public sCol newCol(String r, String s, int d) {
    sCol v = ((sCol)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newCol(r, s, d);
    return v; }
  public sRun newRun(String r, String s, Runnable d) {
    sRun v = ((sRun)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newRun(r, s, d);
    else v.set(d);
    return v; }
    
  
  public Macro_Abstract addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  
  public boolean canSetupFrom(sValueBloc bloc) {
    boolean b = (bloc != null && bloc.getBloc("settings") != null && 
    //        values_found(setting_bloc, bloc.getBloc("settings")) && 
    //        values_found(value_bloc, bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("type")).get().equals(val_type.get()));
    //if (b) log("t"); else log("f");
    return b;
    //return true;
  }
  
  public void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      runEvents(eventsSetupLoad);
    }
  }
}

/*




 sheet extend abstract
 shelfpanel of shown bloc
 
 
 methods for adding blocs inside
 
 has spot for blocs to display when reducted
 child bloc au dessus du panel can snap to spot
 
 no sheet co, stick to a free place in the hard back to make a co 
 
 quand une sheet est ouverte sont soft back est trensparent et sont parent est caché
 seulement une top sheet ouverte a la fois
 cant be grabbed when open
 
 */
class Macro_Sheet extends Macro_Abstract {
  
  public void moving() { updateBack(); sheet.movingChild(this); }
  public void movingChild(Macro_Abstract m) { updateBack(); }
  public void updateBack() {
    if (openning.get() == DEPLOY) {
      float elem_space = ref_size*2.5f;
      float minx = -elem_space, miny = -elem_space, 
            maxx = panel.getLocalX() + panel.getLocalSX() + elem_space, 
            maxy = panel.getLocalY() + panel.getLocalSY() + elem_space;
      
      for (Macro_Abstract m : child_macro) if (m.openning.get() == DEPLOY) {
        if (minx > m.grabber.getLocalX() + m.back.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() + m.back.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() + m.back.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() + m.back.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space;
      } else if (m.openning.get() == OPEN) {
        if (minx > m.grabber.getLocalX() + m.panel.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() + m.panel.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() + m.panel.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() + m.panel.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space;
      } else if (m.openning.get() == REDUC) {
        if (minx > m.grabber.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.grabber.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.grabber.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.grabber.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.grabber.getLocalSY() + elem_space;
      }
      
      back.setPosition(minx, miny);
      back.setSize(maxx - minx, maxy - miny);
      if (sheet != this) sheet.updateBack();
    }
  }
  public Macro_Sheet select() {
    if (mmain().selected_sheet != this) { 
      if (sheet != this && openning.get() != DEPLOY) deploy();
      Macro_Sheet prev_selected = mmain().selected_sheet;
      mmain().selected_sheet.back_front.setOutline(false);
      if (mmain().selected_sheet.openning.get() == DEPLOY)
        mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      else mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber"));
      mmain().selected_macro.clear();
      mmain().selected_sheet = this;
      back_front.setOutline(true);
      grabber.setLook(gui.theme.getLook("MC_Grabber_Selected"));
      prev_selected.cancel_new_spot();
      cancel_new_spot();
      toLayerTop();
      //if (mmain() != this && mmain().preset_explorer != null) mmain().preset_explorer.setBloc(preset_bloc);
    }
    if (mmain().sheet_explorer != null) mmain().sheet_explorer.setBloc(value_bloc);
    return this;
  }
  public Macro_Sheet deploy() {
    if (sheet != this && openning.get() != DEPLOY && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      if (sheet.openning.get() != DEPLOY) sheet.deploy();
      openning.set(DEPLOY);
      title_fixe = true; 
      grabber.show(); panel.show(); back.show(); back_front.show();
      front.show(); title.show(); reduc.hide(); deployer.show();
      grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) { m.show(); m.toLayerTop(); }
      //for (Macro_Element m : child_elements) if (m.sheet_connect != null) m.sheet_connect.show();
      updateBack(); 
      moving(); //toLayerTop();
    }
    toLayerTop();
    return this;
  }
  public Macro_Sheet open() {
    if (sheet != this && openning.get() != OPEN && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      openning.set(OPEN);
      title_fixe = true; 
      grabber.show(); panel.show(); back.hide(); back_front.hide();
      front.show(); title.show(); reduc.show(); deployer.show();
      reduc.setPosition(-ref_size, ref_size*0.375f);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) m.hide();
      //for (Macro_Element m : child_elements) {
      //  if (m.sheet_connect != null && m.spot != null) m.sheet_connect.show();
      //  else if (m.sheet_connect != null && m.spot == null) m.sheet_connect.hide();
      //}
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
      moving(); toLayerTop();
    }
    return this;
  }
  public Macro_Sheet reduc() {
    if (sheet != this && openning.get() != REDUC && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      openning.set(REDUC);
      title_fixe = false; 
      grabber.show(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.show(); deployer.hide();
      reduc.setPosition(ref_size * 0.75f, ref_size*0.75f);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) m.hide();
      //for (Macro_Element m : child_elements) {
      //  if (m.sheet_connect != null && m.spot != null) m.sheet_connect.reduc();
      //  else if (m.sheet_connect != null && m.spot == null) m.sheet_connect.hide();
      //}
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
      moving(); toLayerTop();
    }
    return this;
  }
  public Macro_Sheet hide() {
    if (sheet != this && openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
      title_fixe = false; 
      for (Macro_Abstract m : child_macro) m.hide();
      //for (Macro_Element m : child_elements) if (m.sheet_connect != null) m.sheet_connect.hide();
      cancel_new_spot();
      grabber.hide(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.hide(); deployer.hide();
      if (mmain().show_macro.get() && mmain().selected_sheet == this && sheet != this && sheet != mmain()) 
        sheet.select();
    }
    return this;
  }
  public Macro_Sheet toLayerTop() { 
    super.toLayerTop(); 
    panel.toLayerTop(); front.toLayerTop();
    grabber.toLayerTop(); deployer.toLayerTop();
    if (child_macro != null) for (Macro_Abstract e : child_macro) e.toLayerTop(); 
    back_front.toLayerTop(); 
    return this;
  }
  
  public void add_link(String in, String out) {
    String def = in+INFO_TOKEN+out+OBJ_TOKEN;
    links.set(links.get()+def);
  }
  public void remove_link(String in, String out) {
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    String new_list = "";
    for (String l : links_list) {
      String[] link_l = splitTokens(l, INFO_TOKEN);
      String i = link_l[0]; String o = link_l[1];
      //logln("try "+i+" "+o+" for "+in+" "+out);
      if (!i.equals(in) && !o.equals(out)) new_list += l+OBJ_TOKEN;
    }
    links.set(new_list);
  }
  public void clear_link() {
    for (Macro_Connexion co1 : child_connect) 
      for (Macro_Connexion co2 : child_connect) if (co1 != co2) co1.disconnect_from(co2);
  }
  public void redo_link() {
    //logln("redo_link");
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    clear_link();
    for (String l : links_list) {
      //logln("link "+l);
      String[] link_l = splitTokens(l, INFO_TOKEN);
      if (link_l.length == 2) {
        String i = link_l[0]; String o = link_l[1];
        //logln("in "+i+" out "+o);
        Macro_Connexion in = null, out = null;
        for (Macro_Connexion co : child_connect) {
          if (co.descr.equals(i)) in = co;
          if (co.descr.equals(o)) out = co;
        }
        if (in != null && out != null) {
          //logln("connect");
          in.connect_to(out);
        }
      }
    }
  }
  
  //call by add_spot widget
  public void new_spot(String side) {
    left_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); 
    right_spot_add.setBackground().setLook("MC_Add_Spot_Passif");
    for (Macro_Element m : child_elements) if (m.sheet_viewable) {
      m.back.setTrigger().setLook("MC_Element_For_Spot"); /*event in init de l'element*/ }
    building_spot = true;
    new_spot_side = side;
    mmain().inter.addEventFrame(new_spot_run);
  }
  public void selecting_element(Macro_Element elem) { // called by eventTrigger of elem.back
    add_spot(new_spot_side, elem);
    cancel_new_spot();
  }
  public void cancel_new_spot() {
    
    for (Macro_Element m : child_elements) if (m.sheet_viewable) {
      m.back.setBackground().setLook("MC_Element"); }
    
    mmain().inter.removeEventFrame(new_spot_run);
    if (openning.get() == DEPLOY && mmain().selected_sheet == this) {
      left_spot_add.setTrigger().setLook("MC_Add_Spot_Actif"); 
      right_spot_add.setTrigger().setLook("MC_Add_Spot_Actif"); }
    else {
      left_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); 
      right_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); }
    
    building_spot = false; new_spot_side = "";
  }
  
  public void add_spot(String side, Macro_Element elem) {
    String new_str = "";
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    nWidget spot = null;
    if (side.equals("left")) {
      left_s += elem.descr + OBJ_TOKEN;
      
      getShelf(0).removeDrawer(left_spot_drawer);
      spot = getShelf(0).addDrawer(2, 1).addModel("MC_Panel_Spot_Back");
      getShelf(0).insertDrawer(left_spot_drawer);
    } else if (side.equals("right")) {
      right_s += elem.descr + OBJ_TOKEN;
      
      getShelf(1).removeDrawer(right_spot_drawer);
      spot = getShelf(1).addDrawer(2, 1).addModel("MC_Panel_Spot_Back");
      getShelf(1).insertDrawer(right_spot_drawer);
    }
    
    elem.set_spot(spot);
    new_str += left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
  }
  public void remove_spot(String ref) {
    String new_str = "";
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    String[] list = splitTokens(left_s, OBJ_TOKEN);
    left_s = OBJ_TOKEN;
    for (String s : list) if (!s.equals(ref)) left_s += s + OBJ_TOKEN;
    
    list = splitTokens(right_s, OBJ_TOKEN);
    right_s = OBJ_TOKEN;
    for (String s : list) if (!s.equals(ref)) right_s += s + OBJ_TOKEN;
    
    new_str += left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
    
    redo_spot();
  }
  public void clear_spot() { //clear using and clear spot drawers
    spots.set(OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    for (Macro_Element t : child_elements) t.clear_spot();
    
    getShelf(0).removeDrawer(left_spot_drawer);
    while (getShelf(0).drawers.size() > 0) {
      nDrawer d = getShelf(0).drawers.get(0);
      getShelf(0).removeDrawer(d); d.clear();
    }
    getShelf(0).insertDrawer(left_spot_drawer);
    getShelf(1).removeDrawer(right_spot_drawer);
    while (getShelf(1).drawers.size() > 0) {
      nDrawer d = getShelf(1).drawers.get(0);
      getShelf(1).removeDrawer(d); d.clear();
    }
    getShelf(1).insertDrawer(right_spot_drawer);
    
    cancel_new_spot();
  }
  public void redo_spot() {
    //logln("rredo_spot");
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    clear_spot();
    
    String[] list = splitTokens(left_s, OBJ_TOKEN);
    for (String elem_ref : list) {
      Macro_Element e = null;
      for (Macro_Element t : child_elements) if (t.descr.equals(elem_ref)) { e = t; break; }
      if (e != null) add_spot("left", e);
    }
    
    list = splitTokens(right_s, OBJ_TOKEN);
    for (String elem_ref : list) {
      Macro_Element e = null;
      for (Macro_Element t : child_elements) if (t.descr.equals(elem_ref)) { e = t; break; }
      if (e != null) add_spot("right", e);
    }
  }
  //when a spot is used the ref of the element and the nb and side of the spot are saved into the string
  //when the sheet is open click on a spot to reassign it, 
  //  right click to cancel, left click on empty to clear assignment
  //two add spot button > add_spot(side)
   
   
   
  /*
  access system :
    sheet can only be deployed if you have access to them, a low access score can even hide a sheet to you
    introduce the "user" consept (just a keyword for now)
    each sheet have a str with keywords for complete and restricted access
      complete mean can deploy restricted mean can see it
  */
  String see_access = "all", deploy_access = "all";
  public Macro_Sheet setSeeAccess(String a) {
    see_access = a;
    if (!mmain().canAccess(a) && openning.get() != HIDE) hide();
    return this;
  }
  public Macro_Sheet setDeployAccess(String a) {
    deploy_access = a;
    if (!mmain().canAccess(a) && openning.get() == DEPLOY) open();
    return this;
  }
  
  sStr links;
  sStr spots;
  nWidget right_spot_add, left_spot_add;
  boolean building_spot = false;
  String new_spot_side = "";
  Runnable new_spot_run;
  nDrawer right_spot_drawer, left_spot_drawer;
  
  ArrayList<Macro_Connexion> child_connect = new ArrayList<Macro_Connexion>(0);
  ArrayList<Macro_Element> child_elements = new ArrayList<Macro_Element>(0);
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  ArrayList<Macro_Sheet> child_sheet = new ArrayList<Macro_Sheet>(0);
  
  nWidget back_front, deployer;
  Runnable szone_run;
  
  sStr specialize;
  Sheet_Specialize sheet_specialize = null;
  
  
  
  
 
  /*
  
                  TO DO
  
  develop cursor
    auto size
    dif shape / look
    constrain (dir pos mag ..)
    registered and accessible for
      new comus start
      global effect field
      multi comu objectif
    auto follow / point to objects, instent or chasing
  
  following widgets: > cursors and such
    two widget of different gui will stay at the same relative position
    
  infrastructure :
    structural model switchable (patch structure)
    need used value to be present
  
  link copy when group template
  
  MRamp
    in tick, in reset, out flt, out end
    field for float start, finish ; int length
    driven by tick ramp out from strt to finish
    option : repeat(dents de scie), invert(dents de scie decroissante), loop (aller retour)
  

                    R & D
  
  mtemplate
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  setreset, counter, sequance, multigate 
  
  when selecting a preset a flag widget tell if the values structure is compatible
    auto hide uncompatible widget ? > need to redo explorer < no just filter at list update
  
  mvar should be able to send string packet / should save given value > used for user set val
  
  
  
    
  */
  
    
  /*macro turn:
    no tick anywhere > simulation gives tick
    no frame loop, works only by reacting to gui or input event (for keyboard create a keypress/release event)
      only time bloc have frame loop, delay and pulse need them, get it throug gui
      
    when at a frame an out whant to send :
      all out who want to send do it, input save msg
      if an out have multiple exit packet are send in input priority order
      once no out whant to send all input process msg in function of the corresponding output priority 
      order and mark their out for sending eventually
      once all in have processed their msg we start again if there is an out who want to send
      careful! loop can occur, 1 turn delays will fix them
      
    when in a connexion recursive loop count the depth to detect loop and break them 
      show a popup and desactivate everything somehow
  */
  boolean packet_process_asked = false;
  public void ask_packet_process() {
    if (!packet_process_asked) {
      packet_process_asked = true;
      mmain().inter.addEventNextFrame(new Runnable() { public void run() { process_packets(); } });
    }
  }
  
  boolean DEBUG_PACKETS = true;
  public void process_packets() {
    boolean done = false; int turn_count = 0, max_turn = 100;
    //String send_resum = value_bloc.ref + " send process resum ";
    //logln(send_resum);
    while (!done || turn_count > max_turn) {
      done = true;
      for (Macro_Connexion m : child_connect) if (m.type == OUTPUT) {
        done = done && m.process_send();
        //send_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == INPUT) {
        done = done && m.process_receive();
        //receive_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == OUTPUT) {
        done = done && m.process_send();
        //send_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == INPUT) {
        done = done && m.process_receive();
        //receive_resum += m.process_resum;
        //log(m.process_resum);
      }
      turn_count++;
    }
    
    if (turn_count > max_turn) {
      String[] llink = splitTokens(mmain().last_created_link, INFO_TOKEN);
      if (llink.length == 2) mmain().last_link_sheet.remove_link(llink[0], llink[1]);
      logln("LOOP");
    }
    
    for (Macro_Connexion m : child_connect) m.end_packet_process();
    
    //logln("turn_count "+turn_count);
    //logln("");
    
    
    if (DEBUG_PACKETS) { //if (turn_count > max_turn && 
      
    }
    packet_process_asked = false;
  }
  
  
Macro_Sheet(Macro_Sheet p, String n, sValueBloc _bloc) { 
    super(p, "sheet", n, _bloc); init(); 
    if (_bloc == null) mmain().inter.addEventNextFrame(new Runnable(this) { public void run() { select(); } });
  }
  Macro_Sheet(sInterface _int) {
    super(_int);
    new_preset_name = setting_bloc.newStr("preset_name", "preset", "preset");
    
    specialize = setting_bloc.newStr("specialize", "specialize", "");
    
    links = setting_bloc.newStr("links", "links", "");
    spots = setting_bloc.newStr("spots", "spots", OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    
    addShelf(); addShelf();
    
    left_spot_add = addModel("mc_ref");
    right_spot_add = addModel("mc_ref");
    back_front = addModel("mc_ref");
    deployer = addModel("mc_ref"); }
  public void init() {
    sheet.child_sheet.add(this);
    
    links = ((sStr)(setting_bloc.getValue("links"))); 
    if (links == null) links = setting_bloc.newStr("links", "links", "");
    
    spots = ((sStr)(setting_bloc.getValue("spots"))); 
    if (spots == null) spots = setting_bloc.newStr("spots", "spots", OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    
    new_preset_name = ((sStr)(setting_bloc.getValue("preset_name"))); 
    if (new_preset_name == null) new_preset_name = setting_bloc.newStr("preset_name", "preset", "new");
    specialize = ((sStr)(setting_bloc.getValue("specialize"))); 
    if (specialize == null) specialize = setting_bloc.newStr("specialize", "specialize", "sheet");
    
    back_front = addModel("MC_Front_Sheet")
      .clearParent().setPassif();
    back_front.setParent(back);
    back.addEventShapeChange(new Runnable() { public void run() {
      back_front.setSize(back.getLocalSX(), back.getLocalSY()); } } );
    
    deployer = addModel("MC_Deploy").clearParent();
    deployer.setParent(panel);
    deployer.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { 
      if (openning.get() == DEPLOY) open(); else { deploy(); select(); } } });
    
    left_spot_drawer = addShelf().addDrawer(2, 0.5f);
    left_spot_add = left_spot_drawer.addModel("MC_Add_Spot_Passif")
      .addEventTrigger(new Runnable() { public void run() { 
        new_spot("left"); 
      } });
    right_spot_drawer = addShelf().addDrawer(2, 0.5f);
    right_spot_add = right_spot_drawer.addModel("MC_Add_Spot_Passif")
      .addEventTrigger(new Runnable() { public void run() { 
        new_spot("right");
      } });
    
    new_spot_run = new Runnable() { public void run() { 
        if (mmain().inter.input.getClick("MouseRight")) cancel_new_spot(); } };
    
    szone_run = new Runnable(this) { public void run() { 
      if (openning.get() != REDUC && mmain().search_sheet.sheet_depth < sheet_depth && 
          mmain().szone.isUnder(back_front)) { 
        mmain().search_sheet = ((Macro_Sheet)builder);
      }
    } };
    
    mmain().szone.addEventStartSelect(szone_run);
    
    updateBack();
    
  }
  
  
  public boolean canSetupFrom(sValueBloc bloc) {
    return super.canSetupFrom(bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("specialize")).get().equals(specialize.get());
  }
  
  public void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      empty();
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      
      bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        if (!(bloc.ref.equals("settings"))) {
          //search if existing bloc correspond >> unclearable >> setupFromBloc
          boolean found = false;
          if (value_bloc.getBloc(bloc.ref) != null) {
            for (Macro_Abstract m : child_macro) if (m.value_bloc.ref.equals(bloc.ref)) { 
              found = true; 
              m.setupFromBloc(bloc); 
            }
          }
          if (!found) { //sinon
            //add bloc
            sValueBloc nbloc = copy_bloc(bloc, value_bloc, bloc.base_ref);
            
            sValueBloc nbloc_child = mmain().inter.getTempBloc();
            //get nbloc child
            for (Map.Entry me : nbloc.blocs.entrySet()) {
              sValueBloc vb = ((sValueBloc)me.getValue());
              if (!vb.base_ref.equals("settings")) copy_bloc(vb, nbloc_child);
            }
            
            //empty nbloc
            sValueBloc sett_temp = mmain().inter.getTempBloc();
            sValueBloc sbloc = copy_bloc(bloc.getBloc("settings"), sett_temp, "settings");
            for (Map.Entry b : nbloc.blocs.entrySet()) { 
              sValueBloc s = (sValueBloc)b.getValue(); s.clean();
            } 
            nbloc.blocs.clear();
            copy_bloc(sbloc, nbloc);
            sett_temp.clear();
            
            //logln("adding of "+nbloc.ref+" valbloc.blocs size : "+mmain().value_bloc.blocs.size());
            
            //add macro
            Macro_Abstract a = addByBloc(nbloc);
            
            //logln("added    "+nbloc.ref+" valbloc.blocs size : "+mmain().value_bloc.blocs.size());
            
            //add copyed child to new macro
            if (a != null && a.val_type.get().equals("sheet")) {
              ((Macro_Sheet)a).addCopyofBlocContent(nbloc_child);
            }
            
            //no new macro = invalid bloc
            if (a == null) nbloc.clear();
        
            nbloc_child.clear();
          }
        }
      }});
      
      redo_link();
      redo_spot();
      
      runEvents(eventsSetupLoad);
      
      //mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
        else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
        else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
        else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
        if (!mmain().show_macro.get()) hide();
      //} } );
    }
  }
  
  
  public Macro_Sheet clear() {
    //an unclearable sheet still need to clear child macro
    empty();
    if (!unclearable) {
      super.clear();
      sheet.child_sheet.remove(this);
      value_bloc.clear();
      if (mmain() != this) mmain().szone.removeEventStartSelect(szone_run);
      if (preset_explorer != null) mmain().presets_explorers.remove(preset_explorer);
      sheet_specialize.sheet_count--;
    }
    return this;
  }
  public Macro_Sheet empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    child_sheet.clear();
    //clear spots
    updateBack();
    return this;
  }
  
  nFrontTab custom_tab;
  
  public Macro_Sheet addEventsBuildMenu(Runnable r) { eventsBuildMenu.add(r); return this; }
  ArrayList<Runnable> eventsBuildMenu = new ArrayList<Runnable>();

  public sInt menuIntSlide(int v, int _min, int _max, String r) {
    sInt f = newInt(v, r, r);
    f.set_limit(_min, _max);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf().addDrawer(10, 1)
      .addModel("Label_Small_Text-S1-P1", ((sInt)builder).ref)
        .setTextAlignment(LEFT, CENTER).getDrawer()
      .addWatcherModel("Auto_Watch_Label-S1-P3")
        .setLinkedValue(((sInt)builder))
        .setTextAlignment(CENTER, CENTER).getDrawer()
      .addWidget(new nSlide(custom_tab.gui, ref_size * 6, ref_size * 0.75f)
        .setValue( PApplet.parseFloat( ((sInt)builder).get() - ((sInt)builder).getmin() ) / 
                   PApplet.parseFloat( ((sInt)builder).getmax() - ((sInt)builder).getmin() ) )
        .addEventSlide(new Runnable(((sInt)builder)) { public void run(float c) { 
          ((sInt)builder).set( PApplet.parseInt( ((sInt)builder).getmin() + 
                                    c * (((sInt)builder).getmax() - ((sInt)builder).getmin()) ) ); 
        } } )
        .setPosition(4*ref_size, ref_size * 2 / 16) ).getShelf()
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sFlt menuFltSlide(float v, float _min, float _max, String r) {
    sFlt f = newFlt(v, r, r);
    f.set_limit(_min, _max);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf().addDrawer(10, 1)
      .addModel("Label_Small_Text-S1-P1", ((sFlt)builder).ref)
        .setTextAlignment(LEFT, CENTER).getDrawer()
      .addWatcherModel("Auto_Watch_Label-S1-P3")
        .setLinkedValue(((sFlt)builder))
        .setTextAlignment(CENTER, CENTER).getDrawer()
      .addWidget(new nSlide(custom_tab.gui, ref_size * 6, ref_size * 0.75f)
        .setValue( ( ((sFlt)builder).get() - ((sFlt)builder).getmin() ) / 
                   ( ((sFlt)builder).getmax() - ((sFlt)builder).getmin() ) )
        .addEventSlide(new Runnable(((sFlt)builder)) { public void run(float c) { 
          ((sFlt)builder).set( ((sFlt)builder).getmin() + 
                               c * (((sFlt)builder).getmax() - ((sFlt)builder).getmin()) ); 
        } } )
        .setPosition(4*ref_size, ref_size * 2 / 16) ).getShelf()
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sCol menuColor(int v, String r) {
    sCol f = newCol(r, r, v);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
        .addDrawer(10, 1)
        .addCtrlModel("Auto_Button-S2-P3", "choose").setRunnable(new Runnable(builder) { public void run() { 
          new nColorPanel(custom_tab.gui, mmain().inter.taskpanel, ((sCol)builder));
        } } ).getDrawer()
        .addWatcherModel("Auto_Watch_Label-S6/1", "Color picker: " + ((sCol)builder).ref)
          .setLinkedValue(((sCol)builder))
          .setTextAlignment(LEFT, CENTER).getDrawer()
        .getShelf()
        .addSeparator(0.125f);
    } });
    return f;
  }
  public sInt menuIntWatch(int v, String r) {
    sInt f = newInt(v, r, r);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerWatch(((sInt)builder), 10, 1)
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sFlt menuFltIncr(float v, float _f, String r) {
    sFlt f = newFlt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerIncrValue(((sFlt)builder), ((sFlt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sFlt menuFltFact(float v, float _f, String r) {
    sFlt f = newFlt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerFactValue(((sFlt)builder), ((sFlt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sInt menuIntIncr(int v, float _f, String r) {
    sInt f = newInt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerIncrValue(((sInt)builder), ((sInt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125f);
    } });
    return f;
  }
  public sInt menuIntFact(int v, float _f, String r) {
    sInt f = newInt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerFactValue(((sInt)builder), ((sInt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125f);
    } });
    return f;
  }
  
  nFrontPanel sheet_front;  
  nExplorer sheet_viewer, preset_explorer;
  sStr new_preset_name;
  
  
  public void build_custom_menu(nFrontPanel sheet_front) {}
  
  public void build_sheet_menu() {
    if (sheet_front == null) {
      sheet_front = new nFrontPanel(mmain().screen_gui, mmain().inter.taskpanel, val_title.get());
      
      sheet_front.addTab("View").getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1).addModel("Label-S3", "sheet view :").setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      sheet_viewer = sheet_front.getTab(0).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setChildAccess(false)
          .setStrtBloc(value_bloc)
          .addEventChange(new Runnable() { public void run() { 
              if (sheet_viewer.explored_bloc != value_bloc) {
                sheet_viewer.setStrtBloc(value_bloc);
              }
          } } )
          ;
      sheet_front.addTab("Preset").getShelf()
        .addSeparator(0.125f)
        .addDrawer(10.25f, 1).addModel("Label-S3", "Sheet values preset :").setTextAlignment(LEFT, CENTER).getDrawer()
        .addCtrlModel("Button-S2-P3", "Delete").setRunnable(new Runnable() { public void run() { 
          preset_explorer.selected_bloc.clear(); 
          for (nExplorer e : mmain().presets_explorers) e.update(); } } )
          .setInfo("delete selected preset").getShelf()
        .addSeparator()
        ;
      preset_explorer = sheet_front.getTab(1).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setStrtBloc(mmain().saved_preset)
          //.addEventChange(new Runnable() { public void run() { 
          //} } )
          ;
      mmain().presets_explorers.add(preset_explorer);
      
      preset_explorer.getShelf()
        .addSeparator(0.25f)
        .addDrawer(1)
          .addCtrlModel("Button-S2-P1", "Save").setRunnable(new Runnable() { public void run() { 
            save_preset(); } } ).setInfo("Save sheet values as preset").getDrawer()
          .addLinkedModel("Field-S2-P2").setLinkedValue(new_preset_name).getDrawer()
          .addCtrlModel("Button-S2-P3", "Load").setRunnable(new Runnable() { public void run() { 
            load_preset(); } } ).setInfo("load corresponding preset values into sheet values").getDrawer()
          .getShelf()
        .addSeparator(0.25f)
        ;
      //sheet_front.setPosition(
      //  screen_gui.view.pos.x + screen_gui.view.size.x - sheet_front.grabber.getLocalSX() - ref_size * 3, 
      //  screen_gui.view.pos.y + ref_size * 2 );
      
      custom_tab = sheet_front.addTab("User");

      custom_tab.getShelf()
        .addDrawer(10.25f, 1)
        .addModel("Label-S4", "-  Control  -").setFont(PApplet.parseInt(ref_size/1.8f)).getShelf()
        .addSeparator(0.125f)
        ;
      runEvents(eventsBuildMenu);
      
      build_custom_menu(sheet_front);
      
      sheet_front.addEventClose(new Runnable(this) { public void run() { 
        if (preset_explorer != null) mmain().presets_explorers.remove(preset_explorer);
        sheet_front = null; }});
    } else sheet_front.popUp();
  }
  
  public void save_preset() {
    Save_Bloc b = new Save_Bloc("");
    value_bloc.preset_value_to_save_bloc(b);
    mmain().saved_preset.newBloc(b, new_preset_name.get());
    for (nExplorer e : mmain().presets_explorers) { 
      e.update();
      e.selectEntry(new_preset_name.get());
    }
  }
  public void load_preset() {
    if (preset_explorer.selected_bloc != null) {
      transfer_bloc_values(preset_explorer.selected_bloc, value_bloc);
    }
  }
  
  String new_ref = "";
  
  public void addCopyofBlocContent(sValueBloc bloc) {
    //copy under bloc to value_bloc, do addByBloc with the copy, save new ref change if any
    new_ref = "";
    bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
      if (!bloc.ref.equals("settings")) {
        
        //add bloc
        sValueBloc nbloc = copy_bloc(bloc, value_bloc, bloc.base_ref);
        
        sValueBloc nbloc_child = mmain().inter.getTempBloc();
        //get nbloc child
        for (Map.Entry me : nbloc.blocs.entrySet()) {
          sValueBloc vb = ((sValueBloc)me.getValue());
          if (!vb.base_ref.equals("settings")) copy_bloc(vb, nbloc_child);
        }
        
        //empty nbloc
        sValueBloc sett_temp = mmain().inter.getTempBloc();
        sValueBloc sbloc = copy_bloc(bloc.getBloc("settings"), sett_temp, "settings");
        for (Map.Entry b : nbloc.blocs.entrySet()) { 
          sValueBloc s = (sValueBloc)b.getValue(); s.clean();
        } 
        nbloc.blocs.clear();
        copy_bloc(sbloc, nbloc);
        sett_temp.clear();
        
        //add macro
        Macro_Abstract a = addByBloc(nbloc);
        if (a != null) new_ref = new_ref + OBJ_TOKEN + bloc.base_ref+OBJ_TOKEN+nbloc.ref;
        
        //add copyed child to new macro
        if (a != null && a.val_type.get().equals("sheet")) 
          ((Macro_Sheet)a).addCopyofBlocContent(nbloc_child);
        
        //no new macro = invalid bloc
        if (a == null) nbloc.clear();
        
        nbloc_child.clear();
      } 
    }});
    
    
    //si bloc/links 
    if (bloc.getValue("links") != null) {
      String link_s = ((sStr)bloc.getValue("links")).get();
      //  change bloc name in bloc links
      //String new_links = "";
      String[] change_list = splitTokens(new_ref, OBJ_TOKEN);
      String[] nlink_list = splitTokens(link_s, OBJ_TOKEN);
      //String newlink = "";
      for (String l : nlink_list) {
        String[] linkpart = splitTokens(l, INFO_TOKEN);
        //String newco = "";
        for (String k : linkpart) {
          String[] copart = splitTokens(k, BLOC_TOKEN);
          for (int i = 0 ; i < change_list.length ; i += 2) {
            if (copart.length > 0 && copart[0].equals(change_list[i])) {
              copart[0] = change_list[i+1];
            }
            if (copart.length > 1 && copart[1].equals(change_list[i])) {
              copart[1] = change_list[i+1];
            }
          }
          if (copart.length > 1) {
            add_link(copart[0], copart[1]);
          }
        }
      }
    }
    redo_link();
    redo_spot();
  }
  
  //b need to be child of value_bloc and have setting/type + spe , everything else can be created
  public Macro_Abstract addByBloc(sValueBloc b) { 
    if (b != null && b.parent == value_bloc && b.getBloc("settings") != null && 
        b.getBloc("settings").getValue("type") != null) {
      
      String typ = ((sStr)b.getBloc("settings").getValue("type")).get();
      
      if (!typ.equals("sheet"))   return addByType(typ, b);
      
      else if (b.getBloc("settings").getValue("specialize") != null) {
        
        String spe = ((sStr)b.getBloc("settings").getValue("specialize")).get();
        
        for (Sheet_Specialize t : Sheet_Specialize.prints) if (!t.unique && t.name.equals(spe))
          return t.add_new(this, b, null);
      }
    }
    return null; 
  }
  
  public Macro_Abstract addByType(String t) { return addByType(t, null); }
  public Macro_Abstract addByType(String t, sValueBloc b) { 
    if (t.equals("data")) return addData(b);
    else if (t.equals("in")) return addSheetIn(b);
    else if (t.equals("out")) return addSheetOut(b);
    else if (t.equals("keyb")) return addKey(b);
    else if (t.equals("switch")) return addSwitch(b);
    else if (t.equals("trig")) return addTrig(b);
    else if (t.equals("gate")) return addGate(b);
    else if (t.equals("not")) return addNot(b);
    else if (t.equals("bin")) return addBin(b);
    else if (t.equals("bool")) return addBool(b);
    else if (t.equals("var")) return addVar(b);
    else if (t.equals("pulse")) return addPulse(b);
    else if (t.equals("calc")) return addCalc(b);
    else if (t.equals("comp")) return addComp(b);
    else if (t.equals("chan")) return addChan(b);
    else if (t.equals("vecXY")) return addVecXY(b);
    else if (t.equals("vecMD")) return addVecMD(b);
    else if (t.equals("frame")) return addFrame(b);
    else if (t.equals("numCtrl")) return addNumCtrl(b);
    else if (t.equals("vecCtrl")) return addVecCtrl(b);
    else if (t.equals("rng")) return addRng(b);
    else if (t.equals("mouse")) return addMouse(b);
    else if (t.equals("cursor")) return addCursor(b);
    else if (t.equals("com")) return addComment(b);
    //else if (t.equals("tmpl")) return addTmpl(b);
    else if (t.equals("prst")) return addPrst(b);
    else if (t.equals("menu")) return addMenu(b);
    else if (t.equals("tool")) return addTool(b);
    else if (t.equals("toolbin")) return addToolBin(b);
    else if (t.equals("tooltri")) return addToolTri(b);
    else if (t.equals("toolNC")) return addToolNCtrl(b);
    else if (t.equals("pan")) return addPanel(b);
    else if (t.equals("panbin")) return addPanBin(b);
    else if (t.equals("pansld")) return addPanSld(b);
    else if (t.equals("pangrph")) return addPanGrph(b);
    //else if (t.equals("pancstm")) return addPanCstm(b);
    return null;
  }
  
  public MData addData(sValueBloc b) { MData m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MData(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MData(this, b, mmain().sheet_explorer.selected_value);
    else m = new MData(this, b, null); return m; }
  public MSheetIn addSheetIn(sValueBloc b) { MSheetIn m = new MSheetIn(this, b); return m; }
  public MSheetOut addSheetOut(sValueBloc b) { MSheetOut m = new MSheetOut(this, b); return m; }
  public MKeyboard addKey(sValueBloc b) { MKeyboard m = new MKeyboard(this, b); return m; }
  public MSwitch addSwitch(sValueBloc b) { MSwitch m = new MSwitch(this, b); return m; }
  public MTrig addTrig(sValueBloc b) { MTrig m = new MTrig(this, b); return m; }
  public MGate addGate(sValueBloc b) { MGate m = new MGate(this, b); return m; }
  public MNot addNot(sValueBloc b) { MNot m = new MNot(this, b); return m; }
  public MBin addBin(sValueBloc b) { MBin m = new MBin(this, b); return m; }
  public MBool addBool(sValueBloc b) { MBool m = new MBool(this, b); return m; }
  public MVar addVar(sValueBloc b) { MVar m = new MVar(this, b); return m; }
  public MPulse addPulse(sValueBloc b) { MPulse m = new MPulse(this, b); return m; }
  public MCalc addCalc(sValueBloc b) { MCalc m = new MCalc(this, b); return m; }
  public MComp addComp(sValueBloc b) { MComp m = new MComp(this, b); return m; }
  public MChan addChan(sValueBloc b) { MChan m = new MChan(this, b); return m; }
  public MVecXY addVecXY(sValueBloc b) { MVecXY m = new MVecXY(this, b); return m; }
  public MVecMD addVecMD(sValueBloc b) { MVecMD m = new MVecMD(this, b); return m; }
  public MFrame addFrame(sValueBloc b) { MFrame m = new MFrame(this, b); return m; }
  public MNumCtrl addNumCtrl(sValueBloc b) { MNumCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MNumCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MNumCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MNumCtrl(this, b, null); return m; }
  public MVecCtrl addVecCtrl(sValueBloc b) { MVecCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MVecCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MVecCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MVecCtrl(this, b, null); return m; }
  public MRandom addRng(sValueBloc b) { MRandom m = new MRandom(this, b); return m; }
  public MMouse addMouse(sValueBloc b) { MMouse m = new MMouse(this, b); return m; }
  public MCursor addCursor(sValueBloc b) { MCursor m = new MCursor(this, b); return m; }
  public MComment addComment(sValueBloc b) { MComment m = new MComment(this, b); return m; }
  //MTemplate addTmpl(sValueBloc b) { MTemplate m = new MTemplate(this, b); return m; }
  public MPreset addPrst(sValueBloc b) { MPreset m = new MPreset(this, b); return m; }
  public MMenu addMenu(sValueBloc b) { MMenu m = new MMenu(this, b); return m; }
  public MTool addTool(sValueBloc b) { MTool m = new MTool(this, b); return m; }
  public MToolBin addToolBin(sValueBloc b) { MToolBin m = new MToolBin(this, b); return m; }
  public MToolTri addToolTri(sValueBloc b) { MToolTri m = new MToolTri(this, b); return m; }
  public MToolNCtrl addToolNCtrl(sValueBloc b) { MToolNCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MToolNCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MToolNCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MToolNCtrl(this, b, null); return m; }
  public MPanel addPanel(sValueBloc b) { MPanel m = new MPanel(this, b); return m; }
  public MPanBin addPanBin(sValueBloc b) { MPanBin m = new MPanBin(this, b); return m; }
  public MPanSld addPanSld(sValueBloc b) { MPanSld m = new MPanSld(this, b); return m; }
  public MPanGrph addPanGrph(sValueBloc b) { MPanGrph m = new MPanGrph(this, b); return m; }
  //MPanCstm addPanCstm(sValueBloc b) { MPanCstm m = new MPanCstm(this, b); return m; }
  
}





interface Macro_Interf {
  static final int INPUT = 0, OUTPUT = 1, NO_CO = 2;
  static final int HIDE = 0, REDUC = 1, OPEN = 2, DEPLOY = 3;
  static final String OBJ_TOKEN = "@", GROUP_TOKEN = "¤", INFO_TOKEN = "#", BLOC_TOKEN = "~";
  final String[] bloc_types1 = {"in", "out", "trig", "switch", "gate", "not", "pulse", "frame", 
                                "bin", "bool", "var", "rng", "calc", "comp", "chan", "data" };
  final String[] bloc_types2 = {"com", "vecXY", "vecMD", "vecCtrl", "numCtrl", "mouse", "keyb", 
                                "cursor", "prst", "tool", "tooltri", "toolbin", "toolNC", "pan", 
                                "panbin", "pansld", "pangrph", "menu"}; //, "pancstm", "tmpl"
}






static abstract class Sheet_Specialize {
  static int count = 0;
  static ArrayList<Sheet_Specialize> prints = new ArrayList<Sheet_Specialize>();
  
  Macro_Main mmain;
  String name, build_access = "all";
  int sheet_count = -1;
  boolean unique = false;
  
  Sheet_Specialize(String n) { name = n;  
    prints.add(this); 
    count++;
  }
  
  public Macro_Sheet add_new(Macro_Sheet s, sValueBloc b, Macro_Sheet p ) { 
    if (mmain.canAccess(build_access) && (!unique || (unique && sheet_count == -1))) { 
      sheet_count++; 
      Macro_Sheet m = null;
      if (b == null && p == null) m = get_new(s, name + "_" + sheet_count, (sValueBloc)null);
      else if (b != null) m = get_new(s, b.base_ref, (sValueBloc)b);
      else if (p != null) m = get_new(s, p.value_bloc.base_ref, p);
      m.sheet_specialize = this; m.specialize.set(name); if (unique) m.unclearable = true;
      return m; } 
    else return null; }
  protected abstract Macro_Sheet get_new(Macro_Sheet s, String n, sValueBloc b);
  protected Macro_Sheet get_new(Macro_Sheet s, String n, Macro_Sheet b) { return null; }
}



class SheetPrint extends Sheet_Specialize {
  SheetPrint() { super("sheet"); }
  public Macro_Sheet get_new(Macro_Sheet s, String n, sValueBloc b) { return new Macro_Sheet(s, n, b); }
}



/*
main
 is a sheet without grabber and with panel snapped to camera all time
 is extended to interface ? so work standalone with UI
 
 dont show soft back
 
 sheet on the main sheet can be snapped to camera, 
 they will keep their place and size and show panel content
 only work when not deployed
 
 dedicated toolpanel on top left of screen
 has button :
 -delete selected blocs
 -save/paste template
 -drop down for basic macro
 -menu: see and organise template and sheet (goto sheet)
 
 
 
 
 
 
 
 */
class Macro_Main extends Macro_Sheet {
  //nFrontPanel macro_front;  
  nToolPanel macro_tool, build_tool, sheet_tool;
  nExplorer template_explorer, sheet_explorer;
  sValueBloc pastebin = null;
  
  ArrayList<nExplorer> presets_explorers = new ArrayList<nExplorer>();
  
  public void copy_to_tmpl() {
    if (selected_macro.size() > 0) {
      sValueBloc bloc = saved_template.newBloc("group_"+selected_macro.size());
      for (Macro_Abstract m : selected_macro) copy_bloc(m.value_bloc, bloc);
      pastebin = saved_template.last_created_bloc;
      sStr tmp_link = new sStr(pastebin, "links", "links", "");
      for (Macro_Abstract m : selected_macro) {
        tmp_link.set(tmp_link.get() + m.resum_link());
      }
      for (Map.Entry me : pastebin.blocs.entrySet()) {
        sValueBloc vb = ((sValueBloc)me.getValue());
        if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
          sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
          v.setx(v.x() + ref_size * 2); v.sety(v.y() + ref_size * 3);
        }
      }
    } else if (selected_sheet != this) {
      sValueBloc bloc = saved_template.newBloc("sheet_"+selected_sheet.val_title.get());
      copy_bloc(selected_sheet.value_bloc, bloc);
      pastebin = saved_template.last_created_bloc;
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(selected_sheet.value_bloc.base_ref); }
    }
  }
  public void paste_tmpl() {
    if (template_explorer != null && template_explorer.selected_bloc != null) {
      selected_sheet.addCopyofBlocContent(template_explorer.selected_bloc);
      if (sheet_explorer != null) sheet_explorer.update();
    }
    else if (pastebin != null) {
      selected_sheet.addCopyofBlocContent(pastebin);
    }
  }

  public void build_macro_menus() {
    if (macro_tool != null) macro_tool.clear();
    macro_tool = new nToolPanel(screen_gui, ref_size, 0.125f, true, true);
    macro_tool.addShelf().addDrawer(4.375f, 1)
        .addLinkedModel("Menu_Button_Small_Outline-S1-P1", "S")
          .setLinkedValue(show_macro)
          .setInfo("show/hide macros").setFont(PApplet.parseInt(ref_size/1.9f)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "X")
          .setRunnable(new Runnable() { public void run() { 
          for (Macro_Abstract m : selected_macro) m.clear(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("delete selected bloc").setFont(PApplet.parseInt(ref_size/1.9f)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "E")
          .setRunnable(new Runnable() { public void run() { 
            selected_sheet.empty(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("Empty selected sheet").setFont(PApplet.parseInt(ref_size/1.9f)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P4", "C")
          .setRunnable(new Runnable() { public void run() { copy_to_tmpl(); }})
          .setInfo("copy selected blocs or sheet to template").setFont(PApplet.parseInt(ref_size/1.7f)).getShelfPanel()
      .addShelf().addDrawer(2.125f, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "P")
          .setRunnable(new Runnable() { public void run() { paste_tmpl(); }})
          .setInfo("Paste selected template in selected sheet").setFont(PApplet.parseInt(ref_size/1.9f)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "M")
          .setRunnable(new Runnable() { public void run() { build_sheet_menu(); }})
          .setInfo("Template management and sheets overview").setFont(PApplet.parseInt(ref_size/1.7f)).getShelfPanel()
      .addShelf().addDrawer(2.125f, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "QS")
          .setRunnable(new Runnable() { public void run() { inter.full_data_save(); }})
          .setInfo("Quick Save").setFont(PApplet.parseInt(ref_size/1.9f)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "QL")
          .setRunnable(new Runnable() { public void run() { inter.setup_load(); }})
          .setInfo("Quick Load").setFont(PApplet.parseInt(ref_size/1.9f));
    if (!show_macro_tool.get()) macro_tool.reduc();
    macro_tool.addEventReduc(new Runnable() { public void run() { 
      show_macro_tool.set(!macro_tool.hide); }});
    
    if (build_tool != null) build_tool.clear();
    build_tool = new nToolPanel(screen_gui, ref_size, 0.125f, true, true);
    build_tool.addShelf();
    for (String t : bloc_types2) build_tool.getShelf(0).addDrawer(2.5f, 0.75f)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(PApplet.parseInt(ref_size/2)).setTextAlignment(LEFT, CENTER)
        ;
    build_tool.addShelf();
    for (String t : bloc_types1) build_tool.getShelf(1).addDrawer(2.5f, 0.75f)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(PApplet.parseInt(ref_size/2)).setTextAlignment(LEFT, CENTER)
        ;
    if (!show_build_tool.get()) build_tool.reduc();
    build_tool.addEventReduc(new Runnable() { public void run() { 
      show_build_tool.set(!build_tool.hide); }});
    build_tool.panel.setPY(ref_size*1.625f);
    
    if (sheet_tool != null) sheet_tool.clear();
    sheet_tool = new nToolPanel(screen_gui, ref_size, 0.125f, true, true);
    sheet_tool.addShelf();
    
    for (Sheet_Specialize t : Sheet_Specialize.prints) if (!t.unique) sheet_tool.getShelf(0).addDrawer(3, 0.75f)
      .addCtrlModel("Menu_Button_Small_Outline-S3/0.75", t.name)
        .setRunnable(new Runnable(t) { public void run() { 
          ((Sheet_Specialize)builder).add_new(selected_sheet, null, null); }})
        .setFont(PApplet.parseInt(ref_size/2));
        ;
    
    if (!show_sheet_tool.get()) sheet_tool.reduc();
    sheet_tool.addEventReduc(new Runnable() { public void run() { 
      show_sheet_tool.set(!sheet_tool.hide); }});
    sheet_tool.panel.setPY(ref_size*16.75f);
  }
  public void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Interface");
    tab.getShelf()
      .addDrawer(10.25f, 1)
      .addModel("Label-S4", "- Interface -").setFont(PApplet.parseInt(ref_size/1.4f)).getShelf()
      .addSeparator(0.125f)
      .addDrawerDoubleButton(inter.auto_load, inter.filesm_run, 10, 1)
      .addSeparator(0.125f)
      .addDrawerDoubleButton(inter.quickload_run, inter.quicksave_run, 10, 1)
      .addSeparator(0.125f)
      ;
    
    tab = sheet_front.addTab("Explorer");
    tab.getShelf()
      .addSeparator(0.125f)
      .addDrawer(10.25f, 1).addModel("Label-S3", "sheets explorer :").setTextAlignment(LEFT, CENTER).getShelf()
      .addSeparator()
      ;
    sheet_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(value_bloc)
        .addEventChange(new Runnable() { public void run() { 
            if (value_bloc != sheet_explorer.selected_bloc && 
                sheet_explorer.selected_bloc != null && 
                sheet_explorer.selected_bloc.getBloc("settings") != null &&
                sheet_explorer.selected_bloc.getBloc("settings").getValue("self") != null && 
                sheet_explorer.selected_bloc.getBloc("settings").getValue("type") != null && 
                ((sStr)sheet_explorer.selected_bloc.getBloc("settings").getValue("type")).get().equals("sheet")) {
              Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc
                .getBloc("settings").getValue("self"))).get());
              selected_sheet.open();
              if (s != null) s.select();
            } else if (value_bloc == sheet_explorer.explored_bloc) {
              selected_sheet.open();
              select();
            }
        } } )
        ;
        
    tab = sheet_front.addTab("Template");
    tab.getShelf()
      .addSeparator(0.125f)
      .addDrawer(10.25f, 1).addModel("Label-S3", "Templates :").setTextAlignment(LEFT, CENTER).getShelf()
      .addSeparator()
      ;
    template_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(saved_template)
        .addEventChange(new Runnable() { public void run() { } } )
        ;
    if (pastebin != null) template_explorer.selectEntry(pastebin.ref);
    template_explorer.getShelf()
      .addSeparator(0.25f)
        ;
    
  }
  /*
  setup loading : 
    clear everything
      macro, template, presets, clear call to simulation
    search setup file:
      interface data : transfer values
      template, preset : copy blocs
      for blocs inside main sheet :
        sheet bloc : (has all settings)
          allready same name n spe sheet : transfer value, copy inside blocs and values
          no same name sheet : copy full bloc, build sheet with 
          same name but diff spe : delete it then do as if no same name sheet
        not a sheet bloc : delete it
    load corresponding gui property
  
  */
  public void setup_load(sValueBloc b) {
    if (b.getBloc("Template") != null) {
      saved_template.clean();
      b.getBloc("Template").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_template.newBloc(b, bloc.base_ref);
      }});
    }if (b.getBloc("Preset") != null) {
      saved_preset.clean();
      b.getBloc("Preset").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_preset.newBloc(b, bloc.base_ref);
      }});//
    }
    
    setupFromBloc(b.getBloc(value_bloc.base_ref));

    if (b.getValue("show_macro") != null) 
      show_macro.set(((sBoo)b.getValue("show_macro")).get());
    if (b.getValue("show_build_tool") != null) 
      show_build_tool.set(((sBoo)b.getValue("show_build_tool")).get());
    if (b.getValue("show_sheet_tool") != null) 
      show_sheet_tool.set(((sBoo)b.getValue("show_sheet_tool")).get());
    if (b.getValue("show_macro_tool") != null) 
      show_macro_tool.set(((sBoo)b.getValue("show_macro_tool")).get());
    
    if (sheet_explorer != null) sheet_explorer.update();
    inter.addEventNextFrame(new Runnable() { public void run() { 
      inter.addEventNextFrame(new Runnable() { public void run() { select(); } } ); } } );
  }
  
  sBoo show_gui, show_macro, show_build_tool, show_sheet_tool, show_macro_tool;
  //sInt val_scale;
  sInterface inter;
  sValueBloc saved_template, saved_preset;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  Macro_Sheet selected_sheet = this, search_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  boolean buildingLine = false;
  String access;
  public boolean canAccess(String a) { return inter.canAccess(a); }
  String last_created_link = "";
  ArrayList<MChan> chan_macros = new ArrayList<MChan>();
  ArrayList<MPanel> pan_macros = new ArrayList<MPanel>();
  ArrayList<MTool> tool_macros = new ArrayList<MTool>();
  int pan_nb = 0, tool_nb = 0;
  Macro_Sheet last_link_sheet = null;
  
  public void updateBack() {}
  
Macro_Main(sInterface _int) {
    super(_int);
    inter = _int; 
    access = inter.getAccess();
    cam_gui = inter.cam_gui; 
    screen_gui = inter.screen_gui;
    info = new nInfo(cam_gui, ref_size);
    saved_template = inter.interface_bloc.newBloc("Template");
    saved_preset = inter.interface_bloc.newBloc("Preset");
    
    show_macro = setting_bloc.newBoo("show_macro", "show", true);
    show_macro.addEventChange(new Runnable(this) { public void run() { 
      if (show_macro.get()) for (Macro_Abstract m : child_macro) m.show();
      else for (Macro_Abstract m : child_macro) m.hide();
    }});
    
    show_build_tool = setting_bloc.newBoo("show_build_tool", "build tool", true);
    show_build_tool.addEventChange(new Runnable(this) { public void run() { 
      if (build_tool != null && build_tool.hide == show_build_tool.get()) build_tool.reduc();
    }});
    show_sheet_tool = setting_bloc.newBoo("show_sheet_tool", "sheet tool", true);
    show_sheet_tool.addEventChange(new Runnable(this) { public void run() { 
      if (sheet_tool != null && sheet_tool.hide == show_sheet_tool.get()) sheet_tool.reduc();
    }});
    show_macro_tool = setting_bloc.newBoo("show_macro_tool", "macro tool", true);
    show_macro_tool.addEventChange(new Runnable(this) { public void run() { 
      if (macro_tool != null && macro_tool.hide == show_macro_tool.get()) macro_tool.reduc();
    }});
    show_gui = newBoo("show_gui", "show gui", true);
    show_gui.addEventChange(new Runnable(this) { public void run() { 
      screen_gui.isShown = show_gui.get();
      inter.show_info = show_gui.get();
    }});
    
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable(this) { public void run() { 
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable(this) { public void run() {
      search_sheet.select();
      search_sheet = ((Macro_Sheet)builder);
    }});
    
    addSpecializedSheet(new SheetPrint());
    
    //val_scale = menuIntSlide(int(ref_size), 1, 100, "val_scale");
    //val_scale.addEventChange(new Runnable(this) { public void run() {
    //  boolean b = int(ref_size) == val_scale.get();
    //  ref_size = val_scale.get();
    //  if (b) inter.quicksave_run.run();
    //  //if (b) inter.quickload_run.run();
    //}});

    inter.addEventSetupLoad(new Runnable() { 
      public void run() { 
        
        //ref_size = val_scale.get();
      }
    } 
    );
  }
  
  public void addSpecializedSheet(Sheet_Specialize s) {
    s.mmain = this;
    build_macro_menus();
  }
  public Macro_Sheet addUniqueSheet(Sheet_Specialize s) {
    s.mmain = this;
    s.unique = true;
    build_macro_menus();
    return s.add_new(this, null, null);
  }
}



























      

class CanvasPrint extends Sheet_Specialize {
  Simulation sim;
  CanvasPrint(Simulation s) { super("Canvas"); sim = s; }
  public Canvas get_new(Macro_Sheet s, String n, sValueBloc b) { return new Canvas(sim, b); }
}


//#######################################################################
//##                              CANVAS                               ##
//#######################################################################


//Canvas can;

//void init_canvas() {
//  can = new Canvas(0, 0, int((width) / cam.cam_scale.get()), int((height) / cam.cam_scale.get()), 4);
//}

class Canvas extends Macro_Sheet {
  
  
  public void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Community");
    tab.getShelf()
      .addDrawer(10.25f, 0.75f)
      .addModel("Label-S4", "-Canvas Control-").setFont(PApplet.parseInt(ref_size/1.4f)).getShelf()
      .addSeparator(0.125f)
      .addDrawerTripleButton(val_show, val_show_bound, val_show_grab, 10, 1)
      .addSeparator(0.125f)
      ;
      
    selector_list = tab.getShelf(0)
      .addSeparator(0.25f)
      .addList(4, 10, 1);
    selector_list.addEventChange_Builder(new Runnable() { public void run() {
      nList sl = ((nList)builder); 
      //logln("a "+sl.last_choice_index +"  "+ sim.list.size());
      if (sl.last_choice_index < sim.list.size()) 
        selected_comu(sim.list.get(sl.last_choice_index));
        //selected_com.set(sim.list.get(sl.last_choice_index).name);
    } } );
    
    selector_list.getShelf()
      .addSeparator(0.125f)
      .addDrawer(10.25f, 0.75f)
      .addWatcherModel("Label-S4", "Selected: ").setLinkedValue(selected_com).getShelf()
      .addSeparator(0.125f)
      ;
    
    selector_entry = new ArrayList<String>(); // mmain().data.getCountOfType("flt")
    selector_value = new ArrayList<Community>(); // mmain().data.getCountOfType("flt")
    
    update_com_selector_list();
    
  }
  public void update_com_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (Community v : sim.list) { 
      selector_entry.add(v.name); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }
  
  public void selected_comu(Community c) { 
    if (c != null && c.type_value.get().equals("floc")) { fcom = (FlocComu)c; selected_com.set(fcom.name); }
  }
  
  FlocComu fcom;
  
  ArrayList<String> selector_entry;
  ArrayList<Community> selector_value;
  Community selected_value;
  String selected_entry;
  nList selector_list;
  
  Simulation sim;
  
  Runnable tick_run, rst_run; Drawable cam_draw;
  
  sVec val_pos;
  sInt val_w, val_h, can_div;
  sFlt val_scale;
  sBoo val_show, val_show_bound, val_show_grab;
  sStr selected_com;
  sCol val_col_back;
  
  nLinkedWidget canvas_grabber;
  
  PImage can1,can2;
  int active_can = 0;
  int can_st;
  
  Canvas(Simulation m, sValueBloc b) { 
    super(m.inter.macro_main, "Canvas", b);
    sim = m;
    
    int def_pix_size = 10;
    val_pos = newVec("val_pos", "val_pos");
    val_w = menuIntIncr(width / def_pix_size, 100, "val_w");
    val_h = menuIntIncr(height / def_pix_size, 100, "val_h");
    can_div = menuIntIncr(4, 1, "can_div");
    val_scale = menuFltSlide(def_pix_size, 1, 100, "val_scale");
    val_show = newBoo(true, "val_show", "show_canvas");
    val_show_bound = newBoo(true, "val_show_bound", "show_bound");
    val_show_grab = newBoo(true, "val_show_grab", "show_grab");
    selected_com = newStr("selected_com", "scom", "");
    val_col_back = menuColor(color(0), "background");
    val_col_back.addEventChange(new Runnable() { public void run() { 
      reset();
    } });
    
    can_st = can_div.get()-1;
    can_div.addEventChange(new Runnable() { public void run() { 
      reset();
    } });
    
    canvas_grabber = gui.theme.newLinkedWidget(gui, "MC_Grabber")
      .setLinkedValue(val_pos);
    val_show_grab.addEventChange(new Runnable() { public void run() { 
      if (val_show_grab.get()) canvas_grabber.show(); else canvas_grabber.hide();
    } });
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    cam_draw = new Drawable() { public void drawing() { 
      drawCanvas(); } };
    
    val_w.addEventChange(rst_run);
    val_h.addEventChange(rst_run);
    
    if (sim != null) sim.addEventTick2(tick_run);
    if (sim != null) sim.inter.addToCamDrawerPile(cam_draw);
    if (sim != null) sim.addEventReset(rst_run);
    //if (sim != null) sim.reset();
    reset();
    
    addEventSetupLoad(new Runnable() { public void run() { 
      sim.inter.addEventNextFrame(new Runnable() {public void run() { 
        for (Community c : sim.list) if (c.name.equals(selected_com.get())) selected_comu(c);
        cam_draw.toLayerBottom();
      }}); } } );
  }
  
  public void reset() {
    can1 = createImage(val_w.get(), val_h.get(), RGB);
    init_pim(can1);
    can2 = createImage(val_w.get(), val_h.get(), RGB);
    init_pim(can2);
    can_st = can_div.get();
    active_can = 0;
  }
  
  public Canvas clear() {
    //sim.removeEventTick(tick_run);
    //sim.removeEventReset(rst_run);
    //cam_draw.clear();
    super.clear();
    return this;
  }
  
  private void init_pim(PImage canvas) {
    for(int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = val_col_back.get(); 
    }
  }
  
  private void clear_pim(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      canvas.pixels[i] = val_col_back.get(); 
    }
  }
  
  public void tick() {
    if (fcom != null) {
      for (int i = can_st ; i < fcom.list.size() ; i += max(1, can_div.get()) )
        if (fcom.list.get(i).active) {
          ((Floc)fcom.list.get(i)).draw_halo(this);
      }
    }
    if (active_can == 0) {
      if (can_st <= 0) {
        active_can = 1;
        clear_pim(can1);
        can_st = can_div.get();
      } else can_st--;
    }
    else if (active_can == 1) {
      if (can_st <= 0) {
        active_can = 0;
        clear_pim(can2);
        can_st = can_div.get();
      } else can_st--;
    }
  }
  
  public void drawCanvas() {
    if (val_show_bound.get()) {

      stroke(255);
      strokeWeight(ref_size / (10 * mmain().gui.scale) );
      noFill();
      rect(val_pos.get().x, val_pos.get().y, val_w.get() * val_scale.get(), val_h.get() * val_scale.get());
    }
    if (val_show.get()) {
      if (active_can == 0) draw(can1);
      else if (active_can == 1) draw(can2);
    }
  }
  
  public void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(val_pos.get().x, val_pos.get().y);
    scale(val_scale.get());
    image(canvas, 0, 0);
    popMatrix();
  }
  
  public void draw_halo(PVector pos, float halo_size, float halo_density, int c) {
    //walk a box of pix around entity containing the halo (pos +/- halo radius)
    for (float px = PApplet.parseInt(pos.x - halo_size) ; px < PApplet.parseInt(pos.x + halo_size) ; px+=val_scale.get())
      for (float py = PApplet.parseInt(pos.y - halo_size) ; py < PApplet.parseInt(pos.y + halo_size) ; py+=val_scale.get()) {
        PVector m = new PVector(pos.x - px, pos.y - py);
        if (m.mag() < halo_size) { //get and try distence of current pix
          //the color to add to the current pix is function of his distence to the center
          //the decreasing of the quantity of color to add is soothed
          float a = (halo_density) * soothedcurve(1.0f, m.mag() / halo_size);
          if (active_can == 0) addpix(can2, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
          if (active_can == 1) addpix(can1, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
        }
    }
  }
  
  public void addpix(PImage canvas, float x, float y, int nc) {
    //x -= int(val_scale.get() / 2);
    //y -= int(val_scale.get() / 2);
    x -= val_pos.get().x;
    y -= val_pos.get().y;
    x /= val_scale.get();
    y /= val_scale.get();
    //x += 1 / val_scale.get();
    //y += 1 / val_scale.get();
    if (x < 0 || y < 0 || x > canvas.width || y > canvas.height) return;
    int pi = canvas.width * PApplet.parseInt(y) + PApplet.parseInt(x);
    if (pi >= 0 && pi < canvas.pixels.length) {
      int oc = canvas.pixels[pi];
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




class OrganismPrint extends Sheet_Specialize {
  Simulation sim;
  OrganismPrint(Simulation s) { super("Organism"); sim = s; }
  public Organism get_new(Macro_Sheet s, String n, sValueBloc b) { return new Organism(sim, n, b); }
  public Organism get_new(Macro_Sheet s, String n, Organism b) { return new Organism(sim, n, b); }
}

/*
organism
  cell group limited in size
  different etat influence les stat global de l'organisme > preset
  l'etat depand de la situation majoritaire des cells 
    > condition du type "+ de x% des cell sont dans tel etat"

cell
  shape
  spacialization
  different etat / situation constitue le cicle de vie
    condition de changement
    consequance sur les variables
      element graphique
      feedback ?
  ex:
    evenement : naissance
    etat : croissance
    evenement : produit une cell  /  stop croissance   /  fleurie
    etats :     static            /  static            /  bloom
    evenement : meur (rng)        /  produit une cell  /  stop croissance
    etats :     dead              /  static            /  static
    evenement :                   /  meur (age)        /  meur (age)
    etats :     dead              /  dead              /  dead

shape interaction
  slowed down, 

*/


class Organism extends Macro_Sheet {
  
  public void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Cursors");

    selector_list = tab.getShelf(0)
      .addSeparator(0.125f)
      .addDrawer(10.25f, 1)
        .addCtrlModel("Auto_Ctrl_Button-S3-P1", "new cursor")
        .setRunnable(new Runnable(this) { public void run() { 
          //nCursor nc = new nCursor(custom_tab.gui, ((Macro_Sheet)builder), 
          //                         "cursor_"+cursors_list.size(), "curs");
          //cursors_list.add(nc);
          //nc.show.set(true);
          //update_curs_selector_list();
        } } ).getShelf()
      .addDrawer(10.25f, 1)
        .addLinkedModel("Auto_Ctrl_Button-S3-P1", "add cursor show")
        .setLinkedValue(adding_cursor.show).getDrawer()
        .addCtrlModel("Auto_Ctrl_Button-S3-P2", "duplicate")
        .setLinkedValue(srun_duplic).getShelf()
      .addSeparator(0.125f)
      .addList(4, 10, 0.8f);
    selector_list.addEventChange_Builder(new Runnable() { public void run() {
      nList sl = ((nList)builder); 
      nCursor c;
      if (sl.last_choice_index < cursors_list.size()) 
        c = cursors_list.get(sl.last_choice_index);
    } } );
    
    selector_entry = new ArrayList<String>();
    selector_value = new ArrayList<nCursor>();
    cursors_list = new ArrayList<nCursor>();
    
    selector_list.getShelf()
      .addSeparator(0.0625f)
      ;
    update_curs_selector_list();
  }
  public void update_curs_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (nCursor v : cursors_list) { 
      selector_entry.add(v.ref); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }

  ArrayList<nCursor> cursors_list;
  
  ArrayList<String> selector_entry;
  ArrayList<nCursor> selector_value;
  nCursor selected_cursor;
  String selected_entry;
  nList selector_list;
  
  sRun srun_duplic;
  
  Simulation sim;

  Runnable tick_run, rst_run; Drawable cam_draw;
  
  ArrayList<Cell> list = new ArrayList<Cell>(); //contien les objet

  sInt max_entity, active_entity;
  
  sFlt larg, lon, dev, shrt, branch;
  
  sCol val_fill1, val_fill2, val_stroke;
  
  nCursor adding_cursor;
  
  sRun srun_reset;
  
  Organism(Simulation _s, String n, sValueBloc b) { 
    super(_s.inter.macro_main, n, b);
    sim = _s;
    
    branch = menuFltFact(500, 2, "branch");
    shrt = menuFltFact(0.95f, 1.02f, "shortening");
    dev = menuFltFact(4, 2, "deviation");
    lon = menuFltSlide(40, 5, 200, "length");
    larg = menuFltFact(1, 1.02f, "large");
    
    val_stroke = menuColor(color(10, 190, 40), "val_stroke");
    val_fill2 = menuColor(color(30, 90, 20), "val_fill2");
    val_fill1 = menuColor(color(20, 130, 40), "val_fill1");
    
    max_entity = menuIntIncr(40, 100, "max_entity");
    
    organ_init();
    
    adding_cursor = new nCursor(sim.cam_gui, this, n, "add");
  }
  Organism(Simulation _s, String n, Organism b) { 
    super(_s.inter.macro_main, n, null);
    
    sim = _s;
    branch = menuFltFact(b.branch.get(), 2, "branch");
    shrt = menuFltFact(b.shrt.get(), 1.02f, "shortening");
    dev = menuFltFact(b.dev.get(), 2, "deviation");
    lon = menuFltSlide(b.lon.get(), 5, 200, "length");
    larg = menuFltFact(b.larg.get(), 1.02f, "large");
    
    val_stroke = menuColor(b.val_stroke.get(), "val_stroke");
    val_fill2 = menuColor(b.val_fill2.get(), "val_fill2");
    val_fill1 = menuColor(b.val_fill1.get(), "val_fill1");
    
    max_entity = menuIntIncr(b.max_entity.get(), 100, "max_entity");
    
    organ_init();
    
    adding_cursor = new nCursor(sim.cam_gui, this, n, "add");
    adding_cursor.pval.set(b.adding_cursor.pval.get());
    adding_cursor.pval.add(ref_size * 4, 0);
  }
  
  public void organ_init() {
    
    active_entity = menuIntWatch(0, "active_entity");
    
    srun_reset = newRun("organ_reset", "reset", new Runnable() { 
      public void run() { reset(); } } );
    srun_duplic = newRun("duplication", "duplic", new Runnable() { public void run() { duplicate(); } } );
    
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    cam_draw = new Drawable() { public void drawing() { 
      draw_All(); } };
    
    if (sim != null) sim.addEventTick(tick_run);
    if (sim != null) sim.inter.addToCamDrawerPile(cam_draw);
    if (sim != null) sim.reset();
    if (sim != null) sim.addEventReset(rst_run);
  }

  public Organism clear() {
    this.destroy_All();
    sim.removeEventTick(tick_run);
    sim.removeEventReset(rst_run);
    cam_draw.clear();
    super.clear();
    return this;
  }
  
  public void duplicate() {
    if (selected_cursor != null) {
      Organism m = (Organism)sheet_specialize.add_new(sim, null, this);
      m.setPosition(selected_cursor.pos().x, selected_cursor.pos().y);
    }
  }
  
  public void init_array() {
    list.clear();
    for (int i = 0; i < max_entity.get(); i++)
      list.add(build());
  }

  public void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (max_entity.get() != list.size()) init_array();
    
    Cell c = newEntity(null);
    
  }

  public void tick() {
    active_entity.set(active_Entity_Nb());
    for (Cell e : list) if (e.active) e.tick();
    
  }

  public void draw_All() { 
    for (Cell e : list) if (e.active) e.draw(); }
  public void destroy_All() { 
    for (Cell e : list) e.destroy(); }

  public int active_Entity_Nb() {
    int n = 0;
    for (Cell e : list) if (e.active) n++;
    return n;
  }
  public Cell build() { 
    return new Cell(this);
  }
  public Cell newEntity(Cell p) {
    Cell ng = null;
    for (Cell e : list) 
      if (!e.active && ng == null) { 
        ng = (Cell)e; 
        e.activate();
      }
    if (ng != null) ng.define(p);
    return ng;
  }
}




/*
class nface
  3 coordinate
  should all have the same surface!!
  
nShape spacialization:
  pos, dir, scale, mirroring
  
nBase 
  an exemple
*/




class nFace {
  float standard_aire = 10;
  PVector p1,p2,p3;
  public void norma() {
    //float a = standard_aire; //trig aire
    //p1.mult(standard_aire/a);
    //p2.mult(standard_aire/a);
    //p3.mult(standard_aire/a);
  }
}

abstract class nShape {
  PVector pos = new PVector(0, 0);
  PVector dir = new PVector(10, 0); //heading : rot , mag : scale
  boolean do_fill = true, do_stroke = true;
  int col_fill = color(20, 130, 40), col_line = color(10, 190, 40);
  float line_w = 0.01f;
  public void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir.heading());
    scale(dir.mag());
    if (do_fill) fill(col_fill); else noFill(); 
    if (do_stroke) stroke(col_line); else noStroke(); strokeWeight(line_w);
    
    drawcall();
    
    popMatrix();
  }
  public abstract void drawcall();
}

class nBase extends nShape {
  nFace face;    
  nBase() {
    face = new nFace();
    face.p1 = new PVector(1, 0);
    face.p2 = new PVector(0, 0.3f);
    face.p3 = new PVector(-1, -0.3f);
    face.norma();
  }
  public void drawcall() {
    triangle(face.p1.x, face.p1.y, face.p2.x, face.p2.y, face.p3.x, face.p3.y);
  }
}

class Cell {
  
  nBase shape;

  Organism com;
  int age = 0;
  boolean active = false;
  
  int state = 0;
  Cell(Organism c) { 
    com = c;
  }
  public Cell clear() { 
    return this;
  }
  public Cell activate() {
    if (!active) { 
      active = true; 
      age = 0; 
      state = 0;
      shape = new nBase();
      shape.dir.setMag(com().lon.get());
      float inf = PApplet.parseFloat(com().active_entity.get()) / PApplet.parseFloat(com().max_entity.get());
      float inf2 = (PApplet.parseFloat(com().max_entity.get()) - PApplet.parseFloat(com().active_entity.get())) / 
                   PApplet.parseFloat(com().max_entity.get());
      float re = (com().val_fill2.getred() * inf + com().val_fill1.getred() * inf2) / 1.0f;
      float gr = (com().val_fill2.getgreen() * inf + com().val_fill1.getgreen()* inf2) / 1.0f;
      float bl = (com().val_fill2.getblue() * inf + com().val_fill1.getblue() * inf2) / 1.0f;
      shape.col_fill = color(re, gr, bl);
      shape.col_line = com().val_stroke.get();
    }
    return this;
  }
  public Cell destroy() {
    if (active) { 
      active = false; 
      clear();
    }
    return this;
  }
  public Cell define(Cell p) {
    if (p != null) {
      PVector _p = p.shape.pos;
      PVector _d = p.shape.dir;
      shape.pos.x = _p.x + _d.x;
      shape.pos.y = _p.y + _d.y;
      shape.dir.set(_d);
      shape.dir.rotate(random(-HALF_PI/com().dev.get(), HALF_PI/com().dev.get()));
      shape.dir.setMag(shape.dir.mag() * random(min(com().shrt.get(), 1), max(com().shrt.get(), 1)) );
      
      shape.face.p2.set(p.shape.face.p2.x, - p.shape.face.p2.y / com().larg.get());
      shape.face.p3.set(p.shape.face.p3.x, - p.shape.face.p3.y / com().larg.get());
    } else if (com().adding_cursor != null) {
      shape.pos.x = com().adding_cursor.pos().x;
      shape.pos.y = com().adding_cursor.pos().y;
      float dm = shape.dir.mag();
      shape.dir.set(com().adding_cursor.dir());
      shape.dir.rotate(random(-HALF_PI/com().dev.get(), HALF_PI/com().dev.get()));
      shape.dir.setMag(dm * shape.dir.mag() * random(min(com().shrt.get(), 1), max(com().shrt.get(), 1)) );
    }
    return this;
  }
  public Cell tick() {
    age++;
    if (state == 0) {
      if (age == 2) {
        com().newEntity(this);
        state = 1;
      }
    } else if (state == 1) {
      if (crandom(com().branch.get()) > 0.5f) {
        com().newEntity(this);
        state = 2;
      }
    } else if (state == 2) {
      
    }
    return this;
  }
  public Cell draw() {
    shape.draw();
    return this;
  }
  public Organism com() { 
    return ((Organism)com);
  }
}






class GrowerPrint extends Sheet_Specialize {
  Simulation sim;
  GrowerPrint(Simulation s) { super("Grower"); sim = s; }
  public GrowerComu get_new(Macro_Sheet s, String n, sValueBloc b) { return new GrowerComu(sim, n, b); }
}


class GrowerComu extends Community {

  sFlt DEVIATION; //drifting (rotation posible en portion de pi (PI/drift))
  sFlt L_MIN; //longeur minimum de chaque section
  sFlt L_MAX; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  sFlt L_DIFFICULTY;
  sFlt OLD_AGE;
  //int TEEN_AGE = OLD_AGE / 20;

  RandomTryParam growP;
  RandomTryParam sproutP;
  RandomTryParam stopP;
  RandomTryParam leafP;
  RandomTryParam dieP;
  sFlt MAX_LINE_WIDTH; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  sFlt MIN_LINE_WIDTH; //epaisseur min des ligne

  sBoo create_floc;
  sInt activeGrower;
  sRun srun_killg;

  sCol val_col_live, val_col_leaf;
  
  FlocComu fcom;

  public void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = sim_front.addTab(name);
    tab.getShelf()
      .addDrawerWatch(activeGrower, 10, 0.7f)
      .addDrawer(10.25f, 0).getShelf()
      .addSeparator(0.125f)
      .addDrawerDoubleButton(create_floc, srun_killg, 10, 0.9f)
      .addSeparator(0.125f)
      .addDrawerFactValue(DEVIATION, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(L_MIN, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(L_MAX, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(L_DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(OLD_AGE, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerActFactValue("grow", growP.ON, growP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerActFactValue("Sprout", sproutP.ON, sproutP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerActFactValue("leaf", leafP.ON, leafP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerActFactValue("stop", stopP.ON, stopP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerActFactValue("die", dieP.ON, dieP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125f)
      ;
  }
  
  public void selected_comu(Community c) { 
    //logln(c.name + c.type_value.get());
    if (c != null && c.type_value.get().equals("floc")) fcom = (FlocComu)c;
  }

  GrowerComu(Simulation _c, String n, sValueBloc t) { 
    super(_c, n, "grow", 1000, t);
    DEVIATION = newFlt(6, "dev", "dev");
    L_MIN = newFlt(2.5f, "lmin", "lmin");
    L_MAX = newFlt(40, "lmax", "lmax");
    L_DIFFICULTY = newFlt(1, "ldif", "ldif");
    OLD_AGE = newFlt(100, "age", "age");

    growP = new RandomTryParam(this, 0.2f, true, "grow");
    sproutP = new RandomTryParam(this, 3000, true, "sprout");
    stopP = new RandomTryParam(this, 2, true, "stop");
    leafP = new RandomTryParam(this, 5000, true, "leaf");
    dieP = new RandomTryParam(this, 40, true, "die");

    create_floc = newBoo(true, "create_floc", "create floc");
    activeGrower = newInt(0, "active_grower", "growers nb");
    
    val_col_live = menuColor(color(220), "val_col_live");
    val_col_leaf = menuColor(color(0, 220, 0), "val_col_leaf");
    
    MAX_LINE_WIDTH = menuFltSlide(1.5f, 0.1f, 3, "max_line_width");
    MIN_LINE_WIDTH = menuFltSlide(0.2f, 0.1f, 3, "min_line_width");
    
    srun_killg = newRun("kill_grower", "kill", new Runnable(list) { 
      public void run() { 
        for (Entity e : ((ArrayList<Entity>)builder)) {
          Grower g = (Grower)e;
          if (!g.end && g.sprouts == 0) { 
            g.end = true;
          }
        }
      }
    }
    );

    //graph.init();
  }
  public void custom_cam_draw_pre_entity() {
  }
  public void custom_cam_draw_post_entity() {
  }
  public void custom_pre_tick() {
    activeGrower.set(grower_Nb());
  }
  public void custom_post_tick() {
  }

  public Grower build() { 
    return new Grower(this);
  }
  public Grower addEntity() {
    Grower ng = newEntity();
    if (ng != null) ng.define(adding_cursor.pos(), adding_cursor.dir());
    return ng;
  }
  public Grower newEntity() {
    Grower ng = null;
    for (Entity e : list) 
      if (!e.active && ng == null) { 
        ng = (Grower)e; 
        e.activate();
      }
    return ng;
  }
  public void custom_frame() {
    //graph.update(activeEntity.get(), activeGrower.get());
  }
  public void custom_screen_draw() {
    //graph.draw();
  }
  public int grower_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active && !((Grower)e).end && ((Grower)e).sprouts == 0) n++;
    return n;
  }
}





class RandomTryParam {// extends Callable
  sFlt DIFFICULTY;
  sBoo ON;
  //sFlt test_by_tick;
  int count = 0;
  RandomTryParam(Macro_Sheet sheet, float d, boolean b, String n) { 
    DIFFICULTY = sheet.newFlt(d, n+"_dif", "dif");
    ON = sheet.newBoo(b, n+"_on", "on");
    //test_by_tick = new sFlt(sbloc, 0);
    //DIFFICULTY.set(d); 
    //ON.set(b); 
    //addChannel(frameend_chan);
  }
  public boolean test() { 
    if (ON.get()) count++; 
    //test_by_tick.set(count / sim.tick_by_frame.get()); 
    return ON.get() && crandom(DIFFICULTY.get()) > 0.5f;
  }
  //void answer(Channel chan, float v) { count = 0; test_by_tick.set(0); }
}






class Grower extends Entity {

  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();

  float halo_size = 10;
  float halo_density = 0.2f;

  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0f;
  float start = 0.0f;

  Grower(GrowerComu c) { 
    super(c);
  }

  public Grower init() {
    end = false;
    sprouts = 0;
    age = 0;
    start = 0.0f;
    return this;
  }
  public Grower define(PVector _p, PVector _d) {
    pos = _p;
    grows = new PVector(com().L_MIN.get() + crandom(com().L_DIFFICULTY.get())*(com().L_MAX.get() - com().L_MIN.get()), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(PI / com().DEVIATION.get()) - ((PI / com().DEVIATION.get()) / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    return this;
  }
  public Grower frame() { 
    return this;
  }
  public Grower tick() {
    age++;
    if (age < com().OLD_AGE.get()/20) {
      start = (float)age / (float)com().OLD_AGE.get()/20;
    } else start = 1;

    //grow
    if (start == 1 && !end && sprouts == 0 && com().growP.test()) {
      Grower n = com().newEntity();
      if (n != null) {
        n.define(grows, dir);
        sprouts++;
      }
    }

    // sprout
    if (start == 1 && !end && com().sproutP.test()) {
      Grower n = com().newEntity();
      if (n != null) {
        PVector _p = new PVector(0, 0);
        PVector _d = new PVector(0, 0);
        _d.add(grows).sub(pos);
        _d.setMag(random(1.0f) * _d.mag());
        _p.add(pos).add(_d);
        n.define(_p, _d);
        sprouts++;
      }
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }

    // leaf
    if (start == 1 && !end && com().leafP.test()) {
      PVector _p = new PVector(0, 0);
      PVector _d = new PVector(0, 0);
      _d.add(grows).sub(pos);
      _d.setMag(random(1.0f) * _d.mag());
      _p.add(pos).add(_d);
      Grower n = com().newEntity();
      if (n != null) {
        n.define(_p, _d);
        n.end = true;
        sprouts++;
      }
    }

    // stop growing
    if (start == 1 && !end && sprouts == 0 && com().stopP.test()) {
      if (com().create_floc.get() && com().fcom != null) {
        Floc f = com().fcom.newEntity();
        if (f != null) {
          f.pos.x = pos.x;
          f.pos.y = pos.y;
        }
      }
      end = true;
    }

    // die
    float rng = crandom(com().dieP.DIFFICULTY.get());
    if (com().dieP.ON.get() && start == 1 && !(!end && sprouts == 0) &&
      (rng > ( (float)com().OLD_AGE.get() / (float)age ) //||
      //rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
      )) {
      this.destroy();
    }
    return this;
  }
  public Grower draw() {
    // aging color
    int ca = 255;
    if (age > com().OLD_AGE.get() / 2) ca = (int)constrain(255 + PApplet.parseInt(com().OLD_AGE.get()/2) - PApplet.parseInt(age/1.2f), 90, 255);
    //if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); } //BIG red head
    if (!end && sprouts == 0) { 
      stroke(com().val_col_live.get()); 
      strokeWeight((com().MAX_LINE_WIDTH.get()+1) / com.sim.inter.cam.cam_scale.get());
    } else if (end) { 
      int res = color(com().val_col_leaf.getred() * (PApplet.parseFloat(ca) / 255.0f), 
                        com().val_col_leaf.getgreen() * (PApplet.parseFloat(ca) / 255.0f), 
                        com().val_col_leaf.getblue() * (PApplet.parseFloat(ca) / 255.0f) );
      stroke(res); 
      strokeWeight((com().MAX_LINE_WIDTH.get()+1) / com.sim.inter.cam.cam_scale.get());
    } else { 
      int res = color(com().val_col_live.getred() * (PApplet.parseFloat(ca) / 255.0f), 
                        com().val_col_live.getgreen() * (PApplet.parseFloat(ca) / 255.0f), 
                        com().val_col_live.getblue() * (PApplet.parseFloat(ca) / 255.0f) );
      stroke(res); 
      strokeWeight(((float)com().MIN_LINE_WIDTH.get() + ((float)com().MAX_LINE_WIDTH.get() * (float)ca / 255.0f)) / com.sim.inter.cam.cam_scale.get());
    }              

    PVector e = new PVector(dir.x, dir.y);
    if (start < 1) e = e.setMag(e.mag() * start);
    //e = e.add(pos);
    //line(pos.x,pos.y,e.x,e.y);
    pushMatrix();
    translate(pos.x, pos.y);
    if (end) {
      PVector e2 = new PVector(e.x, e.y);
      e.div(2);
      e.rotate(-PI/16);
      line(0, 0, e.x, e.y);
      line(e2.x, e2.y, e.x, e.y);
      e.rotate(PI/8);
      line(0, 0, e.x, e.y);
      line(e2.x, e2.y, e.x, e.y);
    } else line(0, 0, e.x, e.y);
    popMatrix();

    //line(pos.x,pos.y,grows.x,grows.y);

    //DEBUG
    //fill(255); ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    return this;
  }
  public Grower clear() { 
    return this;
  }
  public GrowerComu com() { 
    return ((GrowerComu)com);
  }
}












         















class FlocPrint extends Sheet_Specialize {
  Simulation sim;
  FlocPrint(Simulation s) { super("Floc"); sim = s; }
  public FlocComu get_new(Macro_Sheet s, String n, sValueBloc b) { return new FlocComu(sim, n, b); }
}



class FlocComu extends Community {
  
  public void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = sim_front.addTab(name);
    tab.getShelf()
      .addDrawerDoubleButton(DRAWMODE_DEF, DRAWMODE_DEBUG, 10.25f, 1)
      .addSeparator(0.125f)
      .addDrawerTripleButton(point_to_mouse, point_to_center, point_to_cursor, 10, 1)
      .addSeparator(0.125f)
      .addDrawerDoubleButton(create_grower, null, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(POURSUITE, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(FOLLOW, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(SPACING, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(SPEED, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(LIMIT, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(AGE, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(HALO_SIZE, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(HALO_DENS, 2, 10, 1)
      .addSeparator(0.125f)
      .addDrawerFactValue(POINT_FORCE, 2, 10, 1)
      .addSeparator(0.125f)
      ;
  }
  
  public void selected_comu(Community c) { 
    if (c != null && c.type_value.get().equals("grow")) gcom = (GrowerComu)c;
  }
  
  sFlt POURSUITE, FOLLOW, SPACING, SPEED, HALO_SIZE, HALO_DENS, POINT_FORCE ;
  sInt LIMIT, AGE ;
  sBoo DRAWMODE_DEF, DRAWMODE_DEBUG, create_grower, point_to_mouse, point_to_center, point_to_cursor;
  
  sCol val_col_def, val_col_deb, val_col_halo;
  sFlt scale;
  
  int startbox = 400;
  
  GrowerComu gcom;
  
  FlocComu(Simulation _c, String n, sValueBloc b) { super(_c, n, "floc", 50, b); 
    POURSUITE = newFlt(0.3f, "POURSUITE", "poursuite");
    FOLLOW = newFlt(0.0036f, "FOLLOW", "follox");
    SPACING = newFlt(95, "SPACING", "space");
    SPEED = newFlt(2, "SPEED", "speed");
    LIMIT = newInt(1600, "limit", "limit");
    AGE = newInt(2000, "age", "age");
    HALO_SIZE = newFlt(80, "HALO_SIZE", "Size");
    HALO_DENS = newFlt(0.15f, "HALO_DENS", "Dens");
    POINT_FORCE = newFlt(0.01f, "POINT_FORCE", "point");
    
    DRAWMODE_DEF = newBoo(true, "DRAWMODE_DEF", "draw1");
    DRAWMODE_DEBUG = newBoo(false, "DRAWMODE_DEBUG", "draw2");
    
    create_grower = newBoo(true, "create_grower", "create grow");
    point_to_mouse = newBoo(false, "point_to_mouse", "to mouse");
    point_to_center = newBoo(false, "point_to_center", "to center");
    point_to_cursor = newBoo(false, "point_to_cursor", "to cursor");
    //init_canvas();
    
    val_col_def = menuColor(color(220), "val_col_def");
    val_col_deb = menuColor(color(255, 0, 0), "val_col_deb");
    val_col_halo = menuColor(color(255, 0, 0), "val_col_halo");
    scale = menuFltSlide(10, 5, 100, "length");
  }
  
  public void custom_pre_tick() {
    for (Entity e1 : list)
      for (Entity e2 : list)
        if (e1.id < e2.id && e1 != e2 && e1.active && e2.active)
            ((Floc)e1).pair(((Floc)e2));
          
  }
  public void custom_post_tick() {}
  public void custom_frame() {
    //can.drawHalo(this);
  }
  public void custom_cam_draw_post_entity() {}
  public void custom_cam_draw_pre_entity() {
    //can.drawCanvas();
  }
  
  public Floc build() { return new Floc(this); }
  public Floc addEntity() { return newEntity(); }
  public Floc newEntity() {
    for (Entity e : list) if (!e.active) { e.activate(); return (Floc)e; } return null; }
}

class Floc extends Entity {
  PVector pos = new PVector(0, 0);
  PVector mov = new PVector(0, 0);
  float speed = 0;
  
  float halo_size = 0;
  float halo_density = 0;
  
  int age = 0;
  int max_age = 2000;
  
  Floc(FlocComu c) { super(c); }
  
  public void draw_halo(Canvas canvas) {
    canvas.draw_halo(pos, halo_size, halo_density, com().val_col_halo.get());
  }
  
  public void headTo(PVector c, float s) {
    PVector l = new PVector(c.x, c.y);
    l.add(-pos.x, -pos.y);
    float r1 = mapToCircularValues(mov.heading(), l.heading(), s, -PI, PI);
    mov.x = speed; mov.y = 0;
    mov.rotate(r1);
  }
  public void headTo(float l, float s) {
    float r1 = mapToCircularValues(mov.heading(), l, s, -PI, PI);
    mov.x = speed; mov.y = 0;
    mov.rotate(r1);
  }
  
  public void pair(Floc b2) {
    float d = dist(pos.x, pos.y, b2.pos.x, b2.pos.y);
    if (d < com().SPACING.get()) {
      headTo(b2.mov.heading(), com().FOLLOW.get() / ((com().SPACING.get() - d) / com().SPACING.get()) );
      b2.headTo(mov.heading(), com().FOLLOW.get() / ((com().SPACING.get() - d) / com().SPACING.get()) );
    } else {
      headTo(b2.pos, com().POURSUITE.get() / d);
      b2.headTo(pos, com().POURSUITE.get() / d);
    }
  }
  
  public Floc init() {
    age = 0;
    max_age = PApplet.parseInt(random(0.5f, 1) * com().AGE.get());
    halo_size = com().HALO_SIZE.get();
    halo_density = com().HALO_DENS.get();
    halo_size += random(com().HALO_SIZE.get());
    halo_density += random(com().HALO_DENS.get());
    pos = com().adding_cursor.pos();
    //pos.x = random(-com().startbox, com().startbox);
    //pos.y = random(-com().startbox, com().startbox);
    speed = random(0.5f, 1) * com().SPEED.get();
    mov.x = speed; mov.y = 0;
    mov.rotate(random(PI * 2.0f));
    return this;
  }
  public Floc frame() { return this; }
  public Floc tick() {
    age++;
    if (age > max_age) {
      if (com().create_grower.get() && com().gcom != null) {
        Grower ng = com().gcom.newEntity();
        if (ng != null) ng.define(new PVector(pos.x, pos.y), new PVector(1, 0).rotate(mov.heading()));
      }
      destroy();
    }
    //point toward mouse
    if (com().point_to_mouse.get()) headTo(com().sim.inter.cam.screen_to_cam(new PVector(mouseX, mouseY)), 
                                           com().POINT_FORCE.get());
    //point toward center
    if (com().point_to_center.get()) headTo(new PVector(0, 0), com().POINT_FORCE.get());
    //point toward cursor
    if (com().point_to_cursor.get()) headTo(com().adding_cursor.pos(), com().POINT_FORCE.get());
    pos.add(mov);
    return this;
  }
  public Floc draw() {
    fill(com().val_col_def.get());
    stroke(com().val_col_def.get());
    strokeWeight(4/com.sim.cam_gui.scale);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(mov.heading());
    if (com().DRAWMODE_DEF.get()) {
      line(0, 0, -com().scale.get(), -com().scale.get());
      line(2, 0, -com().scale.get(), 0);
      line(0, 0, -com().scale.get(), com().scale.get());
    }
    fill(com().val_col_deb.get());
    //stroke(com().val_col_deb.get());
    noStroke();
    float t = (com().scale.get() * (com().ref_size / 10)) / (com.sim.cam_gui.scale * 6);
    if (com().DRAWMODE_DEBUG.get()) ellipse(0, 0, t, t);
    popMatrix();
    return this;
  }
  public Floc clear() { return this; }
  public FlocComu com() { return ((FlocComu)com); }
}



//#######################################################################
//##          ROTATING TO ANGLE CIBLE BY SHORTEST DIRECTION            ##
//#######################################################################


public float mapToCircularValues(float current, float cible, float increment, float start, float stop) {
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

















//class BoxPrint extends Blueprint {
//  BoxPrint(Simulation s) { super(s, "Box", "box"); }
//  BoxComu build(String n, String t) { return new BoxComu(sim, n, t); }
//}




//class BoxComu extends Community {
  
//  void comPanelBuild(nFrontPanel sim_front) {
//    nFrontTab tab = sim_front.addTab(name);
//    tab.getShelf()
//      .addDrawerFactValue(spacing_min, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_max, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_diff, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_max_dist, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(box_size_min, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(box_size_max, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(duplicate_prob, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(corner_space, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(max_age, 2, 10, 1)
//      .addSeparator(0.125)
//      ;
//  }
  
//  sFlt spacing_min , spacing_max, spacing_diff, spacing_max_dist, box_size_min, 
//    box_size_max, duplicate_prob, corner_space;
  
//  sInt max_age;
  
//  //sBoo draw_circle = new sBoo(simval, false);
  
//  int cnt = 0;
//  FlocComu fcom;
//  BoxComu(Simulation _c, String n, String t) { super(_c, n, t, 0);
//    spacing_min = new sFlt(value_bloc, 50, "box_spacing_min", "sp min");
//    spacing_max = new sFlt(value_bloc, 200, "box_spacing_max", "sp max");
//    spacing_diff = new sFlt(value_bloc, 1, "box_spacing_diff", "sp dif");
//    spacing_max_dist = new sFlt(value_bloc, 10000, "normal_spacing_dist", "norm sp");
//    box_size_min = new sFlt(value_bloc, 100, "box_size_min", "sz min");
//    box_size_max = new sFlt(value_bloc, 400, "box_size_max", "sz max");
//    duplicate_prob = new sFlt(value_bloc, 5.0, "duplicate_prob", "duplic");
//    corner_space = new sFlt(value_bloc, 40, "box_corner_space", "corner");
//    max_age = new sInt(value_bloc, 2000, "max_age", "age");
    
    
//  }
//  void custom_pre_tick() {}
//  void custom_build() {}
  
  
//  void custom_post_tick() { 
//    cnt+=2;
//    if (cnt > 2400) cnt -= 2400;
//  }
//  void custom_cam_draw_pre_entity() {}
//  void custom_reset() { cnt = 0; }
//  void custom_cam_draw_post_entity() { 
//    //float r = spacing_max_dist.get();  
//    //noFill();
//    //stroke(255);
//    ////ellipse(0, 0, r, r);
    
//  }//
  
//  Box build() { return new Box(this); }
//  Box addEntity() { return newEntity(); }
//  Box newEntity() { 
//    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
//}


//class Box extends Entity {
//  Rect rect = new Rect();
//  Box origin;
//  int generation = 1;
//  PVector connect1 = new PVector(0, 0);
//  PVector connect2 = new PVector(0, 0);
//  PVector origin_co = new PVector(0, 0); //origin box to ext co
//  float space = 0;
//  int age = 0;
  
//  Box(BoxComu c) { super(c); }
  
//  //void draw_halo(Canvas canvas, PImage i) {}
  
//  void pair(Box b2) {}
  
//  Box init() {
//    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
//    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
//    rect.pos.x = -rect.size.x/2; rect.pos.y = -rect.size.y/2;
//    connect1.x = rect.pos.x; connect1.y = rect.pos.y;
//    connect2.x = rect.pos.x; connect2.y = rect.pos.y;
//    origin = null;
//    origin_co.x = 0;
//    origin_co.y = 0;
//    generation = 1;
//    space = com().spacing_min.get();
//    rotation = -0.008;
//    col = 0;
//    age = 0;
//    return this;
//  }
//  void define_bis(Box b2, float x, float y, String dir) {
//    rect.pos.x = x; rect.pos.y = y;
//    for (Entity e : com().list) if (e.active) {
//      Box b = (Box)e;
//      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
//        this.destroy(); return; } }
//    origin = b2;
//    generation = b2.generation + 1;
//    float corner_space = com().corner_space.get();
//    if (dir.charAt(0) == 'v') {
//      if (dir.charAt(1) == 'u') {
//        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
//        connect1.y = rect.pos.y + rect.size.y;
//        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
//        connect2.y = b2.rect.pos.y;
//      } else {
//        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
//        connect1.y = rect.pos.y;
//        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
//        connect2.y = b2.rect.pos.y + b2.rect.size.y;
//      }
//    } else {
//      if (dir.charAt(1) == 'l') {
//        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
//        connect1.x = rect.pos.x + rect.size.x;
//        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
//        connect2.x = b2.rect.pos.x;
//      } else {
//        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
//        connect1.x = rect.pos.x;
//        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
//        connect2.x = b2.rect.pos.x + b2.rect.size.x;
//      }
//    }
//    origin_co.x = connect2.x - origin.rect.pos.x;
//    origin_co.y = connect2.y - origin.rect.pos.y; //origin box to ext co
//    //PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    
//    rotation = 0;//.008 * (6000 - connect_line.mag()) / 6000;
//    //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
//    //connect_line.rotate(rotation + burst);
//    //connect1.x = connect_line.x + connect2.x;
//    //connect1.y = connect_line.y + connect2.y;
//    //rect.pos.x = box_local.x + connect1.x;
//    //rect.pos.y = box_local.y + connect1.y;
//  }
  
//  Box define(Box b2) {
//    space = com().spacing_min.get() + 
//            ( 2 * com().spacing_max.get() * min(1, b2.rect.pos.mag()
//            / com().spacing_max_dist.get()) ) * crandom(com().spacing_diff.get());
//    //space = crandom( com().spacing_min.get(), 
//    //                 com().spacing_max.get(), 
//    //                 ( min(0, com().spacing_max_dist.get() - b2.rect.pos.mag()) / com().spacing_max_dist.get()) * com().spacing_diff.get() );
//    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
//    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
//    boolean axe = random(10) < 5;
//    float dir_mod = 0;
//    if (axe && b2.rect.pos.y > 0) dir_mod = -2.5;
//    if (axe && b2.rect.pos.y < 0) dir_mod = 2.5;
//    if (!axe && b2.rect.pos.x > 0) dir_mod = -2.5;
//    if (!axe && b2.rect.pos.x < 0) dir_mod = 2.5;
//    boolean side = random(10) < 5 + dir_mod;
//    if (axe) {
//      if (side) {
//        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space), 
//                       b2.rect.pos.y - (rect.size.y + space), "vu"); }
//      else {
//        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space),
//                       b2.rect.pos.y + b2.rect.size.y + space, "vd"); } }
//    else {
//      if (side) {  
//        define_bis(b2, b2.rect.pos.x - (rect.size.x + space),
//                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hl"); }
//      else {                 
//        define_bis(b2, b2.rect.pos.x + b2.rect.size.x + space,
//                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hr"); } }
//    return this;
//  }
  
//  float rotation = -0.008;
//  int col = 0;
//  float burst = 0;
//  boolean blocked = false;
  
//  Box frame() { return this; }
//  Box tick() {
//    age++;
//    if (age > com().max_age.get()) this.destroy();
    
//    if (com().fcom != null) for (Entity e : com().fcom.list) if (e.active) {
//      Floc f = (Floc)e;
//      if (rectCollide(f.pos, rect)) {
//        this.destroy();
//      }
//    }
    
//    if (random(100) < com().duplicate_prob.get()) {
//      Box nb = com().newEntity();
//      if (nb != null) {
//        nb.define(this); } }
    
//    float rspeed = 0.008 / generation;
//    int pcol = col;
//    col = 0;
//    for (Entity e : com().list) if (e.active) {
//      Box b = (Box)e;
//      //if (col >= 1) { rotation = 0; }
//      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
//        //if (col > 0 && !blocked) rotation *= 1.01;
//        if (col == 0 && !blocked) rotation *= -1;
//        col += 1;
//        //if (col == 0 && abs(rotation) > rspeed*2) rotation = 0;
//      } }
//    //if (blocked) rotation -= 0.00001;
//    //if (abs(rotation) > rspeed*2) { blocked = true; burst = 0.1; if (rotation < 0) burst *= -1; rotation = 0;  }
//    //if (col == 0 && abs(rotation) > rspeed) rotation /= 1.01;
//    if (pcol == 0) blocked = false;
//    //if (blocked && rotation == 0) rotation = rspeed;
//    //println(com().comList.tick.get() + " " + col + " " + rotation);
    
//    PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
//    if (origin != null && origin.active) {
//      //connect2.x = origin.rect.pos.x + origin_co.x;
//      //connect2.y = origin.rect.pos.y + origin_co.y;
//      //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
//      ////connect_line.rotate(rotation + burst);
//      //connect1.x = connect_line.x + connect2.x;
//      //connect1.y = connect_line.y + connect2.y;
//      //rect.pos.x = box_local.x + connect1.x;
//      //rect.pos.y = box_local.y + connect1.y;
      
//      //burst /= 1.01;
//    }
//    return this; }
  
//  Box draw() {
//    float connect_bubble_size = com().corner_space.get();
    
    
//    float rd = 255.0 * (float)((10.0 - float(abs(generation - int(com().cnt/60.0)))) / 10.0);
//    float stroke_limit = 1;
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+1200)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-1200)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+2400)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-2400)/60.0)))) / 10.0);
//    //if (abs(generation - int(com().cnt/60)) < 10) 
//    color filling = color(40, max(100, int(rd-20)), 0);
//    float fc = max( 150, 255 - max(0, int(rd)) ) / 255.0;
//    color lining = color(100*fc, 255*fc, 100*fc);
//    //println(lining);
//    noFill();
//    stroke(lining);
//    strokeWeight(max(2/com.sim.cam_gui.scale, connect_bubble_size/1.3));
//    line(connect1.x, connect1.y, connect2.x, connect2.y);
//    if (connect_bubble_size*com.sim.cam_gui.scale > 3) {
//      fill(filling);
//      stroke(lining);
//      strokeWeight(4/com.sim.cam_gui.scale);
//      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
//      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
//    fill(filling);
//    stroke(lining);
//    strokeWeight(2/com.sim.cam_gui.scale);
//    rect.draw();
//    noFill();
//    stroke(0, 255, 0);
//    strokeWeight(3/com.sim.cam_gui.scale);
//    //rect(rect.pos.x - space/2, rect.pos.y - space/2, rect.size.x + space, rect.size.y + space);
//    if (connect_bubble_size*com.sim.cam_gui.scale > 3) {
//      fill(filling);
//      noStroke();
//      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
//      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
//    noFill();
//    stroke(filling);
//    strokeWeight(max(0, connect_bubble_size/1.3 - 4/com.sim.cam_gui.scale));
//    line(connect1.x, connect1.y, connect2.x, connect2.y);
//    int point_size = 16;
//    int c = 0;
//    strokeWeight(point_size);
//    for (float i = rect.pos.x + (rect.size.x%point_size)/2 + point_size/2; i < rect.pos.x + rect.size.x ; i += point_size) 
//      for (float j = rect.pos.y + (rect.size.y%point_size)/2 + point_size/2; j < rect.pos.y + rect.size.y ; j += point_size) {
//        stroke(0, 255, 0, c);
//        point(i, j);
//        c+=(generation*point_size);
//        if (c > 255) c -= 255;
//      }
//    fill(lining);
//    textFont(getFont(int(rect.size.y/3)));
//    text(""+generation, rect.pos.x + rect.size.x/3, rect.pos.y + rect.size.y/1.41);
//    return this; }
//  Box clear() { return this; }
//  BoxComu com() { return ((BoxComu)com); }
//}










   

/*                          RENAME IT " TIME "

 Simulation(Input, Data, Interface)
 Build with interface
 toolPanel down left to down center with main function
 right
 next tick,  pause,  next frame
 tick/frame            5 widget
 time counter,     tick counter
 framerate,            tickrate
 
 down left
 Hide all
 
 left
 open menus      <align to panel top
 title
 Quick save, load
 restart,    RNG
 
 time control (tick by frame, pause, trigger tick by tick or frame by frame)
 restart control and RNG
 Quick save / load
 button to hide all guis (toolpanel reducted)
 Openning main dropdown menu to open main panels
 file selection panel
 communitys panel
 open save / load parameters panel
 basic info n param
 completed by each community type
 shortcut panel
 can link key to preselected button
 taskBar on down right side
 SelectZone working in camera
 Info
 TickPile
 one Drawer for all communitys in camera drawerpile
 simpler before more coding
 community
 has an adding point as an svalue and grabbable
 grower as also an adding direction
 floc an adding radius
 Entity
 position, direction, size
 custom parameters
 list of geometrical shapes and colors
 shapes contain energy???                            <<<<<< THE GAME MECHANIC MAKE HER ENTRY
 to excenge energy throug macro link output need a received method called by receiving input to
 confirm transfer 
 screen width 1200
 draw : invisible, particle 1px, pebble 5px, small 25px, med 100px, 
 big 400px, fullscreen 1100px, zoom in 3000px, micro 10 000px, too big 100 000px
 frame()
 drive ticking
 macro_main
 each community have her sheet inside whom community param and runnable can be acsessed
 maybe for each community her is an independent macro space who can acsess an entity
 property and who can be applyed to each entity of this commu
 there can be plane who take entity from different commu to make them interact
 */

class SimPrint extends Sheet_Specialize {
  SimPrint() { super("Sim"); }
  public Simulation get_new(Macro_Sheet s, String n, sValueBloc b) { return new Simulation(mmain.inter, b); }
}

class Simulation extends Macro_Sheet {
  
  public Simulation clear() {
    for (int i = list.size() - 1 ; i >= 0 ; i--) list.get(i).clear();
    super.clear();
    return this;
  }
  
  Simulation(sInterface _int, sValueBloc b) {
    super(_int.macro_main, "Sim", b);
    inter = _int;
    ref_size = inter.ref_size;
    cam_gui = inter.cam_gui;
    
    //setPosition(0, -ref_size*8);
    val_descr.set("Control time, reset, random...");
    tick_counter = newInt(0, "tick_counter", "tick");
    tick_by_frame = newFlt(2, "tick by frame", "tck/frm");
    pause = newBoo(false, "pause", "pause");
    force_next_tick = newInt(0, "force_next_tick", "nxt tick");
    auto_reset = newBoo(true, "auto_reset", "auto reset");
    auto_reset_rng_seed = newBoo(true, "auto_reset_rng_seed", "auto rng");
    auto_reset_screenshot = newBoo(false, "auto_rest_screenshot", "auto shot");
    show_com = newBoo(false, "show_com", "show");
    auto_reset_turn = newInt(4000, "auto_reset_turn", "auto turn");
    SEED = newInt(548651008, "SEED", "SEED");

    inter.addEventFrame(new Runnable() { public void run() { frame(); } } );
    inter.addToCamDrawerPile(new Drawable() { 
      public void drawing() { draw_to_cam(); } } );
    inter.addToScreenDrawerPile(new Drawable() { 
      public void drawing() { draw_to_screen(); } } );
    
    srun_tick = newRun("sim_tick", "tick", new Runnable() { public void run() { } } );
    srun_reset = newRun("sim_reset", "reset", new Runnable() { 
      public void run() { reset(); } } );
    srun_rngr = newRun("sim_rng_reset", "rst rng", new Runnable() { 
      public void run() { resetRng(); } } );
    srun_nxtt = newRun("sim_next_tick", "nxt tck", new Runnable() { 
      public void run() { force_next_tick.add(1); } } );
    srun_nxtf = newRun("sim_next_frame", "nxt frm", new Runnable() { 
      public void run() { force_next_tick.set(PApplet.parseInt(tick_by_frame.get())); } } );
    
    addEventSetupLoad(new Runnable() { 
      public void run() { reset(); } } );
      
    show_toolpanel = newBoo("show_toolpanel", "toolpanel", true);
    show_toolpanel.addEventChange(new Runnable(this) { public void run() { 
      if (toolpanel != null && toolpanel.hide == show_toolpanel.get()) toolpanel.reduc();
    }});
    
    //build_toolpanel();
    
  }

  sInt tick_counter; //conteur de tour depuis le dernier reset ou le debut
  sBoo pause; //permet d'interompre le defilement des tour
  sInt force_next_tick; 
  sFlt tick_by_frame; //nombre de tour a executé par frame
  sInt SEED; //seed pour l'aleatoire
  sBoo auto_reset, auto_reset_rng_seed, auto_reset_screenshot, show_com;
  sInt auto_reset_turn;
  sRun srun_reset, srun_rngr, srun_nxtt, srun_nxtf, srun_tick;
  sBoo show_toolpanel;

  float tick_pile = 0; //pile des tick a exec

  ArrayList<Runnable> eventsReset = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsUnpausedFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsTick = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsTick2 = new ArrayList<Runnable>();
  public Simulation addEventReset(Runnable r) { eventsReset.add(r); return this; }
  public Simulation removeEventReset(Runnable r) { eventsReset.remove(r); return this; }
  public Simulation addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  public Simulation addEventUnpausedFrame(Runnable r) { eventsUnpausedFrame.add(r); return this; }
  public Simulation addEventTick(Runnable r) { eventsTick.add(r); return this; }
  public Simulation removeEventTick(Runnable r) { eventsTick.remove(r); return this; }
  public Simulation addEventTick2(Runnable r) { eventsTick2.add(r); return this; }
  public Simulation removeEventTick2(Runnable r) { eventsTick2.remove(r); return this; }

  public void resetRng() { 
    SEED.set(PApplet.parseInt(random(1000000000))); 
    reset();
  }
  public void reset() {
    randomSeed(SEED.get());
    tick_counter.set(0);
    inter.framerate.reset();
    for (Community c : list) c.reset();
    runEvents(eventsReset);
  }

  public void frame() {
    if (!pause.get()) {
      tick_pile += tick_by_frame.get();

      //auto screenshot before reset
      if (auto_reset.get() && auto_reset_screenshot.get() &&
        auto_reset_turn.get() == tick_counter.get() + tick_by_frame.get() + tick_by_frame.get()) {
        inter.cam.screenshot = true;
      }

      while (tick_pile >= 1) {
        tick();
        tick_pile--;
      }

      //run_each_unpaused_frame
      runEvents(eventsUnpausedFrame);
    }

    // tick by tick control
    if (pause.get() && force_next_tick.get() > 0) { 
      for (int i = 0; i < force_next_tick.get(); i++) tick(); 
      force_next_tick.set(0);
    }
    if (!pause.get() && force_next_tick.get() > 0) { 
      force_next_tick.set(0);
    }

    //run custom frame methods
    for (Community c : list) c.frame();
    runEvents(eventsFrame);
  }

  public void tick() {

    //auto reset
    if (auto_reset.get() && auto_reset_turn.get() <= tick_counter.get()) {
      if (auto_reset_rng_seed.get()) {
        SEED.set(PApplet.parseInt(random(1000000000)));
      }
      reset();
    }

    //ticking_pile.tick();
    srun_tick.run();

    //tick communitys
    for (Community c : list) c.tick();

    //tick call
    runEvents(eventsTick);
    runEvents(eventsTick2);

    tick_counter.set(tick_counter.get()+1);
  }

  public void draw_to_cam() { 
    if (show_com.get()) {
      for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_pre_entity();
      for (Community c : list) if (c.show_entity.get()) c.draw_Cam();
      for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_post_entity();
    }
  }
  public void draw_to_screen() { 
    for (Community c : list) if (c.show_entity.get()) c.draw_Screen();
  }
  
  nToolPanel toolpanel;
  
  //void build_toolpanel() {
  //  toolpanel = new nToolPanel(inter.screen_gui, ref_size, 0.125, false, false);
  //  toolpanel.addShelf()
  //    .addDrawer(10, 0.75)
  //    .addModel("Label-S4", "-  GROWERS  -").setFont(int(ref_size)).getShelf()
  //    .addSeparator(0.25)
  //    .addDrawer(10, 1)
  //    .addCtrlModel("Button-S3-P1", "RESET")
  //    .setRunnable(new Runnable() {  public void run() {  reset(); } } ).getDrawer()
  //    .addCtrlModel("Button-S3-P2", "RESET RNG")
  //    .setRunnable(new Runnable() { public void run() {  resetRng(); } } )
  //    .getShelf()
  //    .addDrawer(10, 1)
  //    .addCtrlModel("Button-S3-P1", "Quick Save")
  //    .setRunnable(new Runnable() { 
  //    public void run() { 
  //      inter.full_data_save();
  //    }
  //  }
  //  ).getDrawer()
  //    .addCtrlModel("Button-S3-P2", "Quick Load")
  //    .setRunnable(new Runnable() { 
  //    public void run() { 
  //      inter.setup_load();
  //    }
  //  }
  //  ).getDrawer().getShelf()
  //    .addDrawer(10, 1)
  //    .addLinkedModel("Button-S3-P1", "grid")
  //    .setLinkedValue(inter.cam.grid).getDrawer()
  //    .addLinkedModel("Button-S3-P2", "auto load")
  //    .setLinkedValue(inter.auto_load).getDrawer()
  //    .getShelfPanel()
  //    .addShelf()
  //    .addDrawer(10, 1)
  //    .addCtrlModel("Button-S2-P1", "tick").setRunnable(new Runnable() { 
  //    public void run() { 
  //      force_next_tick.set(1);
  //    }
  //  }
  //  ).getDrawer()
  //    .addLinkedModel("Button-S2-P2", "PAUSE").setLinkedValue(pause).getDrawer()
  //    .addCtrlModel("Button-S2-P3", "frame").setRunnable(new Runnable() { 
  //    public void run() { 
  //      force_next_tick.set(int(tick_by_frame.get()));
  //    }
  //  }
  //  ).getShelf()
  //    .addDrawer(10, 1)
  //    .addCtrlModel("Button-S1-P2", "<<").setLinkedValue(tick_by_frame).setFactor(0.5).getDrawer()
  //    .addCtrlModel("Button-S1-P3", "<").setLinkedValue(tick_by_frame).setFactor(0.8).getDrawer()
  //    .addWatcherModel("Label_Back-S2-P2", "--").setLinkedValue(tick_by_frame).getDrawer()
  //    .addCtrlModel("Button-S1-P7", ">").setLinkedValue(tick_by_frame).setFactor(1.25).getDrawer()
  //    .addCtrlModel("Button-S1-P8", ">>").setLinkedValue(tick_by_frame).setFactor(2).getShelf()
  //    .addDrawer(10, 1)
  //    .addCtrlModel("Button-S3-P1", "Sim").setRunnable(new Runnable() { public void run() { 
  //      build_sheet_menu(); } } )
  //    .getDrawer()
  //    .addCtrlModel("Button-S3-P2", "Files").setRunnable(new Runnable() { public void run() { 
  //      inter.filesManagement(); } } ).getShelf()
  //    .addDrawer(10, 1)
  //    .addWatcherModel("Label_Back-S3-P1")
  //    .setLinkedValue(inter.framerate.median_framerate).getDrawer()
  //    .addWatcherModel("Label_Back-S3-P2").setLinkedValue(tick_counter).getDrawer()
  //    .addLinkedModel("Button-S1-P9", "S")
  //    .setLinkedValue(show_com)
  //    .getShelfPanel()
  //    ;
    
  //  inter.screen_gui.addEventSetup(new Runnable() { 
  //    public void run() { 
  //      //for (Blueprint c : com_blueprint) c.simPanelBuild(sim_front);

  //      //if (list.size() > 0) {
  //      //  update_com_selector_list();
  //      //}
  //      //build_sim_frontpanel(inter.screen_gui);
  //    }
  //  } 
  //  );  
    
  //  if (!show_toolpanel.get()) toolpanel.reduc();
  //  toolpanel.addEventReduc(new Runnable() { public void run() { 
  //    show_toolpanel.set(!toolpanel.hide); }});
  //}
  
  public void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Base");

      tab.getShelf()
        .addDrawer(10.25f, 0.6f)
        .addModel("Label-S4", "- Simulation Control -").setFont(PApplet.parseInt(ref_size/1.4f)).getShelf()
        .addSeparator(0.125f)
        .addDrawerWatch(tick_counter, 10, 1)
        .addSeparator(0.125f)
        .addDrawerLargeFieldCtrl(SEED, 10, 1)
        .addSeparator(0.125f)
        .addDrawerFactValue(tick_by_frame, 2, 10, 1)
        .addSeparator(0.125f)
        .addDrawerIncrValue(auto_reset_turn, 1000, 10, 1)
        .addSeparator(0.125f)
        .addDrawerTripleButton(auto_reset, auto_reset_rng_seed, auto_reset_screenshot, 10, 1)
        .addSeparator(0.125f)
        .addDrawerTripleButton(srun_reset, srun_rngr, srun_nxtt, 10, 1)
        .addSeparator(0.125f)
        .addDrawerTripleButton(pause, show_com, inter.cam.grid, 10, 1)
        .addSeparator(0.125f)
        ;
      
      tab.getShelf(0).addSeparator(0.25f)
        .addDrawer(10.25f, 0.75f)
        .addModel("Label-SS4", "- Active Community -").setFont(PApplet.parseInt(ref_size/1.5f)).getShelf()
        ;
        
      selector_list = tab.getShelf(0)
        .addSeparator(0.25f)
        .addList(5, 10, 1);
      selector_list.addEventChange_Builder(new Runnable() { public void run() {
        nList sl = ((nList)builder); 
        if (sl.last_choice_index < list.size()) 
          list.get(sl.last_choice_index).build_sheet_menu();
      } } );
      
      selector_list.getShelf()
        .addSeparator(0.0625f)
        ;
      
      selector_entry = new ArrayList<String>(); // mmain().data.getCountOfType("flt")
      selector_value = new ArrayList<Community>(); // mmain().data.getCountOfType("flt")
    
      update_com_selector_list();
  }
  public void update_com_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (Community v : list) { 
      selector_entry.add(v.name); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }

  ArrayList<String> selector_entry;
  ArrayList<Community> selector_value;
  Community selected_value;
  String selected_entry;
  nList selector_list;

  sInterface inter;
  sValueBloc sbloc;
  nGUI cam_gui;
  float ref_size;
  Ticking_pile ticking_pile;
  Tickable macromain_tickable;

  ArrayList<Community> list = new ArrayList<Community>();
  
}


abstract class Community extends Macro_Sheet {
  
  public Community clear() {
    sim.list.remove(this);
    adding_cursor.clear();
    super.clear();
    return this;
  }

  public abstract void comPanelBuild(nFrontPanel front);
  
  public void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Community");
    tab.getShelf()
      .addDrawer(10.25f, 0.75f)
      .addModel("Label-S4", "-"+name+" Control-").setFont(PApplet.parseInt(ref_size/1.4f)).getShelf()
      .addSeparator(0.125f)
      .addDrawerWatch(active_entity, 10, 1)
      .addSeparator(0.125f)
      .addDrawerIncrValue(max_entity, 100, 10, 1)
      .addSeparator(0.125f)
      .addDrawerIncrValue(adding_entity_nb, 10, 10, 1)
      .addSeparator(0.125f)
      .addDrawerIncrValue(adding_step, 10, 10, 1)
      .addSeparator(0.125f)
      .addDrawerDoubleButton(show_entity, srun_add, 10, 1)
      .addSeparator(0.125f)
      .addDrawerDoubleButton(pulse_add, adding_cursor.show, 10, 1)
      .addSeparator(0.125f)
      .addDrawerIncrValue(pulse_add_delay, 10, 10, 1)
      .addSeparator(0.125f)
      ;
      
    selector_list = tab.getShelf(0)
      .addSeparator(0.25f)
      .addList(4, 10, 1);
    selector_list.addEventChange_Builder(new Runnable() { public void run() {
      nList sl = ((nList)builder); 
      //logln("a "+sl.last_choice_index +"  "+ sim.list.size());
      if (sl.last_choice_index < sim.list.size()) 
        selected_comu(sim.list.get(sl.last_choice_index));
        selected_com.set(sim.list.get(sl.last_choice_index).name);
    } } );
        
    selector_list.getShelf()
      .addSeparator(0.125f)
      .addDrawer(10.25f, 0.75f)
      .addWatcherModel("Label-S4", "Selected: ").setLinkedValue(selected_com).getShelf()
      .addSeparator(0.125f)
      ;
    
    selector_entry = new ArrayList<String>(); // mmain().data.getCountOfType("flt")
    selector_value = new ArrayList<Community>(); // mmain().data.getCountOfType("flt")
    
    update_com_selector_list();
    
    comPanelBuild(sheet_front);
  }
  public void update_com_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (Community v : sim.list) { 
      selector_entry.add(v.name); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }
  
  public void selected_comu(Community c) {}

  ArrayList<String> selector_entry;
  ArrayList<Community> selector_value;
  Community selected_value;
  String selected_entry;
  nList selector_list;


  Simulation sim;
  String name = "";
  String type;

  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet

  sInt max_entity; //longueur max de l'array d'objet
  sInt active_entity, adding_entity_nb, adding_step; // add one new object each adding_step turn
  int adding_pile = 0;
  int adding_counter = 0;
  
  sInt pulse_add_delay;
  sBoo pulse_add;
  int pulse_add_counter = 0;

  sBoo show_entity;
  sRun srun_add;
  sStr type_value, selected_com;

  nCursor adding_cursor;
  
  Community(Simulation _c, String n, String ty, int max, sValueBloc b) { 
    super(_c.inter.macro_main, n, b);
    sim = _c; 
    name = value_bloc.ref;
    sim.list.add(this);
    type = ty;
    
    max_entity = newInt(max, "max_entity", "max_entity");
    type_value = newStr("type", "type", ty);
    selected_com = newStr("selected_com", "scom", "");
    active_entity = newInt(0, "active_entity ", "active_pop");
    adding_entity_nb = newInt(0, "adding_entity_nb ", "add nb");
    adding_step = newInt(0, "adding_step ", "add stp");
    show_entity = newBoo(true, "show_entity ", "show");
    pulse_add = newBoo(true, "pulse_add ", "pulse");
    pulse_add_delay = newInt(100, "pulse_add_delay ", "pulseT");

    adding_cursor = new nCursor(sim.cam_gui, this, n, "add");

    srun_add = newRun("add_entity", "add_pop", new Runnable() { 
      public void run() { 
        adding_pile += adding_entity_nb.get();
      }
    }
    );
    
    
    addEventSetupLoad(new Runnable() { public void run() { 
      sim.inter.addEventNextFrame(new Runnable() {public void run() { 
        for (Community c : sim.list) if (c.name.equals(selected_com.get())) selected_comu(c);
      }}); } } );
    

    reset();
  }

  public Community show_entity() { 
    show_entity.set(true); 
    return this;
  }
  public Community hide_entity() { 
    show_entity.set(false); 
    return this;
  }

  public void custom_reset() {
  }
  public void custom_frame() {
  }
  public abstract void custom_pre_tick();
  public abstract void custom_post_tick();
  public abstract void custom_cam_draw_pre_entity();
  public abstract void custom_cam_draw_post_entity();
  public void custom_screen_draw() {
  }

  public void init_array() {
    list.clear();
    for (int i = 0; i < max_entity.get(); i++)
      list.add(build());
  }

  public void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (max_entity.get() != list.size()) init_array();
    adding_pile += adding_entity_nb.get();
    custom_reset();
  }

  public void frame() {
    custom_frame();
    for (Entity e : list) if (e.active) e.frame();
  }

  public void tick() {
    if (pulse_add.get()) {
      pulse_add_counter++;
      if (pulse_add_counter > pulse_add_delay.get()) { pulse_add_counter = 0; srun_add.run(); }
    }
    if (adding_counter > 0) adding_counter--;
    while (adding_counter == 0 && adding_pile > 0) {
      adding_counter += adding_step.get();
      adding_pile--;
      addEntity();
    }
    active_entity.set(active_Entity_Nb());
    custom_pre_tick();
    for (Entity e : list) if (e.active) e.tick();
    for (Entity e : list) if (e.active) e.age++;
    custom_post_tick();
  }

  public void draw_Cam() { 
    for (Entity e : list) if (e.active) e.draw();
  }
  public void draw_Screen() { 
    custom_screen_draw();
  }

  public void destroy_All() { 
    for (Entity e : list) e.destroy();
  }

  public int active_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n;
  }

  public abstract Entity build();
  public abstract Entity addEntity();
}






abstract class Entity { 
  Community com;
  int age = 0, id;
  boolean active = false;
  Entity(Community c) { 
    com = c; 
    id = com.list.size();
  }
  public Entity activate() {
    if (!active) { 
      active = true; 
      age = 0; 
      init();
    }
    return this;
  }
  public Entity destroy() {
    if (active) { 
      active = false; 
      clear();
    }
    return this;
  }
  public abstract Entity tick();     //exec by community 
  public abstract Entity frame();    //exec by community 
  public abstract Entity draw();    //exec by community 
  public abstract Entity init();     //exec by activate and community.reset
  public abstract Entity clear();    //exec by destroy
}


/*

Global GUI Theme 
 can be picked from by widgets 
 ? list of widgets to update when is changed ?
 map of color and name
 map of size and name
 map<name, widget> models
 methods to directly build a widget from models
 
 


*/



//conteneur de presets
class nTheme {
  float ref_size = 30;
  nTheme(float s) { ref_size = s; new nConstructor(this, s); }
  HashMap<String, nWidget> models = new HashMap<String, nWidget>();
  public nTheme addModel(String r, nWidget w) { models.put(r,w); return this; }
  public nWidget getModel(String r) {  return models.get(r); }
  public nLook getLook(String r) { return models.get(r).look; }
  public nWidget newWidget(String r) { //only for theme model making !!
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget().copy(m); }
    return null; }
  public nWidget newWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget(g).copy(m); }
    return null; }
  public nLinkedWidget newLinkedWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nLinkedWidget lw = new nLinkedWidget(g); lw.copy(m); return lw; }
    return null; }
  public nWatcherWidget newWatcherWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nWatcherWidget lw = new nWatcherWidget(g); lw.copy(m); return lw; }
    return null; }
  public nCtrlWidget newCtrlWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nCtrlWidget lw = new nCtrlWidget(g); lw.copy(m); return lw; }
    return null; }
}






//drawing point
class nGUI {
  
  public nGUI setMouse(PVector v) { mouseVector = v; return this; }
  public nGUI setpMouse(PVector v) { pmouseVector = v; return this; }
  public nGUI setView(Rect v) { view = v; scale = width / view.size.x; return this; }
  public nGUI updateView() { scale = width / view.size.x; return this; }
  public nGUI setTheme(nTheme v) { theme = v; return this; }
  public nGUI addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  public nGUI addEventFound(Runnable r) { hoverable_pile.addEventFound(r); return this; }
  public nGUI addEventNotFound(Runnable r) { hoverable_pile.addEventNotFound(r); return this; }
  public nGUI addEventSetup(Runnable r) {  eventsSetup.add(r);  return this; }
  
  nGUI(sInput _i, nTheme _t, float _ref_size) {
    in = _i; theme = _t; if (theme == null) theme = new nTheme(_ref_size);
    mouseVector = in.mouse; pmouseVector = in.pmouse;
    ref_size = _ref_size;
    view = new Rect(0, 0, width, height);
    info = new nInfo(this, ref_size*0.75f);
  }
  
  sInput in;
  nTheme theme;
  nInfo info;
  Rect view;
  float scale = 1;
  float ref_size = 30;
  boolean isShown = true;
  
  Drawing_pile drawing_pile = new Drawing_pile();
  Hoverable_pile hoverable_pile = new Hoverable_pile();
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsSetup = new ArrayList<Runnable>();
  boolean is_starting = true;
  PVector mouseVector = null, pmouseVector = null;
  boolean hoverpile_passif = false;
  
  public void frame() {
    hoverable_pile.search(mouseVector, hoverpile_passif);
    if (is_starting) { is_starting = false; runEvents(eventsSetup); }
    runEvents(eventsFrame); }
  public void draw() {
    if (isShown) drawing_pile.drawing(); }
}





//liens avec les svalues
class nLinkedWidget extends nWidget { 
  public nLinkedWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("str")) setLinkedValue((sStr)b);
    if (b.type.equals("run")) setLinkedValue((sRun)b);
    if (b.type.equals("vec")) setLinkedValue((sVec)b);
    return this; }
  sBoo bval; sInt ival; sFlt fval; sStr sval; sRun rval; sVec vval;
  String base_text = "";
  nLinkedWidget(nGUI g) { super(g); }
  
  public nLinkedWidget setLinkedValue(sRun b) { 
    rval = b;
    addEventTrigger(new Runnable(this) { public void run() { 
      rval.run(); } } );
    setTrigger();
    return this; }
  public nLinkedWidget setLinkedValue(sBoo b) { 
    bval = b;
    setSwitch();
    if (b.get()) setOn();
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).setSwitchState(bval.get()); } } );
    addEventSwitchOn(new Runnable() { public void run() { bval.set(true); } } );
    addEventSwitchOff(new Runnable() { public void run() { bval.set(false); } } );
    return this; }
  public nLinkedWidget setLinkedValue(sInt b) { 
    ival = b;
    setText(str(ival.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(str(ival.get())); } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      if (!(s.length() > 0 && PApplet.parseInt(s) == 0) && !str(PApplet.parseInt(s)).equals("NaN")) ival.set(PApplet.parseInt(s)); } } );
    return this; }
  public nLinkedWidget setLinkedValue(sFlt b) { 
    fval = b;
    setText(str(fval.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(str(fval.get())); } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      if (!(s.length() > 0 && PApplet.parseFloat(s) == 0) && !str(PApplet.parseFloat(s)).equals("NaN")) fval.set(PApplet.parseFloat(s)); } } );
    return this; }
  public nLinkedWidget setLinkedValue(sVec b) { 
    vval = b;
    setGrabbable();
    setPosition(vval.x(), vval.y());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).setPosition(vval.x(), vval.y()); } } );
    addEventPositionChange(new Runnable(this) { public void run() { 
      vval.set(((nLinkedWidget)builder).getLocalX(), ((nLinkedWidget)builder).getLocalY()); } } );
    return this; }
  public nLinkedWidget setLinkedValue(sStr b) { 
    if (sval == null) base_text = getText();
    sval = b;
    setText(base_text + sval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(base_text + sval.get()); } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      sval.set(s); } } );
    return this; }
}

//liens avec les svalues
class nWatcherWidget extends nWidget {
  public nWatcherWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("str")) setLinkedValue((sStr)b);
    if (b.type.equals("vec")) setLinkedValue((sVec)b);
    if (b.type.equals("col")) setLinkedValue((sCol)b);
    return this; }
  sBoo bval; sInt ival; sFlt fval; sStr sval; sVec vval; sCol cval;
  nWatcherWidget(nGUI g) { super(g); }
  public nWatcherWidget setLinkedValue(sInt b) { 
    ival = b; setText(str(ival.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(str(ival.get())); } } );
    return this; }
  public nWatcherWidget setLinkedValue(sFlt b) { 
    fval = b; setText(trimStringFloat(fval.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(trimStringFloat(fval.get())); } } );
    return this; }
  public nWatcherWidget setLinkedValue(sBoo b) { 
    bval = b; 
    if (bval.get()) setText("true"); else setText("false");
    b.addEventChange(new Runnable(this) { public void run() { 
      if (bval.get()) ((nWatcherWidget)builder).setText("true");
      else ((nWatcherWidget)builder).setText("false"); } } );
    return this; }
  public nWatcherWidget setLinkedValue(sStr b) { 
    sval = b; setText(sval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(sval.get()); } } );
    return this; }
  public nWatcherWidget setLinkedValue(sCol b) { 
    cval = b; setStandbyColor(cval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setStandbyColor(cval.get()); } } );
    return this; }
  public nWatcherWidget setLinkedValue(sVec b) { 
    vval = b; 
    setText(trimStringFloat(vval.x()) + "," + trimStringFloat(vval.y()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(trimStringFloat(vval.x()) + "," + trimStringFloat(vval.y())); } } );
    return this; }
}

//liens avec les svalues
class nCtrlWidget extends nWidget {
  public nCtrlWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("run")) setLinkedValue((sRun)b);
    return this; }
  public nCtrlWidget setRunnable(Runnable b) { 
    rval = b; setTrigger();
    addEventTrigger(new Runnable(this) { public void run() { rval.run(); } } ); return this; }
  public nCtrlWidget setLinkedValue(sRun b) { 
    srval = b; setTrigger();
    addEventTrigger(new Runnable(this) { public void run() { srval.run(); } } ); return this; }
  public nCtrlWidget setLinkedValue(sBoo b) { 
    bval = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  public nCtrlWidget setLinkedValue(sInt b) { 
    ival = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  public nCtrlWidget setLinkedValue(sFlt b) { 
    fval = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  public nCtrlWidget setIncrement(float f) { mode = false; factor = f; return this; }
  public nCtrlWidget setFactor(float f) { mode = true; factor = f; return this; }
  
  nCtrlWidget(nGUI g) { super(g); }
  Runnable rval;
  sBoo bval; sInt ival; sFlt fval; sRun srval;
  float factor = 2.0f; boolean mode = false;
  public void modify() {
    if (bval != null) bval.set(!bval.get());
    if (ival != null) { if (mode) ival.set(PApplet.parseInt(ival.get()*factor)); else ival.set(PApplet.parseInt(ival.get()+factor)); }
    if (fval != null) { if (mode) fval.set(fval.get()*factor); else fval.set(fval.get()+factor); }
  }
}







//manage look
class sLook extends sValue {
  public String getString() { return ""; }
  public void clear() { }
  nLook val = new nLook();
  sLook(sValueBloc b, nLook v, String n, String s) { super(b, "look", n, s); val.copy(v); }
  public nLook get() { return val; }
  public void set(nLook v) { if (!v.ref.equals(val.ref)) has_changed = true; val.copy(v); }
}


//colors n thickness
class nLook {
  public nLook copy(nLook l) {
    ref = l.ref.substring(0, l.ref.length());;
    standbyColor = l.standbyColor; pressColor = l.pressColor; 
    hoveredColor = l.hoveredColor; outlineColor = l.outlineColor;
    outlineSelectedColor = l.outlineSelectedColor; textColor = l.textColor;
    textFont = l.textFont; outlineWeight = l.outlineWeight;
    return this;
  }
  public void clear() {}
  nLook() { }
  String ref = "def";
  int standbyColor = color(80), hoveredColor = color(110), pressColor = color(130), 
        outlineColor = color(255), outlineSelectedColor = color(255, 255, 0), textColor = color(255);
  int textFont = 24; float outlineWeight = 1;
}




class nSlide extends nWidget {
  public nSlide setLinkedValue(sValue v) {
    
    return this;
  }
  public nSlide setValue(float v) {
    if (v < 0) v = 0; if (v > 1) v = 1;
    curs.setPX(v * (bar.getLocalSX() - curs.getLocalSX()));
    cursor_value = v;
    return this;
  }
  public nWidget addEventSlide(Runnable r)   { eventSlide.add(r); return this; }
  public nWidget addEventLiberate(Runnable r)   { eventLiberate.add(r); return this; }
  public nWidget addEventSlide_Builder(Runnable r)   { r.builder = this; eventSlide.add(r); return this; }
  
  nWidget bar, curs;
  sValue val;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float scale_height, scale_width;
  float cursor_value = 0;
  ArrayList<Runnable> eventSlide = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLiberate = new ArrayList<Runnable>();
  nSlide(nGUI g, float _scale_width, float _scale_height) { super(g); 
    scale_height = _scale_height; scale_width = _scale_width;
    bar = new nWidget(gui, 0, scale_height * 3 / 8, _scale_width, scale_height * 1 / 4).setParent(this);
    curs = new nWidget(gui, 0, -scale_height * 3 / 8, scale_height * 1 / 4, scale_height)
      .setParent(bar)
      .setStandbyColor(color(200))
      .setGrabbable().setConstrainY(true)
      .addEventDrag(new Runnable() { public void run() {
        if (curs.getLocalX() < 0) curs.setPX(0);
        if (curs.getLocalX() > bar.getLocalSX() - curs.getLocalSX()) 
          curs.setPX(bar.getLocalSX() - curs.getLocalSX());
        cursor_value = curs.getLocalX() / (bar.getLocalSX() - curs.getLocalSX());
        runEvents(eventSlide, cursor_value);
      }})
      .addEventLiberate(new Runnable() { public void run() {
        runEvents(eventLiberate);
      }});
    widgets.add(bar);
    widgets.add(curs);
  }
  public nSlide setLayer(int l) { super.setLayer(l); for (nWidget w : widgets) w.setLayer(l); return this; }
  public nSlide toLayerTop() { super.toLayerTop(); for (nWidget w : widgets) w.toLayerTop(); return this; }
  public void clear() { for (nWidget w : widgets) w.clear(); super.clear(); }
}






class nWidget {
  
  //nWidget setPanelDrawer(nPanelDrawer d) { pan_drawer = d; return this; }
  //nPanelDrawer getPanelDrawer() { return pan_drawer; }
  public nWidget setDrawer(nDrawer d) { ndrawer = d; return this; }
  public nDrawer getDrawer() { return ndrawer; }
  public nShelf getShelf() { return ndrawer.shelf; }
  public nShelfPanel getShelfPanel() { return ndrawer.shelf.shelfPanel; }
  
  public nWidget addEventPositionChange(Runnable r)   { eventPositionChange.add(r); return this; }
  public nWidget addEventShapeChange(Runnable r)      { eventShapeChange.add(r); return this; }
  public nWidget addEventLayerChange(Runnable r)      { eventLayerChange.add(r); return this; }
  public nWidget addEventVisibilityChange(Runnable r) { eventVisibilityChange.add(r); return this; }
  
  public nWidget addEventClear(Runnable r)      { eventClear.add(r); return this; }
  
  public nWidget addEventFrame(Runnable r)      { eventFrameRun.add(r); return this; }
  public nWidget addEventFrame_Builder(Runnable r) { eventFrameRun.add(r); r.builder = this; return this; }
  
  public nWidget addEventGrab(Runnable r)       { eventGrabRun.add(r); return this; }
  public nWidget addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  public nWidget removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  public nWidget addEventLiberate(Runnable r)   { eventLiberateRun.add(r); return this; }
  
  public nWidget addEventMouseEnter(Runnable r) { eventMouseEnterRun.add(r); return this; }
  public nWidget addEventMouseLeave(Runnable r) { eventMouseLeaveRun.add(r); return this; }
  
  public nWidget addEventPress(Runnable r)      { eventPressRun.add(r); return this; }
  public nWidget addEventRelease(Runnable r)    { eventReleaseRun.add(r); return this; }
  
  public nWidget addEventTrigger(Runnable r)         { eventTriggerRun.add(r); return this; }
  public nWidget removeEventTrigger(Runnable r)      { eventTriggerRun.remove(r); return this; }
  public nWidget clearEventTrigger()                 { eventTriggerRun.clear(); return this; }
  public nWidget addEventTrigger_Builder(Runnable r) { eventTriggerRun.add(r); r.builder = this; return this; }
  
  public nWidget addEventSwitchOn(Runnable r)   { eventSwitchOnRun.add(r); return this; }
  public nWidget addEventSwitchOn_Builder(Runnable r)   { r.builder = this; eventSwitchOnRun.add(r); return this; }
  public nWidget addEventSwitchOff(Runnable r)  { eventSwitchOffRun.add(r); return this; }
  public nWidget clearEventSwitchOn()   { eventSwitchOnRun.clear(); return this; }
  public nWidget clearEventSwitchOff()  { eventSwitchOffRun.clear(); return this; }
  
  public nWidget addEventFieldChange(Runnable r) { eventFieldChangeRun.add(r); return this; }
  
  public nWidget setDrawable(Drawable d) { 
    gui.drawing_pile.drawables.remove(drawer); 
    drawer = d; 
    if (drawer != null) {
      drawer.setLayer(layer); 
      gui.drawing_pile.drawables.add(d); 
    }
    return this; 
  }
  
  public nWidget setLayer(int l) { 
    layer = l; 
    if (drawer != null) drawer.setLayer(layer); 
    if (hover != null) hover.setLayer(layer); 
    runEvents(eventLayerChange); 
    return this; 
  }
  
  public nWidget toLayerTop() {
    drawer.toLayerTop();
    hover.toLayerTop();
    return this;
  }
  
  public nWidget setParent(nWidget p) { 
    if (parent != null) parent.childs.remove(this); 
    if (p != null) { parent = p; p.childs.add(this); changePosition(); } return this; }
  public nWidget clearParent() { 
    if (parent != null) { parent.childs.remove(this); parent = null; changePosition(); } return this; }
  
  public nWidget setText(String s) { if (s != null) { label = s; cursorPos = label.length(); } return this; }
  public nWidget changeText(String s) { label = s; if (cursorPos > label.length()) cursorPos = label.length(); return this; }
  public nWidget setFont(int s) { look.textFont = s; return this; }
  public nWidget setTextAlignment(int sx, int sy) { textAlignX = sx; textAlignY = sy; return this; }
  public nWidget setTextVisibility(boolean s) { show_text = s; return this; }
  public nWidget setInfo(String s) { if (s != null) { infoText = s; showInfo = true; } return this; }
  public nWidget setNoInfo() { showInfo = false; return this; }
  
  public nWidget setLook(nLook l) { look.copy(l); return this; }
  public nWidget setLook(nTheme t, String r) { look.copy(t.getLook(r)); return this; }
  public nWidget setLook(String r) { look.copy(gui.theme.getLook(r)); return this; }
  
  public nWidget hide() { 
    if (!hide) {
      hide = true; 
      changePosition(); 
      if (drawer != null) { drawerHideState = drawer.active; drawer.active = false; }
      if (hover != null) { hoverHideState = hover.active; hover.active = false; }
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.hide(); 
    }
    return this; 
  }
  public nWidget show() { 
    if (hide) {
      hide = false; 
      changePosition(); 
      if (drawer != null) drawer.active = drawerHideState; 
      if (hover != null) hover.active = hoverHideState; 
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.show(); 
    }
    return this; 
  }
  
  public nWidget copy(nWidget w) {
  //eventFrameRun.clear(); for (Runnable r : w.eventFrameRun) eventFrameRun.add(r);
  
  //ArrayList<Runnable> eventPositionChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventShapeChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventLayerChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventVisibilityChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventClear = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventFrameRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventGrabRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventLiberateRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventMouseEnterRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventMouseLeaveRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventPressRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventReleaseRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventTriggerRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventSwitchOnRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventSwitchOffRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventFieldChangeRun = new ArrayList<Runnable>();
    triggerMode = w.triggerMode; switchMode = w.switchMode;
    grabbable = w.grabbable; constrainX = w.constrainX; constrainY = w.constrainY;
    isSelectable = w.isSelectable; isField = w.isField; 
    showCursor = w.showCursor; hoverOutline = w.hoverOutline; showOutline = w.showOutline;
    alignX = w.alignX; stackX = w.stackX; alignY = w.alignY; stackY = w.stackY; centerX = w.centerX; centerY = w.centerY;
    placeLeft = w.placeLeft; placeRight = w.placeRight; placeUp = w.placeUp; placeDown = w.placeDown;
    hide = w.hide; drawerHideState = w.drawerHideState; hoverHideState = w.hoverHideState;
    constantOutlineWeight = w.constantOutlineWeight;
    textAlignX = w.textAlignX; textAlignY = w.textAlignY; show_text = w.show_text;
    shapeRound = w.shapeRound; shapeLosange = w.shapeLosange; 
    showInfo = w.showInfo; infoText = str_copy(w.infoText);
    constrainDlength = w.constrainDlength; constrainD = w.constrainD;
    look.copy(w.look);
    setLayer(w.layer);
    setPosition(w.localrect.pos.x, w.localrect.pos.y);
    setSize(w.localrect.size.x, w.localrect.size.y);
    changePosition();
    if (hover != null && w.hover != null) hover.active = w.hover.active;
    if (w.parent != null) setParent(w.parent);
    //if (hover != null && (isSelectable || grabbable || triggerMode || switchMode) && !hide) hover.active = true;
    return this;
  }
  
  public void clear() {
    for (nWidget w : childs) w.clear();
    runEvents(eventClear);
    if (look != null) look.clear();
    if (drawer != null) drawer.clear(); if (hover != null) hover.clear();
    eventPositionChange.clear(); eventShapeChange.clear(); eventLayerChange.clear(); 
    eventVisibilityChange.clear(); eventClear.clear(); eventFrameRun.clear(); 
    eventGrabRun.clear(); eventDragRun.clear(); eventLiberateRun.clear(); eventFieldChangeRun.clear();
    eventMouseEnterRun.clear(); eventMouseLeaveRun.clear(); eventPressRun.clear(); eventReleaseRun.clear();
    eventTriggerRun.clear(); eventSwitchOnRun.clear(); eventSwitchOffRun.clear(); eventFieldChangeRun.clear();
  }
  
  public nGUI getGUI() { return gui; }
  public Rect getRect() { return globalrect; }
  public Rect getPhantomRect() { return phantomrect; } //rect exist enven when hided ; for hided collisions
  public int getLayer() { return layer; }
  public String getText() { return label.substring(0, label.length()); }
  
  public boolean isClicked() { return isClicked; }
  public boolean isHovered() { return isHovered; }
  public boolean isGrabbed() { return isGrabbed; }
  public boolean isField() { return isField; }
  public boolean isHided() { return hide; }
  public boolean isOn() { return switchState; }
  
  
  
  public nWidget setHoverablePhantomSpace(float f) { if (hover != null) hover.phantom_space = f; return this; }
  
  public nWidget setPassif() { 
    triggerMode = false; 
    switchMode = false; 
    switchState = false; 
    grabbable = false; 
    isField = false;
    isClicked = false;
    if (hover != null) { hover.active = false; hoverHideState = hover.active; }
    return this; }
  public nWidget setBackground() { 
    triggerMode = false; 
    switchMode = false; 
    switchState = false; 
    grabbable = false; 
    isField = false; 
    isClicked = false;
    if (hover != null) { hover.active = true; hoverHideState = hover.active; }
    return this; }
  public nWidget setTrigger() { 
    triggerMode = true; switchMode = false; switchState = false; 
    if (hover != null) hover.active = true; hoverHideState = hover.active; return this; }
  public nWidget setSwitch() { 
    triggerMode = false; switchMode = true; switchState = false; 
    if (hover != null) hover.active = true; hoverHideState = hover.active; return this; }
  
  //carefull!! dont work if excluded cleared before this
  private ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  public nWidget addExclude(nWidget b) { excludes.add(b); return this; }
  public nWidget removeExclude(nWidget b) { excludes.remove(b); return this; }
  
  public nWidget setGrabbable() { triggerMode = true; grabbable = true; hover.active = true; hoverHideState = hover.active; return this; }
  public nWidget setFixed() { grabbable = false; hover.active = false; hoverHideState = hover.active; return this; }
  public nWidget setConstrainX(boolean b) { constrainX = b; return this; }
  public nWidget setConstrainY(boolean b) { constrainY = b; return this; }
  public nWidget setConstrainDistance(float b) { if (b == 0) constrainD = false; else { constrainDlength = b; constrainD = true; } return this; }
  public nWidget setSelectable(boolean o) { isSelectable = o; hoverOutline = o; hover.active = true; hoverHideState = hover.active; return this; }
  public nWidget setField(boolean o) { isField = o; setSelectable(o); return this; }
  
  public nWidget setOutline(boolean o) { showOutline = o; return this; }
  public nWidget setOutlineWeight(float l) { look.outlineWeight = l; return this; }
  public nWidget setOutlineConstant(boolean l) { constantOutlineWeight = l; return this; }
  
  public nWidget setHoveredOutline(boolean o) { hoverOutline = o; return this; }
  
  public nWidget setPosition(float x, float y) { setPX(x); setPY(y); return this; }
  public nWidget setPosition(PVector p) { setPX(p.x); setPY(p.y); return this; }
  public nWidget setSize(float x, float y) { setSX(x); setSY(y); return this; }
  
  public nWidget setPX(float v) { 
    if (v != localrect.pos.x) { localrect.pos.x = v; changePosition(); return this; } return this; }
  public nWidget setPY(float v) { 
    if (v != localrect.pos.y) { localrect.pos.y = v; changePosition(); return this; } return this; }
  public nWidget setSX(float v) { 
    if (v != localrect.size.x) { 
      localrect.size.x = v; 
      globalrect.size.x = getSX(); 
      if (stackX && placeLeft) globalrect.pos.x = getX(); 
      for (nWidget w : childs) 
        if (((w.stackX || w.alignX) && w.placeRight) || ((stackX || alignX) && placeLeft)) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  public nWidget setSY(float v) { 
    if (v != localrect.size.y) { 
      localrect.size.y = v; 
      globalrect.size.y = getSY(); 
      if (stackY && placeUp) globalrect.pos.y = getY(); 
      for (nWidget w : childs) 
        if (((w.stackY || w.alignY) && w.placeDown) || ((stackY || alignY) && placeUp)) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  
  public nWidget setRound(boolean c) { shapeRound = c; return this; }
  public nWidget setLosange(boolean c) { shapeLosange = c; return this; }
  
  public nWidget setStandbyColor(int c) { look.standbyColor = c; return this; }
  public nWidget setHoveredColor(int c) { look.hoveredColor = c; return this; }
  public nWidget setClickedColor(int c) { look.pressColor = c; return this; }
  public nWidget setLabelColor(int c)   { look.textColor = c; return this; }
  public nWidget setOutlineColor(int c) { look.outlineColor = c; return this; }
  public nWidget setOutlineSelectedColor(int c) { look.outlineSelectedColor = c; return this; }
  
  public nWidget alignUp()    { alignY = true;  stackY = false; placeUp   = true;  placeDown = false;  centerY = false; changePosition(); return this; }
  public nWidget alignDown()  { alignY = true;  stackY = false; placeUp   = false; placeDown = true;   centerY = false; changePosition(); return this; }
  public nWidget alignLeft()  { alignX = true;  stackX = false; placeLeft = true;  placeRight = false; centerY = false; changePosition(); return this; }
  public nWidget alignRight() { alignX = true;  stackX = false; placeLeft = false; placeRight = true;  centerY = false; changePosition(); return this; }
  public nWidget stackUp()    { alignY = false; stackY = true;  placeUp   = true;  placeDown = false;  centerX = false; changePosition(); return this; }
  public nWidget stackDown()  { alignY = false; stackY = true;  placeUp   = false; placeDown = true;   centerX = false; changePosition(); return this; }
  public nWidget stackLeft()  { alignX = false; stackX = true;  placeLeft = true;  placeRight = false; centerX = false; changePosition(); return this; }
  public nWidget stackRight() { alignX = false; stackX = true;  placeLeft = false; placeRight = true;  centerX = false; changePosition(); return this; }
  public nWidget centerX()    { alignX = false; stackX = false; placeLeft = false; placeRight = false; centerX = true;  changePosition(); return this; }
  public nWidget centerY()    { alignX = false; stackX = false; placeLeft = false; placeRight = false; centerY = true;  changePosition(); return this; }
  
  public void setSwitchState(boolean s) { if (s) setOn(); else setOff(); }
  public void setOn() {
    if (!switchState) {
      switchState = true;
      runEvents(eventSwitchOnRun);
      for (nWidget b : excludes) b.setOff(); }
  }
  public void forceOn() {
    switchState = true;
    runEvents(eventSwitchOnRun);
    for (nWidget b : excludes) b.setOff(); }
    
  public void setOff() {
    if (switchState) {
      switchState = false;
      runEvents(eventSwitchOffRun); } }
  public void forceOff() {
    switchState = false;
    runEvents(eventSwitchOffRun); }
  
  public float getX() { 
    if (parent != null) {
      if (alignX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x - getSX();
        else if (placeLeft) return parent.getX() + localrect.pos.x;
      } else if (stackX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x;
        else if (placeLeft) return parent.getX() + localrect.pos.x - getSX();
      } else return localrect.pos.x + parent.getX();
      if (centerX) return parent.getX() + localrect.pos.x - getSX()/2;
    } 
    if (alignX) {
      if (placeRight) return localrect.pos.x - getSX();
      else if (placeLeft) return localrect.pos.x;
    } else if (stackX) {
      if (placeRight) return localrect.pos.x;
      else if (placeLeft) return localrect.pos.x - getSX();
    } 
    if (centerX) return localrect.pos.x - getSX()/2;
    return localrect.pos.x;
  }
  public float getY() { 
    if (parent != null) {
      if (alignY) {
        if (placeDown) return parent.getY() + parent.getSY() + localrect.pos.y - getSY();
        else if (placeUp) return parent.getY() + localrect.pos.y;
      } else if (stackY) {
        if (placeDown) return parent.getY() + parent.getSY() + localrect.pos.y;
        else if (placeUp) return parent.getY() + localrect.pos.y - getSY();
      } else return localrect.pos.y + parent.getY();
      if (centerY) return parent.getY() + localrect.pos.y - getSY()/2;
    } 
    if (alignY) {
      if (placeDown) return localrect.pos.y - getSY();
      else if (placeUp) return localrect.pos.y;
    } else if (stackY) {
      if (placeDown) return localrect.pos.y;
      else if (placeUp) return localrect.pos.y - getSY();
    }
    if (centerY) return localrect.pos.y - getSY()/2;
    return localrect.pos.y;
  }
  public float getLocalX() { return localrect.pos.x; }
  public float getLocalY() { return localrect.pos.y; }
  public float getSX() { if (!hide) return localrect.size.x; else return 0; }
  public float getSY() { if (!hide) return localrect.size.y; else return 0; }
  public float getLocalSX() { return localrect.size.x; }
  public float getLocalSY() { return localrect.size.y; }
  
  nWidget() {   //only for theme model saving !!
    localrect = new Rect();
    globalrect = new Rect();
    phantomrect = new Rect();
    hover = new Hoverable(null, null);
    hover.active = true;
    hoverHideState = hover.active; 
    changePosition();
    look = new nLook();
    label = new String();
  }
  nWidget(nGUI g) { init(g); }
  nWidget(nGUI g, float x, float y) {
    init(g);
    setPosition(x, y);
  }
  nWidget(nGUI g, float x, float y, float w, float h) {
    init(g);
    setPosition(x, y);
    setSize(w, h);
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y) {
    init(g);
    label = _label; look.textFont = _text_font;
    setPosition(x, y);
    setSize(label.length() * _text_font, _text_font);
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y, float w, float h) {
    init(g);
    label = _label; look.textFont = _text_font;
    setPosition(x, y);
    setSize(w, h);
  }
  
  protected nGUI gui;
  private Drawable drawer;
  private Hoverable hover;
  private Rect globalrect, localrect, phantomrect;
  private nWidget parent = null;
  private ArrayList<nWidget> childs = new ArrayList<nWidget>();
  private nLook look;
  //private nPanelDrawer pan_drawer = null;
  private nDrawer ndrawer = null;
  
  private String label, infoText;
  private float mx = 0, my = 0, pmx = 0, pmy = 0;
  private int cursorPos = 0;
  private int cursorCount = 0;
  private int cursorCycle = 80;
  
  private boolean switchState = false;
  private boolean isClicked = false;
  private boolean isHovered = false;
  private boolean isGrabbed = false;
  private boolean isSelected = false;
  
  private boolean triggerMode = false, switchMode = false;
  private boolean grabbable = false, constrainX = false, constrainY = false, constrainD = false;
  private float constrainDlength = 0;
  private boolean isSelectable = false, isField = false, showCursor = false;
  private boolean showOutline = false, hoverOutline = false, constantOutlineWeight = false;
  private boolean alignX = false, stackX = false, alignY = false, stackY = false;
  private boolean centerX = false, centerY = false;
  private boolean placeLeft = false, placeRight = false, placeUp = false, placeDown = false;
  private boolean hide = false, drawerHideState = true, hoverHideState = true, show_text = true;
  private boolean shapeRound = false, shapeLosange = false, showInfo = false;
  private int layer = 0, textAlignX = CENTER, textAlignY = CENTER;
 
  ArrayList<Runnable> eventPositionChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventShapeChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLayerChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventVisibilityChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventClear = new ArrayList<Runnable>();
  ArrayList<Runnable> eventFrameRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventGrabRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLiberateRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventMouseEnterRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventMouseLeaveRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventPressRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventReleaseRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventTriggerRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventSwitchOnRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventSwitchOffRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventFieldChangeRun = new ArrayList<Runnable>();
  
  public void init(nGUI g) {
    gui = g;
    gui.addEventFrame(new Runnable() { public void run() { frame(); } } );
    localrect = new Rect();
    globalrect = new Rect();
    phantomrect = new Rect();
    changePosition();
    hover = new Hoverable(g.hoverable_pile, globalrect);
    hover.active = true;
    hoverHideState = hover.active; 
    label = new String();
    look = new nLook();
    drawer = new Drawable(g.drawing_pile) { public void drawing() {
      if (((triggerMode || switchMode) && isClicked) || switchState) { fill(look.pressColor); } 
      else if (isHovered && (triggerMode || switchMode))             { fill(look.hoveredColor); } 
      else                                                           { fill(look.standbyColor); }
      noStroke();
      ellipseMode(CORNER);
      if (shapeRound) ellipse(getX(), getY(), getSX(), getSY());
      else if (shapeLosange) {quad(getX() + getSX()/2, getY(), 
                                   getX() + getSX()  , getY() + getSY()/2, 
                                   getX() + getSX()/2, getY() + getSY(), 
                                   getX()            , getY() + getSY()/2  );}
      else if (!DEBUG_NOFILL) rect(getX(), getY(), getSX(), getSY());
      
      noFill();
      if (isField && isSelected) stroke(look.outlineSelectedColor);
      else if (showOutline || (hoverOutline && isHovered)) stroke(look.outlineColor);
      else noStroke();
      float wf = 1;
      if (constantOutlineWeight) { wf = 1 / gui.scale; strokeWeight(look.outlineWeight / gui.scale); }
      else strokeWeight(look.outlineWeight);
      
      
      if (shapeRound) ellipse(getX() + wf*look.outlineWeight/2, getY() + wf*look.outlineWeight/2, 
           getSX() - wf*look.outlineWeight, getSY() - wf*look.outlineWeight);
      else if (shapeLosange) {quad(getX() + getSX()/2, getY() + wf*look.outlineWeight/2, 
                                   getX() + getSX() - wf*look.outlineWeight/2, getY() + getSY()/2, 
                                   getX() + getSX()/2, getY() + getSY() - wf*look.outlineWeight/2, 
                                   getX() + wf*look.outlineWeight/2, getY() + getSY()/2  );}
      else rect(getX() + wf*look.outlineWeight/2, getY() + wf*look.outlineWeight/2, 
           getSX() - wf*look.outlineWeight, getSY() - wf*look.outlineWeight);
      
      if (show_text) {
        String l = label;
        if (showCursor) {
          String str = label.substring(0, cursorPos);
          String end = label.substring(cursorPos, label.length());
          if (cursorCount < cursorCycle / 2) l = str + "|" + end;
          else l = str + " " + end;
          cursorCount++;
          if (cursorCount > cursorCycle) cursorCount = 0;
        }
        fill(look.textColor); 
        textAlign(textAlignX, textAlignY);
        textFont(getFont(look.textFont));
        //int line = 0;
        //for (int i = 0 ; i < l.length() ; i++) if (l.charAt(i) == '\n') line+=1;
        float tx = getX();
        float ty = getY();
        if (textAlignY == CENTER)         
          ty += (getLocalSY() / 2.0f)
                - (look.textFont / 6.0f)
                //- (line * look.textFont / 3)
                ;
        else if (textAlignY == BOTTOM) 
          ty += getLocalSY() - (look.textFont / 10);
        if (textAlignX == LEFT)        tx += getSY() / 2;
        else if (textAlignX == CENTER) tx += getSX() / 2;
        text(l, tx, ty);
      }
    } } ;
  }
  
  private void changePosition() { 
    globalrect.pos.x = getX(); 
    globalrect.pos.y = getY(); 
    globalrect.size.x = getSX(); 
    globalrect.size.y = getSY(); 
    phantomrect.pos.x = getX(); 
    phantomrect.pos.y = getY(); 
    phantomrect.size.x = getLocalSX(); 
    phantomrect.size.y = getLocalSY(); 
    runEvents(eventPositionChange); 
    for (nWidget w : childs) w.changePosition(); 
  }
  
  public void frame() {
    if (hover.mouseOver) {
      if (!isHovered) runEvents(eventMouseEnterRun);
      if (showInfo) gui.info.showText(infoText);
      isHovered = true;
    } else {
      if (isHovered) runEvents(eventMouseLeaveRun); 
      isHovered = false;
    }
    if (triggerMode || switchMode) {
      if (gui.in.getUnClick("MouseLeft")) {
        if (isClicked) runEvents(eventReleaseRun); 
        isClicked = false;
      }
      if (gui.in.getClick("MouseLeft") && isHovered && !isClicked) {
        runEvents(eventPressRun);
        isClicked = true;
        if (triggerMode) runEvents(eventTriggerRun); 
        if (switchMode) { if (switchState) { setOff(); } else { setOn(); } }
      }
      
    }
    if (grabbable) {
      if (isHovered) {
        if (gui.in.getClick("MouseLeft")) {
          mx = getLocalX() - gui.mouseVector.x;
          my = getLocalY() - gui.mouseVector.y;
          //gui.in.cam.GRAB = false; //deactive le deplacement camera
          //gui.szone.ON = false;
          isGrabbed = true;
          runEvents(eventGrabRun);
        }
      }
      if (isGrabbed && gui.in.getUnClick("MouseLeft")) {
        isGrabbed = false;
        //gui.in.cam.GRAB = true;
        //gui.szone.ON = true;
        runEvents(eventLiberateRun);
      }
      if (isGrabbed && isClicked) {
        float nx = gui.mouseVector.x + mx, ny = gui.mouseVector.y + my;
        if (constrainD) {
          PVector p = new PVector(nx, ny);
          if (p.mag() > constrainDlength) p.setMag(constrainDlength);
          nx = p.x; ny = p.y;
        }
        if (!constrainX) setPX(nx);
        if (!constrainY) setPY(ny);
        runEvents(eventDragRun);
      }
    }
    if (isSelectable) {
      if (isHovered && gui.in.getClick("MouseLeft")) {
        isSelected = !isSelected;
        if (isSelected) {
          prev_select_outline = showOutline;
          showOutline = true;
          if (isField) showCursor = true;
        } else {
          showOutline = prev_select_outline;
          if (isField) showCursor = false;
        }
      } else if (!isHovered && gui.in.getClick("MouseLeft") && isSelected) {
        showOutline = prev_select_outline;
        if (isField) showCursor = false;
        isSelected = false;
      }
    }
    if (isField && isSelected) {
      if (gui.in.getClick("Left")) cursorPos = max(0, cursorPos-1);
      else if (gui.in.getClick("Right")) cursorPos = min(cursorPos+1, label.length());
      else if (gui.in.getClick("Backspace") && cursorPos > 0) {
        String str = label.substring(0, cursorPos-1);
        String end = label.substring(cursorPos, label.length());
        label = str + end;
        cursorPos--;
        runEvents(eventFieldChangeRun);
      }
      else if (gui.in.getClick("Enter") || gui.in.getClick("Backspace")) {}
      else if (gui.in.getClick("All")) {
        String str = label.substring(0, cursorPos);
        String end = label.substring(cursorPos, label.length());
        label = str + gui.in.getLastKey() + end;
        cursorPos++;
        runEvents(eventFieldChangeRun);
      }
    }
    runEvents(eventFrameRun);
  }
  private boolean prev_select_outline = false;
}


/*
  Graph    > data structure and math objects
    Rect    axis aligned
      pvector pos, size
      collision to rect point ...
    Point, Circle, Line, Trig, Poly (multi trig)
    draw methods: rect(Rect), triangle(Trig), line(Line)
    special draw:
      different arrow, interupted circle (cible), 
      chainable outlined line witch articulation connectable to rect circle or trig
  
  

  Animation
    AnimationFrame     abstract void draw()
    list<animframe>
    draw() circle throug frame at each call
    
  
  
  Drawer
    abstract void draw()
    int layer
    DrawerPile
    bool show
    
    rect* view
    a Drawer can point to a rect that should contain the drawing. if the rect is out of a pre_selected rect, 
    or if he is too small he is passed. Maybe a Drawer can hold multiple methods for different level of zoom?
    This could allow large amount of small details. maybe passed and or far away from view drawer can 
    notify their creator for them to desactivate
  
  DrawerPile
    list<drawer>
    frame()
      run draw() for every drawer from the lowest layer so the top layer appear on top
      
  Hoverable
    point to a rect
    can be active pasif or background
    int layer    bool isfound
    
  HoverPile
    list<hover>
    hover founded
    event found, no find
    search(vector) 
      clear founded
      find the first hover under the point, search from the top layer to the down, set as founded
      stop if it found a background hover
*/



//utiliser par le hovering
class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  public void draw() { rect(pos.x, pos.y, size.x, size.y); }
  public Rect copy(Rect r) { 
    pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y; 
    return this; }
}

public boolean rectCollide(Rect rect1, Rect rect2) {
  return (rect1.pos.x < rect2.pos.x + rect2.size.x &&
          rect1.pos.x + rect1.size.x > rect2.pos.x &&
          rect1.pos.y < rect2.pos.y + rect2.size.y &&
          rect1.pos.y + rect1.size.y > rect2.pos.y   );
}

public boolean rectCollide(Rect rect1, Rect rect2, float s) {
  Rect r1 = new Rect(rect1); r1.pos.x -= s; r1.pos.y -= s; r1.size.x += 2*s; r1.size.y += 2*s;
  Rect r2 = new Rect(rect2); r2.pos.x -= s; r2.pos.y -= s; r2.size.x += 2*s; r2.size.y += 2*s;
  return (r1.pos.x < r2.pos.x + r2.size.x &&
          r1.pos.x + r1.size.x > r2.pos.x &&
          r1.pos.y < r2.pos.y + r2.size.y &&
          r1.pos.y + r1.size.y > r2.pos.y   );
}

public boolean rectCollide(PVector p, Rect rect) {
  return (p.x >= rect.pos.x && p.x <= rect.pos.x + rect.size.x &&
          p.y >= rect.pos.y && p.y <= rect.pos.y + rect.size.y );
}

public boolean rectCollide(PVector p, Rect rect, float s) {
  Rect rects = new Rect(rect); rects.pos.x -= s; rects.pos.y -= s; rects.size.x += 2*s; rects.size.y += 2*s;
  return (p.x >= rects.pos.x && p.x <= rects.pos.x + rects.size.x &&
          p.y >= rects.pos.y && p.y <= rects.pos.y + rects.size.y );
}


// systemes pour organiser l'ordre d'execution de different trucs en layer:

//drawing
class Drawable {
  Drawing_pile pile = null;
  int layer = 0;
  boolean active = true;
  public Drawable setPile(Drawing_pile p) {
    pile = p; pile.drawables.add(this);
    return this; }
  Drawable() {}
  Drawable(Drawing_pile p) {
    pile = p; pile.drawables.add(this); }
  Drawable(Drawing_pile p, int l) {
    layer = l;
    pile = p; pile.drawables.add(this); }
  public void clear() { if (pile != null) pile.drawables.remove(this); }
  public void toLayerTop() { pile.drawables.remove(this); pile.drawables.add(0, this); }
  public void toLayerBottom() { pile.drawables.remove(this); pile.drawables.add(this); }
  public Drawable setLayer(int l) {
    layer = l;
    return this;
  }
  public void drawing() {}
}

class Drawing_pile {
  ArrayList<Drawable> drawables = new ArrayList<Drawable>();
  //ArrayList<Drawer> top_drawables = new ArrayList<Drawer>();
  Drawing_pile() { }
  public void drawing() {
    int layer = 0;
    int run_count = 0;
    while (run_count < drawables.size()) {
      for (int i = drawables.size() - 1; i >= 0 ; i--) {
        Drawable r = drawables.get(i);
        if (r.layer == layer) {
          if (r.active) r.drawing();
          run_count++;
        }
      }
      layer++;
    }
  }
  public int getHighestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawable r : drawables) if (r.layer > l) l = r.layer;
      return l;
    } else return 0; }
  public int getLowestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawable r : drawables) if (r.layer < l) l = r.layer;
      return l;
    } else return 0; }
}








//parmi une list de rect en layer lequel est en collision avec un point en premier


class Hoverable_pile {
  ArrayList<Hoverable> hoverables = new ArrayList<Hoverable>();
  ArrayList<Runnable> eventsFound = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNotFound = new ArrayList<Runnable>();
  boolean found = false;
  Hoverable_pile() { }
  public void addEventNotFound(Runnable r) { eventsNotFound.add(r); }
  public void removeEventNotFound(Runnable r) { eventsNotFound.remove(r); }
  public void addEventFound(Runnable r) { eventsFound.add(r); }
  public void removeEventFound(Runnable r) { eventsFound.remove(r); }
  public void search(PVector pointer, boolean passif) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    found = false; int count = 0;
    if (!passif) {
      if (hoverables.size() > 0) while (count < hoverables.size() && !found) {
        for (int i = 0; i < hoverables.size() ; i++) {
          Hoverable h = hoverables.get(i);
          if (h.layer == layer) {
            count++;
            if (!found && h.active && h.rect != null && rectCollide(pointer, h.rect, h.phantom_space)) {
              h.mouseOver = true;
              if (DEBUG_HOVERPILE) {
                fill(255, 0);
                strokeWeight(5);
                stroke(0, 0, 255);
                rect(h.rect.pos.x, h.rect.pos.y, h.rect.size.x, h.rect.size.y);
              }
              found = true;
            }
          }
        }
        layer--;
      }
      if (found) runEvents(eventsFound); else runEvents(eventsNotFound);
    } 
    //else runEvents(eventsNotFound);
  }
}

class Hoverable {
  Hoverable_pile pile = null;
  int layer;
  Rect rect = null;
  boolean mouseOver = false;
  boolean active = true;
  float phantom_space = 0;
  Hoverable(Hoverable_pile p, Rect r) {
    layer = 0;
    pile = p;
    if (pile != null) pile.hoverables.add(this);
    rect = r;
  }
  Hoverable(Hoverable_pile p, Rect r, int l) {
    layer = l;
    pile = p;
    if (pile != null) pile.hoverables.add(this);
    rect = r;
  }
  public void clear() { if (pile != null) pile.hoverables.remove(this); }
  public void toLayerTop() { if (pile != null) { pile.hoverables.remove(this); pile.hoverables.add(0, this); } }
  public void toLayerBottom() { if (pile != null) {pile.hoverables.remove(this); pile.hoverables.add(this); } }
  public Hoverable setLayer(int l) {
    layer = l;
    return this;
  }
}



//execution ordonné en layer et timer
abstract class Tickable {
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
  public void clear() { if (pile != null) pile.tickables.remove(this); }
  public Tickable setLayer(int l) {
    layer = l;
    return this;
  }
  public abstract void tick(float time);
}

class Ticking_pile {
  ArrayList<Tickable> tickables = new ArrayList<Tickable>();
  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;
  Ticking_pile() { }
  public void tick() {
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














 
class nConstructor {
  nTheme theme; 
  float ref_size = 30;
  
  nConstructor(nTheme _g, float s) {
    theme = _g; ref_size = s;
    theme.addModel("ref", new nWidget()
      //.setPassif()
      .setLabelColor(color(200, 200, 200))
      .setFont(PApplet.parseInt(ref_size/1.6f))
      );
    theme.addModel("Hard_Back", theme.newWidget("ref")
      .setStandbyColor(color(50))
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      );
    theme.addModel("Soft_Back", theme.newWidget("ref")
      .setStandbyColor(color(60, 100))
      .setOutlineColor(color(80))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel("Label", theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      );
    theme.addModel("Label_Small_Text", theme.newWidget("Label")
      .setFont(PApplet.parseInt(ref_size/2.1f))
      );
    theme.addModel("Label_Back", theme.newWidget("ref")
      .setStandbyColor(color(55))
      );
    theme.addModel("Label_HightLight_Back", theme.newWidget("ref")
      .setStandbyColor(color(210, 190, 30))
      .setLabelColor(color(90, 80, 50))
      .setFont(PApplet.parseInt(ref_size/2.1f))
      );
    theme.addModel("Label_DownLight_Back", theme.newWidget("ref")
      .setStandbyColor(color(70, 10, 10))
      .setFont(PApplet.parseInt(ref_size/2.1f))
      );
    theme.addModel("Button", theme.newWidget("ref")
      .setStandbyColor(color(80))
      .setHoveredColor(color(110))
      .setClickedColor(color(130))
      );
    theme.addModel("Button_Small_Text", theme.newWidget("Button")
      .setFont(PApplet.parseInt(ref_size/2.2f))
      );
    theme.addModel("Menu_Button", theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(140, 150, 140))
      );
    theme.addModel("Head_Button", theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(120, 130, 120))
      );
    theme.addModel("Auto_Button", theme.newWidget("Button")
      .setFont(PApplet.parseInt(ref_size/1.9f))
      .setStandbyColor(color(20, 100, 15))
      .setHoveredColor(color(120, 180, 120))
      .setClickedColor(color(30, 150, 25))
      );
    theme.addModel("Auto_Ctrl_Button", theme.newWidget("Auto_Button")
      .setFont(PApplet.parseInt(ref_size/2.2f))
      );
    theme.addModel("Auto_Watch_Label", theme.newWidget("ref")
      .setStandbyColor(color(5, 55, 10))
      .setFont(PApplet.parseInt(ref_size/2.2f))
      );
    theme.addModel("Button_Check", theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel("Field", theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineSelectedColor(color(255, 120))
      .setOutlineWeight(ref_size / 10)
      );
    theme.addModel("Cursor", theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      .setHoveredColor(color(255, 120))
      .setClickedColor(color(255, 60))
      .setOutlineColor(color(120))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineConstant(true)
      );
    theme.addModel("Pointer", theme.newWidget("ref")
      .setStandbyColor(color(120))
      .setHoveredColor(color(70))
      .setClickedColor(color(220))
      .setOutlineColor(color(70))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineConstant(true)
      );
    theme.addModel("List_Entry", theme.newWidget("ref")
      .setStandbyColor(color(10, 80, 90))
      .setHoveredColor(color(20, 90, 130))
      .setClickedColor(color(25, 100, 170))
      .setOutlineWeight(ref_size / 40)
      .setOutline(true)
      .setOutlineColor(color(40, 40, 140))
      );
    theme.addModel("List_Entry_Selected", theme.newWidget("ref")
      .setStandbyColor(color(10, 100, 130))
      .setHoveredColor(color(20, 110, 150))
      .setClickedColor(color(30, 115, 175))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineColor(color(100, 170, 210))
      );
      
    make_outline("Button");
    make_outline("Menu_Button");
    make_outline("Head_Button");
    make_outline("Auto_Ctrl_Button");
    make_outline("Label");
    make_outline("Label_Small_Text");
    make_outline("Label_Back");
    make_outline("Auto_Watch_Label");
    make_outline("Auto_Button");
    make_outline("Label_HightLight_Back");
    make_outline("Button_Small_Text");
    make_outline("Label_DownLight_Back");
    make("Label_DownLight_Back");
    make("Button_Small_Text");
    make("Label_HightLight_Back");
    make("Auto_Button");
    make("Label");
    make("Label_Small_Text");
    make("Button");
    make("Menu_Button");
    make("Head_Button");
    make("Auto_Ctrl_Button");
    make("Label_Back");
    make("Auto_Watch_Label");
    make("Button_Check");
    make("Field");
    make("Cursor");
  }
  public void make_outline(String base) {
    theme.addModel(base+"_Outline", theme.newWidget(base)
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel(base+"_Highlight_Outline", theme.newWidget(base)
      .setOutlineColor(color(190, 150, 30))
      .setOutlineWeight(ref_size / 6)
      .setOutline(true)
      );
    theme.addModel(base+"_Downlight_Outline", theme.newWidget(base)
      .setOutlineColor(color(100, 100, 100))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      );
    theme.addModel(base+"_Small_Outline", theme.newWidget(base+"_Outline")
      .setOutlineWeight(ref_size / 12)
      );
      
    make(base+"_Outline");
    make(base+"_Highlight_Outline");
    make(base+"_Downlight_Outline");
    make(base+"_Small_Outline");
  }
  public void do_sizes(String base, String post, float w, float h) {
    theme.addModel(base+post, theme.newWidget(base).setSize(w, h));}
  public void do_places(String base, String post, float x, float y, float w, float h) {
    theme.addModel(base+post, theme.newWidget(base).setSize(w, h).setPosition(x, y));}
  
  float[] sizes_val = { 0.5f, 0.8f, 1, 1.25f, 1.5f, 2, 2.5f, 4, 8 };
  
  public void make(String base) {
    
    do_sizes(base, "-S2/1", ref_size*2, ref_size);
    do_sizes(base, "-S2/0.75", ref_size*2, ref_size*0.75f);
    do_sizes(base, "-S2.5/0.75", ref_size*2.5f, ref_size*0.75f);
    do_sizes(base, "-S3/0.75", ref_size*3, ref_size*0.75f);
    do_sizes(base, "-S4/0.75", ref_size*4, ref_size*0.75f);
    do_sizes(base, "-S6/1", ref_size*6, ref_size*1);
    
    do_sizes(base, "-SS1", ref_size*0.75f, ref_size*0.75f);
    do_sizes(base, "-SS2", ref_size*2.5f, ref_size*0.75f);
    do_sizes(base, "-SS3", ref_size*4, ref_size*0.75f);
    do_sizes(base, "-SS4", ref_size*10, ref_size*0.75f);
    do_sizes(base, "-S1", ref_size, ref_size);
    do_sizes(base, "-S2", ref_size*2.5f, ref_size);
    do_sizes(base, "-S3", ref_size*4, ref_size);
    do_sizes(base, "-S4", ref_size*10, ref_size);
    
    do_places(base, "-S3-P1", ref_size*0.5f, 0, ref_size*4, ref_size);
    do_places(base, "-S3-P2", ref_size*5.5f, 0, ref_size*4, ref_size);
    
    do_places(base, "-S2-P1", ref_size*0.5f, 0, ref_size*2.5f, ref_size);
    do_places(base, "-S2-P2", ref_size*3.75f, 0, ref_size*2.5f, ref_size);
    do_places(base, "-S2-P3", ref_size*7, 0, ref_size*2.5f, ref_size);
    
    do_places(base, "-S1-P1", ref_size*0,     0, ref_size, ref_size);
    do_places(base, "-S1-P2", ref_size*1.125f, 0, ref_size, ref_size);
    do_places(base, "-S1-P3", ref_size*2.25f,  0, ref_size, ref_size);
    do_places(base, "-S1-P4", ref_size*3.375f, 0, ref_size, ref_size);
    do_places(base, "-S1-P5", ref_size*4.5f,   0, ref_size, ref_size);
    do_places(base, "-S1-P6", ref_size*5.625f, 0, ref_size, ref_size);
    do_places(base, "-S1-P7", ref_size*6.75f,  0, ref_size, ref_size);
    do_places(base, "-S1-P8", ref_size*7.875f, 0, ref_size, ref_size);
    do_places(base, "-S1-P9", ref_size*9,     0, ref_size, ref_size);
    
    do_places(base, "-SS1-P1", ref_size*0.125f, ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P2", ref_size*1.25f,  ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P3", ref_size*2.375f, ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P4", ref_size*3.5f,   ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P5", ref_size*4.625f, ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P6", ref_size*5.75f,  ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P7", ref_size*6.875f, ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P8", ref_size*7.0f,   ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
    do_places(base, "-SS1-P9", ref_size*9.125f, ref_size*0.125f, ref_size*0.75f, ref_size*0.75f);
  }
}









class nBuilder { // base pour les class constructrice de nwidget basic

  public nWidget addWidget(nWidget w) { 
    customBuild(w); widgets.add(w); w.toLayerTop(); return w; }
  
  public nWidget addRef(float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, "ref").setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
    
  public nWidget addModel(String r) { 
    nWidget w = gui.theme.newWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWidget addModel(String r, String t) { 
    nWidget w = gui.theme.newWidget(gui, r).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWidget addModel(String r, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWidget addModel(String r, String t, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWidget addModel(String r, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setSize(w, h); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
  public nWidget addModel(String r, String t, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setSize(w, h).setText(t); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
      
  public nLinkedWidget addLinkedModel(String r) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nLinkedWidget addLinkedModel(String r, String t) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nLinkedWidget addLinkedModel(String r, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }  
  public nLinkedWidget addLinkedModel(String r, String t, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }    
    
  public nWatcherWidget addWatcherModel(String r) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWatcherWidget addWatcherModel(String r, String t) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWatcherWidget addWatcherModel(String r, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nWatcherWidget addWatcherModel(String r, String t, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
      
  public nCtrlWidget addCtrlModel(String r) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nCtrlWidget addCtrlModel(String r, String t) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nCtrlWidget addCtrlModel(String r, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  public nCtrlWidget addCtrlModel(String r, String t, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  
  nGUI gui; 
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float ref_size = 30;
  
  public nBuilder setLayer(int l) { for (nWidget w : widgets) w.setLayer(l); return this; }
  public nBuilder toLayerTop() { for (nWidget w : widgets) w.toLayerTop(); return this; }
  public nBuilder clear() { for (nWidget w : widgets) w.clear(); widgets.clear(); return this; }
  public nWidget customBuild(nWidget w) { return w; }
  
  nBuilder(nGUI _g, float s) { gui = _g; ref_size = s; }
}











class nDrawer extends nBuilder {
  public nShelf getShelf() { return shelf; }
  public nShelfPanel getShelfPanel() { return shelf.shelfPanel; }
  nShelf shelf;
  nWidget ref;
  float drawer_width = 0, drawer_height = 0;
  nDrawer(nShelf s, float w, float h) {
    super(s.gui, s.ref_size);
    ref = addModel("ref"); shelf = s;
    drawer_width = w; drawer_height = h; }
  public nDrawer setLayer(int l) { super.setLayer(l); ref.setLayer(l); return this; }
  public nDrawer toLayerTop() { super.toLayerTop(); ref.toLayerTop(); return this; }
  public nWidget customBuild(nWidget w) { return w.setParent(ref).setDrawer(this); }
}










class nShelf extends nBuilder {
  public nShelf addDrawerDoubleButton(sValue val1, sValue val2, float w, float h) {
    nDrawer d = addDrawer(w, h);
    if (val1 != null) {
    d.addLinkedModel("Auto_Button-S3-P1")
      .setLinkedValue(val1)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val1.shrt)
      ;
    }
    if (val2 != null) {
    d.addLinkedModel("Auto_Button-S3-P2")
      .setLinkedValue(val2)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val2.shrt)
      ;
    }
    return this;
  }
  public nShelf addDrawerTripleButton(sValue val1, sValue val2, sValue val3, float w, float h) {
    nDrawer d = addDrawer(w, h);
    if (val1 != null) {
    d.addLinkedModel("Auto_Button-S2-P1")
      .setLinkedValue(val1)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val1.shrt)
      ;
    }
    if (val2 != null) {
    d.addLinkedModel("Auto_Button-S2-P2")
      .setLinkedValue(val2)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val2.shrt)
      ;
    }
    if (val3 != null) {
    d.addLinkedModel("Auto_Button-S2-P3")
      .setLinkedValue(val3)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val3.shrt)
      ;
    }
    return this;
  }
  
  public nShelf addDrawerIncrValue(sValue val2, float incr, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*3.6f, 0)
      .setTextAlignment(LEFT, CENTER)
      ;
    d.addWatcherModel("Auto_Watch_Label-S2")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625f, ref_size*0.8f)
      .setPosition(ref_size*2.25f, ref_size*0.1f)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setIncrement(incr)
      .setText(trimStringFloat(incr))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setIncrement(incr/10)
      .setText(trimStringFloat(incr/10))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setIncrement(-incr/10)
      .setText(trimStringFloat(-incr/10))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setIncrement(-incr)
      .setText(trimStringFloat(-incr))
      ;
    return this;
  }
  
  public nShelf addDrawerActFactValue(String title, sBoo val1, sValue val2, float fact, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*4.3f, 0)
      .setTextAlignment(LEFT, CENTER)
      ;
    d.addWatcherModel("Auto_Watch_Label")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625f, ref_size*0.8f)
      .setPosition(ref_size*3.125f, ref_size*0.1f)
      ;
    d.addLinkedModel("Button_Check-SS1-P3", "")
      .setLinkedValue(val1)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setFactor(fact)
      .setText("x"+trimStringFloat(fact))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setFactor(sqrt(fact))
      .setText("x"+trimStringFloat(sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setFactor(1/sqrt(fact))
      .setText("/"+trimStringFloat(1/sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setFactor(1/fact)
      .setText("/"+trimStringFloat(fact))
      ;
    return this;
  }
  public nShelf addDrawerFactValue(sValue val2, float fact, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*3.6f, 0)
      .setTextAlignment(LEFT, CENTER)
      ;
    d.addWatcherModel("Auto_Watch_Label-S2")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625f, ref_size*0.8f)
      .setPosition(ref_size*2.25f, ref_size*0.1f)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setFactor(fact)
      .setText("x"+trimStringFloat(fact))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setFactor(sqrt(fact))
      .setText("x"+trimStringFloat(sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setFactor(1/sqrt(fact))
      .setText("/"+trimStringFloat(1/sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setFactor(1/fact)
      .setText("/"+trimStringFloat(fact))
      ;
    return this;
  }
  public nShelf addDrawerSlideCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addWidget(new nSlide(gui, w*ref_size, h*ref_size)
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      )
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(PApplet.parseInt(ref_size/1.9f))
      .setTextAlignment(LEFT, CENTER)
      ;
    return this;
  }
  public nShelf addDrawerFieldCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addLinkedModel("Field")
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(PApplet.parseInt(ref_size/1.9f))
      .setTextAlignment(LEFT, CENTER)
      ;
    return this;
  }
  public nShelf addDrawerLargeFieldCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addLinkedModel("Field")
      .setLinkedValue(val)
      .setSize(2*w*ref_size/3, h*ref_size)
      .setPosition(w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setTextAlignment(LEFT, CENTER)
      ;
    return this;
  }
  public nShelf addDrawerWatch(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addWatcherModel("Label_Back")
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(PApplet.parseInt(ref_size/1.9f))
      .setTextAlignment(LEFT, CENTER)
      ;
    return this;
  }
  
  public nDrawer getDrawer(int s) { return drawers.get(s); }
  public nDrawer getLastDrawer() { return drawers.get(drawers.size()-1); }
  public nShelfPanel getShelfPanel() { return shelfPanel; }
  public nFrontTab getTab() { return ((nFrontTab)shelfPanel); }
  public nShelf setPosition(nWidget p, float x, float y) { ref.setParent(p).setPosition(x, y); return this; }
  
  nShelfPanel shelfPanel;
  nWidget ref;
  ArrayList<nDrawer> drawers = new ArrayList<nDrawer>();
  int max_drawer = 0; // 0 = no limit
  float space_factor, max_width = 0, total_height = 0;
  Runnable eventWidth = null, eventHeight = null;

  nShelf(nShelfPanel s, float _space_factor) {
    super(s.gui, s.ref_size);
    shelfPanel = s; space_factor = _space_factor;
    ref = addModel("ref");
  }
  public nShelf addEventWidth(Runnable r) { eventWidth = r; return this; }
  public nShelf addEventHeight(Runnable r) { eventHeight = r; return this; }
  
  public nShelf setLayer(int l) { super.setLayer(l); 
    ref.setLayer(l); for (nDrawer d : drawers) d.setLayer(l); return this; }
  public nShelf toLayerTop() { super.toLayerTop(); 
    ref.toLayerTop(); for (nDrawer d : drawers) d.toLayerTop(); return this; }
  public nWidget customBuild(nWidget w) { return w.setParent(ref); }
  public nShelf clear() { super.clear(); for (nDrawer s : drawers) s.clear(); return this; }
  public nDrawer addDrawer() { return addDrawer(0, 0); }
  public nDrawer addDrawer(float h) { return addDrawer(0, h); }
  public nShelf addSeparator() { addDrawer(0, 0); return this; }
  public nShelf addSeparator(float h) { addDrawer(0, h-space_factor); return this; }
  public nShelf setMax(int m) { max_drawer = m; return this; }
  public nDrawer addDrawer(float w, float h) { return insertDrawer(new nDrawer(this, w*ref_size, h*ref_size)); }
  public nDrawer insertDrawer(nDrawer d) {
    if (d != null && max_drawer == 0 || drawers.size() < max_drawer) {
      if (drawers.size() == 0) { d.ref.setParent(ref).setPY(0); }
      else {
        nDrawer prev = drawers.get(drawers.size()-1);
        prev.drawer_height += ref_size*space_factor/2;
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      drawers.add(d); 
      
      total_height = 0;
      for (nDrawer dr : drawers) total_height += dr.drawer_height;
      if (eventHeight != null) eventHeight.run();
      if (max_width <= d.drawer_width) { max_width = d.drawer_width; if (eventWidth != null) eventWidth.run(); }
      return d;  }
    return null;
  }
  public nShelf removeDrawer(nDrawer d) {
    if (drawers.contains(d)) {
      int d_i = 0;
      for (nDrawer td : drawers) { if (td == d) break; else d_i++; }
      if (drawers.size() == 1) { d.ref.setPY(0).clearParent(); drawers.remove(d); }
      else if (d_i == 0) { 
        drawers.get(1).ref.setPY(0).clearParent().setParent(ref); 
        d.ref.clearParent(); drawers.remove(d); }
      else if (d_i < drawers.size() - 1) { 
        drawers.get(d_i+1).ref.setPY(0).clearParent().setParent(drawers.get(d_i-1).ref); 
        d.ref.clearParent(); drawers.remove(d); }
      else if (d_i == drawers.size() - 1) { d.ref.clearParent(); drawers.remove(d); }
      total_height = 0;
      for (nDrawer dr : drawers) total_height += dr.drawer_height;
      if (eventHeight != null) eventHeight.run();
    }
    return this;
  }
  
  public nList addList(int n, float wf, float hf) {
    nList d = new nList(this, n, ref_size, wf, hf);
    insertDrawer(d);
    return d;
  }
  
  public nExplorer addExplorer() {
    nExplorer d = new nExplorer(this);
    insertDrawer(d);
    return d;
  }
}







class nShelfPanel extends nBuilder {
  public nFrontPanel getFront() { if (fronttab != null) return fronttab.front; else return null; }
  nFrontTab fronttab; // set by superclass fronttab with himself
  
  public nDrawer getDrawer(int c, int r) { return shelfs.get(c).drawers.get(r); }
  public nShelf getShelf(int s) { return shelfs.get(s); }
  public nShelf getShelf() { return shelfs.get(0); }
  
  public nShelf addShelf() {
    nShelf s = new nShelf(this, space_factor);
    s.setPosition(panel, ref_size*space_factor, ref_size*space_factor); 
    shelfs.add(s);
    updateWidth();
    s.addEventHeight(new Runnable(s) { public void run() { updateHeight(); } } );
    s.addEventWidth(new Runnable() { public void run() { updateWidth(); } } );
    return s;
  }
  
  public nDrawer addShelfaddDrawer(float x, float y) {
    return addShelf().addDrawer(x, y);
  }
  
  public nShelfPanel addGrid(int c, int r, float width_factor, float height_factor) {
    for (int i = 0 ; i < c ; i++) {
      nShelf s = addShelf();
      for (int j = 0 ; j < r ; j++) s.addDrawer(width_factor, height_factor);
    }
    return this;
  }
  public nShelfPanel updateHeight() {  
    float h = ref_size * 2 * space_factor;
    for(nShelf s : shelfs) { s.ref.setPX(ref_size * space_factor);
      if (h < s.total_height + ref_size * 2 * space_factor) 
        h = s.total_height + ref_size * 2 * space_factor; }
    panel.setSY(h); 
    max_height = h - ref_size * 2 * space_factor;
    return this; }
  public nShelfPanel updateWidth() { 
    float w = ref_size * space_factor;
    for (nShelf s : shelfs) { s.ref.setPX(w); w += s.max_width + ref_size * space_factor; }
    if (shelfs.size() == 0) w += ref_size * space_factor;
    panel.setSX(w); 
    max_width = w - ref_size * space_factor * 2;
    return this; }
  public nShelfPanel setSpace(float _space_factor) { 
    space_factor = _space_factor;
    return this; }
  nShelfPanel(nGUI _g, float _ref_size, float _space_factor) {
    super(_g, _ref_size);
    panel = addModel("Hard_Back");
    panel.setSize(ref_size*_space_factor*2, ref_size*_space_factor*2);
    space_factor = _space_factor;
  }
  float space_factor, max_width = 0, max_height = 0;
  nWidget panel;
  ArrayList<nShelf> shelfs = new ArrayList<nShelf>();
  
  public nShelfPanel setLayer(int l) { super.setLayer(l); 
    panel.setLayer(l); for (nShelf d : shelfs) d.setLayer(l); return this; }
  public nShelfPanel toLayerTop() { super.toLayerTop(); 
    panel.toLayerTop(); for (nShelf d : shelfs) d.toLayerTop(); return this; }
  public nWidget customBuild(nWidget w) { return w.setParent(panel); }
  public nShelfPanel clear() { super.clear(); for (nShelf s : shelfs) s.clear(); return this; }
}









  









class nToolPanel extends nShelfPanel {
  
  ArrayList<Runnable> eventReducRun = new ArrayList<Runnable>();
  public nToolPanel addEventReduc(Runnable r)       { eventReducRun.add(r); return this; }
  public nToolPanel removeEventReduc(Runnable r)       { eventReducRun.remove(r); return this; }
  public void openit() { if (hide) reduc(); }
  public void closeit() { if (!hide) reduc(); }
  public void reduc() {
    if      (hide && !right)  { panel.show(); reduc.setText("<"); } 
    else if (hide && right)   { panel.show(); reduc.setText(">"); } 
    else if (!hide && !right) { panel.hide(); reduc.show().setText(">"); }
    else                      { panel.hide(); reduc.show().setText("<"); }
    hide = !hide; 
    runEvents(eventReducRun); }
  nCtrlWidget reduc;
  boolean hide = false, right = true, top = true;
  nToolPanel(nGUI _g, float ref_size, float space_factor, boolean rgh, boolean tp) { 
    super(_g, ref_size, space_factor); 
    top = tp; right = rgh;
    reduc = addCtrlModel("Menu_Button_Small_Outline", "<")
      .setRunnable(new Runnable(this) { public void run() { reduc(); } } );
    reduc.setSize(ref_size/1.7f, panel.getSY()).stackRight().show().setLabelColor(color(180));
    if (tp) { panel.setPY(gui.view.pos.y); reduc.alignUp(); }
    else    { panel.setPY(gui.view.pos.y + gui.view.size.y).stackUp(); reduc.alignDown(); }
    if (!rgh) panel.setPX(gui.view.pos.x).stackRight(); 
    else    { panel.setPX(gui.view.pos.x + gui.view.size.x).stackLeft(); reduc.setText(">").stackLeft(); }
  } 
  public nToolPanel updateHeight() { 
    super.updateHeight(); if (reduc != null) reduc.setSY(panel.getLocalSY()); return this; }
}





class nTaskPanel extends nToolPanel {
  ArrayList<nWindowPanel> windowPanels = new ArrayList<nWindowPanel>();
  ArrayList<nWidget> window_buttons = new ArrayList<nWidget>();
  int used_spot = 0, max_spot = 8;
  int row = 2, col = 4;
  float adding_pos;
  public nWidget getWindowPanelButton(nWindowPanel w) {
    if (used_spot < max_spot) {
      int i = 0;
      while(!window_buttons.get(i).getText().equals("")) i++;
      w.taskpanel_button = window_buttons.get(i);
      w.taskpanel_button.setTrigger().setText(w.grabber.getText()).setStandbyColor(color(70))
        //.addEventTrigger(new Runnable() { public void run() {} } )
        ;
      windowPanels.add(w);
      used_spot++;
      if (hide) reduc();
      return w.taskpanel_button;
    }
    return null;
  }
  
  nTaskPanel(nGUI _g, float ref_size, float space_factor) { 
    super(_g, ref_size, space_factor, true, false); 
    
    addGrid(col, row, 4, 0.75f);
    for (int i = 0 ; i < col ; i++) for (int j = 0 ; j < row ; j++) {
      nWidget nw = getDrawer(i, j).addModel("Button-S4/0.75").setStandbyColor(color(60));
      window_buttons.add(nw);
    }
    //gui.addEventSetup(new Runnable() { public void run() { reduc(); } } );
  } 
  public nTaskPanel updateHeight() { 
    super.updateHeight(); return this; }
  public nTaskPanel updateWidth() { 
    super.updateWidth(); return this; }
}







class nWindowPanel extends nShelfPanel {
  public nWindowPanel setPosition(float x, float y) {
    grabber.setPosition(x-task.panel.getX(), y-task.panel.getY()); return this;}
  //void reduc() { panel.hide(); }
  //void enlarg() { panel.show(); }
  public void collapse() { 
    collapsed = true;
    grabber.hide(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(90));
    runEvents(eventCollapseRun);
  }
  public void popUp() { 
    
    collapsed = false;
    if (task.hide) task.reduc();
    grabber.show(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(70)); 
    toLayerTop();
    runEvents(eventCollapseRun);
  }
  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
  public nWindowPanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
  public nWindowPanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
  ArrayList<Runnable> eventCollapseRun = new ArrayList<Runnable>();
  public nWindowPanel addEventCollapse(Runnable r)       { eventCollapseRun.add(r); return this; }
  public nWindowPanel removeEventCollapse(Runnable r)       { eventCollapseRun.remove(r); return this; }
  
  nTaskPanel task;
  nWidget grabber, closer, reduc, collapse, taskpanel_button;
  Runnable run_show;
  boolean collapsed = false;
  nWindowPanel(nGUI _g, nTaskPanel _task, String ti) { 
    super(_g, _task.ref_size, _task.space_factor); 
    task = _task;
    
    grabber = addModel("Head_Button_Small_Outline-SS4").setParent(task.panel).setText(ti)
      .setGrabbable()
      .setSX(ref_size*10.25f)
      .show()
      .addEventGrab(new Runnable() { public void run() { toLayerTop(); } } )
      ;
    if (task.hide) grabber.setPosition(3*ref_size - task.panel.getX() + task.adding_pos*ref_size*1.5f + task.panel.getLocalSX(), 
                                       1*ref_size - task.panel.getY() + task.adding_pos*ref_size*1.5f + task.panel.getLocalSY());
    else grabber.setPosition(3*ref_size - task.panel.getX() + task.adding_pos*ref_size*1.5f, 
                             1*ref_size - task.panel.getY() + task.adding_pos*ref_size*1.5f);
    task.adding_pos++;
    if (task.adding_pos > 5) task.adding_pos -= 5.25f;
    
    closer = addModel("Head_Button_Small_Outline-SS1").setText("X")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { 
        clear(); } } )
      .setParent(grabber)
      .alignRight()
      ;
    collapse = addModel("Head_Button_Small_Outline-SS1").setText("v")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { collapse(); } } )
      .setParent(closer)
      .stackLeft()
      ;
    panel.setParent(grabber).stackDown();
    addShelf()
      //.addDrawer(10, 0)
      ;
    taskpanel_button = task.getWindowPanelButton(this);
    run_show = new Runnable() { public void run() { 
      if (collapsed) popUp(); else collapse(); } };
    if (taskpanel_button != null) taskpanel_button.addEventTrigger(run_show);
  } 
  public nWindowPanel clear() { 
    runEvents(eventCloseRun); 
    task.used_spot--;
    if (taskpanel_button != null) 
      taskpanel_button.removeEventTrigger(run_show).setText("").setPassif().setStandbyColor(color(60));
    super.clear(); return this; }
  public nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  public nWindowPanel updateWidth() { 
    super.updateWidth(); grabber.setSX(max(ref_size * 1.5f, panel.getLocalSX())); 
    //log("wind grab "+grabber.getLocalSX()); 
    return this; }
}









class nFrontTab extends nShelfPanel {
  public nFrontPanel getFront() { return front; }
  
  ArrayList<Runnable> eventOpen = new ArrayList<Runnable>();
  public nFrontTab addEventOpen(Runnable r)       { eventOpen.add(r); return this; }
  
  public nFrontTab show() {
    panel.show();
    front.grabber.setSX(panel.getLocalSX()); 
    return this; }
  
  public nFrontTab hide() {
    panel.hide();
    
    return this; }
  
  nFrontPanel front;
  String name;
  nWidget tabbutton;
  int id = 0;
  nFrontTab(nFrontPanel _front, String ti) { 
    super(_front.gui, _front.ref_size, _front.space_factor); 
    front = _front;
    name = ti;
    fronttab = this;
    addShelf().addDrawer((front.grabber.getLocalSX() / front.ref_size) - 2*front.space_factor, 0);
  } 
  public nFrontTab clear() { 
    tabbutton.clear();
    eventOpen.clear();
    super.clear(); return this; }
  public nFrontTab updateHeight() { 
    
    super.updateHeight(); return this; }
  public nFrontTab updateWidth() { 
    super.updateWidth(); 
    front.grabber.setSX(max_width);
    panel.setSX(max_width); front.updateWidth(); 
    //logln("tab "+name+" : front.grab " + front.grabber.getLocalSX()); 
    
    
    float new_width = front.grabber.getLocalSX() / (front.tab_widgets.size());
    for (nWidget w : front.tab_widgets) w.setSX(new_width); 
    float moy_leng = 0;
    for (nWidget w : front.tab_widgets) moy_leng += w.getText().length();
    moy_leng /= front.tab_widgets.size();
    for (nWidget w : front.tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    
    
    
    return this; }
}






class nFrontPanel extends nWindowPanel {
  
  ArrayList<Runnable> eventTab = new ArrayList<Runnable>();
  public nFrontPanel addEventTab(Runnable r)       { eventTab.add(r); return this; }
  
  public nFrontPanel setNonClosable() { closer.setText("").setBackground(); return this; }
  public nFrontTab getTab(int n) { return tabs.get(n); }
  ArrayList<nFrontTab> tabs = new ArrayList<nFrontTab>();
  ArrayList<nWidget> tab_widgets = new ArrayList<nWidget>();
  nFrontTab current_tab;
  int current_tab_id = 0;
  public nFrontTab addTab(String n) {
    nFrontTab tab = new nFrontTab(this, n);
    tab.id = tabs.size();
    tabs.add(tab);
    tab.panel.setParent(panel)
      .stackDown()
      ;
    float new_width = grabber.getLocalSX() / (tab_widgets.size() + 1);
    nWidget tabbutton = addModel("Button-SS3");
    tabbutton.setSwitch().setText(n)
      .setSX(new_width)
      .setFont(PApplet.parseInt(ref_size/2))
      .addEventSwitchOn(new Runnable(tab) { public void run() {
        for (nFrontTab t : tabs) t.hide();
        current_tab = ((nFrontTab)builder);
        current_tab.show();
        current_tab_id = current_tab.id;
        runEvents(current_tab.eventOpen);
        runEvents(eventTab);
      } } )
      ;
    for (nWidget w : tab_widgets) { 
      w.setSX(new_width); 
      tabbutton.addExclude(w); w.addExclude(tabbutton); }
    if (tab_widgets.size() > 0) tabbutton.setParent(tab_widgets.get(tab_widgets.size()-1)).stackRight();
    else tabbutton.setParent(grabber).stackDown();
    tab_widgets.add(tabbutton);
    tab.tabbutton = tabbutton;
    panel.setParent(tab_widgets.get(0));
    
    tabbutton.setOn();
    
    float moy_leng = 0;
    for (nWidget w : tab_widgets) moy_leng += w.getText().length();
    moy_leng /= tab_widgets.size();
    for (nWidget w : tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    
    return tab;
  }
  
  nFrontPanel(nGUI _g, nTaskPanel _task, String _name) { 
    super(_g, _task, _name); 
    panel.setSY(0).setOutline(false);
    gui.addEventSetup(new Runnable() { public void run() {
      if (tab_widgets.size() > 0) tab_widgets.get(0).setOn();
    } });
  } 
  public void setTab(int i) { 
    if (!collapsed && i < tab_widgets.size()) tab_widgets.get(i).setOn();
  }
  public void collapse() { 
    super.collapse(); 
  }
  public void popUp() { 
    super.popUp(); 
    for (nFrontTab t : tabs) t.hide();
    if (current_tab != null) {
      current_tab.show();
      runEvents(current_tab.eventOpen); }
  }
  public nFrontPanel toLayerTop() { super.toLayerTop(); for (nFrontTab d : tabs) d.toLayerTop(); return this; }
  public nFrontPanel clear() { 
    for (nFrontTab d : tabs) d.clear();
    super.clear(); return this; }
  public nFrontPanel updateHeight() { 
    super.updateHeight(); return this; }
  public nFrontPanel updateWidth() { 
    super.updateWidth(); 
    if (current_tab != null && current_tab.panel.getLocalSX() != grabber.getLocalSX()) 
    grabber.setSX(current_tab.panel.getLocalSX());
    
    //is tabs hhave different width verify tabs width follow correctly
    if (grabber != null && tab_widgets != null) {
      float new_width = grabber.getLocalSX() / (tab_widgets.size());
      for (nWidget w : tab_widgets) w.setSX(new_width); 
      float moy_leng = 0;
      for (nWidget w : tab_widgets) moy_leng += w.getText().length();
      moy_leng /= tab_widgets.size();
      for (nWidget w : tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    }
    //current_tab.updateWidth(); 
    //logln("frontpanel " + panel.getLocalSX()); 
    
    return this; }
}
/*

  Complex Widget Objects
    Hilightable Front
      selectable, run event when selected
    linkedValue switch <> bool , field <> int float
    watcherValue field < int float
    ControlValue trigger > runnable , bool (switch it) , int float (increment / factor it)
    H / V Cursor > svalue
    Graph from sValue
      rectangular canvas with value history has graph
      auto scale, can do multi value
  Complex GUI Objects
    Info
      can appear on top of the mouse with text
    Menubar : series of horizontal switch mutualy exclusive
      auto adjust largeur
      each open a dropdown list of trigger button who close the menus
        close when clicked anywhere else
        on topmost layer
    Scrollbar up/down button, view bar, react to mouse 
      possibly react in a bigger zone than himself to acomodate scroll list
    Scrollable list from string list
      trigger / one select / multi select
    SelectZone
      draw a rectangular zone by click n dragging
      Hilightable front activated inside when releasing are marqued has selected
      they have event when selected / unselected
    
    Tool panel fixe on screen but collapsable (button to enlarg appear when mouse is close)
      can move away if camera move toward him
      all methods for widgets and complex widget creation
    
    Taskbar show pre choosen opened panel (collapsed or not) in rows n collumns
      trigger uncollapse and bring to front
    Panel
      has : title, background, default tab
      can has : 
        grabbable title, close button, reduc/enlarg button, 
        hilightable front for selection, 
        collapse to taskbar button, 
        menu bar, tab bar
      can add : menu, menu entry(trigger), tab
      tab : group of tabDrawer on top of background, one tab shown at a time
        can permit Y scroll through drawer
          des cache de la hauteur du plus grand drawer seront ajouté up n down
        can add a scrollbar
        tabs can change the panel back height
        TabDrawer
           all methods for widgets and complex widget creation
*/









class nColorPanel extends nWindowPanel {
  //nColorPanel setOkEvent_Builder(Runnable r) { ok_run = r; ok_run.builder = this; return this; }
  nWidget color_widget, red_widget, gre_widget, blu_widget;
  float red, gre, blu;
  //Runnable ok_run;
  sCol cval;
  nColorPanel(nGUI _g, nTaskPanel _task, sCol _cv) { 
    super(_g, _task, "color"); 
    cval = _cv;
    red = cval.getred(); gre = cval.getgreen(); blu = cval.getblue(); 
    getShelf()
      .addDrawer(10.25f, 1)
        .addWidget(new nSlide(gui, ref_size*7.375f, ref_size).setValue(cval.getred() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            red = v*255; update(); red_widget.setText(trimStringFloat(red)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25f, 1)
        .addWidget(new nSlide(gui, ref_size*7.375f, ref_size).setValue(cval.getgreen() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            gre = v*255; update(); gre_widget.setText(trimStringFloat(gre)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25f, 1)
        .addWidget(new nSlide(gui, ref_size*7.375f, ref_size).setValue(cval.getblue() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            blu = v*255; update(); blu_widget.setText(trimStringFloat(blu)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25f, 1)
        .addCtrlModel("Button-S2-P3", "OK")
          .setRunnable(new Runnable() { public void run() { clear(); } }).getDrawer()
          ;
        
    color_widget = getDrawer(0,3).addModel("Label-S3-P1")
          .setStandbyColor(color(red, gre, blu));
    red_widget = getDrawer(0,0)
        .addModel("Label_Small_Outline-S2", str(red)).setPX(7.5f*ref_size);
    gre_widget = getDrawer(0,1)
        .addModel("Label_Small_Outline-S2", str(gre)).setPX(7.5f*ref_size);
    blu_widget = getDrawer(0,2)
        .addModel("Label_Small_Outline-S2", str(blu)).setPX(7.5f*ref_size);
    
    if (cval == null) clear();
  } 
  public void update() { 
    if (cval != null) {
      color_widget.setStandbyColor(color(red, gre, blu)); 
      cval.set(color(red, gre, blu)); }
    else clear(); }
  public nWindowPanel clear() { 
    super.clear(); return this; }
  public nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  public nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}










class nCursor extends nWidget {
  public float x() { return pval.x(); }
  public float y() { return pval.y(); }
  public PVector dir() { if (dval.get().mag() > ref_size) return new PVector(dval.x(), dval.y()).setMag(1); 
                  else return new PVector(1, 0).rotate(random(2*PI)); }
  public PVector pos() { return new PVector(pval.x(), pval.y()); }
  nGUI gui;
  float ref_size;
  sVec pval, dval;
  sBoo show;
  String ref;
  nWidget refwidget, thiswidget, pointwidget;
  nCursor(nGUI _g, Macro_Sheet sheet, String r, String s) {
    super(_g);
    new nConstructor(_g.theme, _g.theme.ref_size);
    thiswidget = this;
    gui = _g; ref_size = _g.theme.ref_size; ref = r;
    copy(gui.theme.getModel("Cursor"));
    refwidget = gui.theme.newWidget(gui, "ref").setParent(this).setPosition(ref_size, ref_size);
    setSize(ref_size*2, ref_size*2);
    setPosition(-ref_size, -ref_size);
    setText(r).setFont(PApplet.parseInt(ref_size/2.0f)).setTextAlignment(LEFT, CENTER);
    setGrabbable();
    addEventDrag(new Runnable() {public void run() {pval.set(refwidget.getX(), refwidget.getY());}});
    pval = sheet.newVec(s+"_cursor_position", s+"_pos");
    pval.addEventChange(new Runnable(pval) {public void run() {
      sVec v = ((sVec)builder);
      thiswidget.setPosition(v.x()-ref_size, v.y()-ref_size);}});
    
    show = sheet.newBoo(false, s+"_cursor_show", s+"_show"); //!!!!! is hided by default
   
    pointwidget = gui.theme.newWidget(gui, "Pointer").setPosition(-ref_size/4, -ref_size/4).setSize(ref_size/2, ref_size/2);
    pointwidget.setParent(refwidget).setGrabbable().setConstrainDistance(ref_size*2).toLayerTop();
    dval = sheet.newVec(s+"_cursor_pointer", s+"_dir");
    dval.addEventChange(new Runnable(dval) {public void run() {
      sVec v = ((sVec)builder);
      if (v.get().mag() > ref_size*2) v.set(v.get().setMag(ref_size*2));
      pointwidget.setPosition(v.x()-ref_size/4, v.y()-ref_size/4); }});
    pointwidget.addEventDrag(new Runnable() {public void run() {
      dval.set(pointwidget.getLocalX() + ref_size/4, pointwidget.getLocalY() + ref_size/4);}});
    pointwidget.addEventLiberate(new Runnable() {public void run() {
      if (dval.get().mag() < ref_size) dval.set(0, 0); }});
    
    if (show.get()) { thiswidget.show(); pointwidget.show(); } else { thiswidget.hide(); pointwidget.hide(); }
    show.addEventChange(new Runnable(show) {public void run() {
    sBoo v = ((sBoo)builder);
      if (v.get()) { thiswidget.show(); pointwidget.show(); } else { thiswidget.hide(); pointwidget.hide(); } }});
  }
  public void clear() { 
    refwidget.clear(); pointwidget.clear(); super.clear(); 
    show.clear(); pval.clear(); dval.clear(); }
}





class nDropMenu extends nBuilder {
  
  public nDropMenu drop(nWidget op, float x, float y) { 
    opener = op; 
    ref.setPosition(x, y).show(); 
    for (nWidget w : menu_widgets) w.toLayerTop();
    toLayerTop();
    return this; }
  public nDropMenu drop(nGUI g) { 
    float p_x = g.mouseVector.x - larg/2;
    float p_y = g.mouseVector.y;
    if (!down) p_y += haut/2; else p_y -= haut/4; 
    float total_haut = haut*menu_widgets.size();
    
    if (p_x + larg > g.view.pos.x + g.view.size.x) p_x = g.view.pos.x + g.view.size.x - larg;
    if (p_x < g.view.pos.x) p_x = g.view.pos.x;
    if (down && p_y + total_haut > g.view.pos.y + g.view.size.y) 
      p_y = g.view.pos.y + g.view.size.y - total_haut;
    if (!down && p_y - total_haut < g.view.pos.y) p_y += g.view.pos.y - (p_y - total_haut);
    
    ref.setPosition(p_x, p_y).show(); 
    for (nWidget w : menu_widgets) w.toLayerTop();
    toLayerTop(); return this; }
  public nDropMenu close() { 
    ref.hide();
    return this; }
  public nDropMenu clear() { super.clear(); events.clear(); return this; }
  nWidget ref, opener;
  ArrayList<nWidget> menu_widgets = new ArrayList<nWidget>();
  ArrayList<Runnable> events = new ArrayList<Runnable>();
  int layer = 20;  float haut, larg;  boolean down, ephemere = false;
  
  nDropMenu(nGUI _gui, float ref_size, float width_factor, boolean _down, boolean _ephemere) {
    super(_gui, ref_size);
    haut = ref_size; larg = haut*width_factor; down = _down; ephemere = _ephemere;
    ref = addModel("ref").stackRight()
      .addEventFrame(new Runnable() { public void run() { 
        boolean t = false;
        for (nWidget w : menu_widgets) t = t || w.isHovered();
        if (opener != null) t = t || opener.isHovered();
        if ((gui.in.getClick("MouseLeft") || ephemere) && !t) close();
      } });
    if (!down) ref.stackUp(); 
  }
  public void click() {
    int i = 0;
    for (nWidget w : menu_widgets) {
      if (w.isOn()) { w.setOff(); break; }
      i++; }
    events.get(i).run();
    ref.hide();
  }
  public nWidget addEntry(String l, Runnable r) {
    nWidget ne = new nWidget(gui, l, PApplet.parseInt(haut/1.5f), 0, 0, larg, haut)
      .setSwitch() 
      .setLayer(layer)
      .setTextAlignment(LEFT, CENTER)
      .setHoverablePhantomSpace(ref_size / 4)
      .addEventSwitchOn(new Runnable() { public void run() { click(); }}) 
      ;
     if (!down) ne.stackUp(); else ne.stackDown();
    if (menu_widgets.size() > 0) ne.setParent(menu_widgets.get(menu_widgets.size()-1)); 
    else ne.setParent(ref);
    menu_widgets.add(ne);
    events.add(r);
    return ne;
  }
  public nCtrlWidget addEntry(String l) {
    nCtrlWidget ne = new nCtrlWidget(gui);
    ne.setText(l)
      .setFont(PApplet.parseInt(haut/1.5f))
      .setSize(larg, haut)
      .setHoverablePhantomSpace(ref_size / 4)
      //.addEventSwitchOn(new Runnable() { public void run() { click(); }}) 
      ;
    if (!down) ne.stackUp(); else ne.stackDown();
    if (menu_widgets.size() > 0) ne.setParent(menu_widgets.get(menu_widgets.size()-1)); 
    else ne.setParent(ref);
    menu_widgets.add(ne);
    events.add(new Runnable() { public void run() { }});
    return ne;
  }
}




class nExcludeGroup {
  ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  public void add(nWidget w) {
    excludes.add(w);
    w.addEventSwitchOn(new Runnable(w) { public void run() { 
      for (nWidget n : excludes) if (n != (nWidget)builder) n.setOff(); } } );
    w.addEventClear(new Runnable(w) { public void run() { 
      excludes.remove((nWidget)builder); } } );
  }
  public void closeAll() { for (nWidget n : excludes) n.setOff(); }
  public void forceCloseAll() { for (nWidget n : excludes) n.forceOff(); } 
  public void clear() { excludes.clear(); }
  //nExcludeGroup() {}
}




class nInfo {
  //  A AMELIORER
  //nInfo on cam react to object pos in cam space not on object pos on screen
  public void showText(String t) { 
    float s = t.length()*(ref.getLocalSX() / 1.2f);
    float p = -t.length()*(ref.getLocalSX() / 1.2f) / 2;
    if (ref.getLocalX() + p + s > gui.view.pos.x + gui.view.size.x) 
      p -= ref.getLocalX() + p + s - (gui.view.pos.x + gui.view.size.x);
    if (ref.getLocalX() + p < gui.view.pos.x) p += gui.view.pos.x - (ref.getLocalX() + p);
    if (invert) { ref.stackDown(); label.stackDown().setPY(0); }
    else        { ref.stackUp(); label.stackUp().setPY(0); }
    label.setPX(p).setSX(s);
    label.setText(t); ref.show(); count = 3; toLayerTop();  }
  public nInfo setLayer(int l) { label.setLayer(l); ref.setLayer(l); return this; }
  public nInfo toLayerTop() { label.toLayerTop(); ref.toLayerTop(); return this; }
  nInfo(nGUI _g, float f) {
    gui = _g;
    ref = new nWidget(gui, 0, 0, f/2, f/2).setPassif()
      .setDrawable(new Drawable(_g.drawing_pile) { public void drawing() {
        fill(ref.look.standbyColor);
        noStroke();
        if (invert) triangle(ref.getX(), ref.getY(), 
                 ref.getX() - ref.getSX()/2, ref.getY() + ref.getSY(), 
                 ref.getX() + ref.getSX()/2, ref.getY() + ref.getSY() );
        else triangle(ref.getX(), ref.getY() + ref.getSY(), 
                 ref.getX() - ref.getSX()/2, ref.getY(), 
                 ref.getX() + ref.getSX()/2, ref.getY() );
      } } )
      .addEventFrame(new Runnable() { public void run() {
        if (count > 0) {
          count--; if (count == 0) ref.hide();
          ref.setPosition(gui.mouseVector.x, gui.mouseVector.y);
          if (gui.mouseVector.y < ref.getLocalSY()*3 && !invert) invert = true;
          else if (gui.mouseVector.y > ref.getLocalSY()*6 && invert) invert = false; 
        }
      } } );
    ref.stackDown();
    label = new nWidget(gui, "", PApplet.parseInt(f*0.8f), 0, -f, 0, f*1).setPassif()
      .setParent(ref)
      .stackDown()
      ;
    ref.hide();
  }
  nWidget ref,label;
  nGUI gui;
  int count = 0; boolean invert = true;
}









class nExplorer extends nDrawer {
  boolean access_child = true;
  public nExplorer setChildAccess(boolean b) { access_child = b; return this; }
  ArrayList<String> explorer_entry;
  ArrayList<sValueBloc> explorer_blocs;
  ArrayList<sValue> explorer_values;
  sValueBloc explored_bloc, selected_bloc, starting_bloc;
  sValue selected_value;
  int selected_bloc_index = 0, selected_value_index = 0;
  nList explorer_list;
  
  public nExplorer setStrtBloc(sValueBloc sb) { if (sb != explored_bloc) { starting_bloc = sb; explored_bloc = sb; update(); } return this; }
  public nExplorer setBloc(sValueBloc sb) { if (sb != explored_bloc) { explored_bloc = sb; update(); } return this; }
  
  nShelf shelf;
  nWidget bloc_info, val_info;
  
  public nDrawer setLayer(int l) { super.setLayer(l); shelf.setLayer(l); return this; }
  public nDrawer toLayerTop() { super.toLayerTop(); shelf.toLayerTop(); return this; }
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  public nExplorer addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  
  public nExplorer addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  nExplorer(nShelf s) {
    super(s, s.ref_size*10, s.ref_size*9);
    explorer_entry = new ArrayList<String>();
    explorer_blocs = new ArrayList<sValueBloc>();
    explorer_values = new ArrayList<sValue>();
    shelf = new nShelf(s.shelfPanel, s.space_factor);
    shelf.addSeparator(0.25f);
    shelf.ref.setParent(ref);
    explorer_list = shelf.addList(5, 10, 1).setTextAlign(LEFT)
      .addEventChange_Builder(new Runnable() { 
      public void run() {
        int ind = ((nList)builder).last_choice_index;
        if (ind == 0 && explored_bloc != null && explored_bloc != starting_bloc) {
          explored_bloc = explored_bloc.parent;
          selected_bloc = null;
          selected_value = null;
          update_list();
          runEvents(eventChangeRun);
          
        } else if (ind != 0 && ind < explorer_blocs.size()+1) {
          if (selected_bloc == explorer_blocs.get(ind-1) && access_child) {
            explored_bloc = selected_bloc;
            selected_bloc = null;
            selected_value = null;
            update_list();
            runEvents(eventChangeRun);
          } else {
            selected_bloc = explorer_blocs.get(ind-1);
            selected_value = null;
            update_info();
            runEvents(eventChangeRun);
          }
        } else if (ind != 0 && ind - explorer_blocs.size() < explorer_values.size()+1) {
          selected_bloc = null;
          selected_value = explorer_values.get(ind-1 - explorer_blocs.size());
          
          update_info();
          runEvents(eventChangeRun);
        } 
      } } )
      ;
    
    bloc_info = shelf.addSeparator(0.25f)
      .addDrawer(1.4f)
        .addModel("Label-S4", "Selected Bloc :").setTextAlignment(LEFT, TOP);
    
    val_info = shelf.addSeparator(0.5f)
      .addDrawer(1.4f)
        .addModel("Label-S4", "Selected Value :").setTextAlignment(LEFT, TOP);
    
    update_list();
    
  }
  public void selectEntry(String r) {
    int i = 0;
    for (Map.Entry me : explored_bloc.blocs.entrySet()) {
      if (me.getKey().equals(r)) break;
      i++; }
    if (i < explorer_list.listwidgets.size()) explorer_list.listwidgets.get(i).setOn();
  }
  public void update_info() {
    if (selected_bloc != null) 
      bloc_info.setText("Selected Bloc :\n " + selected_bloc.type + " " + selected_bloc.ref);
    if (selected_value != null) 
      val_info.setText("Selected Value : " + selected_value.type + " " + selected_value.ref
                      +"\n = " + selected_value.getString() );
  }
  
  public void update() {
    selected_bloc = null;
    selected_value = null;
    update_list();
  }
  public void update_list() {
    explorer_entry.clear();
    explorer_blocs.clear();
    explorer_values.clear();
    if (explored_bloc != null) {
      //println(); println(explored_bloc.getHierarchy(false));
      if (explored_bloc != starting_bloc) explorer_entry.add("..");
      else explorer_entry.add("");
      for (Map.Entry me : explored_bloc.blocs.entrySet()) {
        sValueBloc cvb = (sValueBloc)me.getValue();
        explorer_blocs.add(cvb); 
        explorer_entry.add(cvb.base_ref + " " + cvb.use);
        //explorer_entry.add((String)me.getKey());
      }
      for (Map.Entry me : explored_bloc.values.entrySet()) {
        explorer_values.add((sValue)me.getValue()); 
        explorer_entry.add("   - "+(String)me.getKey());
      }
    }
    explorer_list.setEntrys(explorer_entry);
    update_info();
  }
  
}










class nList extends nDrawer {
  
  //nPanelDrawer panel_drawer = null;
  //nList setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  //nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  //nGUI gui;
  ArrayList<nWidget> listwidgets = new ArrayList<nWidget>();
  ArrayList<String> entrys = new ArrayList<String>();
  nWidget back, last_choice_widget;
  nScroll scroll;
  float item_s;
  float larg;
  int list_widget_nb = 5;
  int entry_pos = 0;
  boolean event_active = true;
  int last_choice_index = -1;
  String last_choice_text = null;
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  public nList addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  
  public nList addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  public nWidget getRefWidget() { return back; }
  
  int layer = 0;
  
  public nList setLayer(int l) {
    super.setLayer(l); 
    layer = l;
    scroll.setLayer(l);
    back.setLayer(l);
    for (nWidget w : listwidgets) w.setLayer(l);
    return this;
  }
  public nList toLayerTop() {
    super.toLayerTop();
    back.toLayerTop();
    scroll.toLayerTop();
    for (nWidget w : listwidgets) w.toLayerTop();
    return this;
  }
  public nList clear() {
    super.clear();
    scroll.clear();
    for (nWidget w : listwidgets) w.clear();
    back.clear();
    return this;
  }
  int align = CENTER;
  public nList setTextAlign(int a) { align = a; setListLength(list_widget_nb); return this; }
  nList(nShelf _sh, int _ent_nb, float _rs, float _lf, float _hf) {
    super(_sh, _rs*_lf, _rs*_hf*_ent_nb);
    list_widget_nb = _ent_nb;
    back = new nWidget(gui, 0, 0);
    back.setParent(ref)
      .addEventFrame(new Runnable() { public void run() {
        if (!back.isHided()) {
          for (nWidget w : listwidgets) { 
            if (w.isHovered() && gui.in.mouseWheelUp) {
              scroll.go_down();
            }
            if (w.isHovered() && gui.in.mouseWheelDown) {
              scroll.go_up();
            }
          }
        }
      }});
    item_s = ref_size*_hf; larg = ref_size*_lf;
    
    scroll = new nScroll(gui, larg - item_s, 0, item_s, item_s*list_widget_nb);
    scroll.getRefWidget().setParent(back);
    scroll.setView(list_widget_nb)
      .addEventChange(new Runnable() { public void run() {
        //int mov = scroll.entry_pos - entry_pos;
        //if (mov != 0 && last_choice_index >= 0 && last_choice_index < listwidgets.size()) 
        //  listwidgets.get(last_choice_index).setOff();
        entry_pos = scroll.entry_pos;
        //last_choice_index -= mov;
        //if (mov != 0 && last_choice_index >= 0 && last_choice_index < listwidgets.size()) { event_active = false;
        //  listwidgets.get(last_choice_index).setOn(); event_active = true; }
        
        update_list();
      }});
    setListLength(_ent_nb);
    
  }
  
  public void click() {
    if (event_active) {
      int i = 0;
      for (nWidget w : listwidgets) {
        if (w.isOn()) {
          w.setOff();
          break;
        }
        i++;
      }
      last_choice_index = i+entry_pos;
      last_choice_text = copy(listwidgets.get(i).getText());
      last_choice_widget = listwidgets.get(i);
      runEvents(eventChangeRun);
    }
  }
  public void unselect() { last_choice_index = -1; last_choice_text = ""; update_list(); }
  public void update_list() {
    last_choice_widget = null;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget w = listwidgets.get(i);
      if (i + entry_pos == last_choice_index) { 
        w.setLook(gui.theme, "List_Entry_Selected"); 
        last_choice_widget = w; }
      else w.setLook(gui.theme, "List_Entry");
      if (i + entry_pos < entrys.size()) w.setText(entrys.get(i + entry_pos)); else w.setText("");
    }
  }
  public nList setEntrys(ArrayList<String> l) {
  //nList setEntrys(String[] l) {
    entrys.clear();
    for (String s : l) entrys.add(copy(s));
    scroll.setPos(0);
    scroll.setEntryNb(l.size());
    //scroll.setEntryNb(l.length);

    scroll.setView(list_widget_nb);
    entry_pos = 0; 
    for (int i = 0 ; i < list_widget_nb ; i++) 
      if (i < entrys.size()) listwidgets.get(i).setSwitch();
      else listwidgets.get(i).setBackground();
    unselect();
    return this;
  }
  public nList setListLength(int l) {
    for (int i = 0 ; i < listwidgets.size() ; i++) listwidgets.get(i).clear();
    listwidgets.clear();
    list_widget_nb = l;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = gui.theme.newWidget(gui, "List_Entry").setSize(larg - item_s, item_s)
        .stackDown()
        .setTextAlignment(align, CENTER)
        .addEventSwitchOn_Builder(new Runnable() { public void run() {
          if (last_choice_widget != null && last_choice_widget != ((nWidget)builder)) 
            last_choice_widget.setLook(gui.theme, "List_Entry");
          ((nWidget)builder).setLook(gui.theme, "List_Entry_Selected");
          click();
        }})
        ;
      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
      listwidgets.add(ne);
    }
    for (nWidget w : listwidgets) w.toLayerTop();
    
    for (nWidget w : listwidgets) 
      for (nWidget w2 : listwidgets)
        if (w != w2) ;
          //w.addExclude(w2);
    
    scroll.setPos(0);
    scroll.setEntryNb(entrys.size());
    scroll.setView(list_widget_nb);
    entry_pos = 0;
    update_list();
    return this;
  }
  public nList setItemSize(float l) {
    item_s = l;
    scroll.getRefWidget().setPosition(larg - item_s, 0);
    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
    return this;
  }
  public nList setWidth(float l) {
    larg = l;
    scroll.getRefWidget().setPosition(larg - item_s, 0);
    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
    return this;
  }
}

class nScroll {
  nGUI gui;
  nWidget up, down, back, curs;
  float larg = 60;
  float haut = 200;
  int entry_nb = 1;
  int entry_pos = 0;
  int entry_view = 1;
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  public nScroll addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  public nScroll removeEventChange(Runnable r)       { eventChangeRun.remove(r); return this; }
  
  public nScroll setEntryNb(int v) { entry_nb = v; update_cursor(); return this; }
  public nScroll setView(int v) { entry_view = v; update_cursor(); return this; }
  public nScroll setPos(int v) { entry_pos = v; update_cursor(); return this; }
  
  public nScroll setHeight(float h) { haut = h; back.setSY(h); update_cursor(); return this; }
  public nScroll setWidth(float w) { 
    larg = w; back.setSX(w); up.setSize(w, w); down.setSize(w, w); curs.setSX(w);
    up.setOutlineWeight(w / 16).setFont(PApplet.parseInt(w/1.5f));
    down.setOutlineWeight(w / 16).setFont(PApplet.parseInt(w/1.5f));
    curs.setOutlineWeight(w / 16).setFont(PApplet.parseInt(w/1.5f));
    update_cursor(); return this; }
  
  public nWidget getRefWidget() { return back; }
  
  int layer = 0;
  
  public nScroll setLayer(int l) {
    layer = l;
    up.setLayer(l);
    down.setLayer(l);
    curs.setLayer(l);
    back.setLayer(l);
    return this;
  }
  public nScroll toLayerTop() {
    back.toLayerTop();
    up.toLayerTop();
    down.toLayerTop();
    curs.toLayerTop();
    return this;
  }
  public nScroll clear() {
    up.clear();
    down.clear();
    curs.clear();
    back.clear();
    return this;
  }
  
  nScroll(nGUI _gui, float x, float y, float w, float h) {
    gui = _gui;
    larg = w; haut = h;
    back = new nWidget(gui, x, y, w, h)
        .setStandbyColor(color(70))
        .toLayerTop()
        ;
    up = new nWidget(gui, "^", PApplet.parseInt(w/1.5f), 0, 0, w, w)
        .setParent(back)
        .toLayerTop()
        .setOutlineColor(color(100))
        .setLabelColor(color(180))
        .setTextAlignment(CENTER, BOTTOM)
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .setTrigger()
        .addEventFrame(new Runnable() { public void run() {
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelUp) {
            go_down();
          }
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelDown) {
            go_up();
          }
        }})
        .addEventTrigger(new Runnable() { public void run() {
          go_up();
        }})
        ;
    down = new nWidget(gui, "v", PApplet.parseInt(w/2.0f), 0, 0, w, w)
        .setParent(back)
        .toLayerTop()
        .setOutlineColor(color(100))
        .setLabelColor(color(180))
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .alignDown()
        .setTrigger()
        .addEventTrigger(new Runnable() { public void run() {
          go_down();
        }})
        ; 
    curs = new nWidget(gui, 0, 0, w, h-(w*2))
        .setParent(up)
        .toLayerTop()
        .stackDown()
        .setStandbyColor(color(100))
        ;
  }
  public void go_up() {
    if (entry_pos > 0) entry_pos--;
    update_cursor();
    runEvents(eventChangeRun);
  }
  public void go_down() {
    if (entry_pos < entry_nb - entry_view) entry_pos++;
    update_cursor();
    runEvents(eventChangeRun);
  }
  public void update_cursor() {
    if (entry_view <= entry_nb) {
      float h = haut - (larg*2);
      float d = h / entry_nb;
      curs.setSY(d*entry_view)
        .setPY(d*entry_pos);
    } else {
      curs.setSY(haut - (larg*2))
        .setPY(0);
    }
  }
}






class nSelectZone {
  Hoverable_pile pile;
  Drawable drawer;
  Rect select_zone = new Rect();
  boolean emptyClick = false;
  int clickDelay = 0;
  boolean ON = true;
  
  public nSelectZone addEventEndSelect(Runnable r)  { eventEndSelect.add(r); return this; }
  public nSelectZone removeEventEndSelect(Runnable r)       { eventEndSelect.remove(r); return this; }
  ArrayList<Runnable> eventEndSelect = new ArrayList<Runnable>();
  public nSelectZone addEventStartSelect(Runnable r)  { eventStartSelect.add(r); return this; }
  public nSelectZone removeEventStartSelect(Runnable r)       { eventStartSelect.remove(r); return this; }
  ArrayList<Runnable> eventStartSelect = new ArrayList<Runnable>();
  public nSelectZone addEventSelecting(Runnable r)  { eventStartSelect.add(r); return this; }
  public nSelectZone removeEventSelecting(Runnable r)       { eventStartSelect.remove(r); return this; }
  ArrayList<Runnable> eventSelecting = new ArrayList<Runnable>();
  
  public boolean isSelecting() { return emptyClick; }
  
  nGUI gui;
  nSelectZone(nGUI _g) {
    gui = _g;
    gui.addEventFrame(new Runnable() { public void run() { frame(); } } );
    pile = _g.hoverable_pile;
    pile.addEventNotFound(new Runnable() { public void run() { 
      if (ON && gui.in.getClick("MouseRight")) clickDelay = 1; 
    } } );
    drawer = new Drawable(_g.drawing_pile, 25) { public void drawing() {
      noFill();
      stroke(255);
      strokeWeight(2/gui.scale);
      Rect z = new Rect(select_zone);
      if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
      if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
      if (ON && emptyClick) z.draw();
    } };
  }
  public boolean isUnder(nWidget w) {
    Rect z = new Rect(select_zone);
    if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
    if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
    if (emptyClick && !w.isHided() && rectCollide(w.getRect(), z)) return true;
    return false;
  }
  public void frame() {
    if (ON) {
      if (clickDelay > 0) {
        clickDelay--;
        if (clickDelay == 0) { 
          emptyClick = true;
          select_zone.pos.x = gui.mouseVector.x;
          select_zone.pos.y = gui.mouseVector.y;
          select_zone.size.x = 1;
          select_zone.size.y = 1;
          runEvents(eventStartSelect);
        }
      }
      if (emptyClick) {
        runEvents(eventSelecting);
        select_zone.size.x = gui.mouseVector.x - select_zone.pos.x;
        select_zone.size.y = gui.mouseVector.y - select_zone.pos.y;
        if (gui.in.getUnClick("MouseRight")) { 
          runEvents(eventEndSelect);
          emptyClick = false; 
        }
      }
    }
    if (!gui.in.getState("MouseRight")) emptyClick = false;
  }
}




//class nPanel {
  
//  nPanelDrawer addDrawer(float h) {
//    nPanelDrawer d = new nPanelDrawer(this, back_h);
//    setBackHeight(back_h + h);
//    return d;
//  }
  
//  nPanel addSeparator(float h) {
//    setBackHeight(back_h + h);
//    return this;
//  }
  
//  nPanel end() {
//    setLayer(layer);
//    toLayerTop();
//    return this;
//  }
  
//  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
//  ArrayList<nList> lists = new ArrayList<nList>();
  
//  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
//  nPanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
//  nPanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
//  ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
//  nPanel addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
//  nPanel removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  
//  nWidget grabber, back, closer;
  
//  nGUI gui;
  
//  float haut = 60;
//  float larg = haut*10;
//  float back_h = 0;
  
//  int layer = 0;
  
//  nWidget getRefWidget() { return back; }
//  nWidget getGrabWidget() { return grabber; }
  
//  nPanel(nGUI _gui, String n, float x, float y) {
//    gui = _gui;
    
//    grabber = new nWidget(gui, n, int(haut/1.5), x, y, larg - haut, haut)
//      .setLayer(0)
//      .setGrabbable()
//      .setOutlineColor(color(100))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      .addEventDrag(new Runnable() { public void run() { runEvents(eventDragRun); } } )
//      ;
      
//    closer = new nWidget(gui, "X", int(haut/1.5), 0, 0, haut, haut)
//      .setTrigger()
//      .addEventTrigger(new Runnable() { public void run() { runEvents(eventCloseRun); clear(); } } )
//      .setParent(grabber)
//      .stackRight()
//      .setLayer(0)
//      .setOutlineColor(color(100))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      ;
//    back = new nWidget(gui, 0, 0, larg, 0) {
//      public void customShapeChange() {
//        //front.setSize(back.getLocalSX(), back.getLocalSY());
//      }
//    }
//      .setParent(grabber)
//      .stackDown()
//      .setLayer(0)
//      .setStandbyColor(color(40))
//      .setOutlineColor(color(180, 60))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      ;
//    grabber.toLayerTop();
//    closer.toLayerTop();
//  }
  
//  nPanel setPosition(float x, float y) { grabber.setPosition(x, y); return this; }
//  nPanel setItemHeight(float h) {
//    haut = h;
//    grabber.setSize(larg-haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    closer.setSize(haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    back.setSX(larg)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    return this;
//  }
//  nPanel setWidth(float w) {
//    larg = w;
//    grabber.setSize(larg-haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    closer.setSize(haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    back.setSX(larg)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    return this;
//  }
//  nPanel setBackHeight(float h) {
//    back_h = h;
//    back.setSY(back_h);
//    return this;
//  }
//  nPanel setLayer(int l) {
//    layer = l;
//    grabber.setLayer(l);
//    closer.setLayer(l);
//    back.setLayer(l);
//    for (nWidget w : widgets) w.setLayer(l);
//    for (nList  w : lists) w.setLayer(l);
//    return this;
//  }
//  nPanel toLayerTop() {
//    back.toLayerTop();
//    grabber.toLayerTop();
//    closer.toLayerTop();
//    for (nWidget w : widgets) w.toLayerTop();
//    for (nList  w : lists) w.toLayerTop();
//    return this;
//  }
//  nPanel hide() {
//    grabber.hide();
//    return this;
//  }
//  nPanel show() {
//    grabber.show();
//    return this;
//  }
//  nPanel clear() {
//    for (nWidget w : widgets) w.clear();
//    for (nList  w : lists) w.clear();
//    back.clear();
//    closer.clear();
//    grabber.clear();
//    return this;
//  }
//}




//class nPanelDrawer {
//  nPanel panel;
  
//  float pos = 0;
  
//  nPanelDrawer(nPanel _pan, float p) {
//    panel = _pan;
//    pos = p;
//  }
  
//  nPanel getPanel() { return panel; }
  
//  nWidget addWidget(String n, int f, float x, float y, float l, float h) {
//    nWidget w = new nWidget(panel.gui, n, f, x, y + pos, l, h);
//    w.setParent(panel.back).setPanelDrawer(this).setLayer(panel.layer);
//    panel.widgets.add(w);
//    return w;
//  }
  
//  nList addList(float x, float y, float w, float s) {
//    //nList l = new nList(panel.gui);
//    //l.getRefWidget()
//    //  .setParent(panel.getRefWidget())
//    //  .setPosition(x, y+pos);
//    //l.setPanelDrawer(this)
//    //  .setItemSize(s)
//    //  .setWidth(w)
//    //  .setLayer(panel.layer)
//    //  ;
//    //panel.lists.add(l);
//    //return l;
//    return null;
//  }

//}






 
  public void settings() {  fullScreen();  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "grows_2_8" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}