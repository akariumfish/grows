

/*


*/



class nGUI {
  
  nGUI setMouse(PVector v) { mouseVector = v; return this; }
  nGUI setView(Rect v) { view = v; return this; }
  nGUI setTheme(nTheme v) { theme = v; return this; }
  nGUI addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  nGUI addEventNotFound(Runnable r) { hoverable_pile.addEventNotFound(r); return this; }
  
  nGUI(sInput _i, nTheme _t) {
    in = _i; theme = _t;
    mouseVector = in.mouse;
    view = new Rect(0, 0, width, height);
  }
  
  sInput in;
  nTheme theme;
  Rect view;
  
  Drawing_pile drawing_pile = new Drawing_pile();
  Hoverable_pile hoverable_pile = new Hoverable_pile();
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  PVector mouseVector = null;
  
  void frame() {
    hoverable_pile.search(mouseVector);
    runEvents(eventsFrame);
    drawing_pile.drawing(); }
}


class nTheme {
  HashMap<String, nWidget> models = new HashMap<String, nWidget>();
  HashMap<String, nLook> looks = new HashMap<String, nLook>();
  nTheme addLook(String r, nLook l) { looks.put(r,l); return this; }
  nTheme addModel(String r, nWidget w) { models.put(r,w); return this; }
  nLook getLook(String r) {
    for (Map.Entry me : looks.entrySet()) if (me.getKey().equals(r)) { 
      nLook m = (nLook)me.getValue(); 
      return m; }
    return null; }
  nWidget newWidget(nGUI g, String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget(g).copy(m); }
    return null; }
  nWidget newWidget(String r) {
    for (Map.Entry me : models.entrySet()) if (me.getKey().equals(r)) { 
      nWidget m = (nWidget)me.getValue(); 
      return new nWidget().copy(m); }
    return null; }
}


class sLook extends sValue {
  nLook val = new nLook();
  sLook(sValueBloc b, nLook v, String n) { super(b, "look", n); val.copy(v); }
  nLook get() { return val; }
  void set(nLook v) { if (!v.ref.equals(val.ref)) has_changed = true; val.copy(v); }
}


class sWidgetModel extends sValue {
  nWidget val = new nWidget();
  sWidgetModel(sValueBloc b, nWidget v, String n) { super(b, "look", n); val.copy(v); }
  nWidget get() { return val; }
  void set(nWidget v) { val.copy(v); }
}


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
  color standbyColor = color(80), hoveredColor = color(130), pressColor = color(180), 
        outlineColor = color(255), outlineSelectedColor = color(255, 255, 0), textColor = color(255);
  int textFont = 24; float outlineWeight = 1;
}



class nWidget {
  
  //nWidget setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  //nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  nWidget addEventPositionChange(Runnable r)   { eventPositionChange.add(r); return this; }
  nWidget addEventShapeChange(Runnable r)      { eventShapeChange.add(r); return this; }
  nWidget addEventLayerChange(Runnable r)      { eventLayerChange.add(r); return this; }
  nWidget addEventVisibilityChange(Runnable r) { eventVisibilityChange.add(r); return this; }
  
  nWidget addEventClear(Runnable r)      { eventClear.add(r); return this; }
  
  nWidget addEventFrame(Runnable r)      { eventFrameRun.add(r); return this; }
  nWidget addEventFrame_Builder(Runnable r) { eventFrameRun.add(r); r.builder = this; return this; }
  
  nWidget addEventGrab(Runnable r)       { eventGrabRun.add(r); return this; }
  nWidget addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  nWidget addEventLiberate(Runnable r)   { eventLiberateRun.add(r); return this; }
  
  nWidget addEventMouseEnter(Runnable r) { eventMouseEnterRun.add(r); return this; }
  nWidget addEventMouseLeave(Runnable r) { eventMouseLeaveRun.add(r); return this; }
  
  nWidget addEventPress(Runnable r)      { eventPressRun.add(r); return this; }
  nWidget addEventRelease(Runnable r)    { eventReleaseRun.add(r); return this; }
  
