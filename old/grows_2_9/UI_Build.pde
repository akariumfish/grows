class nConstructor {
  nTheme theme; 
  float ref_size = 30;
  
  nConstructor(nTheme _g, float s) {
    theme = _g; ref_size = s;
    theme.addModel("ref", new nWidget()
      //.setPassif()
      .setLabelColor(color(200, 200, 200))
      .setFont(int(ref_size/1.6))
      );
    theme.addModel("Hard_Back", theme.newWidget("ref")
      .setStandbyColor(color(50))
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      );
    theme.addModel("Soft_Back", theme.newWidget("ref")
      .setStandbyColor(color(60, 100))
      .setOutlineColor(color(80))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel("Label", theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      );
    theme.addModel("Label_Small_Text", theme.newWidget("Label")
      .setFont(int(ref_size/2.1))
      );
    theme.addModel("Label_Back", theme.newWidget("ref")
      .setStandbyColor(color(55))
      );
    theme.addModel("Label_HightLight_Back", theme.newWidget("ref")
      .setStandbyColor(color(210, 190, 30))
      .setLabelColor(color(90, 80, 50))
      .setFont(int(ref_size/2.1))
      );
    theme.addModel("Label_DownLight_Back", theme.newWidget("ref")
      .setStandbyColor(color(70, 10, 10))
      .setFont(int(ref_size/2.1))
      );
    theme.addModel("Button", theme.newWidget("ref")
      .setStandbyColor(color(80))
      .setHoveredColor(color(110))
      .setClickedColor(color(130))
      );
    theme.addModel("Button_Small_Text", theme.newWidget("Button")
      .setFont(int(ref_size/2.2))
      );
    theme.addModel("Menu_Button", theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(140, 150, 140))
      );
    theme.addModel("Head_Button", theme.newWidget("Button")
      .setStandbyColor(color(80, 90, 80))
      .setHoveredColor(color(110, 120, 110))
      .setClickedColor(color(120, 130, 120))
      );
    theme.addModel("Auto_Button", theme.newWidget("Button")
      .setFont(int(ref_size/1.9))
      .setStandbyColor(color(20, 100, 15))
      .setHoveredColor(color(120, 180, 120))
      .setClickedColor(color(30, 150, 25))
      );
    theme.addModel("Auto_Ctrl_Button", theme.newWidget("Auto_Button")
      .setFont(int(ref_size/2.2))
      );
    theme.addModel("Auto_Watch_Label", theme.newWidget("ref")
      .setStandbyColor(color(5, 55, 10))
      .setFont(int(ref_size/2.2))
      );
    theme.addModel("Button_Check", theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel("Field", theme.newWidget("ref")
      .setStandbyColor(color(20))
      .setOutlineColor(color(255, 120))
      .setOutlineSelectedColor(color(255, 120))
      .setOutlineWeight(ref_size / 10)
      );
    theme.addModel("Cursor", theme.newWidget("ref")
      .setStandbyColor(color(255, 0))
      .setHoveredColor(color(255, 120))
      .setClickedColor(color(255, 60))
      .setOutlineColor(color(120))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineConstant(true)
      );
    theme.addModel("Pointer", theme.newWidget("ref")
      .setStandbyColor(color(120))
      .setHoveredColor(color(70))
      .setClickedColor(color(220))
      .setOutlineColor(color(70))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineConstant(true)
      );
    theme.addModel("List_Entry", theme.newWidget("ref")
      .setStandbyColor(color(10, 80, 90))
      .setHoveredColor(color(20, 90, 130))
      .setClickedColor(color(25, 100, 170))
      .setOutlineWeight(ref_size / 40)
      .setOutline(true)
      .setOutlineColor(color(40, 40, 140))
      );
    theme.addModel("List_Entry_Selected", theme.newWidget("ref")
      .setStandbyColor(color(10, 100, 130))
      .setHoveredColor(color(20, 110, 150))
      .setClickedColor(color(30, 115, 175))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      .setOutlineColor(color(100, 170, 210))
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
    make_outline("Label_HightLight_Back");
    make_outline("Button_Small_Text");
    make_outline("Label_DownLight_Back");
    make("Label_DownLight_Back");
    make("Button_Small_Text");
    make("Label_HightLight_Back");
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
    theme.addModel(base+"_Outline", theme.newWidget(base)
      .setOutlineColor(color(90))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      );
    theme.addModel(base+"_Highlight_Outline", theme.newWidget(base)
      .setOutlineColor(color(190, 150, 30))
      .setOutlineWeight(ref_size / 6)
      .setOutline(true)
      );
    theme.addModel(base+"_Downlight_Outline", theme.newWidget(base)
      .setOutlineColor(color(100, 100, 100))
      .setOutlineWeight(ref_size / 10)
      .setOutline(true)
      );
    theme.addModel(base+"_Small_Outline", theme.newWidget(base+"_Outline")
      .setOutlineWeight(ref_size / 12)
      );
      
    make(base+"_Outline");
    make(base+"_Highlight_Outline");
    make(base+"_Downlight_Outline");
    make(base+"_Small_Outline");
  }
  void do_sizes(String base, String post, float w, float h) {
    theme.addModel(base+post, theme.newWidget(base).setSize(w, h));}
  void do_places(String base, String post, float x, float y, float w, float h) {
    theme.addModel(base+post, theme.newWidget(base).setSize(w, h).setPosition(x, y));}
  
  float[] sizes_val = { 0.5, 0.8, 1, 1.25, 1.5, 2, 2.5, 4, 8 };
  
  void make(String base) {
    
    do_sizes(base, "-S2/1", ref_size*2, ref_size);
    do_sizes(base, "-S2/0.75", ref_size*2, ref_size*0.75);
    do_sizes(base, "-S2.5/0.75", ref_size*2.5, ref_size*0.75);
    do_sizes(base, "-S3/0.75", ref_size*3, ref_size*0.75);
    do_sizes(base, "-S4/0.75", ref_size*4, ref_size*0.75);
    do_sizes(base, "-S6/1", ref_size*6, ref_size*1);
    
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
  nBuilder clear() { for (nWidget w : widgets) w.clear(); widgets.clear(); return this; }
  nWidget customBuild(nWidget w) { return w; }
  
  nBuilder(nGUI _g, float s) { gui = _g; ref_size = s; }
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
  nShelf addDrawerButton(sValue val1, float w, float h) {
    nDrawer d = addDrawer(w, h);
    if (val1 != null) {
    d.addLinkedModel("Auto_Button-S3-P2")
      .setLinkedValue(val1)
      .setSY(h*ref_size*0.75)
      .setPY(h*ref_size*0.125)
      .setText(val1.shrt)
      ;
    d.addModel("Label_Small_Text-S1")
      .setText(val1.ref)
      .setPosition(ref_size*0, 0)
      .setTextAlignment(LEFT, CENTER)
      ;
    }
    return this;
  }
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
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
      .setTextAlignment(LEFT, CENTER)
      ;
    return this;
  }
  
  nDrawer getDrawer(int s) { return drawers.get(s); }
  nDrawer getLastDrawer() { return drawers.get(drawers.size()-1); }
  nShelfPanel getShelfPanel() { return shelfPanel; }
  nFrontTab getTab() { return ((nFrontTab)shelfPanel); }
  nShelf setPosition(nWidget p, float x, float y) { ref.setParent(p).setPosition(x, y); return this; }
  
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
  nShelf clear() { super.clear(); for (nDrawer s : drawers) s.clear(); return this; }
  nDrawer addDrawer() { return addDrawer(0, 0); }
  nDrawer addDrawer(float h) { return addDrawer(0, h); }
  nShelf addSeparator() { addDrawer(0, 0); return this; }
  nShelf addSeparator(float h) { addDrawer(0, h-space_factor); return this; }
  nShelf setMax(int m) { max_drawer = m; return this; }
  nDrawer addDrawer(float w, float h) { return insertDrawer(new nDrawer(this, w*ref_size, h*ref_size)); }
  nDrawer insertDrawer(nDrawer d) {
    if (d != null && max_drawer == 0 || drawers.size() < max_drawer) {
      if (drawers.size() == 0) { d.ref.setParent(ref).setPY(0); }
      else {
        nDrawer prev = drawers.get(drawers.size()-1);
        prev.drawer_height += ref_size*space_factor/2;
        d.ref.setParent(prev.ref)
          .setPY(prev.drawer_height);  }
      drawers.add(d); 
      
      total_height = 0;
      for (nDrawer dr : drawers) total_height += dr.drawer_height;
      if (eventHeight != null) eventHeight.run();
      if (max_width <= d.drawer_width) { max_width = d.drawer_width; if (eventWidth != null) eventWidth.run(); }
      return d;  }
    return null;
  }
  nShelf removeDrawer(nDrawer d) {
    if (drawers.contains(d)) {
      int d_i = 0;
      for (nDrawer td : drawers) { if (td == d) break; else d_i++; }
      if (drawers.size() == 1) { d.ref.setPY(0).clearParent(); drawers.remove(d); }
      else if (d_i == 0) { 
        drawers.get(1).ref.setPY(0).clearParent().setParent(ref); 
        d.ref.clearParent(); drawers.remove(d); }
      else if (d_i < drawers.size() - 1) { 
        drawers.get(d_i+1).ref.setPY(0).clearParent().setParent(drawers.get(d_i-1).ref); 
        d.ref.clearParent(); drawers.remove(d); }
      else if (d_i == drawers.size() - 1) { d.ref.clearParent(); drawers.remove(d); }
      total_height = 0;
      for (nDrawer dr : drawers) total_height += dr.drawer_height;
      if (eventHeight != null) eventHeight.run();
    }
    return this;
  }
  
  nList addList(int n, float wf, float hf) {
    nList d = new nList(this, n, ref_size, wf, hf);
    insertDrawer(d);
    return d;
  }
  
  nExplorer addExplorer() {
    nExplorer d = new nExplorer(this);
    insertDrawer(d);
    return d;
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
    shelfs.add(s);
    updateWidth();
    s.addEventHeight(new Runnable(s) { public void run() { updateHeight(); } } );
    s.addEventWidth(new Runnable() { public void run() { updateWidth(); } } );
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
    for(nShelf s : shelfs) { s.ref.setPX(ref_size * space_factor);
      if (h < s.total_height + ref_size * 2 * space_factor) 
        h = s.total_height + ref_size * 2 * space_factor; }
    panel.setSY(h); 
    max_height = h - ref_size * 2 * space_factor;
    return this; }
  nShelfPanel updateWidth() { 
    float w = ref_size * space_factor;
    for (nShelf s : shelfs) { s.ref.setPX(w); w += s.max_width + ref_size * space_factor; }
    if (shelfs.size() == 0) w += ref_size * space_factor;
    panel.setSX(w); 
    max_width = w - ref_size * space_factor * 2;
    return this; }
  nShelfPanel setSpace(float _space_factor) { 
    space_factor = _space_factor;
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
  nShelfPanel clear() { super.clear(); for (nShelf s : shelfs) s.clear(); return this; }
}









  
