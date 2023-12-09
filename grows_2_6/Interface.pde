/*
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
  
*/



class sInterface extends sInput {
  nGUI screen_gui, cam_gui;
  Camera cam;
  DataHolder data; sValueBloc sbloc;
  sFramerate framerate;
  
  sInterface() {
    super();
    data = new DataHolder();
    sbloc = data.newBloc("interface");
    cam = new Camera(this);
    framerate = new sFramerate(data, 60);
    screen_gui = new nGUI(this);
    cam_gui = new nGUI(this)
      .setMouse(cam.mouse)
      .addEventNotFound(new Runnable() { public void run() { 
        if (!screen_gui.hoverable_pile.found) runEvents(eventsHoverNotFound);  
      } } )
      ;
    
    //new nWidget(cam_gui, 10, 10, 100, 50).setField(true);
    
  }
  
  nWidget newCamWidget() { return new nWidget(cam_gui); }
  nWidget newScreenWidget() { return new nWidget(screen_gui); }
  
  sInterface addCamDrawer(Drawer d) { d.setPile(cam_gui.drawing_pile); return this; }
  sInterface addScreenDrawer(Drawer d) { d.setPile(screen_gui.drawing_pile); return this; }
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsHoverNotFound = new ArrayList<Runnable>();
  sInterface addEventHoverNotFound(Runnable r) { eventsHoverNotFound.add(r); return this; }
  sInterface addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  
  void frame() {
    background(0);
    //fill(0,0,0,3);
    //noStroke();
    //rect(-10, -10, 10000, 10000);
    
    runEvents(eventsFrame);
    
    cam.pushCam();
    cam_gui.frame(true);
    cam_gui.draw();
    cam.popCam();
    
    screen_gui.frame(true);
    screen_gui.draw();
    
    //framerate:
    fill(255); 
    textSize(18);
    textAlign(LEFT);
    text(framerate.get() + " " + trimStringFloat(cam.mouse.x) + 
         " " + trimStringFloat(cam.mouse.y), 10, height - 12 );
    
    data.frame();
    framerate.frame();
    super.frame();
  }
  
}







//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


class Camera {
  sInterface inter;
  sValueBloc sbloc;
  sVec cam_pos; //position de la camera
  sFlt cam_scale; //facteur de grossicement
  float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true;
  sBoo grid; //show grid
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive

  boolean matrixPushed = false; //track if in or out of the cam matrix
  
  Camera(sInterface i) { 
    sbloc = new sValueBloc(i.sbloc, "cam");
    grid = new sBoo(sbloc, true, "show grid");
    cam_scale = new sFlt(sbloc, 1.0, "cam scale");
    cam_pos = new sVec(sbloc, "cam pos");
    inter = i; 
  }
  
  ArrayList<Runnable> eventsZoom = new ArrayList<Runnable>();
  Camera addEventZoom(Runnable r) { eventsZoom.add(r); return this; }
  ArrayList<Runnable> eventsDrag = new ArrayList<Runnable>();
  Camera addEventDrag(Runnable r) { eventsDrag.add(r); return this; }
  
  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement
  
  void pushCam() {
    PVector tm = screen_to_cam(inter.mouse);
    PVector tpm = screen_to_cam(inter.pmouse);
    PVector tmm = screen_to_cam(inter.mmouse);
    mouse.x = tm.x; mouse.y = tm.y;
    pmouse.x = tpm.x; pmouse.y = tpm.y;
    mmouse.x = tmm.x; mmouse.y = tmm.y;
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale.get());
    translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));
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

    //permet le cliquer glisser le l'ecran
    if (inter.getState("MouseLeft") && GRAB) { 
      cam_pos.add(mouseX - pmouseX, mouseY - pmouseY);
      runEvents(eventsDrag);
    }

    //permet le zoom
    if (inter.mouseWheelUp) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); 
      cam_pos.mult(1/ZOOM_FACTOR); 
      runEvents(eventsZoom);
    }
    if (inter.mouseWheelDown) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); 
      cam_pos.mult(ZOOM_FACTOR); 
      runEvents(eventsZoom);
    }
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
      translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));

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
  sValueBloc bloc;
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
  sInt sec_since_reset,frame_since_reset;
  
  int frameNbForMsDelay(int d) { return int(d * median_framerate.get() / 1000); }

  int get() { return int(median_framerate.get()); }
  
  sFramerate(DataHolder d, int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    frameR_history = new float[frameRate_cible];
    for (int i = 0 ; i < frameR_history.length ; i++) frameR_history[i] = 1000/frameRate_cible;
    
    bloc = d.newBloc("framerate");
    sec_since_reset = new sInt(bloc, 0, "sec_since_reset");
    frame_since_reset = new sInt(bloc, 0, "frame_since_reset");
    median_framerate = new sFlt(bloc, 0, "median_framerate");
    current_framerate = new sFlt(bloc, 0, "current_framerate");
    frame_duration = new sFlt(bloc, 0, "frame_duration");
  }
  void reset() { sec_since_reset.set(0); reset_time = millis(); frame_counter = 0; }
  
  void frame() {
    frame_counter++;
    frame_since_reset.set(frame_counter);
    
    current_time = millis();
    frame_length = current_time - prev_time;
    frame_duration.set(frame_length);
    current_framerate.set(frame_length / 1000);
    prev_time = current_time;
    
    sec_since_reset.set(int((current_time - reset_time) / 1000));
    
    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { hist_it = 0; }
    
    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0 ; i < frameR_history.length ; i++)  frame_median += frameR_history[i];
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

