import controlP5.*; //la lib pour les menu

class sPanel extends Callable {
  int PANEL_WIDTH = 400;
  int PANEL_MARGIN = 10;
  int drawer_height = 0;
  sDrawer last_drawer = null;
  float mx = 0; float my = 0;
  Group g;
  
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
    g.setPosition(x, y)
        .setSize(PANEL_WIDTH, 0)
        .setBackgroundHeight(0)
        .setBackgroundColor(color(60, 200))
        .disableCollapse()
        .getCaptionLabel().setText("");
        
    this.addChannel(frame_chan);
  }
  
  //void adjustHeight(int newobjectmax) {
  //  if (newobjectmax + PANEL_MARGIN > PANEL_HEIGHT) {
  //    PANEL_HEIGHT = newobjectmax + PANEL_MARGIN;
  //    g.setBackgroundHeight(PANEL_HEIGHT);
  //  }
  //}
  
  void answer(Channel channel, float value) {
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
      }
    }
  }
  
  sDrawer addDrawer(int h) { return new sDrawer(this, h); }
  sDrawer lastDrawer() { return last_drawer; }
  
  sPanel addRngTryCtrl(String title, RandomTryParam p) {
    addFltController(title, p.DIFFICULTY).lastDrawer()
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
  sPanel addIntController(String label, sInt i) {
    addDrawer(30)
      .addIntModifier("-10", 0, 0)
        .setIncremental(-10)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier("-1", 40, 0)
        .setIncremental(-1)
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
      .addIntModifier("+1", 310, 0)
        .setIncremental(1)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addIntModifier("+10", 350, 0)
        .setIncremental(10)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      ;
    return this;
  }
  sPanel addFltController(String label, sFlt i) {
    addDrawer(30)
      .addFltModifier("/2", 0, 0)
        .setFactorial(0.5)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier("/1.2", 40, 0)
        .setFactorial(0.833)
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
      .addFltModifier("x1.2", 310, 0)
        .setFactorial(1.2)
        .setValue(i)
        .setSize(30, 30)
        .setFont(16)
      .getDrawer()
      .addFltModifier("x2", 350, 0)
        .setFactorial(2)
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
  
  sTextfield addTextfield(int _x, int _y) {
    sTextfield b = new sTextfield(cp5, _x+mx, _y+my);
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
  int modifier = 0;
  sMode mode = sMode.INCREMENT;
  
  sIntModifier(ControlP5 cp5) { super(cp5); }
  sIntModifier(ControlP5 cp5, String label, int _x, int _y) { super(cp5, label, _x, _y); }
  
  sIntModifier setIncremental(int m) { mode = sMode.INCREMENT; modifier = m; return this; }
  sIntModifier setFactorial(int m) { mode = sMode.FACTOR; modifier = m; return this; }
  sIntModifier setMode(sMode _m, int f) { mode = _m; modifier = f; return this; }
  
  sIntModifier setValue(sInt v) {
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





class sFltModifier extends sButton {
  sFlt val = null;
  float modifier = 0;
  sMode mode = sMode.INCREMENT;
  
  sFltModifier(ControlP5 cp5) { super(cp5); }
  sFltModifier(ControlP5 cp5, String label, int _x, int _y) { super(cp5, label, _x, _y); }
  
  sFltModifier setIncremental(float m) { mode = sMode.INCREMENT; modifier = m; return this; }
  sFltModifier setFactorial(float m) { mode = sMode.FACTOR; modifier = m; return this; }
  sFltModifier setMode(sMode _m, int f) { mode = _m; modifier = f; return this; }
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
