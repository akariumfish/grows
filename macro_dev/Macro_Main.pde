
/*

objet principale qui contient tout le patch

extended from sheet object
non reductible

fonction save load

can create like sheet object

*/



class Macro_Main extends Macro_Sheet {
  Ticking_pile tickpile;
  nWidget smenu,sclear,sfield,ssave,sload,ssheet;
  String savepath = "save.txt";
  int menu_layer = 20;
  Macro_Main(nGUI _gui, Ticking_pile t, float x, float y) {
    super(_gui, null, x, y);
    tickpile = t;
    closer.hide(); reduc.hide(); menu.show(); addSheet.hide();
    
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
    sclear = new nWidget(_gui, "clear", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(smenu)
      .setLayer(menu_layer)
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
      .setLayer(menu_layer)
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
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_save();
        smenu.setOff();
      }})
      ;
    sload = new nWidget(_gui, "load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(ssave)
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_load();
        childDragged();
        smenu.setOff();
      }})
      ;
    ssheet = new nWidget(_gui, "as sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sload)
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_load_as();
        childDragged();
        smenu.setOff();
      }})
      ;
    //back.toLayerTop();
    setLayer(0);
    toLayerTop();
    addBang.setParent(addSheet);
    addExtOut.clear();
    addExtIn.clear();
  }
  void clear() {
    empty();
    super.clear();
    smenu.clear(); sfield.clear(); ssave.clear(); sload.clear(); 
  }
  
  void empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    for (Macro_Input m : inputs) m.clear(); 
    inputs.clear();
    for (Macro_Output m : outputs) m.clear(); 
    outputs.clear();
  }
  
  int size() {
    int vnb = 2;
    for (Macro_Abstract v : child_macro) vnb += v.size();
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) vnb+=2;
    return vnb;
  }
  
  void toLayerTop() {
    super.toLayerTop();
    smenu.toLayerTop();
    sfield.toLayerTop();
    ssave.toLayerTop();
    sload.toLayerTop();
  }
  void setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l);
    for (Macro_Input m : extinputs) m.connect.setLayer(l);
    for (Macro_Output m : extoutputs) { m.connect.setLayer(l); m.line_drawer.setLayer(l+1); }
    reduc.setLayer(l);
    menu.setLayer(l);
    addSheet.setLayer(menu_layer);
    addExtIn.setLayer(menu_layer);
    addExtOut.setLayer(menu_layer);
    addBang.setLayer(menu_layer);
    addSwitch.setLayer(menu_layer);
    addDelay.setLayer(menu_layer);
    addPulse.setLayer(menu_layer);
    addValue.setLayer(menu_layer);
    addComp.setLayer(menu_layer);
    addCalc.setLayer(menu_layer);
    addNot.setLayer(menu_layer);
    addBool.setLayer(menu_layer);
    smenu.setLayer(l);
    sfield.setLayer(menu_layer);
    ssave.setLayer(menu_layer);
    sload.setLayer(menu_layer);
  }
  void do_save() {
    log("do save ");
    String[] sl = new String[size()];
    int id = 0;
    sl[0] = str(child_macro.size());
    log("childs nb " + id + " " + sl[id]);
    id++;
    for (Macro_Abstract v : child_macro) {
      v.to_string(sl, id);
      id += v.size();
    }
    int l = 0;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) l++;
    sl[id] = str(l);
    log("links nb " + id + " " + sl[id]);
    id++;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
      sl[id] = str(o.index); sl[id+1] = str(i.index); 
      log("link " + id + " " + sl[id] + " " + sl[id+1]);
      id +=2;
    }
    saveStrings(savepath, sl);
    log("save end");
    log("");
  }
  
  void do_load() {
    log("do load");
    log("emptying");
    empty();
    String[] sl = loadStrings(savepath);
    int id = 1;
    int l = int(sl[0]);
    log("childs nb " + 0 + " " + l);
    for (int i = 0; i < l ; i++) {
      Macro_Abstract m = null;
      log("macro type " + id + " " + sl[id]);
      if      (sl[id].equals("bang"))  m = new Macro_Bang(gui, this, 0, 0);
      else if (sl[id].equals("switch")) m = new Macro_Switch(gui, this, 0, 0);
      else if (sl[id].equals("delay")) m = new Macro_Delay(gui, this, 0, 0);
      else if (sl[id].equals("pulse")) m = new Macro_Pulse(gui, this, 0, 0);
      else if (sl[id].equals("value")) m = new Macro_Value(gui, this, 0, 0);
      else if (sl[id].equals("bool"))  m = new Macro_Bool(gui, this, 0, 0);
      else if (sl[id].equals("not"))  m = new Macro_Not(gui, this, 0, 0);
      else if (sl[id].equals("comp"))  m = new Macro_Comp(gui, this, 0, 0);
      else if (sl[id].equals("calc"))  m = new Macro_Calc(gui, this, 0, 0);
      else if (sl[id].equals("sheet")) m = new Macro_Sheet(gui, this, 0, 0);
      m.setLayer(layer+2);
      m.toLayerTop();
      m.from_string(sl, id);
      id += m.size();
    }
    l = int(sl[id]);
    log("link nb " + id + " " + sl[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      log("link " + id + " " + id + " " + sl[id] + " " + sl[id+1]);
      getOutputByIndex(int(sl[id])).connect_to(getInputByIndex(int(sl[id+1])));
      id+=2;
    }
    log("load end");
    log("");
  }
  void do_load_as() {
    log("do load as");
    Macro_Abstract ms = addSheet();
    ms.setLayer(layer+2);
    ms.toLayerTop();
    String[] sl = loadStrings(savepath);
    int id = 1;
    int l = int(sl[0]);
    log("childs nb " + 0 + " " + l);
    for (int i = 0; i < l ; i++) {
      Macro_Abstract m = null;
      log("macro type " + id + " " + sl[id]);
      if      (sl[id].equals("bang"))   m = new Macro_Bang  (gui, ms, 0, 0);
      else if (sl[id].equals("switch")) m = new Macro_Switch(gui, ms, 0, 0);
      else if (sl[id].equals("delay"))  m = new Macro_Delay (gui, ms, 0, 0);
      else if (sl[id].equals("pulse"))  m = new Macro_Pulse (gui, ms, 0, 0);
      else if (sl[id].equals("value"))  m = new Macro_Value (gui, ms, 0, 0);
      else if (sl[id].equals("bool"))   m = new Macro_Bool  (gui, ms, 0, 0);
      else if (sl[id].equals("not"))    m = new Macro_Not   (gui, ms, 0, 0);
      else if (sl[id].equals("comp"))   m = new Macro_Comp  (gui, ms, 0, 0);
      else if (sl[id].equals("calc"))   m = new Macro_Calc  (gui, ms, 0, 0);
      else if (sl[id].equals("sheet"))  m = new Macro_Sheet (gui, ms, 0, 0);
      m.setLayer(layer+2);
      m.toLayerTop();
      m.from_string(sl, id);
      id += m.size();
    }
    l = int(sl[id]);
    log("link nb " + id + " " + sl[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      log("link " + id + " " + id + " " + sl[id] + " " + sl[id+1]);
      ms.getOutputByIndex(int(sl[id])).connect_to(ms.getInputByIndex(int(sl[id+1])));
      id+=2;
    }
    log("load as end");
    log("");
    ms.childDragged();
  }
}
