

SpecialValue sv = new SpecialValue();

sFlt val = new sFlt(sv, 0);

void mysetup() {
  ms = new Macro_Main(gui, tickpile, 70, 20);
  //ms.addSheet();
  //ms.do_load();
  Macro_Custom m = new Macro_Custom(gui, ms, 0, 0)
    .addValueWatcher(val)
      .getMacro()
    ;
  ms.adding(m);
  ms.childDragged();
}





class MC_Connection {
  Macro_Custom parent;
  
  MC_Connection(Macro_Custom _p) {
    parent = _p;
  }
  
  Macro_Custom getMacro() { return parent; }
  
  MC_Connection addTickEvent(Runnable r) { parent.tickEvents.add(r); return this; }
}



class MC_Value_Watcher extends MC_Connection {
  Macro_Output out;
  sFlt val;
  MC_Value_Watcher(Macro_Custom _p, sFlt v) {
    super(_p);
    out = parent.addExtOutput();
    addTickEvent(new Runnable() { public void run() {
      out.send(newFloat(val.get()));
    }});
  }
}



class Macro_Custom extends Macro_Abstract {
  Tickable tick;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  
  ArrayList<Runnable> tickEvents = new ArrayList<Runnable>();
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
    return m;
  }
  
  void clear() {
    super.clear();
    tick.clear();
    for (nWidget w : widgets) w.clear(); }
  void to_save(Save_Bloc bloc) { super.to_save(bloc); }
  void from_save(Save_Bloc bloc) { super.from_save(bloc); }
  void setLayer(int l) {
    super.setLayer(l);
    for (nWidget w : widgets) w.setLayer(l); }
  void toLayerTop() {
    super.toLayerTop();
    for (nWidget w : widgets) w.toLayerTop(); }
  void childDragged() {}
}
