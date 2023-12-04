


//void mysetup() {
  
//  //Macro_Custom m = new Macro_Custom(gui, macro_main, 0, 0)
//  //  .addValueWatcher(gcom.OLD_AGE)
//  //    .getMacro()
//  //  ;
//  //macro_main.adding(m);
//  //macro_main.childDragged();
//}





class MC_Connection {
  Macro_Custom parent;
  String def = null;
  
  MC_Connection(Macro_Custom _p, String d) {
    parent = _p;
    def = d;
  }
  
  Macro_Custom getMacro() { return parent; }
  
  MC_Connection addTickEvent(Runnable r) { parent.tickEvents.add(r); return this; }
  void to_save(Save_Bloc bloc) {
    bloc.newData("def", def);
  }
  void from_save(Save_Bloc bloc) {
    
  }
}



class MC_Value_Watcher extends MC_Connection {
  Macro_Output out;
  sFlt val;
  nWidget label;
  MC_Value_Watcher(Macro_Custom _p, sFlt v) {
    super(_p, "flt watch");
    val = v;
    out = parent.addExtOutput();
    addTickEvent(new Runnable() { public void run() {
      if (val != null) out.send(newFloat(val.get()));
    }});
    
    label = new nWidget(parent.gui, "--", int(parent.macro_size/1.5), -parent.macro_size*0.125, 0, parent.macro_size*2.5, parent.macro_size)
      .setStandbyColor(color(255, 50))
      .setParent(out.connect)
      .stackLeft()
      .addEventFrame_Builder(new Runnable() { public void run() {
        if (val != null)  {
          ((nWidget)builder).setText(val.name);
        }
      }})
      ;
    parent.widgets.add(label);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (val != null) bloc.newData("val", val.name);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("val") != null) {
      for (sFlt v : simval.sfltlist) if (v.name.equals(bloc.getData("val"))) { val = v; break; }
    }
  }
}

class MC_Value_Controller extends MC_Connection {
  Macro_Input in;
  sFlt val;
  nWidget label;
  MC_Value_Controller(Macro_Custom _p, sFlt v) {
    super(_p, "flt ctrl");
    val = v;
    in = parent.addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        if (in.getLastPacket().isFloat() && val != null) val.set(in.getLastPacket().asFloat());
      }})
      ;
    label = new nWidget(parent.gui, "--", int(parent.macro_size/1.5), parent.macro_size*0.125, 0, parent.macro_size*2.5, parent.macro_size)
      .setStandbyColor(color(255, 50))
      .setParent(in.connect)
      .stackRight()
      .addEventFrame_Builder(new Runnable() { public void run() {
        if (val != null)  {
          ((nWidget)builder).setText(val.name);
        }
      }})
      ;
    parent.widgets.add(label);
  }
  void to_save(Save_Bloc bloc) {
    super.to_save(bloc);
    if (val != null) bloc.newData("val", val.name);
  }
  void from_save(Save_Bloc bloc) {
    super.from_save(bloc);
    if (bloc.getData("val") != null) {
      for (sFlt v : simval.sfltlist) if (v.name.equals(bloc.getData("val"))) { val = v; break; }
    }
  }
}



class Macro_Custom extends Macro_Abstract {
  Tickable tick;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  
  ArrayList<Runnable> tickEvents = new ArrayList<Runnable>();
  
  ArrayList<MC_Connection> connections = new ArrayList<MC_Connection>();
  
  Macro_Custom(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "custom", x, y);
    setWidth(macro_size*4);
    
    
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        runEvents(tickEvents);
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  
  MC_Value_Watcher addValueWatcher(sFlt v) {
    MC_Value_Watcher m = new MC_Value_Watcher(this, v);
    connections.add(m);
    toLayerTop();
    setLayer(layer);
    return m;
  }
  
  MC_Value_Controller addValueController(sFlt v) {
    MC_Value_Controller m = new MC_Value_Controller(this, v);
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
    for (MC_Connection m : connections) { m.to_save(co_blocs.newBloc("co")); }
    
  }
  void from_save(Save_Bloc bloc) { 
    Save_Bloc co_blocs = bloc.getBloc("cos");
    if (co_blocs != null) co_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { 
        if      (bloc.getData("def").equals("flt ctrl"))  addValueController(null).from_save(bloc);
        else if (bloc.getData("def").equals("flt watch")) addValueWatcher(null).from_save(bloc);
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
