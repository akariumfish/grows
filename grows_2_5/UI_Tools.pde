
void mySetup() {
  
  
}

class nPanelDrawer {
  nPanel panel;
  
  float pos = 0;
  
  nPanelDrawer(nPanel _pan, float p) {
    panel = _pan;
    pos = p;
  }
  
  nPanel getPanel() { return panel; }
  
  nWidget addWidget(String n, int f, float x, float y, float l, float h) {
    nWidget w = new nWidget(panel.gui, n, f, x, y + pos, l, h);
    w.setParent(panel.back).setPanelDrawer(this).setLayer(panel.layer);
    panel.widgets.add(w);
    return w;
  }
  
  nList addList(float x, float y, float w, float s) {
    nList l = new nList(panel.gui);
    l.getRefWidget()
      .setParent(panel.getRefWidget())
      .setPosition(x, y+pos);
    l.setPanelDrawer(this)
      .setItemSize(s)
      .setWidth(w)
      .setLayer(panel.layer)
      ;
    panel.lists.add(l);
    return l;
  }
}


class nPanel {
  
  nPanelDrawer addDrawer(float h) {
    nPanelDrawer d = new nPanelDrawer(this, back_h);
    setBackHeight(back_h + h);
    return d;
  }
  
  nPanel addSeparator(float h) {
    setBackHeight(back_h + h);
    return this;
  }
  
  nPanel end() {
    setLayer(layer);
    toLayerTop();
    return this;
  }
  
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  ArrayList<nList> lists = new ArrayList<nList>();
  
  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
  nPanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
  nPanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
  ArrayList<Runnable> eventDragRun = new ArrayList<Runnable>();
  nPanel addEventDrag(Runnable r)       { eventDragRun.add(r); return this; }
  nPanel removeEventDrag(Runnable r)       { eventDragRun.remove(r); return this; }
  
  nWidget grabber, back, closer;
  
  nGUI gui;
  
  float haut = 60;
  float larg = haut*10;
  float back_h = 0;
  
  int layer = 0;
  
  nWidget getRefWidget() { return back; }
  nWidget getGrabWidget() { return grabber; }
  
  nPanel(nGUI _gui, String n, float x, float y) {
    gui = _gui;
    
    grabber = new nWidget(gui, n, int(haut/1.5), x, y, larg - haut, haut)
      .setLayer(0)
      .setGrabbable()
      .setOutlineColor(color(100))
      .setOutlineWeight(haut / 16)
      .setOutline(true)
      .addEventDrag(new Runnable() { public void run() { runEvents(eventDragRun); } } )
      ;
      
    closer = new nWidget(gui, "X", int(haut/1.5), 0, 0, haut, haut)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { runEvents(eventCloseRun); clear(); } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(0)
      .setOutlineColor(color(100))
      .setOutlineWeight(haut / 16)
      .setOutline(true)
      ;
    back = new nWidget(gui, 0, 0, larg, 0) {
      public void customShapeChange() {
        //front.setSize(back.getLocalSX(), back.getLocalSY());
      }
    }
      .setParent(grabber)
      .stackDown()
      .setLayer(0)
      .setStandbyColor(color(40))
      .setOutlineColor(color(180, 60))
      .setOutlineWeight(haut / 16)
      .setOutline(true)
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
  }
  
