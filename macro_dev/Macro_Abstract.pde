
//objet de base des bloc macro

/*
peut etre contenue dans un bloc parent et contenir des enfant
a une liste d'entre sortie connectable entre eux
peut s'attacher une connection presente dans l'espace du bloc parent
a des widget pour etre bouger (grabber) et detruit 
a des widget invisible comme ref de position pour les connection et les widget custom
a un widget en background
*/

abstract class Macro_Abstract {
  
  ArrayList<Macro_Input> extinputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> extoutputs = new ArrayList<Macro_Output>(0);
  
  Macro_Sheet parent;
  
  nGUI gui;
  
  float macro_size = 20;
  int layer = 0;
  nWidget grabber, inputs_ref, outputs_ref, panel, back, closer, front;
  
  float sheet_width = macro_size;
  String name = null;
  
  boolean isHided = false;
  
  void hide() {
    isHided = true;
    grabber.hide(); inputs_ref.hide(); outputs_ref.hide(); panel.hide(); back.hide(); closer.hide(); 
    for (Macro_Input m : extinputs) m.hide();
    for (Macro_Output m : extoutputs) m.hide();
  }
  void show() {
    isHided = false;
    grabber.show(); inputs_ref.show(); outputs_ref.show(); panel.show(); back.show(); closer.show(); 
    for (Macro_Input m : extinputs) m.show();
    for (Macro_Output m : extoutputs) m.show();
  }
  
