

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
    CameraView
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
  
  
  Interface(Inputs, DataHolding)
    class CameraView 
      name
      pos and scale as svalue
    map<name, CameraView> : views
    name of current view as svalue
    drawing_pile screen_draw, cam_draw
    hover_pile screen and cam
    event hoverpilesearch both no find
    list<runnable> frameEvents
    add widget methods
    frame()
      hover_pile.search() if screen found dont do cam
      run frameEvents
      update cam view from inputs
      clear screen
      draw grid if needed
      draw cam then screen from their pov
    to control when to screenshot maybe do it in a Drawer
    
    Global GUI Theme 
      can be picked from by widgets 
      ? list of widgets to update when is changed ?
      map of color and name
      map of size and name
    map<name, widget> models
      methods to directly build a widget from models
  
  Widget(Interface)
    bool:is on screen or cam
    can move between cam and screen (and keeping relative pos if needed)
  Widget typical Objects
    Trigger Button can command svalue
    switch button can command svalue
    label can watch svalue
    separating line
  Complex Widget Objects
    Hilightable Front
      selectable, run event when selected
    Menubar : series of horizontal switch mutualy exclusive
      auto adjust largeur
      each open a dropdown list of trigger button who close the menus
        close when clicked anywhere else
        on topmost layer
    Scrollbar up/down button, view bar, react to mouse 
      possibly react in a bigger zone than himself to acomodate scroll list
    Scrollable list from string list
      trigger / one select / multi select
    H / V Cursor > svalue
    Graph from sValue
      rectangular canvas with value history has graph
      auto scale, can do multi value
    sValue controller widget for easy svalue change by increment or factor
      ex: trig x - text value - trig /
  Complex GUI Objects
    Info
      can appear on top of the mouse with text
    SelectZone
      draw a rectangular zone by click n dragging
      Hilightable front activated inside when releasing are marqued has selected
      they have event when selected / unselected
    Tool panel fixe on screen but collapsable (button to enlarg appear when mouse is close)
      can move away if camera move toward him
      all methods for widgets and complex widget creation
    Tasinterar show pre choosen opened panel (collapsed or not) in rows n collumns
      trigger uncollapse and bring to front
    Panel
      has : title, background, default tab
      can has : 
        grabbable title, close button, reduc/enlarg button, 
        hilightable front for selection, 
        collapse to tasinterar button, menubar, tab bar
      can add : menu, menu entry(trigger), tab
      tab : group of tabDrawer on top of background, one tab shown at a time
        can permit Y scroll through drawer
          des cache de la hauteur du plus grand drawer seront ajouté up n down
        can add a scrollbar
        tabs can change the panel back height
        TabDrawer
           all methods for widgets and complex widget creation
  


*/



class nGUI {
  Drawing_pile drawing_pile = new Drawing_pile();
  Hoverable_pile hoverable_pile = new Hoverable_pile();
  
  nWidget selected_widget = null;
  
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  nGUI addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  nGUI addEventNotFound(Runnable r) { hoverable_pile.addEventNotFound(r); return this; }
  
  sInterface in;
  
  PVector mouseVector = null;
  nGUI setMouse(PVector v) { mouseVector = v; return this; }
  
  nGUI(sInterface _i) {
    in = _i;
    mouseVector = in.mouse;
  }
  
  void frame(boolean b) {
    if (b) hoverable_pile.search(mouseVector);
    runEvents(eventsFrame);
  }
  void draw() {
    drawing_pile.drawing();
  }
}


/*

*/

//class nWidget extends Callable {
class nWidget {
  
  private nPanelDrawer panel_drawer = null;
  nWidget setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  private nGUI gui;
  private Drawing_pile dpile;
  private Drawer drawer;
  private int layer = 0;
  private Rect globalrect;
  private Rect localrect;
  private nWidget parent = null;
  private ArrayList<nWidget> childs = new ArrayList<nWidget>();
  
  private Hoverable_pile hpile; Hoverable hover;
  private String label = new String();
  private int text_font;
  private boolean triggerMode = false;
  private boolean switchMode = false;
  private boolean switchState = false;
  private boolean grabbable = false;
  private boolean isClicked = false;
  private boolean isHovered = false;
  private boolean isGrabbed = false;
  private boolean isSelectable = false;
  private boolean isSelected = false;
  private boolean isField = false;
  private boolean showCursor = false;
  private int cursorPos = 0;
  private ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  private float mx = 0, my = 0, pmx = 0, pmy = 0;
  private boolean showOutline = false;
  private boolean hoverOutline = false;
  private float outlineWeight = 1;
  
