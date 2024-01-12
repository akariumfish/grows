



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
  
  void clear() {
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
  
  void drawing() {
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
  
  void answer(Channel channel, float value) { //tick chan
    update();
  }
  
  void update() {
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
  
  void frame() {
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
  
  void addLinkSelectOutB(OutputB out) {
    creatingLinkB = true;
    selectOutB = out;
  }
  
  void addLinkSelectInB(InputB in) {
    creatingLinkB = false;
    selectOutB.linkTo(in);
  }
  
  void addLinkSelectOutF(OutputF out) {
    creatingLinkF = true;
    selectOutF = out;
  }
  
  void addLinkSelectInF(InputF in) {
    creatingLinkF = false;
    selectOutF.linkTo(in);
  }
  
  MacroPulse addMacroPulse(int _x, int _y) {
    int id = macroList.size();
    return new MacroPulse(this, id, _x, _y);
  }
  
  MacroKey addMacroKey(int _x, int _y) {
    int id = macroList.size();
    return new MacroKey(this, id, _x, _y);
  }
  
  MacroBang addMacroBang(int _x, int _y) {
    int id = macroList.size();
    return new MacroBang(this, id, _x, _y);
  }
  
  MacroToggle addMacroToggle(int _x, int _y) {
    int id = macroList.size();
    return new MacroToggle(this, id, _x, _y);
  }
  
  MacroVAL addMacroVAL(int _x, int _y, float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, _x, _y);
  }
  
  MacroNOT addMacroNOT(int _x, int _y) {
    int id = macroList.size();
    return new MacroNOT(this, id, _x, _y);
  }
  
  MacroCOMP addMacroCOMP(int _x, int _y) {
    int id = macroList.size();
    return new MacroCOMP(this, id, _x, _y);
  }
  
  MacroBOOL addMacroBOOL(int _x, int _y) {
    int id = macroList.size();
    return new MacroBOOL(this, id, _x, _y);
  }
  
  MacroCALC addMacroCALC(int _x, int _y) {
    int id = macroList.size();
    return new MacroCALC(this, id, _x, _y);
  }
  
  MacroDELAY addMacroDELAY(int _x, int _y, int v) {
    int id = macroList.size();
    return new MacroDELAY(this, v, id, _x, _y);
  }
  
  Macro addMacro(Macro m) {
    macroList.add(m);
    return m;
  }
  
  InputB createInputB(Group g, int i, String text, int n) {
    int id = inBList.size();
    InputB o = new InputB(this, id, g, i, text, n);
    inBList.add(o);
    return o;
  }

  InputF createInputF(Group g, int i, String text, int n, float d) {
    int id = inFList.size();
    InputF o = new InputF(this, id, g, i, text, n, d);
    inFList.add(o);
    return o;
  }
  
  OutputB createOutputB(Group g, int i, String text, int n) {
    int id = outBList.size();
    OutputB o = new OutputB(this, id, g, i, text, n);
    outBList.add(o);
    return o;
  }
  
  OutputF createOutputF(Group g, int i, String text, int n, float d_) {
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
  void clear() {
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
  
  void update() {} //tick
  void custom_frame() {}
  
  void frame() {
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
        x = int(mouseX + mx); y = int(mouseY + my);
        g.setPosition(mouseX + mx,mouseY + my);
      }
    }
  }
  
  InputB createInputB(String text) {
    InputB in = macroList.createInputB(g, id, text, inCount);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    linB.add(in);
    return in;
  }

  InputF createInputF(String text, float d) {
    InputF in = macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    linF.add(in);
    inCount +=1;
    return in;
  }
  
  OutputB createOutputB(String text) {
    OutputB out = macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    loutB.add(out);
    outCount +=1;
    return out;
  }

  OutputF createOutputF(String text, float d) {
    OutputF out = macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    loutF.add(out);
    outCount +=1;
    return out;
  }
}

class MacroCUSTOM extends Macro {
  ArrayList<MCConnexion> connexions = new ArrayList<MCConnexion>();
  
  MacroCUSTOM(MacroPlane l_) {
    super(l_, l_.macroList.size(), l_.adding_pos, l_.adding_pos);
    g.setLabel("custom");
    g.setWidth(300);
  }
  
  MacroCUSTOM setWidth(int w) { g.setWidth(w); return this; }
  MacroCUSTOM setLabel(String s) { g.setLabel(s); return this; }
  MacroCUSTOM setPos(int x, int y) { g.setPosition(x, y); return this; }
  MacroCUSTOM align() { inCount = max(inCount, outCount); outCount = max(inCount, outCount); return this; }
  
  MCCall addMCCall() { return new MCCall(this); }
  MCListen addMCListen() { return new MCListen(this); }
  MCRun addMCRun() { return new MCRun(this); }
  MCsBooWatcher addMCsBooWatcher() { return new MCsBooWatcher(this); }
  MCsFltWatcher addMCsFltWatcher() { return new MCsFltWatcher(this); }
  MCsIntWatcher addMCsIntWatcher() { return new MCsIntWatcher(this); }
  MCsBooControl addMCsBooControl() { return new MCsBooControl(this); }
  MCsFltControl addMCsFltControl() { return new MCsFltControl(this); }
  MCsIntControl addMCsIntControl() { return new MCsIntControl(this); }
  
  void update() { //tick
    super.update();
    for (MCConnexion c : connexions) c.tick();
    updated = true;
  }
  
  void drawing(float x, float y) {}
  void clear() { super.clear(); }
  //void to_strings() { super.to_strings(); file.append(""); }
}

abstract class MCConnexion extends Callable {
  MacroCUSTOM macro;
  MCConnexion(MacroCUSTOM m) {
    macro = m; macro.connexions.add(this); }
  MacroCUSTOM getMacro() { return macro; }
  abstract void tick();
  abstract MCConnexion setText(String s);
  void answer(Channel c, float f) {}
}



class MCsFltControl extends MCConnexion {
  InputF in;
  sFlt flt;
  
  MCsFltControl(MacroCUSTOM m) { super(m);
    in =  macro.createInputF("CtrlF", 0); }
  
  MCsFltControl setText(String s) { in.t.setText(s); return this; }
  MCsFltControl setValue(sFlt b) { flt = b; in.set(flt.get()); return this; }
  
  void tick() {
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
  
  MCsIntControl setText(String s) { in.t.setText(s); return this; }
  MCsIntControl setValue(sInt b) { i = b; in.set(i.get()); return this; }
  
  void tick() {
    if (in.getUpdate()) {
      if (in.bang()) {
        //print("b" + flt.get() + " ");
        i.set(int(in.get()));  // add other combinateur
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
  
  MCsBooControl setText(String s) { in.t.setText(s); return this; }
  MCsBooControl setValue(sBoo b) { boo = b;; return this; }
  
  void tick() {
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
  
  MCsFltWatcher setText(String s) { out.t.setText(s); return this; }
  
  MCsFltWatcher addValue(sFlt f) {
    flt = f;
    v = f.get();
    out.setBang(v);
    return this; }
  void answer(Channel c, float f) { out.set(flt.get()); out.update(); }
  void tick() {
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
  
  MCsIntWatcher setText(String s) { out.t.setText(s); return this; }
  
  MCsIntWatcher addValue(sInt f) {
    i = f;
    v = f.get();
    out.setBang(v);
    return this; }
  void answer(Channel c, float f) { out.set(i.get()); out.update(); }
  void tick() {
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
  
  MCsBooWatcher setText(String s) { out.t.setText(s); return this; }
  
  MCsBooWatcher addValue(sBoo b) {
    boo = b;
    v = boo.get();
    return this; }
  void tick() {
    out.set(boo.get());
    v = boo.get(); }
}



class MCRun extends MCConnexion {
  InputB in;
  ArrayList<Runnable> runs = new ArrayList<Runnable>();
  
  MCRun(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("Run"); }
  
  MCRun setText(String s) { in.t.setText(s); return this; }
  MCRun addRunnable(Runnable r) { runs.add(r); return this; }
  
  void tick() { if (in.getUpdate() && in.get()) for (Runnable r : runs) r.run(); }
}

//#############    RUNNABLE    #############
abstract class Runnable { public abstract void run(); }



class MCListen extends MCConnexion {
  OutputB out;
  boolean v = false;
  
  MCListen(MacroCUSTOM m) { super(m);
    out =  macro.createOutputB("listen"); }
    
  MCListen setText(String s) { out.t.setText(s); return this; }
  
  MCListen listenTo(Channel chan) {
    new Callable(chan) { public void answer(Channel channel, float value) { v = true; }};
    return this; }
  void tick() {
    if (v) out.set(true); else out.set(false);
    v = false; }
}



class MCCall extends MCConnexion {
  InputB in;
  ArrayList<Channel> chans = new ArrayList<Channel>();
  
  MCCall(MacroCUSTOM m) { super(m);
    in =  macro.createInputB("call"); }
  
  MCCall setText(String s) { in.t.setText(s); return this; }
  MCCall callTo(Channel chan) { chans.add(chan); return this; }
  void tick() { if (in.getUpdate() && in.get()) for (Channel c : chans) callChannel(c); }
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
  void clear() { super.clear(); }
  MacroKey setChar(char _c) { c = _c; g.setLabel("key " + c); return this; }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  void custom_frame() {
    String s = txtf.getText();
    if (s.length() == 1) {
      setChar(s.charAt(0));
    }
    if (kb.getClick(c)) b = true; }
  void update() {
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
  void clear() { super.clear(); }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  void custom_frame() {
    if (b.isPressed() && !flag) { flag = true; v = true; sim.next_tick = true; }
    if (!b.isPressed()) { flag = false; } }
  void update() {
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
  void clear() { super.clear(); }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  void custom_frame() {
    if (b.isPressed() && !flag) {
      flag = true; sim.next_tick = true; if (!out.get()) out.set(true); else out.set(false); }
    if (!b.isPressed()) { flag = false; } }
  void update() {
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
    cnt = int(sim.tick.get());
  }
  void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("pulse");
  //}
  
  void update() {
    if (in.getUpdate()) {
      int m = int(in.get());
      if (m != freq) {
        turn = int(sim.tick.get()) + m;
        freq = m;
      }
    }
    if (sim.tick.get() < cnt) turn = freq;
    cnt = int(sim.tick.get());
    if (sim.tick.get() >= turn) {
      out.set(true);
      turn += freq;
    } else out.set(false);
    super.update();
    updated = true;
  }
  
  void drawing(float x, float y) {}
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
  void clear() {
    //txtf.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroVAL");
  //  file.append(str(value));
  //}

  void update() {
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
  void clear() {
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
  void update() {
    super.update();
    count = int(txtf.getText());
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
  void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroCOMP");
  //}

  void update() {
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
  void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroBOOL");
  //}

  void update() {
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
  void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroBOOL");
  //}

  void update() {
    super.update();
    if (in.getUpdate()) { updated = true; }
    if (!in.get()) {out.bang();} else {out.unBang();}
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
  void clear() {
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("macroCALC");
  //}

  void update() {
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

class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroPlane macroList;
  
  LinkList(MacroPlane m) {
    macroList = m;
  }
  
  void clear() {
    linkBList.clear();
    linkFList.clear();
  }
  
  //void to_strings() {
  //  for (LinkB m : linkBList)
  //    m.to_strings();
  //  for (LinkF m : linkFList)
  //    m.to_strings();
  //}
  
  LinkB createLinkB() {
    LinkB l = new LinkB(plane);
    linkBList.add(l);
    return l;
  }

  LinkF createLinkF() {
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
  boolean collision(int x, int y) {
    if (macroList != null && this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  void drawing() {
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
  boolean collision(int x, int y) {
    if (macroList != null && this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  void drawing() {
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
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 12 + (n*26));
    addChannel(frame_chan);
  }
  void clear() {
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
  void clear() {
    for (LinkB t : l) macroList.linkList.linkBList.remove(t);
    t.remove();
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("B");
  //}
  void answer(Channel chan, float v) {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 14 + (n*26));
    
  }
  boolean getUpdate() {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 14 + (n*26));
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
  boolean get() {
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
            value = float(textf.getText());
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
  void clear() {
    textf.remove();
    t.remove();
    for (LinkF t : l) macroList.linkList.linkFList.remove(t);
    super.clear();
  }
  void answer(Channel chan, float v) {
    if (in.isMouseOver() && kb.mouseClick[0] && macroList.creatingLinkF) {macroList.addLinkSelectInF(this);}
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 14 + (n*26));
  }
  boolean getUpdate() {
    
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
    if (!bang && float(textf.getText()) != value) {
      value = float(textf.getText());
      bang = true;
    }
    if (bang) {in.setOn();} else {in.setOff();}
    
    return true;
  }
  boolean bang() {
    return bang;
  }
  float get() {
    float d = value;
    getUpdate();
    return d;
  }
  void set(float d) {
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
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 14 + (n*26));
    addChannel(frame_chan);
  }
  
  void clear() {
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
  void clear() {
    t.remove();
    for (LinkB t : l) macroList.linkList.linkBList.remove(t);
    super.clear();
  }
  //void to_strings() {
  //  super.to_strings();
  //  file.append("B");
  //}
  void set(boolean v) {
    bang = v;
    if (bang) {
      for (LinkB b : l) {
        b.in.bang = bang;
      }
    }
    if (bang) {out.setOn();} else {out.setOff();}
  }
  void bang() { set(true); }
  void unBang() { set(false); }
  boolean get() {
    return bang;
  }
  void answer(Channel chan, float v) {
    if (out.isMouseOver() && kb.mouseClick[0]) {macroList.addLinkSelectOutB(this);}
    updated = true;
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 14 + (n*26));
    if (bang) {out.setOn();} else {out.setOff();}
  }
  OutputB linkTo(InputB in) {
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
  void clear() {
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
  void set(float v) {
    value = v;
  }
  void setBang(float v) {
    if (value != v) { value = v; bang(); return; }
    value = v;
  }
  void unBang() { bang = false; update(); }
  void bang() {
    bang = true;
    for (LinkF f : l) {
      f.in.bang = true;
    }
    update();
  }
  float get() {return value;}
  void answer(Channel chan, float v) {
    if (out.isMouseOver() && kb.mouseClick[0]) {macroList.addLinkSelectOutF(this);}
    updated = true;
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 12 + (n*26));
    //bang = false;
    update();
  }
  void update() {
    //if (value < 0.000001) {value = 0;}
    if (bang) {out.setOn(); textf.setFocus(true); textf.setText(str(value).trim()); textf.setFocus(false);} else {out.setOff();}
  }
  OutputF linkTo(InputF in) {
    LinkF nl = macroList.linkList.createLinkF();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}
