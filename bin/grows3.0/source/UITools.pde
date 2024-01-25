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
  nWidget screen_widget;
  Macro_Sheet sheet;
  Camera cam;
  Runnable move_run, zoom_run;
  
  void update_view() {
    if (cam.cam_scale.get() < 0.25) { 
      if (show.get()) { screen_widget.show(); toLayerTop(); }
      //screen_widget.setGrabbable();
      pointwidget.hide();
      thiswidget.hide();
    } else { 
      screen_widget.hide();
      //screen_widget.setPassif();
      if (show.get()) { 
        pointwidget.show();
        thiswidget.show();
        toLayerTop();
      }
    }
  }
  
  nCursor(Macro_Sheet _sheet, String r, String s) {
    super(_sheet.gui);
    sheet = _sheet;
    cam = sheet.mmain().inter.cam;
    new nConstructor(sheet.gui.theme, sheet.gui.theme.ref_size);
    thiswidget = this;
    gui = sheet.gui; ref_size = sheet.gui.theme.ref_size; ref = r;
    copy(gui.theme.getModel("Cursor"));
    refwidget = gui.theme.newWidget(gui, "ref").setParent(this).setPosition(ref_size, ref_size);
    setSize(ref_size*2, ref_size*2);
    setPosition(-ref_size, -ref_size);
    setText(r).setFont(int(ref_size/2.0)).setTextAlignment(LEFT, CENTER);
    setGrabbable();
    addEventDrag(new Runnable() {public void run() {pval.set(refwidget.getX(), refwidget.getY());}});
    pval = sheet.newVec(s+"_cursor_position", s+"_pos");
    pval.addEventDelete(new Runnable(pval) { public void run() { clear(); } } );
    pval.addEventChange(new Runnable(pval) { public void run() {
      sVec v = ((sVec)builder);
      thiswidget.setPosition(v.x()-ref_size, v.y()-ref_size);
      
      PVector p = cam.cam_to_screen(pval.get());
      screen_widget.setPosition(p.x-ref_size/4, p.y-ref_size/4); }});
    move_run = new Runnable() {public void run() { 
      PVector p = cam.cam_to_screen(pval.get());
      screen_widget.setPosition(p.x-ref_size/4, p.y-ref_size/4);
    }};
    zoom_run = new Runnable() {public void run() { 
      update_view();
      PVector p = cam.cam_to_screen(pval.get());
      screen_widget.setPosition(p.x-ref_size/4, p.y-ref_size/4);
    }};
    cam.addEventMove(move_run);
    cam.addEventZoom(zoom_run);
    
    screen_widget = gui.theme.newWidget(sheet.mmain().screen_gui, "Cursor")
      .setSize(ref_size/2, ref_size/2)
      .setPosition(-ref_size/4, -ref_size/4)
      //.setPassif()
      .setGrabbable()
      .setText(r)
      .setFont(int(ref_size / 2.0))
      .setTextAlignment(LEFT, DOWN)
      .addEventDrag(new Runnable() {public void run() {
        PVector p = new PVector(screen_widget.getX()+ref_size/4, screen_widget.getY()+ref_size/4);
        p = cam.screen_to_cam(p);
        pval.set(p.x, p.y);
      }});
      ;
      
    show = sheet.newBoo(false, s+"_cursor_show", s+"_show"); //!!!!! is hided by default
   
    pointwidget = gui.theme.newWidget(gui, "Pointer").setPosition(-ref_size/4, -ref_size/4).setSize(ref_size/2, ref_size/2);
    pointwidget.setParent(refwidget).setGrabbable().setConstrainDistance(ref_size*2).toLayerTop();
    dval = sheet.newVec(s+"_cursor_pointer", s+"_dir");
    dval.addEventChange(new Runnable(dval) {public void run() {
      sVec v = ((sVec)builder);
      if (v.get().mag() > ref_size*2) v.set(v.get().setMag(ref_size*2));
      pointwidget.setPosition(v.x()-ref_size/4, v.y()-ref_size/4); }});
    pointwidget.addEventDrag(new Runnable() {public void run() {
      dval.set(pointwidget.getLocalX() + ref_size/4, pointwidget.getLocalY() + ref_size/4);
    }});
      
    pointwidget.addEventLiberate(new Runnable() {public void run() {
      if (dval.get().mag() < ref_size) dval.set(0, 0); }});
    
    if (show.get()) { thiswidget.show(); pointwidget.show(); } else { thiswidget.hide(); pointwidget.hide(); }
    show.addEventChange(new Runnable(show) {public void run() {
    sBoo v = ((sBoo)builder);
      if (v.get()) { thiswidget.show(); pointwidget.show(); screen_widget.show(); } 
    else { thiswidget.hide(); pointwidget.hide(); screen_widget.hide(); } }});
    
    sheet.mmain().inter.addEventNextFrame(new Runnable() {public void run() {
      update_view();
    }});
  }
  void clear() { 
    cam.removeEventMove(move_run);
    cam.removeEventZoom(zoom_run);
    refwidget.clear(); pointwidget.clear(); screen_widget.clear(); super.clear(); 
    show.clear(); dval.clear(); pval.doEvent(false); pval.clear(); }
  nCursor toLayerTop() { 
    super.toLayerTop(); refwidget.toLayerTop(); pointwidget.toLayerTop(); 
    screen_widget.toLayerTop(); 
    return this; }
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
          if (gui.mouseVector.y < ref.getLocalSY()*8 && !invert) invert = true;
          else if (gui.mouseVector.y > ref.getLocalSY()*12 && invert) invert = false; 
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



