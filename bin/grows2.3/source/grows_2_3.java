import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class grows_2_3 extends PApplet {

/*

           
*/

ControlP5 cp5; //l'objet main pour les menu

SpecialValue simval = new SpecialValue(); 

sInput kb;
Camera cam;
sFramerate fr;

Simulation sim;
MacroPlane plane;

Channel frame_chan = new Channel();
Channel frameend_chan = new Channel();

GrowerComu gcom;
FlocComu fcom;
BoxComu bcom;

public void setup() {//executé au demarage
  //size(1600, 900);//taille de l'ecran
  
  //pas d'antialiasing
  //smooth();//anti aliasing
  
  cam = new Camera();
  kb = new sInput();
  fr = new sFramerate(60);
  
  cp5 = new ControlP5(this);
  init_Tabs("Menu");
  
  sim = new Simulation();
  plane = new MacroPlane();
  
  bcom = new BoxComu(sim);
  gcom = new GrowerComu(sim);
  fcom = new FlocComu(sim);
  
  
  sim.building();
  
  loading(simval, "save.txt");
  sim.reset();
  
  background(0);//fond noir
}


public void draw() {//executé once by frame
  background(0);//fond noir
  //fill(0,0,0,3);
  //noStroke();
  //rect(-10, -10, 10000, 10000);
  //framerate
  fr.update();
  callChannel(frameend_chan);
  //execution de la simulation
  sim.frame();
  
  //frame update des macros
  plane.frame();
  
  //call each frame
  callChannel(frame_chan);
  
  // affichage
  // apply camera view
  cam.pushCam();
  
  //simulation draw to camera
  sim.draw_to_cam();
  
  //pop cam view and cam updates
  cam.popCam();
  
  //simulation draw to screen
  sim.draw_to_screen();
  
  //macro drawings
  plane.drawing();
  
  //framerate:
  fill(255); textSize(16);
  text(PApplet.parseInt(fr.get()),10,height - 10 );
  
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
  sInt value = new sInt(simval, 0);
  
  sInt time = new sInt(simval, 0);
  float reset_time = 0;
  
  sFlt tickrate = new sFlt(simval, 0);
  
  sFramerate(int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    for (int i = 0 ; i < frameR_history.length ; i++) frameR_history[i] = 1000/frameRate_cible;
  }
  
  public float get() { return value.get(); }
  
  public void reset() { time.set(0); reset_time = millis(); }
  
  public void update() {
    
    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;
    
    time.set(PApplet.parseInt((current_time - reset_time) / 1000));
    
    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { hist_it = 0; }
    
    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0 ; i < frameR_history.length ; i++)  frame_median += frameR_history[i];
      frame_median /= frameR_history.length;
      value.set(PApplet.parseInt(1000/frame_median));
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
  sFlt cam_scale = new sFlt(simval, 0.2f); //facteur de grossicement
  float ZOOM_FACTOR = 1.1f; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true;
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
  
  boolean matrixPushed = false;
  
  sBoo grid = new sBoo(simval, false);
  
  sFlt pos_x = new sFlt(simval, 0);
  sFlt pos_y = new sFlt(simval, 0);
  boolean pos_loaded = false;
  
  Channel zoom_chan = new Channel();
  
  public PVector cam_to_screen(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
    } else {
      pushMatrix();
      translate(width / 2, height / 2);
      scale(cam_scale.get());
      translate((cam_pos.x / cam_scale.get()), (cam_pos.y / cam_scale.get()));
      
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      
      popMatrix();
    }
    return r;
  }
  
  public PVector screen_to_cam(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      
      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      popMatrix();
    } else {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale.get()), -(cam_pos.y / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      popMatrix();
    }
    return r;
  }
  
  public void pushCam() {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale.get());
    translate((cam_pos.x / cam_scale.get()), (cam_pos.y / cam_scale.get()));
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
      s.x -= s.x%spacing; s.y -= s.y%spacing;
      PVector m = screen_to_cam( new PVector(width, height) );
      for (float x = s.x ; x < m.x ; x += spacing) {
        if ( ( (x-(x%spacing)) / spacing) % 5 == 0 ) stroke(100); else stroke(70);
        if (x == 0) stroke(150, 0, 0);
        line(x, s.y, x, m.y);
      }
      for (float y = s.y ; y < m.y ; y += spacing) {
        if ( ( (y-(y%spacing)) / spacing) % 5 == 0 ) stroke(100); else stroke(70);
        if (y == 0) stroke(150, 0, 0);
        line(s.x, y, m.x, y);
      }
    }
  }
  
  public void popCam() {
    popMatrix();
    matrixPushed = false;
    if (screenshot) { saveFrame("image/shot-########.png"); }
    screenshot = false;
    
    if (!pos_loaded) {
      cam_pos.set(pos_x.get(),pos_y.get());
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
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); cam_pos.mult(1/ZOOM_FACTOR); callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
    if (kb.mouseWheelDown) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); cam_pos.mult(ZOOM_FACTOR); callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
  }
}



//#######################################################################
//##                             INPUT                                 ##
//#######################################################################


public void mouseWheel(MouseEvent event) { kb.mouseWheelEvent(event); }  
public void keyPressed() { kb.keyPressedEvent(); }  
public void keyReleased() { kb.keyReleasedEvent(); }
public void mousePressed() { kb.mousePressedEvent(); }
public void mouseReleased() { kb.mouseReleasedEvent(); }
public void mouseDragged() { kb.mouseDraggedEvent(); }
public void mouseMoved() { kb.mouseMovedEvent(); }

public class sInput {
  boolean[] keysButtons, keysClick, keysJClick, keysUClick, keysJUClick;
  boolean[] mouseButtons, mouseClick, mouseJClick, mouseUClick, mouseJUClick;
  boolean mouseMove = false;
  boolean mouseWheelUp = false;
  boolean mouseWheelDown = false;
  
  char[] keys_code = { 'a', 'b', 'c', 'd'};
  int keyNb = keys_code.length;
  
  public boolean getButton(char c) {
    for (int i = 0 ; i < keys_code.length ; i++)
      if (keys_code[i] == c && keysButtons[i]) return true;
    return false; }
  
  public boolean getClick(char c) {
    for (int i = 0 ; i < keys_code.length ; i++)
      if (keys_code[i] == c && keysClick[i]) return true;
    return false; }
  
  public boolean getUnclick(char c) {
    for (int i = 0 ; i < keys_code.length ; i++)
      if (keys_code[i] == c && keysUClick[i]) return true;
    return false; }
  
  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    keysButtons = new boolean[keyNb];
    keysClick = new boolean[keyNb]; keysJClick = new boolean[keyNb];
    keysUClick = new boolean[keyNb]; keysJUClick = new boolean[keyNb];
    
    for (int i = keyNb-1; i >= 0; i--) {
      keysButtons[i] = false;
      keysClick[i] = false; keysJClick[i] = false;
      keysUClick[i] = false; keysJUClick[i] = false;
    }
    
    mouseButtons = new boolean[3];
    mouseClick = new boolean[3]; mouseJClick = new boolean[3];
    mouseUClick = new boolean[3]; mouseJUClick = new boolean[3];
    
    for (int i = 2; i >= 0; i--) {
      mouseButtons[i] = false;
      mouseClick[i] = false; mouseJClick[i] = false;
      mouseUClick[i] = false; mouseJUClick[i] = false;
    }
  }
  
  public void update() {
    mouseWheelUp = false; mouseWheelDown = false;
    if (mouseX == pmouseX && mouseY == pmouseY) {mouseMove = false;}
    for (int i = 2; i >= 0; i--) {
      if (mouseClick[i] == true && mouseJClick[i] == false) {mouseJClick[i] = true;}
      if (mouseClick[i] == true && mouseJClick[i] == true) {mouseClick[i] = false; mouseJClick[i] = false;}
      if (mouseUClick[i] == true && mouseJUClick[i] == false) {mouseJUClick[i] = true;}
      if (mouseUClick[i] == true && mouseJUClick[i] == true) {mouseUClick[i] = false; mouseJUClick[i] = false;}
    }
    for (int i = keyNb-1; i >= 0; i--) {
      if (keysClick[i] == true) {keysJClick[i] = true;}
      if (keysClick[i] == true && keysJClick[i] == true) {keysClick[i] = false; keysJClick[i] = false;}
      if (keysUClick[i] == true) {keysJUClick[i] = true;}
      if (keysUClick[i] == true && keysJUClick[i] == true) {keysUClick[i] = false; keysJUClick[i] = false;}
    }
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
  
  public void keyPressedEvent()
  {
    for (int i = 0; i < keyNb ; i++)
      if (key==keys_code[i]) {
        keysButtons[i]=true;
        keysClick[i]=true;
      }
  }
  
  public void keyReleasedEvent()
  {
    for (int i = 0; i < keyNb ; i++)
      if (key==keys_code[i]) {
        keysButtons[0]=false;
        keysUClick[0]=true; 
      }
  }
  
  public void mousePressedEvent()
  {
    if(mouseButton==LEFT) {
      mouseButtons[0]=true;
      mouseClick[0]=true; }
    if(mouseButton==RIGHT) {
      mouseButtons[1]=true;
      mouseClick[1]=true; }
    if(mouseButton==CENTER) {
      mouseButtons[2]=true;
      mouseClick[2]=true; }
  }
  
  public void mouseReleasedEvent()
  {
    if(mouseButton==LEFT) {
      mouseButtons[0]=false;
      mouseUClick[0]=true; }
    if(mouseButton==RIGHT) {
      mouseButtons[1]=false;
      mouseUClick[1]=true; }
    if(mouseButton==CENTER) {
      mouseButtons[2]=false;
      mouseUClick[2]=true; }
  }
  
  public void mouseDraggedEvent() { mouseMove = true; }
  
  public void mouseMovedEvent() { mouseMove = true; }
}

class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  public void draw() { rect(pos.x, pos.y, size.x, size.y); }
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

class Box extends Entity {
  Rect rect = new Rect();
  Box origin;
  int generation = 1;
  PVector connect1 = new PVector(0, 0);
  PVector connect2 = new PVector(0, 0);
  PVector origin_co = new PVector(0, 0); //origin box to ext co
  float space = 0;
  
  Box(BoxComu c) { super(c); }
  
  //void draw_halo(Canvas canvas, PImage i) {}
  
  public void pair(Box b2) {}
  
