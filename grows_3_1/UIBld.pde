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
    do_sizes(base, "-S10/0.75", ref_size*10, ref_size*0.75);
    
    do_sizes(base, "-SS1", ref_size*0.75, ref_size*0.75);
    do_sizes(base, "-SSS1", ref_size*0.5, ref_size*0.5);
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
    
    for (int i = 1 ; i <= 9 ; i++) {
      do_places(base, "-N1-P"+i, ref_size*(((i-1)*1.125)+0.125), ref_size*0.0, ref_size*0.5, ref_size*0.5);
      do_places(base, "-N2-P"+i, ref_size*(((i-1)*1.125)+0.125), ref_size*0.5, ref_size*0.5, ref_size*0.5);
      do_places(base, "-N3-P"+i, ref_size*(((i-1)*1.125)+0.675), ref_size*0.0, ref_size*0.5, ref_size*0.5);
      do_places(base, "-N4-P"+i, ref_size*(((i-1)*1.125)+0.675), ref_size*0.5, ref_size*0.5, ref_size*0.5);
    }
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
  nBuilder clear() { 
    for (int i = widgets.size() - 1 ; i >= 0 ; i--) widgets.get(i).clear(); 
    widgets.clear(); 
    return this; 
  }
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
  nDrawer clear() { super.clear(); return this; }
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
  //nShelf addDrawerSlideCtrl(sValue val, float w, float h) {
  //  nDrawer d = addDrawer(w, h);
  //  d.addWidget(new nSlide(gui, w*ref_size, h*ref_size)
  //    .setLinkedValue(val)
  //    .setSize(w*ref_size/3, h*ref_size)
  //    .setPosition(2*w*ref_size/3, 0)
  //    )
  //    ;
  //  d.addModel("Label_Small_Text")
  //    .setSize(w*ref_size/10, h*ref_size)
  //    .setPosition(0, 0)
  //    .setText(val.ref)
  //    .setFont(int(ref_size/1.9))
  //    .setTextAlignment(LEFT, CENTER)
  //    ;
  //  return this;
  //}
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
  nShelf clearDrawer() {
    ArrayList<nDrawer> a = new ArrayList<nDrawer>();
    for (nDrawer d : drawers) a.add(d);
    //for (nDrawer d : a) d.clear();
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









  








class nToolPanel extends nShelfPanel {
  
  ArrayList<Runnable> eventReducRun = new ArrayList<Runnable>();
  nToolPanel addEventReduc(Runnable r)       { eventReducRun.add(r); return this; }
  nToolPanel removeEventReduc(Runnable r)       { eventReducRun.remove(r); return this; }
  void openit() { if (hide) reduc(); }
  void closeit() { if (!hide) reduc(); }
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
    up_pos();
    gui.addEventsFullScreen(new Runnable(this) { public void run() { 
      up_pos();
    } } );
  } 
  float py = 0;
  nToolPanel setPos(float y) { py = y; up_pos(); return this; }
  void up_pos() {
    if (top)    { panel.setPY(py + gui.view.pos.y).stackDown(); reduc.alignUp(); }
    else        { panel.setPY(py + gui.view.pos.y + gui.view.size.y).stackUp(); reduc.alignDown(); }
    if (!right) { panel.setPX(gui.view.pos.x).stackRight(); reduc.setText("<").stackRight(); }
    else        { panel.setPX(gui.view.pos.x + gui.view.size.x).stackLeft(); reduc.setText(">").stackLeft(); }
  }
  nToolPanel updateHeight() { 
    super.updateHeight(); if (reduc != null) reduc.setSY(panel.getLocalSY()); return this; }
}





class nTaskPanel extends nToolPanel {
  ArrayList<nWindowPanel> windowPanels = new ArrayList<nWindowPanel>();
  ArrayList<nWidget> window_buttons = new ArrayList<nWidget>();
  int used_spot = 0, max_spot = 8;
  int row = 2, col = 4;
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
    
    addGrid(col, row, 4, 0.75);
    for (int i = 0 ; i < col ; i++) for (int j = 0 ; j < row ; j++) {
      nWidget nw = getDrawer(i, j).addModel("Button-S4/0.75").setStandbyColor(color(60));
      window_buttons.add(nw);
    }
    //gui.addEventSetup(new Runnable() { public void run() { reduc(); } } );
  } 
  nTaskPanel updateHeight() { 
    super.updateHeight(); return this; }
  nTaskPanel updateWidth() { 
    super.updateWidth(); return this; }
}