  nWidget addEventTrigger(Runnable r)    { eventTriggerRun.add(r); return this; }
  nWidget addEventTrigger_Builder(Runnable r) { eventTriggerRun.add(r); r.builder = this; return this; }
  nWidget addEventSwitchOn(Runnable r)   { eventSwitchOnRun.add(r); return this; }
  nWidget addEventSwitchOff(Runnable r)  { eventSwitchOffRun.add(r); return this; }
  
  nWidget addEventFieldChange(Runnable r) { eventFieldChangeRun.add(r); return this; }
  
  nWidget setDrawer(Drawer d) { 
    gui.drawing_pile.drawables.remove(drawer); 
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
    drawer.toLayerTop();
    hover.toLayerTop();
    return this;
  }
  
  nWidget setParent(nWidget p) { 
    if (parent != null) parent.childs.remove(this); 
    if (p != null) { parent = p; p.childs.add(this); changePosition(); } return this; }
  nWidget clearParent() { 
    if (parent != null) { parent.childs.remove(this); parent = null; changePosition(); } return this; }
  
  nWidget setText(String s) { label = s; cursorPos = label.length(); return this; }
  nWidget setFont(int s) { look.textFont = s; return this; }
  
  nWidget setLook(nLook l) { look.copy(l); return this; }
  nWidget setLook(nTheme t, String r) { look.copy(t.getLook(r)); return this; }
  
  nWidget hide() { 
    if (!hide) {
      hide = true; 
      if (drawer != null) { drawerHideState = drawer.active; drawer.active = false; }
      changePosition(); 
      if (hover != null) { hoverHideState = hover.active; hover.active = false; }
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.hide(); 
    }
    return this; 
  }
  nWidget show() { 
    if (hide) {
      hide = false; 
      if (drawer != null) drawer.active = drawerHideState; 
      changePosition(); 
      if (hover != null) hover.active = hoverHideState; 
      runEvents(eventVisibilityChange); 
      for (nWidget w : childs) w.show(); 
    }
    return this; 
  }
  
  nWidget copy(nWidget w) {
    triggerMode = w.triggerMode; switchMode = w.switchMode;
    grabbable = w.grabbable; constrainX = w.constrainX; constrainY = w.constrainY;
    isSelectable = w.isSelectable; isField = w.isField; 
    showCursor = w.showCursor; hoverOutline = w.hoverOutline; showOutline = w.showOutline;
    alignX = w.alignX; stackX = w.stackX; alignY = w.alignY; stackY = w.stackY;
    placeLeft = w.placeLeft; placeRight = w.placeRight; placeUp = w.placeUp; placeDown = w.placeDown;
    hide = w.hide; drawerHideState = w.drawerHideState; hoverHideState = w.hoverHideState;
    look.copy(w.look);
    setLayer(w.layer);
    setPosition(w.localrect.pos.x, w.localrect.pos.y);
    setSize(w.localrect.size.x, w.localrect.size.y);
    changePosition();
    if (hover != null && (isSelectable || grabbable || triggerMode || switchMode) && !hide) hover.active = true;
    return this;
  }
  
  void clear() {
    for (nWidget w : childs) w.clear();
    runEvents(eventClear);
    if (look != null) look.clear();
    if (drawer != null) drawer.clear(); if (hover != null) hover.clear();
    eventPositionChange.clear(); eventShapeChange.clear(); eventLayerChange.clear(); 
    eventVisibilityChange.clear(); eventClear.clear(); eventFrameRun.clear(); 
    eventGrabRun.clear(); eventDragRun.clear(); eventLiberateRun.clear(); eventFieldChangeRun.clear();
    eventMouseEnterRun.clear(); eventMouseLeaveRun.clear(); eventPressRun.clear(); eventReleaseRun.clear();
    eventTriggerRun.clear(); eventSwitchOnRun.clear(); eventSwitchOffRun.clear();
  }
  
  nGUI getGUI() { return gui; }
  Rect getRect() { return globalrect; }
  int getLayer() { return layer; }
  String getText() { return label.substring(0, label.length()); }
  
  boolean isClicked() { return isClicked; }
  boolean isHovered() { return isHovered; }
  boolean isField() { return isField; }
  boolean isHided() { return hide; }
  boolean isOn() { return switchState; }
  
  
  
