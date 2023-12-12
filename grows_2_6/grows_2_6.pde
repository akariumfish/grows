/*
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


boolean DEBUG = true;
void log(String s) {
  if (DEBUG) print(s);
}
void logln(String s) {
  if (DEBUG) println(s);
}

sInterface interf;

Simulation simul;

GrowerComu gcom;
BoxComu bcom;
FlocComu fcom;


void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  //fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  
  interf = new sInterface();
  simul = new Simulation(interf);
  
  bcom = new BoxComu(simul);
  gcom = new GrowerComu(simul);
  fcom = new FlocComu(simul);
  
  //interf.toolpanel.reduc();
  //simsimul.pause.set(true);
  
  logln("end models: "+interf.gui_theme.models.size());
  background(0);//fond noir
}


void draw() {//executé once by frame
  interf.frame();
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



String copy(String s) { return s.substring(0, s.length()); }

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





  




   