  private boolean alignX = false, stackX = false;
  private boolean alignY = false, stackY = false;
  private boolean placeLeft = false, placeRight = false;
  private boolean placeUp = false, placeDown = false;
  private boolean hide = false;
  
  private color standbyColor = color(80);
  private color hoveredColor = color(130);
  private color clickedColor = color(180);
  private color labelColor = color(255);
  private color outlineColor = color(255);
  private color selectedColor = color(255, 255, 0);
  
  private boolean constrainX = false;
  private boolean constrainY = false;
  
  nWidget setConstrainX(boolean b) { constrainX = b; return this; }
  nWidget setConstrainY(boolean b) { constrainY = b; return this; }
  
  nWidget(nGUI g) {
    label = ""; text_font = 24;
    localrect = new Rect();
    init(g); }
  nWidget(nGUI g, float x, float y) {
    text_font = 24;
    localrect = new Rect(x, y, 0, 0);
    init(g); }
  nWidget(nGUI g, float x, float y, float w, float h) {
    hpile = g.hoverable_pile;
    text_font = 24;
    localrect = new Rect(x, y, w, h);
    init(g); }
  nWidget(nGUI g, String _label, int _text_font, float x, float y) {
    label = _label; text_font = _text_font;
    localrect = new Rect(x, y, label.length() * text_font, text_font);
    init(g); }
  nWidget(nGUI g, String _label, int _text_font, float x, float y, float w, float h) {
    label = _label; text_font = _text_font;
    localrect = new Rect(x, y, w, h);
    init(g); }
  
  private int cursorCount = 0;
  private int cursorCycle = 80;
  
  void init(nGUI g) {
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    gui.addEventFrame(new Runnable() { public void run() { frame(); } } );
    globalrect = new Rect();
    changePosition();
    hover = new Hoverable(hpile, globalrect);
    hover.active = false;
    drawer = new Drawer(dpile) { public void drawing() {
      if (isClicked || switchState)                      { fill(clickedColor); } 
      else if (isHovered && (triggerMode || switchMode)) { fill(hoveredColor); } 
      else                                               { fill(standbyColor); }
      noStroke();
      rect(getX(), getY(), getSX(), getSY());
      
      noFill();
      strokeWeight(outlineWeight);
      if (showOutline || (hoverOutline && isHovered) ) stroke(outlineColor);
      else if (isField && isSelected) stroke(selectedColor);
      else noStroke();
      rect(getX() + outlineWeight/2, getY() + outlineWeight/2, getSX() - outlineWeight, getSY() - outlineWeight);
      
      textAlign(CENTER);
      textFont(getFont(text_font));
      String l = label;
      if (showCursor) {
        String str = label.substring(0, cursorPos);
        String end = label.substring(cursorPos, label.length());
        if (cursorCount < cursorCycle / 2) l = str + "|" + end;
        else l = str + " " + end;
        cursorCount++;
        if (cursorCount > cursorCycle) cursorCount = 0;
      }
      fill(labelColor); text(l, getX() + getSX() / 2, getY() + (text_font / 3.0) + (getLocalSY() / 2.0));
    } } ;
  }
  
  void clear() {
    for (nWidget w : childs) w.clear();
    runEvents(eventClear);
    drawer.clear();
    hover.clear();
    //removeChannel(gui.GUI_Call);
    eventFrameRun.clear();
    eventGrabRun.clear();
    eventDragRun.clear();
    eventLiberateRun.clear();
    eventMouseEnterRun.clear();
    eventMouseLeaveRun.clear();
    eventPressRun.clear();
    eventReleaseRun.clear();
    eventTriggerRun.clear();
    eventSwitchOnRun.clear();
    eventSwitchOffRun.clear();
    eventFieldChangeRun.clear();
  }
  
  nWidget addEventClear(Runnable r)  { eventClear.add(r); return this; }
  nWidget removeEventClear(Runnable r)       { eventClear.remove(r); return this; }
  ArrayList<Runnable> eventClear = new ArrayList<Runnable>();
  
  
  nWidget setDrawer(Drawer d) { 
    dpile.drawables.remove(drawer); 
    drawer = d; 
    if (drawer != null) {
      drawer.setLayer(layer); 
      dpile.drawables.add(d); 
    }
    return this; 
  }
  
