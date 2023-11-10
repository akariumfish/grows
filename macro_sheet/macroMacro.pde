







/*

Basic Macro:    deja fait.
  Pulse
  MacroVAL
  MacroDELAY
  MacroCOMP
  MacroBOOL
  MacroCALC

nouvel objet macro, on peut y ajouté des entré/sortie customizable

MACROCustom
  addConnexion

Macro Custom Connexions:
  >MCListen(Channel) outB value
  >MCCall(Channel) inB value
  
  >MCsValueWatcher(sFlt) outF value
  >MCsValueWatcher(sBoo) outB value
  >MCsValueController(sFlt) inF value      BEUG!!!!
  >MCsValueController(sBoo) inB value
  
  >MCRun( code ) inB bang
  >MCKeyboard(key) outB bang
  
  MCsValueModifier(sFlt)
    inB bang, inF value, select : 'x' / '/' / '+' / '-'
  
*/


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
  //MCRun addMCRun() { return new MCRun(this); }
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
    addChannel(frame_start_chan);
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
    addChannel(frame_start_chan);
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



//class MCRun extends MCConnexion {
//  InputB in;
//  ArrayList<Runnable> runs = new ArrayList<Runnable>();
  
//  MCRun(MacroCUSTOM m) { super(m);
//    in =  macro.createInputB("Run"); }
  
//  MCRun setText(String s) { in.t.setText(s); return this; }
//  MCRun addRunnable(Runnable r) { runs.add(r); return this; }
  
//  void tick() { if (in.getUpdate() && in.get()) for (Runnable r : runs) r.run(); }
//}

////#############    RUNNABLE    #############
//abstract class Runnable { public abstract void run(); }



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
    //if (b.isPressed() && !flag) { flag = true; v = true; sim.next_tick = true; }
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
      //flag = true; sim.next_tick = true; if (!out.get()) out.set(true); else out.set(false);
    }
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
    //cnt = int(sim.tick.get());
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
        //turn = int(sim.tick.get()) + m;
        freq = m;
      }
    }
    //if (sim.tick.get() < cnt) turn = freq;
    //cnt = int(sim.tick.get());
    //if (sim.tick.get() >= turn) {
    //  out.set(true);
    //  turn += freq;
    //} else out.set(false);
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
    if (in.getUpdate()) {
      if (!in.get()) {out.bang();} else {out.unBang();}
      updated = true;
    }
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






















//#######################################################################
//##                           OLD MACRO                               ##
//#######################################################################


//class Keyboard extends Macro {
//  boolean w,c,a,p;
//  OutputB wO,cO,aO,pO;
  
//  Keyboard(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    w = false; c = false; a = false; p = false;
//    g.setLabel("Key");
//    g.setWidth(150);
//    aO = createOutputB("          A");
//    wO = createOutputB("          W");
//    pO = createOutputB("          P");
//    cO = createOutputB("          C");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("Keyboard");
//  //}
  
//  void update() {
//    w = false; c = false; a = false; p = false;
//    if (keysClick[4]) {w = true;}
//    if (keysClick[5]) {c = true;}
//    if (keysClick[7]) {a = true;}
//    if (keysClick[8]) {p = true;}
//    wO.set(w);
//    cO.set(c);
//    aO.set(a);
//    pO.set(p);
//    super.update();
//    updated = true;
//  }
  
//  void drawing(float x, float y) {}
//}

//class GrowingPop extends Macro {
//  InputB addI;
//  InputB add2I;
  
//  GrowingPop(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("ADD");
//    g.setWidth(200);
//    addI = createInputB("grower");
//    add2I = createInputB("floc");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingPop");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (addI.getUpdate() && add2I.getUpdate()) {
//      if (addI.get()) {
//        if (!gcom.adding_type.get()) 
//        for (int j = 0; j < gcom.initial_entity.get(); j++)
//          gcom.initialEntity();
//        if (gcom.adding_type.get()) gcom.adding_pile = gcom.initial_entity.get();
//      }
//      if (add2I.get()) {
//        if (!fcom.adding_type.get()) 
//        for (int j = 0; j < fcom.initial_entity.get(); j++)
//          fcom.initialEntity();
//        if (fcom.adding_type.get()) fcom.adding_pile = fcom.initial_entity.get();
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}

//class GrowingParam extends Macro {
//  InputF growI,sproutI,stopI,dieI,ageI;
//  float grow,sprout,stop,die,age;
  