void mouseWheel(MouseEvent event) { 
  interf.mouseWheelEvent(event);
}  
void keyPressed() { 
  interf.keyPressedEvent();
}  
void keyReleased() { 
  interf.keyReleasedEvent();
}
void mousePressed() { 
  interf.mousePressedEvent();
}
void mouseReleased() { 
  interf.mouseReleasedEvent();
}
void mouseDragged() { 
  //interf.mouseDraggedEvent();
}
void mouseMoved() { 
  //interf.mouseMovedEvent();
}

class sInput_Button {
  boolean state = false, trigClick = false, trigUClick = false;
  //boolean trigJClick = false, trigJUClick = false;
  char key_char;
  String ref;
  sInput_Button(String r, char c) { ref = copy(r); key_char = c; }
  sInput_Button(String r) { ref = copy(r); }
  void eventPress() {
    state=true;
    trigClick=true;
  }
  void eventRelease() {
    state=false;
    trigUClick=true;
  }
  void frame() {
    trigClick = false; trigUClick = false;
  }
  
}

public class sInput {
  
  //keyboard letters
  boolean getState(char k) { return getKeyboardButton(k).state; }
  boolean getClick(char k) { return getKeyboardButton(k).trigClick; }
  boolean getUnClick(char k) { return getKeyboardButton(k).trigUClick; }
  
  //mouse n specials
  boolean getState(String k) { return getButton(k).state; }
  boolean getClick(String k) { return getButton(k).trigClick; }
  boolean getUnClick(String k) { return getButton(k).trigUClick; }
  
  char getLastKey() { return last_key; }
  
  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    mouseLeft = getButton("MouseLeft");
    mouseRight = getButton("MouseRight");
    mouseCenter = getButton("MouseCenter");
    keyBackspace = getButton("Backspace"); keyEnter = getButton("Enter");
    keyLeft = getButton("Left"); keyRight = getButton("Right");
    keyUp = getButton("Up"); keyDown = getButton("Down");
    keyAll = getButton("All"); //any key
    
  }
  
  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement
  boolean mouseWheelUp, mouseWheelDown;
  char last_key = ' ';
  
  ArrayList<sInput_Button> buttons = new ArrayList<sInput_Button>();
  sInput_Button mouseLeft,mouseRight,mouseCenter,
                keyBackspace,keyEnter,keyLeft,keyRight,keyUp,keyDown,keyAll;
  
  sInput_Button getButton(String r) {
    for (sInput_Button b : buttons) if (b.ref.equals(r)) return b;
    sInput_Button n = new sInput_Button(r); buttons.add(n);
    return n; }
  sInput_Button getKeyboardButton(char k) {
    for (sInput_Button b : buttons) if (b.ref.equals("k") && k == b.key_char) return b;
    sInput_Button n = new sInput_Button("k", k); buttons.add(n);
    return n; }
  
  void frame() {
    mouse.x = mouseX; mouse.y = mouseY; pmouse.x = pmouseX; pmouse.y = pmouseY;
    mmouse.x = mouseX - pmouseX; mmouse.y = mouseY - pmouseY;
    
    mouseWheelUp = false; mouseWheelDown = false;
    
    for (sInput_Button b : buttons) b.frame();
  }

  void mouseWheelEvent(MouseEvent event) {
    float e = event.getAmount();
    if (e>0) { mouseWheelUp =true; mouseWheelDown =false; }
    if (e<0) { mouseWheelDown = true; mouseWheelUp=false; }
  }  

  void keyPressedEvent() { 
    for (sInput_Button b : buttons) if (b.ref.equals("k") && b.key_char == key) b.eventPress();
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

  void keyReleasedEvent() { 
    for (sInput_Button b : buttons) if (b.ref.equals("k") && b.key_char == key) b.eventRelease(); 
    if (key == CODED) {
      if (keyCode == LEFT) keyLeft.eventRelease();
      if (keyCode == RIGHT) keyRight.eventRelease();
      if (keyCode == UP) keyUp.eventRelease();
      if (keyCode == DOWN) keyDown.eventRelease();
    } else {
      if (key == BACKSPACE) keyBackspace.eventRelease();
      if (key == ENTER) keyEnter.eventRelease();
      keyAll.eventRelease();
    }
  }

  void mousePressedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventPress();
    if (mouseButton==RIGHT) mouseRight.eventPress();
    if (mouseButton==CENTER) mouseCenter.eventPress();
  }

  void mouseReleasedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventRelease();
    if (mouseButton==RIGHT) mouseRight.eventRelease();
    if (mouseButton==CENTER) mouseCenter.eventRelease();
  }
}






 