class nSimplePanel extends nShelfPanel {
  nSimplePanel setPosition(float x, float y) {
    grabber.setPosition(x, y); return this;}
    
  ArrayList<Runnable> eventCloseRun = new ArrayList<Runnable>();
  nSimplePanel addEventClose(Runnable r)       { eventCloseRun.add(r); return this; }
  nSimplePanel removeEventClose(Runnable r)       { eventCloseRun.remove(r); return this; }
  
  nWidget grabber, closer;
  nSimplePanel(nGUI _g, float _ref_size, float _space_factor, String ti) { 
    super(_g, _ref_size, _space_factor); 
    
    grabber = addModel("Head_Button_Small_Outline-SS4").setText(ti)
      .setGrabbable()
      .setSX(ref_size*10.25)
      .show()
      .addEventGrab(new Runnable() { public void run() { toLayerTop(); } } )
      ;
    
    closer = addModel("Head_Button_Small_Outline-SS1").setText("X")
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { 
        clear(); } } )
      .setParent(grabber)
      .alignRight()
      ;
    panel.setParent(grabber).stackDown();
    addShelf()
      //.addDrawer(10, 0)
      ;
  } 
  nSimplePanel clear() { 
    runEvents(eventCloseRun); 
    super.clear(); return this; }
  nSimplePanel updateHeight() { 
    super.updateHeight(); return this; }
  nSimplePanel updateWidth() { 
    super.updateWidth(); grabber.setSX(max(ref_size * 1.5, panel.getLocalSX())); 
    return this; }
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
    boolean p = collapsed;
    collapsed = false;
    if (task.hide) task.reduc();
    grabber.show(); 
    if (taskpanel_button != null) taskpanel_button.setStandbyColor(color(70)); 
    if (p) toLayerTop();
    if (p) runEvents(eventCollapseRun);
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
  
  nFrontTab toLayerTop() { 
    super.toLayerTop(); 
    
    return this;
  }
  nFrontTab show() {
    panel.show();
    front.grabber.setSX(panel.getLocalSX()); 
    toLayerTop();
    return this; }
  
  nFrontTab hide() {
    panel.hide();
    
    return this; }
  
  nFrontPanel front;
  String name;
  nWidget tabbutton;
  int id = 0;
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
  
  ArrayList<Runnable> eventTab = new ArrayList<Runnable>();
  nFrontPanel addEventTab(Runnable r)       { eventTab.add(r); return this; }
  
  nFrontPanel setNonClosable() { closer.setText("").setBackground(); return this; }
  nFrontTab getTab(int n) { return tabs.get(n); }
  ArrayList<nFrontTab> tabs = new ArrayList<nFrontTab>();
  ArrayList<nWidget> tab_widgets = new ArrayList<nWidget>();
  nFrontTab current_tab;
  int current_tab_id = 0;
  nFrontTab addTab(String n) {
    nFrontTab tab = new nFrontTab(this, n);
    tab.id = tabs.size();
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
        current_tab.toLayerTop();
        current_tab_id = current_tab.id;
        runEvents(current_tab.eventOpen);
        runEvents(eventTab);
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
    
    for (nFrontTab ot : tabs) ot.hide();
    tab.show();
    return tab;
  }
  
  nFrontPanel(nGUI _g, nTaskPanel _task, String _name) { 
    super(_g, _task, _name); 
    panel.setSY(0).setOutline(false);
    gui.addEventSetup(new Runnable() { public void run() {
      if (tab_widgets.size() > 0) tab_widgets.get(0).setOn();
    } });
  } 
  void setTab(int i) { 
    if (!collapsed && i < tab_widgets.size()) tab_widgets.get(i).setOn();
  }
  void collapse() { 
    super.collapse(); 
  }
  void popUp() { 
    boolean p = collapsed;
    super.popUp(); 
    for (nFrontTab t : tabs) t.hide();
    if (current_tab != null) {
      current_tab.show();
      if (p) runEvents(current_tab.eventOpen); 
    }
  }
  nFrontPanel toLayerTop() { 
    super.toLayerTop(); 
    for (nFrontTab d : tabs) d.toLayerTop(); 
    return this;
  }
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









   