//  GrowingParam(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    //growI = createInputF("GROW", GROW_DIFFICULTY);
//    //grow = GROW_DIFFICULTY;
//    //sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
//    //sprout = SPROUT_DIFFICULTY;
//    //stopI = createInputF("STOP", STOP_DIFFICULTY);
//    //stop = STOP_DIFFICULTY;
//    //dieI = createInputF("DIE", DIE_DIFFICULTY);
//    //die = DIE_DIFFICULTY;
//    //ageI = createInputF("AGE", OLD_AGE);
//    //age = OLD_AGE;
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingControl");
//  //  file.append(str(grow));
//  //  file.append(str(sprout));
//  //  file.append(str(stop));
//  //  file.append(str(die));
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    //float g = growI.get();
//    //float sp = sproutI.get();
//    //float st = stopI.get();
//    //float d = dieI.get();
//    //float a = ageI.get();
    
//    //if (g != grow) {
//    //  grow = g; GROW_DIFFICULTY = grow;
//    //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
//    //else if (g != GROW_DIFFICULTY) {
//    //  grow = GROW_DIFFICULTY; growI.set(grow); }
    
//    //if (sp != sprout) {
//    //  sprout = sp; SPROUT_DIFFICULTY = sprout;
//    //  update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
//    //else if (sp != SPROUT_DIFFICULTY) {
//    //  sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
//    //if (st != stop) {
//    //  stop = st; STOP_DIFFICULTY = stop;
//    //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
//    //else if (st != STOP_DIFFICULTY) {
//    //  stop = STOP_DIFFICULTY; stopI.set(stop); }
    
//    //if (d != die) {
//    //  die = d; DIE_DIFFICULTY = die;
//    //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
//    //else if (d != DIE_DIFFICULTY) {
//    //  die = DIE_DIFFICULTY; dieI.set(die); }
      
//    //if (a != age) {
//    //  age = a; OLD_AGE = (int)age;
//    //  update_textlabel("AGING", " at ", OLD_AGE);
//    //}
//    //else if (a != OLD_AGE) {
//    //  age = OLD_AGE; ageI.set(age); }
    
//    super.update();
//    updated = true;
//  }
//}

//class GrowingActive extends Macro {
//  InputB growI,sproutI,stopI,dieI,growoffI,sproutoffI,stopoffI,dieoffI;
  
//  GrowingActive(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    growI = createInputB("GROW ON");
//    sproutI = createInputB("SPROUT ON");
//    stopI = createInputB("STOP ON");
//    dieI = createInputB("DIE ON");
//    growoffI = createInputB("GROW OFF");
//    sproutoffI = createInputB("SPROUT OFF");
//    stopoffI = createInputB("STOP OFF");
//    dieoffI = createInputB("DIE OFF");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingActiv");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    //if (growI.getUpdate() && sproutI.getUpdate() && stopI.getUpdate() && dieI.getUpdate() && 
//    //    growoffI.getUpdate() && sproutoffI.getUpdate() && stopoffI.getUpdate() && dieoffI.getUpdate() ) {
//    //  if (growI.get()   && !ON_GROW)   bGrow.setOn();
//    //  if (sproutI.get() && !ON_SPROUT) bSprout.setOn();
//    //  if (stopI.get()   && !ON_STOP)   bStop.setOn();
//    //  if (dieI.get()    && !ON_DIE)    bDie.setOn();
//    //  if (growoffI.get()   && ON_GROW)   bGrow.setOff();
//    //  if (sproutoffI.get() && ON_SPROUT) bSprout.setOff();
//    //  if (stopoffI.get()   && ON_STOP)   bStop.setOff();
//    //  if (dieoffI.get()    && ON_DIE)    bDie.setOff();
//    //}
//    super.update();
//    updated = true;
//  }
//}

//class GrowingControl extends Macro {
//  InputB in;
  
//  RadioButton r1, r2, r3;
  
//  GrowingControl(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("GROW");
//    g.setWidth(200);
//    in = createInputB("");
//    g.setSize(g.getWidth(), 28 + (inCount*28));
    
//    r1 = cp5.addRadioButton("radioButton1" + id)
//         .setGroup(g)
//         .setPosition(20,6)
//         .setSize(15,15)
//         .setItemsPerRow(1)
//         .setSpacingRow(8)
//         .addItem("x" + id,1)
//         .addItem("/" + id,2)
//         ;
         