  public Box init() {
    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
    rect.pos.x = -rect.size.x/2; rect.pos.y = -rect.size.y/2;
    connect1.x = rect.pos.x; connect1.y = rect.pos.y;
    connect2.x = rect.pos.x; connect2.y = rect.pos.y;
    origin = null;
    origin_co.x = 0;
    origin_co.y = 0;
    generation = 1;
    space = com().spacing_min.get();
    rotation = -0.008f;
    col = 0;
    return this;
  }
  public void define_bis(Box b2, float x, float y, String dir) {
    rect.pos.x = x; rect.pos.y = y;
    for (Entity e : com().list) if (e.active) {
      Box b = (Box)e;
      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
        this.destroy(); return; } }
    origin = b2;
    generation = b2.generation + 1;
    float corner_space = com().corner_space.get();
    if (dir.charAt(0) == 'v') {
      if (dir.charAt(1) == 'u') {
        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
        connect1.y = rect.pos.y + rect.size.y;
        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
        connect2.y = b2.rect.pos.y;
      } else {
        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
        connect1.y = rect.pos.y;
        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
        connect2.y = b2.rect.pos.y + b2.rect.size.y;
      }
    } else {
      if (dir.charAt(1) == 'l') {
        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
        connect1.x = rect.pos.x + rect.size.x;
        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
        connect2.x = b2.rect.pos.x;
      } else {
        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
        connect1.x = rect.pos.x;
        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
        connect2.x = b2.rect.pos.x + b2.rect.size.x;
      }
    }
    origin_co.x = connect2.x - origin.rect.pos.x;
    origin_co.y = connect2.y - origin.rect.pos.y; //origin box to ext co
    //PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    
    rotation = 0;//.008 * (6000 - connect_line.mag()) / 6000;
    //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
    //connect_line.rotate(rotation + burst);
    //connect1.x = connect_line.x + connect2.x;
    //connect1.y = connect_line.y + connect2.y;
    //rect.pos.x = box_local.x + connect1.x;
    //rect.pos.y = box_local.y + connect1.y;
  }
  
  public Box define(Box b2) {
    space = com().spacing_min.get() + 
            ( 2 * com().spacing_max.get() * min(1, b2.rect.pos.mag()
            / com().spacing_max_dist.get()) ) * crandom(com().spacing_diff.get());
    //space = crandom( com().spacing_min.get(), 
    //                 com().spacing_max.get(), 
    //                 ( min(0, com().spacing_max_dist.get() - b2.rect.pos.mag()) / com().spacing_max_dist.get()) * com().spacing_diff.get() );
    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
    boolean axe = random(10) < 5;
    float dir_mod = 0;
    if (axe && b2.rect.pos.y > 0) dir_mod = -2.5f;
    if (axe && b2.rect.pos.y < 0) dir_mod = 2.5f;
    if (!axe && b2.rect.pos.x > 0) dir_mod = -2.5f;
    if (!axe && b2.rect.pos.x < 0) dir_mod = 2.5f;
    boolean side = random(10) < 5 + dir_mod;
    if (axe) {
      if (side) {
        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space), 
                       b2.rect.pos.y - (rect.size.y + space), "vu"); }
      else {
        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space),
                       b2.rect.pos.y + b2.rect.size.y + space, "vd"); } }
    else {
      if (side) {  
        define_bis(b2, b2.rect.pos.x - (rect.size.x + space),
                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hl"); }
      else {                 
        define_bis(b2, b2.rect.pos.x + b2.rect.size.x + space,
                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hr"); } }
    return this;
  }
  
  float rotation = -0.008f;
  int col = 0;
  float burst = 0;
  boolean blocked = false;
  
  public Box tick() {
    for (Entity e : fcom.list) if (e.active) {
      Floc f = (Floc)e;
      if (rectCollide(f.pos, rect)) {
        this.destroy();
      }
    }
    
    if (random(100) < com().duplicate_prob.get()) {
      Box nb = com().newEntity();
      if (nb != null) {
        nb.define(this); } }
    
    float rspeed = 0.008f / generation;
    int pcol = col;
    col = 0;
    for (Entity e : com().list) if (e.active) {
      Box b = (Box)e;
      //if (col >= 1) { rotation = 0; }
      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
        //if (col > 0 && !blocked) rotation *= 1.01;
        if (col == 0 && !blocked) rotation *= -1;
        col += 1;
        //if (col == 0 && abs(rotation) > rspeed*2) rotation = 0;
      } }
    //if (blocked) rotation -= 0.00001;
    //if (abs(rotation) > rspeed*2) { blocked = true; burst = 0.1; if (rotation < 0) burst *= -1; rotation = 0;  }
    //if (col == 0 && abs(rotation) > rspeed) rotation /= 1.01;
    if (pcol == 0) blocked = false;
    //if (blocked && rotation == 0) rotation = rspeed;
    //println(com().comList.tick.get() + " " + col + " " + rotation);
    
    PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    if (origin != null && origin.active) {
      //connect2.x = origin.rect.pos.x + origin_co.x;
      //connect2.y = origin.rect.pos.y + origin_co.y;
      //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
      ////connect_line.rotate(rotation + burst);
      //connect1.x = connect_line.x + connect2.x;
      //connect1.y = connect_line.y + connect2.y;
      //rect.pos.x = box_local.x + connect1.x;
      //rect.pos.y = box_local.y + connect1.y;
      
      //burst /= 1.01;
    }
    return this; }
  
  public Box drawing() {
    float connect_bubble_size = com().corner_space.get();
    
    
    float rd = 255.0f * (float)((10.0f - PApplet.parseFloat(abs(generation - PApplet.parseInt(com().cnt/60.0f)))) / 10.0f);
    float stroke_limit = 1;
    if (rd <= stroke_limit) rd = 255.0f * (float)((10.0f - PApplet.parseFloat(abs(generation - PApplet.parseInt((com().cnt+1200)/60.0f)))) / 10.0f);
    if (rd <= stroke_limit) rd = 255.0f * (float)((10.0f - PApplet.parseFloat(abs(generation - PApplet.parseInt((com().cnt-1200)/60.0f)))) / 10.0f);
    if (rd <= stroke_limit) rd = 255.0f * (float)((10.0f - PApplet.parseFloat(abs(generation - PApplet.parseInt((com().cnt+2400)/60.0f)))) / 10.0f);
    if (rd <= stroke_limit) rd = 255.0f * (float)((10.0f - PApplet.parseFloat(abs(generation - PApplet.parseInt((com().cnt-2400)/60.0f)))) / 10.0f);
    //if (abs(generation - int(com().cnt/60)) < 10) 
    int filling = color(40, max(100, PApplet.parseInt(rd-20)), 0);
    float fc = max( 150, 255 - max(0, PApplet.parseInt(rd)) ) / 255.0f;
    int lining = color(100*fc, 255*fc, 100*fc);
    //println(lining);
    noFill();
    stroke(lining);
    strokeWeight(max(2/cam.cam_scale.get(), connect_bubble_size/1.3f));
    line(connect1.x, connect1.y, connect2.x, connect2.y);
    if (connect_bubble_size*cam.cam_scale.get() > 3) {
      fill(filling);
      stroke(lining);
      strokeWeight(4/cam.cam_scale.get());
      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
    fill(filling);
    stroke(lining);
    strokeWeight(2/cam.cam_scale.get());
    rect.draw();
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3/cam.cam_scale.get());
    //rect(rect.pos.x - space/2, rect.pos.y - space/2, rect.size.x + space, rect.size.y + space);
    if (connect_bubble_size*cam.cam_scale.get() > 3) {
      fill(filling);
      noStroke();
      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
    noFill();
    stroke(filling);
    strokeWeight(max(0, connect_bubble_size/1.3f - 4/cam.cam_scale.get()));
    line(connect1.x, connect1.y, connect2.x, connect2.y);
    
    fill(lining);
    textFont(getFont(PApplet.parseInt(rect.size.y/3)));
    text(""+generation, rect.pos.x + rect.size.x/3, rect.pos.y + rect.size.y/1.41f);
    return this; }
  public Box clear() { return this; }
  public BoxComu com() { return ((BoxComu)com); }
}


class BoxComu extends Community {
  sFlt spacing_min = new sFlt(simval, 50);
  sFlt spacing_max = new sFlt(simval, 200);
  sFlt spacing_diff = new sFlt(simval, 1);
  sFlt spacing_max_dist = new sFlt(simval, 10000);
  sFlt box_size_min = new sFlt(simval, 100);
  sFlt box_size_max = new sFlt(simval, 400);
  sFlt duplicate_prob = new sFlt(simval, 5.0f);
  sFlt corner_space = new sFlt(simval, 40);
  
  //sBoo draw_circle = new sBoo(simval, false);
  
  int cnt = 0;
  
  BoxComu(Simulation _c) { super(_c, "Box ", 0); init(); }
  public void custom_pre_tick() {}
  public void custom_build() {
    panel.addSeparator(1)
      .addValueController("size min ", sMode.FACTOR, 2, 1.2f, box_size_min)
      .addSeparator(5)
      .addValueController("size max ", sMode.FACTOR, 2, 1.2f, box_size_max)
      .addSeparator(5)
      .addValueController("space min", sMode.FACTOR, 2, 1.2f, spacing_min)
      .addSeparator(5)
      .addValueController("space max", sMode.FACTOR, 2, 1.2f, spacing_max)
      .addSeparator(5)
      .addValueController("comu rad", sMode.FACTOR, 2, 1.2f, spacing_max_dist)
      .addSeparator(5)
      .addValueController("space diff", sMode.FACTOR, 2, 1.2f, spacing_diff)
      .addSeparator(5)
      .addValueController("duplic% ", sMode.FACTOR, 2, 1.2f, duplicate_prob)
      .addSeparator(5)
      .addValueController("corner ", sMode.FACTOR, 2, 1.2f, corner_space)
      .addSeparator(5)
      ;
      
    plane.build_panel.addDrawer(30).addButton("PARAM", 0, 0).setSize(120, 30)
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { newMacroFlocIN1(); } } )
      .getDrawer().getPanel().addSeparator(10);
  }
  
  public void newMacroFlocIN1() {
    //new MacroCUSTOM(plane).setLabel("CUSTOM").setWidth(140)
    //  .addMCsFltControl().setValue(spacing).setText("param").getMacro();
  }
  
  public void custom_post_tick() { 
    cnt+=2;
    if (cnt > 2400) cnt -= 2400;
  }
  public void custom_cam_draw_pre_entity() {}
  public void custom_reset() { cnt = 0; }
  public void custom_cam_draw_post_entity() { 
    float r = spacing_max_dist.get();  
    noFill();
    stroke(255);
    //ellipse(0, 0, r, r);
    
  }//
  
  public Box build() { return new Box(this); }
  public Box initialEntity() { return newEntity(); }
  public Box newEntity() { 
    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
}

class FlocComu extends Community {
  
  sFlt POURSUITE = new sFlt(simval, 0.6f);
  sFlt FOLLOW = new sFlt(simval, 0.0036f);
  sFlt SPACING = new sFlt(simval, 150);
  sFlt SPEED = new sFlt(simval, 2);
  sInt LIMIT = new sInt(simval, 400);
  sInt AGE = new sInt(simval, 2000);
  sFlt HALO_SIZE = new sFlt(simval, 20);
  sFlt HALO_DENS = new sFlt(simval, 0.2f);
  
  sBoo DRAWMODE_DEF = new sBoo(simval, true);
  sBoo DRAWMODE_DEBUG = new sBoo(simval, false);
  
  sBoo create_grower = new sBoo(simval, true);
  sBoo point_to_mouse = new sBoo(simval, false);
  sBoo point_to_center = new sBoo(simval, false);
  
  int startbox = 400;
  
  FlocComu(Simulation _c) { super(_c, " Floc ", 100); init();
    
    init_canvas();
  }
  public void custom_build() {
    panel.addSeparator(1)
      .addDrawer(20)
        .addText("Affichage:", 0, 0)
          .setFont(16)
          .getDrawer()
        .addExclusiveSwitchs("def", "debug", 80, 0, DRAWMODE_DEF, DRAWMODE_DEBUG)
        .getPanel()
      .addSeparator(5)
      .addValueController("halosize ", sMode.FACTOR, 2, 1.2f, HALO_SIZE)
      .addSeparator(5)
      .addValueController("halodens ", sMode.FACTOR, 2, 1.2f, HALO_DENS)
      .addSeparator(5)
      .addValueController("TRACK ", sMode.FACTOR, 2, 1.2f, POURSUITE)
      .addSeparator(5)
      .addValueController("FOLLOW ", sMode.FACTOR, 2, 1.2f, FOLLOW)
      .addSeparator(5)
      .addValueController("SPACING ", sMode.FACTOR, 2, 1.2f, SPACING)
      .addSeparator(5)
      .addValueController("LIMIT ", sMode.FACTOR, 2, 1.2f, LIMIT)
      .addSeparator(5)
      .addValueController("SPEED ", sMode.FACTOR, 2, 1.2f, SPEED)
      .addSeparator(5)
      .addValueController("AGE ", sMode.INCREMENT, 100, 10, AGE)
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("CREATE GROWER", 90, 0)
          .setValue(create_grower)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("TO MOUSE", 30, 0)
          .setValue(point_to_mouse)
          .setSize(160, 20)
          .getDrawer()
        .addSwitch("TO CENTER", 210, 0)
          .setValue(point_to_center)
          .setSize(160, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
      
    //creation de macro custom
    plane.build_panel
      .addDrawer(30)
        .addButton("LIFE", 0, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroFlocIN1(); } } )
          .getDrawer()
        .addButton("MOVE", 130, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroFlocIN2(); } } )
          .getDrawer()
        .addButton("HALO", 260, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroFlocIN3(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
  }
  
  //sFlt POURSUITE = new sFlt(simval, 0.6);
  //sFlt FOLLOW = new sFlt(simval, 0.0036);
  //sFlt SPACING = new sFlt(simval, 150);
  //sFlt SPEED = new sFlt(simval, 2);
  //sInt LIMIT = new sInt(simval, 400);
  //sFlt HALO_SIZE = new sFlt(simval, 20);
  //sFlt HALO_DENS = new sFlt(simval, 0.2);
  
  public void newMacroFlocIN1() {
    new MacroCUSTOM(plane)
      .setLabel("FLOC LIFE")
      .setWidth(140)
      .addMCsBooControl()
        .setValue(create_grower)
        .setText("create")
        .getMacro()
      .addMCsBooControl()
        .setValue(point_to_mouse)
        .setText(">mouse")
        .getMacro()
      .addMCsBooControl()
        .setValue(point_to_center)
        .setText(">center")
        .getMacro()
      .addMCsIntControl()
        .setValue(AGE)
        .setText("age")
        .getMacro()
      ;
    
  }
  
  public void newMacroFlocIN2() {
    new MacroCUSTOM(plane)
      .setLabel("FLOC MOVE")
      .setWidth(160)
      .addMCsFltControl()
        .setValue(POURSUITE)
        .setText("pursue")
        .getMacro()
      .addMCsFltControl()
        .setValue(FOLLOW)
        .setText("follow")
        .getMacro()
      .addMCsFltControl()
        .setValue(SPACING)
        .setText("space")
        .getMacro()
      .addMCsFltControl()
        .setValue(SPEED)
        .setText("speed")
        .getMacro()
      .addMCsIntControl()
        .setValue(LIMIT)
        .setText("limit")
        .getMacro()
      ;
  }
  
  public void newMacroFlocIN3() {
    new MacroCUSTOM(plane)
      .setLabel("FLOC HALO")
      .setWidth(160)
      .addMCsFltControl()
        .setValue(HALO_SIZE)
        .setText("size")
        .getMacro()
      .addMCsFltControl()
        .setValue(HALO_DENS)
        .setText("density")
        .getMacro()
      ;
  }
  
  public void custom_pre_tick() {
    for (Entity e1 : list)
      for (Entity e2 : list)
        if (e1.id < e2.id && e1 != e2 && e1.active && e2.active)
            ((Floc)e1).pair(((Floc)e2));
          
  }
  public void custom_post_tick() {}
  public void custom_frame() {
    can.drawHalo(this);
  }
  public void custom_cam_draw_post_entity() {}
  public void custom_cam_draw_pre_entity() {
    can.drawCanvas();
  }
  
  public Floc build() { return new Floc(this); }
  public Floc initialEntity() { return newEntity(); }
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
  
  public void draw_halo(Canvas canvas, PImage i) {
    //walk a box of pix around entity containing the halo (pos +/- halo radius)
    for (float px = PApplet.parseInt(pos.x - halo_size) ; px < PApplet.parseInt(pos.x + halo_size) ; px+=1*canvas.canvas_scale)
      for (float py = PApplet.parseInt(pos.y - halo_size) ; py < PApplet.parseInt(pos.y + halo_size) ; py+=1*canvas.canvas_scale) {
        PVector m = new PVector(pos.x - px, pos.y - py);
        if (m.mag() < halo_size) { //get and try distence of current pix
          //the color to add to the current pix is function of his distence to the center
          //the decreasing of the quantity of color to add is soothed
          int a = PApplet.parseInt( (255.0f * halo_density) * soothedcurve(1.0f, m.mag() / halo_size) );
          canvas.addpix(i, px, py, color(a, 0, 0));
        }
    }
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
    max_age = com().AGE.get();
    halo_size = com().HALO_SIZE.get();
    halo_density = com().HALO_DENS.get();
    halo_size += random(com().HALO_SIZE.get());
    halo_density += random(com().HALO_DENS.get());
    pos.x = random(-com().startbox, com().startbox);
    pos.y = random(-com().startbox, com().startbox);
    speed = random(0.5f, 1) * com().SPEED.get();
    mov.x = speed; mov.y = 0;
    mov.rotate(random(PI * 2.0f));
    return this;
  }
  public Floc tick() {
    age++;
    if (age > max_age) {
      if (com().create_grower.get()) {
        Grower ng = gcom.newEntity();
        if (ng != null) ng.define(new PVector(pos.x, pos.y), new PVector(1, 0).rotate(mov.heading()));
      }
      destroy();
    }
    //point toward mouse
    if (com().point_to_mouse.get()) headTo(cam.screen_to_cam(new PVector(mouseX, mouseY)), 0.01f);
    //point toward center
    if (com().point_to_center.get()) headTo(new PVector(0, 0), 0.01f);
    pos.add(mov);
    return this;
  }
  public Floc drawing() {
    fill(255);
    stroke(255);
    strokeWeight(4/cam.cam_scale.get());
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(mov.heading());
    if (com().DRAWMODE_DEF.get()) {
      line(0, 0, -10, -10);
      line(2, 0, -10, 0);
      line(0, 0, -10, 10);
    }
    stroke(255, 0, 0);
    if (com().DRAWMODE_DEBUG.get()) ellipse(0, 0, 1, 1);
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



//#######################################################################
//##                              CANVAS                               ##
//#######################################################################


Canvas can;

public void init_canvas() {
  can = new Canvas(0, 0, PApplet.parseInt((width) / cam.cam_scale.get()), PApplet.parseInt((height) / cam.cam_scale.get()), 4);
}

class Canvas extends Callable {
  PVector pos = new PVector(0, 0);
  float canvas_scale = 1.0f;
  PImage can1,can2;
  
  int active_can = 0;
  int can_div = 4;
  int can_st = can_div-1;
  
  sBoo show_canvas = new sBoo(simval, true);
  sBoo show_canvas_bound = new sBoo(simval, true);
  
  sGrabable can_grab;
  
  Canvas() { construct(0, 0, width, height, 1); }
  Canvas(float x, float y, int w, int h, float s) { construct(x, y, w, h, s); }
  
  public void construct(float x, float y, int w, int h, float s) {
    w /= s; h /= s;
    can1 = createImage(w, h, RGB);
    init(can1);
    can2 = createImage(w, h, RGB);
    init(can2);
    pos.x = x - PApplet.parseInt(w) / 2;
    pos.y = y - PApplet.parseInt(h) / 2;
    can_grab = new sGrabable(cp5, x, y + 20);
    addChannel(frame_chan);
    if (show_canvas.get()) can_grab.show(); else can_grab.hide();
    canvas_scale = s;
  }
  
  
  public void answer(Channel chan, float value) {
    if (chan == frame_chan) {
      pos = cam.screen_to_cam(can_grab.getP());
      pos.y -= 20 / cam.cam_scale.get();
    }
  }
  
  public void drawHalo(Community com) {
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
  
  public void drawCanvas() {
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
  
  public void clear(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      canvas.pixels[i] = color(0);
    }
  }
  
  public void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(pos.x, pos.y);
    scale(canvas_scale);
    image(canvas, 0, 0);
    popMatrix();
  }
  
  public void addpix(PImage canvas, float x, float y, int nc) {
    x += canvas_scale/2;
    y += canvas_scale/2;
    x -= pos.x;
    y -= pos.y;
    x /= canvas_scale;
    y /= canvas_scale;
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
class RandomTryParam extends Callable {
  //constructeur avec param values
  sFlt DIFFICULTY = new sFlt(simval, 4);
  sBoo ON = new sBoo(simval, true);
  sFlt test_by_tick = new sFlt(simval, 0);
  int count = 0;
  RandomTryParam(float d, boolean b) { DIFFICULTY.set(d); ON.set(b); addChannel(frameend_chan); }
  public boolean test() { if(ON.get()) count++; test_by_tick.set(count / sim.tick_by_frame.get()); return ON.get() && crandom(DIFFICULTY.get()) > 0.5f; }
  public void answer(Channel chan, float v) { count = 0; test_by_tick.set(0); }
}

class GrowerComu extends Community {
  
  //constructeur avec param values
  sFlt DEVIATION = new sFlt(simval, 8); //drifting (rotation posible en portion de pi (PI/drift))
  sFlt L_MIN = new sFlt(simval, 20); //longeur minimum de chaque section
  sFlt L_MAX = new sFlt(simval, 350); //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  sFlt L_DIFFICULTY = new sFlt(simval, 180);
  sFlt OLD_AGE = new sFlt(simval, 666);
  //int TEEN_AGE = OLD_AGE / 20;
  RandomTryParam growP = new RandomTryParam(0.5f, true);
  RandomTryParam sproutP = new RandomTryParam(2080, true);
  RandomTryParam stopP = new RandomTryParam(1.25f, true);
  RandomTryParam leafP = new RandomTryParam(2080, true);
  RandomTryParam dieP = new RandomTryParam(3.6f, true);
  float MAX_LINE_WIDTH = 1.5f; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  float MIN_LINE_WIDTH = 0.2f; //epaisseur min des ligne
  
  sBoo create_floc = new sBoo(simval, true);
  
  sLabel grower_nb_label;
  
  sInt activeGrower = new sInt(simval, 0);
  
  sGraph graph = new sGraph();
  
  GrowerComu(Simulation _c) { super(_c, "Grower", 500); init();
    
    graph.init();
    
  }
  public void custom_cam_draw_pre_entity() {}
  public void custom_cam_draw_post_entity() {}
  public void custom_pre_tick() {}
  public void custom_post_tick() {}
  public void custom_build() {
    //creation du menu
    panel.addText("Shape", 150, 0, 22)
      .addSeparator(8)
      .addValueController("DEV ", sMode.FACTOR, 2, 1.2f, DEVIATION)
      .addSeparator(10)
      .addValueController("L_MIN ", sMode.FACTOR, 2, 1.2f, L_MIN)
      .addSeparator(10)
      .addValueController("L_MAX ", sMode.FACTOR, 2, 1.2f, L_MAX)
      .addSeparator(10)
      .addValueController("L_DIFF ", sMode.FACTOR, 2, 1.2f, L_DIFFICULTY)
      .addLine(22)
      .addText("Behavior", 140, 0, 22)
      .addSeparator(8)
      .addRngTryCtrl("GROW ", growP)
      .addSeparator(5)
      .addRngTryCtrl("SPROUT ", sproutP)
      .addSeparator(5)
      .addRngTryCtrl("STOP ", stopP)
      .addSeparator(5)
      .addRngTryCtrl("LEAF ", leafP)
      .addSeparator(5)
      .addRngTryCtrl("DIE ", dieP)
      .addSeparator(5)
      .addValueController("age ", sMode.FACTOR, 2, 1.2f, OLD_AGE)
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("CREATE FLOC", 90, 0)
          .setValue(create_floc)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addText("test by tick: ", 140, 0)
          .getDrawer()
        .getPanel()
      .addDrawer(60)
        .addText("grow try: ", 30, 0)
          .setValue(growP.test_by_tick)
          .getDrawer()
        .addText("sprout try: ", 200, 0)
          .setValue(sproutP.test_by_tick)
          .getDrawer()
        .addText("stop try: ", 30, 30)
          .setValue(stopP.test_by_tick)
          .getDrawer()
        .addText("leaf try: ", 200, 30)
          .setValue(leafP.test_by_tick)
          .getDrawer()
        .getPanel()
      ;
    grower_nb_label = new sLabel(cp5) { 
        public void answer(Channel channel, float value) {
          grower_nb_label.setText("grower: ", str(grower_Nb())); } }
      .setText("grower: ")
      .setPos(200, 66)
      .setPanel(panel)
      .setFont(20)
      ;
    grower_nb_label.addChannel(frame_chan);
    new sSwitch(cp5, "G", 320, 62)
      .setValue(graph.SHOW_GRAPH)
      .setPanel(panel)
      .setSize(30, 30)
      ;
    
    //creation de macro custom
    plane.build_panel
      .addDrawer(30)
        .addButton("SHAPE", 260, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerINShape(); } } )
          .getDrawer()
        .addButton("BEHAVIOR", 130, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerINMove(); } } )
          .getDrawer()
        .addButton("LIFE", 0, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
  }
  
  public void newMacroGrowerINShape() {
    new MacroCUSTOM(plane)
      .setLabel("GROWER Shape")
      .setWidth(150)
      .addMCsFltControl()
        .setValue(DEVIATION)
        .setText("dev")
        .getMacro()
      .addMCsFltControl()
        .setValue(L_MIN)
        .setText("l min")
        .getMacro()
      .addMCsFltControl()
        .setValue(L_MAX)
        .setText("l max")
        .getMacro()
      .addMCsFltControl()
        .setValue(L_DIFFICULTY)
        .setText("dif")
        .getMacro()
      ;
  }
  
  public void newMacroGrowerINMove() {
    MacroCUSTOM m = new MacroCUSTOM(plane)
      .setLabel("GROWER Move")
      .setWidth(150)
      ;
    addRngTry(m, growP, "grow");
    addRngTry(m, sproutP, "sprout");
    addRngTry(m, leafP, "leaf");
    addRngTry(m, stopP, "stop");
    addRngTry(m, dieP, "die");
  }
  
  public void addRngTry(MacroCUSTOM m, RandomTryParam r, String s) {
    m.addMCsBooControl()
        .setValue(r.ON)
        .setText(s)
        .getMacro()
      .addMCsFltControl()
        .setValue(r.DIFFICULTY)
        .setText("")
        .getMacro()
      ;
  }
  
  public void newMacroGrowerOUT() {
    new MacroCUSTOM(plane)
      .setLabel("GROWER LIFE")
      .setWidth(280)
      .addMCsIntWatcher()
        .addValue(activeGrower)
        .setText("   growing")
        .getMacro()
      .addMCsBooControl()
        .setValue(create_floc)
        .setText("create floc")
        .getMacro()
      ;
  }
  
  public Grower build() { return new Grower(this); }
  public Grower initialEntity() {
    Grower ng = newEntity();
    if (ng != null) ng.define(new PVector(0, 0), new PVector(1, 0).rotate(random(2*PI)));
    return ng;
  }
  public Grower newEntity() {
    Grower ng = null;
    for (Entity e : list) 
      if (!e.active && ng == null) { ng = (Grower)e; e.activate(); }
    return ng;
  }
  public void custom_frame() {
    graph.update(activeEntity.get(), activeGrower.get());
  }
  public void custom_tick() {
    activeGrower.set(grower_Nb());
  }
  public void custom_screen_draw() {
    graph.draw();
  }
  public int grower_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active && !((Grower)e).end && ((Grower)e).sprouts == 0) n++;
    return n;
  }
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

  Grower(GrowerComu c) { super(c); }
  
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
      if (com().create_floc.get()) {
        Floc f = fcom.newEntity();
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
  public Grower drawing() {
    // aging color
    int ca = 255;
    if (age > com().OLD_AGE.get() / 2) ca = (int)constrain(255 + PApplet.parseInt(com().OLD_AGE.get()/2) - PApplet.parseInt(age/1.2f), 90, 255);
    //if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); } //BIG red head
    if (!end && sprouts == 0) { stroke(255); strokeWeight((com().MAX_LINE_WIDTH+1) / cam.cam_scale.get()); }
    else if (end) { stroke(0, ca, 0); strokeWeight((com().MAX_LINE_WIDTH+1) / cam.cam_scale.get()); }
    else { stroke(ca, ca, ca); strokeWeight(((float)com().MIN_LINE_WIDTH + ((float)com().MAX_LINE_WIDTH * (float)ca / 255.0f)) / cam.cam_scale.get()); }              
    
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
      line(0, 0,e.x,e.y);
      line(e2.x,e2.y,e.x,e.y);
      e.rotate(PI/8);
      line(0, 0,e.x,e.y);
      line(e2.x,e2.y,e.x,e.y);
    } else line(0, 0,e.x,e.y);
    popMatrix();
    
    //line(pos.x,pos.y,grows.x,grows.y);
    
    //DEBUG
    //fill(255); ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    return this;
  }
  public Grower clear() { return this; }
  public GrowerComu com() { return ((GrowerComu)com); }
}

