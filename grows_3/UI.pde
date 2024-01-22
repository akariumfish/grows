

/*

Global GUI Theme 
 can be picked from by widgets 
 ? list of widgets to update when is changed ?
 map of color and name
 map of size and name
 map<name, widget> models
 methods to directly build a widget from models
 
 


*/



//conteneur de presets
class nTheme {
  float ref_size = 30;
  nTheme(float s) { ref_size = s; new nConstructor(this, s); }
  HashMap<String, nWidget> models = new HashMap<String, nWidget>();
  nTheme addModel(String r, nWidget w) { models.put(r,w); return this; }
  nWidget getModel(String r) {  return models.get(r); }
  nLook getLook(String r) { return models.get(r).look; }
  nWidget newWidget(String r) { //only for theme model making !!
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget().copy(m); }
    return null; }
  nWidget newWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget(g).copy(m); }
    return null; }
  nLinkedWidget newLinkedWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nLinkedWidget lw = new nLinkedWidget(g); lw.copy(m); return lw; }
    return null; }
  nWatcherWidget newWatcherWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nWatcherWidget lw = new nWatcherWidget(g); lw.copy(m); return lw; }
    return null; }
  nCtrlWidget newCtrlWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      nCtrlWidget lw = new nCtrlWidget(g); lw.copy(m); return lw; }
    return null; }
}






//drawing point
class nGUI {
  
  nGUI setMouse(PVector v) { mouseVector = v; return this; }
  nGUI setpMouse(PVector v) { pmouseVector = v; return this; }
  nGUI setView(Rect v) { view = v; scale = base_width / view.size.x; return this; }
  nGUI updateView() { scale = base_width / view.size.x; return this; }
  nGUI setTheme(nTheme v) { theme = v; return this; }
  nGUI addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  nGUI removeEventFrame(Runnable r) { eventsFrame.remove(r); return this; }
  nGUI addEventsFullScreen(Runnable r) { eventsFullScreen.add(r); return this; }
  nGUI addEventFound(Runnable r) { hoverable_pile.addEventFound(r); return this; }
  nGUI addEventNotFound(Runnable r) { hoverable_pile.addEventNotFound(r); return this; }
  nGUI addEventSetup(Runnable r) { eventsSetup.add(r);  return this; }
  
  nGUI(sInput _i, nTheme _t, float _ref_size) {
    in = _i; theme = _t; if (theme == null) theme = new nTheme(_ref_size);
    mouseVector = in.mouse; pmouseVector = in.pmouse;
    ref_size = _ref_size;
    view = new Rect(0, 0, width, height);
    info = new nInfo(this, ref_size*0.75);
    addEventsFullScreen(new Runnable(this) { public void run() { 
      view.size.set(width, height); updateView();
    } } );
  }
  
  sInput in;
  nTheme theme;
  nInfo info;
  Rect view;
  float scale = 1;
  float ref_size = 30;
  boolean isShown = true;
  boolean field_used = false;
  
  Drawing_pile drawing_pile = new Drawing_pile();
  Hoverable_pile hoverable_pile = new Hoverable_pile();
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsFullScreen = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsSetup = new ArrayList<Runnable>();
  boolean is_starting = true;
  PVector mouseVector = null, pmouseVector = null;
  boolean hoverpile_passif = false;
  
  void frame() {
    hoverable_pile.search(mouseVector, hoverpile_passif);
    if (is_starting) { is_starting = false; runEvents(eventsSetup); }
    runEvents(eventsFrame); 
    clearEvents(eventsFrame); 
    //logln(""+eventsFrame.size());
  }
  void draw() {
    if (isShown) drawing_pile.drawing(); }
}





//liens avec les svalues
class nLinkedWidget extends nWidget { 
  nLinkedWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("str")) setLinkedValue((sStr)b);
    if (b.type.equals("run")) setLinkedValue((sRun)b);
    if (b.type.equals("vec")) setLinkedValue((sVec)b);
    return this; }
  sBoo bval; sInt ival; sFlt fval; sStr sval; sRun rval; sVec vval;
  String base_text = "";
  nLinkedWidget(nGUI g) { super(g); }
  
  nLinkedWidget setLinkedValue(sRun b) { 
    rval = b;
    addEventTrigger(new Runnable(this) { public void run() { 
      rval.run(); } } );
    setTrigger();
    return this; }
  nLinkedWidget setLinkedValue(sBoo b) { 
    bval = b;
    setSwitch();
    if (b.get()) setOn();
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).setSwitchState(bval.get()); } } );
    addEventSwitchOn(new Runnable() { public void run() { bval.set(true); } } );
    addEventSwitchOff(new Runnable() { public void run() { bval.set(false); } } );
    return this; }
  nLinkedWidget setLinkedValue(sInt b) { 
    ival = b;
    setText(str(ival.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(str(ival.get())); } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      if (!(s.length() > 0 && int(s) == 0) && !str(int(s)).equals("NaN")) ival.set(int(s)); } } );
    return this; }
  nLinkedWidget setLinkedValue(sFlt b) { 
    fval = b;
    setText(trimStringFloat(fval.get()));
    //println(fval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(trimStringFloat(fval.get()));  } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      if (!str(float(s)).equals("NaN")) fval.set(float(s)); } } );
      //!(s.length() > 0 && float(s) == 0) && 
    return this; }
  nLinkedWidget setLinkedValue(sVec b) { 
    vval = b;
    setGrabbable();
    setPosition(vval.x(), vval.y());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).setPosition(vval.x(), vval.y()); } } );
    addEventPositionChange(new Runnable(this) { public void run() { 
      vval.set(((nLinkedWidget)builder).getLocalX(), ((nLinkedWidget)builder).getLocalY()); } } );
    return this; }
  nLinkedWidget setLinkedValue(sStr b) { 
    if (sval == null) base_text = getText();
    sval = b;
    setText(base_text + sval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nLinkedWidget)builder).changeText(base_text + sval.get()); } } );
    setField(true);
    addEventFieldChange(new Runnable(this) { public void run() { 
      String s = ((nLinkedWidget)builder).getText();
      sval.set(s); } } );
    return this; }
}