  nPanel setPosition(float x, float y) { grabber.setPosition(x, y); return this; }
  nPanel setItemHeight(float h) {
    haut = h;
    grabber.setSize(larg-haut,haut)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    closer.setSize(haut,haut)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    back.setSX(larg)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    return this;
  }
  nPanel setWidth(float w) {
    larg = w;
    grabber.setSize(larg-haut,haut)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    closer.setSize(haut,haut)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    back.setSX(larg)
      .setOutlineWeight(haut / 16)
      .setFont(int(haut/1.5));
    return this;
  }
  nPanel setBackHeight(float h) {
    back_h = h;
    back.setSY(back_h);
    return this;
  }
  nPanel setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l);
    for (nWidget w : widgets) w.setLayer(l);
    for (nList  w : lists) w.setLayer(l);
    return this;
  }
  nPanel toLayerTop() {
    back.toLayerTop();
    grabber.toLayerTop();
    closer.toLayerTop();
    for (nWidget w : widgets) w.toLayerTop();
    for (nList  w : lists) w.toLayerTop();
    return this;
  }
  nPanel hide() {
    grabber.hide();
    return this;
  }
  nPanel show() {
    grabber.show();
    return this;
  }
  nPanel clear() {
    for (nWidget w : widgets) w.clear();
    for (nList  w : lists) w.clear();
    back.clear();
    closer.clear();
    grabber.clear();
    return this;
  }
}



class nList {
  
  nPanelDrawer panel_drawer = null;
  nList setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  nGUI gui;
  ArrayList<nWidget> listwidgets = new ArrayList<nWidget>();
  ArrayList<String> entrys = new ArrayList<String>();
  nWidget back;
  nScroll scroll;
  float item_s = 60;
  float larg = item_s*10;
  int list_widget_nb = 5;
  int entry_pos = 0;
  
  int last_choice_index = 0;
  String last_choice_text = null;
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  nList addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  nList removeEventChange(Runnable r)    { eventChangeRun.remove(r); return this; }
  
  nList addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  nWidget getRefWidget() { return back; }
  
  int layer = 0;
  
  nList setLayer(int l) {
    layer = l;
    scroll.setLayer(l);
    back.setLayer(l);
    for (nWidget w : listwidgets) w.setLayer(l);
    return this;
  }
  nList toLayerTop() {
    back.toLayerTop();
    scroll.toLayerTop();
    for (nWidget w : listwidgets) w.toLayerTop();
    return this;
  }
  nList clear() {
    scroll.clear();
    for (nWidget w : listwidgets) w.clear();
    back.clear();
    return this;
  }
  nList(nGUI _gui) {
    gui = _gui;
    back = new nWidget(gui, 0, 0)
        ;
    scroll = new nScroll(gui, larg - item_s, 0, item_s, item_s*list_widget_nb);
    scroll.getRefWidget().setParent(back);
    scroll.setView(list_widget_nb)
      .addEventChange(new Runnable() { public void run() {
        entry_pos = scroll.entry_pos;
        update_list();
      }});
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = new nWidget(gui, 0, 0, larg - item_s, item_s)
        .stackDown()
        .setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() {
          click();
        }})
        ;
      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
      listwidgets.add(ne);
    }
    for (nWidget w : listwidgets) 
      for (nWidget w2 : listwidgets)
        if (w != w2)
          w.addExclude(w2);
  }
  
  void click() {
    int i = 0;
    for (nWidget w : listwidgets) {
      if (w.isOn()) {
        w.setOff();
        break;
      }
      i++;
    }
    last_choice_index = i+entry_pos;
    last_choice_text = copy(listwidgets.get(i).getText());
    runEvents(eventChangeRun);
  }
  void update_list() {
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget w = listwidgets.get(i);
      if (i + entry_pos < entrys.size()) w.setText(entrys.get(i + entry_pos)); else w.setText("");
    }
  }
  nList setEntrys(String[] l) {
    entrys.clear();
    for (String s : l) entrys.add(copy(s));
    scroll.setPos(0);
    scroll.setEntryNb(l.length);
    scroll.setView(list_widget_nb);
    entry_pos = 0;
    update_list();
    return this;
  }
  nList setListLength(int l) {
    for (int i = 0 ; i < list_widget_nb ; i++) listwidgets.get(i).clear();
    listwidgets.clear();
    list_widget_nb = l;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = new nWidget(gui, 0, 0, larg - item_s, item_s)
        .stackDown()
        .setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() {
          click();
        }})
        ;
      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
      listwidgets.add(ne);
    }
    for (nWidget w : listwidgets) 
      for (nWidget w2 : listwidgets)
        if (w != w2)
          w.addExclude(w2);
    
    scroll.setPos(0);
    scroll.setEntryNb(entrys.size());
    scroll.setView(list_widget_nb);
    entry_pos = 0;
    update_list();
    return this;
  }
  nList setItemSize(float l) {
    item_s = l;
    scroll.getRefWidget().setPosition(larg - item_s, 0);
    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
    return this;
  }
  nList setWidth(float l) {
    larg = l;
    scroll.getRefWidget().setPosition(larg - item_s, 0);
    scroll.setWidth(item_s); scroll.setHeight(item_s*list_widget_nb);
    for (nWidget w : listwidgets) w.setSize(larg - item_s, item_s);
    return this;
  }
}

