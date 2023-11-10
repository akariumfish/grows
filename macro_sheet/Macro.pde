

Macro_Sheet ms;

Hoverable_pile hpile = new Hoverable_pile();
Drawing_pile dpile = new Drawing_pile();


//void mysetup() {
  
//  ms = new Macro_Sheet(cp5)
//    .addMacro_Box()
//      .setLayer(3)
//      .setPos(200, 200)
//      .setSize(150, 100)
//      .getSheet()
    
//    .addMacro_Box()
//      .setLayer(2)
//      .setPos(500, 200)
//      .setSize(100, 300)
//      .getSheet()
    
//    .addOutput()
//      .setPos(200, 200)
//      .getSheet()
    
//    .addInput()
//      .setPos(400, 200)
//      .getSheet()
    
//    .linkLast()
//    ;
//}



//void mydraw() {
  
//  //hpile.search(new PVector(mouseX, mouseY));
//  hpile.search(cam.getCamMouse());
  
//  ms.frame();
  
//  //dpile.drawing();
  
//  // apply camera view
//  cam.pushCam();
  
//  //hpile.search(cam.getCamMouse());
  
//  dpile.drawing();
  
//  cam.popCam();
  
//}




class Macro_Sheet {
  ArrayList<Macro_Box> mboxl = new ArrayList<Macro_Box>(0);
  ArrayList<Macro_Link> mlinkl = new ArrayList<Macro_Link>(0);
  ArrayList<Macro_Input> minl = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> moutl = new ArrayList<Macro_Output>(0);
  ControlP5 cp5;
  //Group g;
  float mx = 0; float my = 0;
  
  Macro_Sheet(ControlP5 c) {
    cp5 = c;
    //g = new Group(cp5, "group" + get_free_id());
    //g.setPosition(50, 50)
    //      .setSize(600, 0)
    //      .setBackgroundHeight(600)
    //      .setBarHeight(20)
    //      .setBackgroundColor(color(30, 200))
    //      .disableCollapse()
    //      .getCaptionLabel().setText("");
    
  }
  Macro_Box addMacro_Box() {
    return new Macro_Box(this);
  }
  void frame() {
    //if (g.isMouseOver()) {
    //  if (kb.mouseClick[0]) {
    //    mx = g.getPosition()[0] - mouseX;
    //    my = g.getPosition()[1] - mouseY;
    //    cam.GRAB = false; //deactive le deplacement camera
    //  } else if (kb.mouseUClick[0]) {
    //    cam.GRAB = true;
    //  }
    //  if (kb.mouseButtons[0]) {
    //    g.setPosition(mouseX + mx,mouseY + my);
    //  }
    //}
    //update link
    //for (Macro_Link m : mlinkl) m.frame();
    for (Macro_Box m : mboxl) m.frame();
    
  }
  void tick() {
    //update link
    //for (Macro_Link m : mlinkl) m.tick();
    //update input value by combining visible value of connected output
    for (Macro_Input m : minl) m.tick();
    //do each macro tick-update
    for (Macro_Box m : mboxl) m.tick();
    //update each output visible value and activation state
    for (Macro_Output m : moutl) m.tick();
  }
  void drawing() {
    for (Macro_Link m : mlinkl) m.drawing();
    for (Macro_Box m : mboxl) m.drawing();
    for (Macro_Input m : minl) m.drawing();
    for (Macro_Output m : moutl) m.drawing();
  }
  Macro_Input addInput() {
    return new Macro_Input(this);
  }
  Macro_Output addOutput() {
    return new Macro_Output(this);
  }
  
  Macro_Input last_created_input = null;
  Macro_Output last_created_output = null;
  
  Macro_Input getLastInput() { return last_created_input; }
  Macro_Output getLastOutput() { return last_created_output; }
  Macro_Sheet link(Macro_Input in, Macro_Output out) {
    new Macro_Link(this, in, out); return this; }
  Macro_Sheet linkLast() {
    if (last_created_input != null && last_created_output != null)
      link(last_created_input, last_created_output);
    return this; }
  
}


class Macro_Box {
  //has inputs and outputs
  //maybe not do the tick-updates?
  