//liens avec les svalues
class nWatcherWidget extends nWidget {
  nWatcherWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("str")) setLinkedValue((sStr)b);
    if (b.type.equals("vec")) setLinkedValue((sVec)b);
    if (b.type.equals("col")) setLinkedValue((sCol)b);
    return this; }
  sBoo bval; sInt ival; sFlt fval; sStr sval; sVec vval; sCol cval;
  String base_text = "";
  nWatcherWidget(nGUI g) { super(g); }
  nWatcherWidget setLinkedValue(sInt b) { 
    ival = b; setText(str(ival.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(str(ival.get())); } } );
    return this; }
  nWatcherWidget setLinkedValue(sFlt b) { 
    fval = b; setText(trimStringFloat(fval.get()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(trimStringFloat(fval.get())); } } );
    return this; }
  nWatcherWidget setLinkedValue(sBoo b) { 
    bval = b; 
    if (bval.get()) setText("true"); else setText("false");
    b.addEventChange(new Runnable(this) { public void run() { 
      if (bval.get()) ((nWatcherWidget)builder).setText("true");
      else ((nWatcherWidget)builder).setText("false"); } } );
    return this; }
  nWatcherWidget setLinkedValue(sStr b) { 
    if (sval == null) base_text = getText();
    sval = b;
    setText(base_text + sval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).changeText(base_text + sval.get()); } } );
    return this; }
  nWatcherWidget setLinkedValue(sCol b) { 
    cval = b; setStandbyColor(cval.get());
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setStandbyColor(cval.get()); } } );
    return this; }
  nWatcherWidget setLinkedValue(sVec b) { 
    vval = b; 
    setText(trimStringFloat(vval.x()) + "," + trimStringFloat(vval.y()));
    b.addEventChange(new Runnable(this) { public void run() { 
      ((nWatcherWidget)builder).setText(trimStringFloat(vval.x()) + "," + trimStringFloat(vval.y())); } } );
    return this; }
}

