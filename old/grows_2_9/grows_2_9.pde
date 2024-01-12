/*

todo : see to of Macro_Sheet constructor in macmain

PApplet
  Log
    DEBUG_SAVE
    DEBUG_SCREEN_INFO
    log(string)
    logln()

  void setup()
    Interface
    Simulation(Interface)
    Prints

  void draw()
    Interface.frame  >  frame events, drawing
*/

boolean DEBUG_HOVERPILE = false;
boolean DEBUG_NOFILL = false;
boolean DEBUG_MACRO = true;

boolean DEBUG = true;

int global_frame_count = 0;

void log(String s) {
  if (DEBUG) print(s);
}
void logln(String s) {
  if (DEBUG) println(global_frame_count+":"+s);
}
void mlog(String s) {
  if (DEBUG_MACRO) print(s);
}
void mlogln(String s) {
  if (DEBUG_MACRO) println(s);
}

sInterface interf;

void setup() {//executé au demarage
  //size(1600, 900);//taille de l'ecran
  //surface.setLocation(200, 40);
  fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  surface.setResizable(true);
  
  interf = new sInterface(40);
  
  Simulation simul = (Simulation)interf.addUniqueSheet(new SimPrint());
  //Canvas canv = (Canvas)
  interf.addUniqueSheet(new CanvasPrint(simul));
  interf.addSpecializedSheet(new OrganismPrint(simul));
  interf.addSpecializedSheet(new GrowerPrint(simul));
  interf.addSpecializedSheet(new FlocPrint(simul));
  interf.addSpecializedSheet(new BoxPrint(simul));
  
  
  //logln("end models: "+interf.gui_theme.models.size());
  background(0);//fond noir
  
  //File file = new File(sketchPath());
  //if (file.isDirectory()) { String names[] = file.list(); } // all files in sketch directory
  interf.addEventNextFrame(new Runnable() { 
    public void run() { interf.addEventNextFrame(new Runnable() { 
      public void run() { interf.setup_load(); } } ); } } );
  
}


void draw() {//execute once by frame
  
  interf.frame();
  global_frame_count++;
  if (global_frame_count < 5) { fill(0); noStroke(); rect(0, 0, width, height); }
  
}

int base_width=1600; //non fullscreen width
int base_height=900; //non fullscreen height
boolean fullscreen=false;
void fs_switch() {
  if (fullscreen) {
    surface.setSize(base_width,base_height); 
    surface.setLocation(200, 40);
    fullscreen=false;
    surface.setAlwaysOnTop(false);
  } else {
    surface.setSize(displayWidth,displayHeight);
    fullscreen=true;
    surface.setLocation(0, 0);
    //surface.setFocus(true);
    surface.setAlwaysOnTop(true);
  }
}


void mouseWheel(MouseEvent event) { 
  interf.input.mouseWheelEvent(event);
}  
void keyPressed() { 
  interf.input.keyPressedEvent();
}  
void keyReleased() { 
  interf.input.keyReleasedEvent();
}
void mousePressed() { 
  interf.input.mousePressedEvent();
}
void mouseReleased() { 
  interf.input.mouseReleasedEvent();
}
void mouseDragged() { 
  //interf.input.mouseDraggedEvent();
}
void mouseMoved() { 
  //interf.input.mouseMovedEvent();
}




//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################



String copy(String s) { if (s != null) return s.substring(0, s.length()); else return null; }
String str_copy(String s) { if (s != null) return s.substring(0, s.length()); else return null; }

String trimStringFloat(float f) { return trimStringFloat(f, 3); }
String trimStringFloat(float f, int p) {
  String s;
  if (f%1.0 == 0.0) s = nfc(int(f)); else s = str(f);
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
  st = int(st / 2) * 2;
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





  




   
