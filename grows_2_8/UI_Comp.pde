








class nToolPanel extends nShelfPanel {
  
  ArrayList<Runnable> eventReducRun = new ArrayList<Runnable>();
  nToolPanel addEventReduc(Runnable r)       { eventReducRun.add(r); return this; }
  nToolPanel removeEventReduc(Runnable r)       { eventReducRun.remove(r); return this; }
  
  void reduc() {
    if      (hide && !right)  { panel.show(); reduc.setText("<"); } 
    else if (hide && right)   { panel.show(); reduc.setText(">"); } 
    else if (!hide && !right) { panel.hide(); reduc.show().setText(">"); }
    else                      { panel.hide(); reduc.show().setText("<"); }
    hide = !hide; 
    runEvents(eventReducRun); }
  nCtrlWidget reduc;
  boolean hide = false, right = true, top = true;
  nToolPanel(nGUI _g, float ref_size, float space_factor, boolean rgh, boolean tp) { 
    super(_g, ref_size, space_factor); 
    top = tp; right = rgh;
    reduc = addCtrlModel("Menu_Button_Small_Outline", "<")
      .setRunnable(new Runnable(this) { public void run() { reduc(); } } );
    reduc.setSize(ref_size/1.7, panel.getSY()).stackRight().show().setLabelColor(color(180));
    if (tp) { panel.setPY(gui.view.pos.y); reduc.alignUp(); }
    else    { panel.setPY(gui.view.pos.y + gui.view.size.y).stackUp(); reduc.alignDown(); }
    if (!rgh) panel.setPX(gui.view.pos.x).stackRight(); 
    else    { panel.setPX(gui.view.pos.x + gui.view.size.x).stackLeft(); reduc.setText(">").stackLeft(); }
  } 
  nToolPanel updateHeight() { 
    super.updateHeight(); if (reduc != null) reduc.setSY(panel.getLocalSY()); return this; }
}





class nTaskPanel extends nToolPanel {
  ArrayList<nWindowPanel> windowPanels = new ArrayList<nWindowPanel>();
  ArrayList<nWidget> window_buttons = new ArrayList<nWidget>();
  int used_spot = 0, max_spot = 4;
  int row = 1, col = 4;
  float adding_pos;
  nWidget getWindowPanelButton(nWindowPanel w) {
    if (used_spot < max_spot) {
      int i = 0;
      while(!window_buttons.get(i).getText().equals("")) i++;
      w.taskpanel_button = window_buttons.get(i);
      w.taskpanel_button.setTrigger().setText(w.grabber.getText()).setStandbyColor(color(70))
        //.addEventTrigger(new Runnable() { public void run() {} } )
        ;
      windowPanels.add(w);
      used_spot++;
      if (hide) reduc();
      return w.taskpanel_button;
    }
    return null;
  }
  
  nTaskPanel(nGUI _g, float ref_size, float space_factor) { 
    super(_g, ref_size, space_factor, true, false); 
    
    addGrid(col, row, 4, 1);
    for (int i = 0 ; i < col ; i++) for (int j = 0 ; j < row ; j++) {
      nWidget nw = getDrawer(i, j).addModel("Button-S3").setStandbyColor(color(60));
      window_buttons.add(nw);
    }
    //gui.addEventSetup(new Runnable() { public void run() { reduc(); } } );
  } 
  nTaskPanel updateHeight() { 
    super.updateHeight(); return this; }
  nTaskPanel updateWidth() { 
    super.updateWidth(); return this; }
}







class nWindowPanel extends nShelfPanel {
  nWindowPanel setPosition(float x, float y) {
    grabber.setPosition(x-task.panel.getX(), y-task.panel.getY()); return this;}
  //void reduc() { panel.hide(); }
  //void enlarg() { panel.show(); }
  void collapse() { 
    collapsed = true;
    grabber.hide(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(90));
    runEvents(eventCollapseRun);
  }
  void popUp() { 
    
    collapsed = false;
    if (task.hide) task.reduc();
    grabber.show(); 
    taskpanel_button.setStandbyColor(color(70)); 
    toLayerTop();
    runEvents(eventCollapseRun);
  }
  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
  nWindowPanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
  nWindowPanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
  ArrayList<Runnable> eventCollapseRun = new ArrayList<Runnable>();
  nWindowPanel addEventCollapse(Runnable r)       { eventCollapseRun.add(r); return this; }
  nWindowPanel removeEventCollapse(Runnable r)       { eventCollapseRun.remove(r); return this; }
  
