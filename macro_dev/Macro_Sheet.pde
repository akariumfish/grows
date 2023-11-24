


/*

extend l'objet macro abstract

menu de creation de nouvelle macro a l'interieur
  == dans sont plan de connection interne
  sheet
  bang
  switch
  delay
  pulse
  
  todo:
  bool val comp calc
  
peut ce cree des interconnections entre sont plan et le plan du parent 

peut etre reduit cachant sont plan interne 

background englobe automatiquement sont plan 

*/


class Macro_Sheet extends Macro_Abstract {
  nWidget reduc,menu,addSheet,addExtIn,addExtOut,
    addBang,addSwitch,addDelay,addPulse,addBool,addValue,addComp,addCalc,addNot;
  
  ArrayList<Macro_Input> extconnectinputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> extconnectoutputs = new ArrayList<Macro_Output>(0);
  
  boolean isReduc = false;
  void reduc() {
    isReduc = true;
    menu.hide();
    closer.show();
    for (Macro_Abstract m : child_macro) m.hide();
    for (Macro_Input m : extconnectinputs) m.hide();
    for (Macro_Output m : extconnectoutputs) m.hide();
  }
  void enlarg() {
    isReduc = false;
    for (Macro_Abstract m : child_macro) m.show();
    for (Macro_Input m : extconnectinputs) m.show();
    for (Macro_Output m : extconnectoutputs) m.show();
    menu.show();
    addSheet.hide();
  }
  
