

void mySetup() {
  new nPanel(gui, "", 100, 100);
}


class nPanel {
  nWidget grabber, back, closer;
  
  nGUI gui;
  
  int layer = 0;
  
  String name = null;
  
  float ref_size = 20;
  float sheet_width = ref_size*5;
  
  nPanel(nGUI _gui, String n, float x, float y) {
    gui = _gui;
    name = n;
    
    grabber = new nWidget(gui, name, int(ref_size/1.5), x, y, sheet_width - ref_size * 0.75, ref_size * 0.75)
      .setLayer(layer)
      .setGrabbable()
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      //.setField(true)
      ;
      
    closer = new nWidget(gui, "X", int(ref_size/1.5), 0, 0, ref_size * 0.75, ref_size * 0.75)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { clear(); } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(layer)
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      ;
    back = new nWidget(gui, 0, 0) {
      public void customShapeChange() {
        //front.setSize(back.getLocalSX(), back.getLocalSY());
      }
    }
      .setParent(grabber)
      .setLayer(layer)
      .setStandbyColor(color(180, 60))
      .setOutlineColor(color(180, 60))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
  }
  
  nPanel setPosition(float x, float y) {
    
    return this;
  }
  
  nPanel setWidth(float w) {
    
    return this;
  }
  nPanel setLayer(float l) {
    
    return this;
  }
  nPanel toLayerTop() {
    
    return this;
  }
  nPanel hide() {
    
    return this;
  }
  nPanel show() {
    
    return this;
  }
  nPanel reduc() {
    
    return this;
  }
  nPanel enlarge() {
    
    return this;
  }
  nPanel destroy() {
    
    return this;
  }
  nPanel to_save() {
    
    return this;
  }
  nPanel from_save() {
    
    return this;
  }
}
