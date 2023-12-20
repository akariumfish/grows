


///*
//objet macro vide, on peut y ajouté des entré/sortie customizable


//MACROCustom
//  addConnexion

//Macro Custom Connexions:
//  >MCsValueWatcher f i b
//    widget preview
//    in bang or button to send / on change / always
//  >MCsValueController f i b
//    inV set, 
//    inV factor, inB do fact x, inB do fact /, 
//    inV increment, inB do incr +, inB do incr -
//    button ctrl
//  >MCRun( code ) bang 
//    button bang
  
//  MCListen Channel bang value
//  MCCall Channel bang value
  
//  MCJoystick out manette inputs
//*/


////void mysetup() {
  
////  //Macro_Custom m = new Macro_Custom(gui, macro_main, 0, 0)
////  //  .addValueWatcher(gcom.OLD_AGE)
////  //    .getMacro()
////  //  ;
////  //macro_main.adding(m);
////  //macro_main.childDragged();
////}





//class MC_Connexion {
//  Macro_Custom parent;
//  String def = null;
//  String ref = null;
  
//  MC_Connexion setRef(String r) { ref = copy(r); return this; }
  
//  MC_Connexion(Macro_Custom _p, String d) {
//    parent = _p;
//    def = d;
//  }
  
//  Macro_Custom getMacro() { return parent; }
  
//  MC_Connexion addTickEvent(Runnable r) { parent.tickEvents.add(r); return this; }
//  void to_save(Save_Bloc bloc) {
//    bloc.newData("def", def);
//    if (ref != null) bloc.newData("ref", ref);
//  }
//  void from_save(Save_Bloc bloc) {
//    if (bloc.getData("ref") != null) ref = copy(bloc.getData("ref"));
//  }
//}

//class MC_Value_Watcher extends MC_Connexion {
//  Macro_Output out;
//  private sFlt f_val;
//  private sInt i_val;
//  private sBoo b_val;
//  private sVec v_val;
//  nWidget label;
//  MC_Value_Watcher setValue(sValue b) { 
//    if (b.type.equals("flt")) setValue((sFlt)b);
//    if (b.type.equals("int")) setValue((sInt)b);
//    if (b.type.equals("boo")) setValue((sBoo)b);
//    if (b.type.equals("vec")) setValue((sVec)b);
//    return this; }
//  MC_Value_Watcher setValue(sVec v) { v_val = v; return this; }
//  MC_Value_Watcher setValue(sFlt v) { out.setDefFloat(); f_val = v; i_val = null; b_val = null; return this; }
//  MC_Value_Watcher setValue(sInt v) { out.setDefInt(); i_val = v; f_val = null; b_val = null; return this; }
//  MC_Value_Watcher setValue(sBoo v) { out.setDefBool(); b_val = v; i_val = null; f_val = null; return this; }
//  MC_Value_Watcher(Macro_Custom _p) {
//    super(_p, "watch");
//    out = parent.addExtOutput();
//    addTickEvent(new Runnable() { public void run() {
//      if (f_val != null) out.send(newPacketFloat(f_val.get()));
//      if (i_val != null) out.send(newPacketInt(i_val.get()));
//      if (b_val != null) out.send(newPacketBool(b_val.get()));
//      if (v_val != null) out.send(newPacketVec(v_val.get()));
//    }});
    
