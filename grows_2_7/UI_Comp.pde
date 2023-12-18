



// todo --------------------------
/*

nouveau forma macro :
  plus de custom, un type macro data qui fait tout
  macro back : réel 
  sheet back se deplois quand open
  child macro au dessus du hardback can snap to visible spot
    connection spot show only 1 co type and the label
    center spot show only widgets and label
    
  quand une sheet est ouverte sont soft back est trensparent mais le soft back de sont parent non
  selement une top sheet ouverte a la fois
  cant be grabbed when open
  open by double click on grab
    
  no sheet co, stick to a free place in the hard back to make a co 
  package info on top of connections
  
  no tick anywhere
  
  output priority
  
  highlight connectable in when creating link
  
MacroPanel
  grabber center carre no text
  utilise un spot pour menu d'icone 
    open sheet : expend soft back / close sheet
    open spot : a selected child macro can be put on an empty spot by clicking
    switch spot : clicking a spot circle child macro widget
    clear spot
  text down left du softback with outline field > description?
  hard_back 
  soft_back bottomlayer follow hardback des child
    each child event drag
  
  can add in spot
    label
    field for num str vec ...
    trig
    switch
    multi small switch
    ext input/output
    all of this from ones of a child
  
  
  

*/

void mySetup_UI_Comp(nGUI gui, float ref_size) {
  new nMacroPanel(gui, ref_size, 0.125)
    .makeSpot(2, 2)
    .addWidget(0, 0, 0)
      .getMacroPanel()
    .addWidget(0, 1, 2)
      .getMacroPanel()
    .addWidget(1, 0, 0)
      .getMacroPanel()
    .addWidget(1, 1, 1)
    ;
  
}

class nMacroWidget extends nWidget {
  nMacroPanel getMacroPanel() { return macro_panel; }
  nMacroPanel macro_panel;
  nWidget zone,connect, spot_back;
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float ref_size; int position;
  nMacroWidget(nMacroPanel mp, int c, int r, int p) { super(mp.gui); 
    macro_panel = mp;
    ref_size = mp.ref_size; 
    position = p;
    
    int id = c * mp.getShelf(0).drawers.size() + r;
    spot_back = mp.spots_back.get(id);
    
    if (p == 0) {
      zone = mp.getShelf(c).getDrawer(r)
        .addModel("MC_Widget_Solo", "--  --");
      widgets.add(zone);
      
      connect = mp.getShelf(c).getDrawer(r).addModel("MC_Connect")
        .setTrigger();
      if (c==0) connect.setPosition(-ref_size*8/16, ref_size*5/16);
      if (c==1) connect.setPosition(ref_size*(2.0+(10.0/16.0)), ref_size*5/16);
      widgets.add(connect);
    } else if (p == 1) {
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Quad1", "--");
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Quad2", "--");
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Quad3", "--");
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Quad4", "--");
      
      connect = mp.getShelf(c).getDrawer(r).addModel("MC_Connect")
        .setTrigger();
      if (c==0) connect.setPosition(-ref_size*8/16, ref_size*5/16);
      if (c==1) connect.setPosition(ref_size*(2.0+(10.0/16.0)), ref_size*5/16);
      
    } else if (p == 2) {
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Duo1", "--");
      mp.getShelf(c).getDrawer(r).addModel("MC_Widget_Duo2", "--");
      
      connect = mp.getShelf(c).getDrawer(r).addModel("MC_Connect")
        .setTrigger();
      if (c==0) connect.setPosition(-ref_size*8/16, ref_size*5/16);
      if (c==1) connect.setPosition(ref_size*(2.0+(10.0/16.0)), ref_size*5/16);
      
    }
    macro_panel.grabber.toLayerTop()
      ;
  }
  nMacroWidget setLayer(int l) { super.setLayer(l); for (nWidget w : widgets) w.setLayer(l); return this; }
  nMacroWidget toLayerTop() { super.toLayerTop(); for (nWidget w : widgets) w.toLayerTop(); return this; }
  void clear() { for (nWidget w : widgets) w.clear(); super.clear(); }
}

class nMacroPanel extends nShelfPanel {
  
  void makeMenu(int c, int r) {
    new nMacroWidget(this, c, r, 1);
  }
  
  void vrapAround(nMacroPanel mp) {
    
  }
  
  nMacroWidget addWidget(int c, int r, int p) {
    return new nMacroWidget(this, c, r, p);
  }
  
