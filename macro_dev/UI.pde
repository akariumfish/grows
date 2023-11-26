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


class nSelectZone extends Callable {
  Hoverable_pile pile;
  Drawer drawer;
  Rect select_zone = new Rect();
  boolean emptyClick = false;
  int clickDelay = 0;
  
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
      if (kb.mouseUClick[1]) emptyClick = false;
      select_zone.size.x = cam.getCamMouse().x - select_zone.pos.x;
      select_zone.size.y = cam.getCamMouse().y - select_zone.pos.y;
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
  private ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  
  void add(nWidget w) {
    excludes.add(w);
    //close others when seton event
    w.addEventSwitchOn(new Runnable(w) { public void run() { 
      for (nWidget n : excludes) if (n != (nWidget)builder) n.setOff();
    } } );
    
    //removed when cleared
    //      todo
    
    
  }
  
  void closeAll() {
    for (nWidget n : excludes) n.setOff();
  }
  
  void clear() {
    
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
  
  nWidget hide() { hide = true; if (drawer != null) drawer.active = false; changePosition(); if (hover != null) hover.active = false; customVisibilityChange(); for (nWidget w : childs) w.hide(); return this; }
  nWidget show() { hide = false; if (drawer != null) drawer.active = true; changePosition(); if (hover != null) hover.active = true; customVisibilityChange(); for (nWidget w : childs) w.show(); return this; }
  
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
  
  void toLayerTop() {
    drawer.toLayerTop();
    hover.toLayerTop();
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
  
  nWidget addEventGrab(Runnable r)       { eventGrabRun.add(r); return this; }
  nWidget addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  nWidget addEventLiberate(Runnable r)   { eventLiberateRun.add(r); return this; }
  
  nWidget addEventMouseEnter(Runnable r) { eventMouseEnterRun.add(r); return this; }
  nWidget addEventMouseLeave(Runnable r) { eventMouseLeaveRun.add(r); return this; }
  
  nWidget addEventPress(Runnable r)      { eventPressRun.add(r); return this; }
  nWidget addEventRelease(Runnable r)    { eventReleaseRun.add(r); return this; }
  
  nWidget addEventTrigger(Runnable r)    { eventTriggerRun.add(r); return this; }
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