//    label = new nWidget(parent.gui, "--", int(parent.ref_size/1.9), -parent.ref_size*0.125, 0, 
//                                                                    parent.ref_size*2.25, parent.ref_size)
//      .setStandbyColor(color(255, 50))
//      .setParent(out.connect)
//      .stackLeft()
//      .addEventFrame_Builder(new Runnable() { public void run() {
//        if (f_val != null)  {
//          ((nWidget)builder).setText(f_val.shrt);
//        }
//        if (i_val != null)  {
//          ((nWidget)builder).setText(i_val.shrt);
//        }
//        if (b_val != null)  {
//          ((nWidget)builder).setText(b_val.shrt);
//        }
//        if (v_val != null)  {
//          ((nWidget)builder).setText(v_val.shrt);
//        }
//      }})
//      ;
//    parent.widgets.add(label);
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    if (f_val != null) bloc.newData("f", f_val.ref);
//    else if (b_val != null) bloc.newData("b", b_val.ref);
//    else if (i_val != null) bloc.newData("i", i_val.ref);
//    else if (v_val != null) bloc.newData("v", v_val.ref);
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    if (bloc.getData("f") != null) {
//      f_val = (sFlt)(parent.parent.sheet_data.searchValue(bloc.getData("f"))); }
//    else if (bloc.getData("b") != null) {
//      b_val = (sBoo)(parent.parent.sheet_data.searchValue(bloc.getData("b"))); }
//    else if (bloc.getData("i") != null) {
//      i_val = (sInt)(parent.parent.sheet_data.searchValue(bloc.getData("i"))); }
//    else if (bloc.getData("v") != null) {
//      v_val = (sVec)(parent.parent.sheet_data.searchValue(bloc.getData("v"))); }
//  }
//}

//class MC_Value_Controller extends MC_Connexion {
//  Macro_Input in;
//  sFlt f_val;
//  sInt i_val;
//  sBoo b_val;
//  sRun r_val;
//  sVec v_val;
//  nWidget label;
//  MC_Value_Controller setValue(sValue b) { 
//    if (b.type.equals("flt")) setValue((sFlt)b);
//    if (b.type.equals("int")) setValue((sInt)b);
//    if (b.type.equals("boo")) setValue((sBoo)b);
//    if (b.type.equals("run")) setValue((sRun)b);
//    if (b.type.equals("vec")) setValue((sVec)b);
//    return this; }
//  MC_Value_Controller setValue(sVec v) { in.setFilterVec(); v_val = v; return this; }
  
//  MC_Value_Controller setValue(sFlt v) { in.setFilterNumber(); f_val = v; i_val = null; b_val = null; r_val = null; return this; }
//  MC_Value_Controller setValue(sInt v) { in.setFilterNumber(); i_val = v; f_val = null; b_val = null; r_val = null; return this; }
//  MC_Value_Controller setValue(sBoo v) { 
//    in.setFilterBin(); 
//    b_val = v; i_val = null; f_val = null; r_val = null; return this; 
//  }
//  MC_Value_Controller setValue(sRun v) { 
//    in.setFilterBang(); 
//    r_val = v; i_val = null; f_val = null; b_val = null; return this; 
//  }
//  MC_Value_Controller(Macro_Custom _p) {
//    super(_p, "ctrl");
//    in = parent.addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        if (in.getLastPacket().isFloat() && f_val != null) f_val.set(in.getLastPacket().asFloat());
//        else if (in.getLastPacket().isInt() && i_val != null) i_val.set(in.getLastPacket().asInt());
//        else if (in.getLastPacket().isBool() && b_val != null) b_val.set(in.getLastPacket().asBool());
//        else if (in.getLastPacket().isBang() && b_val != null) b_val.set(!b_val.get());
//        else if (in.getLastPacket().isBang() && r_val != null) r_val.run();
//        else if (in.getLastPacket().isVec() && v_val != null) v_val.set(in.getLastPacket().asVec());
//      }})
//      ;
//    label = new nWidget(parent.gui, "--", int(parent.ref_size/1.9), parent.ref_size*0.125, 0, 
//                                                                    parent.ref_size*2.25, parent.ref_size)
//      .setStandbyColor(color(255, 50))
//      .setParent(in.connect)
//      .stackRight()
//      .addEventFrame_Builder(new Runnable() { public void run() {
//        if (f_val != null)  { ((nWidget)builder).setText(f_val.shrt); }
//        else if (i_val != null)  { ((nWidget)builder).setText(i_val.shrt); }
//        else if (b_val != null)  { ((nWidget)builder).setText(b_val.shrt); }
//        else if (r_val != null)  { ((nWidget)builder).setText(r_val.shrt); }
//        else if (v_val != null)  { ((nWidget)builder).setText(v_val.shrt); }
//      }})
//      ;
//    parent.widgets.add(label);
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    if (f_val != null) bloc.newData("f", f_val.ref);
//    else if (b_val != null) bloc.newData("b", b_val.ref);
//    else if (i_val != null) bloc.newData("i", i_val.ref);
//    else if (r_val != null) bloc.newData("r", r_val.ref);
//    else if (v_val != null) bloc.newData("v", v_val.ref);
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    if (bloc.getData("f") != null) {
//      f_val = (sFlt)(parent.parent.sheet_data.searchValue(bloc.getData("f")));
//      in.setFilterNumber();  }
//    else if (bloc.getData("b") != null) {
//      b_val = (sBoo)(parent.parent.sheet_data.searchValue(bloc.getData("b")));
//      in.setFilterBin();  }
//    else if (bloc.getData("i") != null) {
//      i_val = (sInt)(parent.parent.sheet_data.searchValue(bloc.getData("i")));
//      in.setFilterNumber();  }
//    else if (bloc.getData("r") != null) {
//      r_val = (sRun)(parent.parent.sheet_data.searchValue(bloc.getData("r")));
//      in.setFilterBang();  }
//    else if (bloc.getData("v") != null) {
//      v_val = (sVec)(parent.parent.sheet_data.searchValue(bloc.getData("v")));
//      in.setFilterVec();  }
//  }
//}



//class Macro_Custom extends Macro_Abstract {
//  Tickable tick;
//  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  
//  ArrayList<Runnable> tickEvents = new ArrayList<Runnable>();
  
//  ArrayList<MC_Connexion> connections = new ArrayList<MC_Connexion>();
  
//  MC_Connexion getConnexion(String ref) {
//    for (MC_Connexion m : connections) if (m.ref.equals(ref)) return m; 
//    return null;
//  }
//  Macro_Custom(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "custom", x, y);
//    setWidth(ref_size*7);
    
    
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        runEvents(tickEvents);
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//  }
  
//  //MC_Run addRun() {
//  //  MC_Run m = new MC_Run(this);
//  //  connections.add(m);
//  //  toLayerTop();
//  //  setLayer(layer);
//  //  return m;
//  //}
  
//  MC_Value_Watcher addValueWatcher() {
//    MC_Value_Watcher m = new MC_Value_Watcher(this);
//    connections.add(m);
//    toLayerTop();
//    setLayer(layer);
//    return m;
//  }
  
//  MC_Value_Controller addValueController() {
//    MC_Value_Controller m = new MC_Value_Controller(this);
//    connections.add(m);
//    toLayerTop();
//    setLayer(layer);
//    return m;
//  }
  
//  void clear() {
//    super.clear();
//    tick.clear();
//    for (nWidget w : widgets) w.clear(); }
//  void to_save(Save_Bloc bloc) { 
//    super.to_save(bloc); 
//    Save_Bloc co_blocs = bloc.newBloc("cos");
//    for (MC_Connexion m : connections) { m.to_save(co_blocs.newBloc("co")); }
    
//  }
//  void from_save(Save_Bloc bloc) { 
//    Save_Bloc co_blocs = bloc.getBloc("cos");
//    if (co_blocs != null) co_blocs.runIterator(new Iterator<Save_Bloc>() { 
//      public void run(Save_Bloc bloc) { 
//        if      (bloc.getData("def").equals("ctrl"))  addValueController().from_save(bloc);
//        else if (bloc.getData("def").equals("watch")) addValueWatcher().from_save(bloc);
//        //else if (bloc.getData("def").equals("run")) addRun().from_save(bloc);
//      } } );
//    super.from_save(bloc); 
//  }
//  void setLayer(int l) {
//    super.setLayer(l);
//    for (nWidget w : widgets) w.setLayer(l); }
//  void toLayerTop() {
//    super.toLayerTop();
//    for (nWidget w : widgets) w.toLayerTop(); }
//  void childDragged() {}
//}




///*

//objet macro extended de l'abstract pour les fonction de base

//Basic Macro:
//  bg : bang
//  b ; bool
//  i : int
//  f : float
//  n : number : i f
//  v : value : b i f

//  Pulse n > bg
//  MacroDELAY n all > all
//    show msg waiting
//    multiple msg in waiting at dif count
//  MacroGATE b all > all
//    switch widget for activ
  
//  MacroCOMP n n > b
//  MacroBOOL b b > b
//  MacroCALC n n > f
//    out only on change ? or in bang to do calc?
//  MacroVAL bg v > v
//    multiples value
//  MacroKeyboard trig > bg state > b
//  not b > b
//  Switch bg > b
//    switch widget for activ
//  bang bg
  
//  initBang send bang first tick after creation
//  tick bang
//  random min max bang > f
//  set reset bg bg > b bg
//  sequenceur bg > multi bg
//  matrice select i, activ b, in all > multi out all
//    switch widget for activ
  
//  comment
//    change width, multiline


//*/

//class Macro_Comment extends Macro_Abstract {
//  nWidget field;
//  Macro_Comment(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "com", x, y);
//    addLine();
//    field = new nWidget(_gui, - ref_size * 7 / 8, ref_size * 1 / 8, ref_size*8, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("")
//      .setField(true)
//      ;
//    toLayerTop();
//    setWidth(ref_size*8.5);
//  }
//  void to_save(Save_Bloc bloc) { super.to_save(bloc);
//    bloc.newData("value", field.getText()); }
//  void from_save(Save_Bloc bloc) { super.from_save(bloc);
//    field.setText(bloc.getData("value")); }
//  void childDragged() {}
//  void setLayer(int l) { super.setLayer(l); field.setLayer(l); }
//  void toLayerTop() { super.toLayerTop(); field.toLayerTop(); }
//}



//class Macro_Value extends Macro_Abstract {
//  Macro_Output out;
//  Macro_Input in_bang,in_val;
//  nWidget button,field;
//  Macro_Packet pack;
//  Macro_Value setBool() { 
//    pack = newPacketBool(false); field.setField(false); 
//    field.setTrigger(); field.setText("false"); 
//    return this; }
//  Macro_Value(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "value", x, y);
//    button = new nWidget(_gui, ref_size / 8, ref_size / 8, ref_size*2, ref_size)
//      .setTrigger()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      .addEventTrigger(new Runnable() { public void run() {
//        send();
//      }})
//      ;
      
//    pack = newPacketFloat(0);
    
//    field = new nWidget(_gui, ref_size / 8, ref_size * 10 / 8, ref_size*2, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("0.0")
//      .setField(true)
//      .addEventFieldChange(new Runnable() { public void run() {
//        if (pack != null && pack.isFloat()) pack = newPacketFloat(field.getText());
//        if (pack != null && pack.isInt()) pack = newPacketInt(int(float(field.getText())));
//        if (pack == null) pack = newPacketFloat(field.getText());
//      }})
//      .addEventTrigger(new Runnable() { public void run() {
//        if (pack != null && pack.isBool()) pack = newPacketBool(!pack.asBool());
//        if (pack == null || (pack != null && !pack.isBool())) pack = newPacketBool(false);
//        if (pack.asBool()) field.setText("true"); else field.setText("false");
//      }})
//      ;
    
//    in_bang = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        if (in_bang.getLastPacket().isBang()) send();
//      }})
//      .setFilterBang()
//      ;
//    in_val = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack = in_val.getLastPacket();
//        if (pack.isFloat()) { field.setPassif(); field.setField(true); field.setText(trimStringFloat(pack.asFloat())); }
//        if (pack.isInt()) { field.setPassif(); field.setField(true); field.setText(str(pack.asInt())); }
//        if (pack.isBool() && pack.asBool()) { field.setField(false); field.setTrigger(); field.setText("true"); }
//        if (pack.isBool() && !pack.asBool()) { field.setField(false); field.setTrigger(); field.setText("false"); }
//      }})
//      .setFilterValue()
//      ;
//    out = addExtOutput()
//      .setDefVal();
//    toLayerTop();
//    setWidth(ref_size*3.5);
//  }
//  void send() {
//    if (pack != null) out.send(pack);
//  }
  
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    if (pack == null) return;
//    else if (pack.isFloat()) bloc.newData("f", pack.asFloat());
//    else if (pack.isInt()) bloc.newData("i", pack.asFloat());
//    else if (pack.isBool()) bloc.newData("b", pack.asFloat());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    if (bloc.getData("f") != null) {
//      pack = newPacketFloat(bloc.getFloat("f"));
//      field.setText(str(bloc.getFloat("f"))); }
//    if (bloc.getData("i") != null) {
//      pack = newPacketInt(bloc.getInt("i"));
//      field.setText(str(bloc.getInt("i"))); }
//    if (bloc.getData("b") != null) {
//      pack = newPacketBool(bloc.getBoolean("b"));
//      if (pack.asBool()) field.setText("true"); 
//      else field.setText("false"); }
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    button.setLayer(l);
//    field.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    button.toLayerTop();
//    field.toLayerTop();
//  }
//}





//class Macro_Keyboard extends Macro_Abstract {
//  Macro_Output out_t,out_s;
//  nWidget field;
//  Tickable tick;
//  Macro_Keyboard(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "key", x, y);
//    setWidth(ref_size*4.5);
//    field = new nWidget(_gui, ref_size / 8, ref_size / 8, ref_size*3, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("a")
//      .setField(true)
//      ;
//    out_t = addExtOutput()
//      .setDefBang();
//    out_s = addExtOutput()
//      .setDefBool();
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        if (mmain().inter.input.keyAll.state && field.getText().length() > 0 && 
//            field.getText().charAt(0) == mmain().inter.input.getLastKey()) out_t.send(newPacketBang());
//        if (mmain().inter.input.keyAll.trigClick && field.getText().length() > 0 && 
//            field.getText().charAt(0) == mmain().inter.input.getLastKey()) 
//          out_s.send(newPacketBool(true));
//        else out_s.send(newPacketBool(false));
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//  }
//  void clear() {
//    super.clear();
//    tick.clear();
//  }
  
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("value", field.getText());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    field.setText(bloc.getData("value"));
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    field.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    field.toLayerTop();
//  }
//}



//class Macro_Comp extends Macro_Abstract {
//  Macro_Output out;
//  Macro_Input in_val1,in_val2;
//  nWidget field1,field2,modeSUP,modeINF,modeEQ;
//  Tickable tick;
//  Macro_Comp(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "comp", x, y);
//    modeSUP = new nWidget(_gui, ">", int(ref_size/1.5), - ref_size, ref_size * 10 / 8, ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeINF = new nWidget(_gui, "<", int(ref_size/1.5), ref_size / 8, ref_size * 10 / 8, ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      .addExclude(modeSUP)
//      ;
//    modeSUP.addExclude(modeINF);
//    modeEQ = new nWidget(_gui, "=", int(ref_size/1.5), ref_size / 4 + ref_size, ref_size * 10 / 8, ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
    
//    field1 = new nWidget(_gui, ref_size / 8, ref_size * 1 / 8, ref_size*2, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("0.0")
//      .setField(true)
//      ;
//    field2 = new nWidget(_gui, ref_size / 8, ref_size * 19 / 8, ref_size*2, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("0.0")
//      .setField(true)
//      ;
    
    
//    in_val1 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in_val1.getLastPacket();
//        if (pack.isFloat()) {
//          float f = pack.asFloat();
//          field1.setText(str(f)); }
//        if (pack.isInt()) {
//          float f = pack.asInt();
//          field1.setText(str(f)); }
          
        
//        float f1 = float(field1.getText());
//        float f2 = float(field2.getText());
//        if      (modeEQ.isOn() && f1 == f2) out.send(newPacketBool(true));
//        else if (modeSUP.isOn() && f1 > f2) out.send(newPacketBool(true));
//        else if (modeINF.isOn() && f1 < f2) out.send(newPacketBool(true));
//        else if (modeEQ.isOn() || modeSUP.isOn() || modeINF.isOn()) out.send(newPacketBool(false));
//      }})
//      .setFilterNumber()
//      ;
//    addLine();
//    in_val2 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in_val2.getLastPacket();
//        if (pack.isFloat()) {
//          float f = pack.asFloat();
//          field2.setText(str(f)); }
//        if (pack.isInt()) {
//          float f = pack.asInt();
//          field2.setText(str(f)); }
          
        
//        float f1 = float(field1.getText());
//        float f2 = float(field2.getText());
//        if      (modeEQ.isOn() && f1 == f2) out.send(newPacketBool(true));
//        else if (modeSUP.isOn() && f1 > f2) out.send(newPacketBool(true));
//        else if (modeINF.isOn() && f1 < f2) out.send(newPacketBool(true));
//        else if (modeEQ.isOn() || modeSUP.isOn() || modeINF.isOn()) out.send(newPacketBool(false));
//      }})
//      .setFilterNumber()
//      ;
//    out = addExtOutput()
//      .setDefBool();
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        //float f1 = float(field1.getText());
//        //float f2 = float(field2.getText());
//        //if      (modeEQ.isOn() && f1 == f2) out.send(newPacketBool(true));
//        //else if (modeSUP.isOn() && f1 > f2) out.send(newPacketBool(true));
//        //else if (modeINF.isOn() && f1 < f2) out.send(newPacketBool(true));
//        //else if (modeEQ.isOn() || modeSUP.isOn() || modeINF.isOn()) out.send(newPacketBool(false));
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//    setWidth(ref_size*3.5);
//  }
//  //void clear() todo
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("value1", field1.getText());
//    bloc.newData("value2", field2.getText());
//    bloc.newData("inf", modeINF.isOn());
//    bloc.newData("sup", modeSUP.isOn());
//    bloc.newData("eq", modeEQ.isOn());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    field1.setText(bloc.getData("value1"));
//    field2.setText(bloc.getData("value2"));
//    if (bloc.getBoolean("inf")) modeINF.setOn();
//    if (bloc.getBoolean("sup")) modeSUP.setOn();
//    if (bloc.getBoolean("eq")) modeEQ.setOn();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    field1.setLayer(l);
//    field2.setLayer(l);
//    modeINF.setLayer(l);
//    modeSUP.setLayer(l);
//    modeEQ.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    field1.toLayerTop();
//    field2.toLayerTop();
//    modeINF.toLayerTop();
//    modeSUP.toLayerTop();
//    modeEQ.toLayerTop();
//  }
//}



//class Macro_Calc extends Macro_Abstract {
//  Macro_Output out;
//  Macro_Input in_val1,in_val2;
//  nWidget field1,field2,modeADD,modeSUP,modeMUL,modeDIV;
//  Tickable tick;
//  Macro_Calc(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "calc", x, y);
//    modeADD = new nWidget(_gui, "+", int(ref_size/1.3), - ref_size, ref_size * 10 / 8, 
//                                                        ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeSUP = new nWidget(_gui, "-", int(ref_size/1.3), ref_size / 8, ref_size * 10 / 8, 
//                                                        ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeMUL = new nWidget(_gui, "X", int(ref_size/1.5), ref_size / 4 + ref_size, ref_size * 10 / 8, 
//                                                        ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeDIV = new nWidget(_gui, "/", int(ref_size/1.5), ref_size * 3 / 8 + 2 * ref_size, ref_size * 10 / 8, 
//                                                        ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeADD.addExclude(modeSUP).addExclude(modeMUL).addExclude(modeDIV);
//    modeSUP.addExclude(modeADD).addExclude(modeMUL).addExclude(modeDIV);
//    modeMUL.addExclude(modeSUP).addExclude(modeADD).addExclude(modeDIV);
//    modeDIV.addExclude(modeSUP).addExclude(modeMUL).addExclude(modeADD);
    
//    field1 = new nWidget(_gui, ref_size / 8, ref_size * 1 / 8, ref_size*2.125, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("0.0")
//      .setField(true)
//      ;
//    field2 = new nWidget(_gui, ref_size / 8, ref_size * 19 / 8, ref_size*2.125, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText("0.0")
//      .setField(true)
//      ;
    
    
//    in_val1 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in_val1.getLastPacket();
//        if (pack.isFloat()) {
//          float f = pack.asFloat();
//          field1.setText(str(f)); }
//        if (pack.isInt()) {
//          float f = pack.asInt();
//          field1.setText(str(f)); }
        
        
//        float f1 = float(field1.getText());
//        float f2 = float(field2.getText());
//        if (modeADD.isOn()) out.send(newPacketFloat(str(f1 + f2)));
//        if (modeSUP.isOn()) out.send(newPacketFloat(str(f1 - f2)));
//        if (modeMUL.isOn()) out.send(newPacketFloat(str(f1 * f2)));
//        if (modeDIV.isOn() && f2 != 0) out.send(newPacketFloat(str(f1 / f2)));
//      }})
//      .setFilterNumber()
//      ;
//    addLine();
//    in_val2 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in_val2.getLastPacket();
//        if (pack.isFloat()) {
//          float f = pack.asFloat();
//          field2.setText(str(f)); }
//        if (pack.isInt()) {
//          float f = pack.asInt();
//          field2.setText(str(f)); }
        
//        float f1 = float(field1.getText());
//        float f2 = float(field2.getText());
//        if (modeADD.isOn()) out.send(newPacketFloat(str(f1 + f2)));
//        if (modeSUP.isOn()) out.send(newPacketFloat(str(f1 - f2)));
//        if (modeMUL.isOn()) out.send(newPacketFloat(str(f1 * f2)));
//        if (modeDIV.isOn() && f2 != 0) out.send(newPacketFloat(str(f1 / f2)));
//      }})
//      .setFilterNumber()
//      ;
//    out = addExtOutput()
//      .setDefFloat();
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        //float f1 = float(field1.getText());
//        //float f2 = float(field2.getText());
//        //if (modeADD.isOn()) out.send(newPacketFloat(str(f1 + f2)));
//        //if (modeSUP.isOn()) out.send(newPacketFloat(str(f1 - f2)));
//        //if (modeMUL.isOn()) out.send(newPacketFloat(str(f1 * f2)));
//        //if (modeDIV.isOn() && f2 != 0) out.send(newPacketFloat(str(f1 / f2)));
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//    setWidth(ref_size*3.625);
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("value1", field1.getText());
//    bloc.newData("value2", field2.getText());
//    bloc.newData("add", modeADD.isOn());
//    bloc.newData("sup", modeSUP.isOn());
//    bloc.newData("mul", modeMUL.isOn());
//    bloc.newData("div", modeDIV.isOn());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    field1.setText(bloc.getData("value1"));
//    field2.setText(bloc.getData("value2"));
//    if (bloc.getBoolean("add")) modeADD.setOn();
//    if (bloc.getBoolean("sup")) modeSUP.setOn();
//    if (bloc.getBoolean("mul")) modeMUL.setOn();
//    if (bloc.getBoolean("div")) modeDIV.setOn();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    field1.setLayer(l);
//    field2.setLayer(l);
//    modeADD.setLayer(l);
//    modeSUP.setLayer(l);
//    modeMUL.setLayer(l);
//    modeDIV.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    field1.toLayerTop();
//    field2.toLayerTop();
//    modeADD.toLayerTop();
//    modeSUP.toLayerTop();
//    modeMUL.toLayerTop();
//    modeDIV.toLayerTop();
//  }
//}




//class Macro_Bang extends Macro_Abstract {
//  Macro_Output out;
//  nWidget button;
//  Macro_Bang(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "bang", x, y);
//    button = new nWidget(_gui, ref_size / 4, ref_size / 8, ref_size*2, ref_size)
//      .setTrigger()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      .addEventTrigger(new Runnable() { public void run() {
//        out.send(new Macro_Packet("bang"));
//        mmain().askTick(); 
//      }})
//      ;
//    out = addExtOutput()
//      .setDefBang();
//    toLayerTop();
//    setWidth(ref_size*3.5);
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    button.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    button.toLayerTop();
//  }
//}



//class Macro_Switch extends Macro_Abstract {
//  Macro_Output out;
//  nWidget button;
//  Tickable tick;
//  Macro_Switch(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "switch", x, y);
//    setWidth(ref_size*3.5);
//    button = new nWidget(_gui, ref_size / 4, ref_size / 8, ref_size*2, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      .addEventSwitchOn(new Runnable() { public void run() { mmain().askTick(); } } )
//      .addEventSwitchOff(new Runnable() { public void run() { mmain().askTick(); } } )
//      ;
//    out = addExtOutput()
//      .setDefBool();
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        if (button.isOn()) out.send(newPacketBool(true));
//        else out.send(newPacketBool(false));
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//  }
  
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("state", button.isOn());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    if (bloc.getBoolean("state")) button.setOn();
//  }
  
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    button.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    button.toLayerTop();
//  }
//}




//class Macro_Pulse extends Macro_Abstract {
//  Macro_Output out;
//  Macro_Input in_t;
//  nWidget time_field;
//  Tickable tick;
//  int time = 20;
//  int count = 0;
//  Macro_Pulse(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "pulse", x, y);
//    setWidth(ref_size*5.5);
//    time_field = new nWidget(_gui, ref_size / 8, ref_size / 8, ref_size*3, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText(str(time))
//      .setField(true)
//      .addEventFieldChange(new Runnable() { public void run() {
//        String s = time_field.getText();
        
//        time = max(1, int(s));
//        count = time;
//      }})
//      ;
//    out = addExtOutput()
//      .setDefBang();
//    in_t = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        if (in_t.getLastPacket().isInt()) time = in_t.getLastPacket().asInt();
//        if (in_t.getLastPacket().isFloat()) time = int(in_t.getLastPacket().asFloat());
//        if (in_t.getLastPacket().isInt() || in_t.getLastPacket().isFloat()) 
//          { time_field.setText(str(time)); count = time; }
//      }})
//      .setFilterNumber()
//      ;
//    tick = new Tickable(mmain().tickpile) { public void tick(float t) {
//        if (count > 0) { 
//          count--; 
//          if (count == 0) { count = time; out.send(newPacketBang()); }
//        }
//      } }
//      .setLayer(0)
//      ;
//    count = time;
//    toLayerTop();
//  }
//  void clear() {
//    super.clear();
//    tick.clear();
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("time", time);
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    time = int(bloc.getInt("time"));
//    time_field.setText(str(time));
//    count = time;
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    time_field.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    time_field.toLayerTop();
//  }
//}




//class Macro_Delay extends Macro_Abstract {
//  Macro_Input in_m,in_t;
//  Macro_Output out;
//  nWidget time_field;
//  Tickable tick;
//  Macro_Packet pack;
//  int time = 1;
//  int count = 0;
  
//  Macro_Delay(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "delay", x, y);
//    setWidth(ref_size*5.5);
//    time_field = new nWidget(_gui, ref_size / 8, ref_size / 8, ref_size*3, ref_size)
//      .setParent(panel)
//      .setLayer(layer)
//      .setFont(int(ref_size/1.5))
//      .setText(str(time))
//      .setField(true)
//      .addEventFieldChange(new Runnable() { public void run() {
//        String s = time_field.getText();
//        time = max(1, int(s));
//        count = 0;
//      }})
//      ;
//    out = addExtOutput();
//    in_m = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack = in_m.getLastPacket();
//        count = time;
//      }})
//      ;
//    in_t = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        if (in_t.getLastPacket().isInt()) time = in_t.getLastPacket().asInt();
//        if (in_t.getLastPacket().isFloat()) time = int(in_t.getLastPacket().asFloat());
//        if (in_t.getLastPacket().isInt() || in_t.getLastPacket().isFloat()) 
//          { time_field.setText(str(time)); count = 0; }
//      }})
//      .setFilterNumber()
//      ;
//    tick = new Tickable(mmain().tickpile) { public void tick(float time) {
//        if (count > 0) { count--; if (count == 0) out.send(pack); }
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//  }
//  void clear() {
//    super.clear();
//    tick.clear();
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("time", time);
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    time = int(bloc.getInt("time"));
//    time_field.setText(str(time));
//    count = 0;
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    time_field.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    time_field.toLayerTop();
//  }
//}




//class Macro_Gate extends Macro_Abstract {
//  Macro_Input in_b, in_m;
//  Macro_Output out;
//  Tickable tick;
//  Macro_Packet pack_b,pack_m;
  
//  Macro_Gate(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "gate", x, y);
//    setWidth(ref_size*5.5);
//    out = addExtOutput();
//    in_m = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack_m = in_m.getLastPacket();
//        if (pack_b != null && pack_m != null && pack_b.isBool() && pack_b.asBool()) out.send(pack_m);
//      }})
//      ;
//    in_b = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack_b = in_b.getLastPacket();
//        if (pack_b != null && pack_m != null && pack_b.isBool() && pack_b.asBool()) out.send(pack_m);
//      }})
//      .setFilterBool()
//      ;
//    tick = new Tickable(mmain().tickpile) { public void tick(float time) {
//        pack_b = null; pack_m = null;
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//  }
//  void clear() {
//    super.clear();
//    tick.clear();
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//  }
//}




//class Macro_Bool extends Macro_Abstract {
//  Macro_Input in1,in2;
//  Macro_Output out;
//  Tickable tick;
//  Macro_Packet pack1 = null, pack2 = null;
//  nWidget modeAND,modeOR;
  
//  Macro_Bool(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "bool", x, y);
//    modeAND = new nWidget(_gui, "&&", int(ref_size/1.5), ref_size / 8, ref_size * 5 / 8, ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      ;
//    modeOR = new nWidget(_gui, "||", int(ref_size/1.5), ref_size / 4 + ref_size, ref_size * 5 / 8, ref_size, ref_size)
//      .setSwitch()
//      .setParent(panel)
//      .setLayer(layer)
//      .stackDown()
//      .addExclude(modeAND)
//      ;
//    modeAND.addExclude(modeOR);
    
//    out = addExtOutput()
//      .setDefBool();
//    in1 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack1 = in1.getLastPacket();
//      }})
//      .setFilterBool()
//      ;
//    in2 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack2 = in2.getLastPacket();
//      }})
//      .setFilterBool()
//      ;
//    tick = new Tickable(mmain().tickpile) { public void tick(float time) {
//        test();
//        pack1 = null; pack2 = null;
//      } }
//      .setLayer(0)
//      ;
//    toLayerTop();
//    setWidth(ref_size*3.625);
//    outputs_ref.setPY(ref_size * 4 / 8);
//  }
//  void test() {
//    if (modeAND.isOn() && 
//        pack1 != null && pack1.isBool() && 
//        pack2 != null && pack2.isBool() ) {
//      out.send(newPacketBool(pack1.asBool() && pack2.asBool())); }
//    if (modeOR.isOn() &&  
//        pack1 != null && pack1.isBool() && 
//        pack2 != null && pack2.isBool() ) {
//      out.send(newPacketBool(pack1.asBool() || pack2.asBool())); }
//  }
//  void clear() {
//    super.clear();
//    tick.clear();
//  }
//  void to_save(Save_Bloc bloc) {
//    super.to_save(bloc);
//    bloc.newData("and", modeAND.isOn());
//    bloc.newData("or", modeOR.isOn());
//  }
//  void from_save(Save_Bloc bloc) {
//    super.from_save(bloc);
//    if (bloc.getBoolean("and")) modeAND.setOn();
//    if (bloc.getBoolean("or")) modeOR.setOn();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//    modeAND.setLayer(l);
//    modeOR.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    modeAND.toLayerTop();
//    modeOR.toLayerTop();
//  }
//}

//class Macro_Not extends Macro_Abstract {
//  Macro_Input in;
//  Macro_Output out;
  
//  Macro_Not(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "not", x, y);
    
//    out = addExtOutput()
//      .setDefBool();
//    in = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in.getLastPacket();
//        if (pack != null && pack.isBool()) { out.send(newPacketBool(!pack.asBool())); }
//      }})
//      .setFilterBool()
//      ;
//    toLayerTop();
//    setWidth(ref_size*2.25);
//  }
//  void clear() {
//    super.clear();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//  }
//}

//class Macro_Bin extends Macro_Abstract {
//  Macro_Input in;
//  Macro_Output out;
  
//  Macro_Bin(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "bin", x, y);
    
//    out = addExtOutput()
//      .setDefBin();
//    in = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        Macro_Packet pack = in.getLastPacket();
//        if (pack != null) {
//          if (pack.isBool() && pack.asBool()) out.send(newPacketBang());
//          if (pack.isBang()) out.send(newPacketBool(true)); } } } )
//      .setFilterBin()
//      ;
//    toLayerTop();
//    setWidth(ref_size*2.25);
//  }
//  void clear() {
//    super.clear();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//  }
//}
//class Macro_Vec extends Macro_Abstract {
//  Macro_Input in1, in2;
//  Macro_Output out1, out2;
//  Macro_Packet pack1, pack2;
  
//  Macro_Vec(nGUI _gui, Macro_Sheet p, float x, float y) {
//    super(_gui, p, "vec", x, y);
    
//    out1 = addExtOutput();
//    out2 = addExtOutput();
//    in1 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack1 = in1.getLastPacket();
//        if (pack1 != null && pack1.isVec()) {
//          out1.send(newPacketFloat(pack1.asVec().x));
//          out2.send(newPacketFloat(pack1.asVec().y));
//        }
//        if (pack1 != null && pack1.isFloat() && pack2 != null && pack2.isFloat()) 
//          out1.send(newPacketVec(new PVector(pack1.asFloat(), pack2.asFloat())));
        
//      } } );
//    in2 = addExtInput()
//      .addEventReceive(new Runnable() { public void run() {
//        pack2 = in2.getLastPacket();
//        if (pack2 != null && pack2.isVec()) {
//          out1.send(newPacketFloat(pack2.asVec().x));
//          out2.send(newPacketFloat(pack2.asVec().y));
//        }
//        if (pack1 != null && pack1.isFloat() && pack2 != null && pack2.isFloat()) 
//          out1.send(newPacketVec(new PVector(pack1.asFloat(), pack2.asFloat())));
//      } } );
//    toLayerTop();
//    setWidth(ref_size*2.25);
//  }
//  void clear() {
//    super.clear();
//  }
//  void childDragged() {}
//  void setLayer(int l) {
//    super.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//  }
//}
