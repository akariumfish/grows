

class GrowingControl extends Macro {
  InputF growI,sproutI,stopI,dieI;
  float grow,sprout,stop,die;
  
  GrowingControl(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    growI = createInputF("GROW", GROW_DIFFICULTY);
    grow = GROW_DIFFICULTY;
    sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
    sprout = SPROUT_DIFFICULTY;
    stopI = createInputF("STOP", STOP_DIFFICULTY);
    stop = STOP_DIFFICULTY;
    dieI = createInputF("DIE", DIE_DIFFICULTY);
    die = DIE_DIFFICULTY;
  }
  void clear() {
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("GrowingControl");
    file.append(str(grow));
    file.append(str(sprout));
    file.append(str(stop));
    file.append(str(die));
  }
  
  void drawing(float x, float y) {}
  
  void update() {
    float g = growI.get();
    float sp = sproutI.get();
    float st = stopI.get();
    float d = dieI.get();
    
    if (g != grow) {
      grow = g; GROW_DIFFICULTY = grow;
      update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
    else if (g != GROW_DIFFICULTY) {
      grow = GROW_DIFFICULTY; growI.set(grow); }
    
    if (sp != sprout) {
      sprout = sp; SPROUT_DIFFICULTY = sprout;
      update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
    else if (sp != SPROUT_DIFFICULTY) {
      sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
    if (st != stop) {
      stop = st; STOP_DIFFICULTY = stop;
      update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
    else if (st != STOP_DIFFICULTY) {
      stop = STOP_DIFFICULTY; stopI.set(stop); }
    
    if (d != die) {
      die = d; DIE_DIFFICULTY = die;
      update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
    else if (d != DIE_DIFFICULTY) {
      die = DIE_DIFFICULTY; dieI.set(die); }
    
    super.update();
    updated = true;
  }
}

class GrowingWatcher extends Macro {
  OutputF popO,growO;
  float pop,grow;
  
  GrowingWatcher(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("Watcher");
    g.setWidth(150);
    popO = createOutputF("      POP", 0);
    growO = createOutputF("  GROW", 0);
  }
  void clear() {
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("GrowWatcher");
    file.append(str(pop));
    file.append(str(grow));
  }
  
  void drawing(float x, float y) {}
  
  void update() {
    pop = baseNb(); grow = growsNb();
    popO.setBang(pop);
    growO.setBang(grow);
    super.update();
    updated = true;
  }
}

class Keyboard extends Macro {
  boolean w,c,a,p;
  OutputB wO,cO,aO,pO;
  
  Keyboard(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    w = false; c = false; a = false; p = false;
    g.setLabel("Key");
    g.setWidth(150);
    aO = createOutputB("          A");
    wO = createOutputB("          W");
    pO = createOutputB("          P");
    cO = createOutputB("          C");
  }
  void clear() {
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("Keyboard");
  }
  
  void update() {
    w = false; c = false; a = false; p = false;
    if (keysClick[4]) {w = true;}
    if (keysClick[5]) {c = true;}
    if (keysClick[7]) {a = true;}
    if (keysClick[8]) {p = true;}
    wO.set(w);
    cO.set(c);
    aO.set(a);
    pO.set(p);
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
  void clear() {
    txtf.remove();
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("macroVAL");
    file.append(str(value));
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
  void clear() {
    txtf.remove();
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("macroDELAY");
    file.append(str(count));
    file.append(str(actualCount));
    file.append(str(on));
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

class MacroCOMP extends Macro {
  OutputB out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  
  MacroCOMP(MacroList ml, int i_, int x_, int y_) {
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
         .addItem(">",1)
         .addItem("<",2)
         .addItem("=",3)
         ;
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem(">").setState(true);
  }
  void clear() {
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("macroCOMP");
  }

  void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      
      if (in1.bang()) {v1 = in1.get();}
      if (in2.bang()) {v2 = in2.get();}
      if (r1.getItem(">").getState())  
        if (v1 > v2) {out.bang();} else {out.unBang();}
      else if (r1.getItem("<").getState())  
        if (v1 < v2) {out.bang();} else {out.unBang();}
      else if (r1.getItem("=").getState())  
        if (v1 == v2) {out.bang();} else {out.unBang();}

      out.update();
      updated = true;
    }
  }
}

class MacroBOOL extends Macro {
  OutputB out;
  InputB in1,in2;
  
  RadioButton r1;
  
  MacroBOOL(MacroList ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("BOOL");
    in1 =  createInputB("   IN");
    in2 = createInputB("   IN");
    out = createOutputB("    OUT");
    
    r1 = cp5.addRadioButton("radioButton" + id)
         .setGroup(g)
         .setPosition(80,29)
         .setSize(15,15)
         .setItemsPerRow(3)
         .setSpacingColumn(40)
         .addItem("AND",1)
         .addItem("OR",2)
         .addItem("XOR",3)
         .addItem("NOT",4)
         ;
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("AND").setState(true);
  }
  void clear() {
    super.clear();
  }
  void to_strings() {
    super.to_strings();
    file.append("macroBOOL");
  }

  void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      if (r1.getItem("AND").getState())  
        if (in1.get() && in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("OR").getState()) 
        if (in1.get() || in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("XOR").getState()) 
        if (!(in1.get() == in2.get())) {out.bang();} else {out.unBang();}
      else if (r1.getItem("NOT").getState()) 
        if (!in1.get()) {out.bang();} else {out.unBang();}

      out.update();
      updated = true;
    }
  }
}