class nValuePicker extends nWindowPanel {
  
  ArrayList<String> explorer_entry;
  
  nList explorer_list;
  nWidget info;
  
  sStr val_cible;
  sValueBloc search_bloc;
  boolean autoclose = false, mitig_ac = false;
  
  ArrayList<Runnable> eventsChoose = new ArrayList<Runnable>();
  nValuePicker addEventChoose(Runnable r) { eventsChoose.add(r);  return this; } 
  
  nValuePicker(nGUI _g, nTaskPanel _task, sStr _sv, sValueBloc _sb, boolean _autoclose) { 
    super(_g, _task, "select value"); 
    val_cible = _sv;
    search_bloc = _sb;
    autoclose = _autoclose;
    explorer_entry = new ArrayList<String>();
    
    explorer_list = getShelf().addList(5, 10, 1).setTextAlign(LEFT);
    
    if (!_autoclose) {
      info = getShelf().addSeparator(0.25)
        .addDrawer(1.4)
          .addLinkedModel("Label-S4", "Selected Value :")
          .setLinkedValue(val_cible).setTextAlignment(LEFT, TOP);
    
      getShelf()
        .addSeparator(0.25)
        .addDrawer(10.25, 1)
          .addCtrlModel("Button-S2-P2", "OK")
          .setRunnable(new Runnable() { public void run() { 
            runEvents(eventsChoose); clear(); } }).getShelf();
    }
    update_list();
    
    explorer_list.addEventChange_Builder(new Runnable() { 
      public void run() {
        String choice = explorer_list.last_choice_text;
        if (!choice.equals("")) { 
          val_cible.set(choice); 
          if (autoclose && !mitig_ac) { runEvents(eventsChoose); clear(); }
        }
      } } );
  } 
  void selectEntry(String r) {
    int i = 0;
    for (String me : explorer_entry) {
      if (me.equals(r)) break;
      i++; }
    if (i < explorer_list.listwidgets.size()) explorer_list.listwidgets.get(i).setOn();
  }
  
  void update() {
    update_list();
  }
  void update_list() {
    for (Map.Entry b : search_bloc.values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      explorer_entry.add(s.ref);
    }
    explorer_list.setEntrys(explorer_entry);
  }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}



class nTextPop extends nWindowPanel {
  
  nWidget info;
  ArrayList<Runnable> eventsChoose = new ArrayList<Runnable>();
  nTextPop addEventChoose(Runnable r) { eventsChoose.add(r);  return this; } 
  
  nTextPop(nGUI _g, nTaskPanel _task, String t) { 
    super(_g, _task, t); 
    info = getShelf().addSeparator(0.25)
      .addDrawer(10.25, 1)
        .addModel("Label-S4").setTextAlignment(CENTER, CENTER);
        
    info.setText(t);
  
    getShelf()
      .addSeparator(0.25)
      .addDrawer(10.25, 1)
        .addCtrlModel("Button-S2-P2", "OK")
        .setRunnable(new Runnable() { public void run() { clear(); runEvents(eventsChoose); } }).getShelf();
  }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}



class nTextPicker extends nWindowPanel {
  
  nWidget info;
  String suff = "";
  