/*
ici on definie les objet de structure

*/


class Simulation {
  ArrayList<Community> list = new ArrayList<Community>();
  sPanel panel;
  sTextfield file_path_tf;
  
  sFlt tick = new sFlt(simval, 0); //conteur de tour depuis le dernier reset ou le debut
  sBoo pause = new sBoo(simval, false); //permet d'interompre le defilement des tour
  sFlt tick_by_frame = new sFlt(simval, 16); //nombre de tour a executé par frame
  float tick_pile = 0; //pile des tour
  sInt SEED = new sInt(simval, 548651008); //seed pour l'aleatoire
  sBoo auto_reset = new sBoo(simval, true);
  sBoo auto_reset_rng_seed = new sBoo(simval, true);
  sInt auto_reset_turn = new sInt(simval, 4000);
  sBoo auto_screenshot = new sBoo(simval, false);
  
  Channel tick_chan = new Channel();
  Channel unpaused_frame_chan = new Channel();
  
  boolean next_tick = false;
  
  Simulation() {
    
  }
  
  public void building() {
    //menu principale de la sim
    panel = new sPanel(cp5, 1190, 430)
      .addTitle("SIMULATION CONTROL", 28, 0, 28)
      .addLine(10)
      .addDrawer(30)
        .addText("SEED: ", 50, 4)
          .getDrawer()
        .addTextfield(130, 5)
          .setValue(SEED)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addDrawer(60)
        .addText("framerate: ", 30, 0)
          .setValue(fr.value)
          .getDrawer()
        .addText("time (s): ", 200, 0)
          .setValue(fr.time)
          .getDrawer()
        .addText("tickrate: ", 30, 30)
          .setValue(fr.tickrate)
          .getDrawer()
        .addText("tick: ", 200, 30)
          .setValue(tick)
          .getDrawer()
        .getPanel()
      .addValueController("tick / frame:", sMode.FACTOR, 2, 1.2f, tick_by_frame)
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("PAUSE", 20, 0)
          .setValue(pause)
          .setSize(170, 30)
          .getDrawer()
        .addButton("NEXT TICK", 200, 0)
          .setSize(160, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { next_tick = true; } } )
          .getDrawer()
        .getPanel()
        .addSeparator(10)
      .addDrawer(30)
        
        .addButton("RESET", 20, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { reset(); } } )
          .getDrawer()
        .addButton("RNG", 110, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { SEED.set(PApplet.parseInt(random(1000000000))); reset(); } } )
          .getDrawer()
        .addButton("NEXT FRAME", 200, 0)
          .setSize(160, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              for (int i = 0; i < tick_by_frame.get()-1; i++) tick();
              next_tick = true;
            } } )
          .getDrawer()
        
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("AUTO", 0, 0)
          .setValue(auto_reset)
          .setSize(50, 30)
          .setFont(16)
          .getDrawer()
        .addSwitch("RNG", 60, 0)
          .setValue(auto_reset_rng_seed)
          .setSize(50, 30)
          .setFont(16)
          .getDrawer()
        .addButton("-100", 120, 0)
          .setSize(50, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { auto_reset_turn.set(auto_reset_turn.get()-100); } } )
          .getDrawer()
        .addText("restart at: ", 180, 5)
          .setValue(auto_reset_turn)
          .getDrawer()
        .addButton("+100", 330, 0)
          .setSize(50, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { auto_reset_turn.set(auto_reset_turn.get()+100); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("Canvas", 0, 0)
          .setValue(can.show_canvas)
          .setSize(100, 30)
          .setFont(18)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (can.show_canvas.get()) can.can_grab.hide(); else can.can_grab.show();
            } } )
          .getDrawer()
        .addSwitch("Bound", 110, 0)
          .setValue(can.show_canvas_bound)
          .setSize(100, 30)
          .setFont(18)
          .getDrawer()
        .addSwitch("Grid", 280, 0)
          .setValue(cam.grid)
          .setSize(100, 30)
          .setFont(18)
          .getDrawer()
        .getPanel().addSeparator(10)
      .addDrawer(30)
        .addButton("S", 0, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              saving(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .addButton("L", 270, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              loading(simval, file_path_tf.getText()); 
              reset(); } } )
          .getDrawer()
        .addButton("I", 340, 0)
          .setSize(20, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { cam.screenshot = true; } } )
          .getDrawer()
        .addSwitch("A", 360, 0)
          .setValue(auto_screenshot)
          .setSize(20, 30)
          .getDrawer()
        .getPanel()
      ;
    file_path_tf = panel.lastDrawer().addTextfield(70, 0)
      .setText("save.txt")
      .setSize(190, 30)
      
      ;
    //file_path_tf.setColor(color(255));
    panel.addSeparator(10);
    
    //macro custom et menu d'ajout
    plane.build_panel
      .addText("Simulation :", 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("RESET", 20, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimIN1(); } } )
          .getDrawer()
        .addButton("RUN", 110, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimIN2(); } } )
          .getDrawer()
        .addButton("AUTO", 200, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimIN3(); } } )
          .getDrawer()
        .addButton("OUT", 290, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    for (Community c : list) c.building();
  }
  
  public void newMacroSimIN1() {
    new MacroCUSTOM(plane)
      .setLabel("SIM RESET")
      .setWidth(170)
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { reset(); }})
        .setText("reset")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { SEED.set(PApplet.parseInt(random(1000000000))); reset(); }})
        .setText("rng")
        .getMacro()
      ;
  }
  
  public void newMacroSimIN2() {
    new MacroCUSTOM(plane)
      .setLabel("SIM RUN")
      .setWidth(155)
      .addMCsBooWatcher()
        .addValue(pause)
        .setText("pause")
        .getMacro()
      .addMCsBooControl()
        .setValue(pause)
        .setText("")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { next_tick = true; }})
        .setText("tick")
        .getMacro()
      .addMCsFltControl()
        .setValue(tick_by_frame)
        .setText("speed")
        .getMacro()
      ;
  }
  
  public void newMacroSimIN3() {
    new MacroCUSTOM(plane)
      .setLabel("SIM AUTO")
      .setWidth(170)
      .addMCsBooControl()
        .setValue(auto_reset)
        .setText("auto reset")
        .getMacro()
      .addMCsIntControl()
        .setValue(auto_reset_turn)
        .setText("reset tick")
        .getMacro()
      ;
  }
  
  public void newMacroSimOUT() {
    new MacroCUSTOM(plane)
      .setLabel("SIM OUT")
      .setWidth(170)
      .align()
      .addMCsFltWatcher()
        .addValue(tick)
        .setText("   tick")
        .getMacro()
      .addMCsFltWatcher()
        .addValue(tick_by_frame)
        .setText("   speed")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(fr.value)
        .setText("framerate")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(fr.time)
        .setText("time s")
        .getMacro()
      ;
  }
  
  public void reset() {
    randomSeed(SEED.get());
    for (Community c : list) c.reset();
    tick.set(0);
    fr.reset();
  }
  
  public void frame() {
    for (Community c : list) c.isFrame = true;
    if (!pause.get()) {
      tick_pile += tick_by_frame.get();
      
      //auto screenshot before reset
      if (auto_reset.get() && auto_reset_turn.get() == tick.get() + tick_by_frame.get() + tick_by_frame.get() && auto_screenshot.get()) {
          cam.screenshot = true; }
      
      boolean flag = true;
      while (tick_pile >= 1) {
        tick();
        if (flag) for (Community c : list) c.isFrame = false;
        flag = false;
        tick_pile--;
      }
      
      //run_each_unpaused_frame
      callChannel(unpaused_frame_chan);
    }
    
    if (next_tick) { tick(); next_tick = false; }
    
    //run custom frame methods
    for (Community c : list) c.frame();
  }
  
  public void tick() {
    
    //auto reset
    if (auto_reset.get() && auto_reset_turn.get() <= tick.get()) {
      if (auto_reset_rng_seed.get()) {
        SEED.set(PApplet.parseInt(random(1000000000)));
      }
      reset();
    }
    
    //tick communitys
    for (Community c : list) c.tick();
    
    //tick call
    callChannel(tick_chan);
    
    tick.set(tick.get()+1);
  }
  
  public void draw_to_cam() {
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_pre_entity();
    for (Community c : list) if (c.show_entity.get()) c.draw_Cam();
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_post_entity();
  }
  public void draw_to_screen() { for (Community c : list) if (c.show_entity.get()) c.draw_Screen(); }
}

