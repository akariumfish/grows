import themidibus.*;

/*

todo : see top of Macro_Sheet  MacSh.pde
  double click
  right click on widget

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
boolean DEBUG_MACRO = false;

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
  
  setup_midi();
  
  interf = new sInterface(40);
  
  Simulation simul = (Simulation)interf.addUniqueSheet(new SimPrint());
  Canvas canv = (Canvas) interf.addUniqueSheet(new CanvasPrint(simul));
  interf.addSpecializedSheet(new FacePrint(canv));
  interf.addSpecializedSheet(new OrganismPrint(simul));
  interf.addSpecializedSheet(new GrowerPrint(simul));
  interf.addSpecializedSheet(new FlocPrint(simul));
  interf.addSpecializedSheet(new BoxPrint(simul));
  
  
  //logln("end models: "+interf.gui_theme.models.size());
  background(0);//fond noir
  
  
  interf.addEventNextFrame(new Runnable() { 
    public void run() { interf.addEventNextFrame(new Runnable() { 
      public void run() { interf.setup_load(); } } ); } } );
  
  app_grab = new nWidget(interf.screen_gui, "Grows 3.0", 28, 0, 0, base_width - 40, 40)
    .setTrigger()
    .addEventTrigger(new Runnable() { 
    public void run() { mx = mouseX; my = mouseY; } } )
    .addEventPressed(new Runnable() { 
    public void run() { 
      sx = int(mouseX + sx - mx);
      sy = int(mouseY + sy - my);
      surface.setLocation(sx, sy); 
    } } );
  app_close = new nWidget(interf.screen_gui, "X", 28, base_width - 40, 0, 40, 40)
    .setTrigger()
    .addEventTrigger(new Runnable() { 
    public void run() { exit(); } } );
  
  interf.full_screen_run.run();
  interf.full_screen_run.run();
  interf.full_screen_run.run();
  surface.setLocation(200, 40);
}

nWidget app_grab, app_close;
float window_head = 40;
float mx, my;
int sx, sy;

void draw() {//execute once by frame
  //translate(0, 40);
  interf.frame();
  global_frame_count++;
  if (global_frame_count < 5) { fill(0); noStroke(); rect(0, 0, width, height); }
  
}

int base_width=1600; //non fullscreen width
int base_height=940; //non fullscreen height
boolean fullscreen=true;
void fs_switch() {
  if (fullscreen) {
    app_grab.show();
    app_close.show();
    surface.setSize(base_width,base_height); 
    surface.setLocation(200, 40);
    sx = 200; sy = 40;
    fullscreen=false;
    surface.setAlwaysOnTop(false);
  } else {
    app_grab.hide();
    app_close.hide();
    surface.setSize(displayWidth,displayHeight + int(window_head));
    fullscreen=true;
    surface.setLocation(0, -int(window_head));
    sx = 0; sy = -int(window_head);
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
//##                             MIDIBus                               ##
//#######################################################################

MidiBus midiBus;

void setup_midi() {
  //MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //midiBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //midiBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

  // or for testing you could ...
  //                   Parent  In        Out
  //                     |     |          |
  //midiBus = new MidiBus(this, -1, "Java Sound Synthesizer"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  
}
void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  //println();
  //println("Note On:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
  interf.macro_main.noteOn(channel, pitch, velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  //println();
  //println("Note Off:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Pitch:"+pitch);
  //println("Velocity:"+velocity);
  interf.macro_main.noteOff(channel, pitch, velocity);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  //println();
  //println("Controller Change:");
  //println("--------");
  //println("Channel:"+channel);
  //println("Number:"+number);
  //println("Value:"+value);
  interf.macro_main.controllerChange(channel, number, value);
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









  




   
