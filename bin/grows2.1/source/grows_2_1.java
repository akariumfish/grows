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

public class grows_2_1 extends PApplet {

/*

           
*/

ControlP5 cp5; //l'objet main pour les menu
SpecialValue simval = new SpecialValue();
Camera cam = new Camera();
ComunityList comlist;

Channel frame_chan = new Channel();
Channel tick_chan = new Channel();

sGraph graph = new sGraph();

sFlt tick = new sFlt(simval, 0); //conteur de tour depuis le dernier reset ou le debut
sBoo pause = new sBoo(simval, false); //permet d'interompre le defilement des tour
sFlt tick_by_frame = new sFlt(simval, 16); //nombre de tour a executé par frame
float tick_pile = 0; //pile des tour
sInt SEED = new sInt(simval, 548651008); //seed pour l'aleatoire
sInt framerate = new sInt(simval, 0);
sBoo auto_reset = new sBoo(simval, true);
sBoo auto_reset_rng_seed = new sBoo(simval, true);
sInt auto_reset_turn = new sInt(simval, 4000);
sBoo auto_screenshot = new sBoo(simval, false);

GrowerComu gcom;
FlocComu fcom;
BoxComu bcom;

public void setup() {//executé au demarage
  //size(1600, 900);//taille de l'ecran
  
  setupInput();//voir input plus bas
  //pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  init_panel("Menu");
  
  init_canvas();
  
  comlist = new ComunityList();
  
  gcom = new GrowerComu(comlist);
  fcom = new FlocComu(comlist);
  bcom = new BoxComu(comlist);
  
  
  
  graph.init();
  
  loading(simval, "save.txt");
  
  reset();
}

public void draw() {//executé once by frame
  background(0);//fond noir
  
  //drive l'execution
  if (!pause.get()) {
    tick_pile += tick_by_frame.get();
    
    //auto screenshot before reset
    if (auto_reset.get() && auto_reset_turn.get() == tick.get() + tick_by_frame.get() + tick_by_frame.get() && auto_screenshot.get()) {
        cam.screenshot = true; }
    
    while (tick_pile >= 1) {
      //tick call
      callChannel(tick_chan);
      
      //tick communitys
      comlist.tick();
      
      tick.set(tick.get()+1);
      tick_pile--;
      
      //auto reset
      if (auto_reset.get() && auto_reset_turn.get() <= tick.get()) {
        if (auto_reset_rng_seed.get()) {
          SEED.set(PApplet.parseInt(random(1000000000)));
        }
        reset();
      }
    }
    
    //run_each_unpaused_frame
    
    //get value pour le graph
    graph.update(gcom.active_Entity_Nb(), gcom.grower_Nb());
    
    //add halo for each entity of floc community
    can.drawHalo(fcom);
  }
  
  //update des macros
  mList.update();
  
  //run_each_frame
  callChannel(frame_chan);
  
  // affichage
  // apply camera view
  cam.pushCam();
  
  //canvas
  can.drawCanvas();
  
  //community
  comlist.draw();
  
  //pop cam view and cam updates
  cam.popCam();
  
  graph.draw();
  
  mList.drawing();
  
  //framerate:
  fill(255); textSize(16);
  text(PApplet.parseInt(frameRate),10,height - 10 );
  
  //info
  if (!cp5.getTab("default").isActive()) {
    textSize(24);
    text("Click somewhere then hit ESC to quit",700,height - 30 );
  }
  simval.unFlagChange();
  
  framerate.set(PApplet.parseInt(frameRate));
  
  inputUpdate(); //voir l'onglet input
}

public void reset() {
  comlist.comunity_reset();
  tick.set(0);
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
    if (mouseButtons[0] && GRAB) { 
      cam_pos.add(mouseX - pmouseX, mouseY - pmouseY); 
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
    
    //permet le zoom
    if (mouseWheelUp) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); cam_pos.mult(1/ZOOM_FACTOR); callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
    if (mouseWheelDown) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); cam_pos.mult(ZOOM_FACTOR); callChannel(zoom_chan);
      pos_x.set(cam_pos.x);
      pos_y.set(cam_pos.y);
    }
  }
}



//#######################################################################
//##                             INPUT                                 ##
//#######################################################################

//ici c'est super mal foutu
//mais sa gere les boutton du clavier et de la sourie

boolean[] keysButtons;
boolean[] keysClick;
boolean[] keysJClick;
boolean[] keysUClick;
boolean[] keysJUClick;
boolean[] mouseButtons;
boolean[] mouseClick;
boolean[] mouseJClick;
boolean[] mouseUClick;
boolean[] mouseJUClick;
boolean mouseMove = false;
boolean mouseWheelUp = false;
boolean mouseWheelDown = false;
PVector mouseCoord = new PVector(0,0);
PVector mouseGridCoord = new PVector(0,0);

int keyNb = 10;

public void inputUpdate() {
  mouseCoord.x = mouseX; mouseCoord.y = mouseY;
  mouseWheelUp = false; mouseWheelDown = false;
  if (mouseX == pmouseX && mouseY == pmouseY) {mouseMove = false;}
  for (int i = mouseClick.length-1; i >= 0; i--) {if (mouseClick[i] == true && mouseJClick[i] == false) {mouseJClick[i] = true;}}
  for (int i = mouseJClick.length-1; i >= 0; i--) {if (mouseClick[i] == true && mouseJClick[i] == true) {mouseClick[i] = false; mouseJClick[i] = false;}}
  for (int i = mouseUClick.length-1; i >= 0; i--) {if (mouseUClick[i] == true && mouseJUClick[i] == false) {mouseJUClick[i] = true;}}
  for (int i = mouseJUClick.length-1; i >= 0; i--) {if (mouseUClick[i] == true && mouseJUClick[i] == true) {mouseUClick[i] = false; mouseJUClick[i] = false;}}
  for (int i = keysClick.length-1; i >= 0; i--) {if (keysClick[i] == true) {keysJClick[i] = true;}}
  for (int i = keysJClick.length-1; i >= 0; i--) {if (keysClick[i] == true && keysJClick[i] == true) {keysClick[i] = false; keysJClick[i] = false;}}
  for (int i = keysUClick.length-1; i >= 0; i--) {if (keysUClick[i] == true) {keysJUClick[i] = true;}}
  for (int i = keysJUClick.length-1; i >= 0; i--) {if (keysUClick[i] == true && keysJUClick[i] == true) {keysUClick[i] = false; keysJUClick[i] = false;}}
}