abstract class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  sInt MAX_ENT = new sInt(simval, 500); //longueur max de l'array d'objet
  sInt initial_entity = new sInt(simval, 0);
  int id; //index dans comu list
  sInt activeEntity = new sInt(simval, 0);
  Simulation comList;
  sPanel panel;
  sBoo adding_type = new sBoo(simval, true);
  int adding_pile = 0;
  sInt adding_step = new sInt(simval, 10); // add one new object each adding_step turn
  float adding_counter = 0;
  sBoo show_entity = new sBoo(simval, true);
  sBoo show_menu = new sBoo(simval, true);
  String name = "";
  boolean isFrame = false;
  
  Community(Simulation _c, String n, int max) { comList = _c; name = n; MAX_ENT.set(max); }
  
  public Community show_menu() { panel.g.show(); show_menu.set(true); return this; }
  public Community hide_menu() { panel.g.hide(); show_menu.set(false); return this; }
  public Community show_entity() { show_entity.set(true); return this; }
  public Community hide_entity() { show_entity.set(false); return this; }
  
  //void custom_setup() {}
  //void custom_draw() {}
  public void custom_build() {}
  public void custom_reset() {}
  public void custom_frame() {}
  public abstract void custom_pre_tick();
  public abstract void custom_post_tick();
  public abstract void custom_cam_draw_pre_entity();
  public abstract void custom_cam_draw_post_entity();
  public void custom_screen_draw() {}
  
  public void building() {
    comList.panel.addDrawer(20)
        .addText("Community: "+name, 0, 0)
          .setFont(18)
          .getDrawer()
        .addSwitch("M", 280, 0)
          .setValue(show_menu)
          .setSize(50, 20).setFont(18)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (show_menu.get()) panel.big.hide(); else panel.big.show(); } } )
          .getDrawer()
        .addSwitch("D", 330, 0)
          .setValue(show_entity)
          .setSize(50, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    
    panel = new sPanel(cp5, 20 + id*50, 20 + id*30)
      .addTitle(name+" Control", 90, 0, 28)
      .addLine(10)
      .addText("Utilities", 140, 0, 22)
      .addSeparator(8)
      .addDrawer(20)
        .addText("Active Entity: ", 0, 0)
          .setValue(activeEntity)
          .setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addValueController("Max Entity: ", sMode.INCREMENT, 100, 10, MAX_ENT).lastDrawer()
        .addButton("i", 80, 5)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { init_array(); reset(); } } )
          .setSize(20, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addValueController("To Add: ", sMode.INCREMENT, 10, 1, initial_entity)
      .addSeparator(10)
      .addValueController("Step: ", sMode.INCREMENT, 10, 1, adding_step).lastDrawer()
        .addSwitch("S", 80, 5)
          .setValue(adding_type)
          .setSize(20, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addButton("ADD", 120, 0)
          .setSize(140, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { adding_pile += initial_entity.get(); } } )
          .getDrawer()
        .getPanel()
      .addLine(22)
      ;
    if (!show_menu.get()) panel.big.hide();
    
    plane.build_panel
      .addText("Community: " + name, 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("INIT", 0, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuINIT(); } } )
          .getDrawer()
        .addButton("ADD", 130, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuADD(); } } )
          .getDrawer()
        .addButton("POP", 260, 0)
          .setSize(120, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    custom_build();
  }
  
  public void newMacroComuINIT() {
    new MacroCUSTOM(plane)
      .setLabel(name + " INIT")
      .setWidth(250)
      .addMCsIntControl()
        .setValue(MAX_ENT)
        .setText("")
        .getMacro()
      .addMCsIntControl()
        .setValue(initial_entity)
        .setText("")
        .getMacro()
      .addMCsIntControl()
        .setValue(adding_step)
        .setText("")
        .getMacro()
      .addMCsBooControl()
        .setValue(adding_type)
        .setText("              do step")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(MAX_ENT)
        .setText("     max")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(initial_entity)
        .setText("     add")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(adding_step)
        .setText("    step")
        .getMacro()
      .addMCsBooWatcher()
        .addValue(adding_type)
        .setText("")
        .getMacro()
      ;
  }
  
  public void newMacroComuADD() {
    new MacroCUSTOM(plane)
      .setLabel("ADD " + name)
      .setWidth(120)
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { adding_pile += initial_entity.get(); }})
        .setText("add")
        .getMacro()
      ;
  }
  
  public void newMacroComuOUT() {
    new MacroCUSTOM(plane)
      .setLabel(name + " POP")
      .setWidth(160)
      .addMCsIntWatcher()
        .addValue(activeEntity)
        .setText("  active")
        .getMacro()
      ;
  }
  
  public void init_array() {
    list.clear();
    for (int i = 0; i < MAX_ENT.get() ; i++)
      list.add(build());
  }
  
  public void init() {
    id = comList.list.size();
    comList.list.add(this);
    init_array();
  }
  
  public void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (MAX_ENT.get() != list.size()) init_array();
    if (!adding_type.get()) 
      for (int j = 0; j < initial_entity.get(); j++)
        initialEntity();
    if (adding_type.get()) adding_pile = initial_entity.get();
    custom_reset();
  }
  
  public void frame() {
    custom_frame();
  }
  
  public void tick() {
    if (adding_type.get() && adding_pile >= 1) {
      adding_counter++;
      if (adding_counter >= adding_step.get()) {
        adding_counter = 0;
        initialEntity();
        adding_pile--;
      }
    }
    custom_pre_tick();
    for (Entity e : list) if (e.active) e.tick();
    for (Entity e : list) if (e.active) e.age++;
    activeEntity.set(active_Entity_Nb());
    custom_post_tick();
  }
  
  public void draw_Cam() {
    for (Entity e : list) if (e.active) e.drawing(); }
  public void draw_Screen() {
    custom_screen_draw(); }
  public void destroy_All() {
    for (Entity e : list) e.destroy(); }
  
  public int active_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n;
  }
  
  public abstract Entity build();
  public abstract Entity initialEntity();
  public abstract Entity newEntity();
}

abstract class Entity { 
  Community com;
  int id, age;
  boolean active;
  Entity(Community c) {
    active = false;
    id = c.list.size();
    com = c;
    age = 0;
  }
  public Entity activate() {
    if (!active) { active = true; age = 0; init(); }
    return this;
  }
  public Entity destroy() {
    if (active) { active = false; clear(); }
    return this;
  }
  public abstract Entity tick();      //exec by community in run all
  public abstract Entity drawing();  //exec by community in draw all
  public abstract Entity init();     //exec by activate and community.reset
  public abstract Entity clear();    //exec by destroy
  
  public void draw_halo(Canvas canvas, PImage i) {}
}
 //la lib pour les menu


public void init_Tabs(String s) {
  
  int c = color(190);
  cp5.addTab("Menu")
    .setSize(100,30)
    .setHeight(30)
    .setLabel("  Menu")
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;
  cp5.addTab("Macros")
    .setSize(100,30)
    .setHeight(30)
    .setLabel("  Macros")
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;

  cp5.getTab("default")
    .setSize(100,30)
    .setHeight(30)
    .setLabel("  View")
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;
  cp5.getTab(s).bringToFront();
  
  cp5.getWindow()
    .setPositionOfTabs(35, height-30)
    .setColorBackground(color(5, 55, 99, 255))
    .setColorForeground(color(13, 130, 240, 255))
    .setColorActive(color(10, 100, 180, 255))
    ;

}

class sGrabable extends Callable {
  float mx = 0; float my = 0;
  Group g;
  PVector pos = new PVector(0, 0);
  boolean pos_loaded = false;
  
  sFlt pos_x = new sFlt(simval, 0);
  sFlt pos_y = new sFlt(simval, 0);
  
  sGrabable(ControlP5 c, float x, float y) {
    g = new Group(c, "panel" + get_free_id());
    pos = cam.screen_to_cam(new PVector(x, y));
    g.setPosition(x, y)
        .setSize(20, 0)
        .setBackgroundHeight(0)
        .setBarHeight(20)
        //.setColorActive(color(255))
        .setColorBackground(color(200))
        .disableCollapse()
        .moveTo("Menu")
        .getCaptionLabel().setText("");
        
    this.addChannel(frame_chan);
    this.addChannel(cam.zoom_chan);
  }
  
  public void hide() { g.hide(); }
  public void show() { g.show(); }
  
  public float getX() { return g.getPosition()[0]; }
  public float getY() { return g.getPosition()[1]; }
  public PVector getP() { return new PVector(g.getPosition()[0], g.getPosition()[1]); }
  
  public sGrabable setTab(String s) { g.moveTo(s); return this; }
  
  public void answer(Channel chan, float value) {
    if (chan == frame_chan) {
      if (!pos_loaded) {
        g.setPosition(pos_x.get(),pos_y.get());
        pos = cam.screen_to_cam(new PVector(pos_x.get(),pos_y.get()));
        pos_loaded = true;
      } else {
        if (g.isMouseOver()) {
          if (kb.mouseClick[0]) {
            mx = g.getPosition()[0] - mouseX;
            my = g.getPosition()[1] - mouseY;
            cam.GRAB = false; //deactive le deplacement camera
          } else if (kb.mouseUClick[0]) {
            cam.GRAB = true;
          }
          if (kb.mouseButtons[0]) {
            g.setPosition(mouseX + mx,mouseY + my);
            pos = cam.screen_to_cam(new PVector(mouseX + mx, mouseY + my));
            pos_x.set(mouseX + mx);
            pos_y.set(mouseY + my);
          }
        } else {
          if (kb.mouseClick[0] && cam.GRAB == true) {
            mx = g.getPosition()[0] - mouseX;
            my = g.getPosition()[1] - mouseY;
          }
          if (kb.mouseButtons[0] && cam.GRAB == true) {
            g.setPosition(mouseX + mx,mouseY + my);
            pos = cam.screen_to_cam(new PVector(mouseX + mx, mouseY + my));
            pos_x.set(mouseX + mx);
            pos_y.set(mouseY + my);
          }
        }
      }
    }
    if (chan == cam.zoom_chan) {
      PVector p = cam.cam_to_screen(pos);
      g.setPosition(p.x, p.y); 
    }
  }
}

class sPanel extends Callable {
  int PANEL_WIDTH = 400;
  int PANEL_MARGIN = 10;
  int drawer_height = 0;
  sDrawer last_drawer = null;
  float mx = 0; float my = 0;
  Group big;
  Group g;
  Button hideButton;
  boolean pos_loaded = false;
  
  sBoo closed = new sBoo(simval, false);
  sInt pos_x = new sInt(simval, 100);
  sInt pos_y = new sInt(simval, 100);
  
