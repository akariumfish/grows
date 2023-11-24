


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
  nWidget smenu,sclear,sfield,ssave,reduc,menu,addSheet,addExtIn,addExtOut,
    addBang,addSwitch,addDelay,addPulse,addBool,addValue,addComp,addCalc,addNot;
  
  ArrayList<Macro_Sheet_Input> sheet_inputs = new ArrayList<Macro_Sheet_Input>(0);
  ArrayList<Macro_Sheet_Output> sheet_outputs = new ArrayList<Macro_Sheet_Output>(0);
  
  int sheet_inCount = 0;
  int sheet_outCount = 0;
  
  ArrayList<Macro_Input> inputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> outputs = new ArrayList<Macro_Output>(0);
  
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  
  String savepath = "save.txt";
  
  boolean isReduc = false;
  void reduc() {
    isReduc = true;
    menu.hide();
    closer.show();
    for (Macro_Abstract m : child_macro) m.hide();
    for (Macro_Sheet_Input m : sheet_inputs) m.reduc();
    for (Macro_Sheet_Output m : sheet_outputs) m.reduc();
  }
  void enlarg() {
    isReduc = false;
    for (Macro_Abstract m : child_macro) m.show();
    for (Macro_Sheet_Input m : sheet_inputs) m.enlarg();
    for (Macro_Sheet_Output m : sheet_outputs) m.enlarg();
    menu.show();
    addSheet.hide();
    sclear.hide();
  }
  
  Macro_Sheet(nGUI _gui, Macro_Sheet p, float x, float y) {
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
    addSheet = new nWidget(_gui, "Sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(menu)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addSheet();
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
        addSheetInput();
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
        addSheetOutput();
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
      }})
      ;
      
    smenu = new nWidget(_gui, "S", int(macro_size/1.5), 0, 0, macro_size, macro_size * 0.75)
      .setSwitch()
      .setParent(menu)
      .setLayer(layer)
      .stackRight()
      .addExclude(menu)
      .addEventSwitchOn(new Runnable() { public void run() {
        sclear.show();
      }})
      .addEventSwitchOff(new Runnable() { public void run() {
        sclear.hide();
      }})
      ;
    menu.addExclude(smenu);
    closer.setParent(smenu);
    sclear = new nWidget(_gui, "clear", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(smenu)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        empty();
        smenu.setOff();
      }})
      ;
    sfield = new nWidget(_gui, 0, 0, macro_size*5, macro_size)
      .setParent(sclear)
      .stackDown()
      .setLayer(getBase().menu_layer)
      .setFont(int(macro_size/1.5))
      .setText(savepath)
      .setField(true)
      .hide()
      .addEventFieldChange(new Runnable() { public void run() {
        savepath = sfield.getText();
      }})
      ;
    ssave = new nWidget(_gui, "save", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sfield)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_save();
        smenu.setOff();
      }})
      ;
    
    //back.toLayerTop();
    childDragged();
  }
  
  void empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    for (int i = inputs.size() - 1 ; i >= 0 ; i--) inputs.get(i).clear(); inputs.clear();
    for (int i = outputs.size() - 1 ; i >= 0 ; i--) outputs.get(i).clear(); outputs.clear();
    
    for (int i = sheet_inputs.size() - 1 ; i >= 0 ; i--) sheet_inputs.get(i).clear();
    for (int i = sheet_outputs.size() - 1 ; i >= 0 ; i--) sheet_outputs.get(i).clear();
  }
  
  Macro_Input getInputByIndex(int i) {
    for (Macro_Input m : inputs) if (m.index == i) return m;
    return null; }
  Macro_Output getOutputByIndex(int i) {
    for (Macro_Output m : outputs) if (m.index == i) return m;
    return null; }
    
  int getFreeInputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Input m : inputs) if (m.index == i) i++;
      if (t == i) found = true; }
    return i; }
  
  int getFreeOutputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Output m : outputs) if (m.index == i) i++;
      if (t == i) found = true; }
    return i; }
  
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
    smenu.setLayer(l);
    sfield.setLayer(getBase().menu_layer);
    ssave.setLayer(getBase().menu_layer);
    sclear.setLayer(getBase().menu_layer);
    for (Macro_Sheet_Input m : sheet_inputs) m.setLayer(l);
    for (Macro_Sheet_Output m : sheet_outputs) m.setLayer(l);
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
    smenu.toLayerTop();
    sfield.toLayerTop();
    ssave.toLayerTop();
    sclear.toLayerTop();
    for (Macro_Sheet_Input m : sheet_inputs) m.toLayerTop();
    for (Macro_Sheet_Output m : sheet_outputs) m.toLayerTop();
  }
  int size() {
    int vnb = super.size() + 5;
    for (Macro_Abstract v : child_macro) vnb += v.size();
    for (Macro_Sheet_Input i : sheet_inputs) vnb += i.size();
    for (Macro_Sheet_Output o : sheet_outputs) vnb += o.size();
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) vnb+=2;
    return vnb;
  }
  void clear() {
    super.clear();
    reduc.clear(); menu.clear(); addSheet.clear(); addExtIn.clear(); addExtOut.clear(); 
    
    addBang.clear(); addSwitch.clear(); addDelay.clear(); addPulse.clear(); addBool.clear(); 
    addValue.clear(); addComp.clear(); addCalc.clear(); addNot.clear(); 
    smenu.clear(); sfield.clear(); ssave.clear(); 
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    for (int i = inputs.size() - 1 ; i >= 0 ; i--) inputs.get(i).clear(); inputs.clear();
    for (int i = outputs.size() - 1 ; i >= 0 ; i--) outputs.get(i).clear(); outputs.clear();
    
    for (int i = sheet_inputs.size() - 1 ; i >= 0 ; i--) sheet_inputs.get(i).clear();
    for (int i = sheet_outputs.size() - 1 ; i >= 0 ; i--) sheet_outputs.get(i).clear();
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
    for (Macro_Sheet_Input i : sheet_inputs) l++;
    s[id] = str(l);
    log("sheetin nb " + id + " " + s[id]);
    id++;
    for (Macro_Sheet_Input i : sheet_inputs) {
      i.to_string(s, id);
      id += i.size();
    }
    
    
    l = 0;
    for (Macro_Sheet_Output o : sheet_outputs) l++;
    s[id] = str(l);
    log("sheetout nb " + id + " " + s[id]);
    id++;
    for (Macro_Sheet_Output o : sheet_outputs) {
      o.to_string(s, id);
      id += o.size();
    }
    
    
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
    log("sheet in connect nb " + id + " " + s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Sheet_Input m = addSheetInput();
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    log("sheet out connect nb " + id + " " + s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Sheet_Output m = addSheetOutput();
      m.from_string(s, id);
      id += m.size();
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
  
  void do_save() {
    log("do save ");
    String[] sl = new String[size()];
    to_string(sl, 0);
    saveStrings(savepath, sl);
    log("save end");
    log("");
  }
  
  void do_load() {
    log("do load");
    log("emptying");
    empty();
    String[] sl = loadStrings(savepath);
    from_string(sl, 0);
    log("load end");
    log("");
  }
  void do_load_as() {
    log("do load as");
    Macro_Sheet ms = addSheet();
    ms.setLayer(layer+2);
    ms.toLayerTop();
    String[] sl = loadStrings(savepath);
    ms.from_string(sl, 0);
    log("load as end");
    log("");
    ms.childDragged();
  }
  void childDragged() {
    float minx = 0, miny = 0, maxx = macro_size*5, maxy = macro_size*0.75;
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
    
    for (Macro_Sheet_Input m : sheet_inputs) {
      if (maxy < m.grabber.getLocalY() + macro_size)
        maxy = m.grabber.getLocalY() + macro_size;
      if (miny > m.grabber.getLocalY())
        miny = m.grabber.getLocalY();
    }
    for (Macro_Sheet_Output m : sheet_outputs) {
      if (maxy < m.grabber.getLocalY() + macro_size)
        maxy = m.grabber.getLocalY() + macro_size;
      if (miny > m.grabber.getLocalY())
        miny = m.grabber.getLocalY();
    }
    if (isReduc) {
      back.setPosition(minx, miny);
      back.setSize(maxx - minx, maxy - miny + macro_size);
      inputs_ref.setPX(minx + macro_size);
      outputs_ref.setPX(maxx - macro_size*0.25);
    } else {
      back.setPosition(minx - macro_size, miny - macro_size);
      back.setSize(maxx - minx + macro_size*2, maxy - miny + macro_size*2);
      inputs_ref.setPX(minx);
      outputs_ref.setPX(maxx);
    }
    if (parent != null) parent.childDragged();
  }
  
  Macro_Sheet_Input addSheetInput() {
    Macro_Sheet_Input m = new Macro_Sheet_Input(gui, parent, this);
    childDragged();
    return m;
  }
  
  Macro_Sheet_Output addSheetOutput() {
    Macro_Sheet_Output m = new Macro_Sheet_Output(gui, parent, this);
    childDragged();
    return m;
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
    childDragged();
  }
  
}