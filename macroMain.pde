

MacroList mList;

Keyboard keyb;
//GrowingControl gcC;
//GrowingWatcher gwC;

MacroVAL mv1,mv2;

void init_macro() {
  mList = new MacroList();
  //gcC = mList.addGrowingControl(800, 50);
  //gwC = mList.addGrowingWatcher(50, 400);
  keyb = mList.addKeyboard(50, 50);
  
  mv1 = mList.addMacroVAL(300, 50, 0.16);
  mv2 = mList.addMacroVAL(300, 200, 0.833);
  
  keyb.wO.linkTo(mv1.in);
  keyb.aO.linkTo(mv2.in);
  
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
  
  void to_strings() {
    file.append("macros:");
    for (Macro m : macroList)
      m.to_strings();
    file.append("in/out:");
    for (InputB m : inBList)
      m.to_strings();
    for (InputF m : inFList)
      m.to_strings();
    for (OutputB m : outBList)
      m.to_strings();
    for (OutputF m : outFList)
      m.to_strings();
    file.append("links:");
    linkList.to_strings();
  }
  
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
  
  //GrowingControl addGrowingControl(int _x, int _y) {
  //  int id = macroList.size();
  //  return new GrowingControl(this, id, _x, _y);
  //}
  
  //GrowingWatcher addGrowingWatcher(int _x, int _y) {
  //  int id = macroList.size();
  //  return new GrowingWatcher(this, id, _x, _y);
  //}
  
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
  void to_strings() {
    file.append("macro");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(inCount));
    file.append(str(outCount));
  }
  
  void update() {
    if (cp5.getTab("Macros").isActive()) {
      if (g.isMouseOver() && mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        GRAB = false; //deactive le deplacement camera
      }
      if (g.isMouseOver() && mouseUClick[0]) {
        GRAB = true;
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

class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroList macroList;
  
  LinkList(MacroList m) {
    macroList = m;
  }
  
  void clear() {
    linkBList.clear();
    linkFList.clear();
  }
  
  void to_strings() {
    for (LinkB m : linkBList)
      m.to_strings();
    for (LinkF m : linkFList)
      m.to_strings();
  }
  
  LinkB createLinkB() {
    LinkB l = new LinkB(macroList);
    linkBList.add(l);
    return l;
  }

  LinkF createLinkF() {
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
  void to_strings() {
    if (this != macroList.NOTB) {
      file.append("linkB");
      file.append(str(in.id));
      file.append(str(out.id));
    }
  }
  boolean collision(int x, int y) {
    if (this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  void drawing() {
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
  void to_strings() {
    if (this != macroList.NOTF) {
      file.append("linkF");
      file.append(str(in.id));
      file.append(str(out.id));
    }
  }
  boolean collision(int x, int y) {
    if (this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  void drawing() {
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
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 12 + (n*26));
  }
  void clear() {
    in.remove();
    g.remove();
  }
  void to_strings() {
    file.append("input");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(n));
  }
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
  void clear() {
    t.remove();
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("B");
  }
  boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
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
       .lock()
       .setGroup(g)
       .setFocus(true)
       .setText(str(value))
       .setFocus(false);
       ;
    textf.getValueLabel().setFont(createFont("Arial",18));
  }
  void clear() {
    textf.remove();
    t.remove();
    super.clear();
  }
  boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkF) {macroList.addLinkSelectInF(this);}
    x = int(g.getPosition()[0]); y = int(g.getPosition()[1] + 14 + (n*26));
    bang = false;
    for (LinkF f : l) {
      if (!f.out.updated) {return false;}
    }
    for (LinkF f : l) {
      bang |= f.out.bang;
      if (f.out.bang) {value = f.out.value;}
    }
    if (bang) {in.setOn(); textf.setFocus(true); textf.setText(str(value)); textf.setFocus(false);} else {in.setOff();}
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
  void to_strings() {
    super.to_strings();
    file.append("F");
    file.append(str(value));
  }
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
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 14 + (n*26));
  }
  
  void clear() {
    g.remove();
    out.remove();
  }
  void to_strings() {
    file.append("output");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(n));
  }
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
  void clear() {
    t.remove();
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("B");
  }
  void set(boolean v) {
    bang = v;
    if (bang) {
      for (LinkB b : l) {
        b.in.bang = bang;
      }
    }
    update();
  }
  void bang() { set(true); }
  void unBang() { set(false); }
  boolean get() {
    return bang;
  }
  void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutB(this);}
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
  void clear() {
    t.remove();
    textf.remove();
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("F");
    file.append(str(value));
  }
  void set(float v) {
    value = v;
  }
  void setBang(float v) {
    if (value != v) { value = v; bang(); return; }
    value = v;
  }
  void unBang() {bang = false;}
  void bang() {
    bang = true;
    for (LinkF f : l) {
      f.in.bang = true;
    }
    update();
  }
  float get() {return value;}
  void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutF(this);}
    updated = true;
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 12 + (n*26));
    if (value < 0.000001) {value = 0;}
    if (bang) {out.setOn(); textf.setFocus(true); textf.setText(str(value).trim()); textf.setFocus(false);} else {out.setOff();}
    //bang = false;
  }
  OutputF linkTo(InputF in) {
    LinkF nl = macroList.linkList.createLinkF();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}