  sPanel(ControlP5 c, float x, float y) {
    g = new Group(c, "panel" + get_free_id()) {
      public void onEnter() {
        //println("enter");
        super.onEnter();
      }
      public void onLeave() {
        //println("leave");
        super.onLeave();
      }
    };
    big = new Group(c, "panel" + get_free_id());
    
    pos_x.set(PApplet.parseInt(x));
    pos_y.set(PApplet.parseInt(y));
    
    g.setPosition(0, 0)
        .setSize(PANEL_WIDTH, 0)
        .setBackgroundHeight(0)
        .setBarHeight(0)
        .setBackgroundColor(color(60, 200))
        .disableCollapse()
        .moveTo("Menu")
        .setGroup(big)
        .getCaptionLabel().setText("");
    big.setPosition(x, y)
        .setSize(PANEL_WIDTH, 0)
        .setBackgroundHeight(35)
        .setBackgroundColor(color(60))
        .setBarHeight(12)
        .disableCollapse()
        .moveTo("Menu")
        .getCaptionLabel().setText("");
    hideButton = new Button(c, "button"+get_free_id());
    hideButton.setPosition(PANEL_WIDTH-20, 0)
        .setSize(20, 20)
        .setGroup(big)
        .setSwitch(true)
        .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (g.isVisible()) { closed.set(true); g.hide(); hideButton.getCaptionLabel().setText("v"); }
              else { closed.set(false); g.show(); hideButton.getCaptionLabel().setText("-"); } } } )
        .getCaptionLabel().setText("-").setFont(getFont(18));
    this.addChannel(frame_chan);
  }
  
  public void answer(Channel channel, float value) {
    if (!pos_loaded) {
      big.setPosition(pos_x.get(),pos_y.get());
      if (closed.get()) { hideButton.setOn(); }
      pos_loaded = true;
    } else {
      //moving control panel
      if (big.isMouseOver()) {
        if (kb.mouseClick[0]) {
          mx = big.getPosition()[0] - mouseX;
          my = big.getPosition()[1] - mouseY;
          cam.GRAB = false; //deactive le deplacement camera
        } else if (kb.mouseUClick[0]) {
          cam.GRAB = true;
        }
        if (kb.mouseButtons[0]) {
          big.setPosition(mouseX + mx,mouseY + my);
          pos_x.set(PApplet.parseInt(mouseX+mx));
          pos_y.set(PApplet.parseInt(mouseY+my));
        }
      }
    }
  }
  
  public sPanel setTab(String s) { big.moveTo(s); return this; }
  
  public sDrawer addDrawer(int h) { return new sDrawer(this, h); }
  public sDrawer lastDrawer() { return last_drawer; }
  
  public sPanel addRngTryCtrl(String title, RandomTryParam p) {
    addValueController(title, sMode.FACTOR, 2, 1.2f, p.DIFFICULTY).lastDrawer()
      .addSwitch("", 80, 5)
        .setValue(p.ON)
        .setSize(20, 20).setFont(18)
      ;
    return this;
  }
  public sPanel addTitle(String title, int x, int y, int s) {
    addDrawer(s + y)
      .addText(title, x, y)
        .setFont(s)
        .setGroup(big);
    return this;
  }
  public sPanel addText(String title, int x, int y, int s) {
    addDrawer(s + y)
      .addText(title, x, y)
        .setFont(s);
    return this;
  }
  public sPanel addLine(int h) {
    addDrawer(h)
      .addLine(PANEL_MARGIN*6, h / 2 - 1, PANEL_WIDTH - PANEL_MARGIN*14);
    return this;
  }
  public sPanel addSeparator(int h) {
    addDrawer(h);
    return this;
  }
  
  public sPanel addValueController(String label, sMode mode, float f1, float f2, sInt i) {
    String signe1 = "-", signe2 = "+";
    float f1a = 0, f1b = 0, f2a = 0, f2b = 0;
    if (mode == sMode.INCREMENT) {
      f1a = -f1; f1b = f1; f2a = -f2; f2b = f2;
    } else if (mode == sMode.FACTOR) {
      signe1 = "/"; signe2 = "x";
      f1a = 1/f1; f2a = 1/f2; f1b = f1; f2b = f2;
    }
    String s1,s2;
    if (f1%1 == 0) s1 = str(PApplet.parseInt(f1)); else s1 = str(f1);
    if (f2%1 == 0) s2 = str(PApplet.parseInt(f2)); else s2 = str(f2);
    addDrawer(30)
      .addIntModifier(signe1+s1, 0, 0)
        .setMode(mode, f1a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier(signe1+s2, 40, 0)
        .setMode(mode, f2a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addText(label, 110, 5)
        .setFont(18)
      .getDrawer()
      .addText("", 210, 5)
        .setValue(i)
        .setFont(18)
      .getDrawer()
      .addIntModifier(signe2+s2, 310, 0)
        .setMode(mode, f2b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier(signe2+s1, 350, 0)
        .setMode(mode, f1b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      ;
    return this;
  }
  public sPanel addValueController(String label, sMode mode, float f1, float f2, sFlt i) {
    String signe1 = "-", signe2 = "+";
    float f1a = 0, f1b = 0, f2a = 0, f2b = 0;
    if (mode == sMode.INCREMENT) {
      f1a = -f1; f1b = f1; f2a = -f2; f2b = f2;
    } else if (mode == sMode.FACTOR) {
      signe1 = "/"; signe2 = "x";
      f1a = 1/f1; f2a = 1/f2; f1b = f1; f2b = f2;
    }
    String s1,s2;
    if (f1%1 == 0) s1 = str(PApplet.parseInt(f1)); else s1 = str(f1);
    if (f2%1 == 0) s2 = str(PApplet.parseInt(f2)); else s2 = str(f2);
    addDrawer(30)
      .addFltModifier(signe1+s1, 0, 0)
        .setMode(mode, f1a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier(signe1+s2, 40, 0)
        .setMode(mode, f2a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addText(label, 110, 5)
        .setFont(18)
      .getDrawer()
      .addText("", 210, 5)
        .setValue(i)
        .setFont(18)
      .getDrawer()
      .addFltModifier(signe2+s2, 310, 0)
        .setMode(mode, f2b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier(signe2+s1, 350, 0)
        .setMode(mode, f1b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      ;
    return this;
  }
}

class sDrawer {
  int mx, my, h;
  sPanel panel;
  
  sDrawer(sPanel p, int _h) { 
    h = _h; 
    panel = p; 
    mx = p.PANEL_MARGIN; 
    my = p.drawer_height; 
    p.drawer_height += _h;
    p.g.setBackgroundHeight(p.drawer_height + 1);
    p.last_drawer = this;
  }
  
  public sPanel getPanel() { return panel; }
  
  public sDrawer addExclusiveSwitchs(String l1, String l2, int x, int y, sBoo b1, sBoo b2) {
    sExclusifSwitch s1 = addExclusifSwitch(l1, x, y);
    s1.setValue(b1).setSize(60, 20).setFont(16);
    sExclusifSwitch s2 = addExclusifSwitch(l2, x+70, y);
    s2.setValue(b2).setSize(60, 20).setFont(16);
    s1.addExclu(s2);
    s2.addExclu(s1);
    return this;
  }
  
  public sDrawer addExclusiveSwitchs(String l1, String l2, String l3, int x, int y, sBoo b1, sBoo b2, sBoo b3) {
    sExclusifSwitch s1 = addExclusifSwitch(l1, x, y);
    s1.setValue(b1).setSize(60, 20).setFont(16);
    sExclusifSwitch s2 = addExclusifSwitch(l2, x+70, y);
    s2.setValue(b2).setSize(60, 20).setFont(16);
    sExclusifSwitch s3 = addExclusifSwitch(l3, x+140, y);
    s2.setValue(b3).setSize(60, 20).setFont(16);
    s1.addExclu(s2).addExclu(s3);
    s2.addExclu(s1).addExclu(s3);
    s3.addExclu(s1).addExclu(s2);
    return this;
  }
  
  public sTextfield addTextfield(int _x, int _y) {
    sTextfield b = new sTextfield(cp5, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sExclusifSwitch addExclusifSwitch(String label, int _x, int _y) {
    sExclusifSwitch b = new sExclusifSwitch(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sSwitch addSwitch(String label, int _x, int _y) {
    sSwitch b = new sSwitch(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sIntModifier addIntModifier(String label, int _x, int _y) {
    sIntModifier b = new sIntModifier(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sFltModifier addFltModifier(String label, int _x, int _y) {
    sFltModifier b = new sFltModifier(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sButton addButton(String label, int _x, int _y) {
    sButton b = new sButton(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  public sLabel addText(String label, int _x, int _y) {
    sLabel l = new sLabel(cp5, label, _x+mx, _y+my);
    l.setPanel(panel);
    l.drawer = this;
    return l;
  }
  public sDrawer addLine(int _x, int _y, int _l) {
    sLine l = new sLine(cp5, "line"+get_free_id(), _x+mx, _y+my, _l);
    l.setGroup(panel.g);
    return this;
  }
}








class sTextfield extends Callable {
  Textfield t;
  sDrawer drawer = null;
  
  sFlt fval = null;
  sInt ival = null;
  
  sTextfield(ControlP5 cp5, float x, float y) {
    t = cp5.addTextfield("textfield" + get_free_id())
      .setPosition(x, y)
      .setSize(220, 30)
      .setCaptionLabel("")
      .setValue("")
      .setFont(getFont(18))
      .setColor(color(255))
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { 
          if (ival != null) ival.set(PApplet.parseInt(t.getText()));
          else if (fval != null) fval.set(PApplet.parseFloat(t.getText()));
        } } )
      ;
  }
  
  public sDrawer getDrawer() { return drawer; }
  
  public sTextfield setValue(sFlt i) {
    this.addChannel(frame_chan);
    fval = i;
    ival = null;
    this.setText();
    return this;
  }
  public sTextfield setValue(sInt i) {
    this.addChannel(frame_chan);
    ival = i;
    fval = null;
    this.setText();
    return this;
  }
  
  public sTextfield setPanel(sPanel p) { t.setGroup(p.g); return this; }
  public sTextfield setPos(int _x, int _y) { t.setPosition(_x, _y); return this; }
  public sTextfield setSize(int _x, int _y) { t.setSize(_x, _y); return this; }
  public sTextfield setFont(int s) { t.setFont(getFont(s)); return this; }
  
  public void answer(Channel channel, float value) {
    if (fval != null && fval.has_changed) this.setText();
    if (ival != null && ival.has_changed) this.setText();
  }
  public void setText() {
    if (ival != null) t.setText(str(ival.get()));
    else if (fval != null) t.setText(str(fval.get()));
    else t.setText("");
  }
  public sTextfield setText(String s) { t.setText(s); return this; }
  public String getText() { return t.getText(); }
}



enum sMode { INCREMENT, FACTOR }

class sIntModifier extends sButton {
  sInt val = null;
  float modifier = 0;
  sMode mode = sMode.INCREMENT;
  
  sIntModifier(ControlP5 cp5) { super(cp5); }
  sIntModifier(ControlP5 cp5, String label, int _x, int _y) { super(cp5, label, _x, _y); }
  
  public sIntModifier setIncremental(float m) { mode = sMode.INCREMENT; modifier = m; return this; }
  public sIntModifier setFactorial(float m) { mode = sMode.FACTOR; modifier = m; return this; }
  public sIntModifier setMode(sMode _m, float f) { mode = _m; modifier = f; return this; }
  
  public sIntModifier setValue(sInt v) {
    val = v;
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null)
          if (mode == sMode.INCREMENT)
            val.set(PApplet.parseInt(val.get()+modifier));
          else if (mode == sMode.FACTOR)
            val.set(PApplet.parseInt(val.get()*modifier));
      }
    });
    return this;
  }
}





class sFltModifier extends sButton {
  sFlt val = null;
  float modifier = 0;
  sMode mode = sMode.INCREMENT;
  
  sFltModifier(ControlP5 cp5) { super(cp5); }
  sFltModifier(ControlP5 cp5, String label, int _x, int _y) { super(cp5, label, _x, _y); }
  
  public sFltModifier setIncremental(float m) { mode = sMode.INCREMENT; modifier = m; return this; }
  public sFltModifier setFactorial(float m) { mode = sMode.FACTOR; modifier = m; return this; }
  public sFltModifier setMode(sMode _m, float f) { mode = _m; modifier = f; return this; }
  public sFltModifier setValue(sFlt v) {
    val = v;
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null)
          if (mode == sMode.INCREMENT)
            val.set(val.get()+modifier);
          else if (mode == sMode.FACTOR)
            val.set(val.get()*modifier);
      }
    });
    return this;
  }
}




class sExclusifSwitch extends sButton {
  sBoo val = null;
  ArrayList<sExclusifSwitch> exclu = new ArrayList<sExclusifSwitch>();
  sExclusifSwitch(ControlP5 cp5) {
    super(cp5);
    b.setSwitch(true);
  }
  sExclusifSwitch(ControlP5 cp5, String label, int _x, int _y) {
    super(cp5, label, _x, _y); 
    b.setSwitch(true);
  }
  
  public sExclusifSwitch setValue(sBoo v) {
    val = v;
    this.addChannel(frame_chan);
    if (val.get()) b.setOn();
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null) val.set(b.isOn());
        if (val.get()) for (sExclusifSwitch s : exclu) s.val.set(false);
      }
    });
    return this;
  }
  
  public sExclusifSwitch addExclu(sExclusifSwitch s) { exclu.add(s); return this; }
  
  public void answer(Channel chan, float v) {
    if (val != null && val.has_changed) {
      if (val.get()) b.setOn(); else b.setOff();
      //val.set(!val.get()); // the controlListener was called by b.set so we change the value back
    }
  }
}






class sSwitch extends sButton {
  sBoo val = null;
  sSwitch(ControlP5 cp5) {
    super(cp5);
    b.setSwitch(true);
  }
  sSwitch(ControlP5 cp5, String label, int _x, int _y) {
    super(cp5, label, _x, _y); 
    b.setSwitch(true);
  }
  
  public sSwitch setValue(sBoo v) {
    val = v;
    this.addChannel(frame_chan);
    if (val.get()) b.setOn();
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null) val.set(!val.get()); }
    });
    return this;
  }
  
  public void answer(Channel chan, float v) {
    if (val != null && val.has_changed) {
      if (val.get()) b.setOn(); else b.setOff();
      val.set(!val.get()); // the controlListener was called by b.set so we change the value back
    }
  }
}





class sButton extends Callable {
  sDrawer drawer;
  Button b;
  
  sButton(ControlP5 cp5) { init(cp5); }
  sButton(ControlP5 cp5, String label, int _x, int _y) {
    init(cp5);
    setText(label);
    setPos(_x, _y);
  }
  
  public sDrawer getDrawer() { return drawer; }
  
  public void init(ControlP5 cp5) {
    int id = get_free_id();
    b = cp5.addButton("button" + id)
       .setId(id);
    setText("");
    setPos(10, 10);
    setSize(100, 20);
    b.getCaptionLabel().setFont(getFont(18));
  }
  
  public sButton addListener(ControlListener c) { b.addListener(c); return this; }
  
  public sButton setPanel(sPanel p) { b.setGroup(p.g); return this; }
  public sButton setText(String text) { b.getCaptionLabel().setText(text); return this; }
  public sButton setPos(int _x, int _y) { b.setPosition(_x, _y); return this; }
  public sButton setSize(int _x, int _y) { b.setSize(_x, _y); return this; }
  public sButton setFont(int s) { b.getCaptionLabel().setFont(getFont(s)); return this; }
  
  public void answer(Channel chan, float val) {}
}





class sLabel extends Callable {
  sDrawer drawer;
  Textlabel t;
  sFlt fval = null;
  sInt ival = null;
  String text_start = "";
  String text_end = "";
  int text_font = 18; // = textWidth(str)??
  sLabel(ControlP5 cp5) {
    t = cp5.addTextlabel("textlabel" + get_free_id());
    t.setColorValue(color(255))
       .setFont(getFont(text_font));
  }
  sLabel(ControlP5 cp5, String _text, int _x, int _y) {
    t = cp5.addTextlabel("textlabel" + get_free_id());
    t.setColorValue(color(255))
       .setFont(getFont(text_font));
    setText(_text, "");
    setPos(_x, _y);
  }
  public sDrawer getDrawer() { return drawer; }
  public void answer(Channel channel, float value) {
    if (fval != null && fval.has_changed) this.print();
    if (ival != null && ival.has_changed) this.print();
  }
  public void print() {
    if (ival != null) t.setText(text_start + str(ival.get()) + text_end);
    else if (fval != null) {t.setText(text_start + trimStringFloat(fval.get()) + text_end); }
    else t.setText(text_start + text_end);
  }
  public sLabel setPanel(sPanel p) { t.setGroup(p.g); return this; }
  public sLabel setGroup(Group p) { t.setGroup(p); return this; }
  public sLabel setValue(sFlt i) {
    this.addChannel(frame_chan);
    fval = i;
    ival = null;
    this.print();
    return this;
  }
  public sLabel setValue(sInt i) {
    this.addChannel(frame_chan);
    ival = i;
    fval = null;
    this.print();
    return this;
  }
  public sLabel setText(String _s) {
    text_start = _s; text_end = "";
    this.print();
    return this;
  }
  public sLabel setText(String _s, String _e) {
    text_start = _s; text_end = _e;
    this.print();
    return this;
  }
  public sLabel setPos(int _x, int _y) { t.setPosition(_x, _y); return this; }
  public sLabel setColor(int c) { t.setColorValue(c); return this; }
  public sLabel setFont(int s) { t.setFont(getFont(s)); text_font = s; return this; }
}

class sLine extends Controller<sLine> {
  int length = 0;
  int thick = 1;
  sLine(ControlP5 cp5, String theName, int x, int y, int l) {
    super(cp5, theName);
    length = l;
    setPosition(x, y);
    setView(new ControllerView() { // replace the default view with a custom view.
      public void display(PGraphics p, Object b) {
        // draw button background
        p.stroke(255);
        p.strokeWeight(thick);
        p.rect(0, 0, length, thick);
        p.noStroke();
      }
    } );
  }
}
class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroPlane macroList;
  
  LinkList(MacroPlane m) {
    macroList = m;
  }
  
  public void clear() {
    linkBList.clear();
    linkFList.clear();
  }
  
  //void to_strings() {
  //  for (LinkB m : linkBList)
  //    m.to_strings();
  //  for (LinkF m : linkFList)
  //    m.to_strings();
  //}
  
  public LinkB createLinkB() {
    LinkB l = new LinkB(plane);
    linkBList.add(l);
    return l;
  }

  public LinkF createLinkF() {
    LinkF l = new LinkF(plane);
    linkFList.add(l);
    return l;
  }
}

class LinkB {
  MacroPlane macroList;
  InputB in;
  OutputB out;
  LinkB(MacroPlane m) {
    macroList = m;
  }
  //void to_strings() {
  //  if (this != macroList.NOTB) {
  //    file.append("linkB");
  //    file.append(str(in.id));
  //    file.append(str(out.id));
  //  }
  //}
  public boolean collision(int x, int y) {
    if (macroList != null && this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (macroList != null && 
        macroList.NOTB != null && macroList.NOTBI != null && macroList.NOTBO != null && 
        this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
        if (out.bang) {stroke(255,255,0,180); fill(255,255,0);} else {stroke(182,182,0,180); fill(182,182,0);}
      } else {
        if (out.bang) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
      }
      if (in.in.getTab().isActive() && out.out.getTab().isActive()) {
        strokeWeight(3);
        line(in.x,in.y,out.x,out.y);
      }
      ellipseMode(RADIUS);
      noStroke();
      if (out.out.getTab().isActive()) {
        ellipse(out.x,out.y,6,6);
      }
      if (in.in.getTab().isActive()) {
        if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
          if (in.in.isOn()) {fill(255,255,0);} else {fill(182,182,0);}
        } else {
          if (in.in.isOn()) {fill(255);} else {fill(182);}
        }
        ellipse(in.x,in.y,6,6);
      }
    }
  }
}

class LinkF {
  MacroPlane macroList;
  InputF in;
  OutputF out;
  float value = 0;
  LinkF(MacroPlane m) {
    macroList = m;
  }
  //void to_strings() {
  //  if (this != macroList.NOTF) {
  //    file.append("linkF");
  //    file.append(str(in.id));
  //    file.append(str(out.id));
  //  }
  //}
  public boolean collision(int x, int y) {
    if (macroList != null && this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (macroList != null && 
        macroList.NOTB != null && macroList.NOTBI != null && macroList.NOTBO != null && 
        this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
        if (out.bang) {stroke(255,255,0,180); fill(255,255,0);} else {stroke(182,182,0,180); fill(182,182,0);}
      } else {
        if (out.bang) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
      }
      if (in.in.getTab().isActive() && out.out.getTab().isActive()) {
        strokeWeight(3);
        line(in.x,in.y,out.x,out.y);
      }
      ellipseMode(RADIUS);
      noStroke();
      if (out.out.getTab().isActive()) {
        ellipse(out.x,out.y,6,6);
      }
      if (in.in.getTab().isActive()) {
        if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
          if (in.in.isOn()) {fill(255,255,0);} else {fill(182,182,0);}
        } else {
          if (in.in.isOn()) {fill(255);} else {fill(182);}
        }
        ellipse(in.x,in.y,6,6);
      }
    }
  }
}

abstract class InputA extends Callable {
  MacroPlane macroList;
  int x,y,n;
  int id = 0;
  Group g;
  Button in;
  boolean bang = false;
  InputA(MacroPlane m, String s_, int _id, Group g_, int n_) {
    macroList = m;
    id = _id;
    g = g_;
    n = n_;
    in = cp5.addButton(s_ + str(id))
       .setSwitch(true)
       .setLabelVisible(false)
       .setPosition(0, 3 + (n*26))
       .setSize(12,22)
       .setGroup(g)
       ;
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 12 + (n*26));
    addChannel(frame_chan);
  }
  public void clear() {
    in.remove();
    g.remove();
  }
  //void to_strings() {
  //  file.append("input");
  //  file.append(str(id));
  //  file.append(str(x));
  //  file.append(str(y));
  //  file.append(str(n));
  //}
}

