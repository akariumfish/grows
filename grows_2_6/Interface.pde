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
  DataHolding data;
  
  sInterface() {
    super();
    data = new DataHolding();
    cam = new Camera(this);
    screen_gui = new nGUI(this);
    cam_gui = new nGUI(this)
      .setMouse(cam.mouse)
      .addEventNotFound(new Runnable() { public void run() { 
        if (!screen_gui.hoverable_pile.found) runEvents(eventsHoverNotFound);  
      } } )
      ;
    
    new nWidget(cam_gui, 10, 10, 100, 50).setTrigger();
    
  }
  
  nWidget newCamWidget() { return new nWidget(cam_gui); }
  nWidget newScreenWidget() { return new nWidget(screen_gui); }
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsHoverNotFound = new ArrayList<Runnable>();
  sInterface addEventHoverNotFound(Runnable r) { eventsHoverNotFound.add(r); return this; }
  sInterface addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  
  void frame() {
    runEvents(eventsFrame);
    
    cam.pushCam();
    cam_gui.frame(true);
    cam_gui.draw();
    cam.popCam();
    
    screen_gui.frame(true);
    screen_gui.draw();
    
    super.update();
  }
  
}







////#######################################################################
////##                             CAMERA                                ##
////#######################################################################


class Camera {
  sInterface inter;
  sValueBloc sbloc;
  PVector cam_pos = new PVector(0, 0); //position de la camera
  sFlt cam_scale; //facteur de grossicement
  float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true;
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive

  boolean matrixPushed = false;

  sBoo grid;

  //sFlt pos_x = new sFlt(simval, 0);
  //sFlt pos_y = new sFlt(simval, 0);
  boolean pos_loaded = false;

  Channel zoom_chan = new Channel();
  
  Camera(sInterface i) { 
    sbloc = new sValueBloc(i.data, "cam");
    grid = new sBoo(sbloc, true, "show grid");
    cam_scale = new sFlt(sbloc, 1.0, "cam scale");
    inter = i; 
  }
  //Camera(sInterface i, float x, float y, float s) { inter = i; pos_x.set(x); pos_y.set(y); cam_scale.set(s); }

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
  
  PVector mouse = new PVector();

  void pushCam() {
    PVector tm = getCamMouse();
    mouse.x = tm.x; mouse.y = tm.y;
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

    //if (!pos_loaded) {
    //  cam_pos.set(pos_x.get(), pos_y.get());
    //  pos_loaded = true;
    //}

    //permet le cliquer glisser le l'ecran
    if (inter.mouseButtons[0] && GRAB) { 
      cam_pos.add(mouseX - pmouseX, mouseY - pmouseY); 
      //pos_x.set(cam_pos.x);
      //pos_y.set(cam_pos.y);
    }

    //permet le zoom
    if (inter.mouseWheelUp) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); 
      cam_pos.mult(1/ZOOM_FACTOR); 
      callChannel(zoom_chan);
      //pos_x.set(cam_pos.x);
      //pos_y.set(cam_pos.y);
    }
    if (inter.mouseWheelDown) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); 
      cam_pos.mult(ZOOM_FACTOR); 
      callChannel(zoom_chan);
      //pos_x.set(cam_pos.x);
      //pos_y.set(cam_pos.y);
    }
  }
}
