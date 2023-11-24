/*

objet macro extended de l'abstract pour les fonction de base






Basic Macro:
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



class Macro_Value extends Macro_Abstract {
  Macro_Output out;
  Macro_Input in_bang,in_val;
  nWidget button,field;
  Macro_Value(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "value", x, y);
    button = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*2, macro_size)
      .setTrigger()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      .addEventTrigger(new Runnable() { public void run() {
        send();
      }})
      ;
    
    field = new nWidget(_gui, macro_size / 8, macro_size * 10 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0")
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        String s = field.getText();
      }})
      ;
    
    in_bang = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in_bang.getLastPacket().isBang()) send();
      }})
      ;
    in_val = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field.setText(str(f));
        }
      }})
      ;
    out = addExtOutput();
    toLayerTop();
    setWidth(macro_size*3.5);
  }
  void send() {
    out.send(newFloat(field.getText()));
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = field.getText();
    log("value " + id + " " + s[id]);
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    field.setText(s[id]);
    log("value " + id + " " + s[id]);
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    button.setLayer(l);
    field.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    button.toLayerTop();
    field.toLayerTop();
  }
}



class Macro_Comp extends Macro_Abstract {
  Macro_Output out;
  Macro_Input in_val1,in_val2;
  nWidget field1,field2,modeSUP,modeINF,modeEQ;
  Tickable tick;
  Macro_Comp(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "comp", x, y);
    modeSUP = new nWidget(_gui, ">", int(macro_size/1.5), - macro_size, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeINF = new nWidget(_gui, "<", int(macro_size/1.5), macro_size / 8, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      .addExclude(modeSUP)
      ;
    modeSUP.addExclude(modeINF);
    modeEQ = new nWidget(_gui, "=", int(macro_size/1.5), macro_size / 4 + macro_size, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    
    field1 = new nWidget(_gui, macro_size / 8, macro_size * 1 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      ;
    field2 = new nWidget(_gui, macro_size / 8, macro_size * 19 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      ;
    
    
    in_val1 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val1.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field1.setText(str(f));
        }
      }})
      ;
    addLine();
    in_val2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val2.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field2.setText(str(f));
        }
      }})
      ;
    out = addExtOutput();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        float f1 = float(field1.getText());
        float f2 = float(field2.getText());
        if (modeEQ.isOn() && f1 == f2) out.send(newBang());
        if (modeSUP.isOn() && f1 > f2) out.send(newBang());
        if (modeINF.isOn() && f1 < f2) out.send(newBang());
      } }
      .setLayer(0)
      ;
    toLayerTop();
    setWidth(macro_size*3.5);
  }
  
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = field1.getText();
    s[id+1] = field2.getText();
    if (modeINF.isOn()) s[id+2] = "1"; else s[id+2] = "0";
    if (modeSUP.isOn()) s[id+3] = "1"; else s[id+3] = "0";
    if (modeEQ.isOn()) s[id+4] = "1"; else s[id+4] = "0";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    field1.setText(s[id]);
    field2.setText(s[id+1]);
    if (s[id+2].equals("1")) modeINF.setOn();
    if (s[id+3].equals("1")) modeSUP.setOn();
    if (s[id+4].equals("1")) modeEQ.setOn();
    
  }
  int size() { return 5 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    field1.setLayer(l);
    field2.setLayer(l);
    modeINF.setLayer(l);
    modeSUP.setLayer(l);
    modeEQ.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    field1.toLayerTop();
    field2.toLayerTop();
    modeINF.toLayerTop();
    modeSUP.toLayerTop();
    modeEQ.toLayerTop();
  }
}



class Macro_Calc extends Macro_Abstract {
  Macro_Output out;
  Macro_Input in_val1,in_val2;
  nWidget field1,field2,modeADD,modeSUP,modeMUL,modeDIV;
  Tickable tick;
  Macro_Calc(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "calc", x, y);
    modeADD = new nWidget(_gui, "+", int(macro_size/1.3), - macro_size, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeSUP = new nWidget(_gui, "-", int(macro_size/1.3), macro_size / 8, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeMUL = new nWidget(_gui, "X", int(macro_size/1.5), macro_size / 4 + macro_size, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeDIV = new nWidget(_gui, "/", int(macro_size/1.5), macro_size * 3 / 8 + 2 * macro_size, macro_size * 10 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeADD.addExclude(modeSUP).addExclude(modeMUL).addExclude(modeDIV);
    modeSUP.addExclude(modeADD).addExclude(modeMUL).addExclude(modeDIV);
    modeMUL.addExclude(modeSUP).addExclude(modeADD).addExclude(modeDIV);
    modeDIV.addExclude(modeSUP).addExclude(modeMUL).addExclude(modeADD);
    
    field1 = new nWidget(_gui, macro_size / 8, macro_size * 1 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      ;
    field2 = new nWidget(_gui, macro_size / 8, macro_size * 19 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      ;
    
    
    in_val1 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val1.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field1.setText(str(f));
        }
      }})
      ;
    addLine();
    in_val2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val2.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field2.setText(str(f));
        }
      }})
      ;
    out = addExtOutput();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        float f1 = float(field1.getText());
        float f2 = float(field2.getText());
        if (modeADD.isOn()) out.send(newFloat(str(f1 + f2)));
        if (modeSUP.isOn()) out.send(newFloat(str(f1 - f2)));
        if (modeMUL.isOn()) out.send(newFloat(str(f1 * f2)));
        if (modeDIV.isOn() && f2 != 0) out.send(newFloat(str(f1 / f2)));
      } }
      .setLayer(0)
      ;
    toLayerTop();
    setWidth(macro_size*3.5);
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = field1.getText();
    s[id+1] = field2.getText();
    if (modeADD.isOn()) s[id+2] = "1"; else s[id+2] = "0";
    if (modeSUP.isOn()) s[id+3] = "1"; else s[id+3] = "0";
    if (modeMUL.isOn()) s[id+4] = "1"; else s[id+4] = "0";
    if (modeDIV.isOn()) s[id+5] = "1"; else s[id+5] = "0";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    field1.setText(s[id]);
    field2.setText(s[id+1]);
    if (s[id+2].equals("1")) modeADD.setOn();
    if (s[id+3].equals("1")) modeSUP.setOn();
    if (s[id+4].equals("1")) modeMUL.setOn();
    if (s[id+5].equals("1")) modeDIV.setOn();
    
  }
  int size() { return 6 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    field1.setLayer(l);
    field2.setLayer(l);
    modeADD.setLayer(l);
    modeSUP.setLayer(l);
    modeMUL.setLayer(l);
    modeDIV.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    field1.toLayerTop();
    field2.toLayerTop();
    modeADD.toLayerTop();
    modeSUP.toLayerTop();
    modeMUL.toLayerTop();
    modeDIV.toLayerTop();
  }
}




class Macro_Bang extends Macro_Abstract {
  Macro_Output out;
  nWidget button;
  Macro_Bang(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "bang", x, y);
    button = new nWidget(_gui, macro_size / 4, macro_size / 8, macro_size*2, macro_size)
      .setTrigger()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      .addEventTrigger(new Runnable() { public void run() {
        out.send(new Macro_Packet("bang"));
      }})
      ;
    out = addExtOutput();
    toLayerTop();
    setWidth(macro_size*3.5);
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = "bang";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    button.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    button.toLayerTop();
  }
}



class Macro_Switch extends Macro_Abstract {
  Macro_Output out;
  nWidget button;
  Tickable tick;
  Macro_Switch(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "switch", x, y);
    setWidth(macro_size*3.5);
    button = new nWidget(_gui, macro_size / 4, macro_size / 8, macro_size*2, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    out = addExtOutput();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (button.isOn()) out.send(new Macro_Packet("bang"));
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    if (button.isOn()) s[id] = "1"; else s[id] = "0";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    if (s[id].equals("1")) button.setOn();
  }
  
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    button.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    button.toLayerTop();
  }
}




class Macro_Pulse extends Macro_Abstract {
  Macro_Output out;
  nWidget time_field;
  Tickable tick;
  int time = 20;
  int count = 0;
  Macro_Pulse(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "pulse", x, y);
    setWidth(macro_size*4.5);
    time_field = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*3, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText(str(time))
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        String s = time_field.getText();
        
        time = max(1, int(s));
        count = time;
      }})
      ;
    out = addExtOutput();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (count > 0) { 
          count--; 
          if (count == 0) { count = time; out.send(new Macro_Packet("bang")); }
        }
      } }
      .setLayer(0)
      ;
    count = time;
    toLayerTop();
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = str(time);
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    time = int(s[id]);
    time_field.setText(str(time));
    count = time;
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    time_field.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    time_field.toLayerTop();
  }
}




class Macro_Delay extends Macro_Abstract {
  Macro_Input in;
  Macro_Output out;
  nWidget time_field;
  Tickable tick;
  Macro_Packet pack;
  int time = 1;
  int count = 0;
  
  Macro_Delay(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "delay", x, y);
    setWidth(macro_size*5.5);
    time_field = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*3, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText(str(time))
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        String s = time_field.getText();
        time = max(1, int(s));
        count = 0;
      }})
      ;
    out = addExtOutput();
    in = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack = in.getLastPacket();
        count = time;
      }})
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float time) {
        if (count > 0) { count--; if (count == 0) out.send(pack); }
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = str(time);
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    time = int(s[id]);
    time_field.setText(str(time));
    count = 0;
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    time_field.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    time_field.toLayerTop();
  }
}




class Macro_Bool extends Macro_Abstract {
  Macro_Input in1,in2;
  Macro_Output out;
  Tickable tick;
  Macro_Packet pack1 = null, pack2 = null;
  nWidget modeAND,modeOR;
  
  Macro_Bool(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "bool", x, y);
    modeAND = new nWidget(_gui, "&&", int(macro_size/1.5), macro_size / 8, macro_size * 5 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      ;
    modeOR = new nWidget(_gui, "||", int(macro_size/1.5), macro_size / 4 + macro_size, macro_size * 5 / 8, macro_size, macro_size)
      .setSwitch()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      .addExclude(modeAND)
      ;
    modeAND.addExclude(modeOR);
    
    out = addExtOutput();
    in1 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack1 = in1.getLastPacket();
      }})
      ;
    in2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack2 = in2.getLastPacket();
      }})
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float time) {
        test();
        pack1 = null; pack2 = null;
      } }
      .setLayer(0)
      ;
    toLayerTop();
    setWidth(macro_size*3.625);
    outputs_ref.setPY(macro_size * 4 / 8);
  }
  void test() {
    if (modeAND.isOn() && pack1 != null && pack1.isBang() && pack2 != null && pack2.isBang() ) {
      out.send(newBang()); }
    if (modeOR.isOn() && ((pack1 != null && pack1.isBang()) || (pack2 != null && pack2.isBang())) ) {
      out.send(newBang()); }
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    if (modeAND.isOn()) s[id] = "1"; else s[id] = "0";
    if (modeOR.isOn()) s[id+1] = "1"; else s[id+1] = "0";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    if (s[id].equals("1")) modeAND.setOn();
    if (s[id+1].equals("1")) modeOR.setOn();
  }
  int size() { return 2 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    modeAND.setLayer(l);
    modeOR.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    modeAND.toLayerTop();
    modeOR.toLayerTop();
  }
}

class Macro_Not extends Macro_Abstract {
  Macro_Input in;
  Macro_Output out;
  Tickable tick;
  Macro_Packet pack = null;
  
  Macro_Not(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "not", x, y);
    
    out = addExtOutput();
    in = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack = in.getLastPacket();
      }})
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float time) {
        test();
        pack = null;
      } }
      .setLayer(0)
      ;
    toLayerTop();
    setWidth(macro_size*2);
  }
  void test() {
    if (pack == null || !pack.isBang()) { out.send(newBang()); }
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
  }
  int size() { return 0 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
  }
}