  sStr val_cible;
  ArrayList<Runnable> eventsChoose = new ArrayList<Runnable>();
  nTextPicker addEventChoose(Runnable r) { eventsChoose.add(r);  return this; } 
  nTextPicker addSuffix(String s) { suff = s;  return this; } 
  
  nTextPicker(nGUI _g, nTaskPanel _task, sStr _sv, String t) { 
    super(_g, _task, t); 
    val_cible = _sv; 
    info = getShelf().addSeparator(0.25)
      .addDrawer(10.25, 1)
        .addModel("Field-S4").setTextAlignment(LEFT, CENTER);
        
    info.setText(val_cible.get());
    val_cible.addEventChange(new Runnable() { public void run() { 
      info.changeText(val_cible.get()); } } );
    info.setField(true);
    info.addEventFieldChange(new Runnable() { public void run() { 
      String s = info.getText();
      
      int i = s.length() - 1;
      while (i > 0 && s.charAt(i) != '.') { i--; }
      s = s.substring(0, i);
      val_cible.set(s + "." + suff); 
      //logln(s + "." + suff);
    } } );
  
    getShelf()
      .addSeparator(0.25)
      .addDrawer(10.25, 1)
        .addCtrlModel("Button-S2-P2", "OK")
        .setRunnable(new Runnable() { public void run() { clear(); runEvents(eventsChoose); } }).getShelf();
  }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}

class nFilePicker extends nWindowPanel {
  
  nFilePicker addFilter(String f) { 
    ext_filter.add(f); 
    mitig_ac = true; 
    update(); 
    mitig_ac = false; 
    return this; 
  }
  
  ArrayList<String> explorer_entry;
  ArrayList<String> ext_filter;
  
  nList explorer_list;
  nWidget info;
  
  sStr val_cible;
  boolean autoclose = false, mitig_ac = false;
  
  ArrayList<Runnable> eventsChoose = new ArrayList<Runnable>();
  nFilePicker addEventChoose(Runnable r) { eventsChoose.add(r);  return this; } 
  
  nFilePicker(nGUI _g, nTaskPanel _task, sStr _sv, boolean _autoclose, String t) { 
    super(_g, _task, t); 
    val_cible = _sv;
    autoclose = _autoclose;
    explorer_entry = new ArrayList<String>();
    ext_filter = new ArrayList<String>();
    
    explorer_list = getShelf().addList(5, 10, 1).setTextAlign(LEFT);
    
    if (!_autoclose) {
      info = getShelf().addSeparator(0.25)
        .addDrawer(1.4)
          .addLinkedModel("Label-S4", "Selected File :")
          .setLinkedValue(val_cible).setTextAlignment(LEFT, TOP);
    
      getShelf()
        .addSeparator(0.25)
        .addDrawer(10.25, 1)
          .addCtrlModel("Button-S2-P2", "OK")
          .setRunnable(new Runnable() { public void run() { 
            clear(); runEvents(eventsChoose); } }).getShelf();
    }
    update_list();
    
    explorer_list.addEventChange_Builder(new Runnable() { 
      public void run() {
        String choice = explorer_list.last_choice_text;
        if (!choice.equals("")) { 
          val_cible.set(choice); 
          if (autoclose && !mitig_ac) { clear(); runEvents(eventsChoose); }
        }
      } } );
  } 
  void selectEntry(String r) {
    int i = 0;
    for (String me : explorer_entry) {
      if (me.equals(r)) break;
      i++; }
    if (i < explorer_list.listwidgets.size()) explorer_list.listwidgets.get(i).setOn();
  }
  
  void update() {
    update_list();
  }
  void update_list() {
    String[] names = null;
    File file = new File(sketchPath());
    if (file.isDirectory()) { names = file.list(); } // all files in sketch directory
    if (names != null) {
      explorer_entry.clear();
      for (String s : names) {
        String ext = "";
        int i = s.length() - 1;
        while (i > 0 && s.charAt(i) != '.') { ext = s.charAt(i) + ext; i--; }
        boolean fn = false;
        for (String st : ext_filter) { fn = fn || st.equals(ext); }
        if (fn && !s.equals("database.sdata")) explorer_entry.add(s);
      }
      explorer_list.setEntrys(explorer_entry);
      selectEntry(val_cible.get());
    }
  }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}








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





class nNumPanel extends nWindowPanel {
  sInt ival; sFlt fval;
  nNumPanel(nGUI _g, nTaskPanel _task, sFlt _cv) { 
    super(_g, _task, "number"); 
    fval = _cv; if (fval == null) clear();
    build_ui(fval);
  } 
  nNumPanel(nGUI _g, nTaskPanel _task, sInt _cv) { 
    super(_g, _task, "number"); 
    ival = _cv; if (ival == null) clear();
    build_ui(ival);
  } 
  
