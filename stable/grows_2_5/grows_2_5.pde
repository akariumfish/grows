/*

PApplet
  Log
    DEBUG_SAVE
    DEBUG_SCREEN_INFO
    log(string)
    logln()

  Graph    > data structure and math objects
    Rect    axis aligned
      pvector pos, size
      collision to rect point ...
    Point, Circle, Line, Trig, Poly (multi trig)
    draw methods: rect(Rect), triangle(Trig), line(Line)
    special draw:
      different arrow, interupted circle (cible), 
      chainable outlined line witch articulation connectable to rect circle or trig


  Inputs
    information disponible as variable / get methods / svalue
      keyboard
        getbool for each key state and triggers
      mouse
        getbool for each key state and triggers
        double click (delay set in real time)
        getWheel  getPointerPos  getPointerLastMove
        getbool for pointer movement state and trigger
      framerate
        median and current framerate
        frame duration
        frame and time counter total and resetable
        get frame number for delay of(ms)
      joystick / manette 
    frame()
  
  
  
  
  DataHolding
    class special value : svalue
      ref, type, val, changeevents(call each change / one by changing frame)
      can has limits (min max, float precision, vect mag or angle ...)
      
    class svalue bloc : svaluebloc
      string ref
      svalue map<string name, svalue>
        for bool int float string vector color
    
    svalue bloc map<string name, bloc>   each bloc loaded and saved independently
    runnables map<string name, run>      string-referanced runnables for saving
    
    frame()
      for bloc : map runFrameEventsIf() unFlagChanges()
    
    class sdata
      string ref data
    class sdatabloc
      string ref
      list<sdata>
      list<sbloc>
    save and load sdatabloc from file methods
    svaluebloc To sdatabloc  /  svaluebloc From sdatabloc()
  
  
  
  Animation
    AnimationFrame     abstract void draw()
    list<animframe>
    draw() circle throug frame at each call
    
  
  
  Drawer
    abstract void draw()
    int layer
    DrawerPile
    bool show
    CameraView
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
  
  
  Interface(Inputs, DataHolding)
    class CameraView 
      name
      pos and scale as svalue
    map<name, CameraView> : views
    name of current view as svalue
    drawing_pile screen_draw, cam_draw
    hover_pile screen and cam
    event hoverpilesearch both no find
    list<runnable> frameEvents
    add widget methods
    frame()
      hover_pile.search() if screen found dont do cam
      run frameEvents
      update cam view from inputs
      clear screen
      draw grid if needed
      draw cam then screen from their pov
    to control when to screenshot maybe do it in a Drawer
    
    Global GUI Theme 
      can be picked from by widgets 
      ? list of widgets to update when is changed ?
      map of color and name
      map of size and name
    map<name, widget> models
      methods to directly build a widget from models
  
  Widget(Interface)
    bool:is on screen or cam
    can move between cam and screen (and keeping relative pos if needed)
  Widget typical Objects
    Trigger Button can command svalue
    switch button can command svalue
    label can watch svalue
    separating line
  Complex Widget Objects
    Hilightable Front
      selectable, run event when selected
    Menubar : series of horizontal switch mutualy exclusive
      auto adjust largeur
      each open a dropdown list of trigger button who close the menus
        close when clicked anywhere else
        on topmost layer
    Scrollbar up/down button, view bar, react to mouse 
      possibly react in a bigger zone than himself to acomodate scroll list
    Scrollable list from string list
      trigger / one select / multi select
    H / V Cursor > svalue
    Graph from sValue
      rectangular canvas with value history has graph
      auto scale, can do multi value
    sValue controller widget for easy svalue change by increment or factor
      ex: trig x - text value - trig /
  Complex GUI Objects
    Info
      can appear on top of the mouse with text
    SelectZone
      draw a rectangular zone by click n dragging
      Hilightable front activated inside when releasing are marqued has selected
      they have event when selected / unselected
    Tool panel fixe on screen but collapsable (button to enlarg appear when mouse is close)
      can move away if camera move toward him
      all methods for widgets and complex widget creation
    TaskBar show pre choosen opened panel (collapsed or not) in rows n collumns
      trigger uncollapse and bring to front
    Panel
      has : title, background, default tab
      can has : 
        grabbable title, close button, reduc/enlarg button, 
        hilightable front for selection, 
        collapse to taskbar button, menubar, tab bar
      can add : menu, menu entry(trigger), tab
      tab : group of tabDrawer on top of background, one tab shown at a time
        can permit Y scroll through drawer
          des cache de la hauteur du plus grand drawer seront ajouté up n down
        can add a scrollbar
        tabs can change the panel back height
        TabDrawer
           all methods for widgets and complex widget creation
  
  
  
  
  Simulation(Input, Data, Interface)
    Build with interface
      toolPanel down left to down center with main function
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
      width 1200
      draw : invisible, particle 1px, pebble 5px, small 25px, med 100px, 
             big 400px, fullscreen 1100px, zoom in 3000px, micro 10 000px, too big 100 000px
    frame()
      drive ticking
    macro_main
      each community have her sheet inside whom community param and runnable can be acsessed
      maybe for each community her is an independent macro space who can acsess an entity
      property and who can be applyed to each entity of this commu
      there can be plane who take entity from different commu to make them interact
      
  Macro_Main(Input, Data, Interface)
    tick()
    addTickAskMethod
    add show/hide button in sim toolpanel ( go back n forth between two camera view )
    add entry to sim main menu to create macro main panel
    macro main panel
      tab file
        select save file
        clear/save/load all
      tab add to selected sheet
        child sheet
        sheet in/out
          can be named
        basic macro
        macro for svalue watch/ctrl
        macro to launch referanced runnables
      tab templates
        select template list file
        save selected sheet as template
        template list 
          trigger creation of selected template as child in selected sheet
          can trigger deletion of selected template
    
      
  
  void draw()
    Inputs.frame
    Data.frame
    Simulation.frame
    Interface.frame  >  drawing
    










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



boolean DEBUG = true;
void log(String s) {
  if (DEBUG) println(s);
}



ControlP5 cp5; //l'objet main pour les menu

SpecialValue simval = new SpecialValue(); 

nGUI cam_gui,screen_gui;

Ticking_pile tickpile;

Macro_Main macro_main;

sInput kb;
Camera cam;
sFramerate fr;

Simulation sim;

Channel frame_chan = new Channel();
Channel frameend_chan = new Channel();

GrowerComu gcom;
FlocComu fcom;
BoxComu bcom;

void setup() {//executé au demarage
  //size(1600, 900);//taille de l'ecran
  fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  
  cam = new Camera();
  kb = new sInput();
  fr = new sFramerate(60);
  
  cp5 = new ControlP5(this);
  init_Tabs("Menu");
  
  cam_gui = new nGUI();
  screen_gui = new nGUI();
  screen_gui.on_screen = true;
  screen_gui.szone.ON = false;
  
  sim = new Simulation();
  
  bcom = new BoxComu(sim);
  gcom = new GrowerComu(sim);
  fcom = new FlocComu(sim);
  
  sim.building();
  
  loading(simval, "save.txt");
  sim.reset();
  
  tickpile = new Ticking_pile();
  macro_main = new Macro_Main(cam_gui, screen_gui, tickpile, 900, 20);
  new Callable() { public void answer(Channel channel, float value) { tickpile.tick(); } }
    .addChannel(sim.tick_chan);
  macro_main.addTickAskMethod(new Runnable() { public void run() { sim.next_tick = true; } } );
  
  macro_main.sdata_load();
  
  mySetup();
  
  background(0);//fond noir
}


void draw() {//executé once by frame
  background(0);//fond noir
  //fill(0,0,0,3);
  //noStroke();
  //rect(-10, -10, 10000, 10000);
  //framerate
  fr.update();
  callChannel(frameend_chan);
  
  String m_tab = "Menu";
  cam_gui.update(cp5.getTab(m_tab).isActive());
  screen_gui.update(cp5.getTab(m_tab).isActive());
  
  //execution de la simulation
  sim.frame();
  
  //call each frame
  callChannel(frame_chan);
  
  // affichage
  // apply camera view
  cam.pushCam();
  
  //simulation draw to camera
  sim.draw_to_cam();
  
  if (cp5.getTab(m_tab).isActive()) cam_gui.draw();
  
  //pop cam view and cam updates
  cam.popCam();
  
  //simulation draw to screen
  sim.draw_to_screen();
  
  if (cp5.getTab(m_tab).isActive()) screen_gui.draw();
  
  //framerate:
  fill(255); 
  textSize(16);
  textAlign(LEFT);
  text(int(fr.get()) + " " + cam.getCamMouse().x + " " + cam.getCamMouse().y, 400, height - 10 );

  //info
  if (!cp5.getTab("default").isActive()) {
    textSize(24);
    text("Click somewhere then hit ESC to quit",700,height - 30 );
  }
  
  //reset des flag de changement des svalue
  simval.unFlagChange();
  
  kb.update(); // input
}




//#######################################################################
//##                           FRAMERATE                               ##
//#######################################################################


class sFramerate {
  int frameRate_cible = 60;
  
  float[] frameR_history = new float[frameRate_cible];
  int hist_it = 0;
  int frameR_update_rate = 10; // frames between update 
  int frameR_update_counter = frameR_update_rate;
  
  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;
  
  float frame_median = 0;
  sInt value = new sInt(simval, 0, "sFramerate");
  
  sInt time = new sInt(simval, 0);
  float reset_time = 0;
  
  sFlt tickrate = new sFlt(simval, 0);
  
  sFramerate(int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    for (int i = 0 ; i < frameR_history.length ; i++) frameR_history[i] = 1000/frameRate_cible;
  }
  
  float get() { return value.get(); }
  
  void reset() { time.set(0); reset_time = millis(); }
  
  void update() {
    
    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;
    
    time.set(int((current_time - reset_time) / 1000));
    
    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { hist_it = 0; }
    
    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0 ; i < frameR_history.length ; i++)  frame_median += frameR_history[i];
      frame_median /= frameR_history.length;
      value.set(int(1000/frame_median));
      tickrate.set(value.get() * sim.tick_by_frame.get());
      frameR_update_counter = 0;
    }
    frameR_update_counter++;
  }
}




//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


class Camera {
  PVector cam_pos = new PVector(0, 0); //position de la camera
  sFlt cam_scale = new sFlt(simval, 1.0); //facteur de grossicement
  float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true;
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive

  boolean matrixPushed = false;

  sBoo grid = new sBoo(simval, true);

  sFlt pos_x = new sFlt(simval, 0);
  sFlt pos_y = new sFlt(simval, 0);
  boolean pos_loaded = false;

  Channel zoom_chan = new Channel();
  
  Camera() {}
  Camera(float x, float y, float s) { pos_x.set(x); pos_y.set(y); cam_scale.set(s); }

  PVector getCamMouse() { 
    return screen_to_cam(new PVector(mouseX, mouseY));
  }
  PVector getPCamMouse() { 
    return screen_to_cam(new PVector(pmouseX, pmouseY));
  }

  PVector cam_to_screen(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
    } else {
      pushMatrix();
      translate(width / 2, height / 2);
      scale(cam_scale.get());
      translate((cam_pos.x / cam_scale.get()), (cam_pos.y / cam_scale.get()));

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);

      popMatrix();
    }
    return r;
  }

  PVector screen_to_cam(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    } else {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    }
    return r;
  }

  void pushCam() {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale.get());
    translate((cam_pos.x / cam_scale.get()), (cam_pos.y / cam_scale.get()));
    matrixPushed = true;

    if (grid.get() && cam_scale.get() > 0.0008) {
      int spacing = 200;
      if (cam_scale.get() > 2) spacing /= 5;
      if (cam_scale.get() < 0.2) spacing *= 5;
      if (cam_scale.get() < 0.04) spacing *= 5;
      if (cam_scale.get() < 0.008) spacing *= 5;
      stroke(100);
      strokeWeight(2.0 / cam_scale.get());
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

  void popCam() {
    popMatrix();
    matrixPushed = false;
    if (screenshot) { 
      saveFrame("image/shot-########.png");
    }
    screenshot = false;

    if (!pos_loaded) {
      cam_pos.set(pos_x.get(), pos_y.get());
      pos_loaded = true;
    }

    //permet le cliquer glisser le l'ecran
    if (kb.mouseButtons[0] && GRAB) { 
      cam_pos.add(mouseX - pmouseX, mouseY - pmouseY); 
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }

    //permet le zoom
    if (kb.mouseWheelUp) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); 
      cam_pos.mult(1/ZOOM_FACTOR); 
      callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
    if (kb.mouseWheelDown) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); 
      cam_pos.mult(ZOOM_FACTOR); 
      callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
  }
}



//#######################################################################
//##                             INPUT                                 ##
//#######################################################################


void mouseWheel(MouseEvent event) { 
  kb.mouseWheelEvent(event);
}  
void keyPressed() { 
  kb.keyPressedEvent();
}  
void keyReleased() { 
  kb.keyReleasedEvent();
}
void mousePressed() { 
  kb.mousePressedEvent();
}
void mouseReleased() { 
  kb.mouseReleasedEvent();
}
void mouseDragged() { 
  kb.mouseDraggedEvent();
}
void mouseMoved() { 
  kb.mouseMovedEvent();
}

public class sInput {

  boolean keyButton, keyClick, keyJClick, keyUClick, keyJUClick;
  boolean[] keysButtons, keysClick, keysJClick, keysUClick, keysJUClick;
  boolean[] mouseButtons, mouseClick, mouseJClick, mouseUClick, mouseJUClick;
  boolean mouseMove = false;
  boolean mouseWheelUp = false;
  boolean mouseWheelDown = false;
  char last_key = ' ';

  char[] keys_code = { 'a', 'b', 'c', 'd'};
  int keyNb = keys_code.length;

  boolean getButton(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysButtons[i]) return true;
    return false;
  }

  boolean getClick(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysClick[i]) return true;
    return false;
  }

  boolean getUnclick(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysUClick[i]) return true;
    return false;
  }

  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    keysButtons = new boolean[keyNb];
    keysClick = new boolean[keyNb]; 
    keysJClick = new boolean[keyNb];
    keysUClick = new boolean[keyNb]; 
    keysJUClick = new boolean[keyNb];

    for (int i = keyNb-1; i >= 0; i--) {
      keysButtons[i] = false;
      keysClick[i] = false; 
      keysJClick[i] = false;
      keysUClick[i] = false; 
      keysJUClick[i] = false;
    }

    keyButton = false;
    keyClick = false; 
    keyJClick = false;
    keyUClick = false; 
    keyJUClick = false;

    mouseButtons = new boolean[3];
    mouseClick = new boolean[3]; 
    mouseJClick = new boolean[3];
    mouseUClick = new boolean[3]; 
    mouseJUClick = new boolean[3];

    for (int i = 2; i >= 0; i--) {
      mouseButtons[i] = false;
      mouseClick[i] = false; 
      mouseJClick[i] = false;
      mouseUClick[i] = false; 
      mouseJUClick[i] = false;
    }
  }

  public void update() {
    mouseWheelUp = false; 
    mouseWheelDown = false;
    if (mouseX == pmouseX && mouseY == pmouseY) {
      mouseMove = false;
    }
    for (int i = 2; i >= 0; i--) {
      if (mouseClick[i] == true && mouseJClick[i] == false) {
        mouseJClick[i] = true;
      }
      if (mouseClick[i] == true && mouseJClick[i] == true) {
        mouseClick[i] = false; 
        mouseJClick[i] = false;
      }
      if (mouseUClick[i] == true && mouseJUClick[i] == false) {
        mouseJUClick[i] = true;
      }
      if (mouseUClick[i] == true && mouseJUClick[i] == true) {
        mouseUClick[i] = false; 
        mouseJUClick[i] = false;
      }
    }
    for (int i = keyNb-1; i >= 0; i--) {
      if (keysClick[i] == true) {
        keysJClick[i] = true;
      }
      if (keysClick[i] == true && keysJClick[i] == true) {
        keysClick[i] = false; 
        keysJClick[i] = false;
      }
      if (keysUClick[i] == true) {
        keysJUClick[i] = true;
      }
      if (keysUClick[i] == true && keysJUClick[i] == true) {
        keysUClick[i] = false; 
        keysJUClick[i] = false;
      }
    }
    if (keyClick == true) {
      keyJClick = true;
    }
    if (keyClick == true && keyJClick == true) {
      keyClick = false; 
      keyJClick = false;
    }
    if (keyUClick == true) {
      keyJUClick = true;
    }
    if (keyUClick == true && keyJUClick == true) {
      keyUClick = false; 
      keyJUClick = false;
    }
  }

  void mouseWheelEvent(MouseEvent event) {
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

  void keyPressedEvent()
  {
    for (int i = 0; i < keyNb; i++)
      if (key==keys_code[i]) {
        keysButtons[i]=true;
        keysClick[i]=true;
      }
    keyButton=true;
    keyClick=true;
  }

  void keyReleasedEvent()
  {
    for (int i = 0; i < keyNb; i++)
      if (key==keys_code[i]) {
        keysButtons[0]=false;
        keysUClick[0]=true;
      }
    keyButton=false;
    keyUClick=true;
  }

  void mousePressedEvent()
  {
    if (mouseButton==LEFT) {
      mouseButtons[0]=true;
      mouseClick[0]=true;
    }
    if (mouseButton==RIGHT) {
      mouseButtons[1]=true;
      mouseClick[1]=true;
    }
    if (mouseButton==CENTER) {
      mouseButtons[2]=true;
      mouseClick[2]=true;
    }
  }

  void mouseReleasedEvent()
  {
    if (mouseButton==LEFT) {
      mouseButtons[0]=false;
      mouseUClick[0]=true;
    }
    if (mouseButton==RIGHT) {
      mouseButtons[1]=false;
      mouseUClick[1]=true;
    }
    if (mouseButton==CENTER) {
      mouseButtons[2]=false;
      mouseUClick[2]=true;
    }
  }

  void mouseDraggedEvent() { 
    mouseMove = true;
  }

  void mouseMovedEvent() { 
    mouseMove = true;
  }
}