//liens avec les svalues
class nCtrlWidget extends nWidget {
  nCtrlWidget setLinkedValue(sValue b) { 
    if (b.type.equals("flt")) setLinkedValue((sFlt)b);
    if (b.type.equals("int")) setLinkedValue((sInt)b);
    if (b.type.equals("boo")) setLinkedValue((sBoo)b);
    if (b.type.equals("run")) setLinkedValue((sRun)b);
    return this; }
  nCtrlWidget setRunnable(Runnable b) { 
    rval = b; setTrigger();
    addEventTrigger(new Runnable(this) { public void run() { rval.run(); } } ); return this; }
  nCtrlWidget setLinkedValue(sRun b) { 
    srval = b; setTrigger();
    addEventTrigger(new Runnable(this) { public void run() { srval.run(); } } ); return this; }
  nCtrlWidget setLinkedValue(sBoo b) { 
    bval = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  nCtrlWidget setLinkedValue(sInt b) { 
    ival = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  nCtrlWidget setLinkedValue(sFlt b) { 
    fval = b; setTrigger(); 
    addEventTrigger(new Runnable(this) { public void run() { modify(); } } ); return this; }
  nCtrlWidget setIncrement(float f) { mode = false; factor = f; return this; }
  nCtrlWidget setFactor(float f) { mode = true; factor = f; return this; }
  
  nCtrlWidget(nGUI g) { super(g); }
  Runnable rval;
  sBoo bval; sInt ival; sFlt fval; sRun srval;
  float factor = 2.0; boolean mode = false;
  void modify() {
    if (bval != null) bval.set(!bval.get());
    if (ival != null) { if (mode) ival.set(int(ival.get()*factor)); else ival.set(int(ival.get()+factor)); }
    if (fval != null) { if (mode) fval.set(fval.get()*factor); else fval.set(fval.get()+factor); }
  }
}







//manage look
class sLook extends sValue {
  String getString() { return ""; }
  void clear() { }
  nLook val = new nLook();
  sLook(sValueBloc b, nLook v, String n, String s) { super(b, "look", n, s); val.copy(v); }
  nLook get() { return val; }
  void set(nLook v) { if (!v.ref.equals(val.ref)) has_changed = true; val.copy(v); }
}


//colors n thickness
class nLook {
  nLook copy(nLook l) {
    ref = l.ref.substring(0, l.ref.length());;
    standbyColor = l.standbyColor; pressColor = l.pressColor; 
    hoveredColor = l.hoveredColor; outlineColor = l.outlineColor;
    outlineSelectedColor = l.outlineSelectedColor; textColor = l.textColor;
    textFont = l.textFont; outlineWeight = l.outlineWeight;
    return this;
  }
  void clear() {}
  nLook() { }
  String ref = "def";
  color standbyColor = color(80), hoveredColor = color(110), pressColor = color(130), 
        outlineColor = color(255), outlineSelectedColor = color(255, 255, 0), textColor = color(255);
  int textFont = 24; float outlineWeight = 1;
}




class nSlide extends nWidget {
  nSlide setLinkedValue(sValue v) {
    
    return this;
  }
  nSlide setValue(float v) {
    if (v < 0) v = 0; if (v > 1) v = 1;
    curs.setPX(v * (bar.getLocalSX() - curs.getLocalSX()));
    cursor_value = v;
    return this;
  }
  nWidget addEventSlide(Runnable r)   { eventSlide.add(r); return this; }
  nWidget addEventLiberate(Runnable r)   { eventLiberate.add(r); return this; }
  nWidget addEventSlide_Builder(Runnable r)   { r.builder = this; eventSlide.add(r); return this; }
  
  nWidget bar, curs;
  sValue val;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float scale_height, scale_width;
  float cursor_value = 0;
  ArrayList<Runnable> eventSlide = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLiberate = new ArrayList<Runnable>();
  nSlide(nGUI g, float _scale_width, float _scale_height) { super(g); 
    scale_height = _scale_height; scale_width = _scale_width;
    bar = new nWidget(gui, 0, scale_height * 3 / 8, _scale_width, scale_height * 1 / 4).setParent(this);
    curs = new nWidget(gui, 0, -scale_height * 3 / 8, scale_height * 1 / 4, scale_height)
      .setParent(bar)
      .setStandbyColor(color(200))
      .setGrabbable().setConstrainY(true)
      .addEventDrag(new Runnable() { public void run() {
        if (curs.getLocalX() < 0) curs.setPX(0);
        if (curs.getLocalX() > bar.getLocalSX() - curs.getLocalSX()) 
          curs.setPX(bar.getLocalSX() - curs.getLocalSX());
        cursor_value = curs.getLocalX() / (bar.getLocalSX() - curs.getLocalSX());
        runEvents(eventSlide, cursor_value);
      }})
      .addEventLiberate(new Runnable() { public void run() {
        runEvents(eventLiberate);
      }});
    widgets.add(bar);
    widgets.add(curs);
  }
  nSlide setLayer(int l) { super.setLayer(l); for (nWidget w : widgets) w.setLayer(l); return this; }
  nSlide toLayerTop() { super.toLayerTop(); for (nWidget w : widgets) w.toLayerTop(); return this; }
  void clear() { for (nWidget w : widgets) w.clear(); super.clear(); }
}






class nWidget {
  
  //nWidget setPanelDrawer(nPanelDrawer d) { pan_drawer = d; return this; }
  //nPanelDrawer getPanelDrawer() { return pan_drawer; }
  nWidget setDrawer(nDrawer d) { ndrawer = d; return this; }
  nDrawer getDrawer() { return ndrawer; }
  nShelf getShelf() { return ndrawer.shelf; }
  nShelfPanel getShelfPanel() { return ndrawer.shelf.shelfPanel; }
  
  nWidget addEventPositionChange(Runnable r)   { eventPositionChange.add(r); return this; }
  nWidget addEventShapeChange(Runnable r)      { eventShapeChange.add(r); return this; }
  nWidget addEventLayerChange(Runnable r)      { eventLayerChange.add(r); return this; }
  nWidget addEventVisibilityChange(Runnable r) { eventVisibilityChange.add(r); return this; }
  
  nWidget addEventClear(Runnable r)      { eventClear.add(r); return this; }
  
  nWidget addEventFrame(Runnable r)      { eventFrameRun.add(r); return this; }
  nWidget addEventFrame_Builder(Runnable r) { eventFrameRun.add(r); r.builder = this; return this; }
  
  nWidget addEventGrab(Runnable r)       { eventGrabRun.add(r); return this; }
  nWidget addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  nWidget removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  nWidget addEventLiberate(Runnable r)   { eventLiberateRun.add(r); return this; }
  
  nWidget addEventMouseEnter(Runnable r) { eventMouseEnterRun.add(r); return this; }
  nWidget addEventMouseLeave(Runnable r) { eventMouseLeaveRun.add(r); return this; }
  
  nWidget addEventPressed(Runnable r)      { eventPressRun.add(r); return this; }
  nWidget addEventRelease(Runnable r)    { eventReleaseRun.add(r); return this; }
  
  nWidget addEventTrigger(Runnable r)         { eventTriggerRun.add(r); return this; }
  nWidget removeEventTrigger(Runnable r)      { eventTriggerRun.remove(r); return this; }
  nWidget clearEventTrigger()                 { eventTriggerRun.clear(); return this; }
  nWidget addEventTrigger_Builder(Runnable r) { eventTriggerRun.add(r); r.builder = this; return this; }
  
  nWidget addEventSwitchOn(Runnable r)   { eventSwitchOnRun.add(r); return this; }
  nWidget addEventSwitchOn_Builder(Runnable r)   { r.builder = this; eventSwitchOnRun.add(r); return this; }
  nWidget addEventSwitchOff(Runnable r)  { eventSwitchOffRun.add(r); return this; }
  nWidget clearEventSwitchOn()   { eventSwitchOnRun.clear(); return this; }
  nWidget clearEventSwitchOff()  { eventSwitchOffRun.clear(); return this; }
  
  nWidget addEventFieldChange(Runnable r) { eventFieldChangeRun.add(r); return this; }
  
  nWidget setDrawable(Drawable d) { 
    gui.drawing_pile.drawables.remove(drawer); 
    drawer.clear();
    drawer = d; 
    if (drawer != null) {
      drawer.setLayer(layer); 
      gui.drawing_pile.drawables.add(d); 
    }
    return this; 
  }
  
  nWidget setLayer(int l) { 
    layer = l; 
    if (drawer != null) drawer.setLayer(layer); 
    if (hover != null) hover.setLayer(layer); 
    runEvents(eventLayerChange); 
    return this; 
  }
  
  nWidget toLayerTop() {
    if (drawer != null) drawer.toLayerTop();
    if (hover != null) hover.toLayerTop();
    return this;
  }
  
  nWidget setParent(nWidget p) { 
    if (parent != null) parent.childs.remove(this); 
    if (p != null) { parent = p; p.childs.add(this); changePosition(); } return this; }
  nWidget clearParent() { 
    if (parent != null) { parent.childs.remove(this); parent = null; changePosition(); } return this; }
  
  nWidget setText(String s) { if (s != null) { label = s; cursorPos = label.length(); } return this; }
  nWidget changeText(String s) { label = s; if (cursorPos > label.length()) cursorPos = label.length(); return this; }
  nWidget setFont(int s) { look.textFont = s; return this; }
  nWidget setTextAlignment(int sx, int sy) { textAlignX = sx; textAlignY = sy; return this; }
  nWidget setTextVisibility(boolean s) { show_text = s; return this; }
  nWidget setInfo(String s) { if (s != null) { infoText = s; showInfo = true; } return this; }
  nWidget setNoInfo() { showInfo = false; return this; }
  
  nWidget setLook(nLook l) { look.copy(l); return this; }
  nWidget setLook(nTheme t, String r) { look.copy(t.getLook(r)); return this; }
  nWidget setLook(String r) { look.copy(gui.theme.getLook(r)); return this; }
  
  nWidget hide() { 
    if (!hide) {
      hide = true; 
      changePosition(); 
      if (drawer != null) { drawerHideState = drawer.active; drawer.active = false; }
      if (hover != null) { hoverHideState = hover.active; hover.active = false; }
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.hide(); 
    }
    return this; 
  }
  nWidget show() { 
    if (hide) {
      hide = false; 
      changePosition(); 
      if (drawer != null) drawer.active = drawerHideState; 
      if (hover != null) hover.active = hoverHideState; 
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.show(); 
    }
    return this; 
  }
  
  nWidget copy(nWidget w) {
  //eventFrameRun.clear(); for (Runnable r : w.eventFrameRun) eventFrameRun.add(r);
  
  //ArrayList<Runnable> eventPositionChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventShapeChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventLayerChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventVisibilityChange = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventClear = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventFrameRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventGrabRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventLiberateRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventMouseEnterRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventMouseLeaveRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventPressRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventReleaseRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventTriggerRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventSwitchOnRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventSwitchOffRun = new ArrayList<Runnable>();
  //ArrayList<Runnable> eventFieldChangeRun = new ArrayList<Runnable>();
    triggerMode = w.triggerMode; switchMode = w.switchMode;
    grabbable = w.grabbable; constrainX = w.constrainX; constrainY = w.constrainY;
    isSelectable = w.isSelectable; isField = w.isField; 
    showCursor = w.showCursor; hoverOutline = w.hoverOutline; showOutline = w.showOutline;
    alignX = w.alignX; stackX = w.stackX; alignY = w.alignY; stackY = w.stackY; centerX = w.centerX; centerY = w.centerY;
    placeLeft = w.placeLeft; placeRight = w.placeRight; placeUp = w.placeUp; placeDown = w.placeDown;
    hide = w.hide; drawerHideState = w.drawerHideState; hoverHideState = w.hoverHideState;
    constantOutlineWeight = w.constantOutlineWeight;
    textAlignX = w.textAlignX; textAlignY = w.textAlignY; show_text = w.show_text;
    shapeRound = w.shapeRound; shapeLosange = w.shapeLosange; 
    showInfo = w.showInfo; infoText = str_copy(w.infoText);
    constrainDlength = w.constrainDlength; constrainD = w.constrainD;
    look.copy(w.look);
    setLayer(w.layer);
    setPosition(w.localrect.pos.x, w.localrect.pos.y);
    setSize(w.localrect.size.x, w.localrect.size.y);
    changePosition();
    if (hover != null && w.hover != null) hover.active = w.hover.active;
    if (w.parent != null) setParent(w.parent);
    //if (hover != null && (isSelectable || grabbable || triggerMode || switchMode) && !hide) hover.active = true;
    return this;
  }
  
  void clear() {
    //if (ndrawer != null) ndrawer.widgets.remove(this);
    for (nWidget w : childs) w.clear();
    runEvents(eventClear);
    //if (gui != null) gui.removeEventFrame(frame_run);
    frame_run.to_clear = true;
    //if (look != null) look.clear(); 
    //look = null;
    if (drawer != null) drawer.clear(); if (hover != null) hover.clear();
    drawer = null; hover = null;
    eventPositionChange.clear(); eventShapeChange.clear(); eventLayerChange.clear(); 
    eventVisibilityChange.clear(); eventClear.clear(); eventFrameRun.clear(); 
    eventGrabRun.clear(); eventDragRun.clear(); eventLiberateRun.clear(); eventFieldChangeRun.clear();
    eventMouseEnterRun.clear(); eventMouseLeaveRun.clear(); eventPressRun.clear(); eventReleaseRun.clear();
    eventTriggerRun.clear(); eventSwitchOnRun.clear(); eventSwitchOffRun.clear(); eventFieldChangeRun.clear();
  }
  
  nGUI getGUI() { return gui; }
  Rect getRect() { return globalrect; }
  Rect getPhantomRect() { return phantomrect; } //rect exist enven when hided ; for hided collisions
  int getLayer() { return layer; }
  String getText() { return label.substring(0, label.length()); }
  
  boolean isClicked() { return isClicked; }
  boolean isHovered() { return isHovered; }
  boolean isGrabbed() { return isGrabbed; }
  boolean isField() { return isField; }
  boolean isHided() { return hide; }
  boolean isOn() { return switchState; }
  
  
  
  nWidget setHoverablePhantomSpace(float f) { if (hover != null) hover.phantom_space = f; return this; }
  
  nWidget setPassif() { 
    triggerMode = false; 
    switchMode = false; 
    switchState = false; 
    grabbable = false; 
    isField = false;
    isClicked = false;
    if (hover != null) { hover.active = false; hoverHideState = hover.active; }
    return this; }
  nWidget setBackground() { 
    triggerMode = false; 
    switchMode = false; 
    switchState = false; 
    grabbable = false; 
    isField = false; 
    isClicked = false;
    if (hover != null) { hover.active = true; hoverHideState = hover.active; }
    return this; }
  nWidget setTrigger() { 
    triggerMode = true; switchMode = false; switchState = false; 
    if (hover != null) hover.active = true; if (hover != null) hoverHideState = hover.active; return this; }
  nWidget setSwitch() { 
    triggerMode = false; switchMode = true; switchState = false; 
    if (hover != null) hover.active = true; if (hover != null) hoverHideState = hover.active; return this; }
  
  //carefull!! dont work if excluded cleared before this
  private ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  nWidget addExclude(nWidget b) { excludes.add(b); return this; }
  nWidget removeExclude(nWidget b) { excludes.remove(b); return this; }
  
  nWidget setGrabbable() { triggerMode = true; grabbable = true; hover.active = true; hoverHideState = hover.active; return this; }
  nWidget setFixed() { grabbable = false; hover.active = false; hoverHideState = hover.active; return this; }
  nWidget setConstrainX(boolean b) { constrainX = b; return this; }
  nWidget setConstrainY(boolean b) { constrainY = b; return this; }
  nWidget setConstrainDistance(float b) { if (b == 0) constrainD = false; else { constrainDlength = b; constrainD = true; } return this; }
  nWidget setSelectable(boolean o) { isSelectable = o; hoverOutline = o; hover.active = true; hoverHideState = hover.active; return this; }
  nWidget setField(boolean o) { isField = o; setSelectable(o); return this; }
  
  nWidget setOutline(boolean o) { showOutline = o; return this; }
  nWidget setOutlineWeight(float l) { look.outlineWeight = l; return this; }
  nWidget setOutlineConstant(boolean l) { constantOutlineWeight = l; return this; }
  
  nWidget setHoveredOutline(boolean o) { hoverOutline = o; return this; }
  
  nWidget setPosition(float x, float y) { setPX(x); setPY(y); return this; }
  nWidget setPosition(PVector p) { setPX(p.x); setPY(p.y); return this; }
  nWidget setSize(float x, float y) { setSX(x); setSY(y); return this; }
  
  nWidget setPX(float v) { 
    if (v != localrect.pos.x) { localrect.pos.x = v; changePosition(); return this; } return this; }
  nWidget setPY(float v) { 
    if (v != localrect.pos.y) { localrect.pos.y = v; changePosition(); return this; } return this; }
  nWidget setSX(float v) { 
    if (v != localrect.size.x) { 
      localrect.size.x = v; 
      globalrect.size.x = getSX(); 
      if (stackX && placeLeft) globalrect.pos.x = getX(); 
      for (nWidget w : childs) 
        if (((w.stackX || w.alignX) && w.placeRight) || ((stackX || alignX) && placeLeft)) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  nWidget setSY(float v) { 
    if (v != localrect.size.y) { 
      localrect.size.y = v; 
      globalrect.size.y = getSY(); 
      if (stackY && placeUp) globalrect.pos.y = getY(); 
      for (nWidget w : childs) 
        if (((w.stackY || w.alignY) && w.placeDown) || ((stackY || alignY) && placeUp)) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  
  nWidget setRound(boolean c) { shapeRound = c; return this; }
  nWidget setLosange(boolean c) { shapeLosange = c; return this; }
  
  nWidget setStandbyColor(color c) { look.standbyColor = c; return this; }
  nWidget setHoveredColor(color c) { look.hoveredColor = c; return this; }
  nWidget setClickedColor(color c) { look.pressColor = c; return this; }
  nWidget setLabelColor(color c)   { look.textColor = c; return this; }
  nWidget setOutlineColor(color c) { look.outlineColor = c; return this; }
  nWidget setOutlineSelectedColor(color c) { look.outlineSelectedColor = c; return this; }
  
  nWidget alignUp()    { alignY = true;  stackY = false; placeUp   = true;  placeDown = false;  centerY = false; changePosition(); return this; }
  nWidget alignDown()  { alignY = true;  stackY = false; placeUp   = false; placeDown = true;   centerY = false; changePosition(); return this; }
  nWidget alignLeft()  { alignX = true;  stackX = false; placeLeft = true;  placeRight = false; centerY = false; changePosition(); return this; }
  nWidget alignRight() { alignX = true;  stackX = false; placeLeft = false; placeRight = true;  centerY = false; changePosition(); return this; }
  nWidget stackUp()    { alignY = false; stackY = true;  placeUp   = true;  placeDown = false;  centerX = false; changePosition(); return this; }
  nWidget stackDown()  { alignY = false; stackY = true;  placeUp   = false; placeDown = true;   centerX = false; changePosition(); return this; }
  nWidget stackLeft()  { alignX = false; stackX = true;  placeLeft = true;  placeRight = false; centerX = false; changePosition(); return this; }
  nWidget stackRight() { alignX = false; stackX = true;  placeLeft = false; placeRight = true;  centerX = false; changePosition(); return this; }
  nWidget centerX()    { alignX = false; stackX = false; placeLeft = false; placeRight = false; centerX = true;  changePosition(); return this; }
  nWidget centerY()    { alignX = false; stackX = false; placeLeft = false; placeRight = false; centerY = true;  changePosition(); return this; }
  
  nWidget setSwitchState(boolean s) { if (s) setOn(); else setOff(); return this; }
  void setOn() {
    if (!switchState) {
      switchState = true;
      runEvents(eventSwitchOnRun);
      for (nWidget b : excludes) b.setOff(); }
  }
  void forceOn() {
    switchState = true;
    runEvents(eventSwitchOnRun);
    for (nWidget b : excludes) b.setOff(); }
    
  void setOff() {
    if (switchState) {
      switchState = false;
      runEvents(eventSwitchOffRun); } }
  void forceOff() {
    switchState = false;
    runEvents(eventSwitchOffRun); }
  
  float getX() { 
    if (parent != null) {
      if (alignX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x - getSX();
        else if (placeLeft) return parent.getX() + localrect.pos.x;
      } else if (stackX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x;
        else if (placeLeft) return parent.getX() + localrect.pos.x - getSX();
      } else return localrect.pos.x + parent.getX();
      if (centerX) return parent.getX() + localrect.pos.x - getSX()/2;
    } 
    if (alignX) {
      if (placeRight) return localrect.pos.x - getSX();
      else if (placeLeft) return localrect.pos.x;
    } else if (stackX) {
      if (placeRight) return localrect.pos.x;
      else if (placeLeft) return localrect.pos.x - getSX();
    } 
    if (centerX) return localrect.pos.x - getSX()/2;
    return localrect.pos.x;
  }
  float getY() { 
    if (parent != null) {
      if (alignY) {
        if (placeDown) return parent.getY() + parent.getSY() + localrect.pos.y - getSY();
        else if (placeUp) return parent.getY() + localrect.pos.y;
      } else if (stackY) {
        if (placeDown) return parent.getY() + parent.getSY() + localrect.pos.y;
        else if (placeUp) return parent.getY() + localrect.pos.y - getSY();
      } else return localrect.pos.y + parent.getY();
      if (centerY) return parent.getY() + localrect.pos.y - getSY()/2;
    } 
    if (alignY) {
      if (placeDown) return localrect.pos.y - getSY();
      else if (placeUp) return localrect.pos.y;
    } else if (stackY) {
      if (placeDown) return localrect.pos.y;
      else if (placeUp) return localrect.pos.y - getSY();
    }
    if (centerY) return localrect.pos.y - getSY()/2;
    return localrect.pos.y;
  }
  float getLocalX() { return localrect.pos.x; }
  float getLocalY() { return localrect.pos.y; }
  float getSX() { if (!hide) return localrect.size.x; else return 0; }
  float getSY() { if (!hide) return localrect.size.y; else return 0; }
  float getLocalSX() { return localrect.size.x; }
  float getLocalSY() { return localrect.size.y; }
  
  nWidget() {   //only for theme model saving !!
    localrect = new Rect();
    globalrect = new Rect();
    phantomrect = new Rect();
    hover = new Hoverable(null, null);
    hover.active = true;
    hoverHideState = hover.active; 
    changePosition();
    look = new nLook();
    label = new String();
  }
  nWidget(nGUI g) { init(g); }
  nWidget(nGUI g, float x, float y) {
    init(g);
    setPosition(x, y);
  }
  nWidget(nGUI g, float x, float y, float w, float h) {
    init(g);
    setPosition(x, y);
    setSize(w, h);
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y) {
    init(g);
    label = _label; look.textFont = _text_font;
    setPosition(x, y);
    setSize(label.length() * _text_font, _text_font);
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y, float w, float h) {
    init(g);
    label = _label; look.textFont = _text_font;
    setPosition(x, y);
    setSize(w, h);
  }
  
  protected nGUI gui;
  private Drawable drawer;
  private Hoverable hover;
  private Rect globalrect, localrect, phantomrect;
  private nWidget parent = null;
  private ArrayList<nWidget> childs = new ArrayList<nWidget>();
  private nLook look;
  //private nPanelDrawer pan_drawer = null;
  private nDrawer ndrawer = null;
  
  private String label, infoText;
  private float mx = 0, my = 0, pmx = 0, pmy = 0;
  private int cursorPos = 0;
  private int cursorCount = 0;
  private int cursorCycle = 80;
  
  private boolean switchState = false;
  private boolean isClicked = false;
  private boolean isHovered = false;
  private boolean isGrabbed = false;
  private boolean isSelected = false;
  
  private boolean triggerMode = false, switchMode = false;
  private boolean grabbable = false, constrainX = false, constrainY = false, constrainD = false;
  private float constrainDlength = 0;
  private boolean isSelectable = false, isField = false, showCursor = false;
  private boolean showOutline = false, hoverOutline = false, constantOutlineWeight = false;
  private boolean alignX = false, stackX = false, alignY = false, stackY = false;
  private boolean centerX = false, centerY = false;
  private boolean placeLeft = false, placeRight = false, placeUp = false, placeDown = false;
  private boolean hide = false, drawerHideState = true, hoverHideState = true, show_text = true;
  private boolean shapeRound = false, shapeLosange = false, showInfo = false;
  private int layer = 0, textAlignX = CENTER, textAlignY = CENTER;
 
  ArrayList<Runnable> eventPositionChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventShapeChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLayerChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventVisibilityChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventClear = new ArrayList<Runnable>();
  ArrayList<Runnable> eventFrameRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventGrabRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventLiberateRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventMouseEnterRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventMouseLeaveRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventPressRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventReleaseRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventTriggerRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventSwitchOnRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventSwitchOffRun = new ArrayList<Runnable>();
  ArrayList<Runnable> eventFieldChangeRun = new ArrayList<Runnable>();
  
  private Runnable frame_run;
  
  void init(nGUI g) {
    gui = g;
    frame_run = new Runnable() { public void run() { frame(); } };
    gui.addEventFrame(frame_run);
    localrect = new Rect();
    globalrect = new Rect();
    phantomrect = new Rect();
    changePosition();
    hover = new Hoverable(g.hoverable_pile, globalrect);
    hover.active = true;
    hoverHideState = hover.active; 
    label = new String();
    look = new nLook();
    drawer = new Drawable(g.drawing_pile) { public void drawing() {
      if (((triggerMode || switchMode) && isClicked) || switchState) { fill(look.pressColor); } 
      else if (isHovered && (triggerMode || switchMode))             { fill(look.hoveredColor); } 
      else                                                           { fill(look.standbyColor); }
      noStroke();
      ellipseMode(CORNER);
      if (shapeRound) ellipse(getX(), getY(), getSX(), getSY());
      else if (shapeLosange) {quad(getX() + getSX()/2, getY(), 
                                   getX() + getSX()  , getY() + getSY()/2, 
                                   getX() + getSX()/2, getY() + getSY(), 
                                   getX()            , getY() + getSY()/2  );}
      else if (!DEBUG_NOFILL) rect(getX(), getY(), getSX(), getSY());
      
      noFill();
      if (isField && isSelected) stroke(look.outlineSelectedColor);
      else if (showOutline || (hoverOutline && isHovered)) stroke(look.outlineColor);
      else noStroke();
      float wf = 1;
      if (constantOutlineWeight) { wf = 1 / gui.scale; strokeWeight(look.outlineWeight / gui.scale); }
      else strokeWeight(look.outlineWeight);
      
      
      if (shapeRound) ellipse(getX() + wf*look.outlineWeight/2, getY() + wf*look.outlineWeight/2, 
           getSX() - wf*look.outlineWeight, getSY() - wf*look.outlineWeight);
      else if (shapeLosange) {quad(getX() + getSX()/2, getY() + wf*look.outlineWeight/2, 
                                   getX() + getSX() - wf*look.outlineWeight/2, getY() + getSY()/2, 
                                   getX() + getSX()/2, getY() + getSY() - wf*look.outlineWeight/2, 
                                   getX() + wf*look.outlineWeight/2, getY() + getSY()/2  );}
      else rect(getX() + wf*look.outlineWeight/2, getY() + wf*look.outlineWeight/2, 
           getSX() - wf*look.outlineWeight, getSY() - wf*look.outlineWeight);
      
      if (show_text) {
        String l = label;
        if (showCursor) {
          String str = label.substring(0, cursorPos);
          String end = label.substring(cursorPos, label.length());
          if (cursorCount < cursorCycle / 2) l = str + "|" + end;
          else l = str + " " + end;
          cursorCount++;
          if (cursorCount > cursorCycle) cursorCount = 0;
        }
        fill(look.textColor); 
        textAlign(textAlignX, textAlignY);
        textFont(getFont(look.textFont));
        //int line = 0;
        //for (int i = 0 ; i < l.length() ; i++) if (l.charAt(i) == '\n') line+=1;
        float tx = getX();
        float ty = getY();
        if (textAlignY == CENTER)         
          ty += (getLocalSY() / 2.0)
                - (look.textFont / 6.0)
                  //- (line * look.textFont / 3)
                ;
        else if (textAlignY == BOTTOM) 
          ty += getLocalSY() - (look.textFont / 10);
        if (textAlignX == LEFT)        tx += getSY() / 2;
        else if (textAlignX == CENTER) tx += getSX() / 2;
        text(l, tx, ty);
      }
    } } ;
  }
  
  private void changePosition() { 
    globalrect.pos.x = getX(); 
    globalrect.pos.y = getY(); 
    globalrect.size.x = getSX(); 
    globalrect.size.y = getSY(); 
    phantomrect.pos.x = getX(); 
    phantomrect.pos.y = getY(); 
    phantomrect.size.x = getLocalSX(); 
    phantomrect.size.y = getLocalSY(); 
    runEvents(eventPositionChange); 
    for (nWidget w : childs) w.changePosition(); 
  }
  
  void frame() {
    if (hover != null && hover.mouseOver) {
      if (!isHovered) runEvents(eventMouseEnterRun);
      if (showInfo) gui.info.showText(infoText);
      isHovered = true;
    } else {
      if (isHovered) runEvents(eventMouseLeaveRun); 
      isHovered = false;
    }
    if (triggerMode || switchMode) {
      if (gui.in.getUnClick("MouseLeft")) {
        if (isClicked) runEvents(eventReleaseRun); 
        isClicked = false;
      }
      if (gui.in.getClick("MouseLeft") && isHovered && !isClicked) {
        
        isClicked = true;
        if (triggerMode) runEvents(eventTriggerRun); 
        if (switchMode) { if (switchState) { setOff(); } else { setOn(); } }
      }
      
    }
    if (isClicked) runEvents(eventPressRun);
    if (grabbable) {
      if (isHovered) {
        if (gui.in.getClick("MouseLeft")) {
          mx = getLocalX() - gui.mouseVector.x;
          my = getLocalY() - gui.mouseVector.y;
          //gui.in.cam.GRAB = false; //deactive le deplacement camera
          //gui.szone.ON = false;
          isGrabbed = true;
          runEvents(eventGrabRun);
        }
      }
      if (isGrabbed && gui.in.getUnClick("MouseLeft")) {
        isGrabbed = false;
        //gui.in.cam.GRAB = true;
        //gui.szone.ON = true;
        runEvents(eventLiberateRun);
      }
      if (isGrabbed && isClicked) {
        float nx = gui.mouseVector.x + mx, ny = gui.mouseVector.y + my;
        if (constrainD) {
          PVector p = new PVector(nx, ny);
          if (p.mag() > constrainDlength) p.setMag(constrainDlength);
          nx = p.x; ny = p.y;
        }
        if (!constrainX) setPX(nx);
        if (!constrainY) setPY(ny);
        runEvents(eventDragRun);
      }
    }
    if (isSelectable) {
      if (isHovered && gui.in.getClick("MouseLeft")) {
        isSelected = !isSelected;
        if (isSelected) {
          prev_select_outline = showOutline;
          showOutline = true;
          if (isField) showCursor = true;
          gui.field_used = true;
        } else {
          showOutline = prev_select_outline;
          if (isField) showCursor = false;
          gui.field_used = false;
        }
      } else if (!isHovered && gui.in.getClick("MouseLeft") && isSelected) {
        showOutline = prev_select_outline;
        if (isField) showCursor = false;
        isSelected = false;
        gui.field_used = false;
      }
    }
    if (isField && isSelected) {
      if (gui.in.getClick("Left")) cursorPos = max(0, cursorPos-1);
      else if (gui.in.getClick("Right")) cursorPos = min(cursorPos+1, label.length());
      else if (gui.in.getClick("Backspace") && cursorPos > 0) {
        String str = label.substring(0, cursorPos-1);
        String end = label.substring(cursorPos, label.length());
        label = str + end;
        cursorPos--;
        runEvents(eventFieldChangeRun);
      }
      else if (gui.in.getClick("Enter")) {
        String str = label.substring(0, cursorPos);
        String end = label.substring(cursorPos, label.length());
        label = str + '\n' + end;
        cursorPos++;
        runEvents(eventFieldChangeRun);
      }
      else if (gui.in.getClick("Backspace")) {}
      else if (gui.in.getClick("All")) {
        String str = label.substring(0, cursorPos);
        String end = label.substring(cursorPos, label.length());
        label = str + gui.in.getLastKey() + end;
        cursorPos++;
        runEvents(eventFieldChangeRun);
      }
    }
    runEvents(eventFrameRun);
  }
  private boolean prev_select_outline = false;
}


/*
  Graph    > data structure and math objects
    Rect    axis aligned
      pvector pos, size
      collision to rect point ...
    Point, Circle, Line, Trig, Poly (multi trig)
    draw methods: rect(Rect), triangle(Trig), line(Line)
    special draw:
      different arrow, interupted circle (cible), 
      chainable outlined line witch articulation connectable to rect circle or trig
  
  

  Animation
    AnimationFrame     abstract void draw()
    list<animframe>
    draw() circle throug frame at each call
    
  
  
  Drawer
    abstract void draw()
    int layer
    DrawerPile
    bool show
    
    rect* view
    a Drawer can point to a rect that should contain the drawing. if the rect is out of a pre_selected rect, 
    or if he is too small he is passed. Maybe a Drawer can hold multiple methods for different level of zoom?
    This could allow large amount of small details. maybe passed and or far away from view drawer can 
    notify their creator for them to desactivate
  
  DrawerPile
    list<drawer>
    frame()
      run draw() for every drawer from the lowest layer so the top layer appear on top
      
  Hoverable
    point to a rect
    can be active pasif or background
    int layer    bool isfound
    
  HoverPile
    list<hover>
    hover founded
    event found, no find
    search(vector) 
      clear founded
      find the first hover under the point, search from the top layer to the down, set as founded
      stop if it found a background hover
*/



//utiliser par le hovering
class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  void draw() { rect(pos.x, pos.y, size.x, size.y); }
  Rect copy(Rect r) { 
    pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y; 
    return this; }
}

boolean rectCollide(Rect rect1, Rect rect2) {
  return (rect1.pos.x < rect2.pos.x + rect2.size.x &&
          rect1.pos.x + rect1.size.x > rect2.pos.x &&
          rect1.pos.y < rect2.pos.y + rect2.size.y &&
          rect1.pos.y + rect1.size.y > rect2.pos.y   );
}

boolean rectCollide(Rect rect1, Rect rect2, float s) {
  Rect r1 = new Rect(rect1); r1.pos.x -= s; r1.pos.y -= s; r1.size.x += 2*s; r1.size.y += 2*s;
  Rect r2 = new Rect(rect2); r2.pos.x -= s; r2.pos.y -= s; r2.size.x += 2*s; r2.size.y += 2*s;
  return (r1.pos.x < r2.pos.x + r2.size.x &&
          r1.pos.x + r1.size.x > r2.pos.x &&
          r1.pos.y < r2.pos.y + r2.size.y &&
          r1.pos.y + r1.size.y > r2.pos.y   );
}

boolean rectCollide(PVector p, Rect rect) {
  return (p.x >= rect.pos.x && p.x <= rect.pos.x + rect.size.x &&
          p.y >= rect.pos.y && p.y <= rect.pos.y + rect.size.y );
}

boolean rectCollide(PVector p, Rect rect, float s) {
  Rect rects = new Rect(rect); rects.pos.x -= s; rects.pos.y -= s; rects.size.x += 2*s; rects.size.y += 2*s;
  return (p.x >= rects.pos.x && p.x <= rects.pos.x + rects.size.x &&
          p.y >= rects.pos.y && p.y <= rects.pos.y + rects.size.y );
}


// systemes pour organiser l'ordre d'execution de different trucs en layer:

//drawing
class Drawable {
  Drawing_pile pile = null;
  int layer = 0;
  boolean active = true;
  Drawable setPile(Drawing_pile p) {
    pile = p; pile.drawables.add(this);
    return this; }
  Drawable() {}
  Drawable(Drawing_pile p) {
    pile = p; pile.drawables.add(this); }
  Drawable(Drawing_pile p, int l) {
    layer = l;
    pile = p; pile.drawables.add(this); }
  void clear() { if (pile != null) pile.drawables.remove(this); }
  void toLayerTop() { pile.drawables.remove(this); pile.drawables.add(0, this); }
  void toLayerBottom() { pile.drawables.remove(this); pile.drawables.add(this); }
  Drawable setLayer(int l) {
    layer = l;
    return this;
  }
  void drawing() {}
}

class Drawing_pile {
  ArrayList<Drawable> drawables = new ArrayList<Drawable>();
  //ArrayList<Drawer> top_drawables = new ArrayList<Drawer>();
  Drawing_pile() { }
  void drawing() {
    int layer = 0;
    int run_count = 0;
    while (run_count < drawables.size()) {
      for (int i = drawables.size() - 1; i >= 0 ; i--) {
        Drawable r = drawables.get(i);
        if (r.layer == layer) {
          if (r.active) r.drawing();
          run_count++;
        }
      }
      layer++;
    }
  }
  int getHighestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawable r : drawables) if (r.layer > l) l = r.layer;
      return l;
    } else return 0; }
  int getLowestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawable r : drawables) if (r.layer < l) l = r.layer;
      return l;
    } else return 0; }
}