class InputB extends InputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);
  Textlabel t;
  InputB(MacroPlane m, int id, Group g_, int i, String text, int n_) {
    super(m, "inB", id, g_, n_);
    t = cp5.addTextlabel("Ctrl" + str(i) + "inBText" + str(n))
                    .setText(text)
                    .setPosition(28, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
  }
  public void clear() {
    for (LinkB t : l) macroList.linkList.linkBList.remove(t);
    t.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("B");
  //}
  public void answer(Channel chan, float v) {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    
  }
  public boolean getUpdate() {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    bang = false;
    for (LinkB b : l) {
      if (!b.out.updated) {return false;}
    }
    for (LinkB b : l) {
      bang |= b.out.bang;
    }
    if (bang) {in.setOn();} else {in.setOff();}
    return true;
  }
  public boolean get() {
    return bang;
  }
}

class InputF extends InputA {
  ArrayList<LinkF> l = new ArrayList<LinkF>(0);
  float value;
  Textfield textf;
  Textlabel t;
  Button ch;
  boolean auto_reset = false;
  InputF(MacroPlane m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "inF", id, g_, n_);
    value = d;
    t = cp5.addTextlabel("Ctrl" + str(id) + "inFText" + str(n))
                    .setText(text)
                    .setPosition(88, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
    textf = cp5.addTextfield("Ctrl" + str(id) + "inFTextfield" + str(n_))
       .setLabel("")
       .setPosition(28, 3 + (n_*26))
       .setSize(60,22)
       .setAutoClear(false)
       .setDecimalPrecision(3)
       //.lock()
       .setInputFilter(cp5.FLOAT)
       .setGroup(g)
       .setFocus(true)
       .setText(str(value))
       .setFocus(false)
       .addCallback(new CallbackListener() {
          public void controlEvent(final CallbackEvent ev) {  
            value = PApplet.parseFloat(textf.getText());
          }
        }) 
       ;
    textf.getValueLabel().setFont(createFont("Arial",18));
    ch = cp5.addButton("button" + get_free_id())
      .setGroup(g)
      .setSize(12, 22)
      .setSwitch(true)
      .setPosition(in.getPosition()[0] + 14, in.getPosition()[1])
      .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) { auto_reset = ch.isOn(); } } )
      ;
    ch.getCaptionLabel().setText("R").setFont(getFont(12));
  }
  public void clear() {
    textf.remove();
    t.remove();
    for (LinkF t : l) macroList.linkList.linkFList.remove(t);
    super.clear();
  }
  public void answer(Channel chan, float v) {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkF) {macroList.addLinkSelectInF(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
  }
  public boolean getUpdate() {
    
    bang = false;
    for (LinkF f : l) {
      if (!f.out.updated) {return false;}
    }
    //
    for (LinkF f : l) {
      bang |= f.out.bang;
      if (f.out.bang) {value = f.out.value;}
    }
    if (bang) { textf.setFocus(true); textf.setText(str(value)); textf.setFocus(false); }
    if (!bang && auto_reset && value != 0) {
      value = 0;
      bang = true;
      textf.setFocus(true); textf.setText(str(value)); textf.setFocus(false);
    }
    if (!bang && PApplet.parseFloat(textf.getText()) != value) {
      value = PApplet.parseFloat(textf.getText());
      bang = true;
    }
    if (bang) {in.setOn();} else {in.setOff();}
    
    return true;
  }
  public boolean bang() {
    return bang;
  }
  public float get() {
    float d = value;
    getUpdate();
    return d;
  }
  public void set(float d) {
    value = d;
    textf.setFocus(true);
    textf.setText(str(d));
    textf.setFocus(false);
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("F");
  //  file.append(str(value));
  //}
}

abstract class OutputA extends Callable {
  MacroPlane macroList;
  boolean updated = false;
  int x = -100; int y = -100;
  int n = 0;
  int id = 0;
  Group g;
  Button out;
  boolean bang = false;

  OutputA(MacroPlane m, String s_, int _id, Group g_, int n_) {
    g = g_;
    n = n_;
    id = _id;
    macroList = m;
    out = cp5.addButton(s_ + str(id))
       .setSwitch(true)
       .setLabelVisible(false)
       .setPosition(g.getWidth() - 12, 3 + (n*26))
       .setSize(12,22)
       .setGroup(g)
       ;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    addChannel(frame_chan);
  }
  
  public void clear() {
    g.remove();
    out.remove();
  }
  //void to_strings() {
  //  file.append("output");
  //  file.append(str(id));
  //  file.append(str(x));
  //  file.append(str(y));
  //  file.append(str(n));
  //}
}

class OutputB extends OutputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);
  Textlabel t;
  OutputB(MacroPlane m, int id, Group g_, int i, String text, int n_) {
    super(m, "outB", id, g_, n_);
    t = cp5.addTextlabel("Ctrl" + str(i) + "outBText" + str(n))
                    .setText(text)
                    .setPosition(g.getWidth() - 100, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
  }
  public void clear() {
    t.remove();
    for (LinkB t : l) macroList.linkList.linkBList.remove(t);
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("B");
  //}
  public void set(boolean v) {
    bang = v;
    if (bang) {
      for (LinkB b : l) {
        b.in.bang = bang;
      }
    }
    //update();
  }
  public void bang() { set(true); }
  public void unBang() { set(false); }
  public boolean get() {
    return bang;
  }
  public void answer(Channel chan, float v) {
    if (out.isMouseOver() && kb.mouseClick[0]) {macroList.addLinkSelectOutB(this);}
    updated = true;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    if (bang) {out.setOn();} else {out.setOff();}
  }
  public OutputB linkTo(InputB in) {
    LinkB nl = macroList.linkList.createLinkB();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}

class OutputF extends OutputA {
  ArrayList<LinkF> l = new ArrayList<LinkF>(0);
  float value;
  Textfield textf;
  Textlabel t;
  OutputF(MacroPlane m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "outF", id, g_, n_);
    value = d;
    t = cp5.addTextlabel("Ctrl" + str(i) + "outFText" + str(n_))
                    .setText(text)
                    .setPosition(g.getWidth() - 160, 3 + (n_*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
    textf = cp5.addTextfield("Ctrl" + str(i) + "outFTextfield" + str(n_))
       .setLabel("")
       .setPosition(g.getWidth() - 76, 3 + (n_*26))
       .setSize(60,22)
       .setAutoClear(false)
       .setDecimalPrecision(3)
       .lock()
       .setGroup(g)
       .setFocus(true)
       .setText(str(value))
       .setFocus(false)
       ;
    textf.getValueLabel().setFont(createFont("Arial",18));
    
  }
  public void clear() {
    t.remove();
    textf.remove();
    for (LinkF t : l) macroList.linkList.linkFList.remove(t);
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("F");
  //  file.append(str(value));
  //}
  public void set(float v) {
    value = v;
  }
  public void setBang(float v) {
    if (value != v) { value = v; bang(); return; }
    value = v;
  }
  public void unBang() { bang = false; update(); }
  public void bang() {
    bang = true;
    for (LinkF f : l) {
      f.in.bang = true;
    }
    update();
  }
  public float get() {return value;}
  public void answer(Channel chan, float v) {
    if (out.isMouseOver() && kb.mouseClick[0]) {macroList.addLinkSelectOutF(this);}
    updated = true;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 12 + (n*26));
    //bang = false;
    update();
  }
  public void update() {
    //if (value < 0.000001) {value = 0;}
    if (bang) {out.setOn(); textf.setFocus(true); textf.setText(str(value).trim()); textf.setFocus(false);} else {out.setOff();}
  }
  public OutputF linkTo(InputF in) {
    LinkF nl = macroList.linkList.createLinkF();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}








/*

Basic Macro:    deja fait.
  Pulse
  MacroVAL
  MacroDELAY
  MacroCOMP
  MacroBOOL
  MacroCALC

nouvel objet macro, on peut y ajouté des entré/sortie customizable

MACROCustom
  addConnexion

Macro Custom Connexions:
  >MCListen(Channel) outB value
  >MCCall(Channel) inB value
  
  >MCsValueWatcher(sFlt) outF value
  >MCsValueWatcher(sBoo) outB value
  >MCsValueController(sFlt) inF value      BEUG!!!!
  >MCsValueController(sBoo) inB value
  
  >MCRun( code ) inB bang
  >MCKeyboard(key) outB bang
  
  MCsValueModifier(sFlt)
    inB bang, inF value, select : 'x' / '/' / '+' / '-'
  
*/


class MacroCUSTOM extends Macro {
  ArrayList<MCConnexion> connexions = new ArrayList<MCConnexion>();
  
  MacroCUSTOM(MacroPlane l_) {
    super(l_, l_.macroList.size(), l_.adding_pos, l_.adding_pos);
    g.setLabel("custom");
    g.setWidth(300);
  }
  
  public MacroCUSTOM setWidth(int w) { g.setWidth(w); return this; }
  public MacroCUSTOM setLabel(String s) { g.setLabel(s); return this; }
  public MacroCUSTOM setPos(int x, int y) { g.setPosition(x, y); return this; }
  public MacroCUSTOM align() { inCount = max(inCount, outCount); outCount = max(inCount, outCount); return this; }
  
  public MCCall addMCCall() { return new MCCall(this); }
  public MCListen addMCListen() { return new MCListen(this); }
  public MCRun addMCRun() { return new MCRun(this); }
  public MCsBooWatcher addMCsBooWatcher() { return new MCsBooWatcher(this); }
  public MCsFltWatcher addMCsFltWatcher() { return new MCsFltWatcher(this); }
  public MCsIntWatcher addMCsIntWatcher() { return new MCsIntWatcher(this); }
  public MCsBooControl addMCsBooControl() { return new MCsBooControl(this); }
  public MCsFltControl addMCsFltControl() { return new MCsFltControl(this); }
  public MCsIntControl addMCsIntControl() { return new MCsIntControl(this); }
  
  public void update() { //tick
    super.update();
    for (MCConnexion c : connexions) c.tick();
    updated = true;
  }
  
  public void drawing(float x, float y) {}
  public void clear() { super.clear(); }
  //void to_strings() { super.to_strings(); file.append(""); }
}

abstract class MCConnexion extends Callable {
  MacroCUSTOM macro;
  MCConnexion(MacroCUSTOM m) {
    macro = m; macro.connexions.add(this); }
  public MacroCUSTOM getMacro() { return macro; }
  public abstract void tick();
  public abstract MCConnexion setText(String s);
  public void answer(Channel c, float f) {}
}



class MCsFltControl extends MCConnexion {
  InputF in;
  sFlt flt;
  
  MCsFltControl(MacroCUSTOM m) { super(m);
    in =  macro.createInputF("CtrlF", 0); }
  
  public MCsFltControl setText(String s) { in.t.setText(s); return this; }
  public MCsFltControl setValue(sFlt b) { flt = b; in.set(flt.get()); return this; }
  
  public void tick() {
    if (in.getUpdate()) {
      if (in.bang()) {
        //print("b" + flt.get() + " ");
        flt.set(in.get());  // add other combinateur
        //println(flt.get());
      }
    }
  }
}




class MCsIntControl extends MCConnexion {
  InputF in;
  sInt i;
  
  MCsIntControl(MacroCUSTOM m) { super(m);
    in =  macro.createInputF("CtrlF", 0); }
  
  public MCsIntControl setText(String s) { in.t.setText(s); return this; }
  public MCsIntControl setValue(sInt b) { i = b; in.set(i.get()); return this; }
  
  public void tick() {
    if (in.getUpdate()) {
      if (in.bang()) {
        //print("b" + flt.get() + " ");
        i.set(PApplet.parseInt(in.get()));  // add other combinateur
        //println(flt.get());
      }
    }
  }
}




class MCsBooControl extends MCConnexion {
  InputB in;
  sBoo boo;
  boolean swtch = true;
  
  MCsBooControl(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("CtrlB");
    cp5.addButton("button" + get_free_id())
      .setGroup(macro.g)
      .setSize(12, 22)
      .setSwitch(true)
      .setOn()
      .setPosition(in.t.getPosition()[0] - 14, in.t.getPosition()[1])
      .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { swtch = !swtch; } } )
      .getCaptionLabel().setText("S").setFont(getFont(12))
      ;
  }
  
  public MCsBooControl setText(String s) { in.t.setText(s); return this; }
  public MCsBooControl setValue(sBoo b) { boo = b;; return this; }
  
  public void tick() {
    if (in.getUpdate()) {
      if (in.get()) {
        if (swtch) { boo.set(!boo.get()); }  //change l'etat de la cicle quand bang
        else boo.set(true); //set la cible TRUE quand bang
      } else {
        if (!swtch) boo.set(false); //set la cible FALSE quand pas bang
      }
    }
  }
}



class MCsFltWatcher extends MCConnexion {
  OutputF out;
  float v = 0;
  sFlt flt;
  Button ch;
  boolean onchange = true;
  
  MCsFltWatcher(MacroCUSTOM m) { super(m);
    out =  macro.createOutputF("WatchF", 0);
    ch = cp5.addButton("button" + get_free_id())
      .setGroup(macro.g)
      .setSize(12, 22)
      .setSwitch(true)
      .setPosition(out.out.getPosition()[0] - 14, out.out.getPosition()[1])
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { onchange = !ch.isOn(); } } )
      ;
    ch.getCaptionLabel().setText("A").setFont(getFont(12));
    addChannel(frame_chan);
  }
  
  public MCsFltWatcher setText(String s) { out.t.setText(s); return this; }
  
  public MCsFltWatcher addValue(sFlt f) {
    flt = f;
    v = f.get();
    out.setBang(v);
    return this; }
  public void answer(Channel c, float f) { out.set(flt.get()); out.update(); }
  public void tick() {
    float t = flt.get();
    out.set(t);
    if (v != t || !onchange) out.bang(); else out.unBang();
    v = t;
  }
}



class MCsIntWatcher extends MCConnexion {
  OutputF out;
  float v = 0;
  sInt i;
  Button ch;
  boolean onchange = true;
  
  MCsIntWatcher(MacroCUSTOM m) { super(m);
    out =  macro.createOutputF("WatchI", 0);
    ch = cp5.addButton("button" + get_free_id())
      .setGroup(macro.g)
      .setSize(12, 22)
      .setSwitch(true)
      .setPosition(out.out.getPosition()[0] - 14, out.out.getPosition()[1])
      .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) { onchange = !ch.isOn(); } } )
      ;
    ch.getCaptionLabel().setText("A").setFont(getFont(12));
    addChannel(frame_chan);
  }
  
  public MCsIntWatcher setText(String s) { out.t.setText(s); return this; }
  
  public MCsIntWatcher addValue(sInt f) {
    i = f;
    v = f.get();
    out.setBang(v);
    return this; }
  public void answer(Channel c, float f) { out.set(i.get()); out.update(); }
  public void tick() {
    int a = i.get();
    out.set(a);
    //
    if (v != a || !onchange) out.bang(); else out.unBang();
    v = a; }
}



class MCsBooWatcher extends MCConnexion {
  OutputB out;
  boolean v = false;
  sBoo boo;
  
  MCsBooWatcher(MacroCUSTOM m) { super(m);
    out =  macro.createOutputB("WatchB"); }
  
  public MCsBooWatcher setText(String s) { out.t.setText(s); return this; }
  
  public MCsBooWatcher addValue(sBoo b) {
    boo = b;
    v = boo.get();
    return this; }
  public void tick() {
    out.set(boo.get());
    v = boo.get(); }
}



class MCRun extends MCConnexion {
  InputB in;
  ArrayList<Runnable> runs = new ArrayList<Runnable>();
  
  MCRun(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("Run"); }
  
  public MCRun setText(String s) { in.t.setText(s); return this; }
  public MCRun addRunnable(Runnable r) { runs.add(r); return this; }
  
  public void tick() { if (in.getUpdate() && in.get()) for (Runnable r : runs) r.run(); }
}

//#############    RUNNABLE    #############
abstract class Runnable { public abstract void run(); }



class MCListen extends MCConnexion {
  OutputB out;
  boolean v = false;
  
  MCListen(MacroCUSTOM m) { super(m);
    out =  macro.createOutputB("listen"); }
    
  public MCListen setText(String s) { out.t.setText(s); return this; }
  
  public MCListen listenTo(Channel chan) {
    new Callable(chan) { public void answer(Channel channel, float value) { v = true; }};
    return this; }
  public void tick() {
    if (v) out.set(true); else out.set(false);
    v = false; }
}



class MCCall extends MCConnexion {
  InputB in;
  ArrayList<Channel> chans = new ArrayList<Channel>();
  
  MCCall(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("call"); }
  
  public MCCall setText(String s) { in.t.setText(s); return this; }
  public MCCall callTo(Channel chan) { chans.add(chan); return this; }
  public void tick() { if (in.getUpdate() && in.get()) for (Channel c : chans) callChannel(c); }
}





//#######################################################################
//##                           BASIC MACRO                             ##
//#######################################################################



class MacroKey extends Macro {
  OutputB out;
  boolean b;
  char c = 'a';
  Textfield txtf;
  MacroKey(MacroPlane l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("key a");
    g.setWidth(70);
    out = createOutputB("");
    txtf = cp5.addTextfield("textDel" + str(id))
       .setLabel("").setPosition(16,3).setSize(22,22)
       .setAutoClear(false).setGroup(g).setText("a") ;
    txtf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() { super.clear(); }
  public MacroKey setChar(char _c) { c = _c; g.setLabel("key " + c); return this; }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  public void custom_frame() {
    String s = txtf.getText();
    if (s.length() == 1) {
      setChar(s.charAt(0));
    }
    if (kb.getClick(c)) b = true; }
  public void update() {
    if (b) { out.set(true); b = false; }
    else out.set(false);
    super.update();
    updated = true; }
}


class MacroBang extends Macro {
  OutputB out;
  Button b;
  boolean v,flag = false;
  MacroBang(MacroPlane l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("bang");
    g.setWidth(70);
    out = createOutputB("");
    b = cp5.addButton("button" + get_free_id())
        .setSize(35, 22)
        .setPosition(11, 2)
        .setGroup(g)
        ;
    b.getCaptionLabel().setText("");
  }
  public void clear() { super.clear(); }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  public void custom_frame() {
    if (b.isPressed() && !flag) { flag = true; v = true; sim.next_tick = true; }
    if (!b.isPressed()) { flag = false; } }
  public void update() {
    if (v) { out.set(true); v = false; } 
    else out.set(false);
    super.update();
    updated = true; }
}


class MacroToggle extends Macro {
  OutputB out;
  Button b;
  boolean flag = false;
  MacroToggle(MacroPlane l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("toggle");
    g.setWidth(70);
    out = createOutputB("");
    b = cp5.addButton("button" + get_free_id())
        .setSize(35, 22)
        .setPosition(11, 2)
        .setGroup(g)
        .setSwitch(true)
        ;
    b.getCaptionLabel().setText("");
  }
  public void clear() { super.clear(); }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  public void custom_frame() {
    if (b.isPressed() && !flag) {
      flag = true; sim.next_tick = true; if (!out.get()) out.set(true); else out.set(false); }
    if (!b.isPressed()) { flag = false; } }
  public void update() {
    super.update();
    updated = true; }
}


class MacroPulse extends Macro {
  OutputB out;
  InputF in;
  int turn = 0;
  int freq = 100;
  int cnt = 0;
  
