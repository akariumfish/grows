/*

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
    
    Taskbar show pre choosen opened panel (collapsed or not) in rows n collumns
      trigger uncollapse and bring to front
    Panel
      has : title, background, default tab
      can has : 
        grabbable title, close button, reduc/enlarg button, 
        hilightable front for selection, 
        collapse to taskbar button, menubar, tab bar
      can add : menu, menu entry(trigger), tab
      tab : group of tabDrawer on top of background, one tab shown at a time
        can permit Y scroll through drawer
          des cache de la hauteur du plus grand drawer seront ajouté up n down
        can add a scrollbar
        tabs can change the panel back height
        TabDrawer
           all methods for widgets and complex widget creation
  
  Widget typical Objects
    Trigger run command
    switch ctrl sbool
    label can watch snumber
    separating line

*/

void build_tools_theme(nTheme t, float ref_size) {
  t.addModel("hard_back", new nWidget()
    .setStandbyColor(color(50))
    .setOutlineColor(color(255, 60))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  t.addModel("label", new nWidget()
    .setFont(int(ref_size/1.5))
    .setText("--")
    );
  t.addModel("Trigger", new nWidget()
    .setTrigger()
    .setOutlineColor(color(255, 60))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  t.addModel("Switch", new nWidget()
    .setSwitch()
    .setOutlineColor(color(255, 60))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  t.addModel("Trigger-S1", t.newWidget("Trigger")
      .setSize(ref_size*5, ref_size)
    );
  t.addModel("Switch-S1", t.newWidget("Switch")
      .setSize(ref_size*5, ref_size)
    );
}

void linkToSwitch(sBoo boo, nWidget w) {
  //boo.addEventChange(new Runnable() { public void run() { w.set(get()); } } );
  //w.addEventSwitchOn(new Runnable() { public void run() { boo.set(true); } } );
  //w.addEventSwitchOff(new Runnable() { public void run() { boo.set(false); } } );
}

class nToolPanel {
  
  nWidget addLabel(String r, float x, float y) { return addModel("label",x ,y).setText(r); }
  nWidget addTrigger(String r, float x, float y) { return addModel("Trigger",x ,y).setText(r); }
  nWidget addSwitch(String r, float x, float y) { return addModel("Switch",x ,y).setText(r); }
  
  nWidget panel;
  nGUI gui; 
  
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  
  nToolPanel(nGUI _g, float ref_size) {
    gui = _g;
    panel = addModel("hard_back", 
       gui.view.pos.x, gui.view.pos.y + gui.view.size.y - ref_size*4.625, 
       ref_size*40, ref_size*4.625);
  }
  nWidget addModel(String r) { 
    nWidget w = gui.theme.newWidget(gui, r).setParent(panel);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setParent(panel).setPosition(x, y);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setParent(panel).setPosition(x, y).setSize(w, h);
    widgets.add(nw); nw.toLayerTop(); return nw; }
  nToolPanel setLayer(int l) { 
    panel.setLayer(l); 
    for (nWidget w : widgets) w.setLayer(l);
    return this; 
  }
  nToolPanel toLayerTop() { 
    panel.toLayerTop(); 
    for (nWidget w : widgets) w.toLayerTop();
    return this; 
  }
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
      .setDrawer(new Drawer(_g.drawing_pile) { public void drawing() {
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


 
