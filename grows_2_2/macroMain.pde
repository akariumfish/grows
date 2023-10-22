



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
      .addText("BASIC MACRO :", 0, 0, 18)
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
  
  void answer(Channel channel, float value) {
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
  
  void update() {}
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