  MacroPulse(MacroPlane l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("pulse");
    g.setWidth(150);
    out = createOutputB("            O");
    in = createInputF("", freq);
    turn = freq;
    cnt = PApplet.parseInt(sim.tick.get());
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  
  public void update() {
    if (in.getUpdate()) {
      int m = PApplet.parseInt(in.get());
      if (m != freq) {
        turn = PApplet.parseInt(sim.tick.get()) + m;
        freq = m;
      }
    }
    if (sim.tick.get() < cnt) turn = freq;
    cnt = PApplet.parseInt(sim.tick.get());
    if (sim.tick.get() >= turn) {
      out.set(true);
      turn += freq;
    } else out.set(false);
    super.update();
    updated = true;
  }
  
  public void drawing(float x, float y) {}
}



class MacroVAL extends Macro {
  OutputF out;
  InputB in;
  InputF inV;
  float value;
  boolean flag = false;
  
  MacroVAL(MacroPlane ml, float v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    value = v_;
    g.setLabel("Value");
    g.setSize(180, 22);
    in =  createInputB(">");
    inV =  createInputF("  VAL",value);
    out = createOutputF("",v_);
    new Button(cp5, "button"+get_free_id())
      .setPosition(50, 3)
      .setSize(45, 22)
      .setGroup(g)
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { 
          flag = true;
        } } )
      .getCaptionLabel().setText(">").setFont(getFont(18))
      ;
  }
  public void clear() {
    //txtf.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroVAL");
  //  file.append(str(value));
  //}

  public void update() {
    super.update();
    if (in.getUpdate()) {// && inV.getUpdate()
      //value = float(txtf.getText());
      //if (inV.bang()) {value = inV.get(); }//txtf.setText(str(value));}
      value = inV.get();
      out.set(value);
      if (in.get() || flag) {out.bang();} else {out.unBang();}
      flag = false;
      updated = true;
    }
  }
}

class MacroDELAY extends Macro {
  OutputB out;
  InputB in;
  int count;
  int actualCount;
  boolean on = false;
  Textfield txtf;
  boolean temp = false;
  
  MacroDELAY(MacroPlane ml, int v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    count = v_;
    g.setLabel("Delay");
    g.setWidth(200);
    in =  createInputB(">");
    out = createOutputB("           >");
    txtf = cp5.addTextfield("textDel" + str(id))
       .setLabel("")
       .setPosition(65,2)
       .setSize(70,22)
       .setAutoClear(false)
       .setGroup(g)
       .setText(str(count))
       ;
    txtf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() {
    txtf.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroDELAY");
  //  file.append(str(count));
  //  file.append(str(actualCount));
  //  file.append(str(on));
  //}
  public void update() {
    super.update();
    count = PApplet.parseInt(txtf.getText());
    if (in.getUpdate()) {
      if (in.get()) {
        if (!on && !temp) {
          on = true;
          actualCount = count;
        }
      }
      temp = false;
      if (on) {
        actualCount -= 1;
        if (actualCount <= 0) {
          on = false;
          out.set(true);
          temp = true;
        } else {
          out.set(false);
        }
      } else {
        out.set(false);
      }
      updated = true;
    }
  }

}

class MacroCOMP extends Macro {
  OutputB out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  Button b1;
  
  MacroCOMP(MacroPlane ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("Comp>");
    in1 =  createInputF("   IN",0);
    in2 = createInputF("   IN",0);
    out = createOutputB("    OUT");
    v1 = 0; v2 = 0;
    
    r1 = cp5.addRadioButton("radioButton" + id)
         .setGroup(g)
         .setPosition(150,29)
         .setSize(20,20)
         .setItemsPerRow(3)
         .setSpacingColumn(20)
         .addItem("sup" + id,1)
         .addItem("inf" + id,2)
         ;
     r1.getItem("sup" + id).getCaptionLabel().setText(">");
     r1.getItem("inf" + id).getCaptionLabel().setText("<");
     b1 = cp5.addButton("macrocompButton" + id)
         .setGroup(g)
         .setPosition(230,29)
         .setSize(20,20)
         .setSwitch(true)
         ;
     b1.getCaptionLabel().setFont(createFont("Arial",16)).setText("        =");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("sup" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroCOMP");
  //}

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      
      v1 = in1.get();
      v2 = in2.get();
      
      if ( (r1.getItem("sup" + id).getState() && v1 > v2) || 
           (r1.getItem("inf" + id).getState() && v1 < v2) ||
           (b1.isOn() && v1 == v2) )
        {out.bang();}
      else {out.unBang();}

      //out.update();
      updated = true;
    }
  }
}

class MacroBOOL extends Macro {
  OutputB out;
  InputB in1,in2;
  
  RadioButton r1;
  
  MacroBOOL(MacroPlane ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("BOOL");
    in1 =  createInputB("   IN");
    in2 = createInputB("   IN");
    out = createOutputB("    OUT");
    
    r1 = cp5.addRadioButton("radioButton" + id)
         .setGroup(g)
         .setPosition(80,29)
         .setSize(15,15)
         .setItemsPerRow(4)
         .setSpacingColumn(40)
         .addItem("AND" + id,1)
         .addItem("OR" + id,2)
         .addItem("XOR" + id,3)
         .addItem("NOT" + id,4)
         ;
     r1.getItem("AND" + id).getCaptionLabel().setText("AND");
     r1.getItem("OR" + id).getCaptionLabel().setText("OR");
     r1.getItem("XOR" + id).getCaptionLabel().setText("XOR");
     r1.getItem("NOT" + id).getCaptionLabel().setText("NOT");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("AND" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroBOOL");
  //}

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      if (r1.getItem("AND" + id).getState())  
        if (in1.get() && in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("OR" + id).getState()) 
        if (in1.get() || in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("XOR" + id).getState()) 
        if (!(in1.get() == in2.get())) {out.bang();} else {out.unBang();}
      else if (r1.getItem("NOT" + id).getState()) 
        if (!in1.get()) {out.bang();} else {out.unBang();}

      //out.update();
      updated = true;
    }
  }
}

class MacroNOT extends Macro {
  OutputB out;
  InputB in;
  
  MacroNOT(MacroPlane ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("NOT").setSize(45, 22);
    in =  createInputB("");
    out = createOutputB("              !");
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroBOOL");
  //}

  public void update() {
    super.update();
    if (in.getUpdate()) {
      if (!in.get()) {out.bang();} else {out.unBang();}
      updated = true;
    }
  }
}

class MacroCALC extends Macro {
  OutputF out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  
  MacroCALC(MacroPlane ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("CALC");
    in1 =  createInputF("   IN", 0);
    in2 = createInputF("   IN", 0);
    out = createOutputF("    OUT", 0);
    v1 = 0; v2 = 0;
    
    r1 = cp5.addRadioButton("calcradioButton" + id)
         .setGroup(g)
         .setPosition(150,29)
         .setSize(15,15)
         .setItemsPerRow(4)
         .setSpacingColumn(20)
         .addItem("+" + id,1)
         .addItem("-" + id,2)
         .addItem("x" + id,3)
         .addItem("/" + id,4)
         ;
     r1.getItem("+" + id).getCaptionLabel().setText("+");
     r1.getItem("-" + id).getCaptionLabel().setText("-");
     r1.getItem("x" + id).getCaptionLabel().setText("x");
     r1.getItem("/" + id).getCaptionLabel().setText("/");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("+" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroCALC");
  //}

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      
      if (r1.getItem("+" + id).getState())  
        out.set(in1.get() + in2.get());
      else if (r1.getItem("-" + id).getState())  
        out.set(in1.get() - in2.get());
      else if (r1.getItem("x" + id).getState())  
        out.set(in1.get() * in2.get());
      else if (r1.getItem("/" + id).getState())  
        out.set(in1.get() / in2.get());
      
      //if (v1 != in1.get() || v2 != in2.get()) out.bang();
      //else out.unBang();
      if (in1.bang() || in2.bang()) out.bang();
      else out.unBang();
      v1 = in1.get(); v2 = in2.get(); 

      //out.update();
      updated = true;
    }
  }
}






















//#######################################################################
//##                           OLD MACRO                               ##
//#######################################################################


//class Keyboard extends Macro {
//  boolean w,c,a,p;
//  OutputB wO,cO,aO,pO;
  
//  Keyboard(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    w = false; c = false; a = false; p = false;
//    g.setLabel("Key");
//    g.setWidth(150);
//    aO = createOutputB("          A");
//    wO = createOutputB("          W");
//    pO = createOutputB("          P");
//    cO = createOutputB("          C");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("Keyboard");
//  //}
  
//  void update() {
//    w = false; c = false; a = false; p = false;
//    if (keysClick[4]) {w = true;}
//    if (keysClick[5]) {c = true;}
//    if (keysClick[7]) {a = true;}
//    if (keysClick[8]) {p = true;}
//    wO.set(w);
//    cO.set(c);
//    aO.set(a);
//    pO.set(p);
//    super.update();
//    updated = true;
//  }
  
//  void drawing(float x, float y) {}
//}

//class GrowingPop extends Macro {
//  InputB addI;
//  InputB add2I;
  
//  GrowingPop(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("ADD");
//    g.setWidth(200);
//    addI = createInputB("grower");
//    add2I = createInputB("floc");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingPop");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (addI.getUpdate() && add2I.getUpdate()) {
//      if (addI.get()) {
//        if (!gcom.adding_type.get()) 
//        for (int j = 0; j < gcom.initial_entity.get(); j++)
//          gcom.initialEntity();
//        if (gcom.adding_type.get()) gcom.adding_pile = gcom.initial_entity.get();
//      }
//      if (add2I.get()) {
//        if (!fcom.adding_type.get()) 
//        for (int j = 0; j < fcom.initial_entity.get(); j++)
//          fcom.initialEntity();
//        if (fcom.adding_type.get()) fcom.adding_pile = fcom.initial_entity.get();
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}

//class GrowingParam extends Macro {
//  InputF growI,sproutI,stopI,dieI,ageI;
//  float grow,sprout,stop,die,age;
  
//  GrowingParam(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    //growI = createInputF("GROW", GROW_DIFFICULTY);
//    //grow = GROW_DIFFICULTY;
//    //sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
//    //sprout = SPROUT_DIFFICULTY;
//    //stopI = createInputF("STOP", STOP_DIFFICULTY);
//    //stop = STOP_DIFFICULTY;
//    //dieI = createInputF("DIE", DIE_DIFFICULTY);
//    //die = DIE_DIFFICULTY;
//    //ageI = createInputF("AGE", OLD_AGE);
//    //age = OLD_AGE;
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingControl");
//  //  file.append(str(grow));
//  //  file.append(str(sprout));
//  //  file.append(str(stop));
//  //  file.append(str(die));
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    //float g = growI.get();
//    //float sp = sproutI.get();
//    //float st = stopI.get();
//    //float d = dieI.get();
//    //float a = ageI.get();
    
//    //if (g != grow) {
//    //  grow = g; GROW_DIFFICULTY = grow;
//    //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
//    //else if (g != GROW_DIFFICULTY) {
//    //  grow = GROW_DIFFICULTY; growI.set(grow); }
    
//    //if (sp != sprout) {
//    //  sprout = sp; SPROUT_DIFFICULTY = sprout;
//    //  update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
//    //else if (sp != SPROUT_DIFFICULTY) {
//    //  sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
//    //if (st != stop) {
//    //  stop = st; STOP_DIFFICULTY = stop;
//    //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
//    //else if (st != STOP_DIFFICULTY) {
//    //  stop = STOP_DIFFICULTY; stopI.set(stop); }
    
//    //if (d != die) {
//    //  die = d; DIE_DIFFICULTY = die;
//    //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
//    //else if (d != DIE_DIFFICULTY) {
//    //  die = DIE_DIFFICULTY; dieI.set(die); }
      
//    //if (a != age) {
//    //  age = a; OLD_AGE = (int)age;
//    //  update_textlabel("AGING", " at ", OLD_AGE);
//    //}
//    //else if (a != OLD_AGE) {
//    //  age = OLD_AGE; ageI.set(age); }
    
//    super.update();
//    updated = true;
//  }
//}

//class GrowingActive extends Macro {
//  InputB growI,sproutI,stopI,dieI,growoffI,sproutoffI,stopoffI,dieoffI;
  
//  GrowingActive(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    growI = createInputB("GROW ON");
//    sproutI = createInputB("SPROUT ON");
//    stopI = createInputB("STOP ON");
//    dieI = createInputB("DIE ON");
//    growoffI = createInputB("GROW OFF");
//    sproutoffI = createInputB("SPROUT OFF");
//    stopoffI = createInputB("STOP OFF");
//    dieoffI = createInputB("DIE OFF");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingActiv");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    //if (growI.getUpdate() && sproutI.getUpdate() && stopI.getUpdate() && dieI.getUpdate() && 
//    //    growoffI.getUpdate() && sproutoffI.getUpdate() && stopoffI.getUpdate() && dieoffI.getUpdate() ) {
//    //  if (growI.get()   && !ON_GROW)   bGrow.setOn();
//    //  if (sproutI.get() && !ON_SPROUT) bSprout.setOn();
//    //  if (stopI.get()   && !ON_STOP)   bStop.setOn();
//    //  if (dieI.get()    && !ON_DIE)    bDie.setOn();
//    //  if (growoffI.get()   && ON_GROW)   bGrow.setOff();
//    //  if (sproutoffI.get() && ON_SPROUT) bSprout.setOff();
//    //  if (stopoffI.get()   && ON_STOP)   bStop.setOff();
//    //  if (dieoffI.get()    && ON_DIE)    bDie.setOff();
//    //}
//    super.update();
//    updated = true;
//  }
//}

//class GrowingControl extends Macro {
//  InputB in;
  
//  RadioButton r1, r2, r3;
  
//  GrowingControl(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    in = createInputB("");
//    g.setSize(g.getWidth(), 28 + (inCount*28));
    
//    r1 = cp5.addRadioButton("radioButton1" + id)
//         .setGroup(g)
//         .setPosition(20,6)
//         .setSize(15,15)
//         .setItemsPerRow(1)
//         .setSpacingRow(8)
//         .addItem("x" + id,1)
//         .addItem("/" + id,2)
//         ;
         
//     r2 = cp5.addRadioButton("radioButton2" + id)
//         .setGroup(g)
//         .setPosition(55,6)
//         .setSize(15,15)
//         .setItemsPerRow(1)
//         .setSpacingRow(8)
//         .addItem("1.2" + id,1)
//         .addItem("2" + id,2)
//         ;
     
//     r3 = cp5.addRadioButton("radioButton3" + id)
//         .setGroup(g)
//         .setPosition(100,6)
//         .setSize(15,15)
//         .setItemsPerRow(2)
//         .setSpacingRow(8)
//         .setSpacingColumn(35)
//         .addItem("GROW" + id,1)
//         .addItem("BLOOM" + id,2)
//         .addItem("STOP" + id,3)
//         .addItem("DIE" + id,4)
//         ;
     
//     r1.getItem("x" + id).getCaptionLabel().setText("x");
//     r1.getItem("/" + id).getCaptionLabel().setText("/");
//     r2.getItem("1.2" + id).getCaptionLabel().setText("1.2");
//     r2.getItem("2" + id).getCaptionLabel().setText("2");
//     r3.getItem("GROW" + id).getCaptionLabel().setText("GROW");
//     r3.getItem("BLOOM" + id).getCaptionLabel().setText("BLOOM");
//     r3.getItem("STOP" + id).getCaptionLabel().setText("STOP");
//     r3.getItem("DIE" + id).getCaptionLabel().setText("DIE");
     
//     for(Toggle t:r1.getItems())
//       t.getCaptionLabel().setFont(createFont("Arial",16));
//     r1.getItem("x" + id).setState(true);
//     for(Toggle t:r2.getItems())
//       t.getCaptionLabel().setFont(createFont("Arial",16));
//     r2.getItem("2" + id).setState(true);
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingActiv");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (in.getUpdate()) {
//      float m = 0;
//      if (r2.getItem("1.2" + id).getState()) m = 1.2;
//      else if (r2.getItem("2" + id).getState()) m = 2;
//      if (r1.getItem("/" + id).getState()) m = 1 / m;
//      if (in.get()) {
//        //if (r3.getItem("GROW" + id).getState()) {
//        //  GROW_DIFFICULTY *= m;
//        //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
//        //if (r3.getItem("BLOOM" + id).getState()) {
//        //  SPROUT_DIFFICULTY *= m;
//        //  update_textlabel("SPROUT", " = r^", SPROUT_DIFFICULTY); }
//        //if (r3.getItem("STOP" + id).getState()) {
//        //  STOP_DIFFICULTY *= m;
//        //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
//        //if (r3.getItem("DIE" + id).getState()) {
//        //  DIE_DIFFICULTY *= m;
//        //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}

//class GrowingWatcher extends Macro {
//  OutputF popO,growO,turnO;
//  float pop,grow,turn;
  
//  GrowingWatcher(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("Watcher");
//    g.setWidth(150);
//    popO = createOutputF("      POP", 0);
//    growO = createOutputF("  GROW", 0);
//    turnO = createOutputF("  turn", 0);
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowWatcher");
//  //  file.append(str(pop));
//  //  file.append(str(grow));
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    int p = gcom.active_Entity_Nb();
//    int g = gcom.grower_Nb();
//    popO.set(p);
//    growO.set(g);
//    turnO.set(sim.tick.get());
//    if (pop != p) popO.bang();
//    if (grow != g) growO.bang();
//    if (turn != sim.tick.get()) turnO.bang();
//    pop = p; grow = g; turn = sim.tick.get();
//    super.update();
//    updated = true;
//  }
//}

//class SimControl extends Macro {
//  InputB inR,inRng,inP;
  
//  SimControl(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("SIMULATION");
//    g.setWidth(150);
//    inR = createInputB("RESET");
//    inRng = createInputB("RNG");
//    inP = createInputB("PAUSE");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("Sim Control");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (inR.getUpdate() && inRng.getUpdate() && inP.getUpdate()) {
//      if (inR.get()) sim.reset();
//      if (inRng.get()) {
//        sim.SEED.set(int(random(1000000000)));
//        sim.reset();
//      }
//      if (inP.get()) {
//        sim.pause.set(!sim.pause.get());
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}




class MacroPlane extends Callable {
  ArrayList<Macro> macroList = new ArrayList<Macro>(0);
  ArrayList<InputB> inBList = new ArrayList<InputB>(0);
  ArrayList<OutputB> outBList = new ArrayList<OutputB>(0);
  ArrayList<InputF> inFList = new ArrayList<InputF>(0);
  ArrayList<OutputF> outFList = new ArrayList<OutputF>(0);
  
