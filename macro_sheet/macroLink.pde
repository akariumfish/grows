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
  
  LinkB createLinkB(MacroPlane p) {
    LinkB l = new LinkB(p);
    linkBList.add(l);
    return l;
  }

  LinkF createLinkF(MacroPlane p) {
    LinkF l = new LinkF(p);
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
    addChannel(frame_start_chan);
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
    addChannel(frame_start_chan);
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
    //update();
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
    LinkB nl = macroList.linkList.createLinkB(macroList);
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
    LinkF nl = macroList.linkList.createLinkF(macroList);
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}