public void setupInput() {
  keysButtons = new boolean[keyNb];
  for (int i = keysButtons.length-1; i >= 0; i--) {keysButtons[i] = false;}
  keysClick = new boolean[keyNb];
  for (int i = keysClick.length-1; i >= 0; i--) {keysClick[i] = false;}
  keysJClick = new boolean[keyNb];
  for (int i = keysJClick.length-1; i >= 0; i--) {keysJClick[i] = false;}
  keysUClick = new boolean[keyNb];
  for (int i = keysUClick.length-1; i >= 0; i--) {keysUClick[i] = false;}
  keysJUClick = new boolean[keyNb];
  for (int i = keysJUClick.length-1; i >= 0; i--) {keysJUClick[i] = false;}
  mouseButtons = new boolean[3];
  for (int i = mouseButtons.length-1; i >= 0; i--) {mouseButtons[i] = false;}
  mouseClick = new boolean[3];
  for (int i = mouseClick.length-1; i >= 0; i--) {mouseClick[i] = false;}
  mouseJClick = new boolean[3];
  for (int i = mouseJClick.length-1; i >= 0; i--) {mouseJClick[i] = false;}
  mouseUClick = new boolean[3];
  for (int i = mouseUClick.length-1; i >= 0; i--) {mouseUClick[i] = false;}
  mouseJUClick = new boolean[3];
  for (int i = mouseJUClick.length-1; i >= 0; i--) {mouseJUClick[i] = false;}
}