  nTaskPanel task;
  nWidget grabber, closer, reduc, collapse, taskpanel_button;
  Runnable run_show;
  boolean collapsed = false;
  nWindowPanel(nGUI _g, nTaskPanel _task, String ti) { 
    super(_g, _task.ref_size, _task.space_factor); 
    task = _task;
    
    grabber = addModel("Head_Button_Small_Outline-SS4").setParent(task.panel).setText(ti)
      .setGrabbable()
      .setSX(ref_size*10.25)
      .show()
      .addEventGrab(new Runnable() { public void run() { toLayerTop(); } } )
      ;
    if (task.hide) grabber.setPosition(3*ref_size - task.panel.getX() + task.adding_pos*ref_size*1.5 + task.panel.getLocalSX(), 
                                       1*ref_size - task.panel.getY() + task.adding_pos*ref_size*1.5 + task.panel.getLocalSY());
    else grabber.setPosition(3*ref_size - task.panel.getX() + task.adding_pos*ref_size*1.5, 
                             1*ref_size - task.panel.getY() + task.adding_pos*ref_size*1.5);
    task.adding_pos++;
    if (task.adding_pos > 5) task.adding_pos -= 5.25;
    
    closer = addModel("Head_Button_Small_Outline-SS1").setText("X")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { 
        clear(); } } )
      .setParent(grabber)
      .alignRight()
      ;
    collapse = addModel("Head_Button_Small_Outline-SS1").setText("v")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { collapse(); } } )
      .setParent(closer)
      .stackLeft()
      ;
    panel.setParent(grabber).stackDown();
    addShelf()
      //.addDrawer(10, 0)
      ;
    taskpanel_button = task.getWindowPanelButton(this);
    run_show = new Runnable() { public void run() { 
      if (collapsed) popUp(); else collapse(); } };
    if (taskpanel_button != null) taskpanel_button.addEventTrigger(run_show);
  } 
  nWindowPanel clear() { 
    runEvents(eventCloseRun); 
    task.used_spot--;
    if (taskpanel_button != null) 
      taskpanel_button.removeEventTrigger(run_show).setText("").setPassif().setStandbyColor(color(60));
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); grabber.setSX(max(ref_size * 1.5, panel.getLocalSX())); 
    //log("wind grab "+grabber.getLocalSX()); 
    return this; }
}









class nFrontTab extends nShelfPanel {
  nFrontPanel getFront() { return front; }
  
  ArrayList<Runnable> eventOpen = new ArrayList<Runnable>();
  nFrontTab addEventOpen(Runnable r)       { eventOpen.add(r); return this; }
  
  nFrontTab show() {
    panel.show();
    front.grabber.setSX(panel.getLocalSX()); 
    return this; }
  
  nFrontTab hide() {
    panel.hide();
    
    return this; }
  