  nWidget setPassif() { triggerMode = false; switchMode = false; switchState = false; hover.active = false; return this; }
  nWidget setTrigger() { triggerMode = true; switchMode = false; switchState = false; hover.active = true; return this; }
  nWidget setSwitch() { triggerMode = false; switchMode = true; switchState = false; hover.active = true; return this; }
  
  nWidget addExclude(nWidget b) { excludes.add(b); return this; }
  nWidget removeExclude(nWidget b) { excludes.remove(b); return this; }
  
  nWidget setGrabbable() { triggerMode = true; grabbable = true; hover.active = true; return this; }
  nWidget setFixed() { grabbable = false; hover.active = false; return this; }
  
  nWidget setParent(nWidget p) { 
    if (parent != null) parent.childs.remove(this); 
    if (p != null) { parent = p; p.childs.add(this); changePosition(); } return this; }
  nWidget clearParent() { 
    if (parent != null) { parent.childs.remove(this); parent = null; changePosition(); } return this; }
  
  nWidget setLayer(int l) { 
    layer = l; 
    if (drawer != null) drawer.setLayer(layer); 
    if (hover != null) hover.setLayer(layer); 
    customLayerChange(); 
    return this; 
  }
  
  nWidget setSelectable(boolean o) { isSelectable = o; hoverOutline = o; hover.active = true; return this; }
  nWidget setField(boolean o) { isField = o; setSelectable(o); return this; }
  
  
  nWidget setOutline(boolean o) { showOutline = o; return this; }
  nWidget setOutlineWeight(float l) { outlineWeight = l; return this; }
  nWidget setHoveredOutline(boolean o) { hoverOutline = o; return this; }
  
  nWidget setText(String s) { label = s; cursorPos = label.length(); return this; }
  nWidget setFont(int s) { text_font = s; return this; }
  
  nWidget setPosition(float x, float y) { setPX(x); setPY(y); return this; }
  nWidget setSize(float x, float y) { setSX(x); setSY(y); return this; }
  
  nWidget setPX(float v) { if (v != localrect.pos.x) { localrect.pos.x = v; changePosition(); return this; } return this; }
  nWidget setPY(float v) { if (v != localrect.pos.y) { localrect.pos.y = v; changePosition(); return this; } return this; }
  nWidget setSX(float v) { 
    if (v != localrect.size.x) { 
      localrect.size.x = v; 
      globalrect.size.x = getSX(); 
      for (nWidget w : childs) if (w.stackX && w.placeRight) w.changePosition(); 
      customShapeChange(); 
      return this; 
    } 
    return this; 
  }
  nWidget setSY(float v) { 
    if (v != localrect.size.y) { 
      localrect.size.y = v; 
      globalrect.size.y = getSY(); 
      for (nWidget w : childs) if (w.stackY && w.placeDown) w.changePosition(); 
      customShapeChange(); 
      return this; 
    } 
    return this; 
  }
  
  nWidget setStandbyColor(color c) { standbyColor = c; return this; }
  nWidget setHoveredColor(color c) { hoveredColor = c; return this; }
  nWidget setClickedColor(color c) { clickedColor = c; return this; }
  nWidget setLabelColor(color c) { labelColor = c; return this; }
  nWidget setOutlineColor(color c) { outlineColor = c; return this; }
  nWidget setSelectedColor(color c) { selectedColor = c; return this; }
  
  boolean drawerState = true;
  boolean hoverState = true;
  nWidget hide() { 
    if (!hide) {
      hide = true; 
      if (drawer != null) { drawerState = drawer.active; drawer.active = false; }
      changePosition(); 
      if (hover != null) { hoverState = hover.active; hover.active = false; }
      customVisibilityChange(); 
      for (nWidget w : childs) w.hide(); 
    }
    return this; 
  }
  nWidget show() { 
    if (hide) {
      hide = false; 
      if (drawer != null) drawer.active = drawerState; 
      changePosition(); 
      if (hover != null) hover.active = hoverState; 
      customVisibilityChange(); 
      for (nWidget w : childs) w.show(); 
    }
    return this; 
  }
  