  LinkList linkList;
  
  Group g;
  LinkB NOTB = null;
  LinkF NOTF = null;
  InputB NOTBI = null;
  InputF NOTFI = null;
  OutputB NOTBO = null;
  OutputF NOTFO = null;
  
  boolean creatingLinkB = false;
  OutputB selectOutB;
  boolean creatingLinkF = false;
  OutputF selectOutF;
  
  int adding_pos = 40;
  
  sPanel build_panel;
  
  MacroPlane() {
    linkList = new LinkList(this);
    NOTB = linkList.createLinkB();
    NOTF = linkList.createLinkF();
    g = cp5.addGroup("Main")
                  .setVisible(false)
                  .setPosition(-200,-200)
                  .moveTo("Macros")
                  ;
    NOTBO = createOutputB(g, -1,"",0);
    NOTFO = createOutputF(g,-1,"",1,0);
    NOTBI = createInputB(g,-1,"",0);
    NOTFI = createInputF(g,-1,"",1,0);
    
    addChannel(sim.tick_chan);
    
    build_panel = new sPanel(cp5, 100, 200)
      .setTab("Macros")
      .addTitle("- NEW  MACRO -", 85, 0, 28)
      .addSeparator(12)
      .addText("Basic Macro :", 0, 0, 18)
      .addSeparator(8)
      .addDrawer(150)
        .addButton("VAL", 30, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroVAL(adding_pos, adding_pos, 0);
            } } )
          .getDrawer()
        .addButton("PULSE", 140, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroPulse(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("DELAY", 250, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroDELAY(adding_pos, adding_pos, 0);
            } } )
          .getDrawer()
        .addButton("COMP", 30, 40)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroCOMP(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("BOOL", 140, 40)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroBOOL(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("CALC", 250, 40)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroCALC(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("BANG", 30, 80)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroBang(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("KEY", 140, 80)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroKey(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("TOGGLE", 250, 80)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroToggle(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .addButton("NOT", 140, 120)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              addMacroNOT(adding_pos, adding_pos);
            } } )
          .getDrawer()
        .getPanel()
      .addLine(12)
      .addSeparator(5)
      ;
  }
  
  public void clear() {
    g.remove();
    for (Macro m : macroList) m.clear();
    for (InputB i : inBList) i.clear();
    for (InputF i : inFList) i.clear();
    for (OutputB o : outBList) o.clear();
    for (OutputF o : outFList) o.clear();
    macroList.clear();
    inBList.clear();
    outBList.clear();
    inFList.clear();
    outFList.clear();
    linkList.clear();
  }
  
  //void to_strings() {
  //  file.append("macros:");
  //  for (Macro m : macroList)
  //    m.to_strings();
  //  file.append("in/out:");
  //  for (InputB m : inBList)
  //    m.to_strings();
  //  for (InputF m : inFList)
  //    m.to_strings();
  //  for (OutputB m : outBList)
  //    m.to_strings();
  //  for (OutputF m : outFList)
  //    m.to_strings();
  //  file.append("links:");
  //  linkList.to_strings();
  //}
  
  public void drawing() {
    if (creatingLinkB) {
      stroke(255);
      fill(255);
      strokeWeight(3);
      line(mouseX,mouseY,selectOutB.x,selectOutB.y);
      ellipseMode(RADIUS);
      noStroke();
      ellipse(mouseX,mouseY,6,6);
      ellipse(selectOutB.x,selectOutB.y,6,6);
    } else if (creatingLinkF) {
      stroke(255);
      fill(255);
      strokeWeight(3);
      line(mouseX,mouseY,selectOutF.x,selectOutF.y);
      ellipseMode(RADIUS);
      noStroke();
      ellipse(mouseX,mouseY,6,6);
      ellipse(selectOutF.x,selectOutF.y,6,6);
    }
    for (LinkB l : linkList.linkBList) {
      l.drawing();
    }
    for (LinkF l : linkList.linkFList) {
      l.drawing();
    }
  }
  
  public void answer(Channel channel, float value) { //tick chan
    update();
  }
  
  public void update() {
    int counter = 0;
    while (counter < macroList.size()) {
      for (Macro m : macroList) {
        if (!m.updated) {
          m.update();
          if (m.updated) {counter += 1;}
        }
      }
    }
    for (Macro m : macroList) {
      m.updated = false;
    }
  }
  
  public void frame() {
    for (Macro m : macroList) m.frame();
    if (kb.mouseClick[1]) {
      creatingLinkB = false;
      creatingLinkF = false;
      for (int i = linkList.linkBList.size() - 1; i >= 0; i--) {
        LinkB l = linkList.linkBList.get(i);
        if (l.collision(mouseX, mouseY)) {
          l.in.l.remove(l);
          l.out.l.remove(l);
          linkList.linkBList.remove(l);
        }
      }
      for (int i = linkList.linkFList.size() - 1; i >= 0; i--) {
        LinkF l = linkList.linkFList.get(i);
        if (l.collision(mouseX, mouseY)) {
          l.in.l.remove(l);
          l.out.l.remove(l);
          linkList.linkFList.remove(l);
        }
      }
    }
  }
  
  public void addLinkSelectOutB(OutputB out) {
    creatingLinkB = true;
    selectOutB = out;
  }
  
  public void addLinkSelectInB(InputB in) {
    creatingLinkB = false;
    selectOutB.linkTo(in);
  }
  
  public void addLinkSelectOutF(OutputF out) {
    creatingLinkF = true;
    selectOutF = out;
  }
  
  public void addLinkSelectInF(InputF in) {
    creatingLinkF = false;
    selectOutF.linkTo(in);
  }
  
  public MacroPulse addMacroPulse(int _x, int _y) {
    int id = macroList.size();
    return new MacroPulse(this, id, _x, _y);
  }
  
  public MacroKey addMacroKey(int _x, int _y) {
    int id = macroList.size();
    return new MacroKey(this, id, _x, _y);
  }
  
  public MacroBang addMacroBang(int _x, int _y) {
    int id = macroList.size();
    return new MacroBang(this, id, _x, _y);
  }
  
  public MacroToggle addMacroToggle(int _x, int _y) {
    int id = macroList.size();
    return new MacroToggle(this, id, _x, _y);
  }
  
  public MacroVAL addMacroVAL(int _x, int _y, float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, _x, _y);
  }
  
  public MacroNOT addMacroNOT(int _x, int _y) {
    int id = macroList.size();
    return new MacroNOT(this, id, _x, _y);
  }
  
  public MacroCOMP addMacroCOMP(int _x, int _y) {
    int id = macroList.size();
    return new MacroCOMP(this, id, _x, _y);
  }
  
  public MacroBOOL addMacroBOOL(int _x, int _y) {
    int id = macroList.size();
    return new MacroBOOL(this, id, _x, _y);
  }
  
  public MacroCALC addMacroCALC(int _x, int _y) {
    int id = macroList.size();
    return new MacroCALC(this, id, _x, _y);
  }
  
  public MacroDELAY addMacroDELAY(int _x, int _y, int v) {
    int id = macroList.size();
    return new MacroDELAY(this, v, id, _x, _y);
  }
  
  public Macro addMacro(Macro m) {
    macroList.add(m);
    return m;
  }
  
  public InputB createInputB(Group g, int i, String text, int n) {
    int id = inBList.size();
    InputB o = new InputB(this, id, g, i, text, n);
    inBList.add(o);
    return o;
  }

  public InputF createInputF(Group g, int i, String text, int n, float d) {
    int id = inFList.size();
    InputF o = new InputF(this, id, g, i, text, n, d);
    inFList.add(o);
    return o;
  }
  
  public OutputB createOutputB(Group g, int i, String text, int n) {
    int id = outBList.size();
    OutputB o = new OutputB(this, id, g, i, text, n);
    outBList.add(o);
    return o;
  }
  
  public OutputF createOutputF(Group g, int i, String text, int n, float d_) {
    int id = outFList.size();
    OutputF o = new OutputF(this, id, g, i, text, n, d_);
    outFList.add(o);
    return o;
  }
  
}

abstract class Macro {
  MacroPlane macroList;
  boolean updated = false;
  Group g;
  int id; int x,y; float mx = 0; float my = 0;
  int inCount = 0;
  int outCount = 0;
  ArrayList<OutputB> loutB = new ArrayList<OutputB>(0);
  ArrayList<OutputF> loutF = new ArrayList<OutputF>(0);
  ArrayList<InputB> linB = new ArrayList<InputB>(0);
  ArrayList<InputF> linF = new ArrayList<InputF>(0);
  
  Macro(MacroPlane ml, int i_, int x_, int y_) {
    ml.addMacro(this);
    macroList = ml;
    ml.adding_pos += 30;
    if (ml.adding_pos >= 200) ml.adding_pos -= 162;
    id = i_;
    x = x_; y = y_;
    g = cp5.addGroup("Macro" + str(id))
                  .activateEvent(true)
                  .setPosition(x,y)
                  .setSize(320,22)
                  .setBackgroundColor(color(60, 200))
                  .disableCollapse()
                  .moveTo("Macros")
                  .setBarHeight(20)//<
                  ;
    g.getCaptionLabel().setFont(createFont("Arial",16));
    new Button(cp5, "button"+get_free_id())
      .setPosition(-20, -20)
      .setSize(20, 20)
      .setGroup(g)
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { 
          clear(); } } )
      .getCaptionLabel().setText("X")
      ;
  }
  public void clear() {
    for (OutputB o : loutB) { o.clear(); macroList.outBList.remove(o); }
    for (OutputF o : loutF) { o.clear(); macroList.outFList.remove(o); }
    for (InputB o : linB) { o.clear(); macroList.inBList.remove(o); }
    for (InputF o : linF) { o.clear(); macroList.inFList.remove(o); }
    g.remove();
  }
  
  //void to_strings() {
  //  file.append("macro");
  //  file.append(str(id));
  //  file.append(str(x));
  //  file.append(str(y));
  //  file.append(str(inCount));
  //  file.append(str(outCount));
  //}
  
  public void update() {} //tick
  public void custom_frame() {}
  
  public void frame() {
    custom_frame();
    if (cp5.getTab("Macros").isActive()) {
      if (g.isMouseOver() && kb.mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        cam.GRAB = false; //deactive le deplacement camera
      }
      if (g.isMouseOver() && kb.mouseUClick[0]) {
        cam.GRAB = true;
      }
      if (g.isMouseOver() && kb.mouseButtons[0]) {
        x = PApplet.parseInt(mouseX + mx); y = PApplet.parseInt(mouseY + my);
        g.setPosition(mouseX + mx,mouseY + my);
      }
    }
  }
  
  public InputB createInputB(String text) {
    InputB in = macroList.createInputB(g, id, text, inCount);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    linB.add(in);
    return in;
  }

  public InputF createInputF(String text, float d) {
    InputF in = macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    linF.add(in);
    inCount +=1;
    return in;
  }
  
  public OutputB createOutputB(String text) {
    OutputB out = macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    loutB.add(out);
    outCount +=1;
    return out;
  }

  public OutputF createOutputF(String text, float d) {
    OutputF out = macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    loutF.add(out);
    outCount +=1;
    return out;
  }
}

//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


public String trimStringFloat(float f) {
  String s;
  if (f%1.0f == 0.0f) s = nfc(PApplet.parseInt(f)); else s = str(f);
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
  for (myFont f : existingFont) if (f.st == st) return f.f;
  myFont f = new myFont();
  f.f = createFont("Arial",st); f.st = st;
  return f.f; }
//for (String s : PFont.list()) println(s); // liste toute les police de text qui existe




//#######################################################################
//##                        CALLABLE CLASS V2                          ##
//#######################################################################


public void callChannel(Channel chan, float val) {
  for (Callable c : chan.calls) c.answer(chan, val); }
public void callChannel(Channel chan) { callChannel(chan, 0); }
class Channel { ArrayList<Callable> calls = new ArrayList<Callable>(); }
abstract class Callable {
  Callable() {}   Callable(Channel c) {addChannel(c);}
  public void addChannel(Channel c) { c.calls.add(this); }
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
  public void unFlagChange() {
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
  public int get() { return val; }
  public void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  String name = "flt";
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  sFlt(SpecialValue s, float v, String n) { name = n; save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  public float get() { return val; }
  public void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  String name = "boo";
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  sBoo(SpecialValue s, boolean v, String n) { name = n; save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  public boolean get() { return val; }
  public void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}

class sVec {
  boolean has_changed = false;
  SpecialValue save;
  PVector val = new PVector();
  int id = 0;
  String name = "vec";
  sVec(SpecialValue s, PVector v) { save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  sVec(SpecialValue s, PVector v, String n) { name = n; save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  public PVector get() { return new PVector(val.x, val.y); }
  public void set(PVector v) { if (v.x != val.x || v.y != val.y) { has_changed = true; val.x = v.x; val.y = v.y; } }
}

class sStr {
  boolean has_changed = false;
  SpecialValue save;
  String val = new String();
  int id = 0;
  String name = "str";
  sStr(SpecialValue s, String v) { save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  sStr(SpecialValue s, String v, String n) { name = n; save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  public String get() { return new String(val); }
  public void set(String v) { if (!v.equals(val)) { has_changed = true; val = v; } }
}



//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


int SV_start_bloc = 3;

public void saving(SpecialValue sv, String file) {
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
public void loading(SpecialValue s, String file) {
  
  String[] sl = loadStrings(file);
  
  int intlsize = PApplet.parseInt(sl[0]);
  int fltlsize = PApplet.parseInt(sl[1]);
  int boolsize = PApplet.parseInt(sl[2]);
  
  if (intlsize != s.sintlist.size()) return;
  if (fltlsize != s.sfltlist.size()) return;
  if (boolsize != s.sboolist.size()) return;
  if (sl.length < SV_start_bloc + intlsize + fltlsize + boolsize) return;
  
  for (sInt i : s.sintlist) {
    i.set(PApplet.parseInt(sl[SV_start_bloc + i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(PApplet.parseFloat(sl[SV_start_bloc + s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(PApplet.parseBoolean(sl[SV_start_bloc + s.sintlist.size() + s.sfltlist.size() + i.id]));
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
  
  public void init() {
    //initialisation des array des graph
    for (int i = 0; i < larg; i++) { 
      graph[i] = 0; 
      graph2[i] = 0;
    }
    max = 10;
    //addChannel(c);
  }
  
  public void draw() {
    if (SHOW_GRAPH.get() && !cp5.getTab("default").isActive()) {
      strokeWeight(0.5f);
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
  
  public void update(int val1, int val2) {
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





  
  public void settings() {  fullScreen();  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "grows_2_3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