  float mx = 0; float my = 0;
  int id = 0;
  Macro_Sheet sheet;
  Rect head;
  Rect body;
  Hoverable hover;
  Drawer drawer;
  
  Macro_Box(Macro_Sheet _s) {
    sheet = _s;
    id = sheet.mboxl.size();
    sheet.mboxl.add(this);
    head = new Rect(100, 100, 200, 20);
    body = new Rect(100, 100, 200, 200);
    hover = new Hoverable(hpile, head, 0);
    drawer = new Drawer(dpile, 0) { public void drawing() {
      if (hover.mouseOver) { stroke(255,180); fill(255); } else { stroke(182,180); fill(182); }
      strokeWeight(1);
      head.draw();
      stroke(255);
      noFill();
      body.draw();
    } };
  }
  
  Macro_Box setLayer(int l) { hover.setLayer(l); return this; }
  Macro_Box setPos(float x, float y) { 
    head.pos.x = x; head.pos.y = y;
    body.pos.x = x; body.pos.y = y; 
    return this; }
  Macro_Box setSize(float x, float y) { 
    head.size.x = x;
    body.size.x = x; body.size.y = y; 
    return this; }

  Macro_Sheet getSheet() { return sheet; }
  
  boolean grabbed = false;
  
  void frame() {
    if (hover != null && hover.mouseOver && kb.mouseClick[0]) {
      mx = head.pos.x - mouseX;
      my = head.pos.y - mouseY;
      cam.GRAB = false; //deactive le deplacement camera
      grabbed = true;
    }
    if (grabbed && kb.mouseUClick[0]) {
      cam.GRAB = true;
      grabbed = false;
    }
    if (grabbed && kb.mouseButtons[0]) {
      head.pos.x = mouseX + mx;
      head.pos.y = mouseY + my;
      body.pos.x = mouseX + mx;
      body.pos.y = mouseY + my;
    }
  }
  
  void tick() {
    
  }
  
  void drawing() {
    
  }

}

class Macro_Packet {
  
  void combine(Macro_Packet p) {
    
  }
}

float macro_connection_size = 20;

class Macro_Input {
  //is actif if one of connected link is actif
  //his value is a combination of proposed linked value
  ArrayList<Macro_Link> links = new ArrayList<Macro_Link>(0);
  int id = 0;
  Macro_Sheet sheet;
  Macro_Packet packet = new Macro_Packet();
  Rect rect = new Rect();
  Hoverable over;
  
  Macro_Input(Macro_Sheet _s) {
    sheet = _s;
    sheet.last_created_input = this;
    id = sheet.minl.size();
    sheet.minl.add(this);
    rect.size.x = macro_connection_size;
    rect.size.y = macro_connection_size;
    //over = new Hoverable(rect);
  }
  Macro_Sheet getSheet() { return sheet; }
  
  PVector getPos() { return new PVector(rect.pos.x, rect.pos.y); }
  Macro_Input setPos(float x, float y) { 
    rect.pos.x = x; 
    rect.pos.y = y; 
    return this; }
    
  void tick() {
    //update input value by combining visible value of connected output
    
    for (Macro_Link l : links) if (l.out.isActive) packet.combine(l.out.packet);
    
  }
  
  void drawing() {
    if (over != null && over.mouseOver) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
    strokeWeight(3);
    rect(rect.pos.x, rect.pos.y, 
         macro_connection_size, macro_connection_size);
  }
  
}

class Macro_Output {
  //visible value
  //isActif
  ArrayList<Macro_Link> links = new ArrayList<Macro_Link>(0);
  int id = 0;
  Macro_Sheet sheet;
  boolean isActive = false;
  Macro_Packet packet = new Macro_Packet();
  Rect rect = new Rect();
  Hoverable over;
  
  Macro_Output(Macro_Sheet _s) {
    sheet = _s;
    sheet.last_created_output = this;
    id = sheet.moutl.size();
    sheet.moutl.add(this);
    rect.size.x = macro_connection_size;
    rect.size.y = macro_connection_size;
    //over = new Hoverable(rect);
  }
  Macro_Sheet getSheet() { return sheet; }
  
