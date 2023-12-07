/*

objet macro extended de l'abstract pour les fonction de base

Basic Macro:
  bg : bang
  b ; bool
  i : int
  f : float
  n : number : i f
  v : value : b i f

  Pulse n > bg
  MacroDELAY n all > all
    show msg waiting
  MacroGATE b all > all
  
  MacroCOMP n n > b
  MacroBOOL b b > b
  MacroCALC n n > f
  MacroVAL bg v > v
  MacroKeyboard trig > bg state > b
  not b > b
  Switch b
  bang bg
  
  comment


*/

class Macro_Comment extends Macro_Abstract {
  nWidget field;
  Macro_Comment(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "com", x, y);
    addLine();
    field = new nWidget(_gui, - macro_size * 7 / 8, macro_size * 1 / 8, macro_size*8, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("")
      .setField(true)
      ;
    
    toLayerTop();
    setWidth(macro_size*8.5);
  }
  //void to_string(String[] s, int id) {
  //  super.to_string(s, id);
  //  id += super.size();
  //  s[id] = field.getText();
  //  log("value " + id + " " + s[id]);
  //}
  //void from_string(String[] s, int id) {
  //  super.from_string(s, id);
  //  id += super.size();
  //  field.setText(s[id]);
  //  log("value " + id + " " + s[id]);
  //}
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("value", field.getText());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    field.setText(bloc.getData("value"));
  }
  //int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    field.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    field.toLayerTop();
  }
}



class Macro_Value extends Macro_Abstract {
  Macro_Output out;
  Macro_Input in_bang,in_val;
  nWidget button,field;
  Macro_Packet pack;
  Macro_Value setBool() { 
    pack = newPacketBool(false); field.setField(false); 
    field.setTrigger(); field.setText("false"); 
    return this; }
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
      
    pack = newPacketFloat(0);
    
    field = new nWidget(_gui, macro_size / 8, macro_size * 10 / 8, macro_size*2, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        if (pack != null && pack.isFloat()) pack = newPacketFloat(field.getText());
        if (pack != null && pack.isInt()) pack = newPacketInt(int(float(field.getText())));
        if (pack == null) pack = newPacketFloat(field.getText());
      }})
      .addEventTrigger(new Runnable() { public void run() {
        if (pack != null && pack.isBool()) pack = newPacketBool(!pack.asBool());
        if (pack == null || (pack != null && !pack.isBool())) pack = newPacketBool(false);
        if (pack.asBool()) field.setText("true"); else field.setText("false");
      }})
      ;
    
    in_bang = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in_bang.getLastPacket().isBang()) send();
      }})
      .setFilterBang()
      ;
    in_val = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack = in_val.getLastPacket();
        if (pack.isFloat()) { field.setPassif(); field.setField(true); field.setText(trimStringFloat(pack.asFloat())); }
        if (pack.isInt()) { field.setPassif(); field.setField(true); field.setText(str(pack.asInt())); }
        if (pack.isBool() && pack.asBool()) { field.setField(false); field.setTrigger(); field.setText("true"); }
        if (pack.isBool() && !pack.asBool()) { field.setField(false); field.setTrigger(); field.setText("false"); }
      }})
      .setFilterValue()
      ;
    out = addExtOutput()
      .setDefVal();
    toLayerTop();
    setWidth(macro_size*3.5);
  }
  void send() {
    if (pack != null) out.send(pack);
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (pack == null) return;
    else if (pack.isFloat()) bloc.newData("f", pack.asFloat());
    else if (pack.isInt()) bloc.newData("i", pack.asFloat());
    else if (pack.isBool()) bloc.newData("b", pack.asFloat());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("f") != null) {
      pack = newPacketFloat(bloc.getFloat("f"));
      field.setText(str(bloc.getFloat("f"))); }
    if (bloc.getData("i") != null) {
      pack = newPacketInt(bloc.getInt("i"));
      field.setText(str(bloc.getInt("i"))); }
    if (bloc.getData("b") != null) {
      pack = newPacketBool(bloc.getBoolean("b"));
      if (pack.asBool()) field.setText("true"); 
      else field.setText("false"); }
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