  Macro_Abstract(nGUI _gui, Macro_Sheet p, String n, float x, float y) {
    gui = _gui;
    parent = p;
    name = n;
    if (parent != null) parent.child_macro.add(this);
    
    grabber = new nWidget(gui, name, int(macro_size/1.5), x, y, sheet_width - macro_size * 0.75, macro_size * 0.75)
      .setLayer(layer)
      .addEventDrag(new Runnable() { public void run() { if (parent != null) parent.childDragged(); } } )
      .setGrabbable()
      ;
    if (parent != null) grabber.setParent(parent.grabber);
    closer = new nWidget(gui, "X", int(macro_size/1.5), 0, 0, macro_size * 0.75, macro_size * 0.75)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { clear(); } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(layer)
      ;
    back = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .setStandbyColor(color(180, 60))
      //.stackDown()
      ;
    front = new nWidget(gui, 0, 0)
      .setParent(back)
      .setLayer(layer+1)
      .setStandbyColor(color(255, 0))
      .setOutlineWeight(macro_size/15)
      .addEventFrame(new Runnable() { public void run() { 
        front.setSize(back.getLocalSX(), back.getLocalSY());
        if (gui.szone.isUnder(front)) front.setOutline(true);
        else front.setOutline(false);
      } } )
      //.stackDown()
      ;
    panel = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .stackDown()
      ;
    inputs_ref = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .stackDown()
      ;
    outputs_ref = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .stackDown()
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
    
    //opener = new nWidget(gui, "-", 24, 0, 0, macro_size, macro_size)
    //  .addEventTrigger(new Runnable() { public void run() {
    //    //if (ref.hide) ref.show(); else ref.hide(); 
    //    //if (pan.hide) pan.show(); else pan.hide(); 
    //  } } )
    //  .setParent(grabber)
    //  .stackDown()
    //  .setTrigger()
    //  .setLayer(layer)
    //  ;
  }
  void setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l); front.setLayer(l);
    for (Macro_Input m : extinputs) m.connect.setLayer(l);
    for (Macro_Output m : extoutputs) { m.connect.setLayer(l); m.line_drawer.setLayer(l+1); }
  }
  void toLayerTop() {
    back.toLayerTop();
    for (Macro_Input m : extinputs) m.connect.toLayerTop();
    for (Macro_Output m : extoutputs) { m.connect.toLayerTop(); m.line_drawer.toLayerTop(); }
    grabber.toLayerTop();
    closer.toLayerTop(); front.toLayerTop();
  }
  
  
  
  void to_string(String[] s, int id) {
    log("to string abstract");
    s[id] = name.substring(0, name.length());
    int vnb = 7;
    for (Macro_Input v : extinputs) vnb += v.size();
    for (Macro_Output v : extoutputs) vnb += v.size();
    s[id+1] = str(vnb);
    s[id+2] = str(grabber.getLocalX());
    s[id+3] = str(grabber.getLocalY());
    s[id+4] = str(sheet_width);
    log("id " + id + " name " + s[id] + " size " + s[id+1] + 
        " px " + s[id+2] + " py " + s[id+3] + " w " + s[id+4]);
    id+=5;
    
    vnb = 0;
    for (Macro_Input v : extinputs) vnb += v.size();
    s[id] = str(vnb);
    log("extin nb " + id + " " + s[id]); 
    id++;
    for (Macro_Input v : extinputs) {
      v.to_string(s, id);
      id += v.size(); }
      
    vnb = 0;
    for (Macro_Output v : extoutputs) vnb += v.size();
    s[id] = str(vnb);
    log("extout nb " + id + " " + s[id]); 
    id++;
    for (Macro_Output v : extoutputs) {
      v.to_string(s, id);
      id += v.size(); }
    log("end to string abstract");
  }
  void from_string(String[] s, int id) {
    log("from string abstract");
    name = s[id].substring(0, s[id].length());
    grabber.setPX(float(s[id+2]))
      .setPY(float(s[id+3]));
    setWidth(float(s[id+4]));
    log("id " + id + " name " + s[id] + " size " + s[id+1] + 
        " px " + s[id+2] + " py " + s[id+3] + " w " + s[id+4]);
    id+=5;
    int l = int(s[id]);
    log("ext in nb " + id + " " + s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Input m = extinputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    log("ext out nb " + id + " " + s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Output m = extoutputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
    log("end from string abstract");
  }
  int size() {
    int vnb = 7;
    for (Macro_Input v : extinputs) vnb += v.size();
    for (Macro_Output v : extoutputs) vnb += v.size();
    return vnb;
  }
  void clear() {
    for (Macro_Input m : extinputs) m.clear(); extinputs.clear();
    for (Macro_Output m : extoutputs) m.clear(); extoutputs.clear();
    if (parent != null) parent.child_macro.remove(this);
    grabber.clear(); inputs_ref.clear(); outputs_ref.clear(); 
    panel.clear(); back.clear(); closer.clear(); front.clear();
    parent.childDragged();
  }
  
  Macro_Abstract setWidth(float w) {
    sheet_width = w;
    if (inCount > 1) w += macro_size;
    if (outCount > 1) w += macro_size;
    grabber.setSX(w - macro_size * 0.75);
    back.setSX(w);
    outputs_ref.setPX(w - macro_size);
    return this;
  }
  
  float getW() {
    return back.getSX(); }
  float getH() {
    return back.getSY(); }
  
  abstract void childDragged();
  
  void up_back() {
    int h = max(inCount, outCount);
    back.setSY(h * macro_size * 1.125 + macro_size * 0.875);
    if (inCount > 0) panel.setPX(macro_size + macro_size / 8);
  }
  
  int inCount = 0;
  int outCount = 0;
  
  Macro_Input addExtInput() {
    Macro_Input m = new Macro_Input(gui, parent, 0, inCount * macro_size * 1.125 + macro_size / 8 )
      .setParent(inputs_ref)
      ;
    extinputs.add(m);
    inCount++;
    up_back();
    return m;
  }
  
  Macro_Output addExtOutput() {
    Macro_Output m = new Macro_Output(gui, parent, 0, outCount * macro_size * 1.125 + macro_size / 8 )
      .setParent(outputs_ref)
      ;
    extoutputs.add(m);
    outCount++;
    up_back();
    return m;
  }
  
  Macro_Abstract addLine() { if (inCount >= outCount) inCount++; else outCount++; return this; }
  
  float getLastLineY() { 
    if (inCount >= outCount) return (inCount-1) * macro_size + macro_size / 8; 
    else                     return (outCount-1) * macro_size + macro_size / 8; 
  }
  
  Macro_Main getBase() { if (parent == null) return (Macro_Main)this; return parent.getBase(); }
  
}