  PVector getPos() { return new PVector(rect.pos.x, rect.pos.y); }
  Macro_Output setPos(float x, float y) { 
    rect.pos.x = x; 
    rect.pos.y = y; 
    return this; }
  
  void tick() {
    //update output visible value and activation state
    
    isActive = false;
  }
  
  void drawing() {
    if (over != null && over.mouseOver) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
    strokeWeight(3);
    rect(rect.pos.x, rect.pos.y, 
         macro_connection_size, macro_connection_size);
  }
  
}

float macro_link_size = 4;
float macro_link_bubble_size = 18;

class Macro_Link {
  //bool isActif
  //objet information transfered
  int id = 0;
  Macro_Output out; Macro_Input in;
  
  Macro_Sheet sheet;
  
  Macro_Link(Macro_Sheet _s, Macro_Input _i, Macro_Output _o) {
    sheet = _s;
    in = _i; out = _o;
    id = sheet.mlinkl.size();
    sheet.mlinkl.add(this);
    in.links.add(this);
    out.links.add(this);
  }
  
  void drawing() {
    if (in != null && out != null) {
      if (distancePointToLine(mouseX, mouseY, 
             in.getPos().x, in.getPos().y + macro_connection_size/2,
             out.getPos().x + macro_connection_size, out.getPos().y + macro_connection_size/2 )
             < macro_link_size ) {
        if (out.isActive) {stroke(255,255,0,180); fill(255,255,0);} else {stroke(182,182,0,180); fill(182,182,0);}
      } else {
        if (out.isActive) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
      }
      //if (in.in.getTab().isActive() && out.out.getTab().isActive()) {
        strokeWeight(macro_link_size);
        line(in.getPos().x, in.getPos().y + macro_connection_size/2,
             out.getPos().x + macro_connection_size, out.getPos().y + macro_connection_size/2);
      //}
      ellipseMode(RADIUS);
      noStroke();
      //if (out.out.getTab().isActive()) {
        ellipse(out.getPos().x + macro_connection_size, out.getPos().y + macro_connection_size/2,
                macro_link_bubble_size/2,macro_link_bubble_size/2);
      //}
      //if (in.in.getTab().isActive()) {
        //if (distancePointToLine(mouseX, mouseY, in.getPos().x, in.getPos().y, out.getPos().x, out.getPos().y) < 3) {
        //  if (in.in.isOn()) {fill(255,255,0);} else {fill(182,182,0);}
        //} else {
        //  if (in.in.isOn()) {fill(255);} else {fill(182);}
        //}
        ellipse(in.getPos().x, in.getPos().y + macro_connection_size/2,
                macro_link_bubble_size/2,macro_link_bubble_size/2);
      //}
    }
  }
  
}
















//class Sheet extends Controller<Sheet> {
//  boolean mouseOver = false;
//  int backgroundHeight = 0;
  
//  Sheet(ControlP5 cp5, String theName, int x, int y, int w, int h) {
//    super(cp5, theName);
//    backgroundHeight = h;
//    setPosition(x, y);
//    setSize(w, 20);
    
//    setView(new ControllerView() { // replace the default view with a custom view.
//      public void display(PGraphics p, Object b) {
//        Sheet thisSheet = (Sheet)b;
//        // draw button background
//        p.stroke(255);
//        p.noFill();
//        p.rect(0, 0, thisSheet.getWidth(), thisSheet.backgroundHeight);
//        if (thisSheet.mouseOver) p.fill(255);
//        p.rect(0, 0, thisSheet.getWidth(), thisSheet.getHeight());
        
//      }
//    } );
//  }
  
//  void onEnter() {
//    mouseOver = true;
//  }
  
//  void onScroll(int n) {
    
//  }
  
//  void onPress() {
    
//  }
  
//  void onClick() {
    
//  }

//  void onRelease() {
    
//  }
  
//  void onMove() {
    
//  }

//  void onDrag() {
    
//  }
  
//  void onReleaseOutside() {
//    onLeave();
//  }

//  void onLeave() {
//    mouseOver = false;
//  }
//}