  nWidget setPassif() { triggerMode = false; switchMode = false; switchState = false; if (hover != null) hover.active = false; return this; }
  nWidget setTrigger() { 
    triggerMode = true; switchMode = false; switchState = false; 
    if (hover != null) hover.active = true; return this; }
  nWidget setSwitch() { 
    triggerMode = false; switchMode = true; switchState = false; 
    if (hover != null) hover.active = true; return this; }
  
  //private ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  //nWidget addExclude(nWidget b) { excludes.add(b); return this; }
  //nWidget removeExclude(nWidget b) { excludes.remove(b); return this; }
  
  nWidget setGrabbable() { triggerMode = true; grabbable = true; hover.active = true; return this; }
  nWidget setFixed() { grabbable = false; hover.active = false; return this; }
  nWidget setConstrainX(boolean b) { constrainX = b; return this; }
  nWidget setConstrainY(boolean b) { constrainY = b; return this; }
  nWidget setSelectable(boolean o) { isSelectable = o; hoverOutline = o; hover.active = true; return this; }
  nWidget setField(boolean o) { isField = o; setSelectable(o); return this; }
  
  nWidget setOutline(boolean o) { showOutline = o; return this; }
  nWidget setOutlineWeight(float l) { look.outlineWeight = l; return this; }
  nWidget setHoveredOutline(boolean o) { hoverOutline = o; return this; }
  
  nWidget setPosition(float x, float y) { setPX(x); setPY(y); return this; }
  nWidget setSize(float x, float y) { setSX(x); setSY(y); return this; }
  
