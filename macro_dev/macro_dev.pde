/*

 
 */

nGUI gui = new nGUI();

Ticking_pile tickpile = new Ticking_pile();

Macro_Main ms;

Macro_Output o;
Macro_Input i;

void mysetup() {
  ms = new Macro_Main(gui, tickpile, 70, 20);
  //ms.addSheet();
  //ms.do_load();
  ms.childDragged();
}


void mydraw() {
  gui.update();

  tickpile.tick();

  if (kb.mouseClick[0]) {
    //o.send( new Macro_Packet("test").addMsg("val") );
  }

  // apply camera view
  cam.pushCam();

  gui.draw();

  cam.popCam();
}



boolean DEBUG = true;
void log(String s) {
  if (DEBUG) println(s);
}





SpecialValue simval = new SpecialValue(); 

sInput kb;
Camera cam;
sFramerate fr;


Channel frame_start_chan = new Channel();
Channel frame_end_chan = new Channel();

void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  //fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing

  cam = new Camera(-700, -350, 3.0);
  kb = new sInput();
  fr = new sFramerate(60);

  mysetup();

  background(0);//fond noir
}


void draw() {//executé once by frame
  background(0);//fond noir
  //fill(0,0,0,3);
  //noStroke();
  //rect(-10, -10, 10000, 10000);


  //framerate
  fr.update();

  //check_overable();

  //call each frame
  callChannel(frame_start_chan);

  //call each frame
  callChannel(frame_end_chan);

  // affichage

  mydraw();




  //framerate:
  fill(255); 
  textSize(16);
  textAlign(LEFT);
  text(int(fr.get()) + " " + cam.getCamMouse().x + " " + cam.getCamMouse().y, 10, height - 10 );

  //info
  //if (!cp5.getTab("default").isActive()) {
  //  textSize(24);
  //  text("Click somewhere then hit ESC to quit",700,height - 30 );
  //}

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
  sInt value = new sInt(simval, 0);

  sInt time = new sInt(simval, 0);
  float reset_time = 0;

  sFlt tickrate = new sFlt(simval, 0);

  sFramerate(int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    for (int i = 0; i < frameR_history.length; i++) frameR_history[i] = 1000/frameRate_cible;
  }

  float get() { 
    return value.get();
  }

  void reset() { 
    time.set(0); 
    reset_time = millis();
  }

  void update() {

    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;

    time.set(int((current_time - reset_time) / 1000));

    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { 
      hist_it = 0;
    }

    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0; i < frameR_history.length; i++)  frame_median += frameR_history[i];
      frame_median /= frameR_history.length;
      value.set(int(1000/frame_median));
      //tickrate.set(value.get() * sim.tick_by_frame.get());
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
