import java.util.Map;


/*

APPLET
  Cam
    drawable_pile:
      world ref
      screen ref

  GUI
    hoverable


*/

//nGUI gui = new nGUI();

//void mysetup() {
//  nWidget field = new nWidget(gui, 100, 100, 100, 30)
//    .setField(true)
//    ;
    
//  nWidget field2 = new nWidget(gui, 100, 150, 100, 30)
//    .setField(true)
//    ;
//}





//ArrayList<nWidget> menubuttons = new ArrayList<nWidget>(0);

//  nWidget newMenu(String name) {
//    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size() + 1);
//    nWidget menu = new nWidget(gui, name, int(macro_size/1.85), 0, 0, new_width, macro_size * 0.75)
//      .setSwitch()
//      .setLayer(layer)
//      .setOutlineColor(color(100))
//      .setOutlineWeight(macro_size / 16)
//      .setOutline(true)
//      ;
//    if (menubuttons.size() == 0) menu.setParent(reduc).stackDown();
//    else menu.setParent(menubuttons.get(menubuttons.size()-1)).stackRight();
//    for (nWidget w : menubuttons) w.setSX(new_width);
//    menubuttons.add(menu);
//    return menu;
//  }
  
//  Macro_Abstract setWidth(float w) {
//    super.setWidth(w);
//    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size());
//    for (nWidget m : menubuttons) m.setSX(new_width);
//    return this;
//  }

//  ArrayList<nWidget> addbuttons = new ArrayList<nWidget>(0);

//  Macro_Sheet newAdd(String name, Runnable run) {
//    nWidget add = new nWidget(gui, name, int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
//      .setTrigger()
//      .setLayer(getBase().menu_layer)
//      .stackDown()
//      .hide()
//      .addEventTrigger(new Runnable() { 
//      public void run() { 
//        getBase().menugroup.closeAll();
//      }
//    }
//    )
//    .addEventTrigger(run)
//      ;
//    if (addbuttons.size() == 0) add.setParent(addExtOut);
//    else add.setParent(addbuttons.get(addbuttons.size()-1));
//    addbuttons.add(add);
//    return this;
//  }

    //if (getBase().menugroup != null) {
    //  for (nWidget w : menubuttons) getBase().menugroup.add(w);
    //}

    //for (nWidget w : addbuttons) w.setLayer(getBase().menu_layer);
    //for (nWidget w : addbuttons) w.toLayerTop();

    //for (int i = menubuttons.size() - 1; i >= 0; i--) menubuttons.get(i).clear(); 

class nWidgetPile {
  ArrayList<nWidget> pile = new ArrayList<nWidget>();
  
  nWidget newWidget(String name) {
    nWidget add = new nWidget(gui, name, 12, 0, 0, 50, 10)
      .setTrigger()
      //.setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
    //  .addEventTrigger(new Runnable() { 
    //  public void run() { 
    //    getBase().menugroup.closeAll();
    //  }
    //}
    //)
      ;
    //if (addbuttons.size() == 0) add.setParent(addExtOut);
    //else add.setParent(addbuttons.get(addbuttons.size()-1));
    //addbuttons.add(add);
    return add;
  }
  
}


class nSelectZone extends Callable {
  Hoverable_pile pile;
  Drawer drawer;
  Rect select_zone = new Rect();
  boolean emptyClick = false;
  int clickDelay = 0;
  
  nSelectZone addEventEndSelect(Runnable r)  { eventEndSelect.add(r); return this; }
  nSelectZone removeEventEndSelect(Runnable r)       { eventEndSelect.remove(r); return this; }
  ArrayList<Runnable> eventEndSelect = new ArrayList<Runnable>();
  
  boolean isSelecting() { return emptyClick; }
  
