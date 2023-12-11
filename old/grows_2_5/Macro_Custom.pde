/*
objet macro vide, on peut y ajouté des entré/sortie customizable


MACROCustom
  addConnexion

Macro Custom Connexions:
  >MCsValueWatcher f i b
    widget preview
    in bang or button to send / on change / always
  >MCsValueController f i b
    inV set, 
    inV factor, inB do fact x, inB do fact /, 
    inV increment, inB do incr +, inB do incr -
    button ctrl
  >MCRun( code ) bang 
    button bang
  
  MCListen Channel bang value
  MCCall Channel bang value
  
  MCJoystick out manette inputs
*/


//void mysetup() {
  
//  //Macro_Custom m = new Macro_Custom(gui, macro_main, 0, 0)
//  //  .addValueWatcher(gcom.OLD_AGE)
//  //    .getMacro()
//  //  ;
//  //macro_main.adding(m);
//  //macro_main.childDragged();
//}





class MC_Connexion {
  Macro_Custom parent;
  String def = null;
  String ref = null;
  
  MC_Connexion setRef(String r) { ref = copy(r); return this; }
  
  MC_Connexion(Macro_Custom _p, String d) {
    parent = _p;
    def = d;
  }
  
  Macro_Custom getMacro() { return parent; }
  
  MC_Connexion addTickEvent(Runnable r) { parent.tickEvents.add(r); return this; }
  void to_save(Save_Bloc bloc) {
    bloc.newData("def", def);
    if (ref != null) bloc.newData("ref", ref);
  }
  void from_save(Save_Bloc bloc) {
    if (bloc.getData("ref") != null) ref = copy(bloc.getData("ref"));
  }
}




class MC_Run extends MC_Connexion {
  Macro_Input in;
  Runnable run = null;
  String run_key = null;
  nWidget label;
  
  MC_Run setRunnable(String k) { run_key = k; run = custom_runnable_map.get(k); return this; }

  MC_Run(Macro_Custom _p) {
    super(_p, "run");
    in = parent.addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (run != null) run.run();
      }})
      .setFilterBang()
      ;
    label = new nWidget(parent.gui, "--", int(parent.macro_size/1.5), parent.macro_size*0.125, 0, parent.macro_size*5.5, parent.macro_size)
      .setStandbyColor(color(255, 50))
      .setParent(in.connect)
      .stackRight()
      .addEventFrame_Builder(new Runnable() { public void run() {
        if (run_key != null)  {
          ((nWidget)builder).setText(run_key);
        }
      }})
      ;
    parent.widgets.add(label);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (run_key != null) bloc.newData("key", run_key);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("key") != null) setRunnable(bloc.getData("key"));
  }
}



class MC_Value_Watcher extends MC_Connexion {
  Macro_Output out;
  private sFlt f_val;
  private sInt i_val;
  private sBoo b_val;
  nWidget label;
  MC_Value_Watcher setValue(sFlt v) { out.setDefFloat(); f_val = v; i_val = null; b_val = null; return this; }
  MC_Value_Watcher setValue(sInt v) { out.setDefInt(); i_val = v; f_val = null; b_val = null; return this; }
  MC_Value_Watcher setValue(sBoo v) { out.setDefBool(); b_val = v; i_val = null; f_val = null; return this; }
  MC_Value_Watcher(Macro_Custom _p) {
    super(_p, "watch");
    out = parent.addExtOutput();
    addTickEvent(new Runnable() { public void run() {
      if (f_val != null) out.send(newPacketFloat(f_val.get()));
      if (i_val != null) out.send(newPacketInt(i_val.get()));
      if (b_val != null) out.send(newPacketBool(b_val.get()));
    }});
    
    label = new nWidget(parent.gui, "--", int(parent.macro_size/1.5), -parent.macro_size*0.125, 0, parent.macro_size*5.5, parent.macro_size)
      .setStandbyColor(color(255, 50))
      .setParent(out.connect)
      .stackLeft()
      .addEventFrame_Builder(new Runnable() { public void run() {
        if (f_val != null)  {
          ((nWidget)builder).setText(f_val.name);
        }
        if (i_val != null)  {
          ((nWidget)builder).setText(i_val.name);
        }
        if (b_val != null)  {
          ((nWidget)builder).setText(b_val.name);
        }
      }})
      ;
    parent.widgets.add(label);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (f_val != null) bloc.newData("f", f_val.name);
    if (b_val != null) bloc.newData("b", b_val.name);
    if (i_val != null) bloc.newData("i", i_val.name);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("f") != null) {
      for (sFlt v : simval.sfltlist) if (v.name.equals(bloc.getData("f"))) { f_val = v; break; }
    }
    if (bloc.getData("b") != null) {
      for (sBoo v : simval.sboolist) if (v.name.equals(bloc.getData("b"))) { b_val = v; break; }
    }
    if (bloc.getData("i") != null) {
      for (sInt v : simval.sintlist) if (v.name.equals(bloc.getData("i"))) { i_val = v; break; }
    }
  }
}

