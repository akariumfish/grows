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
  
  MacroVAL addMacroVAL(float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, 300, 100 + (id * 100));
  }
  
  MacroDELAY addMacroDELAY(int v) {
    int id = macroList.size();
    return new MacroDELAY(this, v, id, 300, 100 + (id * 100));
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
    InputB in = mworld.macroList.createInputB(g, id, text, inCount);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }

  InputF createInputF(String text, float d) {
    InputF in = mworld.macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }
  
  OutputB createOutputB(String text) {
    OutputB out = mworld.macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }

  OutputF createOutputF(String text, float d) {
    OutputF out = mworld.macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }
  
}

class MacroVAL extends Macro {
  OutputF out;
  InputB in;
  InputF inV;
  float value;
  Textfield txtf;
  
  MacroVAL(MacroList ml, float v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    value = v_;
    g.setLabel("Value");
    in =  createInputB("IN");
    inV =  createInputF("  VAL",value);
    out = createOutputF("    OUT",v_);
    txtf = cp5.addTextfield("textVal" + str(id))
       .setLabel("")
       .setPosition(100,2)
       .setSize(70,22)
       .setAutoClear(false)
       .setGroup(g)
       .setText(str(value))
       ;
    txtf.getValueLabel().setFont(createFont("Arial",18));
  }

  void update() {
    super.update();
    if (in.getUpdate() && inV.getUpdate()) {
      value = float(txtf.getText());
      if (inV.bang()) {value = inV.get(); txtf.setText(str(value));}
      out.set(value);
      if (in.get()) {out.bang();} else {out.unBang();}
      out.update();
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
  
  MacroDELAY(MacroList ml, int v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    count = v_;
    g.setLabel("Delay");
    in =  createInputB("IN");
    out = createOutputB("    OUT");
    txtf = cp5.addTextfield("textDel" + str(id))
       .setLabel("")
       .setPosition(100,2)
       .setSize(70,22)
       .setAutoClear(false)
       .setGroup(g)
       .setText(str(count))
       ;
    txtf.getValueLabel().setFont(createFont("Arial",18));
  }

  void update() {
    super.update();
    count = int(txtf.getText());
    if (in.getUpdate()) {
      if (in.get()) {
        if (!on) {
          on = true;
          actualCount = count;
        }
      }
      if (on) {
        actualCount -= 1;
        if (actualCount <= 0) {
          on = false;
          out.set(true);
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

//class MacroPileF extends Macro {
//  OutputF out;
  
//  ArrayList<InputB> inL = new ArrayList<InputB>(0);
//  float[] frameState = new float[0];
  
//  int frameCounter = 0;
  
//  MacroPileF(MacroList ml) {super(ml); out = world.macroList.createOutputF();}
  
//  void printself() {
//    for (int i = 0; i < frameState.length; i++) {
//      println("frame " + i);
//      println(inL.get(i));
//      println(frameState[i]);
//    }
//  }
  
//  InputB addFrame(float value) {
//    InputB in = world.macroList.createInputB(false);
//    inL.add(in);
//    frameState = (float[]) append(frameState, value);
//    return in;
//  }

//  void update() {
//    boolean is = true;
//    for (InputB in : inL) {
//      is &= in.getUpdate();
//    }
//    if (is) {
//      if (frameState.length > 0) {
//        if (inL.get(frameCounter).get()) {
//          out.set(frameState[frameCounter]);
//          frameCounter +=1;
//        }
//        if (frameCounter == frameState.length) {
//          frameCounter = 0;
//        }
//      }
//      out.update();
//      updated = true;
//    }
//  }
  
//}

//class MacroEQUAL extends Macro {
//  OutputB out;
//  InputF in1,in2;
  
//  MacroEQUAL(MacroList ml, float v_) {
//    super(ml);
//    in1 =  world.macroList.createInputF(0);
//    in2 =  world.macroList.createInputF(0);
//    out = world.macroList.createOutputB();
//  }

//  void update() {
//    if (in1.getUpdate() && in2.getUpdate()) {
//      if (in1.get() == in2.get()) {out.set(true);} else {out.set(false);}
//      updated = true;
//    }
//  }
//}



//class MacroAND extends Macro {
//  OutputB out;
//  InputB in1,in2;
  
//  MacroAND(MacroList ml, float v_) {
//    super(ml);
//    in1 =  world.macroList.createInputB(false);
//    in2 =  world.macroList.createInputB(false);
//    out = world.macroList.createOutputB();
//  }

//  void update() {
//    if (in1.getUpdate() && in2.getUpdate()) {
//      if (in1.get() && in2.get()) {out.set(true);} else {out.set(false);}
//      updated = true;
//    }
//  }
//}