  nWidget field_widget;
  
  void build_ui(sValue v) {
    getShelf().addDrawer(10.25, 1).getShelf()
      .addDrawer(10.25, 1).addCtrlModel("Button-S2-P3", "OK")
        .setRunnable(new Runnable() { public void run() { clear(); } }).getDrawer();
    field_widget = getDrawer(0,0).addLinkedModel("Field-S4")
      .setLinkedValue(v);
  }
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}


class nBoolPanel extends nWindowPanel {
  nWidget widget;
  sBoo val;
  nBoolPanel(nGUI _g, nTaskPanel _task, sBoo _cv) { 
    super(_g, _task, "boolean"); 
    val = _cv;
    
    if (val == null) clear();
    
    getShelf()
      .addDrawer(7.25, 1).getShelf()
      .addDrawer(7.25, 1)
        .addCtrlModel("Button-S2", "OK")
          .setRunnable(new Runnable() { public void run() { clear(); } })
          .setPX(2.375*ref_size).getDrawer()
          ;
    
    widget = getDrawer(0,0).addLinkedModel("Button-S3")
      .setLinkedValue(val)
      ;
  } 
  nBoolPanel clear() { 
    super.clear(); return this; }
  nBoolPanel updateHeight() { 
    super.updateHeight(); return this; }
  nBoolPanel updateWidth() { 
    super.updateWidth(); return this; }
}


