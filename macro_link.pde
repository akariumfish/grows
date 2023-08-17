class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroList macroList;
  
  LinkList(MacroList m) {
    macroList = m;
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
  Group g;
  Button in;
  boolean bang = false;
  InputA(MacroList m, String s_, int id, Group g_, int n_) {
    macroList = m;
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
}

class InputB extends InputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);

  InputB(MacroList m, int id, Group g_, int i, String text, int n_) {
    super(m, "inB", id, g_, n_);
    cp5.addTextlabel("Ctrl" + str(i) + "inBText" + str(n))
                    .setText(text)
                    .setPosition(28, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
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
  InputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "inF", id, g_, n_);
    value = d;
    cp5.addTextlabel("Ctrl" + str(id) + "inFText" + str(n))
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
}

abstract class OutputA {
  MacroList macroList;
  boolean updated = false;
  int x = -100; int y = -100;
  int n = 0;
  Group g;
  Button out;
  boolean bang = false;

  OutputA(MacroList m, String s_, int id, Group g_, int n_) {
    g = g_;
    n = n_;
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
}

class OutputB extends OutputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);
  OutputB(MacroList m, int id, Group g_, int i, String text, int n_) {
    super(m, "outB", id, g_, n_);
    cp5.addTextlabel("Ctrl" + str(i) + "outBText" + str(n))
                    .setText(text)
                    .setPosition(g.getWidth() - 100, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
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
  boolean get() {
    return bang;
  }
  void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutB(this);}
    updated = true;
    x = int(g.getPosition()[0] + g.getWidth()); y = int(g.getPosition()[1] + 14 + (n*26));
    if (bang) {out.setOn();} else {out.setOff();}
  }
  void linkTo(InputB in) {
    LinkB nl = macroList.linkList.createLinkB();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
  }
}

class OutputF extends OutputA {
  ArrayList<LinkF> l = new ArrayList<LinkF>(0);
  float value;
  Textfield textf;
  OutputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "outF", id, g_, n_);
    value = d;
    cp5.addTextlabel("Ctrl" + str(i) + "outFText" + str(n_))
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
  void linkTo(InputF in) {
    LinkF nl = macroList.linkList.createLinkF();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
  }
}