class Macro_Keyboard extends Macro_Abstract {
  Macro_Output out_t,out_s;
  nWidget field;
  Tickable tick;
  Macro_Keyboard(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "key", x, y);
    setWidth(macro_size*4.5);
    field = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*3, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("a")
      .setField(true)
      ;
    out_t = addExtOutput()
      .setDefBang();
    out_s = addExtOutput()
      .setDefBool();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (kb.keyClick && field.getText().length() > 0 && field.getText().charAt(0) == key) out_t.send(newPacketBang());
        if (kb.keyButton && field.getText().length() > 0 && field.getText().charAt(0) == key) 
          out_s.send(newPacketBool(true));
        else out_s.send(newPacketBool(false));
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
    s[id] = field.getText();
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    field.setText(s[id]);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("value", field.getText());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    field.setText(bloc.getData("value"));
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void setLayer(int l) {
    super.setLayer(l);
    field.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
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
          field1.setText(str(f)); }
        if (pack.isInt()) {
          float f = pack.asInt();
          field1.setText(str(f)); }
      }})
      .setFilterNumber()
      ;
    addLine();
    in_val2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val2.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field2.setText(str(f)); }
        if (pack.isInt()) {
          float f = pack.asInt();
          field2.setText(str(f)); }
      }})
      .setFilterNumber()
      ;
    out = addExtOutput()
      .setDefBool();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        float f1 = float(field1.getText());
        float f2 = float(field2.getText());
        if      (modeEQ.isOn() && f1 == f2) out.send(newPacketBool(true));
        else if (modeSUP.isOn() && f1 > f2) out.send(newPacketBool(true));
        else if (modeINF.isOn() && f1 < f2) out.send(newPacketBool(true));
        else if (modeEQ.isOn() || modeSUP.isOn() || modeINF.isOn()) out.send(newPacketBool(false));
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("value1", field1.getText());
    bloc.newData("value2", field2.getText());
    bloc.newData("inf", modeINF.isOn());
    bloc.newData("sup", modeSUP.isOn());
    bloc.newData("eq", modeEQ.isOn());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    field1.setText(bloc.getData("value1"));
    field2.setText(bloc.getData("value2"));
    if (bloc.getBoolean("inf")) modeINF.setOn();
    if (bloc.getBoolean("sup")) modeSUP.setOn();
    if (bloc.getBoolean("eq")) modeEQ.setOn();
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
    
    field1 = new nWidget(_gui, macro_size / 8, macro_size * 1 / 8, macro_size*2.125, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText("0.0")
      .setField(true)
      ;
    field2 = new nWidget(_gui, macro_size / 8, macro_size * 19 / 8, macro_size*2.125, macro_size)
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
          field1.setText(str(f)); }
        if (pack.isInt()) {
          float f = pack.asInt();
          field1.setText(str(f)); }
      }})
      .setFilterNumber()
      ;
    addLine();
    in_val2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in_val2.getLastPacket();
        if (pack.isFloat()) {
          float f = pack.asFloat();
          field2.setText(str(f)); }
        if (pack.isInt()) {
          float f = pack.asInt();
          field2.setText(str(f)); }
      }})
      .setFilterNumber()
      ;
    out = addExtOutput()
      .setDefFloat();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        float f1 = float(field1.getText());
        float f2 = float(field2.getText());
        if (modeADD.isOn()) out.send(newPacketFloat(str(f1 + f2)));
        if (modeSUP.isOn()) out.send(newPacketFloat(str(f1 - f2)));
        if (modeMUL.isOn()) out.send(newPacketFloat(str(f1 * f2)));
        if (modeDIV.isOn() && f2 != 0) out.send(newPacketFloat(str(f1 / f2)));
      } }
      .setLayer(0)
      ;
    toLayerTop();
    setWidth(macro_size*3.625);
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("value1", field1.getText());
    bloc.newData("value2", field2.getText());
    bloc.newData("add", modeADD.isOn());
    bloc.newData("sup", modeSUP.isOn());
    bloc.newData("mul", modeMUL.isOn());
    bloc.newData("div", modeDIV.isOn());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    field1.setText(bloc.getData("value1"));
    field2.setText(bloc.getData("value2"));
    if (bloc.getBoolean("add")) modeADD.setOn();
    if (bloc.getBoolean("sup")) modeSUP.setOn();
    if (bloc.getBoolean("mul")) modeMUL.setOn();
    if (bloc.getBoolean("div")) modeDIV.setOn();
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
        getBase().askTick(); 
      }})
      ;
    out = addExtOutput()
      .setDefBang();
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
      .addEventSwitchOn(new Runnable() { public void run() { getBase().askTick(); } } )
      .addEventSwitchOff(new Runnable() { public void run() { getBase().askTick(); } } )
      ;
    out = addExtOutput()
      .setDefBool();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (button.isOn()) out.send(newPacketBool(true));
        else out.send(newPacketBool(false));
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("state", button.isOn());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getBoolean("state")) button.setOn();
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
  Macro_Input in_t;
  nWidget time_field;
  Tickable tick;
  int time = 20;
  int count = 0;
  Macro_Pulse(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "pulse", x, y);
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
        count = time;
      }})
      ;
    out = addExtOutput()
      .setDefBang();
    in_t = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in_t.getLastPacket().isInt()) time = in_t.getLastPacket().asInt();
        if (in_t.getLastPacket().isFloat()) time = int(in_t.getLastPacket().asFloat());
        if (in_t.getLastPacket().isInt() || in_t.getLastPacket().isFloat()) 
          { time_field.setText(str(time)); count = time; }
      }})
      .setFilterNumber()
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (count > 0) { 
          count--; 
          if (count == 0) { count = time; out.send(newPacketBang()); }
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("time", time);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    time = int(bloc.getInt("time"));
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
  Macro_Input in_m,in_t;
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
    in_m = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack = in_m.getLastPacket();
        count = time;
      }})
      ;
    in_t = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in_t.getLastPacket().isInt()) time = in_t.getLastPacket().asInt();
        if (in_t.getLastPacket().isFloat()) time = int(in_t.getLastPacket().asFloat());
        if (in_t.getLastPacket().isInt() || in_t.getLastPacket().isFloat()) 
          { time_field.setText(str(time)); count = 0; }
      }})
      .setFilterNumber()
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("time", time);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    time = int(bloc.getInt("time"));
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




