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
      if (max_width <= w) { 
        max_width = w; 
        if (eventWidth != null) eventWidth.run(); 
      }
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
  
  nDrawer addShelfaddDrawer(float x, float y) {
    return addShelf().addDrawer(x, y);
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
    max_height = h;
    return this; }
  nShelfPanel updateWidth() { 
    float w = ref_size * space_factor;
    for (nShelf s : shelfs) { s.ref.setPX(w); w += s.max_width + ref_size * space_factor; }
    if (shelfs.size() == 0) w += ref_size * space_factor;
    panel.setSX(w); 
    max_width = w;
    logln("shelfpanel " + w);
    return this; }
  nShelfPanel(nGUI _g, float _ref_size, float _space_factor) {
    super(_g, _ref_size);
    panel = addModel("Hard_Back");
    panel.setSize(ref_size*_space_factor*2, ref_size*_space_factor*2);
    space_factor = _space_factor;
  }
  float space_factor, max_width = 0, max_height = 0;
  nWidget panel;
  ArrayList<nShelf> shelfs = new ArrayList<nShelf>();
  
  nShelfPanel setLayer(int l) { super.setLayer(l); 
    panel.setLayer(l); for (nShelf d : shelfs) d.setLayer(l); return this; }
  nShelfPanel toLayerTop() { super.toLayerTop(); 
    panel.toLayerTop(); for (nShelf d : shelfs) d.toLayerTop(); return this; }
  nWidget customBuild(nWidget w) { return w.setParent(panel); }
}









  
