

MacroList mList;

Keyboard keyb;
GrowingControl gcC;
GrowingWatcher gwC;

MacroVAL mv1,mv2;

void init_macro() {
  mList = new MacroList();
  //mList.addGrowingParam(1400, 50);
  //mList.addGrowingActive(1400, 230);
  //mList.addGrowingControl(1400, 500);
  mList.addGrowingWatcher(50, 250);
  mList.addKeyboard(50, 50);
  mList.addSimControl(60, 400);
  mList.addGrowingPop(50, 550);
  mList.addPulse(300, 550);
  
  mList.addMacroVAL(20, height - 80, 0);
  mList.addMacroVAL(360, height - 80, 0);
  mList.addMacroVAL(700, height - 80, 0);
  mList.addMacroVAL(1040, height - 80, 0);
  mList.addMacroVAL(1380, height - 80, 0);
  mList.addMacroVAL(20, height - 180, 0);
  mList.addMacroVAL(360, height - 180, 0);
  mList.addMacroVAL(700, height - 180, 0);
  mList.addMacroCALC(1040, height - 180);
  mList.addMacroCALC(1380, height - 180);
  mList.addMacroCOMP(20, height - 280);
  mList.addMacroCOMP(360, height - 280);
  mList.addMacroBOOL(700, height - 280);
  mList.addMacroBOOL(1040, height - 280);
  mList.addMacroDELAY(1380, height - 280, 10);
  
  //gcC = mList.addGrowingControl(800, 50);
  //gwC = mList.addGrowingWatcher(50, 400);
  //keyb = mList.addKeyboard(50, 50);
  
  //mv1 = mList.addMacroVAL(300, 50, 0.16);
  //mv2 = mList.addMacroVAL(300, 200, 0.833);
  
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
  
  Keyboard addKeyboard(int _x, int _y) {
    int id = macroList.size();
    return new Keyboard(this, id, _x, _y);
  }
  
  Pulse addPulse(int _x, int _y) {
    int id = macroList.size();
    return new Pulse(this, id, _x, _y);
  }
  
  SimControl addSimControl(int _x, int _y) {
    int id = macroList.size();
    return new SimControl(this, id, _x, _y);
  }
  
  GrowingPop addGrowingPop(int _x, int _y) {
    int id = macroList.size();
    return new GrowingPop(this, id, _x, _y);
  }
  
  GrowingParam addGrowingParam(int _x, int _y) {
    int id = macroList.size();
    return new GrowingParam(this, id, _x, _y);
  }
  
  GrowingControl addGrowingControl(int _x, int _y) {
    int id = macroList.size();
    return new GrowingControl(this, id, _x, _y);
  }
  
  GrowingActive addGrowingActive(int _x, int _y) {
    int id = macroList.size();
    return new GrowingActive(this, id, _x, _y);
  }
  
  GrowingWatcher addGrowingWatcher(int _x, int _y) {
    int id = macroList.size();
    return new GrowingWatcher(this, id, _x, _y);
  }
  
  MacroVAL addMacroVAL(int _x, int _y, float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, _x, _y);
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
  MacroList macroList;
  boolean updated = false;
  Group g;
  int id; int x,y; float mx = 0; float my = 0;
  int inCount = 0;
  int outCount = 0;
  
  Macro(MacroList ml, int i_, int x_, int y_) {
    ml.addMacro(this);
    macroList = ml;
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
  void clear() {
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
  
  void update() {
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
    return in;
  }

  InputF createInputF(String text, float d) {
    InputF in = macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }
  
  OutputB createOutputB(String text) {
    OutputB out = macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }

  OutputF createOutputF(String text, float d) {
    OutputF out = macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }
}