class Macro_Gate extends Macro_Abstract {
  Macro_Input in_b, in_m;
  Macro_Output out;
  Tickable tick;
  Macro_Packet pack_b,pack_m;
  
  Macro_Gate(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "gate", x, y);
    setWidth(macro_size*5.5);
    out = addExtOutput();
    in_m = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack_m = in_m.getLastPacket();
      }})
      ;
    in_b = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack_b = in_b.getLastPacket();
      }})
      .setFilterBool()
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float time) {
        if (pack_b != null && pack_m != null && pack_b.isBool() && pack_b.asBool()) out.send(pack_m);
        pack_b = null; pack_m = null;
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
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
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
    
    out = addExtOutput()
      .setDefBool();
    in1 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack1 = in1.getLastPacket();
      }})
      .setFilterBool()
      ;
    in2 = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack2 = in2.getLastPacket();
      }})
      .setFilterBool()
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
    if (modeAND.isOn() && 
        pack1 != null && pack1.isBool() && 
        pack2 != null && pack2.isBool() ) {
      out.send(newPacketBool(pack1.asBool() && pack2.asBool())); }
    if (modeOR.isOn() &&  
        pack1 != null && pack1.isBool() && 
        pack2 != null && pack2.isBool() ) {
      out.send(newPacketBool(pack1.asBool() || pack2.asBool())); }
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
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    bloc.newData("and", modeAND.isOn());
    bloc.newData("or", modeOR.isOn());
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getBoolean("and")) modeAND.setOn();
    if (bloc.getBoolean("or")) modeOR.setOn();
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
  
  Macro_Not(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "not", x, y);
    
    out = addExtOutput()
      .setDefBool();
    in = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        Macro_Packet pack = in.getLastPacket();
        if (pack != null && pack.isBool()) { out.send(newPacketBool(!pack.asBool())); }
      }})
      .setFilterBool()
      ;
    toLayerTop();
    setWidth(macro_size*2.25);
  }
  void clear() {
    super.clear();
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