  nMacroPanel makeSpot(int c, int r) {
    addGrid(c, r, 3, 1.5);
    for (int i = 0 ; i < c ; i++) for (int j = 0 ; j < r ; j++) {
      nWidget w = getDrawer(i,j).addModel("MC_Hard_Back_Spot");
      spots_back.add(w);
    }
    panel
      .setPosition(grabber.getLocalSX()/2-panel.getLocalSX()/2, 
                   grabber.getLocalSY()/2-panel.getLocalSY()/2);
    grabber.toLayerTop();
    return this;
  }
  ArrayList<nWidget> spots_back = new ArrayList<nWidget>();
  nWidget grabber, soft_back, title_field;
  nMacroPanel(nGUI _g, float rfs, float spf) { 
    super(_g, rfs, spf); 
    grabber = addModel("MC_Grabber")
      .setGrabbable()
      .clearParent()
      .toLayerTop()
      ;
    grabber.setPosition(-grabber.getLocalSX()/2, -grabber.getLocalSY()/2)
      ;
    soft_back = addModel("MC_Soft_Back")
      .clearParent()
      .setPassif()
      //.hide()
      ;
    soft_back.setParent(grabber).setSize(ref_size*15, ref_size*11)
      .setPosition(grabber.getLocalSX()/2-soft_back.getLocalSX()/2, 
                   grabber.getLocalSY()/2-soft_back.getLocalSY()/2);
      
    panel
      .setLook(gui.theme.getLook("MC_Hard_Back"))
      .setParent(grabber)
      .setPassif()
      .toLayerTop()
      .setPosition(grabber.getLocalSX()/2-panel.getLocalSX()/2, 
                   grabber.getLocalSY()/2-panel.getLocalSY()/2);
                   
   title_field = addModel("MC_Label_Back", "macro")
     .stackDown()
     .toLayerTop()
     .setSize(ref_size*4, ref_size*0.75)
      ;
    
  } 
  nMacroPanel clear() { 
    super.clear(); return this; }
  nMacroPanel updateHeight() { 
    super.updateHeight(); 
    return this; }
  nMacroPanel updateWidth() { 
    super.updateWidth(); 
    //grabber.setSX(max(ref_size * 1.5, panel.getLocalSX())); 
    //log("wind grab "+grabber.getLocalSX()); 
    return this; }
}









class nToolPanel extends nShelfPanel {
  void reduc() {
    if      (hide && !right)  { panel.show(); reduc.setText("<"); } 
    else if (hide && right)   { panel.show(); reduc.setText(">"); } 
    else if (!hide && !right) { panel.hide(); reduc.show().setText(">"); }
    else                      { panel.hide(); reduc.show().setText("<"); }
    hide = !hide; }
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
  int used_spot = 0, max_spot = 6;
  int row = 3, col = 2;
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
  //void enlarg() { panel.show();  }
  void collapse() { 
    collapsed = true;
    grabber.hide(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(90)); }
  void popUp() { 
    collapsed = false;
    if (task.hide) task.reduc();
    grabber.show(); taskpanel_button.setStandbyColor(color(70)); 
  }
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
      .setPosition(3*ref_size-task.panel.getX() + task.adding_pos*ref_size*1.5, 
                   1*ref_size-task.panel.getY() + task.adding_pos*ref_size*1.5)
      .show()
      //.addEventDrag(new Runnable() { public void run() { runEvents(eventDragRun); } } )
      ;
    
    task.adding_pos++;
    if (task.adding_pos > 5) task.adding_pos -= 5.25;
    
    closer = addModel("Head_Button_Small_Outline-SS1").setText("X")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { 
        //runEvents(eventCloseRun); 
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
    //reduc = addModel("Head_Button_Small_Outline-SS1").setText("-")
    //  .setTrigger()
    //  .addEventTrigger(new Runnable() { public void run() {
    //    if (panel.isHided()) enlarg(); else reduc(); } } )
    //  .setParent(collapse)
    //  .stackLeft()
    //  ;
    panel.setParent(grabber).stackDown();
    addShelf().addDrawer(10, 0);
    taskpanel_button = task.getWindowPanelButton(this);
    run_show = new Runnable() { public void run() { 
      if (collapsed) popUp(); else collapse(); } };
    if (taskpanel_button != null) taskpanel_button.addEventTrigger(run_show);
  } 
  nWindowPanel clear() { 
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
  //void reduc() { 
  //  super.reduc(); 
  //  if (tab_widgets.size() > 0) tab_widgets.get(0).hide(); }
  //void enlarg() { 
  //  super.enlarg(); 
  //  if (tab_widgets.size() > 0) tab_widgets.get(0).show();
  //  for (nFrontTab t : tabs) t.hide();
  //  if (current_tab != null) {
  //    current_tab.show();
  //    runEvents(current_tab.eventOpen); } }
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
  nFrontPanel clear() { 
    
    super.clear(); return this; }
  nFrontPanel updateHeight() { 
    super.updateHeight(); return this; }
  nFrontPanel updateWidth() { 
    super.updateWidth(); 
    if (current_tab != null && current_tab.panel.getLocalSX() != grabber.getLocalSX()) 
    grabber.setSX(current_tab.panel.getLocalSX());
    //panel.setSX(grabber.getLocalSX());
    //current_tab.updateWidth(); 
    //logln("frontpanel " + panel.getLocalSX()); 
    
    return this; }
}