public void mouseWheel(MouseEvent event) {
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

public void keyPressed()
{
  if(key==CODED) {
  if(keyCode==UP) {
    keysButtons[0]=true;
    keysClick[0]=true; }
  if(keyCode==DOWN) {
    keysButtons[1]=true;
    keysClick[1]=true; }
  if(keyCode==LEFT) {
    keysButtons[2]=true;
    keysClick[2]=true; }
  if(keyCode==RIGHT) {
    keysButtons[3]=true;
    keysClick[3]=true; } }
  if(key=='w') {
    keysButtons[4]=true;
    keysClick[4]=true; }
  if(key=='c') {
    keysButtons[5]=true;
    keysClick[5]=true; }
  if(key==' ') {
    keysButtons[6]=true;
    keysClick[6]=true; }
  if(key=='a') {
    keysButtons[7]=true;
    keysClick[7]=true; }
  if(key=='p') {
    keysButtons[8]=true;
    keysClick[8]=true; }
  if(key=='h') {
    keysButtons[9]=true;
    keysClick[9]=true; }
}

public void keyReleased()
{
  if(key==CODED) {
  if(keyCode==UP) {
    keysButtons[0]=false;
    keysUClick[0]=true; }
  if(keyCode==DOWN) {
    keysButtons[1]=false;
    keysUClick[1]=true; }
  if(keyCode==LEFT) {
    keysButtons[2]=false;
    keysUClick[2]=true; }
  if(keyCode==RIGHT) {
    keysButtons[3]=false;
    keysUClick[3]=true; } }
  if(key=='w') {
    keysButtons[4]=false;
    keysUClick[4]=true; }
  if(key=='c') {
    keysButtons[5]=false;
    keysUClick[5]=true; }
  if(key==' ') {
    keysButtons[6]=false;
    keysUClick[6]=true; }
  if(key=='a') {
    keysButtons[7]=false;
    keysUClick[7]=true; }
  if(key=='p') {
    keysButtons[8]=false;
    keysUClick[8]=true; }
  if(key=='h') {
    keysButtons[9]=false;
    keysUClick[9]=true; }
}

public void mousePressed()
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

public void mouseReleased()
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

public void mouseDragged() { mouseMove = true; }

public void mouseMoved() { mouseMove = true; }
class BoxComu extends Community {
  
  BoxComu(ComunityList _c) { super(_c, "Box", 1000); init();
    
    
  }
  public void custom_tick() {
          
  }
  
  public Box build() { return new Box(this); }
  public Box initialEntity() { return newEntity(); }
  public Box newEntity() {
    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
}

class Box extends Entity {
  PVector pos1 = new PVector(0, 0);
  PVector pos2 = new PVector(0, 0);
  boolean top = false, right = false, left = false, down = false;
  
  Box(BoxComu c) { super(c); }
  
  public Box init() {
    pos1 = new PVector(-10, -10);
    pos2 = new PVector(10, 10);
    top = false; right = false; left = false; down = false;
    return this;
  }
  public Box tick() {
    if (true) {
      if (!top && random(1.0f) > 0.99f) {
        Box nb = com().newEntity();
        if (nb != null) {
          top = true;
          nb.pos2.y = pos1.y;
          nb.pos1.y = pos1.y - (pos2.y - pos1.y);
          nb.pos1.x = pos1.x;
          nb.pos2.x = pos2.x;
        }
      }
      if (!down && random(1.0f) > 0.99f) {
        Box nb = com().newEntity();
        if (nb != null) {
          down = true;
          nb.pos1.y = pos2.y;
          nb.pos2.y = pos2.y + (pos2.y - pos1.y);
          nb.pos1.x = pos1.x;
          nb.pos2.x = pos2.x;
        }
      }
      if (!right && random(1.0f) > 0.99f) {
        Box nb = com().newEntity();
        if (nb != null) {
          right = true;
          nb.pos1.x = pos2.x;
          nb.pos2.x = pos2.x + (pos2.x - pos1.x);
          nb.pos1.y = pos1.y;
          nb.pos2.y = pos2.y;
        }
      }
      if (!left && random(1.0f) > 0.99f) {
        Box nb = com().newEntity();
        if (nb != null) {
          left = true;
          nb.pos2.x = pos1.x;
          nb.pos1.x = pos1.x - (pos2.x - pos1.x);
          nb.pos1.y = pos1.y;
          nb.pos2.y = pos2.y;
        }
      }
    }
    return this;
  }
  public Box drawing() {
    //fill(255);
    noFill();
    stroke(255);
    strokeWeight(2/cam.cam_scale.get());
    line(pos1.x, pos1.y, pos1.x, pos2.y);
    line(pos2.x, pos1.y, pos2.x, pos2.y);
    line(pos1.x, pos1.y, pos2.x, pos1.y);
    line(pos1.x, pos2.y, pos2.x, pos2.y);
    return this;
  }
  public Box clear() { return this; }
  public BoxComu com() { return ((BoxComu)com); }
}
class FlocComu extends Community {
  
  sFlt POURSUITE = new sFlt(simval, 0.6f);
  sFlt FOLLOW = new sFlt(simval, 0.0036f);
  sFlt SPACING = new sFlt(simval, 150);
  sFlt SPEED = new sFlt(simval, 2);
  sInt LIMIT = new sInt(simval, 400);
  
  sBoo DRAWMODE_DEF = new sBoo(simval, true);
  sBoo DRAWMODE_DEBUG = new sBoo(simval, false);
  
  sFlt HALO_SIZE = new sFlt(simval, 20);
  sFlt HALO_DENS = new sFlt(simval, 0.2f);
  
  sBoo create_grower = new sBoo(simval, true);
  sBoo point_to_mouse = new sBoo(simval, false);
  sBoo point_to_center = new sBoo(simval, false);
  
  int startbox = 400;
  
  FlocComu(ComunityList _c) { super(_c, "Floc", 100); init();
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
    
  }
  public void custom_tick() {
    for (Entity e1 : list)
      for (Entity e2 : list)
        if (e1.id < e2.id && e1 != e2 && e1.active && e2.active)
            ((Floc)e1).pair(((Floc)e2));
          
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
    if (age > 2000) {
      if (com().create_grower.get()) {
        Grower ng = gcom.newEntity();
        if (ng != null) ng.define(new PVector(pos.x, pos.y), new PVector(1, 0).rotate(random(2*PI)));
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
class RandomTryParam {
  //constructeur avec param values
  sFlt DIFFICULTY = new sFlt(simval, 4);
  sBoo ON = new sBoo(simval, true);
  RandomTryParam(float d, boolean b) {
    DIFFICULTY.set(d); ON.set(b);
  }
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
  
  GrowerComu(ComunityList _c) { super(_c, "Grower", 500); init();
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
    macro_build_panel
      .addDrawer(30)
        .addButton("GROWER SHAPE", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerINShape(); } } )
          .getDrawer()
        .addButton("GROWER MOUV", 200, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerINMove(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addButton(" GROWER OUT", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroGrowerOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
  }
  
  public void newMacroGrowerINShape() {
    new MacroCUSTOM(mList)
      .setLabel("GROWER IN")
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
    MacroCUSTOM m = new MacroCUSTOM(mList)
      .setLabel("GROWER IN")
      .setWidth(150)
      ;
    addRngTry(m, growP, "grow");
    addRngTry(m, sproutP, "sprout");
    addRngTry(m, leafP, "leaf");
    addRngTry(m, stopP, "stop");
    addRngTry(m, dieP, "die");
  }
  
  public void addRngTry(MacroCUSTOM m, RandomTryParam r, String s) {
    m.addMCsFltControl()
        .setValue(r.DIFFICULTY)
        .setText(s)
        .getMacro()
      .addMCsBooControl()
        .setValue(r.ON)
        .setText("")
        .getMacro()
      ;
  }
  
  public void newMacroGrowerOUT() {
    new MacroCUSTOM(mList)
      .setLabel("GROWER OUT")
      .setWidth(150)
      .addMCsIntWatcher()
        .addValue(activeEntity)
        .setText("  active")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(activeGrower)
        .setText("  grover")
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
  public void custom_tick() {
    activeGrower.set(grower_Nb());
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
    if (com().growP.ON.get() && start == 1 && !end && sprouts == 0 && crandom(com().growP.DIFFICULTY.get()) > 0.5f) {
      Grower n = com().newEntity();
      if (n != null) {
        n.define(grows, dir);
        sprouts++;
      }
    }
    
    // sprout
    if (com().sproutP.ON.get() && start == 1 && !end && crandom(com().sproutP.DIFFICULTY.get()) > 0.5f) {
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
    if (com().leafP.ON.get() && start == 1 && !end && crandom(com().leafP.DIFFICULTY.get()) > 0.5f) {
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
    if (com().stopP.ON.get() && start == 1 && !end && sprouts == 0 && crandom(com().stopP.DIFFICULTY.get()) > 0.5f) {
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


class ComunityList {
  ArrayList<Community> list = new ArrayList<Community>();
  sPanel panel;
  sTextfield file_path_tf;
  
  ComunityList() {
    //menu principale de la sim
    panel = new sPanel(cp5, 1190, 500)
      .addText("SIMULATION CONTROL", 28, 0, 28)
      .addLine(10)
      .addDrawer(30)
        .addText("SEED: ", 50, 4)
          .getDrawer()
        .addTextfield(130, 5)
          .setValue(SEED)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addDrawer(30)
        .addText("framerate: ", 30, 0)
          .setValue(framerate)
          .getDrawer()
        .addText("turn: ", 200, 0)
          .setValue(tick)
          .getDrawer()
        .getPanel()
      .addValueController("SPEED: ", sMode.FACTOR, 2, 1.2f, tick_by_frame)
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("P", 20, 0)
          .setValue(pause)
          .setSize(40, 30)
          .getDrawer()
        .addButton("R", 80, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { reset(); } } )
          .getDrawer()
        .addButton("RNG", 200, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { SEED.set(PApplet.parseInt(random(1000000000))); reset(); } } )
          .getDrawer()
        .addButton("I", 320, 0)
          .setSize(20, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { cam.screenshot = true; } } )
          .getDrawer()
        .addSwitch("A", 340, 0)
          .setValue(auto_screenshot)
          .setSize(20, 30)
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
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addButton("S", 0, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { saving(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .addButton("L", 320, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { loading(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .getPanel()
      ;
    file_path_tf = panel.lastDrawer().addTextfield(70, 0)
      .setText("save.txt")
      .setSize(240, 30)
      ;
    panel.addSeparator(10);
    
    //macro custom et menu d'ajout
    macro_build_panel
      .addText("SIMULATION :", 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("SIM IN", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimIN(); } } )
          .getDrawer()
        .addButton("SIM OUT", 200, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
  }
  
  public void newMacroSimIN() {
    new MacroCUSTOM(mList)
      .setLabel("SIM IN")
      .setWidth(170)
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { reset(); }})
        .setText("reset")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { SEED.set(PApplet.parseInt(random(1000000000))); reset(); }})
        .setText("rng")
        .getMacro()
      .addMCsBooControl()
        .setValue(pause)
        .setText("pause")
        .getMacro()
      .addMCsFltControl()
        .setValue(tick_by_frame)
        .setText("speed")
        .getMacro()
      ;
  }
  
  public void newMacroSimOUT() {
    new MacroCUSTOM(mList)
      .setLabel("SIM OUT")
      .setWidth(150)
      .addMCsBooWatcher()
        .addValue(pause)
        .setText("pause")
        .getMacro()
      .align()
      .addMCsFltWatcher()
        .addValue(tick)
        .setText("   tick")
        .getMacro()
      .addMCsFltWatcher()
        .addValue(tick_by_frame)
        .setText("   speed")
        .getMacro()
      ;
  }
  
  public void tick() {
    for (Community c : list) c.tick();
  }
  
  public void draw() {
    for (Community c : list) if (c.show_entity.get()) c.draw_All();
  }
  
  public void comunity_reset() {
    randomSeed(SEED.get());
    for (Community c : list) c.reset();
  }
}

abstract class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  int MAX_ENT = 5000; //longueur max de l'array d'objet
  sInt initial_entity = new sInt(simval, 0);
  int id; //index dans comu list
  sInt activeEntity = new sInt(simval, 0);
  ComunityList comList;
  sPanel panel;
  sBoo adding_type = new sBoo(simval, true);
  int adding_pile = 0;
  sInt adding_step = new sInt(simval, 10); // add one new object each adding_step turn
  float adding_counter = 0;
  sBoo show_entity = new sBoo(simval, true);
  sBoo show_menu = new sBoo(simval, true);
  String name = "";
  
  Community(ComunityList _c, String n, int max) { comList = _c; name = n; MAX_ENT = max; }
    
  public void init() {
    id = comList.list.size();
    comList.list.add(this);
    list.clear();
    for (int i = 0; i < MAX_ENT ; i++)
      list.add(build());
      
    comList.panel.addDrawer(20)
        .addText("Community: "+name, 0, 0)
          .setFont(18)
          .getDrawer()
        .addSwitch("M", 280, 0)
          .setValue(show_menu)
          .setSize(50, 20).setFont(18)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (show_menu.get()) panel.g.hide(); else panel.g.show(); } } )
          .getDrawer()
        .addSwitch("E", 330, 0)
          .setValue(show_entity)
          .setSize(50, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    
    panel = new sPanel(cp5, 30 + id*50, 50 + id*30)
      .addText("COMUNITY CONTROL", 38, 0, 28)
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
    if (!show_menu.get()) panel.g.hide();
    
    macro_build_panel
      .addText("Community: " + name, 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("COM IN", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuIN(); } } )
          .getDrawer()
        .addButton("COM OUT", 200, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
  }
  
  public void newMacroComuIN() {
    new MacroCUSTOM(mList)
      .setLabel("COMU IN " + name)
      .setWidth(200)
      .addMCsIntControl()
        .setValue(initial_entity)
        .setText("init")
        .getMacro()
      .addMCsIntControl()
        .setValue(adding_step)
        .setText("step")
        .getMacro()
      .addMCsBooControl()
        .setValue(adding_type)
        .setText("step")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { adding_pile += initial_entity.get(); }})
        .setText("add")
        .getMacro()
      ;
  }
  
  public void newMacroComuOUT() {
    new MacroCUSTOM(mList)
      .setLabel("COMU OUT " + name)
      .setWidth(200)
      .addMCsIntWatcher()
        .addValue(activeEntity)
        .setText("  active")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(initial_entity)
        .setText("  init")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(adding_step)
        .setText("  step")
        .getMacro()
      .addMCsBooWatcher()
        .addValue(adding_type)
        .setText("  step")
        .getMacro()
      ;
  }
  
  public Community show_menu() { panel.g.show(); show_menu.set(true); return this; }
  public Community hide_menu() { panel.g.hide(); show_menu.set(false); return this; }
  public Community show_entity() { show_entity.set(true); return this; }
  public Community hide_entity() { show_entity.set(false); return this; }
  
  public void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (!adding_type.get()) 
      for (int j = 0; j < initial_entity.get(); j++)
        initialEntity();
    if (adding_type.get()) adding_pile = initial_entity.get();
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
    for (Entity e : list) if (e.active) e.tick();
    custom_tick();
    activeEntity.set(active_Entity_Nb());
  }
  public void custom_tick() {}
  public void draw_All() {
    for (Entity e : list) if (e.active) e.drawing(); }
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
  int id;
  boolean active;
  Entity(Community c) {
    active = false;
    id = c.list.size();
    com = c;
  }
  public Entity activate() {
    if (!active) { active = true; init(); }
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


public void init_panel(String s) {
  cp5 = new ControlP5(this);
  
  int c = color(190);
  int c2 = color(10, 100, 180);
  cp5.addTab("Menu")
    .setSize(100,30)
    .setHeight(30)
    .setColorActive(c2)
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;
  cp5.addTab("Macros")
    .setSize(100,30)
    .setHeight(30)
    .setColorActive(c2)
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;

  cp5.getTab("default")
    .setSize(100,30)
    .setHeight(30)
    .setColorActive(c2)
    .setLabel("Main")
    .getCaptionLabel().setFont(getFont(18)).setColor(c);
    ;
  cp5.getTab(s).bringToFront();
  
  cp5.getWindow().setPositionOfTabs(35, height-30);

  init_macro();
}

class sGrabable extends Callable {
  float mx = 0; float my = 0;
  Group g;
  PVector pos = new PVector(0, 0);
  
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
      if (g.isMouseOver()) {
        if (mouseClick[0]) {
          mx = g.getPosition()[0] - mouseX;
          my = g.getPosition()[1] - mouseY;
          cam.GRAB = false; //deactive le deplacement camera
        } else if (mouseUClick[0]) {
          cam.GRAB = true;
        }
        if (mouseButtons[0]) {
          g.setPosition(mouseX + mx,mouseY + my);
          pos = cam.screen_to_cam(new PVector(mouseX + mx, mouseY + my));
        }
      } else {
        if (mouseClick[0] && cam.GRAB == true) {
          mx = g.getPosition()[0] - mouseX;
          my = g.getPosition()[1] - mouseY;
        }
        if (mouseButtons[0] && cam.GRAB == true) {
          g.setPosition(mouseX + mx,mouseY + my);
          pos = cam.screen_to_cam(new PVector(mouseX + mx, mouseY + my));
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
  Group g;
  boolean pos_loaded = false;
  
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
    
    pos_x.set(PApplet.parseInt(x));
    pos_y.set(PApplet.parseInt(y));
    
    g.setPosition(x, y)
        .setSize(PANEL_WIDTH, 0)
        .setBackgroundHeight(0)
        .setBackgroundColor(color(60, 200))
        .disableCollapse()
        .moveTo("Menu")
        .getCaptionLabel().setText("");
        
    this.addChannel(frame_chan);
  }
  
  public void answer(Channel channel, float value) {
    if (!pos_loaded) {
      g.setPosition(pos_x.get(),pos_y.get());
      pos_loaded = true;
    } else {
      //moving control panel
      if (g.isMouseOver()) {
        if (mouseClick[0]) {
          mx = g.getPosition()[0] - mouseX;
          my = g.getPosition()[1] - mouseY;
          cam.GRAB = false; //deactive le deplacement camera
        } else if (mouseUClick[0]) {
          cam.GRAB = true;
        }
        if (mouseButtons[0]) {
          g.setPosition(mouseX + mx,mouseY + my);
          pos_x.set(PApplet.parseInt(mouseX+mx));
          pos_y.set(PApplet.parseInt(mouseY+my));
        }
      }
    }
  }
  
  public sPanel setTab(String s) { g.moveTo(s); return this; }
  
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
    addDrawer(30)
      .addIntModifier(signe1+str(f1), 0, 0)
        .setMode(mode, f1a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier(signe1+str(f2), 40, 0)
        .setMode(mode, f2a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addText(label, 110, 5)
        .setFont(18)
      .getDrawer()
      .addText("", 200, 5)
        .setValue(i)
        .setFont(18)
      .getDrawer()
      .addIntModifier(signe2+str(f2), 310, 0)
        .setMode(mode, f2b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier(signe2+str(f1), 350, 0)
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
    addDrawer(30)
      .addFltModifier(signe1+str(f1), 0, 0)
        .setMode(mode, f1a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier(signe1+str(f2), 40, 0)
        .setMode(mode, f2a)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addText(label, 110, 5)
        .setFont(18)
      .getDrawer()
      .addText("", 200, 5)
        .setValue(i)
        .setFont(18)
      .getDrawer()
      .addFltModifier(signe2+str(f2), 310, 0)
        .setMode(mode, f2b)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier(signe2+str(f1), 350, 0)
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
    else if (fval != null) t.setText(text_start + str(fval.get()) + text_end);
    else t.setText(text_start + text_end);
  }
  public sLabel setPanel(sPanel p) { t.setGroup(p.g); return this; }
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
  
  sBoo show_canvas = new sBoo(simval, false);
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
  
  
  public void answer(Channel channel, float value) {
    pos = cam.screen_to_cam(can_grab.getP());
    pos.y -= 20 / cam.cam_scale.get();
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
class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroList macroList;
  
  LinkList(MacroList m) {
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
    LinkB l = new LinkB(macroList);
    linkBList.add(l);
    return l;
  }

  public LinkF createLinkF() {
    LinkF l = new LinkF(macroList);
    linkFList.add(l);
    return l;
  }
}

class LinkB {
  MacroList macroList;
  InputB in;
  OutputB out;
  LinkB(MacroList m) {
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
    if (this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
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
  MacroList macroList;
  InputF in;
  OutputF out;
  float value = 0;
  LinkF(MacroList m) {
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
    if (this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
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

abstract class InputA {
  MacroList macroList;
  int x,y,n;
  int id = 0;
  Group g;
  Button in;
  boolean bang = false;
  InputA(MacroList m, String s_, int _id, Group g_, int n_) {
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
  InputB(MacroList m, int id, Group g_, int i, String text, int n_) {
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
    t.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("B");
  //}
  public boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
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
  InputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
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
  }
  public void clear() {
    textf.remove();
    t.remove();
    super.clear();
  }
  public boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkF) {macroList.addLinkSelectInF(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    bang = false;
    for (LinkF f : l) {
      if (!f.out.updated) {return false;}
    }
    for (LinkF f : l) {
      bang |= f.out.bang;
      if (f.out.bang) {value = f.out.value;}
    }
    if (bang) { textf.setFocus(true); textf.setText(str(value)); textf.setFocus(false); }
    
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

abstract class OutputA {
  MacroList macroList;
  boolean updated = false;
  int x = -100; int y = -100;
  int n = 0;
  int id = 0;
  Group g;
  Button out;
  boolean bang = false;

  OutputA(MacroList m, String s_, int _id, Group g_, int n_) {
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
  OutputB(MacroList m, int id, Group g_, int i, String text, int n_) {
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
    update();
  }
  public void bang() { set(true); }
  public void unBang() { set(false); }
  public boolean get() {
    return bang;
  }
  public void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutB(this);}
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
  OutputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
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
  public void unBang() {bang = false;}
  public void bang() {
    bang = true;
    for (LinkF f : l) {
      f.in.bang = true;
    }
    update();
  }
  public float get() {return value;}
  public void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutF(this);}
    updated = true;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 12 + (n*26));
    if (value < 0.000001f) {value = 0;}
    if (bang) {out.setOn(); textf.setFocus(true); textf.setText(str(value).trim()); textf.setFocus(false);} else {out.setOff();}
    //bang = false;
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
  MCsValueController(sFlt) inF value      BEUG!!!!
  >MCsValueController(sBoo) inB value
  
  >MCRun( code ) inB bang
  MCKeyboard(key) outB bang
  
  MCsValueModifier(sFlt)
    inB bang, inF value, select : 'x' / '/' / '+' / '-'
  
*/




class MacroCUSTOM extends Macro {
  ArrayList<MCConnexion> connexions = new ArrayList<MCConnexion>();
  
  MacroCUSTOM(MacroList l_) {
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
  
  public void update() {
    super.update();
    for (MCConnexion c : connexions) c.update();
    updated = true;
  }
  
  public void drawing(float x, float y) {}
  public void clear() { super.clear(); }
  //void to_strings() { super.to_strings(); file.append(""); }
}

abstract class MCConnexion {
  MacroCUSTOM macro;
  MCConnexion(MacroCUSTOM m) {
    macro = m; macro.connexions.add(this); }
  public MacroCUSTOM getMacro() { return macro; }
  public abstract void update();
  public abstract MCConnexion setText(String s);
}



class MCsFltControl extends MCConnexion {
  InputF in;
  sFlt flt;
  
  MCsFltControl(MacroCUSTOM m) { super(m);
    in =  macro.createInputF("CtrlF", 0); }
  
  public MCsFltControl setText(String s) { in.t.setText(s); return this; }
  public MCsFltControl setValue(sFlt b) { flt = b; in.set(flt.get()); return this; }
  
  public void update() {
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
  
  public void update() {
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
  
  public void update() {
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
  
  MCsFltWatcher(MacroCUSTOM m) { super(m);
    out =  macro.createOutputF("WatchF", 0); }
  
  public MCsFltWatcher setText(String s) { out.t.setText(s); return this; }
  
  public MCsFltWatcher addValue(sFlt f) {
    flt = f;
    v = f.get();
    out.set(v);
    return this; }
  public void update() {
    if (v != flt.get()) out.set(flt.get());
    out.bang();                                    // !! ou seulement si changement !!
    v = flt.get(); }
}



class MCsIntWatcher extends MCConnexion {
  OutputF out;
  float v = 0;
  sInt i;
  
  MCsIntWatcher(MacroCUSTOM m) { super(m);
    out =  macro.createOutputF("WatchI", 0); }
  
  public MCsIntWatcher setText(String s) { out.t.setText(s); return this; }
  
  public MCsIntWatcher addValue(sInt f) {
    i = f;
    v = f.get();
    out.set(v);
    return this; }
  public void update() {
    if (v != i.get()) out.set(i.get());
    out.bang();                                    // !! ou seulement si changement !!
    v = i.get(); }
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
  public void update() {
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
  
  public void update() { if (in.getUpdate() && in.get()) for (Runnable r : runs) r.run(); }
}

//#############    RUNNABLE    #############
abstract class Runnable { public abstract void run(); }



class MCListen extends MCConnexion {
  OutputB out;
  boolean v = false;
  
  MCListen(MacroCUSTOM m) { super(m);
    out =  macro.createOutputB("listen"); }
    
  public MCListen setText(String s) { out.t.setText(s); return this; }
  
  public MCListen addChannel(Channel chan) {
    new Callable(chan) { public void answer(Channel channel, float value) { v = true; }};
    return this; }
  public void update() {
    if (v) out.set(true); else out.set(false);
    v = false; }
}



class MCCall extends MCConnexion {
  InputB in;
  ArrayList<Channel> chans = new ArrayList<Channel>();
  
  MCCall(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("call"); }
  
  public MCCall setText(String s) { in.t.setText(s); return this; }
  public MCCall addChannel(Channel chan) { chans.add(chan); return this; }
  public void update() { if (in.getUpdate() && in.get()) for (Channel c : chans) callChannel(c); }
}





//#######################################################################
//##                           BASIC MACRO                             ##
//#######################################################################


class Pulse extends Macro {
  OutputB out;
  InputF in;
  int turn = 0;
  int freq = 100;
  int cnt = 0;
  
  Pulse(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("pulse");
    g.setWidth(150);
    out = createOutputB("");
    in = createInputF("", freq);
    turn = freq;
    cnt = PApplet.parseInt(tick.get());
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
        turn = PApplet.parseInt(tick.get()) + m;
        freq = m;
      }
    }
    if (tick.get() < cnt) turn = freq;
    cnt = PApplet.parseInt(tick.get());
    if (tick.get() >= turn) {
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
  //Textfield txtf;
  
  MacroVAL(MacroList ml, float v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    value = v_;
    g.setLabel("Value");
    in =  createInputB("IN");
    inV =  createInputF("  VAL",value);
    out = createOutputF("    OUT",v_);
    //txtf = cp5.addTextfield("textVal" + str(id))
    //   .setLabel("")
    //   .setPosition(100,2)
    //   .setSize(70,22)
    //   .setAutoClear(false)
    //   .setGroup(g)
    //   .setText(str(value))
    //   ;
    //txtf.getValueLabel().setFont(createFont("Arial",18));
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
      if (in.get()) {out.bang();} else {out.unBang();}
      out.update();
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
  
  MacroDELAY(MacroList ml, int v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    count = v_;
    g.setLabel("Delay");
    in =  createInputB("IN");
    out = createOutputB("    OUT");
    txtf = cp5.addTextfield("textDel" + str(id))
       .setLabel("")
       .setPosition(100,2)
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
  
  MacroCOMP(MacroList ml, int i_, int x_, int y_) {
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

      out.update();
      updated = true;
    }
  }
}

class MacroBOOL extends Macro {
  OutputB out;
  InputB in1,in2;
  
  RadioButton r1;
  
  MacroBOOL(MacroList ml, int i_, int x_, int y_) {
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

      out.update();
      updated = true;
    }
  }
}

class MacroCALC extends Macro {
  OutputF out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  
  MacroCALC(MacroList ml, int i_, int x_, int y_) {
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

      out.update();
      updated = true;
    }
  }
}






















//#######################################################################
//##                           OLD MACRO                               ##
//#######################################################################


class Keyboard extends Macro {
  boolean w,c,a,p;
  OutputB wO,cO,aO,pO;
  
  Keyboard(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    w = false; c = false; a = false; p = false;
    g.setLabel("Key");
    g.setWidth(150);
    aO = createOutputB("          A");
    wO = createOutputB("          W");
    pO = createOutputB("          P");
    cO = createOutputB("          C");
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("Keyboard");
  //}
  
  public void update() {
    w = false; c = false; a = false; p = false;
    if (keysClick[4]) {w = true;}
    if (keysClick[5]) {c = true;}
    if (keysClick[7]) {a = true;}
    if (keysClick[8]) {p = true;}
    wO.set(w);
    cO.set(c);
    aO.set(a);
    pO.set(p);
    super.update();
    updated = true;
  }
  
  public void drawing(float x, float y) {}
}

class GrowingPop extends Macro {
  InputB addI;
  InputB add2I;
  
  GrowingPop(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("ADD");
    g.setWidth(200);
    addI = createInputB("grower");
    add2I = createInputB("floc");
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("GrowingPop");
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (addI.getUpdate() && add2I.getUpdate()) {
      if (addI.get()) {
        if (!gcom.adding_type.get()) 
        for (int j = 0; j < gcom.initial_entity.get(); j++)
          gcom.initialEntity();
        if (gcom.adding_type.get()) gcom.adding_pile = gcom.initial_entity.get();
      }
      if (add2I.get()) {
        if (!fcom.adding_type.get()) 
        for (int j = 0; j < fcom.initial_entity.get(); j++)
          fcom.initialEntity();
        if (fcom.adding_type.get()) fcom.adding_pile = fcom.initial_entity.get();
      }
    }
    super.update();
    updated = true;
  }
}

class GrowingParam extends Macro {
  InputF growI,sproutI,stopI,dieI,ageI;
  float grow,sprout,stop,die,age;
  
  GrowingParam(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    //growI = createInputF("GROW", GROW_DIFFICULTY);
    //grow = GROW_DIFFICULTY;
    //sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
    //sprout = SPROUT_DIFFICULTY;
    //stopI = createInputF("STOP", STOP_DIFFICULTY);
    //stop = STOP_DIFFICULTY;
    //dieI = createInputF("DIE", DIE_DIFFICULTY);
    //die = DIE_DIFFICULTY;
    //ageI = createInputF("AGE", OLD_AGE);
    //age = OLD_AGE;
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("GrowingControl");
  //  file.append(str(grow));
  //  file.append(str(sprout));
  //  file.append(str(stop));
  //  file.append(str(die));
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    //float g = growI.get();
    //float sp = sproutI.get();
    //float st = stopI.get();
    //float d = dieI.get();
    //float a = ageI.get();
    
    //if (g != grow) {
    //  grow = g; GROW_DIFFICULTY = grow;
    //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
    //else if (g != GROW_DIFFICULTY) {
    //  grow = GROW_DIFFICULTY; growI.set(grow); }
    
    //if (sp != sprout) {
    //  sprout = sp; SPROUT_DIFFICULTY = sprout;
    //  update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
    //else if (sp != SPROUT_DIFFICULTY) {
    //  sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
    //if (st != stop) {
    //  stop = st; STOP_DIFFICULTY = stop;
    //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
    //else if (st != STOP_DIFFICULTY) {
    //  stop = STOP_DIFFICULTY; stopI.set(stop); }
    
    //if (d != die) {
    //  die = d; DIE_DIFFICULTY = die;
    //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
    //else if (d != DIE_DIFFICULTY) {
    //  die = DIE_DIFFICULTY; dieI.set(die); }
      
    //if (a != age) {
    //  age = a; OLD_AGE = (int)age;
    //  update_textlabel("AGING", " at ", OLD_AGE);
    //}
    //else if (a != OLD_AGE) {
    //  age = OLD_AGE; ageI.set(age); }
    
    super.update();
    updated = true;
  }
}

class GrowingActive extends Macro {
  InputB growI,sproutI,stopI,dieI,growoffI,sproutoffI,stopoffI,dieoffI;
  
  GrowingActive(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    growI = createInputB("GROW ON");
    sproutI = createInputB("SPROUT ON");
    stopI = createInputB("STOP ON");
    dieI = createInputB("DIE ON");
    growoffI = createInputB("GROW OFF");
    sproutoffI = createInputB("SPROUT OFF");
    stopoffI = createInputB("STOP OFF");
    dieoffI = createInputB("DIE OFF");
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("GrowingActiv");
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    //if (growI.getUpdate() && sproutI.getUpdate() && stopI.getUpdate() && dieI.getUpdate() && 
    //    growoffI.getUpdate() && sproutoffI.getUpdate() && stopoffI.getUpdate() && dieoffI.getUpdate() ) {
    //  if (growI.get()   && !ON_GROW)   bGrow.setOn();
    //  if (sproutI.get() && !ON_SPROUT) bSprout.setOn();
    //  if (stopI.get()   && !ON_STOP)   bStop.setOn();
    //  if (dieI.get()    && !ON_DIE)    bDie.setOn();
    //  if (growoffI.get()   && ON_GROW)   bGrow.setOff();
    //  if (sproutoffI.get() && ON_SPROUT) bSprout.setOff();
    //  if (stopoffI.get()   && ON_STOP)   bStop.setOff();
    //  if (dieoffI.get()    && ON_DIE)    bDie.setOff();
    //}
    super.update();
    updated = true;
  }
}

class GrowingControl extends Macro {
  InputB in;
  
  RadioButton r1, r2, r3;
  
  GrowingControl(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    in = createInputB("");
    g.setSize(g.getWidth(), 28 + (inCount*28));
    
    r1 = cp5.addRadioButton("radioButton1" + id)
         .setGroup(g)
         .setPosition(20,6)
         .setSize(15,15)
         .setItemsPerRow(1)
         .setSpacingRow(8)
         .addItem("x" + id,1)
         .addItem("/" + id,2)
         ;
         
     r2 = cp5.addRadioButton("radioButton2" + id)
         .setGroup(g)
         .setPosition(55,6)
         .setSize(15,15)
         .setItemsPerRow(1)
         .setSpacingRow(8)
         .addItem("1.2" + id,1)
         .addItem("2" + id,2)
         ;
     
     r3 = cp5.addRadioButton("radioButton3" + id)
         .setGroup(g)
         .setPosition(100,6)
         .setSize(15,15)
         .setItemsPerRow(2)
         .setSpacingRow(8)
         .setSpacingColumn(35)
         .addItem("GROW" + id,1)
         .addItem("BLOOM" + id,2)
         .addItem("STOP" + id,3)
         .addItem("DIE" + id,4)
         ;
     
     r1.getItem("x" + id).getCaptionLabel().setText("x");
     r1.getItem("/" + id).getCaptionLabel().setText("/");
     r2.getItem("1.2" + id).getCaptionLabel().setText("1.2");
     r2.getItem("2" + id).getCaptionLabel().setText("2");
     r3.getItem("GROW" + id).getCaptionLabel().setText("GROW");
     r3.getItem("BLOOM" + id).getCaptionLabel().setText("BLOOM");
     r3.getItem("STOP" + id).getCaptionLabel().setText("STOP");
     r3.getItem("DIE" + id).getCaptionLabel().setText("DIE");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("x" + id).setState(true);
     for(Toggle t:r2.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r2.getItem("2" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("GrowingActiv");
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (in.getUpdate()) {
      float m = 0;
      if (r2.getItem("1.2" + id).getState()) m = 1.2f;
      else if (r2.getItem("2" + id).getState()) m = 2;
      if (r1.getItem("/" + id).getState()) m = 1 / m;
      if (in.get()) {
        //if (r3.getItem("GROW" + id).getState()) {
        //  GROW_DIFFICULTY *= m;
        //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
        //if (r3.getItem("BLOOM" + id).getState()) {
        //  SPROUT_DIFFICULTY *= m;
        //  update_textlabel("SPROUT", " = r^", SPROUT_DIFFICULTY); }
        //if (r3.getItem("STOP" + id).getState()) {
        //  STOP_DIFFICULTY *= m;
        //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
        //if (r3.getItem("DIE" + id).getState()) {
        //  DIE_DIFFICULTY *= m;
        //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
      }
    }
    super.update();
    updated = true;
  }
}

class GrowingWatcher extends Macro {
  OutputF popO,growO,turnO;
  float pop,grow,turn;
  
  GrowingWatcher(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("Watcher");
    g.setWidth(150);
    popO = createOutputF("      POP", 0);
    growO = createOutputF("  GROW", 0);
    turnO = createOutputF("  turn", 0);
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("GrowWatcher");
  //  file.append(str(pop));
  //  file.append(str(grow));
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    int p = gcom.active_Entity_Nb();
    int g = gcom.grower_Nb();
    popO.set(p);
    growO.set(g);
    turnO.set(tick.get());
    if (pop != p) popO.bang();
    if (grow != g) growO.bang();
    if (turn != tick.get()) turnO.bang();
    pop = p; grow = g; turn = tick.get();
    super.update();
    updated = true;
  }
}

class SimControl extends Macro {
  InputB inR,inRng,inP;
  
  SimControl(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("SIMULATION");
    g.setWidth(150);
    inR = createInputB("RESET");
    inRng = createInputB("RNG");
    inP = createInputB("PAUSE");
  }
  public void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("Sim Control");
  //}
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (inR.getUpdate() && inRng.getUpdate() && inP.getUpdate()) {
      if (inR.get()) reset();
      if (inRng.get()) {
        SEED.set(PApplet.parseInt(random(1000000000)));
        reset();
      }
      if (inP.get()) {
        pause.set(!pause.get());
      }
    }
    super.update();
    updated = true;
  }
}


MacroList mList;

//Keyboard keyb;
//GrowingControl gcC;
//GrowingWatcher gwC;

//MacroVAL mv1,mv2;

sPanel macro_build_panel;

public void init_macro() {
  mList = new MacroList();
  
  macro_build_panel = new sPanel(cp5, 100, 300)
    .setTab("Macros")
    .addSeparator(5)
    .addText("- NEW  MACRO -", 85, 0, 26)
    .addSeparator(12)
    .addText("BASIC MACRO :", 0, 0, 18)
    .addSeparator(8)
    .addDrawer(70)
      .addButton("VAL", 30, 0)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addMacroVAL(mList.adding_pos, mList.adding_pos, 0);
          } } )
        .getDrawer()
      .addButton("PULSE", 140, 0)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addPulse(mList.adding_pos, mList.adding_pos);
          } } )
        .getDrawer()
      .addButton("DELAY", 250, 0)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addMacroDELAY(mList.adding_pos, mList.adding_pos, 0);
          } } )
        .getDrawer()
      .addButton("COMP", 30, 40)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addMacroCOMP(mList.adding_pos, mList.adding_pos);
          } } )
        .getDrawer()
      .addButton("BOOL", 140, 40)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addMacroBOOL(mList.adding_pos, mList.adding_pos);
          } } )
        .getDrawer()
      .addButton("CALC", 250, 40)
        .setSize(100, 30)
        .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {
            mList.addMacroCALC(mList.adding_pos, mList.adding_pos);
          } } )
        .getDrawer()
      .getPanel()
    .addLine(12)
    .addSeparator(5)
    ;
  
  //keyb.wO.linkTo(mv1.in);
  //keyb.aO.linkTo(mv2.in);
  
  //mv1.out.linkTo(gcC.growI);
  //mv2.out.linkTo(gcC.growI);
}

class MacroList {
  ArrayList<Macro> macroList = new ArrayList<Macro>(0);
  ArrayList<InputB> inBList = new ArrayList<InputB>(0);
  ArrayList<OutputB> outBList = new ArrayList<OutputB>(0);
  ArrayList<InputF> inFList = new ArrayList<InputF>(0);
  ArrayList<OutputF> outFList = new ArrayList<OutputF>(0);
  
  LinkList linkList = new LinkList(this);
  
  Group g;
  LinkB NOTB = linkList.createLinkB();
  LinkF NOTF = linkList.createLinkF();
  InputB NOTBI;
  InputF NOTFI;
  OutputB NOTBO;
  OutputF NOTFO;
  
  boolean creatingLinkB = false;
  OutputB selectOutB;
  boolean creatingLinkF = false;
  OutputF selectOutF;
  
  int adding_pos = 40;
  
  MacroList() {
    g = cp5.addGroup("Main")
                  .setVisible(false)
                  .setPosition(-200,-200)
                  .moveTo("Macros")
                  ;
    NOTBO = createOutputB(g, -1,"",0);
    NOTFO = createOutputF(g,-1,"",1,0);
    NOTBI = createInputB(g,-1,"",0);
    NOTFI = createInputF(g,-1,"",1,0);
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
    if (mouseClick[1]) {
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
  
  public Keyboard addKeyboard(int _x, int _y) {
    int id = macroList.size();
    return new Keyboard(this, id, _x, _y);
  }
  
  public Pulse addPulse(int _x, int _y) {
    int id = macroList.size();
    return new Pulse(this, id, _x, _y);
  }
  
  public SimControl addSimControl(int _x, int _y) {
    int id = macroList.size();
    return new SimControl(this, id, _x, _y);
  }
  
  public GrowingPop addGrowingPop(int _x, int _y) {
    int id = macroList.size();
    return new GrowingPop(this, id, _x, _y);
  }
  
  public GrowingParam addGrowingParam(int _x, int _y) {
    int id = macroList.size();
    return new GrowingParam(this, id, _x, _y);
  }
  
  public GrowingControl addGrowingControl(int _x, int _y) {
    int id = macroList.size();
    return new GrowingControl(this, id, _x, _y);
  }
  
  public GrowingActive addGrowingActive(int _x, int _y) {
    int id = macroList.size();
    return new GrowingActive(this, id, _x, _y);
  }
  
  public GrowingWatcher addGrowingWatcher(int _x, int _y) {
    int id = macroList.size();
    return new GrowingWatcher(this, id, _x, _y);
  }
  
  public MacroVAL addMacroVAL(int _x, int _y, float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, _x, _y);
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
  MacroList macroList;
  boolean updated = false;
  Group g;
  int id; int x,y; float mx = 0; float my = 0;
  int inCount = 0;
  int outCount = 0;
  
  Macro(MacroList ml, int i_, int x_, int y_) {
    ml.addMacro(this);
    macroList = ml;
    ml.adding_pos += 60;
    if (ml.adding_pos >= 700) ml.adding_pos -= 635;
    id = i_;
    x = x_; y = y_;
    g = cp5.addGroup("Macro" + str(id))
                  .activateEvent(true)
                  .setPosition(x,y)
                  .setSize(320,22)
                  .setBackgroundColor(color(60, 200))
                  .disableCollapse()
                  .moveTo("Macros")
                  .setHeight(22)
                  ;
    g.getCaptionLabel().setFont(createFont("Arial",16));
  }
  public void clear() {
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
  
  public void update() {
    if (cp5.getTab("Macros").isActive()) {
      if (g.isMouseOver() && mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        cam.GRAB = false; //deactive le deplacement camera
      }
      if (g.isMouseOver() && mouseUClick[0]) {
        cam.GRAB = true;
      }
      if (g.isMouseOver() && mouseButtons[0]) {
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
    return in;
  }

  public InputF createInputF(String text, float d) {
    InputF in = macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }
  
  public OutputB createOutputB(String text) {
    OutputB out = macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }

  public OutputF createOutputF(String text, float d) {
    OutputF out = macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }
}

//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


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

public float crandom(float d) {
  return pow(random(1.0f), d) ;
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
  public void unFlagChange() {
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
  public int get() { return val; }
  public void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  public float get() { return val; }
  public void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  public boolean get() { return val; }
  public void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}




//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


public void saving(SpecialValue sv, String file) {
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
public void loading(SpecialValue s, String file) {
  String[] sl = loadStrings(file);
  if (sl.length != s.sintlist.size() + s.sfltlist.size() + s.sboolist.size()) return;
  for (sInt i : s.sintlist) {
    i.set(PApplet.parseInt(sl[i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(PApplet.parseFloat(sl[s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(PApplet.parseBoolean(sl[s.sintlist.size() + s.sfltlist.size() + i.id]));
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
  
  public void init() {
    //initialisation des array des graph
    for (int i = 0; i < larg; i++) { 
      graph[i] = 0; 
      graph2[i] = 0;
    }
    max = 10;
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
    String[] appletArgs = new String[] { "grows_2_1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