//parmi une list de rect en layer lequel est en collision avec un point en premier


class Hoverable_pile {
  ArrayList<Hoverable> hoverables = new ArrayList<Hoverable>();
  ArrayList<Runnable> eventsFound = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNotFound = new ArrayList<Runnable>();
  boolean found = false;
  Hoverable_pile() { }
  void addEventNotFound(Runnable r) { eventsNotFound.add(r); }
  void removeEventNotFound(Runnable r) { eventsNotFound.remove(r); }
  void addEventFound(Runnable r) { eventsFound.add(r); }
  void removeEventFound(Runnable r) { eventsFound.remove(r); }
  void search(PVector pointer, boolean passif) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    found = false; int count = 0;
    if (!passif) {
      if (hoverables.size() > 0) while (count < hoverables.size() && !found) {
        for (int i = 0; i < hoverables.size() ; i++) {
          Hoverable h = hoverables.get(i);
          if (h.layer == layer) {
            count++;
            if (!found && h.active && h.rect != null && rectCollide(pointer, h.rect, h.phantom_space)) {
              h.mouseOver = true;
              if (DEBUG_HOVERPILE) {
                fill(255, 0);
                strokeWeight(5);
                stroke(0, 0, 255);
                rect(h.rect.pos.x, h.rect.pos.y, h.rect.size.x, h.rect.size.y);
              }
              found = true;
            }
          }
        }
        layer--;
      }
      if (found) runEvents(eventsFound); else runEvents(eventsNotFound);
    } 
    //else runEvents(eventsNotFound);
  }
}