  nWidget alignUp()    { alignY = true; stackY = false; placeUp = true; placeDown = false; changePosition(); return this; }
  nWidget alignDown()  { alignY = true; stackY = false; placeUp = false; placeDown = true; changePosition(); return this; }
  nWidget alignLeft()  { alignX = true; stackX = false; placeLeft = true; placeRight = false; changePosition(); return this; }
  nWidget alignRight() { alignX = true; stackX = false; placeLeft = false; placeRight = true; changePosition(); return this; }
  nWidget stackUp()    { alignY = false; stackY = true; placeUp = true; placeDown = false; changePosition(); return this; }
  nWidget stackDown()  { alignY = false; stackY = true; placeUp = false; placeDown = true; changePosition(); return this; }
  nWidget stackLeft()  { alignX = false; stackX = true; placeLeft = true; placeRight = false; changePosition(); return this; }
  nWidget stackRight() { alignX = false; stackX = true; placeLeft = false; placeRight = true; changePosition(); return this; }
  
  boolean isOn() { return switchState; }
  
  void setOn() {
    if (!switchState) {
      switchState = true;
      runEvents(eventSwitchOnRun);
      eventSwitchOn();
      for (nWidget b : excludes) b.setOff();
    }
  }
  
  void setOff() {
    if (switchState) {
      switchState = false;
      runEvents(eventSwitchOffRun);
      eventSwitchOff();
    }
  }
  
  void forceOff() {
    switchState = false;
    runEvents(eventSwitchOffRun);
    eventSwitchOff();
  }
  
  nWidget toLayerTop() {
    drawer.toLayerTop();
    hover.toLayerTop();
    return this;
  }
  
  nGUI getGUI() { return gui; }
  Rect getRect() { return globalrect; }
  int getLayer() { return layer; }
  
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
  
  String getText() { return label.substring(0, label.length()); }
  
  boolean isClicked() { return isClicked; }
  boolean isHovered() { return isHovered; }
  boolean isField() { return isField; }
  boolean isHided() { return hide; }
  
  void customPositionChange() {}
  void customShapeChange() {}
  void customLayerChange() {}
  void customVisibilityChange() {}
  
  private void changePosition() { 
    globalrect.pos.x = getX(); 
    globalrect.pos.y = getY(); 
    globalrect.size.x = getSX(); 
    globalrect.size.y = getSY(); 
    customPositionChange(); 
    for (nWidget w : childs) w.changePosition(); 
  }
  
