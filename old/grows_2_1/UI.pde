import controlP5.*; //la lib pour les menu


void init_panel(String s) {
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
  
  void hide() { g.hide(); }
  void show() { g.show(); }
  
  float getX() { return g.getPosition()[0]; }
  float getY() { return g.getPosition()[1]; }
  PVector getP() { return new PVector(g.getPosition()[0], g.getPosition()[1]); }
  
  sGrabable setTab(String s) { g.moveTo(s); return this; }
  
  void answer(Channel chan, float value) {
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
      void onEnter() {
        //println("enter");
        super.onEnter();
      }
      void onLeave() {
        //println("leave");
        super.onLeave();
      }
    };
    
    pos_x.set(int(x));
    pos_y.set(int(y));
    
    g.setPosition(x, y)
        .setSize(PANEL_WIDTH, 0)
        .setBackgroundHeight(0)
        .setBackgroundColor(color(60, 200))
        .disableCollapse()
        .moveTo("Menu")
        .getCaptionLabel().setText("");
        
    this.addChannel(frame_chan);
  }
  
  void answer(Channel channel, float value) {
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
          pos_x.set(int(mouseX+mx));
          pos_y.set(int(mouseY+my));
        }
      }
    }
  }
  
  sPanel setTab(String s) { g.moveTo(s); return this; }
  
  sDrawer addDrawer(int h) { return new sDrawer(this, h); }
  sDrawer lastDrawer() { return last_drawer; }
  
  sPanel addRngTryCtrl(String title, RandomTryParam p) {
    addValueController(title, sMode.FACTOR, 2, 1.2, p.DIFFICULTY).lastDrawer()
      .addSwitch("", 80, 5)
        .setValue(p.ON)
        .setSize(20, 20).setFont(18)
      ;
    return this;
  }
  
  sPanel addText(String title, int x, int y, int s) {
    addDrawer(s + y)
      .addText(title, x, y)
        .setFont(s);
    return this;
  }
  sPanel addLine(int h) {
    addDrawer(h)
      .addLine(PANEL_MARGIN*6, h / 2 - 1, PANEL_WIDTH - PANEL_MARGIN*14);
    return this;
  }
  sPanel addSeparator(int h) {
    addDrawer(h);
    return this;
  }
  
  sPanel addValueController(String label, sMode mode, float f1, float f2, sInt i) {
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
  sPanel addValueController(String label, sMode mode, float f1, float f2, sFlt i) {
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
  
  sPanel getPanel() { return panel; }
  
  sDrawer addExclusiveSwitchs(String l1, String l2, int x, int y, sBoo b1, sBoo b2) {
    sExclusifSwitch s1 = addExclusifSwitch(l1, x, y);
    s1.setValue(b1).setSize(60, 20).setFont(16);
    sExclusifSwitch s2 = addExclusifSwitch(l2, x+70, y);
    s2.setValue(b2).setSize(60, 20).setFont(16);
    s1.addExclu(s2);
    s2.addExclu(s1);
    return this;
  }
  
  sDrawer addExclusiveSwitchs(String l1, String l2, String l3, int x, int y, sBoo b1, sBoo b2, sBoo b3) {
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
  
  sTextfield addTextfield(int _x, int _y) {
    sTextfield b = new sTextfield(cp5, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sExclusifSwitch addExclusifSwitch(String label, int _x, int _y) {
    sExclusifSwitch b = new sExclusifSwitch(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sSwitch addSwitch(String label, int _x, int _y) {
    sSwitch b = new sSwitch(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sIntModifier addIntModifier(String label, int _x, int _y) {
    sIntModifier b = new sIntModifier(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sFltModifier addFltModifier(String label, int _x, int _y) {
    sFltModifier b = new sFltModifier(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sButton addButton(String label, int _x, int _y) {
    sButton b = new sButton(cp5, label, _x+mx, _y+my);
    b.setPanel(panel);
    b.drawer = this;
    return b;
  }
  sLabel addText(String label, int _x, int _y) {
    sLabel l = new sLabel(cp5, label, _x+mx, _y+my);
    l.setPanel(panel);
    l.drawer = this;
    return l;
  }
  sDrawer addLine(int _x, int _y, int _l) {
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
          if (ival != null) ival.set(int(t.getText()));
          else if (fval != null) fval.set(float(t.getText()));
        } } )
      ;
  }
  
  sDrawer getDrawer() { return drawer; }
  
  sTextfield setValue(sFlt i) {
    this.addChannel(frame_chan);
    fval = i;
    ival = null;
    this.setText();
    return this;
  }
  sTextfield setValue(sInt i) {
    this.addChannel(frame_chan);
    ival = i;
    fval = null;
    this.setText();
    return this;
  }
  
  sTextfield setPanel(sPanel p) { t.setGroup(p.g); return this; }
  sTextfield setPos(int _x, int _y) { t.setPosition(_x, _y); return this; }
  sTextfield setSize(int _x, int _y) { t.setSize(_x, _y); return this; }
  sTextfield setFont(int s) { t.setFont(getFont(s)); return this; }
  
  void answer(Channel channel, float value) {
    if (fval != null && fval.has_changed) this.setText();
    if (ival != null && ival.has_changed) this.setText();
  }
  void setText() {
    if (ival != null) t.setText(str(ival.get()));
    else if (fval != null) t.setText(str(fval.get()));
    else t.setText("");
  }
  sTextfield setText(String s) { t.setText(s); return this; }
  String getText() { return t.getText(); }
}



enum sMode { INCREMENT, FACTOR }

class sIntModifier extends sButton {
  sInt val = null;
  float modifier = 0;
  sMode mode = sMode.INCREMENT;
  
  sIntModifier(ControlP5 cp5) { super(cp5); }
  sIntModifier(ControlP5 cp5, String label, int _x, int _y) { super(cp5, label, _x, _y); }
  
  sIntModifier setIncremental(float m) { mode = sMode.INCREMENT; modifier = m; return this; }
  sIntModifier setFactorial(float m) { mode = sMode.FACTOR; modifier = m; return this; }
  sIntModifier setMode(sMode _m, float f) { mode = _m; modifier = f; return this; }
  
  sIntModifier setValue(sInt v) {
    val = v;
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null)
          if (mode == sMode.INCREMENT)
            val.set(int(val.get()+modifier));
          else if (mode == sMode.FACTOR)
            val.set(int(val.get()*modifier));
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
  
  sFltModifier setIncremental(float m) { mode = sMode.INCREMENT; modifier = m; return this; }
  sFltModifier setFactorial(float m) { mode = sMode.FACTOR; modifier = m; return this; }
  sFltModifier setMode(sMode _m, float f) { mode = _m; modifier = f; return this; }
  sFltModifier setValue(sFlt v) {
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
  
  sExclusifSwitch setValue(sBoo v) {
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
  
  sExclusifSwitch addExclu(sExclusifSwitch s) { exclu.add(s); return this; }
  
  void answer(Channel chan, float v) {
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
  
  sSwitch setValue(sBoo v) {
    val = v;
    this.addChannel(frame_chan);
    if (val.get()) b.setOn();
    b.addListener(new ControlListener() {
      public void controlEvent(final ControlEvent ev) {  
        if (val != null) val.set(!val.get()); }
    });
    return this;
  }
  
  void answer(Channel chan, float v) {
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
  
  sDrawer getDrawer() { return drawer; }
  
  void init(ControlP5 cp5) {
    int id = get_free_id();
    b = cp5.addButton("button" + id)
       .setId(id);
    setText("");
    setPos(10, 10);
    setSize(100, 20);
    b.getCaptionLabel().setFont(getFont(18));
  }
  
  sButton addListener(ControlListener c) { b.addListener(c); return this; }
  
  sButton setPanel(sPanel p) { b.setGroup(p.g); return this; }
  sButton setText(String text) { b.getCaptionLabel().setText(text); return this; }
  sButton setPos(int _x, int _y) { b.setPosition(_x, _y); return this; }
  sButton setSize(int _x, int _y) { b.setSize(_x, _y); return this; }
  sButton setFont(int s) { b.getCaptionLabel().setFont(getFont(s)); return this; }
  
  void answer(Channel chan, float val) {}
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
  sDrawer getDrawer() { return drawer; }
  void answer(Channel channel, float value) {
    if (fval != null && fval.has_changed) this.print();
    if (ival != null && ival.has_changed) this.print();
  }
  void print() {
    if (ival != null) t.setText(text_start + str(ival.get()) + text_end);
    else if (fval != null) t.setText(text_start + str(fval.get()) + text_end);
    else t.setText(text_start + text_end);
  }
  sLabel setPanel(sPanel p) { t.setGroup(p.g); return this; }
  sLabel setValue(sFlt i) {
    this.addChannel(frame_chan);
    fval = i;
    ival = null;
    this.print();
    return this;
  }
  sLabel setValue(sInt i) {
    this.addChannel(frame_chan);
    ival = i;
    fval = null;
    this.print();
    return this;
  }
  sLabel setText(String _s) {
    text_start = _s; text_end = "";
    this.print();
    return this;
  }
  sLabel setText(String _s, String _e) {
    text_start = _s; text_end = _e;
    this.print();
    return this;
  }
  sLabel setPos(int _x, int _y) { t.setPosition(_x, _y); return this; }
  sLabel setColor(color c) { t.setColorValue(c); return this; }
  sLabel setFont(int s) { t.setFont(getFont(s)); text_font = s; return this; }
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
