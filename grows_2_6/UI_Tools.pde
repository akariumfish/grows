/*

  Complex Widget Objects
    Info
      can appear on top of the mouse with text
    Hilightable Front
      selectable, run event when selected
    linkedValue switch <> bool , field <> int float
    watcherValue field < int float
    ControlValue trigger > runnable , bool (switch it) , int float (increment / factor it)
    H / V Cursor > svalue
    Graph from sValue
      rectangular canvas with value history has graph
      auto scale, can do multi value
  Complex GUI Objects
    Menubar : series of horizontal switch mutualy exclusive
      auto adjust largeur
      each open a dropdown list of trigger button who close the menus
        close when clicked anywhere else
        on topmost layer
    Scrollbar up/down button, view bar, react to mouse 
      possibly react in a bigger zone than himself to acomodate scroll list
    Scrollable list from string list
      trigger / one select / multi select
    SelectZone
      draw a rectangular zone by click n dragging
      Hilightable front activated inside when releasing are marqued has selected
      they have event when selected / unselected
    
    Tool panel fixe on screen but collapsable (button to enlarg appear when mouse is close)
      can move away if camera move toward him
      all methods for widgets and complex widget creation
    
    Taskbar show pre choosen opened panel (collapsed or not) in rows n collumns
      trigger uncollapse and bring to front
    Panel
      has : title, background, default tab
      can has : 
        grabbable title, close button, reduc/enlarg button, 
        hilightable front for selection, 
        collapse to taskbar button, 
        menu bar, tab bar
      can add : menu, menu entry(trigger), tab
      tab : group of tabDrawer on top of background, one tab shown at a time
        can permit Y scroll through drawer
          des cache de la hauteur du plus grand drawer seront ajouté up n down
        can add a scrollbar
        tabs can change the panel back height
        TabDrawer
           all methods for widgets and complex widget creation
*/



class nBuilder { // base pour les class constructrice de nwidget basic
  
  nWidget addRef(float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, "ref").setPosition(x, y); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
    