  //void answer(Channel chan, float val) {
  void frame() {
    if (hover.mouseOver) {
      if (!isHovered) { runEvents(eventMouseEnterRun); eventMouseEnter(); }
      isHovered = true;
    } else {
      if (isHovered) { runEvents(eventMouseLeaveRun); eventMouseLeave(); }
      isHovered = false;
    }
    if (triggerMode || switchMode) {
      if (gui.in.getUnClick("MouseLeft")) {
        if (isClicked) { runEvents(eventReleaseRun); eventRelease(); }
        isClicked = false;
      }
      if (gui.in.getClick("MouseLeft") && isHovered && !isClicked) {
        runEvents(eventPressRun);
        eventPress();
        isClicked = true;
        if (triggerMode) { runEvents(eventTriggerRun); eventTrigger(); }
        if (switchMode) { if (switchState) { setOff(); } else { setOn(); } }
      }
      
    }
    if (grabbable) {
      if (isHovered) {
        if (gui.in.getClick("MouseLeft")) {
          mx = getLocalX() - gui.mouseVector.x;
          my = getLocalY() - gui.mouseVector.y;
          gui.in.cam.GRAB = false; //deactive le deplacement camera
          //gui.szone.ON = false;
          isGrabbed = true;
          runEvents(eventGrabRun);
          eventGrab();
        }
      }
      if (isGrabbed && gui.in.getUnClick("MouseLeft")) {
        isGrabbed = false;
        gui.in.cam.GRAB = true;
        //gui.szone.ON = true;
        runEvents(eventLiberateRun);
        eventLiberate();
      }
      if (isGrabbed && isClicked) {
        if (!constrainX) setPX(gui.mouseVector.x + mx);
        if (!constrainY) setPY(gui.mouseVector.y + my);
        runEvents(eventDragRun);
        eventDrag();
      }
    }
    if (isSelectable) {
      if (isHovered && gui.in.getClick("MouseLeft")) {
        isSelected = !isSelected;
        if (isSelected) {
          if (gui.selected_widget != null) gui.selected_widget.showOutline = false;
          gui.selected_widget = this;
          showOutline = true;
          if (isField) showCursor = true;
        } else {
          gui.selected_widget = null;
          showOutline = false;
          if (isField) showCursor = false;
        }
      } else if (!isHovered && gui.in.getClick("MouseLeft") && isSelected) {
        gui.selected_widget = null;
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
    //if (isField && isSelected && gui.in.keyClick) {
    //  if (key == CODED) {
    //    if (keyCode == LEFT) {
    //      cursorPos = max(0, cursorPos-1);
    //    } else if (keyCode == RIGHT) {
    //      cursorPos = min(cursorPos+1, label.length());
    //    } 
    //  } else {
    //    if (key == BACKSPACE && cursorPos > 0) {
    //      String str = label.substring(0, cursorPos-1);
    //      String end = label.substring(cursorPos, label.length());
    //      label = str + end;
    //      cursorPos--;
    //      runEvents(eventFieldChangeRun);
    //    } else if (key == BACKSPACE || key == ENTER) {
          
    //    } else {
    //      String str = label.substring(0, cursorPos);
    //      String end = label.substring(cursorPos, label.length());
    //      label = str + key + end;
    //      cursorPos++;
    //      runEvents(eventFieldChangeRun);
    //    }
    //  }
    //}
    runEvents(eventFrameRun);
    eventFrame();
  }
  
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
  
  nWidget addEventFrame(Runnable r)       { eventFrameRun.add(r); return this; }
  nWidget addEventFrame_Builder(Runnable r)       { eventFrameRun.add(r); r.builder = this; return this; }
  
  nWidget addEventGrab(Runnable r)       { eventGrabRun.add(r); return this; }
  nWidget addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  nWidget addEventLiberate(Runnable r)   { eventLiberateRun.add(r); return this; }
  
  nWidget addEventMouseEnter(Runnable r) { eventMouseEnterRun.add(r); return this; }
  nWidget addEventMouseLeave(Runnable r) { eventMouseLeaveRun.add(r); return this; }
  
  nWidget addEventPress(Runnable r)      { eventPressRun.add(r); return this; }
  nWidget addEventRelease(Runnable r)    { eventReleaseRun.add(r); return this; }
  
  nWidget addEventTrigger(Runnable r)    { eventTriggerRun.add(r); return this; }
  nWidget addEventTrigger_Builder(Runnable r)    { eventTriggerRun.add(r); r.builder = this; return this; }
  nWidget addEventSwitchOn(Runnable r)   { eventSwitchOnRun.add(r); return this; }
  nWidget addEventSwitchOff(Runnable r)  { eventSwitchOffRun.add(r); return this; }
  
  nWidget addEventFieldChange(Runnable r)  { eventFieldChangeRun.add(r); return this; }
  
  nWidget removeEventFrame(Runnable r)       { eventFrameRun.remove(r); return this; }
  
  nWidget removeEventGrab(Runnable r)       { eventGrabRun.remove(r); return this; }
  nWidget removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  nWidget removeEventLiberate(Runnable r)   { eventLiberateRun.remove(r); return this; }
  
  nWidget removeEventMouseEnter(Runnable r) { eventMouseEnterRun.remove(r); return this; }
  nWidget removeEventMouseLeave(Runnable r) { eventMouseLeaveRun.remove(r); return this; }
  
  nWidget removeEventPress(Runnable r)      { eventPressRun.remove(r); return this; }
  nWidget removeEventRelease(Runnable r)    { eventReleaseRun.remove(r); return this; }
  
  nWidget removeEventTrigger(Runnable r)    { eventTriggerRun.remove(r); return this; }
  nWidget removeEventSwitchOn(Runnable r)   { eventSwitchOnRun.remove(r); return this; }
  nWidget removeEventSwitchOff(Runnable r)  { eventSwitchOffRun.remove(r); return this; }
  
  nWidget removeEventFieldChange(Runnable r)  { eventFieldChangeRun.remove(r); return this; }
  
  
  
  void eventFrame() {}
  
  void eventGrab() {}
  void eventDrag() {}
  void eventLiberate() {}
  
  void eventMouseEnter() {}
  void eventMouseLeave() {}
  
  void eventPress() {}
  void eventRelease() {}
  
  void eventTrigger() {}
  void eventSwitchOn() {}
  void eventSwitchOff() {}
}







//utiliser par le hovering
class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  void draw() { rect(pos.x, pos.y, size.x, size.y); }
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



 