class nTextPanel extends nWindowPanel implements Macro_Interf {
  nWidget text_widget;
  sStr cval;
  String txt; boolean auto_return = true;
  Runnable val_run;
  int larg = 20;
  nTextPanel(nGUI _g, nTaskPanel _task, sStr _cv) { 
    super(_g, _task, "text"); 
    cval = _cv;
    
    if (cval == null) clear();
    if (cval.get().length() < 50) larg = 10;
    float font = int(ref_size/2.1);
    int max_l = int(larg * ref_size / (font / 1.7));
    
    txt = cval.get();
    
    float line_cnt = float(txt.length()) / float(max_l);
    if (line_cnt % 1 > 0) line_cnt += 1 - (line_cnt % 1);
    
    if (cval.ref.equals("links") || cval.ref.equals("spots")) {
      auto_return = false;
      line_cnt = 1;
      int char_counter = 0;
      for (int i = 0 ; i < txt.length() ; i++) {
        char_counter++;
        if (char_counter >= max_l) { line_cnt++; char_counter = 0; }
        if (txt.charAt(i) == OBJ_TOKEN.charAt(0) || txt.charAt(i) == GROUP_TOKEN.charAt(0)) {
          txt = txt.substring(0, i+1) + '\n' + txt.substring(i+1, txt.length());
          line_cnt++;
          char_counter = 0;
        }
      }
    }
    
    float h_fact = (font * line_cnt) / ref_size + font / (ref_size * 2);
    
    //logln("m " + max_l + " lc " + line_cnt + " hf " + h_fact);
    
    getShelf()
      .addDrawer(larg + 0.25, h_fact)
        .getShelf()
      .addDrawer(larg, 1)
        .addCtrlModel("Button-S2-P3", "OK")
          .setRunnable(new Runnable() { public void run() { 
            for (int i = txt.length() - 1 ; i >= 0  ; i--) 
              if (txt.charAt(i) == '\n' || txt.charAt(i) == '\r') {
                txt = txt.substring(0, i);
                if (i+1 < txt.length()) txt += txt.substring(i + 1, txt.length());
            }
            if (cval != null) cval.set(txt);
            clear(); 
          } }).getDrawer()
          ;
    
    text_widget = getDrawer(0,0).addModel("Field")
      .setText(txt)
      .setField(true)
      .setTextAlignment(CENTER, TOP)
      .setTextAutoReturn(auto_return)
      .setFont(int(font))
      .setSX(ref_size * larg)
      .setSY(ref_size * h_fact)
      .setPX(ref_size * 0.125)
      ;
    val_run = new Runnable() { public void run() { 
      float font = int(ref_size/2.1);
      int max_l = int(larg * ref_size / (font / 1.7));
      
      txt = cval.get();
      
      float line_cnt = float(txt.length()) / float(max_l);
      if (line_cnt % 1 > 0) line_cnt += 1 - (line_cnt % 1);
      
      if (cval.ref.equals("links") || cval.ref.equals("spots")) {
        auto_return = false;
        line_cnt = 1;
        int char_counter = 0;
        for (int i = 0 ; i < txt.length() ; i++) {
          char_counter++;
          if (char_counter >= max_l) { line_cnt++; char_counter = 0; }
          if (txt.charAt(i) == OBJ_TOKEN.charAt(0) || txt.charAt(i) == GROUP_TOKEN.charAt(0)) {
            txt = txt.substring(0, i+1) + '\n' + txt.substring(i+1, txt.length());
            line_cnt++;
            char_counter = 0;
          }
        }
      }
      text_widget.setText(txt);
    } };
    cval.addEventChange(val_run);
  } 
  nWindowPanel clear() { 
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
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
  
  nExplorer hideValueView() { 
    myshelf.removeDrawer(info_drawer);
    info_drawer.drawer_height = 0;
    myshelf.insertDrawer(info_drawer);
    //info_drawer.clear(); info_drawer = null;
    val_info.clear(); val_info = null;
    shelf.removeDrawer(this);
    drawer_height = ref_size*7.1;
    shelf.insertDrawer(this);
    return this; 
  }
  nExplorer hideGoBack() { 
    hidegoback = true;
    gobackindex = -1;
    gobackspace = 0;
    update();
    return this; 
  }
  nExplorer showGoBack() { 
    hidegoback = false;
    gobackindex = 0;
    gobackspace = 1;
    update();
    return this; 
  }
  boolean hidegoback = false;
  int gobackindex = 0;
  int gobackspace = 1; 
  
  nShelf myshelf;
  nWidget bloc_info, val_info;
  nDrawer info_drawer;
  
  nDrawer setLayer(int l) { super.setLayer(l); myshelf.setLayer(l); return this; }
  nDrawer toLayerTop() { 
    super.toLayerTop(); myshelf.toLayerTop(); 
    for (nCtrlWidget w : values_button) w.toLayerTop(); 
    return this; }
  
  ArrayList<Runnable> eventChangeRun = new ArrayList<Runnable>();
  nExplorer addEventChange(Runnable r)       { eventChangeRun.add(r); return this; }
  
  nExplorer addEventChange_Builder(Runnable r) { eventChangeRun.add(r); r.builder = this; return this; }
  
  nExplorer addValuesModifier(nTaskPanel _t) {
    task = _t;
    hasvalbutton = true;
    for (int i = 0 ; i < entry_nb ; i++) {
      nCtrlWidget w = explorer_list.addCtrlModel("Button-SSS1", ""+i);
      w.setRunnable(new Runnable(w) { public void run() {
        int ind = int(((nCtrlWidget)builder).getText()) + explorer_list.entry_pos;
        if (ind != gobackindex && ind - explorer_blocs.size() < explorer_values.size()+gobackspace) {
          sValue clicked_val = explorer_values.get(ind-gobackspace - explorer_blocs.size());
          if (clicked_val.type.equals("str")) { 
            new nTextPanel(gui, task, (sStr)clicked_val);
          } else if (clicked_val.type.equals("flt")) { 
            new nNumPanel(gui, task, (sFlt)clicked_val);
          } else if (clicked_val.type.equals("int")) { 
            new nNumPanel(gui, task, (sInt)clicked_val);
          } else if (clicked_val.type.equals("boo")) { 
            new nBoolPanel(gui, task, (sBoo)clicked_val);
          } else if (clicked_val.type.equals("col")) { 
            new nColorPanel(gui, task, (sCol)clicked_val);
          }
        } 
      }});
      w.addEventVisibilityChange(new Runnable(w) { public void run() {
        int ind = int(((nCtrlWidget)builder).getText()) + explorer_list.entry_pos;
        if (ind != gobackindex && ind > explorer_blocs.size() && 
            ind - explorer_blocs.size() < explorer_values.size()+gobackspace) {
          sValue val = explorer_values.get(ind-gobackspace - explorer_blocs.size());
          if (val.type.equals("str") || val.type.equals("col") || 
              val.type.equals("int") || val.type.equals("flt") || val.type.equals("boo")) 
                ((nCtrlWidget)builder).show();
          else { ((nCtrlWidget)builder).hide(); }
        } else { ((nCtrlWidget)builder).hide(); }
      }});
      w.setPosition(ref_size * 8.125, ref_size * (i + 0.25))
        .setTextVisibility(false)
        //.hide()
        ;
      values_button.add(w);
    }
    explorer_list.addEventScroll(new Runnable() { public void run() {
      update_val_bp();
    }});
    update_val_bp();
    return this; 
  }
  
  void update_val_bp() {
    if (hasvalbutton) {
      for (int i = 0 ; i < entry_nb ; i++) {
        int ind = i + explorer_list.entry_pos;
        if (ind != gobackindex && ind > explorer_blocs.size() && 
            ind - explorer_blocs.size() < explorer_values.size()+gobackspace) {
          sValue val = explorer_values.get(ind-gobackspace - explorer_blocs.size());
          if (val.type.equals("str") || val.type.equals("col") || 
              val.type.equals("int") || val.type.equals("flt") || val.type.equals("boo")) values_button.get(i).show();
          else values_button.get(i).hide();
        } else values_button.get(i).hide();
      }
    }
  }
  
  nTaskPanel task;
  ArrayList<nCtrlWidget> values_button;
  boolean hasvalbutton = false;
  int entry_nb = 5;
  
  nExplorer(nShelf s) {
    super(s, s.ref_size*10, s.ref_size*9);
    explorer_entry = new ArrayList<String>();
    explorer_blocs = new ArrayList<sValueBloc>();
    explorer_values = new ArrayList<sValue>();
    values_button = new ArrayList<nCtrlWidget>();
    myshelf = new nShelf(shelf.shelfPanel, shelf.space_factor);
    myshelf.addSeparator(0.25);
    myshelf.ref.setParent(ref);
    explorer_list = myshelf.addList(entry_nb, 10, 1).setTextAlign(LEFT)
      .addEventChange_Builder(new Runnable() { 
      public void run() {
        int ind = ((nList)builder).last_choice_index;
        if (ind == gobackindex && explored_bloc != null && explored_bloc != starting_bloc) {
          explored_bloc = explored_bloc.parent;
          selected_bloc = null;
          selected_value = null;
          update_list();
          runEvents(eventChangeRun);
          
        } else if (ind != gobackindex && ind < explorer_blocs.size()+gobackspace) {
          if (selected_bloc == explorer_blocs.get(ind-gobackspace) && access_child) {
            explored_bloc = selected_bloc;
            selected_bloc = null;
            selected_value = null;
            update_list();
            runEvents(eventChangeRun);
          } else {
            selected_bloc = explorer_blocs.get(ind-gobackspace);
            selected_value = null;
            update_info();
            runEvents(eventChangeRun);
          }
        } else if (ind != gobackindex && ind - explorer_blocs.size() < explorer_values.size()+gobackspace) {
          selected_bloc = null;
          selected_value = explorer_values.get(ind-gobackspace - explorer_blocs.size());
          
          update_info();
          runEvents(eventChangeRun);
        } 
      } } )
      ;
      
    bloc_info = myshelf.addSeparator(0.25)
      .addDrawer(1.4)
        .addModel("Label-S4", "Selected Bloc :").setTextAlignment(LEFT, TOP);
    
    info_drawer = myshelf.addDrawer(1.9);
      
    val_info = info_drawer
        .addModel("Label-S4", "Selected Value :").setTextAlignment(LEFT, TOP).setPY(ref_size * 0.4);
    
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
    update_val_bp();
    if (selected_bloc != null) 
      bloc_info.setText("Selected Bloc :\n " + selected_bloc.type + " " + selected_bloc.ref);
    else bloc_info.setText("Selected Bloc : ");
    if (selected_value != null && val_info != null) 
      val_info.setText("Selected Value : " + selected_value.type + " " + selected_value.ref
                      +"\n = " + selected_value.getString() );
    else if (val_info != null) val_info.setText("Selected Value : " );
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
      if (!hidegoback) {
        if (explored_bloc != starting_bloc) explorer_entry.add("..");
        else explorer_entry.add("");
      }
      for (Map.Entry me : explored_bloc.blocs.entrySet()) {
        sValueBloc cvb = (sValueBloc)me.getValue();
        explorer_blocs.add(cvb); 
        explorer_entry.add(cvb.ref + " " + cvb.use);
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
  ArrayList<Runnable> eventScrollRun = new ArrayList<Runnable>();
  nList addEventScroll(Runnable r)       { eventScrollRun.add(r); return this; }
  
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
        runEvents(eventScrollRun);
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






 