  nSelectZone(nGUI _g) {
    pile = _g.hoverable_pile;
    pile.addEventNotFound(new Runnable() { public void run() { 
      if (kb.mouseClick[1]) clickDelay = 5; 
    } } );
    drawer = new Drawer(_g.drawing_pile, 25) { public void drawing() {
      noFill();
      stroke(255);
      strokeWeight(2/cam.cam_scale.get());
      Rect z = new Rect(select_zone);
      if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
      if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
      if (emptyClick) z.draw();
    } };
    addChannel(_g.GUI_Call);
  }
  boolean isUnder(nWidget w) {
    Rect z = new Rect(select_zone);
    if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
    if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
    if (emptyClick && rectCollide(w.getRect(), z)) return true;
    return false;
  }
  void answer(Channel c, float f) {
    if (clickDelay > 0) {
      clickDelay--;
      if (clickDelay == 0) { 
        emptyClick = true;
        select_zone.pos.x = cam.getCamMouse().x;
        select_zone.pos.y = cam.getCamMouse().y;
      }
    }
    if (emptyClick) {
      select_zone.size.x = cam.getCamMouse().x - select_zone.pos.x;
      select_zone.size.y = cam.getCamMouse().y - select_zone.pos.y;
      if (kb.mouseUClick[1]) { 
        runEvents(eventEndSelect);
        emptyClick = false; 
      }
    }
  }
}


class nGUI {
  Channel GUI_Call = new Channel();
  Drawing_pile drawing_pile = new Drawing_pile();
  Hoverable_pile hoverable_pile = new Hoverable_pile();
  nWidget selected_widget = null;
  
  nSelectZone szone;
  
  nGUI() {
    szone = newSelectZone();
  }
  
  void update() {
    hoverable_pile.search(cam.getCamMouse());
    callChannel(GUI_Call);
  }
  void draw() {
    drawing_pile.drawing();
  }
  nExcludeGroup newExcludeGroup() {
    return new nExcludeGroup(hoverable_pile); }
  nSelectZone newSelectZone() {
    return new nSelectZone(this); }
}

class nExcludeGroup {
  Hoverable_pile pile;
  ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  Runnable run;
  
  void add(nWidget w) {
    excludes.add(w);
    //close others when seton event
    w.addEventSwitchOn(new Runnable(w) { public void run() { 
      for (nWidget n : excludes) if (n != (nWidget)builder) n.setOff();
    } } );
    w.addEventClear(new Runnable(w) { public void run() { 
      excludes.remove((nWidget)builder);
    } } );
  }
  
  void closeAll() {
    for (nWidget n : excludes) n.setOff();
  }
  
  void forceCloseAll() {
    for (nWidget n : excludes) n.forceOff();
  }
  
  void clear() {
    excludes.clear();
  }
  
  nExcludeGroup(Hoverable_pile _h) {
    pile = _h;
    //close all when hover not found event
    pile.addEventNotFound(new Runnable() { public void run() { if (kb.mouseClick[0]) closeAll(); } } );
  }
}