  nFrontPanel front;
  String name;
  nWidget tabbutton;
  nFrontTab(nFrontPanel _front, String ti) { 
    super(_front.gui, _front.ref_size, _front.space_factor); 
    front = _front;
    name = ti;
    fronttab = this;
    addShelf().addDrawer((front.grabber.getLocalSX() / front.ref_size) - 2*front.space_factor, 0);
  } 
  nFrontTab clear() { 
    tabbutton.clear();
    eventOpen.clear();
    super.clear(); return this; }
  nFrontTab updateHeight() { 
    
    super.updateHeight(); return this; }
  nFrontTab updateWidth() { 
    super.updateWidth(); 
    front.grabber.setSX(max_width);
    panel.setSX(max_width); front.updateWidth(); 
    //logln("tab "+name+" : front.grab " + front.grabber.getLocalSX()); 
    
    
    float new_width = front.grabber.getLocalSX() / (front.tab_widgets.size());
    for (nWidget w : front.tab_widgets) w.setSX(new_width); 
    float moy_leng = 0;
    for (nWidget w : front.tab_widgets) moy_leng += w.getText().length();
    moy_leng /= front.tab_widgets.size();
    for (nWidget w : front.tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    
    
    
    return this; }
}






class nFrontPanel extends nWindowPanel {
  nFrontPanel setNonClosable() { closer.setText("").setBackground(); return this; }
  nFrontTab getTab(int n) { return tabs.get(n); }
  ArrayList<nFrontTab> tabs = new ArrayList<nFrontTab>();
  ArrayList<nWidget> tab_widgets = new ArrayList<nWidget>();
  nFrontTab current_tab;
  nFrontTab addTab(String n) {
    nFrontTab tab = new nFrontTab(this, n);
    tabs.add(tab);
    tab.panel.setParent(panel)
      .stackDown()
      ;
    float new_width = grabber.getLocalSX() / (tab_widgets.size() + 1);
    nWidget tabbutton = addModel("Button-SS3");
    tabbutton.setSwitch().setText(n)
      .setSX(new_width)
      .setFont(int(ref_size/2))
      .addEventSwitchOn(new Runnable(tab) { public void run() {
        for (nFrontTab t : tabs) t.hide();
        current_tab = ((nFrontTab)builder);
        current_tab.show();
        runEvents(current_tab.eventOpen);
      } } )
      ;
    for (nWidget w : tab_widgets) { 
      w.setSX(new_width); 
      tabbutton.addExclude(w); w.addExclude(tabbutton); }
    if (tab_widgets.size() > 0) tabbutton.setParent(tab_widgets.get(tab_widgets.size()-1)).stackRight();
    else tabbutton.setParent(grabber).stackDown();
    tab_widgets.add(tabbutton);
    tab.tabbutton = tabbutton;
    panel.setParent(tab_widgets.get(0));
    
    tabbutton.setOn();
    
    float moy_leng = 0;
    for (nWidget w : tab_widgets) moy_leng += w.getText().length();
    moy_leng /= tab_widgets.size();
    for (nWidget w : tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    
    return tab;
  }
  
  nFrontPanel(nGUI _g, nTaskPanel _task, String _name) { 
    super(_g, _task, _name); 
    panel.setSY(0).setOutline(false);
    gui.addEventSetup(new Runnable() { public void run() {
      if (tab_widgets.size() > 0) tab_widgets.get(0).setOn();
    } });
  } 
  void collapse() { 
    super.collapse(); 
  }
  void popUp() { 
    super.popUp(); 
    for (nFrontTab t : tabs) t.hide();
    if (current_tab != null) {
      current_tab.show();
      runEvents(current_tab.eventOpen); }
  }
  nFrontPanel toLayerTop() { super.toLayerTop(); for (nFrontTab d : tabs) d.toLayerTop(); return this; }
  nFrontPanel clear() { 
    for (nFrontTab d : tabs) d.clear();
    super.clear(); return this; }
  nFrontPanel updateHeight() { 
    super.updateHeight(); return this; }
  nFrontPanel updateWidth() { 
    super.updateWidth(); 
    if (current_tab != null && current_tab.panel.getLocalSX() != grabber.getLocalSX()) 
    grabber.setSX(current_tab.panel.getLocalSX());
    
    //is tabs hhave different width verify tabs width follow correctly
    if (grabber != null && tab_widgets != null) {
      float new_width = grabber.getLocalSX() / (tab_widgets.size());
      for (nWidget w : tab_widgets) w.setSX(new_width); 
      float moy_leng = 0;
      for (nWidget w : tab_widgets) moy_leng += w.getText().length();
      moy_leng /= tab_widgets.size();
      for (nWidget w : tab_widgets) w.setSX(w.getLocalSX() * w.getText().length() / moy_leng);
    }
    //current_tab.updateWidth(); 
    //logln("frontpanel " + panel.getLocalSX()); 
    
    return this; }
}
