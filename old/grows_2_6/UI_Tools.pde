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

class nConstructor {
  nGUI gui; 
  float ref_size = 30;
  
  nConstructor(nGUI _g, float s) {
    gui = _g; ref_size = s;
    gui.theme.addModel("ref", new nWidget()
      .setLabelColor(color(200, 200, 200))
      .setFont(int(ref_size/1.6))
      );
    gui.theme.addModel("Hard_Back", gui.theme.newWidget("ref")
      .setStandbyColor(color(50))
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      );
    gui.theme.addModel("Soft_Back", gui.theme.newWidget("ref")
      .setStandbyColor(color(60, 100))
      .setOutlineColor(color(80))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    gui.theme.addModel("Label", gui.theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      );
    gui.theme.addModel("Label_Small_Text", gui.theme.newWidget("Label")
      .setFont(int(ref_size/2.1))
      );
    gui.theme.addModel("Label_Back", gui.theme.newWidget("ref")
      .setStandbyColor(color(55))
      );
    gui.theme.addModel("Button", gui.theme.newWidget("ref")
      .setStandbyColor(color(80))
      .setHoveredColor(color(110))
      .setClickedColor(color(130))
      );
    gui.theme.addModel("Menu_Button", gui.theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(140, 150, 140))
      );
    gui.theme.addModel("Head_Button", gui.theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(120, 130, 120))
      );
    gui.theme.addModel("Auto_Button", gui.theme.newWidget("Button")
      .setStandbyColor(color(25, 120, 20))
      .setHoveredColor(color(30, 140, 25))
      .setClickedColor(color(120, 180, 120))
      );
    gui.theme.addModel("Auto_Ctrl_Button", gui.theme.newWidget("Auto_Button")
      .setFont(int(ref_size/2.2))
      );
    gui.theme.addModel("Auto_Watch_Label", gui.theme.newWidget("ref")
      .setStandbyColor(color(5, 55, 10))
      .setFont(int(ref_size/2.2))
      );
    gui.theme.addModel("Button_Check", gui.theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    gui.theme.addModel("Field", gui.theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineSelectedColor(color(255, 120))
      .setOutlineWeight(ref_size / 10)
      );
    gui.theme.addModel("Cursor", gui.theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      .setHoveredColor(color(255, 120))
      .setClickedColor(color(255, 60))
      .setOutlineColor(color(120))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineConstant(true)
      );
    gui.theme.addModel("List_Entry", gui.theme.newWidget("ref")
      .setStandbyColor(color(10, 80, 90))
      .setHoveredColor(color(20, 90, 130))
      .setClickedColor(color(25, 100, 170))
      .setOutlineWeight(ref_size / 40)
      .setOutline(true)
      .setOutlineColor(color(40, 40, 140))
      );
    make_outline("Button");
    make_outline("Menu_Button");
    make_outline("Head_Button");
    make_outline("Auto_Ctrl_Button");
    make_outline("Label");
    make_outline("Label_Small_Text");
    make_outline("Label_Back");
    make_outline("Auto_Watch_Label");
    make_outline("Auto_Button");
    make("Auto_Button");
    make("Label");
    make("Label_Small_Text");
    make("Button");
    make("Menu_Button");
    make("Head_Button");
    make("Auto_Ctrl_Button");
    make("Label_Back");
    make("Auto_Watch_Label");
    make("Button_Check");
    make("Field");
    make("Cursor");
  }
  void make_outline(String base) {
    gui.theme.addModel(base+"_Outline", gui.theme.newWidget(base)
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    gui.theme.addModel(base+"_Small_Outline", gui.theme.newWidget(base+"_Outline")
      .setOutlineWeight(ref_size / 12)
      );
      
    make(base+"_Outline");
    make(base+"_Small_Outline");
  }
  void do_sizes(String base, String post, float w, float h) {
    gui.theme.addModel(base+post, gui.theme.newWidget(base).setSize(w, h));}
  void do_places(String base, String post, float x, float y, float w, float h) {
    gui.theme.addModel(base+post, gui.theme.newWidget(base).setSize(w, h).setPosition(x, y));}
  
  float[] sizes_val = { 0.5, 0.8, 1, 1.25, 1.5, 2, 2.5, 4, 8 };
  
  void make(String base) {
    do_sizes(base, "-SS1", ref_size*0.75, ref_size*0.75);
    do_sizes(base, "-SS2", ref_size*2.5, ref_size*0.75);
    do_sizes(base, "-SS3", ref_size*4, ref_size*0.75);
    do_sizes(base, "-SS4", ref_size*10, ref_size*0.75);
    do_sizes(base, "-S1", ref_size, ref_size);
    do_sizes(base, "-S2", ref_size*2.5, ref_size);
    do_sizes(base, "-S3", ref_size*4, ref_size);
    do_sizes(base, "-S4", ref_size*10, ref_size);
    
    do_places(base, "-S3-P1", ref_size*0.5, 0, ref_size*4, ref_size);
    do_places(base, "-S3-P2", ref_size*5.5, 0, ref_size*4, ref_size);
    
    do_places(base, "-S2-P1", ref_size*0.5, 0, ref_size*2.5, ref_size);
    do_places(base, "-S2-P2", ref_size*3.75, 0, ref_size*2.5, ref_size);
    do_places(base, "-S2-P3", ref_size*7, 0, ref_size*2.5, ref_size);
    
    do_places(base, "-S1-P1", ref_size*0,     0, ref_size, ref_size);
    do_places(base, "-S1-P2", ref_size*1.125, 0, ref_size, ref_size);
    do_places(base, "-S1-P3", ref_size*2.25,  0, ref_size, ref_size);
    do_places(base, "-S1-P4", ref_size*3.375, 0, ref_size, ref_size);
    do_places(base, "-S1-P5", ref_size*4.5,   0, ref_size, ref_size);
    do_places(base, "-S1-P6", ref_size*5.625, 0, ref_size, ref_size);
    do_places(base, "-S1-P7", ref_size*6.75,  0, ref_size, ref_size);
    do_places(base, "-S1-P8", ref_size*7.875, 0, ref_size, ref_size);
    do_places(base, "-S1-P9", ref_size*9,     0, ref_size, ref_size);
    
    do_places(base, "-SS1-P1", ref_size*0.125, ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P2", ref_size*1.25,  ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P3", ref_size*2.375, ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P4", ref_size*3.5,   ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P5", ref_size*4.625, ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P6", ref_size*5.75,  ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P7", ref_size*6.875, ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P8", ref_size*7.0,   ref_size*0.125, ref_size*0.75, ref_size*0.75);
    do_places(base, "-SS1-P9", ref_size*9.125, ref_size*0.125, ref_size*0.75, ref_size*0.75);
  }
}





class nShelf extends nBuilder {
  nShelf addDrawerDoubleButton(sValue val1, sValue val2, float w, float h) {
    nDrawer d = addDrawer(w, h);
    if (val1 != null) {
    d.addLinkedModel("Auto_Button-S3-P1")
      .setLinkedValue(val1)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val1.shrt)
      ;
    }
    if (val2 != null) {
    d.addLinkedModel("Auto_Button-S3-P2")
      .setLinkedValue(val2)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val2.shrt)
      ;
    }
    return this;
  }
  nShelf addDrawerTripleButton(sValue val1, sValue val2, sValue val3, float w, float h) {
    nDrawer d = addDrawer(w, h);
    if (val1 != null) {
    d.addLinkedModel("Auto_Button-S2-P1")
      .setLinkedValue(val1)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val1.shrt)
      ;
    }
    if (val2 != null) {
    d.addLinkedModel("Auto_Button-S2-P2")
      .setLinkedValue(val2)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val2.shrt)
      ;
    }
    if (val3 != null) {
    d.addLinkedModel("Auto_Button-S2-P3")
      .setLinkedValue(val3)
      //.setSize(w*ref_size/3, h*ref_size)
      //.setPosition(2*w*ref_size/3, 0)
      .setText(val3.shrt)
      ;
    }
    return this;
  }
  
  nShelf addDrawerIncrValue(sValue val2, float incr, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*3.6, 0)
      .setTextAlignment(LEFT)
      ;
    d.addWatcherModel("Auto_Watch_Label-S2")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625, ref_size*0.8)
      .setPosition(ref_size*2.25, ref_size*0.1)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setIncrement(incr)
      .setText(trimStringFloat(incr))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setIncrement(incr/10)
      .setText(trimStringFloat(incr/10))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setIncrement(-incr/10)
      .setText(trimStringFloat(-incr/10))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setIncrement(-incr)
      .setText(trimStringFloat(-incr))
      ;
    return this;
  }
  
  nShelf addDrawerActFactValue(String title, sBoo val1, sValue val2, float fact, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*4.3, 0)
      .setTextAlignment(LEFT)
      ;
    d.addWatcherModel("Auto_Watch_Label")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625, ref_size*0.8)
      .setPosition(ref_size*3.125, ref_size*0.1)
      ;
    d.addLinkedModel("Button_Check-SS1-P3", "")
      .setLinkedValue(val1)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setFactor(fact)
      .setText("x"+trimStringFloat(fact))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setFactor(sqrt(fact))
      .setText("x"+trimStringFloat(sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setFactor(1/sqrt(fact))
      .setText("/"+trimStringFloat(1/sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setFactor(1/fact)
      .setText("/"+trimStringFloat(fact))
      ;
    return this;
  }
  nShelf addDrawerFactValue(sValue val2, float fact, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addModel("Label_Small_Text-S1")
      .setText(val2.ref)
      .setPosition(ref_size*3.6, 0)
      .setTextAlignment(LEFT)
      ;
    d.addWatcherModel("Auto_Watch_Label-S2")
      .setLinkedValue(val2)
      .setSize(ref_size*1.625, ref_size*0.8)
      .setPosition(ref_size*2.25, ref_size*0.1)
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P1")
      .setLinkedValue(val2)
      .setFactor(fact)
      .setText("x"+trimStringFloat(fact))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P2")
      .setLinkedValue(val2)
      .setFactor(sqrt(fact))
      .setText("x"+trimStringFloat(sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P8")
      .setLinkedValue(val2)
      .setFactor(1/sqrt(fact))
      .setText("/"+trimStringFloat(1/sqrt(fact)))
      ;
    d.addCtrlModel("Auto_Ctrl_Button-S1-P9")
      .setLinkedValue(val2)
      .setFactor(1/fact)
      .setText("/"+trimStringFloat(fact))
      ;
    return this;
  }
  nShelf addDrawerSlideCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addWidget(new nSlide(gui, w*ref_size, h*ref_size)
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      )
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(int(ref_size/1.9))
      .setTextAlignment(LEFT)
      ;
    return this;
  }
  nShelf addDrawerFieldCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addLinkedModel("Field")
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(int(ref_size/1.9))
      .setTextAlignment(LEFT)
      ;
    return this;
  }
  nShelf addDrawerLargeFieldCtrl(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addLinkedModel("Field")
      .setLinkedValue(val)
      .setSize(2*w*ref_size/3, h*ref_size)
      .setPosition(w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setTextAlignment(LEFT)
      ;
    return this;
  }
  nShelf addDrawerWatch(sValue val, float w, float h) {
    nDrawer d = addDrawer(w, h);
    d.addWatcherModel("Label_Back")
      .setLinkedValue(val)
      .setSize(w*ref_size/3, h*ref_size)
      .setPosition(2*w*ref_size/3, 0)
      ;
    d.addModel("Label_Small_Text")
      .setSize(w*ref_size/10, h*ref_size)
      .setPosition(0, 0)
      .setText(val.ref)
      .setFont(int(ref_size/1.9))
      .setTextAlignment(LEFT)
      ;
    return this;
  }
  
  nDrawer getDrawer(int s) { return drawers.get(s); }
  nShelfPanel getShelfPanel() { return shelfPanel; }
  nFrontTab getTab() { return ((nFrontTab)shelfPanel); }
  nShelf setPosition(nWidget p, float x, float y) { ref.setParent(p).setPosition(x, y); return this; }
  nDrawer addDrawer(float w, float h) {
    if (max_drawer == 0 || drawers.size() < max_drawer) {
      w = w*ref_size; h = h*ref_size; 
      if (drawers.size() >  0) h += space_factor*ref_size;
      nDrawer d = new nDrawer(this, w, h); 
      //d.ref.setPY(space_factor*ref_size/2);
      if (drawers.size() == 0) d.ref.setParent(ref);
      else if (drawers.size() == 1) {
        nDrawer prev = drawers.get(drawers.size()-1);
        prev.drawer_height += space_factor*ref_size;
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      else {
        nDrawer prev = drawers.get(drawers.size()-1);
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      drawers.add(d); 
      
      total_height += h;
      if (eventHeight != null) eventHeight.run();
      if (max_width <= w) { max_width = w; if (eventWidth != null) eventWidth.run(); }
      return d;  }
    return null;
  }
  nDrawer addDrawer() { return addDrawer(0, 0); }
  nDrawer addDrawer(float h) { return addDrawer(0, h); }
  nShelf addSeparator(float h) { addDrawer(0, h-space_factor); return this; }
  nShelf setMax(int m) { max_drawer = m; return this; }
  
  nShelfPanel shelfPanel;
  nWidget ref;
  ArrayList<nDrawer> drawers = new ArrayList<nDrawer>();
  int max_drawer = 0; // 0 = no limit
  float space_factor, max_width = 0, total_height = 0;
  Runnable eventWidth = null, eventHeight = null;

  nShelf(nShelfPanel s, float _space_factor) {
    super(s.gui, s.ref_size);
    shelfPanel = s; space_factor = _space_factor;
    ref = addModel("ref");
  }
  nShelf addEventWidth(Runnable r) { eventWidth = r; return this; }
  nShelf addEventHeight(Runnable r) { eventHeight = r; return this; }
  
  nShelf setLayer(int l) { super.setLayer(l); 
    ref.setLayer(l); for (nDrawer d : drawers) d.setLayer(l); return this; }
  nShelf toLayerTop() { super.toLayerTop(); 
    ref.toLayerTop(); for (nDrawer d : drawers) d.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(ref); }
  
  
  nList addList(int n, float wf, float hf) {
    
    if (max_drawer == 0 || drawers.size() < max_drawer) {
      float w = wf * ref_size; float h = hf * n * ref_size; 
      if (drawers.size() >  0) h += space_factor*ref_size;
      //nDrawer d = new nDrawer(this, w, h); 
      nList d = new nList(this, n, ref_size, wf, hf);
      //d.ref.setPY(space_factor*ref_size/2);
      if (drawers.size() == 0) d.ref.setParent(ref);
      else if (drawers.size() == 1) {
        nDrawer prev = drawers.get(drawers.size()-1);
        prev.drawer_height += space_factor*ref_size;
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      else {
        nDrawer prev = drawers.get(drawers.size()-1);
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      drawers.add(d); 
      
      total_height += h;
      if (eventHeight != null) eventHeight.run();
      if (max_width <= w) { max_width = w; if (eventWidth != null) eventWidth.run(); }
      return d;  }
    return null;
  }
}





class nBuilder { // base pour les class constructrice de nwidget basic

  nWidget addWidget(nWidget w) { 
    customBuild(w); widgets.add(w); w.toLayerTop(); return w; }
  
  nWidget addRef(float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, "ref").setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
    
  nWidget addModel(String r) { 
    nWidget w = gui.theme.newWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, String t) { 
    nWidget w = gui.theme.newWidget(gui, r).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, String t, float x, float y) { 
    nWidget w = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWidget addModel(String r, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setSize(w, h); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
  nWidget addModel(String r, String t, float x, float y, float w, float h) { 
    nWidget nw = gui.theme.newWidget(gui, r).setPosition(x*ref_size, y*ref_size).setSize(w, h).setText(t); customBuild(nw);
    widgets.add(nw); nw.toLayerTop(); return nw; }
      
  nLinkedWidget addLinkedModel(String r) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nLinkedWidget addLinkedModel(String r, String t) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nLinkedWidget addLinkedModel(String r, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }  
  nLinkedWidget addLinkedModel(String r, String t, float x, float y) { 
    nLinkedWidget w = gui.theme.newLinkedWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }    
    
  nWatcherWidget addWatcherModel(String r) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, String t) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nWatcherWidget addWatcherModel(String r, String t, float x, float y) { 
    nWatcherWidget w = gui.theme.newWatcherWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
      
  nCtrlWidget addCtrlModel(String r) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, String t) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x*ref_size, y*ref_size); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  nCtrlWidget addCtrlModel(String r, String t, float x, float y) { 
    nCtrlWidget w = gui.theme.newCtrlWidget(gui, r); w.setPosition(x*ref_size, y*ref_size).setText(t); customBuild(w);
    widgets.add(w); w.toLayerTop(); return w; }
  
  nGUI gui; 
  ArrayList<nWidget> widgets = new ArrayList<nWidget>();
  float ref_size = 30;
  
  nBuilder setLayer(int l) { for (nWidget w : widgets) w.setLayer(l); return this; }
  nBuilder toLayerTop() { for (nWidget w : widgets) w.toLayerTop(); return this; }
  nBuilder clear() { for (nWidget w : widgets) w.clear(); return this; }
  nWidget customBuild(nWidget w) { return w; }
  
  nBuilder(nGUI _g, float s) {
    //super(_g, s);
    gui = _g; ref_size = s;
    new nConstructor(_g, s);
  }
}



class nCursor extends nWidget {
  float x() { return sval.x(); }
  float y() { return sval.y(); }
  nGUI gui;
  float ref_size;
  sVec sval;
  sBoo show;
  String ref;
  nWidget refwidget, thiswidget;
  nCursor(nGUI _g, sValueBloc bloc, float s, String r) {
    super(_g);
    new nConstructor(_g, s);
    thiswidget = this;
    gui = _g; ref_size = s; ref = r;
    copy(gui.theme.getModel("Cursor"));
    refwidget = gui.theme.newWidget("ref").setParent(this).setPosition(ref_size, ref_size);
    setSize(ref_size*2, ref_size*2);
    setPosition(-ref_size, -ref_size);
    setText(r).setFont(int(ref_size/2.0)).setTextAlignment(LEFT);
    setGrabbable();
    addEventDrag(new Runnable() {public void run() {sval.set(refwidget.getX(), refwidget.getY());}});
    sval = new sVec(bloc, r, "cursor");
    show = new sBoo(bloc, false, r+" show cursor", "cursor"); //!!!!! is hided by default
    if (show.get()) thiswidget.show(); else thiswidget.hide();
    sval.addEventChange(new Runnable(sval) {public void run() {
      sVec v = ((sVec)builder);
      thiswidget.setPosition(v.x()-ref_size, v.y()-ref_size);}});
    show.addEventChange(new Runnable(show) {public void run() {
    sBoo v = ((sBoo)builder);
      if (v.get()) thiswidget.show(); else thiswidget.hide();}});
    
  }
}





class nDropMenu extends nBuilder {
  
  nDropMenu drop(nWidget op, float x, float y) { 
    opener = op; 
    ref.setPosition(x, y).show(); 
    return this; }
  nDropMenu drop(nGUI g) { 
    float p_y = g.mouseVector.y + haut/2;
    float total_haut = haut*menu_widgets.size();
    if (p_y - total_haut < g.view.pos.y) p_y += g.view.pos.y - (p_y - total_haut);
    //openner = op; 
    ref.setPosition(g.mouseVector.x - larg/2, p_y).show(); return this; }
  nDropMenu close() { ref.hide(); return this; }
  
  nWidget ref, opener;
  ArrayList<nWidget> menu_widgets = new ArrayList<nWidget>();
  ArrayList<Runnable> events = new ArrayList<Runnable>();
  int layer = 0;  float haut, larg;  boolean down, ephemere = false;
  
  nDropMenu(nGUI _gui, float ref_size, float width_factor, boolean _down, boolean _ephemere) {
    super(_gui, ref_size);
    haut = ref_size; larg = haut*width_factor; down = _down; ephemere = _ephemere;
    ref = addModel("ref").stackRight()
      .addEventFrame(new Runnable() { public void run() { 
        boolean t = false;
        for (nWidget w : menu_widgets) t = t || w.isHovered();
        if (opener != null) t = t || opener.isHovered();
        if ((gui.in.getClick("MouseLeft") || ephemere) && !t) ref.hide();
      } });
    if (!down) ref.stackUp(); 
  }
  //nDropMenu setDropLeft() { ref.stackLeft(); return this; }
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
      .setTextAlignment(LEFT)
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


class nColorPanel extends nWindowPanel {
  nColorPanel setOkEvent_Builder(Runnable r) { ok_run = r; ok_run.builder = this; return this; }
  
  nWidget color_widget, red_widget, gre_widget, blu_widget;
  float red, gre, blu;
  Runnable ok_run;
  nColorPanel(nGUI _g, nTaskPanel _task) { 
    super(_g, _task, "color"); 
    getShelf(0)
      .addDrawer(1)
        .addWidget(new nSlide(gui, ref_size, ref_size*7.375)
          .addEventSlide(new Runnable() { public void run(float v) { 
            red = v*255; update(); red_widget.setText(trimStringFloat(red)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(1)
        .addWidget(new nSlide(gui, ref_size, ref_size*7.375)
          .addEventSlide(new Runnable() { public void run(float v) { 
            gre = v*255; update(); gre_widget.setText(trimStringFloat(gre)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(1)
        .addWidget(new nSlide(gui, ref_size, ref_size*7.375)
          .addEventSlide(new Runnable() { public void run(float v) { 
            blu = v*255; update(); blu_widget.setText(trimStringFloat(blu)); } } )
          .setPosition(0, 0) ).getShelf()
      .addDrawer(1)
        .addCtrlModel("Button-S2-P3", "OK")
          .setRunnable(new Runnable() { public void run() { clear();  } }).getDrawer()
          ;
        
    color_widget = getDrawer(0,4).addModel("Label-S3-P1")
          .setStandbyColor(color(red, gre, blu));
    red_widget = getDrawer(0,1)
        .addModel("Label_Small_Outline-S2", "0.0").setPX(7.5*ref_size);
    gre_widget = getDrawer(0,2)
        .addModel("Label_Small_Outline-S2", "0.0").setPX(7.5*ref_size);
    blu_widget = getDrawer(0,3)
        .addModel("Label_Small_Outline-S2", "0.0").setPX(7.5*ref_size);
  } 
  void update() { color_widget.setStandbyColor(color(red, gre, blu)); }
  nWindowPanel clear() { 
    //taskpanel_button.removeEventTrigger(run_show).setText("").setPassif().setStandbyColor(color(60));
    super.clear(); return this; }
  nWindowPanel updateHeight() { 
    super.updateHeight(); return this; }
  nWindowPanel updateWidth() { 
    super.updateWidth(); return this; }
}



class nDrawer extends nBuilder {
  nShelf getShelf() { return shelf; }
  nShelfPanel getShelfPanel() { return shelf.shelfPanel; }
  nShelf shelf;
  nWidget ref;
  float drawer_width = 0, drawer_height = 0;
  nDrawer(nShelf s, float w, float h) {
    super(s.gui, s.ref_size);
    ref = addModel("ref"); shelf = s;
    drawer_width = w; drawer_height = h; }
  nDrawer setLayer(int l) { super.setLayer(l); ref.setLayer(l); return this; }
  nDrawer toLayerTop() { super.toLayerTop(); ref.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(ref).setDrawer(this); }
}



class nList extends nDrawer {
  
  nPanelDrawer panel_drawer = null;
  nList setPanelDrawer(nPanelDrawer d) { panel_drawer = d; return this; }
  nPanelDrawer getPanelDrawer() { return panel_drawer; }
  
  //nGUI gui;
  ArrayList<nWidget> listwidgets = new ArrayList<nWidget>();
  ArrayList<String> entrys = new ArrayList<String>();
  nWidget back;
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
  nList(nShelf _sh, int _ent_nb, float _rs, float _lf, float _hf) {
    super(_sh, _rs*_lf, _rs*_hf*_ent_nb);
    list_widget_nb = _ent_nb;
    back = new nWidget(gui, 0, 0);
    back.setParent(ref);
    item_s = ref_size*_hf; larg = ref_size*_lf;
        ;
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
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = gui.theme.newWidget(gui, "List_Entry").setSize(larg - item_s, item_s)
        .stackDown()
        .setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() {
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
      runEvents(eventChangeRun);
    }
  }
  void update_list() {
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget w = listwidgets.get(i);
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
    update_list();
    return this;
  }
  nList setListLength(int l) {
    for (int i = 0 ; i < list_widget_nb ; i++) listwidgets.get(i).clear();
    listwidgets.clear();
    list_widget_nb = l;
    for (int i = 0 ; i < list_widget_nb ; i++) {
      nWidget ne = gui.theme.newWidget(gui, "List_Entry").setSize(larg - item_s, item_s)
        .stackDown()
        .setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() {
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
        .setOutlineWeight(w / 16)
        .setOutline(true)
        .setTrigger()
        .addEventFrame(new Runnable() { public void run() {
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelUp) {
            if (entry_pos < entry_nb - entry_view) entry_pos++;
            update_cursor();
            runEvents(eventChangeRun);
          }
          if ((back.isHovered() || up.isHovered() || down.isHovered() || curs.isHovered()) && gui.in.mouseWheelDown) {
            if (entry_pos > 0) entry_pos--;
            update_cursor();
            runEvents(eventChangeRun);
          }
        }})
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

class nShelfPanel extends nBuilder {
  nFrontPanel getFront() { if (fronttab != null) return fronttab.front; else return null; }
  nFrontTab fronttab; // set by superclass fronttab with himself
  
  nDrawer getDrawer(int c, int r) { return shelfs.get(c).drawers.get(r); }
  nShelf getShelf(int s) { return shelfs.get(s); }
  nShelf getShelf() { return shelfs.get(0); }
  
  nShelf addShelf() {
    nShelf s = new nShelf(this, space_factor);
    s.setPosition(panel, ref_size*space_factor, ref_size*space_factor); 
    s.addEventHeight(new Runnable(s) { public void run() { updateHeight(); } } );
    s.addEventWidth(new Runnable() { public void run() { updateWidth(); } } );
    shelfs.add(s);
    updateWidth();
    return s;
  }
  nShelfPanel addGrid(int c, int r, float width_factor, float height_factor) {
    for (int i = 0 ; i < c ; i++) {
      nShelf s = addShelf();
      for (int j = 0 ; j < r ; j++) s.addDrawer(width_factor, height_factor);
    }
    return this;
  }
  nShelfPanel updateHeight() {  
    float h = ref_size * 2 * space_factor;
    for(nShelf s : shelfs) 
      if (h < s.total_height + ref_size * 2 * space_factor) 
        h = s.total_height + ref_size * 2 * space_factor;
    panel.setSY(h); 
    return this; }
  nShelfPanel updateWidth() { 
    float w = ref_size * space_factor;
    for (nShelf s : shelfs) { s.ref.setPX(w); w += s.max_width + ref_size * space_factor; }
    if (shelfs.size() == 0) w += ref_size * space_factor;
    panel.setSX(w); 
    return this; }
  nShelfPanel(nGUI _g, float _ref_size, float _space_factor) {
    super(_g, _ref_size);
    panel = addModel("Hard_Back");
    panel.setSize(ref_size*_space_factor*2, ref_size*_space_factor*2);
    space_factor = _space_factor;
  }
  float space_factor, max_height = 0;
  nWidget panel;
  ArrayList<nShelf> shelfs = new ArrayList<nShelf>();
  
  nShelfPanel setLayer(int l) { super.setLayer(l); 
    panel.setLayer(l); for (nShelf d : shelfs) d.setLayer(l); return this; }
  nShelfPanel toLayerTop() { super.toLayerTop(); 
    panel.toLayerTop(); for (nShelf d : shelfs) d.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(panel); }
}


class nFrontTab extends nShelfPanel {
  nFrontPanel getFront() { return front; }
  
  ArrayList<Runnable> eventOpen = new ArrayList<Runnable>();
  nFrontTab addEventOpen(Runnable r)       { eventOpen.add(r); return this; }
  
  
  
  nFrontTab show() {
    panel.show();
    
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
    
    super.updateWidth(); return this; }
}


class nFrontPanel extends nWindowPanel {
  nFrontPanel setNonClosable() { closer.setText("").setBackground(); return this; }
  ArrayList<nFrontTab> tabs = new ArrayList<nFrontTab>();
  ArrayList<nWidget> tab_widgets = new ArrayList<nWidget>();
  nFrontTab current_tab;
  nFrontTab addTab(String n) {
    nFrontTab tab = new nFrontTab(this, n);
    tabs.add(tab);
    tab.panel.setParent(panel).stackDown();
    float new_width = grabber.getLocalSX() / (tab_widgets.size() + 1);
    nWidget tabbutton = addModel("Button-SS3");
    tabbutton.setSwitch().setText(n)
      .setParent(grabber)
      .setSX(new_width)
      .addEventSwitchOn(new Runnable(tab) { public void run() {
        if (current_tab != null) current_tab.hide();
        current_tab = ((nFrontTab)builder);
        current_tab.show();
        runEvents(current_tab.eventOpen);
      } } )
      ;
    for (nWidget w : tab_widgets) { w.setSX(new_width); tabbutton.addExclude(w); w.addExclude(tabbutton); }
    if (tab_widgets.size() > 0) tabbutton.setParent(tab_widgets.get(tab_widgets.size()-1)).stackRight();
    else tabbutton.stackDown();
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
    panel.setSY(0);
  } 
  void reduc() { super.reduc(); if (tab_widgets.size() > 0) tab_widgets.get(0).hide(); }
  void enlarg() { super.enlarg(); if (tab_widgets.size() > 0) tab_widgets.get(0).show();  }
  nFrontPanel clear() { 
    
    super.clear(); return this; }
  nFrontPanel updateHeight() { 
    super.updateHeight(); return this; }
  nFrontPanel updateWidth() { 
    super.updateWidth(); return this; }
}







class nWindowPanel extends nShelfPanel {
  nWindowPanel setPosition(float x, float y) {
    grabber.setPosition(x-task.panel.getX(), y-task.panel.getY()); return this;}
  void reduc() { panel.hide(); }
  void enlarg() { panel.show();  }
  void collapse() { 
    grabber.hide(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(90)); }
  void popUp() { 
    if (task.hide) task.reduc();
    grabber.show(); taskpanel_button.setStandbyColor(color(70)); }
  nTaskPanel task;
  nWidget grabber, closer, reduc, collapse, taskpanel_button;
  Runnable run_show;
  nWindowPanel(nGUI _g, nTaskPanel _task, String ti) { 
    super(_g, _task.ref_size, _task.space_factor); 
    task = _task;
    
    grabber = addModel("Head_Button_Small_Outline-SS4").setParent(task.panel).setText(ti)
      .setGrabbable()
      .setSX(ref_size*10.25)
      .setPosition(10*ref_size-task.panel.getX(), 5*ref_size-task.panel.getY())
      .show()
      //.addEventDrag(new Runnable() { public void run() { runEvents(eventDragRun); } } )
      ;
      
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
    reduc = addModel("Head_Button_Small_Outline-SS1").setText("-")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() {
        if (panel.isHided()) enlarg(); else reduc(); } } )
      .setParent(collapse)
      .stackLeft()
      ;
    panel.setParent(grabber).stackDown();
    addShelf().addDrawer(10, 0);
    taskpanel_button = task.getWindowPanelButton(this);
    run_show = new Runnable() { public void run() { 
      popUp(); } };
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
    super.updateWidth(); return this; }
}


class nTaskPanel extends nToolPanel {
  ArrayList<nWindowPanel> windowPanels = new ArrayList<nWindowPanel>();
  ArrayList<nWidget> window_buttons = new ArrayList<nWidget>();
  int used_spot = 0, max_spot = 6;
  int row = 3, col = 2;
  nWidget getWindowPanelButton(nWindowPanel w) {
    if (used_spot < max_spot) {
      int i = 0;
      while(!window_buttons.get(i).getText().equals("")) i++;
      w.taskpanel_button = window_buttons.get(i);
      w.taskpanel_button.setTrigger().setText(w.grabber.getText()).setStandbyColor(color(70))
        .addEventTrigger(new Runnable() { public void run() {} } );
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
    reduc();
  } 
  nTaskPanel updateHeight() { 
    super.updateHeight(); return this; }
  nTaskPanel updateWidth() { 
    super.updateWidth(); return this; }
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
    //nList l = new nList(panel.gui);
    //l.getRefWidget()
    //  .setParent(panel.getRefWidget())
    //  .setPosition(x, y+pos);
    //l.setPanelDrawer(this)
    //  .setItemSize(s)
    //  .setWidth(w)
    //  .setLayer(panel.layer)
    //  ;
    //panel.lists.add(l);
    //return l;
    return null;
  }

}






 