/*

objet UI multi fonction

Constructeurs:
nWidget(nGUI g) 
nWidget(nGUI g, float x, float y) 
nWidget(nGUI g, float x, float y, float w, float h) 
nWidget(nGUI g, String _label, int _text_font, float x, float y)
nWidget(nGUI g, String _label, int _text_font, float x, float y, float w, float h) 

void clear() destructeur

nWidget setDrawer(Drawer d)

nWidget setPassif()
nWidget setTrigger() one time click
nWidget setSwitch() switch on / off

nWidget addExclude(nWidget b) auto off excluded when set on
nWidget removeExclude(nWidget b)

nWidget setGrabbable() peut etre deplacer en clicker glisser
nWidget setFixed() 

nWidget setParent(nWidget p) attache sa position au parent
nWidget clearParent() 

nWidget setLayer(int l) pour l'ordre d'affichage (valeur haute au dessus)

nWidget setSelectable(boolean o) click=select (show outline)
nWidget setField(boolean o) can input text inside

nWidget setOutline(boolean o)
nWidget setOutlineWeight(int l) 
nWidget setHoveredOutline(boolean o)

nWidget setText(String s) 
nWidget setFont(int s) 

nWidget setPosition(float x, float y) par rapport au parent et au stick/align
nWidget setSize(float x, float y) 

nWidget setPX(float v) 
nWidget setPY(float v) 
nWidget setSX(float v) 
nWidget setSY(float v) 

nWidget setStandbyColor(color c) 
nWidget setHoveredColor(color c)
nWidget setClickedColor(color c)
nWidget setLabelColor(color c) 
nWidget setOutlineColor(color c)
nWidget setSelectedColor(color c)

nWidget hide() desactive draw et comportement
nWidget show() 

positionnement auto par rapport au parent independent sur les deux axes
nWidget alignUp()
nWidget alignDown()
nWidget alignLeft()   left side aligned with parent left side
nWidget alignRight()  right side aligned with parent right side
nWidget stackUp()
nWidget stackDown()
nWidget stackLeft()   right side aligned with parent left side
nWidget stackRight()  left side aligned with parent right side

switch
boolean isOn()
void setOn()
void setOff()

void toLayerTop() sera au dessus dans sont layer

nGUI getGUI()
Rect getRect()
int getLayer()

float getX() real pos 
float getY() real pos
float getLocalX() 
float getLocalY() 
float getSX() prend en compte si cacher ou non
float getSY() prend en compte si cacher ou non
float getLocalSX() 
float getLocalSY() 

String getText() 

boolean isClicked() trigger ou switch
boolean isHovered() 
boolean isHided() 

nWidget addEventFrame(Runnable r)       
nWidget addEventGrab(Runnable r)       
nWidget addEventDrag(Runnable r)       
nWidget addEventLiberate(Runnable r)   
nWidget addEventMouseEnter(Runnable r) 
nWidget addEventMouseLeave(Runnable r) 
nWidget addEventPress(Runnable r)    
nWidget addEventRelease(Runnable r)   
nWidget addEventTrigger(Runnable r)   
nWidget addEventSwitchOn(Runnable r)   
nWidget addEventSwitchOff(Runnable r)  
nWidget addEventFieldChange(Runnable r)  

nWidget removeEventFrame(Runnable r)      
nWidget removeEventGrab(Runnable r)       
nWidget removeEventDrag(Runnable r)       
nWidget removeEventLiberate(Runnable r)   
nWidget removeEventMouseEnter(Runnable r) 
nWidget removeEventMouseLeave(Runnable r)
nWidget removeEventPress(Runnable r)      
nWidget removeEventRelease(Runnable r)    
nWidget removeEventTrigger(Runnable r)    
nWidget removeEventSwitchOn(Runnable r)   
nWidget removeEventSwitchOff(Runnable r)  
nWidget removeEventFieldChange(Runnable r) 

pour les super class
void customPositionChange() {}
void customShapeChange() {}
void customLayerChange() {}
void customVisibilityChange() {}
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

*/