  nWidget addModel(String r) { 
    nWidget w = gui.theme.newWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, String t) { 
    nWidget w = gui.theme.newWidget(gui, r).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x, y); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, String t, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x, y).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x, y).setSize(w, h); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
  nWidget addModel(String r, String t, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x, y).setSize(w, h).setText(t); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
      
  nLinkedWidget addLinkedModel(String r) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nLinkedWidget addLinkedModel(String r, String t) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nLinkedWidget addLinkedModel(String r, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x, y); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }  
  nLinkedWidget addLinkedModel(String r, String t, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x, y).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }    
    
  nWatcherWidget addWatcherModel(String r) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, String t) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x, y); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, String t, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x, y).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
      
  nCtrlWidget addCtrlModel(String r) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, String t) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x, y); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, String t, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x, y).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  
  nGUI gui; 
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float ref_size = 30;
  
  nBuilder setLayer(int l) { for (nWidget w : widgets) w.setLayer(l); return this; }
  nBuilder toLayerTop() { for (nWidget w : widgets) w.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w; }
  
  nBuilder(nGUI _g, float s) {
    gui = _g; ref_size = s;
    gui.theme.addModel("ref", new nWidget()
      );
    gui.theme.addModel("Hard_Back", new nWidget()
      .setStandbyColor(color(50))
      .setOutlineColor(color(255, 60))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      );
    gui.theme.addModel("Soft_Back", new nWidget()
      .setStandbyColor(color(60, 100))
      .setOutlineColor(color(255, 60))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    gui.theme.addModel("Label", new nWidget()
      .setFont(int(ref_size/1.5))
      .setStandbyColor(color(255, 0))
      );
    gui.theme.addModel("Label_Back", new nWidget()
      .setFont(int(ref_size/1.5))
      .setStandbyColor(color(70))
      );
    gui.theme.addModel("Button", new nWidget()
      .setFont(int(ref_size/1.5))
      );
    gui.theme.addModel("Button_Outline", new nWidget()
      .setOutlineColor(color(255, 60))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      .setFont(int(ref_size/1.5))
      );
    gui.theme.addModel("Button_Check", new nWidget()
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    gui.theme.addModel("Field", new nWidget()
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineSelectedColor(color(255, 120))
      .setOutlineWeight(ref_size / 10)
      .setFont(int(ref_size/1.5))
      );
    make("Label");
    make("Button");
    make("Label_Back");
    make("Button_Outline");
    make("Button_Check");
    make("Field");
  }
  void do_sizes(String base, String post, float w, float h) {
    gui.theme.addModel(base+post, gui.theme.newWidget(base).setSize(w, h));}
  void do_places(String base, String post, float x, float y, float w, float h) {
    gui.theme.addModel(base+post, gui.theme.newWidget(base).setSize(w, h).setPosition(x, y));}
  
  void make(String base) {
    do_sizes(base, "-S1", ref_size, ref_size);
    do_sizes(base, "-S2", ref_size*2.5, ref_size);
    do_sizes(base, "-S3", ref_size*4, ref_size);
    do_sizes(base, "-S4", ref_size*10, ref_size);
    
    do_places(base, "-S3-P1", ref_size*0.5, 0, ref_size*4, ref_size);
    do_places(base, "-S3-P2", ref_size*5.5, 0, ref_size*4, ref_size);
    
    do_places(base, "-S2-P1", ref_size*0.5, 0, ref_size*2.5, ref_size);
    do_places(base, "-S2-P2", ref_size*3.75, 0, ref_size*2.5, ref_size);
    do_places(base, "-S2-P3", ref_size*7, 0, ref_size*2.5, ref_size);
  }
}

class nDrawer extends nBuilder {
  nShelf getShelf() { return shelf; }
  nShelfPanel getShelfPanel() { return shelf.shelfPanel; }
  nShelf shelf;
  nWidget ref;
  float drawer_height = 0;
  nDrawer(nShelf s, float h) {
    super(s.gui, s.ref_size);
    ref = addModel("ref"); shelf = s;
    drawer_height = h; }
  nDrawer setLayer(int l) { super.setLayer(l); ref.setLayer(l); return this; }
  nDrawer toLayerTop() { super.toLayerTop(); ref.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(ref).setDrawer(this); }
  
  //preset drawer for svalue ctrl
  nDrawer setValueCtrl() {
    
    return this;
  }
}

class nShelf extends nBuilder {
  nDrawer getDrawer(int s) { return drawers.get(s); }
  nShelfPanel getShelfPanel() { return shelfPanel; }
  nShelf setPosition(nWidget p, float x, float y) { ref.setParent(p).setPosition(x, y); return this; }
  nDrawer addDrawer(float h) {
    if (max_drawer == 0 || drawers.size() < max_drawer) {
      total_height += h;
      if (eventHeight != null) eventHeight.run();
      nDrawer d = new nDrawer(this, h);
      if (drawers.size() == 0) d.ref.setParent(ref);
      else {
        nDrawer prev = drawers.get(drawers.size()-1);
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      drawers.add(d); return d;  }
    return null;
  }
  nDrawer addDrawer() { return addDrawer(ref_size); }
  nShelf addSeparator(float h) { addDrawer(h); return this; }
  nShelf setMax(int m) { max_drawer = m; return this; }
  
  nShelfPanel shelfPanel;
  nWidget ref;
  ArrayList<nDrawer> drawers = new ArrayList<nDrawer>();
  int max_drawer = 0; // 0 = no limit
  float total_height = 0;
  Runnable eventHeight;
  
  nShelf(nShelfPanel s) {
    super(s.gui, s.ref_size);
    shelfPanel = s;
    ref = addModel("ref");
  }
  nShelf addEventHeight(Runnable r) { eventHeight = r; return this; }
  nShelf setLayer(int l) { super.setLayer(l); 
    ref.setLayer(l); for (nDrawer d : drawers) d.setLayer(l); return this; }
  nShelf toLayerTop() { super.toLayerTop(); 
    ref.toLayerTop(); for (nDrawer d : drawers) d.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(ref); }
}



class nShelfPanel extends nBuilder {
  
  nDrawer getDrawer(int c, int r) { return shelfs.get(c).drawers.get(r); }
  nShelf getShelf(int s) { return shelfs.get(s); }
  
  nShelf addShelf() {
    nShelf s = new nShelf(this);
    s.setPosition(panel, shelfs.size()*ref_size*(width_factor+space_factor)+ref_size*space_factor, 
                         ref_size*space_factor);
    s.addEventHeight(new Runnable(s) { public void run() { 
      float n = ((nShelf)builder).total_height; if (n > max_height) setHeight(n); } } );
    shelfs.add(s);
    panel.setSX(shelfs.size()*ref_size*(width_factor+space_factor)+ref_size*space_factor);
    return s;
  }
  nShelfPanel addGrid(int c, int r) {
    for (int i = 0 ; i < c ; i++) {
      nShelf s = addShelf();
      for (int j = 0 ; j < r ; j++) s.addDrawer(ref_size*(1+space_factor));
    }
    panel.setSize(c*ref_size*(width_factor+space_factor)+ref_size*space_factor, 
               r*ref_size*(1+space_factor)+ref_size*space_factor);
    return this;
  }
  
  
  nShelfPanel setHeight(float h) { panel.setSY(h+2*space_factor); return this; }
    
  nShelfPanel(nGUI _g, float ref_size, float _width_factor, float _space_factor, int c, int r) {
    super(_g, ref_size);
    width_factor = _width_factor; space_factor = _space_factor;
    panel = addModel("Hard_Back")
      .setSize(c*ref_size*(width_factor+space_factor)+ref_size*space_factor, 
               r*ref_size*(1+space_factor)+ref_size*space_factor);
    for (int i = 0 ; i < c ; i++) {
      nShelf s = new nShelf(this)
        .setPosition(panel, i*ref_size*(width_factor+space_factor)+ref_size*space_factor, 
                            ref_size*space_factor)
        .setMax(r);
      for (int j = 0 ; j < r ; j++) s.addDrawer(ref_size*(1+space_factor));
      shelfs.add(s);
    }
  }
  nShelfPanel(nGUI _g, float ref_size, float _width_factor, float height_factor, float _space_factor) {
    super(_g, ref_size);
    panel = addModel("Hard_Back");
    panel.setSY(ref_size*(height_factor+_space_factor)+_space_factor);
    width_factor = _width_factor; space_factor = _space_factor;
  }
  
  float width_factor, space_factor, max_height = 0;
  nWidget panel;
  ArrayList<nShelf> shelfs = new ArrayList<nShelf>();
  
  nShelfPanel setLayer(int l) { super.setLayer(l); 
    panel.setLayer(l); for (nShelf d : shelfs) d.setLayer(l); return this; }
  nShelfPanel toLayerTop() { super.toLayerTop(); 
    panel.toLayerTop(); for (nShelf d : shelfs) d.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(panel); }
}


class nToolPanel extends nShelfPanel {
  nCtrlWidget reduc;
  boolean hide = false, right = false, top = true;
  nToolPanel(nGUI _g, float ref_size) {
    super(_g, ref_size, 10, 0, 0.125); }
  nToolPanel setTop(boolean sd) {
    top = sd;
    if (sd) panel.setPY(0); 
    else panel.setPY(gui.view.pos.y + gui.view.size.y - panel.getSY()); 
    return this; }
  nToolPanel addReduc(boolean sd) {
    right = sd;
    if (sd) panel.setPX(gui.view.pos.x); 
    else panel.setPX(gui.view.pos.x + gui.view.size.x - panel.getSX());
    reduc = addCtrlModel("Button", "<")
      .setRunnable(new Runnable(this) { public void run() { 
        if      (hide && right)  { panel.setPX(gui.view.pos.x).show(); reduc.setText("<"); } 
        else if (hide && !right) { 
          panel.show().setPX(gui.view.pos.x + gui.view.size.x - panel.getSX()); reduc.setText(">"); } 
        else if (!hide && right)  { panel.hide(); reduc.show().setText(">"); }
        else                     { 
          panel.hide().setPX(gui.view.pos.x + gui.view.size.x); reduc.show().setText("<"); }
        hide = !hide;
      } } );
    reduc.setSize(ref_size, panel.getSY())
      .stackRight();
    if (!sd) reduc.setText(">").stackLeft();
    return this;
  }
  nToolPanel setHeight(float h) { 
    super.setHeight(h); 
    if (reduc != null) reduc.setSY(h+2*space_factor);
    if (!top) panel.setPY(panel.getLocalY() - (h+2*space_factor)); //make widget stack aroud pos even wout parent
    return this; }
}





class nExcludeGroup {
  ArrayList<nWidget> excludes = new ArrayList<nWidget>();
  void add(nWidget w) {
    excludes.add(w);
    w.addEventSwitchOn(new Runnable(w) { public void run() { 
      for (nWidget n : excludes) if (n != (nWidget)builder) n.setOff(); } } );
    w.addEventClear(new Runnable(w) { public void run() { 
      excludes.remove((nWidget)builder); } } );
  }
  void closeAll() { for (nWidget n : excludes) n.setOff(); }
  void forceCloseAll() { for (nWidget n : excludes) n.forceOff(); } 
  void clear() { excludes.clear(); }
  //nExcludeGroup() {}
}




class nInfo {
  void showText(String t) { 
    label.setPX(-t.length()*(ref.getLocalSX() / 1.5) / 2).setSX(t.length()*(ref.getLocalSX() / 1.5));
    label.setText(t); ref.show(); count = 2; }
  nInfo setLayer(int l) { label.setLayer(l); ref.setLayer(l); return this; }
  nInfo toLayerTop() { label.toLayerTop(); ref.toLayerTop(); return this; }
  nInfo(nGUI _g, float f) {
    gui = _g;
    ref = new nWidget(gui, 0, 0, f, f)
      .setDrawable(new Drawable(_g.drawing_pile) { public void drawing() {
        fill(ref.look.standbyColor);
        noStroke();
        triangle(ref.getX(), ref.getY(), 
                 ref.getX() - ref.getSX(), ref.getY() - ref.getSY(), 
                 ref.getX() + ref.getSX(), ref.getY() - ref.getSY() );
      } } )
      .addEventFrame_Builder(new Runnable() { public void run() {
        count--;
        nWidget w = ((nWidget)builder);
        w.setPosition(gui.mouseVector.x, gui.mouseVector.y);
        if (count == 0) w.hide();
      } } );
    label = new nWidget(gui, "", int(f), 0, -f, 0, f*1.5)
      .setParent(ref)
      .stackUp()
      ;
    ref.hide();
  }
  nWidget ref,label;
  nGUI gui;
  int count = 0;
}

//class nPanelDrawer {
//  nPanel panel;
  
//  float pos = 0;
  
//  nPanelDrawer(nPanel _pan, float p) {
//    panel = _pan;
//    pos = p;
//  }
  
//  nPanel getPanel() { return panel; }
  
//  nWidget addWidget(String n, int f, float x, float y, float l, float h) {
//    nWidget w = new nWidget(panel.gui, n, f, x, y + pos, l, h);
//    w.setParent(panel.back).setPanelDrawer(this).setLayer(panel.layer);
//    panel.widgets.add(w);
//    return w;
//  }
  
//  nList addList(float x, float y, float w, float s) {
//    nList l = new nList(panel.gui);
//    l.getRefWidget()
//      .setParent(panel.getRefWidget())
//      .setPosition(x, y+pos);
//    l.setPanelDrawer(this)
//      .setItemSize(s)
//      .setWidth(w)
//      .setLayer(panel.layer)
//      ;
//    panel.lists.add(l);
//    return l;
//  }
//}


//class nPanel {
  
//  nPanelDrawer addDrawer(float h) {
//    nPanelDrawer d = new nPanelDrawer(this, back_h);
//    setBackHeight(back_h + h);
//    return d;
//  }
  
//  nPanel addSeparator(float h) {
//    setBackHeight(back_h + h);
//    return this;
//  }
  
//  nPanel end() {
//    setLayer(layer);
//    toLayerTop();
//    return this;
//  }
  
//  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
//  ArrayList<nList> lists = new ArrayList<nList>();
  
//  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
//  nPanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
//  nPanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
//  ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
//  nPanel addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
//  nPanel removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  
//  nWidget grabber, back, closer;
  
//  nGUI gui;
  
//  float haut = 60;
//  float larg = haut*10;
//  float back_h = 0;
  
//  int layer = 0;
  
//  nWidget getRefWidget() { return back; }
//  nWidget getGrabWidget() { return grabber; }
  
//  nPanel(nGUI _gui, String n, float x, float y) {
//    gui = _gui;
    
//    grabber = new nWidget(gui, n, int(haut/1.5), x, y, larg - haut, haut)
//      .setLayer(0)
//      .setGrabbable()
//      .setOutlineColor(color(100))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      .addEventDrag(new Runnable() { public void run() { runEvents(eventDragRun); } } )
//      ;
      
//    closer = new nWidget(gui, "X", int(haut/1.5), 0, 0, haut, haut)
//      .setTrigger()
//      .addEventTrigger(new Runnable() { public void run() { runEvents(eventCloseRun); clear(); } } )
//      .setParent(grabber)
//      .stackRight()
//      .setLayer(0)
//      .setOutlineColor(color(100))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      ;
//    back = new nWidget(gui, 0, 0, larg, 0) {
//      public void customShapeChange() {
//        //front.setSize(back.getLocalSX(), back.getLocalSY());
//      }
//    }
//      .setParent(grabber)
//      .stackDown()
//      .setLayer(0)
//      .setStandbyColor(color(40))
//      .setOutlineColor(color(180, 60))
//      .setOutlineWeight(haut / 16)
//      .setOutline(true)
//      ;
//    grabber.toLayerTop();
//    closer.toLayerTop();
//  }
  
//  nPanel setPosition(float x, float y) { grabber.setPosition(x, y); return this; }
//  nPanel setItemHeight(float h) {
//    haut = h;
//    grabber.setSize(larg-haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    closer.setSize(haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    back.setSX(larg)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    return this;
//  }
//  nPanel setWidth(float w) {
//    larg = w;
//    grabber.setSize(larg-haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    closer.setSize(haut,haut)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    back.setSX(larg)
//      .setOutlineWeight(haut / 16)
//      .setFont(int(haut/1.5));
//    return this;
//  }
//  nPanel setBackHeight(float h) {
//    back_h = h;
//    back.setSY(back_h);
//    return this;
//  }
//  nPanel setLayer(int l) {
//    layer = l;
//    grabber.setLayer(l);
//    closer.setLayer(l);
//    back.setLayer(l);
//    for (nWidget w : widgets) w.setLayer(l);
//    for (nList  w : lists) w.setLayer(l);
//    return this;
//  }
//  nPanel toLayerTop() {
//    back.toLayerTop();
//    grabber.toLayerTop();
//    closer.toLayerTop();
//    for (nWidget w : widgets) w.toLayerTop();
//    for (nList  w : lists) w.toLayerTop();
//    return this;
//  }
//  nPanel hide() {
//    grabber.hide();
//    return this;
//  }
//  nPanel show() {
//    grabber.show();
//    return this;
//  }
//  nPanel clear() {
//    for (nWidget w : widgets) w.clear();
//    for (nList  w : lists) w.clear();
//    back.clear();
//    closer.clear();
//    grabber.clear();
//    return this;
//  }
//}



//class nList {
  
//  nPanelDrawer panel_drawer = null;
//  nList setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
//  nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
//  nGUI gui;
//  ArrayList<nWidget> listwidgets = new ArrayList<nWidget>();
//  ArrayList<String> entrys = new ArrayList<String>();
//  nWidget back;
//  nScroll scroll;
//  float item_s = 60;
//  float larg = item_s*10;
//  int list_widget_nb = 5;
//  int entry_pos = 0;
  
//  int last_choice_index = 0;
//  String last_choice_text = null;
  
//  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
//  nList addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
//  nList removeEventChange(Runnable r)    { eventChangeRun.remove(r); return this; }
  
//  nList addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
//  nWidget getRefWidget() { return back; }
  
//  int layer = 0;
  
//  nList setLayer(int l) {
//    layer = l;
//    scroll.setLayer(l);
//    back.setLayer(l);
//    for (nWidget w : listwidgets) w.setLayer(l);
//    return this;
//  }
//  nList toLayerTop() {
//    back.toLayerTop();
//    scroll.toLayerTop();
//    for (nWidget w : listwidgets) w.toLayerTop();
//    return this;
//  }
//  nList clear() {
//    scroll.clear();
//    for (nWidget w : listwidgets) w.clear();
//    back.clear();
//    return this;
//  }
//  nList(nGUI _gui) {
//    gui = _gui;
//    back = new nWidget(gui, 0, 0)
//        ;
//    scroll = new nScroll(gui, larg - item_s, 0, item_s, item_s*list_widget_nb);
//    scroll.getRefWidget().setParent(back);
//    scroll.setView(list_widget_nb)
//      .addEventChange(new Runnable() { public void run() {
//        entry_pos = scroll.entry_pos;
//        update_list();
//      }});
//    for (int i = 0 ; i < list_widget_nb ; i++) {
//      nWidget ne = new nWidget(gui, 0, 0, larg - item_s, item_s)
//        .stackDown()
//        .setSwitch()
//        .addEventSwitchOn(new Runnable() { public void run() {
//          click();
//        }})
//        ;
//      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
//      listwidgets.add(ne);
//    }
//    for (nWidget w : listwidgets) 
//      for (nWidget w2 : listwidgets)
//        if (w != w2) ;
//          //w.addExclude(w2);
//  }
  
//  void click() {
//    int i = 0;
//    for (nWidget w : listwidgets) {
//      if (w.isOn()) {
//        w.setOff();
//        break;
//      }
//      i++;
//    }
//    last_choice_index = i+entry_pos;
//    last_choice_text = copy(listwidgets.get(i).getText());
//    runEvents(eventChangeRun);
//  }
//  void update_list() {
//    for (int i = 0 ; i < list_widget_nb ; i++) {
//      nWidget w = listwidgets.get(i);
//      if (i + entry_pos < entrys.size()) w.setText(entrys.get(i + entry_pos)); else w.setText("");
//    }
//  }
//  nList setEntrys(String[] l) {
//    entrys.clear();
//    for (String s : l) entrys.add(copy(s));
//    scroll.setPos(0);
//    scroll.setEntryNb(l.length);
//    scroll.setView(list_widget_nb);
//    entry_pos = 0;
//    update_list();
//    return this;
//  }
//  nList setListLength(int l) {
//    for (int i = 0 ; i < list_widget_nb ; i++) listwidgets.get(i).clear();
//    listwidgets.clear();
//    list_widget_nb = l;
//    for (int i = 0 ; i < list_widget_nb ; i++) {
//      nWidget ne = new nWidget(gui, 0, 0, larg - item_s, item_s)
//        .stackDown()
//        .setSwitch()
//        .addEventSwitchOn(new Runnable() { public void run() {
//          click();
//        }})
//        ;
//      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
//      listwidgets.add(ne);
//    }
//    for (nWidget w : listwidgets) 
//      for (nWidget w2 : listwidgets)
//        if (w != w2) ;
//          //w.addExclude(w2);
    
//    scroll.setPos(0);
//    scroll.setEntryNb(entrys.size());
//    scroll.setView(list_widget_nb);
//    entry_pos = 0;
//    update_list();
//    return this;
//  }
//  nList setItemSize(float l) {
//    item_s = l;
//    scroll.getRefWidget().setPosition(larg - item_s, 0);
//    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
//    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
//    return this;
//  }
//  nList setWidth(float l) {
//    larg = l;
//    scroll.getRefWidget().setPosition(larg - item_s, 0);
//    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
//    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
//    return this;
//  }
//}

//class nScroll {
//  nGUI gui;
//  nWidget up, down, back, curs;
//  float larg = 60;
//  float haut = 200;
//  int entry_nb = 1;
//  int entry_pos = 0;
//  int entry_view = 1;
  
//  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
//  nScroll addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
//  nScroll removeEventChange(Runnable r)       { eventChangeRun.remove(r); return this; }
  
//  nScroll setEntryNb(int v) { entry_nb = v; update_cursor(); return this; }
//  nScroll setView(int v) { entry_view = v; update_cursor(); return this; }
//  nScroll setPos(int v) { entry_pos = v; update_cursor(); return this; }
  
//  nScroll setHeight(float h) { haut = h; back.setSY(h); update_cursor(); return this; }
//  nScroll setWidth(float w) { 
//    larg = w; back.setSX(w); up.setSize(w, w); down.setSize(w, w); curs.setSX(w);
//    up.setOutlineWeight(w / 16).setFont(int(w/1.5));
//    down.setOutlineWeight(w / 16).setFont(int(w/1.5));
//    curs.setOutlineWeight(w / 16).setFont(int(w/1.5));
//    update_cursor(); return this; }
  
//  nWidget getRefWidget() { return back; }
  
//  int layer = 0;
  
//  nScroll setLayer(int l) {
//    layer = l;
//    up.setLayer(l);
//    down.setLayer(l);
//    curs.setLayer(l);
//    back.setLayer(l);
//    return this;
//  }
//  nScroll toLayerTop() {
//    back.toLayerTop();
//    up.toLayerTop();
//    down.toLayerTop();
//    curs.toLayerTop();
//    return this;
//  }
//  nScroll clear() {
//    up.clear();
//    down.clear();
//    curs.clear();
//    back.clear();
//    return this;
//  }
  
//  nScroll(nGUI _gui, float x, float y, float w, float h) {
//    gui = _gui;
//    larg = w; haut = h;
//    back = new nWidget(gui, x, y, w, h)
//        .setStandbyColor(color(70))
//        .toLayerTop()
//        ;
//    up = new nWidget(gui, "^", int(w/1.5), 0, 0, w, w)
//        .setParent(back)
//        .toLayerTop()
//        .setOutlineColor(color(100))
//        .setOutlineWeight(w / 16)
//        .setOutline(true)
//        .setTrigger()
//        .addEventTrigger(new Runnable() { public void run() {
//          if (entry_pos > 0) entry_pos--;
//          update_cursor();
//          runEvents(eventChangeRun);
//        }})
//        ;
//    down = new nWidget(gui, "V", int(w/1.5), 0, 0, w, w)
//        .setParent(back)
//        .toLayerTop()
//        .setOutlineColor(color(100))
//        .setOutlineWeight(w / 16)
//        .setOutline(true)
//        .alignDown()
//        .setTrigger()
//        .addEventTrigger(new Runnable() { public void run() {
//          if (entry_pos < entry_nb - entry_view) entry_pos++;
//          update_cursor();
//          runEvents(eventChangeRun);
//        }})
//        ; 
//    curs = new nWidget(gui, 0, 0, w, h-(w*2))
//        .setParent(up)
//        .toLayerTop()
//        .stackDown()
//        .setStandbyColor(color(100))
//        ;
//  }
//  void update_cursor() {
//    if (entry_view <= entry_nb) {
//      float h = haut - (larg*2);
//      float d = h / entry_nb;
//      curs.setSY(d*entry_view)
//        .setPY(d*entry_pos);
//    } else {
//      curs.setSY(haut - (larg*2))
//        .setPY(0);
//    }
//  }
//}


////ArrayList<nWidget> menubuttons = new ArrayList<nWidget>(0);

////  nWidget newMenu(String name) {
////    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size() + 1);
////    nWidget menu = new nWidget(gui, name, int(macro_size/1.85), 0, 0, new_width, macro_size * 0.75)
////      .setSwitch()
////      .setLayer(layer)
////      .setOutlineColor(color(100))
////      .setOutlineWeight(macro_size / 16)
////      .setOutline(true)
////      ;
////    if (menubuttons.size() == 0) menu.setParent(reduc).stackDown();
////    else menu.setParent(menubuttons.get(menubuttons.size()-1)).stackRight();
////    for (nWidget w : menubuttons) w.setSX(new_width);
////    menubuttons.add(menu);
////    return menu;
////  }
  
////  Macro_Abstract setWidth(float w) {
////    super.setWidth(w);
////    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size());
////    for (nWidget m : menubuttons) m.setSX(new_width);
////    return this;
////  }

////  ArrayList<nWidget> addbuttons = new ArrayList<nWidget>(0);

////  Macro_Sheet newAdd(String name, Runnable run) {
////    nWidget add = new nWidget(gui, name, int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
////      .setTrigger()
////      .setLayer(getBase().menu_layer)
////      .stackDown()
////      .hide()
////      .addEventTrigger(new Runnable() { 
////      public void run() { 
////        getBase().menugroup.closeAll();
////      }
////    }
////    )
////    .addEventTrigger(run)
////      ;
////    if (addbuttons.size() == 0) add.setParent(addExtOut);
////    else add.setParent(addbuttons.get(addbuttons.size()-1));
////    addbuttons.add(add);
////    return this;
////  }

//    //if (getBase().menugroup != null) {
//    //  for (nWidget w : menubuttons) getBase().menugroup.add(w);
//    //}

//    //for (nWidget w : addbuttons) w.setLayer(getBase().menu_layer);
//    //for (nWidget w : addbuttons) w.toLayerTop();

//    //for (int i = menubuttons.size() - 1; i >= 0; i--) menubuttons.get(i).clear(); 

//class nWidgetPile {
//  ArrayList<nWidget> pile = new ArrayList<nWidget>();
  
//  //nWidget newWidget(String name) {
//  //  nWidget add = new nWidget(gui, name, 12, 0, 0, 50, 10)
//  //    .setTrigger()
//  //    //.setLayer(getBase().menu_layer)
//  //    .stackDown()
//  //    .hide()
//  //  //  .addEventTrigger(new Runnable() { 
//  //  //  public void run() { 
//  //  //    getBase().menugroup.closeAll();
//  //  //  }
//  //  //}
//  //  //)
//  //    ;
//  //  //if (addbuttons.size() == 0) add.setParent(addExtOut);
//  //  //else add.setParent(addbuttons.get(addbuttons.size()-1));
//  //  //addbuttons.add(add);
//  //  return add;
//  //}
  
//}


////class nSelectZone extends Callable {
////  Hoverable_pile pile;
////  Drawer drawer;
////  Rect select_zone = new Rect();
////  boolean emptyClick = false;
////  int clickDelay = 0;
////  boolean ON = true;
  
////  nSelectZone addEventEndSelect(Runnable r)  { eventEndSelect.add(r); return this; }
////  nSelectZone removeEventEndSelect(Runnable r)       { eventEndSelect.remove(r); return this; }
////  ArrayList<Runnable> eventEndSelect = new ArrayList<Runnable>();
////  nSelectZone addEventStartSelect(Runnable r)  { eventStartSelect.add(r); return this; }
////  nSelectZone removeEventStartSelect(Runnable r)       { eventStartSelect.remove(r); return this; }
////  ArrayList<Runnable> eventStartSelect = new ArrayList<Runnable>();
  
////  boolean isSelecting() { return emptyClick; }
  
////  nGUI gui;
////  nSelectZone(nGUI _g) {
////    gui = _g;
////    pile = _g.hoverable_pile;
////    pile.addEventNotFound(new Runnable() { public void run() { 
////      if (ON && gui.in.getClick("MouseRight")) clickDelay = 1; 
////    } } );
////    drawer = new Drawer(_g.drawing_pile, 25) { public void drawing() {
////      noFill();
////      stroke(255);
////      strokeWeight(2/gui.in.cam.cam_scale.get());
////      Rect z = new Rect(select_zone);
////      if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
////      if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
////      if (ON && emptyClick) z.draw();
////    } };
////      //addChannel(_g.GUI_Call);
////  }
////  boolean isUnder(nWidget w) {
////    Rect z = new Rect(select_zone);
////    if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
////    if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
////    if (emptyClick && !w.isHided() && rectCollide(w.getRect(), z)) return true;
////    return false;
////  }
////  void answer(Channel c, float f) {
////    if (ON) {
////      if (clickDelay > 0) {
////        clickDelay--;
////        if (clickDelay == 0) { 
////          emptyClick = true;
////          runEvents(eventStartSelect);
////          select_zone.pos.x = gui.in.cam.mouse.x;
////          select_zone.pos.y = gui.in.cam.mouse.y;
////        }
////      }
////      if (emptyClick) {
////        select_zone.size.x = gui.in.cam.mouse.x - select_zone.pos.x;
////        select_zone.size.y = gui.in.cam.mouse.y - select_zone.pos.y;
////        if (gui.in.getUnClick("MouseRight")) { 
////          runEvents(eventEndSelect);
////          emptyClick = false; 
////        }
////      }
////    }
////    if (!gui.in.getState("MouseRight")) emptyClick = false;
////  }
////}


 
