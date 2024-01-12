/*

  Complex Widget Objects
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
    Info
      can appear on top of the mouse with text
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









class nColorPanel extends nWindowPanel {
  //nColorPanel setOkEvent_Builder(Runnable r) { ok_run = r; ok_run.builder = this; return this; }
  nWidget color_widget, red_widget, gre_widget, blu_widget;
  float red, gre, blu;
  //Runnable ok_run;
  sCol cval;
  nColorPanel(nGUI _g, nTaskPanel _task, sCol _cv) { 
    super(_g, _task, "color"); 
    cval = _cv;
    red = cval.getred(); gre = cval.getgreen(); blu = cval.getblue(); 
    getShelf()
      .addDrawer(10.25, 1)
        .addWidget(new nSlide(gui, ref_size*7.375, ref_size).setValue(cval.getred() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            red = v*255; update(); red_widget.setText(trimStringFloat(red)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25, 1)
        .addWidget(new nSlide(gui, ref_size*7.375, ref_size).setValue(cval.getgreen() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            gre = v*255; update(); gre_widget.setText(trimStringFloat(gre)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25, 1)
        .addWidget(new nSlide(gui, ref_size*7.375, ref_size).setValue(cval.getblue() / 255)
          .addEventSlide(new Runnable() { public void run(float v) { 
            blu = v*255; update(); blu_widget.setText(trimStringFloat(blu)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(10.25, 1)
        .addCtrlModel("Button-S2-P3", "OK")
          .setRunnable(new Runnable() { public void run() { clear(); } }).getDrawer()
          ;
        
    color_widget = getDrawer(0,3).addModel("Label-S3-P1")
          .setStandbyColor(color(red, gre, blu));
    red_widget = getDrawer(0,0)
        .addModel("Label_Small_Outline-S2", str(red)).setPX(7.5*ref_size);
    gre_widget = getDrawer(0,1)
        .addModel("Label_Small_Outline-S2", str(gre)).setPX(7.5*ref_size);
    blu_widget = getDrawer(0,2)
        .addModel("Label_Small_Outline-S2", str(blu)).setPX(7.5*ref_size);
    
    if (cval == null) clear();
  } 
  void update() { 
    if (cval != null) {
      color_widget.setStandbyColor(color(red, gre, blu)); 
      cval.set(color(red, gre, blu)); }
    else clear(); }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}










class nCursor extends nWidget {
  float x() { return pval.x(); }
  float y() { return pval.y(); }
  PVector dir() { if (dval.get().mag() > ref_size) return new PVector(dval.x(), dval.y()).setMag(1); 
                  else return new PVector(1, 0).rotate(random(2*PI)); }
  PVector pos() { return new PVector(pval.x(), pval.y()); }
  nGUI gui;
  float ref_size;
  sVec pval, dval;
  sBoo show;
  String ref;
  nWidget refwidget, thiswidget, pointwidget;
  nCursor(nGUI _g, Macro_Sheet sheet, String r, String s) {
    super(_g);
    new nConstructor(_g.theme, _g.theme.ref_size);
    thiswidget = this;
    gui = _g; ref_size = _g.theme.ref_size; ref = r;
    copy(gui.theme.getModel("Cursor"));
    refwidget = gui.theme.newWidget(gui, "ref").setParent(this).setPosition(ref_size, ref_size);
    setSize(ref_size*2, ref_size*2);
    setPosition(-ref_size, -ref_size);
    setText(r).setFont(int(ref_size/2.0)).setTextAlignment(LEFT, CENTER);
    setGrabbable();
    addEventDrag(new Runnable() {public void run() {pval.set(refwidget.getX(), refwidget.getY());}});
    pval = sheet.newVec(s+"_cursor_position", s+"_pos");
    pval.addEventChange(new Runnable(pval) {public void run() {
      sVec v = ((sVec)builder);
      thiswidget.setPosition(v.x()-ref_size, v.y()-ref_size);}});
    
    show = sheet.newBoo(false, s+"_cursor_show", s+"_show"); //!!!!! is hided by default
   
    pointwidget = gui.theme.newWidget(gui, "Pointer").setPosition(-ref_size/4, -ref_size/4).setSize(ref_size/2, ref_size/2);
    pointwidget.setParent(refwidget).setGrabbable().setConstrainDistance(ref_size*2).toLayerTop();
    dval = sheet.newVec(s+"_cursor_pointer", s+"_dir");
    dval.addEventChange(new Runnable(dval) {public void run() {
      sVec v = ((sVec)builder);
      if (v.get().mag() > ref_size*2) v.set(v.get().setMag(ref_size*2));
      pointwidget.setPosition(v.x()-ref_size/4, v.y()-ref_size/4); }});
    pointwidget.addEventDrag(new Runnable() {public void run() {
      dval.set(pointwidget.getLocalX() + ref_size/4, pointwidget.getLocalY() + ref_size/4);}});
    pointwidget.addEventLiberate(new Runnable() {public void run() {
      if (dval.get().mag() < ref_size) dval.set(0, 0); }});
    
    if (show.get()) { thiswidget.show(); pointwidget.show(); } else { thiswidget.hide(); pointwidget.hide(); }
    show.addEventChange(new Runnable(show) {public void run() {
    sBoo v = ((sBoo)builder);
      if (v.get()) { thiswidget.show(); pointwidget.show(); } else { thiswidget.hide(); pointwidget.hide(); } }});
  }
  void clear() { 
    refwidget.clear(); pointwidget.clear(); super.clear(); 
    show.clear(); pval.clear(); dval.clear(); }
}





class nDropMenu extends nBuilder {
  
  nDropMenu drop(nWidget op, float x, float y) { 
    opener = op; 
    ref.setPosition(x, y).show(); 
    for (nWidget w : menu_widgets) w.toLayerTop();
    toLayerTop();
    return this; }
  nDropMenu drop(nGUI g) { 
    float p_x = g.mouseVector.x - larg/2;
    float p_y = g.mouseVector.y;
    if (!down) p_y += haut/2; else p_y -= haut/4; 
    float total_haut = haut*menu_widgets.size();
    
    if (p_x + larg > g.view.pos.x + g.view.size.x) p_x = g.view.pos.x + g.view.size.x - larg;
    if (p_x < g.view.pos.x) p_x = g.view.pos.x;
    if (down && p_y + total_haut > g.view.pos.y + g.view.size.y) 
      p_y = g.view.pos.y + g.view.size.y - total_haut;
    if (!down && p_y - total_haut < g.view.pos.y) p_y += g.view.pos.y - (p_y - total_haut);
    
    ref.setPosition(p_x, p_y).show(); 
    for (nWidget w : menu_widgets) w.toLayerTop();
    toLayerTop(); return this; }
  nDropMenu close() { 
    ref.hide();
    return this; }
  nDropMenu clear() { super.clear(); events.clear(); return this; }
  nWidget ref, opener;
  ArrayList<nWidget> menu_widgets = new ArrayList<nWidget>();
  ArrayList<Runnable> events = new ArrayList<Runnable>();
  int layer = 20;  float haut, larg;  boolean down, ephemere = false;
  
  nDropMenu(nGUI _gui, float ref_size, float width_factor, boolean _down, boolean _ephemere) {
    super(_gui, ref_size);
    haut = ref_size; larg = haut*width_factor; down = _down; ephemere = _ephemere;
    ref = addModel("ref").stackRight()
      .addEventFrame(new Runnable() { public void run() { 
        boolean t = false;
        for (nWidget w : menu_widgets) t = t || w.isHovered();
        if (opener != null) t = t || opener.isHovered();
        if ((gui.in.getClick("MouseLeft") || ephemere) && !t) close();
      } });
    if (!down) ref.stackUp(); 
  }
  void click() {
    int i = 0;
    for (nWidget w : menu_widgets) {
      if (w.isOn()) { w.setOff(); break; }
      i++; }
    events.get(i).run();
    ref.hide();
  }
  nWidget addEntry(String l, Runnable r) {
    nWidget ne = new nWidget(gui, l, int(haut/1.5), 0, 0, larg, haut)
      .setSwitch() 
      .setLayer(layer)
      .setTextAlignment(LEFT, CENTER)
      .setHoverablePhantomSpace(ref_size / 4)
      .addEventSwitchOn(new Runnable() { public void run() { click(); }}) 
      ;
     if (!down) ne.stackUp(); else ne.stackDown();
    if (menu_widgets.size() > 0) ne.setParent(menu_widgets.get(menu_widgets.size()-1)); 
    else ne.setParent(ref);
    menu_widgets.add(ne);
    events.add(r);
    return ne;
  }
  nCtrlWidget addEntry(String l) {
    nCtrlWidget ne = new nCtrlWidget(gui);
    ne.setText(l)
      .setFont(int(haut/1.5))
      .setSize(larg, haut)
      .setHoverablePhantomSpace(ref_size / 4)
      //.addEventSwitchOn(new Runnable() { public void run() { click(); }}) 
      ;
    if (!down) ne.stackUp(); else ne.stackDown();
    if (menu_widgets.size() > 0) ne.setParent(menu_widgets.get(menu_widgets.size()-1)); 
    else ne.setParent(ref);
    menu_widgets.add(ne);
    events.add(new Runnable() { public void run() { }});
    return ne;
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
  //  A AMELIORER
  //nInfo on cam react to object pos in cam space not on object pos on screen
  void showText(String t) { 
    float s = t.length()*(ref.getLocalSX() / 1.2);
    float p = -t.length()*(ref.getLocalSX() / 1.2) / 2;
    if (ref.getLocalX() + p + s > gui.view.pos.x + gui.view.size.x) 
      p -= ref.getLocalX() + p + s - (gui.view.pos.x + gui.view.size.x);
    if (ref.getLocalX() + p < gui.view.pos.x) p += gui.view.pos.x - (ref.getLocalX() + p);
    if (invert) { ref.stackDown(); label.stackDown().setPY(0); }
    else        { ref.stackUp(); label.stackUp().setPY(0); }
    label.setPX(p).setSX(s);
    label.setText(t); ref.show(); count = 3; toLayerTop();  }
  nInfo setLayer(int l) { label.setLayer(l); ref.setLayer(l); return this; }
  nInfo toLayerTop() { label.toLayerTop(); ref.toLayerTop(); return this; }
  nInfo(nGUI _g, float f) {
    gui = _g;
    ref = new nWidget(gui, 0, 0, f/2, f/2).setPassif()
      .setDrawable(new Drawable(_g.drawing_pile) { public void drawing() {
        fill(ref.look.standbyColor);
        noStroke();
        if (invert) triangle(ref.getX(), ref.getY(), 
                 ref.getX() - ref.getSX()/2, ref.getY() + ref.getSY(), 
                 ref.getX() + ref.getSX()/2, ref.getY() + ref.getSY() );
        else triangle(ref.getX(), ref.getY() + ref.getSY(), 
                 ref.getX() - ref.getSX()/2, ref.getY(), 
                 ref.getX() + ref.getSX()/2, ref.getY() );
      } } )
      .addEventFrame(new Runnable() { public void run() {
        if (count > 0) {
          count--; if (count == 0) ref.hide();
          ref.setPosition(gui.mouseVector.x, gui.mouseVector.y);
          if (gui.mouseVector.y < ref.getLocalSY()*3 && !invert) invert = true;
          else if (gui.mouseVector.y > ref.getLocalSY()*6 && invert) invert = false; 
        }
      } } );
    ref.stackDown();
    label = new nWidget(gui, "", int(f*0.8), 0, -f, 0, f*1).setPassif()
      .setParent(ref)
      .stackDown()
      ;
    ref.hide();
  }
  nWidget ref,label;
  nGUI gui;
  int count = 0; boolean invert = true;
}









class nExplorer extends nDrawer {
  boolean access_child = true;
  nExplorer setChildAccess(boolean b) { access_child = b; return this; }
  ArrayList<String> explorer_entry;
  ArrayList<sValueBloc> explorer_blocs;
  ArrayList<sValue> explorer_values;
  sValueBloc explored_bloc, selected_bloc, starting_bloc;
  sValue selected_value;
  int selected_bloc_index = 0, selected_value_index = 0;
  nList explorer_list;
  
  nExplorer setStrtBloc(sValueBloc sb) { if (sb != explored_bloc) { starting_bloc = sb; explored_bloc = sb; update(); } return this; }
  nExplorer setBloc(sValueBloc sb) { if (sb != explored_bloc) { explored_bloc = sb; update(); } return this; }
  
  nShelf shelf;
  nWidget bloc_info, val_info;
  
  nDrawer setLayer(int l) { super.setLayer(l); shelf.setLayer(l); return this; }
  nDrawer toLayerTop() { super.toLayerTop(); shelf.toLayerTop(); return this; }
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  nExplorer addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  
  nExplorer addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  nExplorer(nShelf s) {
    super(s, s.ref_size*10, s.ref_size*9);
    explorer_entry = new ArrayList<String>();
    explorer_blocs = new ArrayList<sValueBloc>();
    explorer_values = new ArrayList<sValue>();
    shelf = new nShelf(s.shelfPanel, s.space_factor);
    shelf.addSeparator(0.25);
    shelf.ref.setParent(ref);
    explorer_list = shelf.addList(5, 10, 1).setTextAlign(LEFT)
      .addEventChange_Builder(new Runnable() { 
      public void run() {
        int ind = ((nList)builder).last_choice_index;
        if (ind == 0 && explored_bloc != null && explored_bloc != starting_bloc) {
          explored_bloc = explored_bloc.parent;
          selected_bloc = null;
          selected_value = null;
          update_list();
          runEvents(eventChangeRun);
          
        } else if (ind != 0 && ind < explorer_blocs.size()+1) {
          if (selected_bloc == explorer_blocs.get(ind-1) && access_child) {
            explored_bloc = selected_bloc;
            selected_bloc = null;
            selected_value = null;
            update_list();
            runEvents(eventChangeRun);
          } else {
            selected_bloc = explorer_blocs.get(ind-1);
            selected_value = null;
            update_info();
            runEvents(eventChangeRun);
          }
        } else if (ind != 0 && ind - explorer_blocs.size() < explorer_values.size()+1) {
          selected_bloc = null;
          selected_value = explorer_values.get(ind-1 - explorer_blocs.size());
          
          update_info();
          runEvents(eventChangeRun);
        } 
      } } )
      ;
    
    bloc_info = shelf.addSeparator(0.25)
      .addDrawer(1.4)
        .addModel("Label-S4", "Selected Bloc :").setTextAlignment(LEFT, TOP);
    
    val_info = shelf.addSeparator(0.5)
      .addDrawer(1.4)
        .addModel("Label-S4", "Selected Value :").setTextAlignment(LEFT, TOP);
    
    update_list();
    
  }
  void selectEntry(String r) {
    int i = 0;
    for (Map.Entry me : explored_bloc.blocs.entrySet()) {
      if (me.getKey().equals(r)) break;
      i++; }
    if (i < explorer_list.listwidgets.size()) explorer_list.listwidgets.get(i).setOn();
  }
  void update_info() {
    if (selected_bloc != null) 
      bloc_info.setText("Selected Bloc :\n " + selected_bloc.type + " " + selected_bloc.ref);
    if (selected_value != null) 
      val_info.setText("Selected Value : " + selected_value.type + " " + selected_value.ref
                      +"\n = " + selected_value.getString() );
  }
  
  void update() {
    selected_bloc = null;
    selected_value = null;
    update_list();
  }
  void update_list() {
    explorer_entry.clear();
    explorer_blocs.clear();
    explorer_values.clear();
    if (explored_bloc != null) {
      //println(); println(explored_bloc.getHierarchy(false));
      if (explored_bloc != starting_bloc) explorer_entry.add("..");
      else explorer_entry.add("");
      for (Map.Entry me : explored_bloc.blocs.entrySet()) {
        sValueBloc cvb = (sValueBloc)me.getValue();
        explorer_blocs.add(cvb); 
        explorer_entry.add(cvb.base_ref + " " + cvb.use);
        //explorer_entry.add((String)me.getKey());
      }
      for (Map.Entry me : explored_bloc.values.entrySet()) {
        explorer_values.add((sValue)me.getValue()); 
        explorer_entry.add("   - "+(String)me.getKey());
      }
    }
    explorer_list.setEntrys(explorer_entry);
    update_info();
  }
  
}










class nList extends nDrawer {
  
  //nPanelDrawer panel_drawer = null;
  //nList setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  //nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  //nGUI gui;
  ArrayList<nWidget> listwidgets = new ArrayList<nWidget>();
  ArrayList<String> entrys = new ArrayList<String>();
  nWidget back, last_choice_widget;
  nScroll scroll;
  float item_s;
  float larg;
  int list_widget_nb = 5;
  int entry_pos = 0;
  boolean event_active = true;
  int last_choice_index = -1;
  String last_choice_text = null;
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  nList addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  
  nList addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  nWidget getRefWidget() { return back; }
  
  int layer = 0;
  
  nList setLayer(int l) {
    super.setLayer(l); 
    layer = l;
    scroll.setLayer(l);
    back.setLayer(l);
    for (nWidget w : listwidgets) w.setLayer(l);
    return this;
  }
  nList toLayerTop() {
    super.toLayerTop();
    back.toLayerTop();
    scroll.toLayerTop();
    for (nWidget w : listwidgets) w.toLayerTop();
    return this;
  }
  nList clear() {
    super.clear();
    scroll.clear();
    for (nWidget w : listwidgets) w.clear();
    back.clear();
    return this;
  }
  int align = CENTER;
  nList setTextAlign(int a) { align = a; setListLength(list_widget_nb); return this; }
  nList(nShelf _sh, int _ent_nb, float _rs, float _lf, float _hf) {
    super(_sh, _rs*_lf, _rs*_hf*_ent_nb);
    list_widget_nb = _ent_nb;
    back = new nWidget(gui, 0, 0);
    back.setParent(ref)
      .addEventFrame(new Runnable() { public void run() {
        if (!back.isHided()) {
          for (nWidget w : listwidgets) { 
            if (w.isHovered() && gui.in.mouseWheelUp) {
              scroll.go_down();
            }
            if (w.isHovered() && gui.in.mouseWheelDown) {
              scroll.go_up();
            }
          }
        }
      }});
    item_s = ref_size*_hf; larg = ref_size*_lf;
    
    scroll = new nScroll(gui, larg - item_s, 0, item_s, item_s*list_widget_nb);
    scroll.getRefWidget().setParent(back);
    scroll.setView(list_widget_nb)
      .addEventChange(new Runnable() { public void run() {
        //int mov = scroll.entry_pos - entry_pos;
        //if (mov != 0 && last_choice_index >= 0 && last_choice_index < listwidgets.size()) 
        //  listwidgets.get(last_choice_index).setOff();
        entry_pos = scroll.entry_pos;
        //last_choice_index -= mov;
        //if (mov != 0 && last_choice_index >= 0 && last_choice_index < listwidgets.size()) { event_active = false;
        //  listwidgets.get(last_choice_index).setOn(); event_active = true; }
        
        update_list();
      }});
    setListLength(_ent_nb);
    
  }
  
  void click() {
    if (event_active) {
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
      last_choice_widget = listwidgets.get(i);
      runEvents(eventChangeRun);
    }
  }
  void unselect() { last_choice_index = -1; last_choice_text = ""; update_list(); }
  void update_list() {
    last_choice_widget = null;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget w = listwidgets.get(i);
      if (i + entry_pos == last_choice_index) { 
        w.setLook(gui.theme, "List_Entry_Selected"); 
        last_choice_widget = w; }
      else w.setLook(gui.theme, "List_Entry");
      if (i + entry_pos < entrys.size()) w.setText(entrys.get(i + entry_pos)); else w.setText("");
    }
  }
  nList setEntrys(ArrayList<String> l) {
  //nList setEntrys(String[] l) {
    entrys.clear();
    for (String s : l) entrys.add(copy(s));
    scroll.setPos(0);
    scroll.setEntryNb(l.size());
    //scroll.setEntryNb(l.length);

    scroll.setView(list_widget_nb);
    entry_pos = 0; 
    for (int i = 0 ; i < list_widget_nb ; i++) 
      if (i < entrys.size()) listwidgets.get(i).setSwitch();
      else listwidgets.get(i).setBackground();
    unselect();
    return this;
  }
  nList setListLength(int l) {
    for (int i = 0 ; i < listwidgets.size() ; i++) listwidgets.get(i).clear();
    listwidgets.clear();
    list_widget_nb = l;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = gui.theme.newWidget(gui, "List_Entry").setSize(larg - item_s, item_s)
        .stackDown()
        .setTextAlignment(align, CENTER)
        .addEventSwitchOn_Builder(new Runnable() { public void run() {
          if (last_choice_widget != null && last_choice_widget != ((nWidget)builder)) 
            last_choice_widget.setLook(gui.theme, "List_Entry");
          ((nWidget)builder).setLook(gui.theme, "List_Entry_Selected");
          click();
        }})
        ;
      if (listwidgets.size() > 0) ne.setParent(listwidgets.get(listwidgets.size()-1)); else ne.setParent(back);
      listwidgets.add(ne);
    }
    for (nWidget w : listwidgets) w.toLayerTop();
    
    for (nWidget w : listwidgets) 
      for (nWidget w2 : listwidgets)
        if (w != w2) ;
          //w.addExclude(w2);
    
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
        .setLabelColor(color(180))
        .setTextAlignment(CENTER, BOTTOM)
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .setTrigger()
        .addEventFrame(new Runnable() { public void run() {
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelUp) {
            go_down();
          }
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelDown) {
            go_up();
          }
        }})
        .addEventTrigger(new Runnable() { public void run() {
          go_up();
        }})
        ;
    down = new nWidget(gui, "v", int(w/2.0), 0, 0, w, w)
        .setParent(back)
        .toLayerTop()
        .setOutlineColor(color(100))
        .setLabelColor(color(180))
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .alignDown()
        .setTrigger()
        .addEventTrigger(new Runnable() { public void run() {
          go_down();
        }})
        ; 
    curs = new nWidget(gui, 0, 0, w, h-(w*2))
        .setParent(up)
        .toLayerTop()
        .stackDown()
        .setStandbyColor(color(100))
        ;
  }
  void go_up() {
    if (entry_pos > 0) entry_pos--;
    update_cursor();
    runEvents(eventChangeRun);
  }
  void go_down() {
    if (entry_pos < entry_nb - entry_view) entry_pos++;
    update_cursor();
    runEvents(eventChangeRun);
  }
  void update_cursor() {
    if (entry_view <= entry_nb) {
      float h = haut - (larg*2);
      float d = h / entry_nb;
      curs.setSY(d*entry_view)
        .setPY(d*entry_pos);
    } else {
      curs.setSY(haut - (larg*2))
        .setPY(0);
    }
  }
}






class nSelectZone {
  Hoverable_pile pile;
  Drawable drawer;
  Rect select_zone = new Rect();
  boolean emptyClick = false;
  int clickDelay = 0;
  boolean ON = true;
  
  nSelectZone addEventEndSelect(Runnable r)  { eventEndSelect.add(r); return this; }
  nSelectZone removeEventEndSelect(Runnable r)       { eventEndSelect.remove(r); return this; }
  ArrayList<Runnable> eventEndSelect = new ArrayList<Runnable>();
  nSelectZone addEventStartSelect(Runnable r)  { eventStartSelect.add(r); return this; }
  nSelectZone removeEventStartSelect(Runnable r)       { eventStartSelect.remove(r); return this; }
  ArrayList<Runnable> eventStartSelect = new ArrayList<Runnable>();
  nSelectZone addEventSelecting(Runnable r)  { eventStartSelect.add(r); return this; }
  nSelectZone removeEventSelecting(Runnable r)       { eventStartSelect.remove(r); return this; }
  ArrayList<Runnable> eventSelecting = new ArrayList<Runnable>();
  
  boolean isSelecting() { return emptyClick; }
  
  nGUI gui;
  nSelectZone(nGUI _g) {
    gui = _g;
    gui.addEventFrame(new Runnable() { public void run() { frame(); } } );
    pile = _g.hoverable_pile;
    pile.addEventNotFound(new Runnable() { public void run() { 
      if (ON && gui.in.getClick("MouseRight")) clickDelay = 1; 
    } } );
    drawer = new Drawable(_g.drawing_pile, 25) { public void drawing() {
      noFill();
      stroke(255);
      strokeWeight(2/gui.scale);
      Rect z = new Rect(select_zone);
      if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
      if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
      if (ON && emptyClick) z.draw();
    } };
  }
  boolean isUnder(nWidget w) {
    Rect z = new Rect(select_zone);
    if (z.size.x < 0) { z.pos.x += z.size.x; z.size.x *= -1; }
    if (z.size.y < 0) { z.pos.y += z.size.y; z.size.y *= -1; }
    if (emptyClick && !w.isHided() && rectCollide(w.getRect(), z)) return true;
    return false;
  }
  void frame() {
    if (ON) {
      if (clickDelay > 0) {
        clickDelay--;
        if (clickDelay == 0) { 
          emptyClick = true;
          select_zone.pos.x = gui.mouseVector.x;
          select_zone.pos.y = gui.mouseVector.y;
          select_zone.size.x = 1;
          select_zone.size.y = 1;
          runEvents(eventStartSelect);
        }
      }
      if (emptyClick) {
        runEvents(eventSelecting);
        select_zone.size.x = gui.mouseVector.x - select_zone.pos.x;
        select_zone.size.y = gui.mouseVector.y - select_zone.pos.y;
        if (gui.in.getUnClick("MouseRight")) { 
          runEvents(eventEndSelect);
          emptyClick = false; 
        }
      }
    }
    if (!gui.in.getState("MouseRight")) emptyClick = false;
  }
}




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
//    //nList l = new nList(panel.gui);
//    //l.getRefWidget()
//    //  .setParent(panel.getRefWidget())
//    //  .setPosition(x, y+pos);
//    //l.setPanelDrawer(this)
//    //  .setItemSize(s)
//    //  .setWidth(w)
//    //  .setLayer(panel.layer)
//    //  ;
//    //panel.lists.add(l);
//    //return l;
//    return null;
//  }

//}






 