  Macro_Sheet(nGUI _gui, Macro_Abstract p, float x, float y) {
    super(_gui, p, "sheet", x, y);
    setWidth(macro_size*1.75);
    
    back.setSize(macro_size*3, macro_size * 0.75);
    closer.setSX(macro_size);
    grabber.setText("");
    
    reduc = new nWidget(_gui, "-", int(macro_size/1.5), 0, 0, macro_size, macro_size * 0.75)
      .setTrigger()
      .setParent(grabber)
      .setLayer(layer)
      .stackRight()
      .addEventTrigger(new Runnable() { public void run() {
        if (isReduc) enlarg(); else reduc();
        childDragged();
      }})
      ;
    menu = new nWidget(_gui, "+", int(macro_size), 0, 0, macro_size, macro_size * 0.75)
      .setSwitch()
      .setParent(reduc)
      .setLayer(layer)
      .stackRight()
      .addEventSwitchOn(new Runnable() { public void run() {
        addSheet.show();
      }})
      .addEventSwitchOff(new Runnable() { public void run() {
        addSheet.hide();
      }})
      ;
    closer.setParent(menu);
    addSheet = new nWidget(_gui, "Sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(menu)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addSheet();
        childDragged();
      }})
      ;
    addExtIn = new nWidget(_gui, "Input", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addSheet)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable(this) { public void run() {
        menu.setOff();
        Macro_Output o = new Macro_Output(gui, (Macro_Abstract)builder, macro_size, inCount * macro_size * 1.25 + macro_size / 8 )
          .setParent(inputs_ref)
          .setLayer(layer+2)
          ;
        extconnectoutputs.add(o);
        Macro_Input i = addExtInput();
        i.direct_connect(o);
        childDragged();
      }})
      ;
    addExtOut = new nWidget(_gui, "Output", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addExtIn)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable(this) { public void run() {
        menu.setOff();
        Macro_Input i = new Macro_Input(gui, (Macro_Abstract)builder, -macro_size, outCount * macro_size * 1.25 + macro_size / 8 )
          .setParent(outputs_ref)
          .setLayer(layer+2)
          ;
        extconnectinputs.add(i);
        Macro_Output o = addExtOutput();
        i.direct_connect(o);
        childDragged();
      }})
      ;
    addBang = new nWidget(_gui, "Bang", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addExtOut)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addBang();
        childDragged();
      }})
      ;
    addSwitch = new nWidget(_gui, "Switch", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addBang)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addSwitch();
        childDragged();
      }})
      ;
    addDelay = new nWidget(_gui, "Delay", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addSwitch)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addDelay();
        childDragged();
      }})
      ;
    addPulse = new nWidget(_gui, "Pulse", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addDelay)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addPulse();
        childDragged();
      }})
      ;
    addBool = new nWidget(_gui, "Bool", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addPulse)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addBool();
        childDragged();
      }})
      ;
    
    addValue = new nWidget(_gui, "Value", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addBool)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addValue();
        childDragged();
      }})
      ;
    addComp = new nWidget(_gui, "Comp", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addValue)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addComp();
        childDragged();
      }})
      ;
    addCalc = new nWidget(_gui, "Calc", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addComp)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addCalc();
        childDragged();
      }})
      ;
    addNot = new nWidget(_gui, "Not", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addCalc)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addNot();
        childDragged();
      }})
      ;
    //back.toLayerTop();
    childDragged();
  }
  void setLayer(int l) {
    super.setLayer(l);
    reduc.setLayer(l);
    menu.setLayer(l);
    addSheet.setLayer(getBase().menu_layer);
    addExtIn.setLayer(getBase().menu_layer);
    addExtOut.setLayer(getBase().menu_layer);
    addBang.setLayer(getBase().menu_layer);
    addDelay.setLayer(getBase().menu_layer);
    addPulse.setLayer(getBase().menu_layer);
    addBool.setLayer(getBase().menu_layer);
    addSwitch.setLayer(getBase().menu_layer);
    
    addNot.setLayer(getBase().menu_layer);
    addValue.setLayer(getBase().menu_layer);
    addComp.setLayer(getBase().menu_layer);
    addCalc.setLayer(getBase().menu_layer);
  }
  void toLayerTop() {
    super.toLayerTop();
    reduc.toLayerTop();
    menu.toLayerTop();
    addSheet.toLayerTop();
    addExtIn.toLayerTop();
    addExtOut.toLayerTop();
    addBang.toLayerTop();
    addDelay.toLayerTop();
    addPulse.toLayerTop();
    addBool.toLayerTop();
    addSwitch.toLayerTop();
    addNot.toLayerTop();
    
    addValue.toLayerTop();
    addComp.toLayerTop();
    addCalc.toLayerTop();
  }
  void to_string(String[] s, int id) {
    log("to string sheet ");
    super.to_string(s, id);
    id += super.size();
    if (isReduc) s[id] = "1"; else s[id] = "0";
    log("reducted " + id + " " + s[id]);
    id++;
    s[id] = str(child_macro.size());
    log("childs nb " + id + " " + s[id]);
    id++;
    for (Macro_Abstract v : child_macro) {
      v.to_string(s, id);
      id += v.size();
    }
    int l = 0;
    for (Macro_Input o : extinputs) l++;
    s[id] = str(l);
    log("extin nb " + id + " " + s[id]);
    id++;
    l = 0;
    for (Macro_Output o : extoutputs) l++;
    s[id] = str(l);
    log("extout nb " + id + " " + s[id]);
    id++;
    l = 0;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) l++;
    s[id] = str(l);
    log("link nb " + id + " " + s[id]);
    id++;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
      s[id] = str(o.index); s[id+1] = str(i.index); 
      log("link " + id + " " + s[id] + " " + s[id+1]);
      id +=2;
    }
    log("end to string sheet");
  }
  void from_string(String[] s, int id) {
    log("from string sheet ");
    int start_id = id;
    int abs_size = int(s[id+1]);
    id += abs_size;
    if (s[id].equals("1")) isReduc = true;
    log("reduc " + id + " " + isReduc);
    id++;
    int l = int(s[id]);
    log("child nb " + id + " " + s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Abstract m = null;
      log("child type " + id + " " + s[id]);
      if      (s[id].equals("bang"))  m = new Macro_Bang(gui, this, 0, 0);
      else if (s[id].equals("switch")) m = new Macro_Switch(gui, this, 0, 0);
      else if (s[id].equals("delay")) m = new Macro_Delay(gui, this, 0, 0);
      else if (s[id].equals("pulse")) m = new Macro_Pulse(gui, this, 0, 0);
      else if (s[id].equals("value")) m = new Macro_Value(gui, this, 0, 0);
      else if (s[id].equals("bool"))  m = new Macro_Bool(gui, this, 0, 0);
      else if (s[id].equals("not"))  m = new Macro_Not(gui, this, 0, 0);
      else if (s[id].equals("comp"))  m = new Macro_Comp(gui, this, 0, 0);
      else if (s[id].equals("calc"))  m = new Macro_Calc(gui, this, 0, 0);
      else if (s[id].equals("sheet")) m = new Macro_Sheet(gui, this, 0, 0);
      m.setLayer(layer+2);
      m.toLayerTop();
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    log("ext in connect nb " + id + " " + s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Output o = new Macro_Output(gui, this, macro_size, inCount * macro_size * 1.25 + macro_size / 8 )
        .setParent(inputs_ref)
        .setLayer(layer+2)
        ;
      addExtInput().direct_connect(o);
      extconnectoutputs.add(o);
      childDragged();
    }
    l = int(s[id]);
    log("ext out connect nb " + id + " " + s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Input in = new Macro_Input(gui, this, -macro_size, outCount * macro_size * 1.25 + macro_size / 8 )
        .setParent(outputs_ref)
        .setLayer(layer+2)
        ;
      Macro_Output o = addExtOutput();
      in.direct_connect(o);
      extconnectinputs.add(in);
      childDragged();
    }
    super.from_string(s, start_id);
    l = int(s[id]);
    log("link nb " + id + " " + s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      log("link " + id + " " + s[id] + " " + s[id+1]);
      getOutputByIndex(int(s[id])).connect_to(getInputByIndex(int(s[id+1])));
      id+=2;
    }
    if (isReduc) reduc();
    childDragged();
    log("end from string sheet");
  }
  int size() {
    int vnb = super.size() + 5;
    for (Macro_Abstract v : child_macro) vnb += v.size();
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) vnb+=2;
    return vnb;
  }
  void clear() {
    super.clear();
    reduc.clear(); menu.clear(); addSheet.clear(); addExtIn.clear(); addExtOut.clear(); 
    addBang.clear();
    
    
    
    
    //todo
    
    
  }
  void childDragged() {
    float minx = 0, miny = 0, maxx = macro_size*4, maxy = macro_size*0.75;
    if (isReduc) maxx = macro_size*3;
    for (Macro_Abstract m : child_macro) if (!m.isHided) {
      if (minx > m.grabber.getLocalX() + m.back.getLocalX()) 
        minx = m.grabber.getLocalX() + m.back.getLocalX();
      if (miny > m.grabber.getLocalY() + m.back.getLocalY()) 
        miny = m.grabber.getLocalY() + m.back.getLocalY();
      if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.getW()) 
        maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.getW();
      if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.getH()) 
        maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.getH();
    }
    if (maxy < max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75)
      maxy = max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75;
    if (isReduc) {
      back.setPosition(minx - macro_size, miny - macro_size);
      back.setSize(maxx - minx + macro_size*2, maxy - miny + macro_size*2);
      inputs_ref.setPX(minx - macro_size*2);
      outputs_ref.setPX(maxx - macro_size*2);
    } else if (inCount > 0 || outCount > 0) {
      back.setPosition(minx - macro_size*2, miny - macro_size);
      back.setSize(maxx - minx + macro_size*4, maxy - miny + macro_size*2);
      inputs_ref.setPX(minx - macro_size*3);
      outputs_ref.setPX(maxx - macro_size*2);
    } else {
      back.setPosition(minx - macro_size, miny - macro_size);
      back.setSize(maxx - minx + macro_size*2, maxy - miny + macro_size*2);
      inputs_ref.setPX(minx - macro_size*2);
      outputs_ref.setPX(maxx - macro_size*3);
    }
    if (parent != null) parent.childDragged();
  }
  
  float add_pos = macro_size;
  
  Macro_Sheet addSheet() {
    Macro_Sheet m = new Macro_Sheet(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Delay addDelay() {
    Macro_Delay m = new Macro_Delay(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Bang addBang() {
    Macro_Bang m = new Macro_Bang(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Switch addSwitch() {
    Macro_Switch m = new Macro_Switch(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Pulse addPulse() {
    Macro_Pulse m = new Macro_Pulse(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Bool addBool() {
    Macro_Bool m = new Macro_Bool(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Value addValue() {
    Macro_Value m = new Macro_Value(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Comp addComp() {
    Macro_Comp m = new Macro_Comp(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Calc addCalc() {
    Macro_Calc m = new Macro_Calc(gui, this, 0, 0);
    adding(m); return m; }
  Macro_Not addNot() {
    Macro_Not m = new Macro_Not(gui, this, 0, 0);
    adding(m); return m; }
    
  void adding(Macro_Abstract m) {
    m.grabber.setPosition(add_pos, macro_size + add_pos);
    add_pos += macro_size / 2;
    m.setLayer(layer+2);
    m.toLayerTop();
    if (add_pos > macro_size * 3) add_pos = 0;
  }
}