class nScroll {
  nGUI gui;
  nWidget up, down, back, curs;
  float larg = 60;
  float haut = 200;
  int entry_nb = 1;
  int entry_pos = 0;
  int entry_view = 1;
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  nScroll addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  nScroll removeEventChange(Runnable r)       { eventChangeRun.remove(r); return this; }
  
  nScroll setEntryNb(int v) { entry_nb = v; update_cursor(); return this; }
  nScroll setView(int v) { entry_view = v; update_cursor(); return this; }
  nScroll setPos(int v) { entry_pos = v; update_cursor(); return this; }
  
  nScroll setHeight(float h) { haut = h; back.setSY(h); update_cursor(); return this; }
  nScroll setWidth(float w) { 
    larg = w; back.setSX(w); up.setSize(w, w); down.setSize(w, w); curs.setSX(w);
    up.setOutlineWeight(w / 16).setFont(int(w/1.5));
    down.setOutlineWeight(w / 16).setFont(int(w/1.5));
    curs.setOutlineWeight(w / 16).setFont(int(w/1.5));
    update_cursor(); return this; }
  
  nWidget getRefWidget() { return back; }
  
  int layer = 0;
  
  nScroll setLayer(int l) {
    layer = l;
    up.setLayer(l);
    down.setLayer(l);
    curs.setLayer(l);
    back.setLayer(l);
    return this;
  }
  nScroll toLayerTop() {
    back.toLayerTop();
    up.toLayerTop();
    down.toLayerTop();
    curs.toLayerTop();
    return this;
  }
  nScroll clear() {
    up.clear();
    down.clear();
    curs.clear();
    back.clear();
    return this;
  }
  
  nScroll(nGUI _gui, float x, float y, float w, float h) {
    gui = _gui;
    larg = w; haut = h;
    back = new nWidget(gui, x, y, w, h)
        .setStandbyColor(color(70))
        .toLayerTop()
        ;
    up = new nWidget(gui, "^", int(w/1.5), 0, 0, w, w)
        .setParent(back)
        .toLayerTop()
        .setOutlineColor(color(100))
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .setTrigger()
        .addEventTrigger(new Runnable() { public void run() {
          if (entry_pos > 0) entry_pos--;
          update_cursor();
          runEvents(eventChangeRun);
        }})
        ;
    down = new nWidget(gui, "V", int(w/1.5), 0, 0, w, w)
        .setParent(back)
        .toLayerTop()
        .setOutlineColor(color(100))
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .alignDown()
        .setTrigger()
        .addEventTrigger(new Runnable() { public void run() {
          if (entry_pos < entry_nb - entry_view) entry_pos++;
          update_cursor();
          runEvents(eventChangeRun);
        }})
        ; 
    curs = new nWidget(gui, 0, 0, w, h-(w*2))
        .setParent(up)
        .toLayerTop()
        .stackDown()
        .setStandbyColor(color(100))
        ;
  }
  void update_cursor() {
    float h = haut - (larg*2);
    float d = h / entry_nb;
    curs.setSY(d*entry_view)
      .setPY(d*entry_pos);
  }
}