  nWidget setPX(float v) { if (v != localrect.pos.x) { localrect.pos.x = v; changePosition(); return this; } return this; }
  nWidget setPY(float v) { if (v != localrect.pos.y) { localrect.pos.y = v; changePosition(); return this; } return this; }
  nWidget setSX(float v) { 
    if (v != localrect.size.x) { 
      localrect.size.x = v; 
      globalrect.size.x = getSX(); 
      for (nWidget w : childs) if (w.stackX && w.placeRight) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  nWidget setSY(float v) { 
    if (v != localrect.size.y) { 
      localrect.size.y = v; 
      globalrect.size.y = getSY(); 
      for (nWidget w : childs) if (w.stackY && w.placeDown) w.changePosition(); 
      runEvents(eventShapeChange); 
      return this; 
    } 
    return this; 
  }
  
  nWidget setStandbyColor(color c) { look.standbyColor = c; return this; }
  nWidget setHoveredColor(color c) { look.hoveredColor = c; return this; }
  nWidget setClickedColor(color c) { look.pressColor = c; return this; }
  nWidget setLabelColor(color c) { look.textColor = c; return this; }
  nWidget setOutlineColor(color c) { look.outlineColor = c; return this; }
  nWidget setSelectedColor(color c) { look.outlineSelectedColor = c; return this; }
  
  nWidget alignUp()    { alignY = true; stackY = false; placeUp = true; placeDown = false; changePosition(); return this; }
  nWidget alignDown()  { alignY = true; stackY = false; placeUp = false; placeDown = true; changePosition(); return this; }
  nWidget alignLeft()  { alignX = true; stackX = false; placeLeft = true; placeRight = false; changePosition(); return this; }
  nWidget alignRight() { alignX = true; stackX = false; placeLeft = false; placeRight = true; changePosition(); return this; }
  nWidget stackUp()    { alignY = false; stackY = true; placeUp = true; placeDown = false; changePosition(); return this; }
  nWidget stackDown()  { alignY = false; stackY = true; placeUp = false; placeDown = true; changePosition(); return this; }
  nWidget stackLeft()  { alignX = false; stackX = true; placeLeft = true; placeRight = false; changePosition(); return this; }
  nWidget stackRight() { alignX = false; stackX = true; placeLeft = false; placeRight = true; changePosition(); return this; }
  
  void setSwitchState(boolean s) { if (s) setOn(); else setOff(); }
  void setOn() {
    if (!switchState) {
      switchState = true;
      runEvents(eventSwitchOnRun);
      //for (nWidget b : excludes) b.setOff();
    }
  }
  
  void setOff() {
    if (switchState) {
      switchState = false;
      runEvents(eventSwitchOffRun);
    }
  }
  
  void forceOff() {
    switchState = false;
    runEvents(eventSwitchOffRun);
  }
  
  float getX() { 
    if (parent != null) {
      if (alignX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x - getSX();
        else if (placeLeft) return parent.getX() + localrect.pos.x;
      } else if (stackX) {
        if (placeRight) return parent.getX() + parent.getSX() + localrect.pos.x;
        else if (placeLeft) return parent.getX() + localrect.pos.x - getSX();
      } else return localrect.pos.x + parent.getX();
    } 
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
    } 
    return localrect.pos.y;
  }
  float getLocalX() { return localrect.pos.x; }
  float getLocalY() { return localrect.pos.y; }
  float getSX() { if (!hide) return localrect.size.x; else return 0; }
  float getSY() { if (!hide) return localrect.size.y; else return 0; }
  float getLocalSX() { return localrect.size.x; }
  float getLocalSY() { return localrect.size.y; }
  
  nWidget() {
    localrect = new Rect();
    globalrect = new Rect();
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
  
  private nGUI gui;
  private Drawer drawer;
  private Hoverable hover;
  private Rect globalrect, localrect;
  private nWidget parent = null;
  private ArrayList<nWidget> childs = new ArrayList<nWidget>();
  private nLook look;
  //private nPanelDrawer panel_drawer = null;
  
  private String label;
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
  private boolean grabbable = false, constrainX = false, constrainY = false;
  private boolean isSelectable = false, isField = false, showCursor = false;
  private boolean showOutline = false, hoverOutline = false;
  private boolean alignX = false, stackX = false, alignY = false, stackY = false;
  private boolean placeLeft = false, placeRight = false, placeUp = false, placeDown = false;
  private boolean hide = false, drawerHideState = true, hoverHideState = true;
  private int layer = 0;
 
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
  
  void init(nGUI g) {
    gui = g;
    gui.addEventFrame(new Runnable() { public void run() { frame(); } } );
    localrect = new Rect();
    globalrect = new Rect();
    changePosition();
    hover = new Hoverable(g.hoverable_pile, globalrect);
    hover.active = false;
    label = new String();
    look = new nLook();
    drawer = new Drawer(g.drawing_pile) { public void drawing() {
      if (isClicked || switchState)                      { fill(look.pressColor); } 
      else if (isHovered && (triggerMode || switchMode)) { fill(look.hoveredColor); } 
      else                                               { fill(look.standbyColor); }
      noStroke();
      rect(getX(), getY(), getSX(), getSY());
      
      noFill();
      strokeWeight(look.outlineWeight);
      if (showOutline || (hoverOutline && isHovered)) stroke(look.outlineColor);
      else if (isField && isSelected) stroke(look.outlineSelectedColor);
      else noStroke();
      rect(getX() + look.outlineWeight/2, getY() + look.outlineWeight/2, 
           getSX() - look.outlineWeight, getSY() - look.outlineWeight);
           
      textAlign(CENTER);
      textFont(getFont(look.textFont));
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
      text(l, getX() + getSX() / 2, getY() + (look.textFont / 3.0) + (getLocalSY() / 2.0));
      
    } } ;
  }
  
  private void changePosition() { 
    globalrect.pos.x = getX(); 
    globalrect.pos.y = getY(); 
    globalrect.size.x = getSX(); 
    globalrect.size.y = getSY(); 
    runEvents(eventPositionChange); 
    for (nWidget w : childs) w.changePosition(); 
  }
  
  void frame() {
    if (hover.mouseOver) {
      if (!isHovered) runEvents(eventMouseEnterRun);
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
        runEvents(eventPressRun);
        isClicked = true;
        if (triggerMode) runEvents(eventTriggerRun); 
        if (switchMode) { if (switchState) { setOff(); } else { setOn(); } }
      }
      
    }
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
        if (!constrainX) setPX(gui.mouseVector.x + mx);
        if (!constrainY) setPY(gui.mouseVector.y + my);
        runEvents(eventDragRun);
      }
    }
    if (isSelectable) {
      if (isHovered && gui.in.getClick("MouseLeft")) {
        isSelected = !isSelected;
        if (isSelected) {
          //if (gui.selected_widget != null) gui.selected_widget.showOutline = false;
          //gui.selected_widget = this;
          showOutline = true;
          if (isField) showCursor = true;
        } else {
          //gui.selected_widget = null;
          showOutline = false;
          if (isField) showCursor = false;
        }
      } else if (!isHovered && gui.in.getClick("MouseLeft") && isSelected) {
        //gui.selected_widget = null;
        showOutline = false;
        if (isField) showCursor = false;
        isSelected = false;
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
      else if (gui.in.getClick("Enter") || gui.in.getClick("Backspace")) {}
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



// systemes pour organiser l'ordre d'execution de different trucs en layer:

//drawing
class Drawer {
  Drawing_pile pile = null;
  int layer = 0;
  boolean active = true;
  Drawer setPile(Drawing_pile p) {
    pile = p; pile.drawables.add(this);
    return this; }
  Drawer() {}
  Drawer(Drawing_pile p) {
    pile = p; pile.drawables.add(this); }
  Drawer(Drawing_pile p, int l) {
    layer = l;
    pile = p; pile.drawables.add(this); }
  void clear() { if (pile != null) pile.drawables.remove(this); }
  void toLayerTop() { pile.drawables.remove(this); pile.drawables.add(0, this); }
  void toLayerBottom() { pile.drawables.remove(this); pile.drawables.add(this); }
  Drawer setLayer(int l) {
    layer = l;
    return this;
  }
  void drawing() {}
}

class Drawing_pile {
  ArrayList<Drawer> drawables = new ArrayList<Drawer>();
  //ArrayList<Drawer> top_drawables = new ArrayList<Drawer>();
  Drawing_pile() { }
  void drawing() {
    int layer = 0;
    int run_count = 0;
    while (run_count < drawables.size()) {
      for (int i = drawables.size() - 1; i >= 0 ; i--) {
        Drawer r = drawables.get(i);
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
      for (Drawer r : drawables) if (r.layer > l) l = r.layer;
      return l;
    } else return 0; }
  int getLowestLayer() {
    if (drawables.size() > 0) {
      int l = drawables.get(0).layer;
      for (Drawer r : drawables) if (r.layer < l) l = r.layer;
      return l;
    } else return 0; }
}








//parmi une list de rect en layer lequel est en collision avec un point en premier
class Hoverable_pile {
  ArrayList<Hoverable> hoverables = new ArrayList<Hoverable>();
  ArrayList<Runnable> eventsNotFound = new ArrayList<Runnable>();
  boolean found = false;
  Hoverable_pile() { }
  void addEventNotFound(Runnable r) { eventsNotFound.add(r); }
  void removeEventNotFound(Runnable r) { eventsNotFound.remove(r); }
  void search(PVector pointer) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    found = false;
    int count = 0;
    
    if (hoverables.size() > 0) while (count < hoverables.size() && !found) {
      for (int i = 0; i < hoverables.size() ; i++) {
        Hoverable h = hoverables.get(i);
        if (h.layer == layer) {
          count++;
          if (!found && h.active && h.rect != null && rectCollide(pointer, h.rect)) {
            h.mouseOver = true;
            found = true;
          }
        }
      }
      layer--;
    }
    if (!found) runEvents(eventsNotFound);
  }
}

class Hoverable {
  Hoverable_pile pile = null;
  int layer;
  Rect rect = null;
  boolean mouseOver = false;
  boolean active = true;
  Hoverable(Hoverable_pile p, Rect r) {
    layer = 0;
    pile = p;
    pile.hoverables.add(this);
    rect = r;
  }
  Hoverable(Hoverable_pile p, Rect r, int l) {
    layer = l;
    pile = p;
    pile.hoverables.add(this);
    rect = r;
  }
  void clear() { if (pile != null) pile.hoverables.remove(this); }
  void toLayerTop() { pile.hoverables.remove(this); pile.hoverables.add(0, this); }
  void toLayerBottom() { pile.hoverables.remove(this); pile.hoverables.add(this); }
  Hoverable setLayer(int l) {
    layer = l;
    return this;
  }
}



//execution ordonné en layer et timer
class Tickable {
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
  void tick(float time) {}
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








 