class MC_Value_Controller extends MC_Connexion {
  Macro_Input in;
  sFlt f_val;
  sInt i_val;
  sBoo b_val;
  nWidget label;
  MC_Value_Controller setValue(sFlt v) { in.setFilterNumber(); f_val = v; i_val = null; b_val = null; return this; }
  MC_Value_Controller setValue(sInt v) { in.setFilterNumber(); i_val = v; f_val = null; b_val = null; return this; }
  MC_Value_Controller setValue(sBoo v) { 
    in.setFilterBool(); 
    b_val = v; i_val = null; f_val = null; return this; 
  }
  MC_Value_Controller(Macro_Custom _p) {
    super(_p, "ctrl");
    in = parent.addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in.getLastPacket().isFloat() && f_val != null) f_val.set(in.getLastPacket().asFloat());
        if (in.getLastPacket().isInt() && i_val != null) i_val.set(in.getLastPacket().asInt());
        if (in.getLastPacket().isBool() && b_val != null) b_val.set(in.getLastPacket().asBool());
        if (in.getLastPacket().isBang() && b_val != null) b_val.set(true);
      }})
      ;
    label = new nWidget(parent.gui, "--", int(parent.macro_size/1.5), parent.macro_size*0.125, 0, parent.macro_size*5.5, parent.macro_size)
      .setStandbyColor(color(255, 50))
      .setParent(in.connect)
      .stackRight()
      .addEventFrame_Builder(new Runnable() { public void run() {
        if (f_val != null)  { ((nWidget)builder).setText(f_val.name); }
        if (i_val != null)  { ((nWidget)builder).setText(i_val.name); }
        if (b_val != null)  { ((nWidget)builder).setText(b_val.name); }
      }})
      ;
    parent.widgets.add(label);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (f_val != null) bloc.newData("f", f_val.name);
    if (b_val != null) bloc.newData("b", b_val.name);
    if (i_val != null) bloc.newData("i", i_val.name);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("f") != null) {
      for (sFlt v : simval.sfltlist) if (v.name.equals(bloc.getData("f"))) { setValue(v); break; }
    }
    if (bloc.getData("b") != null) {
      for (sBoo v : simval.sboolist) if (v.name.equals(bloc.getData("b"))) { setValue(v); break; }
    }
    if (bloc.getData("i") != null) {
      for (sInt v : simval.sintlist) if (v.name.equals(bloc.getData("i"))) { setValue(v); break; }
    }
  }
}



class Macro_Custom extends Macro_Abstract {
  Tickable tick;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  
  ArrayList<Runnable> tickEvents = new ArrayList<Runnable>();
  
  ArrayList<MC_Connexion> connections = new ArrayList<MC_Connexion>();
  
  MC_Connexion getConnexion(String ref) {
    for (MC_Connexion m : connections) if (m.ref.equals(ref)) return m; 
    return null;
  }
  Macro_Custom(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "custom", x, y);
    setWidth(macro_size*7);
    
    
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        runEvents(tickEvents);
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  
  MC_Run addRun() {
    MC_Run m = new MC_Run(this);
    connections.add(m);
    toLayerTop();
    setLayer(layer);
    return m;
  }
  
  MC_Value_Watcher addValueWatcher() {
    MC_Value_Watcher m = new MC_Value_Watcher(this);
    connections.add(m);
    toLayerTop();
    setLayer(layer);
    return m;
  }
  
  MC_Value_Controller addValueController() {
    MC_Value_Controller m = new MC_Value_Controller(this);
    connections.add(m);
    toLayerTop();
    setLayer(layer);
    return m;
  }
  
  void clear() {
    super.clear();
    tick.clear();
    for (nWidget w : widgets) w.clear(); }
  void to_save(Save_Bloc bloc) { 
    super.to_save(bloc); 
    Save_Bloc co_blocs = bloc.newBloc("cos");
    for (MC_Connexion m : connections) { m.to_save(co_blocs.newBloc("co")); }
    
  }
  void from_save(Save_Bloc bloc) { 
    Save_Bloc co_blocs = bloc.getBloc("cos");
    if (co_blocs != null) co_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { 
        if      (bloc.getData("def").equals("ctrl"))  addValueController().from_save(bloc);
        else if (bloc.getData("def").equals("watch")) addValueWatcher().from_save(bloc);
        else if (bloc.getData("def").equals("run")) addRun().from_save(bloc);
      } } );
    super.from_save(bloc); 
  }
  void setLayer(int l) {
    super.setLayer(l);
    for (nWidget w : widgets) w.setLayer(l); }
  void toLayerTop() {
    super.toLayerTop();
    for (nWidget w : widgets) w.toLayerTop(); }
  void childDragged() {}
}