//     r2 = cp5.addRadioButton("radioButton2" + id)
//         .setGroup(g)
//         .setPosition(55,6)
//         .setSize(15,15)
//         .setItemsPerRow(1)
//         .setSpacingRow(8)
//         .addItem("1.2" + id,1)
//         .addItem("2" + id,2)
//         ;
     
//     r3 = cp5.addRadioButton("radioButton3" + id)
//         .setGroup(g)
//         .setPosition(100,6)
//         .setSize(15,15)
//         .setItemsPerRow(2)
//         .setSpacingRow(8)
//         .setSpacingColumn(35)
//         .addItem("GROW" + id,1)
//         .addItem("BLOOM" + id,2)
//         .addItem("STOP" + id,3)
//         .addItem("DIE" + id,4)
//         ;
     
//     r1.getItem("x" + id).getCaptionLabel().setText("x");
//     r1.getItem("/" + id).getCaptionLabel().setText("/");
//     r2.getItem("1.2" + id).getCaptionLabel().setText("1.2");
//     r2.getItem("2" + id).getCaptionLabel().setText("2");
//     r3.getItem("GROW" + id).getCaptionLabel().setText("GROW");
//     r3.getItem("BLOOM" + id).getCaptionLabel().setText("BLOOM");
//     r3.getItem("STOP" + id).getCaptionLabel().setText("STOP");
//     r3.getItem("DIE" + id).getCaptionLabel().setText("DIE");
     
//     for(Toggle t:r1.getItems())
//       t.getCaptionLabel().setFont(createFont("Arial",16));
//     r1.getItem("x" + id).setState(true);
//     for(Toggle t:r2.getItems())
//       t.getCaptionLabel().setFont(createFont("Arial",16));
//     r2.getItem("2" + id).setState(true);
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowingActiv");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (in.getUpdate()) {
//      float m = 0;
//      if (r2.getItem("1.2" + id).getState()) m = 1.2;
//      else if (r2.getItem("2" + id).getState()) m = 2;
//      if (r1.getItem("/" + id).getState()) m = 1 / m;
//      if (in.get()) {
//        //if (r3.getItem("GROW" + id).getState()) {
//        //  GROW_DIFFICULTY *= m;
//        //  update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
//        //if (r3.getItem("BLOOM" + id).getState()) {
//        //  SPROUT_DIFFICULTY *= m;
//        //  update_textlabel("SPROUT", " = r^", SPROUT_DIFFICULTY); }
//        //if (r3.getItem("STOP" + id).getState()) {
//        //  STOP_DIFFICULTY *= m;
//        //  update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
//        //if (r3.getItem("DIE" + id).getState()) {
//        //  DIE_DIFFICULTY *= m;
//        //  update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}

//class GrowingWatcher extends Macro {
//  OutputF popO,growO,turnO;
//  float pop,grow,turn;
  
//  GrowingWatcher(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("Watcher");
//    g.setWidth(150);
//    popO = createOutputF("      POP", 0);
//    growO = createOutputF("  GROW", 0);
//    turnO = createOutputF("  turn", 0);
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("GrowWatcher");
//  //  file.append(str(pop));
//  //  file.append(str(grow));
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    int p = gcom.active_Entity_Nb();
//    int g = gcom.grower_Nb();
//    popO.set(p);
//    growO.set(g);
//    turnO.set(sim.tick.get());
//    if (pop != p) popO.bang();
//    if (grow != g) growO.bang();
//    if (turn != sim.tick.get()) turnO.bang();
//    pop = p; grow = g; turn = sim.tick.get();
//    super.update();
//    updated = true;
//  }
//}

//class SimControl extends Macro {
//  InputB inR,inRng,inP;
  
//  SimControl(MacroList l_, int i_, int x_, int y_) {
//    super(l_, i_, x_, y_);
//    g.setLabel("SIMULATION");
//    g.setWidth(150);
//    inR = createInputB("RESET");
//    inRng = createInputB("RNG");
//    inP = createInputB("PAUSE");
//  }
//  void clear() {
//    super.clear();
//  }
//  //void to_strings() {
//  //  super.to_strings();
//  //  file.append("Sim Control");
//  //}
  
//  void drawing(float x, float y) {}
  
//  void update() {
//    if (inR.getUpdate() && inRng.getUpdate() && inP.getUpdate()) {
//      if (inR.get()) sim.reset();
//      if (inRng.get()) {
//        sim.SEED.set(int(random(1000000000)));
//        sim.reset();
//      }
//      if (inP.get()) {
//        sim.pause.set(!sim.pause.get());
//      }
//    }
//    super.update();
//    updated = true;
//  }
//}