class nWidget extends Callable {
  
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
  private float mx = 0; float my = 0;
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
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    addChannel(g.GUI_Call);
    label = ""; text_font = 24;
    localrect = new Rect();
    init();
  }
  nWidget(nGUI g, float x, float y) {
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    addChannel(g.GUI_Call);
    text_font = 24;
    localrect = new Rect(x, y, 0, 0);
    init();
  }
  nWidget(nGUI g, float x, float y, float w, float h) {
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    addChannel(g.GUI_Call);
    text_font = 24;
    localrect = new Rect(x, y, w, h);
    init();
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y) {
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    addChannel(g.GUI_Call);
    label = _label; text_font = _text_font;
    localrect = new Rect(x, y, label.length() * text_font, text_font);
    init();
  }
  nWidget(nGUI g, String _label, int _text_font, float x, float y, float w, float h) {
    gui = g;
    dpile = g.drawing_pile;
    hpile = g.hoverable_pile;
    addChannel(g.GUI_Call);
    label = _label; text_font = _text_font;
    localrect = new Rect(x, y, w, h);
    init();
  }
  
  private int cursorCount = 0;
  private int cursorCycle = 80;
  
  void init() {
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
    removeChannel(gui.GUI_Call);
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
  
  void answer(Channel chan, float val) {
    if (hover.mouseOver) {
      if (!isHovered) { runEvents(eventMouseEnterRun); eventMouseEnter(); }
      isHovered = true;
    } else {
      if (isHovered) { runEvents(eventMouseLeaveRun); eventMouseLeave(); }
      isHovered = false;
    }
    if (triggerMode || switchMode) {
      if (kb.mouseUClick[0]) {
        if (isClicked) { runEvents(eventReleaseRun); eventRelease(); }
        isClicked = false;
      }
      if (kb.mouseClick[0] && isHovered && !isClicked) {
        runEvents(eventPressRun);
        eventPress();
        isClicked = true;
        if (triggerMode) { runEvents(eventTriggerRun); eventTrigger(); }
        if (switchMode) { if (switchState) { setOff(); } else { setOn(); } }
      }
      
    }
    if (grabbable) {
      if (isHovered) {
        if (kb.mouseClick[0]) {
          mx = getLocalX() - cam.getCamMouse().x;
          my = getLocalY() - cam.getCamMouse().y;
          cam.GRAB = false; //deactive le deplacement camera
          isGrabbed = true;
          runEvents(eventGrabRun);
          eventGrab();
        }
      }
      if (isGrabbed && kb.mouseUClick[0]) {
        isGrabbed = false;
        cam.GRAB = true;
        runEvents(eventLiberateRun);
        eventLiberate();
      }
      if (isGrabbed && isClicked) {
        if (!constrainX) setPX(cam.getCamMouse().x + mx);
        if (!constrainY) setPY(cam.getCamMouse().y + my);
        runEvents(eventDragRun);
        eventDrag();
      }
    }
    if (isSelectable) {
      if (isHovered && kb.mouseClick[0]) {
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
      } else if (!isHovered && kb.mouseClick[0] && isSelected) {
        gui.selected_widget = null;
        showOutline = false;
        if (isField) showCursor = false;
        isSelected = false;
      }
    }
    if (isField && isSelected && kb.keyClick) {
      if (key == CODED) {
        if (keyCode == LEFT) {
          cursorPos = max(0, cursorPos-1);
        } else if (keyCode == RIGHT) {
          cursorPos = min(cursorPos+1, label.length());
        } 
      } else {
        if (key == BACKSPACE && cursorPos > 0) {
          String str = label.substring(0, cursorPos-1);
          String end = label.substring(cursorPos, label.length());
          label = str + end;
          cursorPos--;
          runEvents(eventFieldChangeRun);
        } else if (key == BACKSPACE || key == ENTER) {
          
        } else {
          String str = label.substring(0, cursorPos);
          String end = label.substring(cursorPos, label.length());
          label = str + key + end;
          cursorPos++;
          runEvents(eventFieldChangeRun);
        }
      }
    }
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
  int layer;
  boolean active = true;
  Drawer() {}
  Drawer(Drawing_pile p) {
    layer = 0;
    pile = p;
    pile.drawables.add(this);
  }
  Drawer(Drawing_pile p, int l) {
    layer = l;
    pile = p;
    pile.drawables.add(this);
  }
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
  Hoverable_pile() { }
  void addEventNotFound(Runnable r) { eventsNotFound.add(r); }
  void removeEventNotFound(Runnable r) { eventsNotFound.remove(r); }
  void search(PVector pointer) {
    int layer = 0;
    for (Hoverable h : hoverables) { 
      if (layer < h.layer) layer = h.layer;
      h.mouseOver = false;
    }
    
    boolean found = false;
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



 