class Hoverable {
  Hoverable_pile pile = null;
  int layer;
  Rect rect = null;
  boolean mouseOver = false;
  boolean active = true;
  float phantom_space = 0;
  Hoverable(Hoverable_pile p, Rect r) {
    layer = 0;
    pile = p;
    if (pile != null) pile.hoverables.add(this);
    rect = r;
  }
  Hoverable(Hoverable_pile p, Rect r, int l) {
    layer = l;
    pile = p;
    if (pile != null) pile.hoverables.add(this);
    rect = r;
  }
  void clear() { if (pile != null) pile.hoverables.remove(this); }
  void toLayerTop() { if (pile != null) { pile.hoverables.remove(this); pile.hoverables.add(0, this); } }
  void toLayerBottom() { if (pile != null) {pile.hoverables.remove(this); pile.hoverables.add(this); } }
  Hoverable setLayer(int l) {
    layer = l;
    return this;
  }
}



//execution ordonné en layer et timer
abstract class Tickable {
  Ticking_pile pile = null;
  int layer;
  boolean active = true;
  Tickable() {}
  Tickable(Ticking_pile p) {
    layer = 0;
    pile = p;
    pile.tickables.add(this);
  }
  Tickable(Ticking_pile p, int l) {
    layer = l;
    pile = p;
    pile.tickables.add(this);
  }
  void clear() { if (pile != null) pile.tickables.remove(this); }
  Tickable setLayer(int l) {
    layer = l;
    return this;
  }
  abstract void tick(float time);
}

class Ticking_pile {
  ArrayList<Tickable> tickables = new ArrayList<Tickable>();
  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;
  Ticking_pile() { }
  void tick() {
    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;
    int layer = 0;
    int run_count = 0;
    while (run_count < tickables.size()) {
      for (Tickable r : tickables) {
        if (r.layer == layer) {
          if (r.active) r.tick(frame_length);
          run_count++;
        }
      }
      layer++;
    }
  }
}














 
