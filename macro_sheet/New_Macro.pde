






nGUI gui = new nGUI();

Ticking_pile tickpile = new Ticking_pile();

Macro_Main ms;

Macro_Output o;
Macro_Input i;

void mysetup() {
  ms = new Macro_Main(gui, tickpile, 20, 20);
  //ms.addDelay();
}


void mydraw() {
  gui.update();
  
  tickpile.tick();
  
  if (kb.mouseClick[0]) {
    //o.send( new Macro_Packet("test").addMsg("val") );
  }
  
  // apply camera view
  cam.pushCam();
  
  gui.draw();
  
  cam.popCam();
  
}





class Macro_Output {
  Macro_Abstract macro;
  Drawer line_drawer;
  nWidget connect;
  
  boolean buildingLine = false;
  PVector newLine = new PVector();
  
  ArrayList<Macro_Input> connected_inputs = new ArrayList<Macro_Input>();
  
  boolean sending = false;
  int hasSend = 0;
  
  int index = -1;
  
  Macro_Output(nGUI _gui, Macro_Abstract _s, float x, float y) {
    
    macro = _s;
    index = macro.getFreeOutputIndex();
    macro.outputs.add(this);
    
    line_drawer = new Drawer(_gui.drawing_pile, macro.layer + 1) { public void drawing() {
      if (buildingLine) {
        stroke(connect.outlineColor);
        strokeWeight(connect.outlineWeight);
        line(getCenterX(), getCenterY(), 
             newLine.x, newLine.y);
        fill(255);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                getSize(), getSize() );
        fill(0);
        ellipse(newLine.x, newLine.y, 
                getSize(), getSize() );
      }
      for (Macro_Input m : connected_inputs) {
        if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
            getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight ) 
          { fill(connect.selectedColor); stroke(connect.selectedColor); }
        else if (sending || hasSend > 0)
          { fill(connect.outlineColor); stroke(connect.outlineColor); }
        else { fill(color(255, 120)); stroke(color(255, 120)); }
        strokeWeight(connect.outlineWeight);
        line(getCenterX(), getCenterY(), 
             m.getCenterX(), m.getCenterY());
        ellipseMode(CENTER);
        fill(0);
        ellipse(m.getCenterX(), m.getCenterY(), 
                getSize(), getSize() );
        fill(255);
        ellipse(getCenterX(), getCenterY(), 
                getSize(), getSize() );
      }
      if (hasSend > 0) hasSend--;
    } };
    
    connect = new nWidget(_gui, x, y, macro.macro_size, macro.macro_size)
      {
        public void customVisibilityChange() {
          if (connect.isHided()) line_drawer.active = false;
          else line_drawer.active = true;
        }
      }
      .setTrigger()
      .setLayer(macro.layer)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)                     { fill(connect.clickedColor); } 
        else if (connect.isHovered || hasSend > 0) { fill(connect.hoveredColor); } 
        else                                       { fill(connect.standbyColor); }
        //stroke(connect.outlineColor);
        //strokeWeight(connect.outlineWeight);
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        
        fill(255);
        noStroke();
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.7, connect.getSY() / 1.7 );
        //fill(255);
        //textFont(getFont(6));
        //text(""+index, connect.getX()+20, connect.getY()+6);
      } } )
      .addEventPress(new Runnable() { public void run() {
        buildingLine = true;
      } } )
      .addEventFrame(new Runnable(this) { public void run() {
        sending = false;
        if (buildingLine) {
          newLine.x = cam.getCamMouse().x;
          newLine.y = cam.getCamMouse().y;
          if (kb.mouseClick[1]) buildingLine = false;
          if (kb.mouseClick[0]) {
            for (Macro_Input m : macro.inputs) {
              boolean found = false;
              for (Macro_Input n : connected_inputs)
                if (m == n) found = true;
              if (!found && m.connect.isHovered()) {
                connect_to(m);
                buildingLine = false;
                break;
              }
            }
          }
        }
        if (kb.mouseClick[1]) for (Macro_Input m : connected_inputs) {
          if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
              getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight) {
            disconnect_from(m);
            break;
          }
        }
      } } )
      ;
  }
  void connect_to(Macro_Input m) {
    connected_inputs.add(m);
    m.connected_outputs.add(this); }
  void disconnect_from(Macro_Input m) {
    connected_inputs.remove(m);
    m.connected_outputs.remove(this); }
  
  void to_string(String[] s, int id) {
    s[id] = str(index);
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
  }
  int size() { return 1; }
  void clear() {
    connect.clear();
    line_drawer.clear();
    macro.outputs.remove(this);
    for (Macro_Input m : connected_inputs) m.connected_outputs.remove(this);
    connected_inputs.clear();
  }
  
  float getCenterX() { return connect.getX() + connect.getSX() / 2; }
  float getCenterY() { return connect.getY() + connect.getSY() / 2; }
  float getSize() { return connect.getSX() / 1.4; }
  Macro_Abstract getMacro() { return macro; }
  
  Macro_Output setParent(nWidget w) { connect.setParent(w); return this; }
  
  void send(Macro_Packet p) {
    sending = true;
    hasSend = 5;
    for (Macro_Input m : connected_inputs) m.receive(p);
  }
  
}




class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  Macro_Packet addMsg(String m) { messages.add(m); return this; }
}




class Macro_Input {
  Macro_Abstract macro;
  nWidget connect;
  ArrayList<Macro_Output> connected_outputs = new ArrayList<Macro_Output>();
  int index = -1;
  Macro_Input(nGUI _gui, Macro_Abstract _s, float x, float y) {
    macro = _s;
    index = macro.getFreeInputIndex();
    macro.inputs.add(this);
    connect = new nWidget(_gui, x, y, macro.macro_size, macro.macro_size)
      .setLayer(macro.layer)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)      { fill(connect.clickedColor); } 
        else if (connect.isHovered) { fill(connect.hoveredColor); } 
        else                        { fill(connect.standbyColor); }
        //stroke(connect.outlineColor);
        //strokeWeight(connect.outlineWeight);
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        noStroke();
        fill(0);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.7, connect.getSY() / 1.7 );
        //fill(255);
        //textFont(getFont(6));
        //text(""+index, connect.getX()-5, connect.getY()+6);
      } } )
      .setTrigger()
      ;
    
  }
  void to_string(String[] s, int id) {
    s[id] = str(index);
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
  }
  int size() { return 1; }
  void clear() {
    connect.clear();
    macro.inputs.remove(this);
    for (Macro_Output m : connected_outputs) m.connected_inputs.remove(this);
  }
  
  Macro_Input setParent(nWidget w) { connect.setParent(w); return this; }
  
  float getCenterX() { return connect.getX() + connect.getSX() / 2; }
  float getCenterY() { return connect.getY() + connect.getSY() / 2; }
  Macro_Abstract getMacro() { return macro; }
  
  Macro_Packet last_packet = null;
  
  Macro_Packet getLastPacket() { return last_packet; }
  
  void receive(Macro_Packet p) {
    last_packet = p;
    for (Runnable r : eventReceiveRun) r.run();
    if (direct_out != null) direct_out.send(p);
  }
  
  ArrayList<Runnable> eventReceiveRun = new ArrayList<Runnable>();
  Macro_Input addEventReceive(Runnable r)    { eventReceiveRun.add(r); return this; }
  Macro_Input removeEventReceive(Runnable r) { eventReceiveRun.remove(r); return this; }
  
  Macro_Output direct_out = null;
  void direct_connect(Macro_Output o) { direct_out = o; }
}










abstract class Macro_Abstract {
  
  ArrayList<Macro_Input> extinputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> extoutputs = new ArrayList<Macro_Output>(0);
  
  ArrayList<Macro_Input> inputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> outputs = new ArrayList<Macro_Output>(0);
  
  Macro_Abstract parent;
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  
  nGUI gui;
  
  float macro_size = 15;
  int layer = 0;
  nWidget grabber, inputs_ref, outputs_ref, panel, back, closer;
  
  float sheet_width = macro_size;
  String name = null;
  
  Macro_Abstract(nGUI _gui, Macro_Abstract p, String n, float x, float y) {
    gui = _gui;
    parent = p;
    name = n;
    if (parent != null) parent.child_macro.add(this);
    
    grabber = new nWidget(gui, name, int(macro_size/1.5), x, y, sheet_width - macro_size * 0.75, macro_size * 0.75)
      .setLayer(layer)
      .addEventDrag(new Runnable() { public void run() { if (parent != null) parent.childDragged(); } } )
      .setGrabbable()
      ;
    if (parent != null) grabber.setParent(parent.grabber);
    closer = new nWidget(gui, "X", int(macro_size/1.5), 0, 0, macro_size * 0.75, macro_size * 0.75)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { clear(); } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(layer)
      ;
    inputs_ref = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .stackDown()
      ;
    outputs_ref = new nWidget(gui, -macro_size, 0)
      .setParent(closer)
      .stackRight()
      .stackDown()
      ;
    back = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .setStandbyColor(color(180, 80))
      //.stackDown()
      ;
    panel = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .stackDown()
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
    
    //opener = new nWidget(gui, "-", 24, 0, 0, macro_size, macro_size)
    //  .addEventTrigger(new Runnable() { public void run() {
    //    //if (ref.hide) ref.show(); else ref.hide(); 
    //    //if (pan.hide) pan.show(); else pan.hide(); 
    //  } } )
    //  .setParent(grabber)
    //  .stackDown()
    //  .setTrigger()
    //  .setLayer(layer)
    //  ;
  }
  void setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l);
    for (Macro_Input m : extinputs) m.connect.setLayer(l);
    for (Macro_Output m : extoutputs) { m.connect.setLayer(l); m.line_drawer.setLayer(l+1); }
  }
  void toLayerTop() {
    back.toLayerTop();
    for (Macro_Input m : extinputs) m.connect.toLayerTop();
    for (Macro_Output m : extoutputs) { m.connect.toLayerTop(); m.line_drawer.toLayerTop(); }
    grabber.toLayerTop();
    closer.toLayerTop();
  }
  
  Macro_Input getInputByIndex(int i) {
    for (Macro_Input m : inputs) if (m.index == i) return m;
    return null; }
  Macro_Output getOutputByIndex(int i) {
    for (Macro_Output m : outputs) if (m.index == i) return m;
    return null; }
    
  int getFreeInputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Input m : inputs) if (m.index == i) i++;
      if (t == i) found = true; }
    return i; }
  
  int getFreeOutputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Output m : outputs) if (m.index == i) i++;
      if (t == i) found = true; }
    return i; }
  
  void to_string(String[] s, int id) {
    s[id] = name.substring(0, name.length());
    s[id+1] = str(grabber.getLocalX());
    s[id+2] = str(grabber.getLocalY());
    s[id+3] = str(sheet_width);
    id+=4;
    
    int vnb = 0;
    for (Macro_Input v : extinputs) vnb += v.size();
    s[id] = str(vnb);
    id++;
    for (Macro_Input v : extinputs) {
      v.to_string(s, id);
      id += v.size(); }
      
    vnb = 0;
    for (Macro_Output v : extoutputs) vnb += v.size();
    s[id] = str(vnb);
    id++;
    for (Macro_Output v : extoutputs) {
      v.to_string(s, id);
      id += v.size(); }
  }
  void from_string(String[] s, int id) {
    grabber.setText(s[id])
      .setPX(float(s[id+1]))
      .setPY(float(s[id+2]));
    setWidth(float(s[id+3]));
    id+=4;
    int l = int(s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Input m = extinputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Output m = extoutputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
  }
  int size() {
    int vnb = 6;
    for (Macro_Input v : extinputs) vnb += v.size();
    for (Macro_Output v : extoutputs) vnb += v.size();
    return vnb;
  }
  void clear() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    for (int i = inputs.size() - 1 ; i >= 0 ; i--) inputs.get(i).clear(); inputs.clear();
    for (int i = outputs.size() - 1 ; i >= 0 ; i--) outputs.get(i).clear(); outputs.clear();
    for (Macro_Input m : extinputs) m.clear(); extinputs.clear();
    for (Macro_Output m : extoutputs) m.clear(); extoutputs.clear();
    if (parent != null) parent.child_macro.remove(this);
    grabber.clear(); inputs_ref.clear(); outputs_ref.clear(); 
    panel.clear(); back.clear(); closer.clear();
    parent.childDragged();
  }
  
  Macro_Abstract setWidth(float w) {
    sheet_width = w;
    if (inCount > 1) w += macro_size;
    if (outCount > 1) w += macro_size;
    grabber.setSX(w - macro_size * 0.75);
    back.setSX(w);
    return this;
  }
  
  float getW() {
    return back.getSX(); }
  float getH() {
    return back.getSY(); }
  
  abstract void childDragged();
  
  void up_back() {
    int h = max(inCount, outCount);
    back.setSY(h * macro_size * 1.25 + macro_size * 0.75);
    if (inCount > 0) panel.setPX(macro_size + macro_size / 8);
  }
  
  int inCount = 0;
  int outCount = 0;
  
  Macro_Input addExtInput() {
    Macro_Input m = new Macro_Input(gui, parent, 0, inCount * macro_size * 1.25 + macro_size / 8 )
      .setParent(inputs_ref)
      ;
    extinputs.add(m);
    inCount++;
    up_back();
    return m;
  }
  
  Macro_Output addExtOutput() {
    Macro_Output m = new Macro_Output(gui, parent, 0, outCount * macro_size * 1.25 + macro_size / 8 )
      .setParent(outputs_ref)
      ;
    extoutputs.add(m);
    outCount++;
    up_back();
    return m;
  }
  
  Macro_Abstract addLine() { if (inCount >= outCount) inCount++; else outCount++; return this; }
  
  float getLastLineY() { 
    if (inCount >= outCount) return (inCount-1) * macro_size + macro_size / 8; 
    else                     return (outCount-1) * macro_size + macro_size / 8; 
  }
  
  Macro_Main getBase() { if (parent == null) return (Macro_Main)this; return parent.getBase(); }
  
}

class Macro_Sheet extends Macro_Abstract {
  nWidget menu,addSheet,addExtIn,addExtOut,addBang,addDelay,addPulse;
  Macro_Sheet(nGUI _gui, Macro_Abstract p, float x, float y) {
    super(_gui, p, "", x, y);
    setWidth(macro_size*1.75);
    
    back.setSize(macro_size*3, macro_size * 0.75);
    closer.setSX(macro_size);
    
    menu = new nWidget(_gui, "+", int(macro_size), 0, 0, macro_size, macro_size * 0.75)
      .setSwitch()
      .setParent(grabber)
      .setLayer(layer)
      .stackRight()
      .addEventSwitchOn(new Runnable() { public void run() {
        addSheet.show();
      }})
      .addEventSwitchOff(new Runnable() { public void run() {
        addSheet.hide();
      }})
      ;
    closer.setParent(menu);
    addSheet = new nWidget(_gui, "Sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(menu)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addSheet();
        childDragged();
      }})
      ;
    addExtIn = new nWidget(_gui, "Input", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addSheet)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable(this) { public void run() {
        menu.setOff();
        Macro_Output o = new Macro_Output(gui, (Macro_Abstract)builder, macro_size, inCount * macro_size * 1.25 + macro_size / 8 )
          .setParent(inputs_ref)
          ;
        Macro_Input i = addExtInput();
        i.direct_connect(o);
        childDragged();
      }})
      ;
    addExtOut = new nWidget(_gui, "Output", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addExtIn)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable(this) { public void run() {
        menu.setOff();
        Macro_Input i = new Macro_Input(gui, (Macro_Abstract)builder, -macro_size, outCount * macro_size * 1.25 + macro_size / 8 )
          .setParent(outputs_ref)
          ;
        Macro_Output o = addExtOutput();
        i.direct_connect(o);
        childDragged();
      }})
      ;
    addBang = new nWidget(_gui, "Bang", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addExtOut)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addBang();
        childDragged();
      }})
      ;
    addDelay = new nWidget(_gui, "Delay", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addBang)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addDelay();
        childDragged();
      }})
      ;
    addPulse = new nWidget(_gui, "Pulse", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addDelay)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        menu.setOff();
        addPulse();
        childDragged();
      }})
      ;
    //back.toLayerTop();
    childDragged();
  }
  void setLayer(int l) {
    super.setLayer(l);
    menu.setLayer(l);
    addSheet.setLayer(l);
    addExtIn.setLayer(l);
    addExtOut.setLayer(l);
    addBang.setLayer(l);
    addDelay.setLayer(l);
    addPulse.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    menu.toLayerTop();
    addSheet.toLayerTop();
    addExtIn.toLayerTop();
    addExtOut.toLayerTop();
    addBang.toLayerTop();
    addDelay.toLayerTop();
    addPulse.toLayerTop();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = str(child_macro.size());
    id++;
    for (Macro_Abstract v : child_macro) {
      v.to_string(s, id);
      id += v.size();
    }
    int l = 0;
    for (Macro_Output o : extoutputs) l++;
    s[id] = str(l);
    id++;
    l = 0;
    for (Macro_Input o : extinputs) l++;
    s[id] = str(l);
    id++;
    l = 0;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) l++;
    s[id] = str(l);
    id++;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
      s[id] = str(o.index); s[id+1] = str(i.index); id +=2;
    }
  }
  void from_string(String[] s, int id) {
    int start_id = id;
    id += super.size();
    int l = int(s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Abstract m = null;
      if      (s[id].equals("bang"))  m = new Macro_Bang(gui, this, 0, 0);
      else if (s[id].equals("delay")) m = new Macro_Delay(gui, this, 0, 0);
      else if (s[id].equals("pulse")) m = new Macro_Pulse(gui, this, 0, 0);
      else                            m = new Macro_Sheet(gui, this, 0, 0);
      m.setLayer(layer+2);
      m.toLayerTop();
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Output o = new Macro_Output(gui, this, macro_size, inCount * macro_size * 1.25 + macro_size / 8 )
        .setParent(inputs_ref)
        ;
      addExtInput().direct_connect(o);
      childDragged();
    }
    l = int(s[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      Macro_Input in = new Macro_Input(gui, this, -macro_size, outCount * macro_size * 1.25 + macro_size / 8 )
        .setParent(outputs_ref)
        ;
      Macro_Output o = addExtOutput();
      in.direct_connect(o);
      childDragged();
    }
    l = int(s[id]);
    id++;
    super.from_string(s, start_id);
    for (int i = 0 ; i < l ; i++) {
      getOutputByIndex(int(s[id])).connect_to(getInputByIndex(int(s[id+1])));
      id+=2;
    }
    childDragged();
  }
  int size() {
    int vnb = super.size() + 4;
    for (Macro_Abstract v : child_macro) vnb += v.size();
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) vnb+=2;
    return vnb;
  }
  void clear() {
    super.clear();
    menu.clear(); addSheet.clear(); addExtIn.clear(); addExtOut.clear(); 
    addBang.clear(); addDelay.clear(); addPulse.clear();
  }
  void childDragged() {
    float minx = 0, miny = 0, maxx = macro_size*3, maxy = macro_size*0.75;
    for (Macro_Abstract m : child_macro) {
      if (minx > m.grabber.getLocalX() + m.back.getLocalX()) 
        minx = m.grabber.getLocalX() + m.back.getLocalX();
      if (miny > m.grabber.getLocalY() + m.back.getLocalY()) 
        miny = m.grabber.getLocalY() + m.back.getLocalY();
      if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.getW()) 
        maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.getW();
      if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.getH()) 
        maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.getH();
    }
    if (maxy < max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75)
      maxy = max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75;
    back.setPosition(minx - macro_size, miny - macro_size);
    back.setSize(maxx - minx + macro_size*2, maxy - miny + macro_size*2);
    inputs_ref.setPX(minx - macro_size*2);
    outputs_ref.setPX(maxx - macro_size*2);
    if (parent != null) parent.childDragged();
  }
  float add_pos = macro_size;
  Macro_Sheet addSheet() {
    Macro_Sheet m = new Macro_Sheet(gui, this, macro_size*6.5 + add_pos, add_pos);
    m.setLayer(layer+2);
    m.toLayerTop();
    add_pos += macro_size / 2;
    if (add_pos > macro_size * 3) add_pos = macro_size;
    return m; }
  Macro_Delay addDelay() {
    Macro_Delay m = new Macro_Delay(gui, this, macro_size*6.5 + add_pos, add_pos);
    m.setLayer(layer+2);
    m.toLayerTop();
    add_pos += macro_size / 2;
    if (add_pos > macro_size * 3) add_pos = macro_size;
    return m; }
  Macro_Bang addBang() {
    Macro_Bang m = new Macro_Bang(gui, this, macro_size*6.5 + add_pos, add_pos);
    add_pos += macro_size / 2;
    m.setLayer(layer+2);
    m.toLayerTop();
    if (add_pos > macro_size * 3) add_pos = macro_size;
    return m; }
  Macro_Pulse addPulse() {
    Macro_Pulse m = new Macro_Pulse(gui, this, macro_size*6.5 + add_pos, add_pos);
    add_pos += macro_size / 2;
    m.setLayer(layer+2);
    m.toLayerTop();
    if (add_pos > macro_size * 3) add_pos = macro_size;
    return m; }
}

class Macro_Main extends Macro_Sheet {
  Ticking_pile tickpile;
  nWidget smenu,sfield,ssave,sload;
  String savepath = "save.txt";
  Macro_Main(nGUI _gui, Ticking_pile t, float x, float y) {
    super(_gui, null, x, y);
    tickpile = t;
    closer.hide();
    
    smenu = new nWidget(_gui, "S", int(macro_size/1.5), 0, 0, macro_size, macro_size * 0.75)
      .setSwitch()
      .setParent(menu)
      .setLayer(layer)
      .stackRight()
      .addExclude(menu)
      .addEventSwitchOn(new Runnable() { public void run() {
        sfield.show();
      }})
      .addEventSwitchOff(new Runnable() { public void run() {
        sfield.hide();
      }})
      ;
    menu.addExclude(smenu);
    
    sfield = new nWidget(_gui, 0, 0, macro_size*5, macro_size)
      .setParent(smenu)
      .stackDown()
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText(savepath)
      .setField(true)
      .hide()
      .addEventFieldChange(new Runnable() { public void run() {
        savepath = sfield.getText();
      }})
      ;
    ssave = new nWidget(_gui, "save", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sfield)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_save();
        smenu.setOff();
      }})
      ;
    sload = new nWidget(_gui, "load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(ssave)
      .setLayer(layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_load();
        childDragged();
        smenu.setOff();
      }})
      ;
    //back.toLayerTop();
    toLayerTop();
    addBang.setParent(addSheet);
    addExtOut.clear();
    addExtIn.clear();
  }
  void clear() {
    empty();
    super.clear();
    smenu.clear(); sfield.clear(); ssave.clear(); sload.clear(); 
  }
  
  void empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    for (Macro_Input m : inputs) m.clear(); 
    inputs.clear();
    for (Macro_Output m : outputs) m.clear(); 
    outputs.clear();
  }
  
  int size() {
    int vnb = 2;
    for (Macro_Abstract v : child_macro) vnb += v.size();
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) vnb+=2;
    return vnb;
  }
  
  void toLayerTop() {
    super.toLayerTop();
    smenu.toLayerTop();
    sfield.toLayerTop();
    ssave.toLayerTop();
    sload.toLayerTop();
  }
  void do_save() {
    String[] sl = new String[size()];
    int id = 0;
    sl[0] = str(child_macro.size());
    id++;
    for (Macro_Abstract v : child_macro) {
      v.to_string(sl, id);
      id += v.size();
    }
    int l = 0;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) l++;
    sl[id] = str(l);
    id++;
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
      sl[id] = str(o.index); sl[id+1] = str(i.index); id +=2;
    }
    saveStrings(savepath, sl);
  }
  
  void do_load() {
    empty();
    String[] sl = loadStrings(savepath);
    int id = 1;
    for (int i = 0; i < int(sl[0]) ; i++) {
      Macro_Abstract m = null;
      if      (sl[id].equals("bang"))  m = new Macro_Bang(gui, this, 0, 0);
      else if (sl[id].equals("delay")) m = new Macro_Delay(gui, this, 0, 0);
      else if (sl[id].equals("pulse")) m = new Macro_Pulse(gui, this, 0, 0);
      else                             m = new Macro_Sheet(gui, this, 0, 0);
      m.setLayer(layer+2);
      m.toLayerTop();
      m.from_string(sl, id);
      id += m.size();
    }
    int l = int(sl[id]);
    id++;
    for (int i = 0 ; i < l ; i++) {
      getOutputByIndex(int(sl[id])).connect_to(getInputByIndex(int(sl[id+1])));
      id+=2;
    }
  }
}

class Macro_Bang extends Macro_Abstract {
  Macro_Output out;
  nWidget button;
  Macro_Bang(nGUI _gui, Macro_Abstract p, float x, float y) {
    super(_gui, p, "bang", x, y);
    setWidth(macro_size*3.5);
    button = new nWidget(_gui, macro_size / 4, macro_size / 8, macro_size*2, macro_size)
      .setTrigger()
      .setParent(panel)
      .setLayer(layer)
      .stackDown()
      .addEventTrigger(new Runnable() { public void run() {
        out.send(new Macro_Packet("bang"));
      }})
      ;
    out = addExtOutput();
    toLayerTop();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = "bang";
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void toLayerTop() {
    super.toLayerTop();
    button.toLayerTop();
  }
}

class Macro_Pulse extends Macro_Abstract {
  Macro_Output out;
  nWidget time_field;
  Tickable tick;
  int time = 20;
  int count = 0;
  Macro_Pulse(nGUI _gui, Macro_Abstract p, float x, float y) {
    super(_gui, p, "pulse", x, y);
    setWidth(macro_size*4.5);
    time_field = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*3, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText(str(time))
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        String s = time_field.getText();
        
        time = max(1, int(s));
        count = time;
      }})
      ;
    out = addExtOutput();
    tick = new Tickable(getBase().tickpile) { public void tick(float t) {
        if (count > 0) { 
          count--; 
          if (count == 0) { count = time; out.send(new Macro_Packet("bang")); }
        }
      } }
      .setLayer(0)
      ;
    count = time;
    toLayerTop();
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = str(time);
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    time = int(s[id]);
    time_field.setText(str(time));
    count = time;
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void toLayerTop() {
    super.toLayerTop();
    time_field.toLayerTop();
  }
}

class Macro_Delay extends Macro_Abstract {
  Macro_Input in;
  Macro_Output out;
  nWidget time_field;
  Tickable tick;
  Macro_Packet pack;
  int time = 1;
  int count = 0;
  
  Macro_Delay(nGUI _gui, Macro_Abstract p, float x, float y) {
    super(_gui, p, "delay", x, y);
    setWidth(macro_size*5.5);
    time_field = new nWidget(_gui, macro_size / 8, macro_size / 8, macro_size*3, macro_size)
      .setParent(panel)
      .setLayer(layer)
      .setFont(int(macro_size/1.5))
      .setText(str(time))
      .setField(true)
      .addEventFieldChange(new Runnable() { public void run() {
        String s = time_field.getText();
        time = max(1, int(s));
        count = 0;
      }})
      ;
    out = addExtOutput();
    in = addExtInput()
      .addEventReceive(new Runnable() { public void run() {
        pack = in.getLastPacket();
        count = time;
      }})
      ;
    tick = new Tickable(getBase().tickpile) { public void tick(float time) {
        if (count > 0) { count--; if (count == 0) out.send(pack); }
      } }
      .setLayer(0)
      ;
    toLayerTop();
  }
  void clear() {
    super.clear();
    tick.clear();
  }
  void to_string(String[] s, int id) {
    super.to_string(s, id);
    id += super.size();
    s[id] = str(time);
  }
  void from_string(String[] s, int id) {
    super.from_string(s, id);
    id += super.size();
    time = int(s[id]);
    time_field.setText(str(time));
    count = 0;
  }
  int size() { return 1 + super.size(); }
  void childDragged() {}
  void toLayerTop() {
    super.toLayerTop();
    time_field.toLayerTop();
  }
}

/*

Basic Macro:    deja fait.
  Pulse
  MacroVAL
  MacroDELAY
  MacroCOMP
  MacroBOOL
  MacroCALC

nouvel objet macro, on peut y ajouté des entré/sortie customizable

MACROCustom
  addConnexion

Macro Custom Connexions:
  >MCListen(Channel) outB value
  >MCCall(Channel) inB value
  
  >MCsValueWatcher(sFlt) outF value
  >MCsValueWatcher(sBoo) outB value
  >MCsValueController(sFlt) inF value      BEUG!!!!
  >MCsValueController(sBoo) inB value
  
  >MCRun( code ) inB bang
  >MCKeyboard(key) outB bang
  
  MCsValueModifier(sFlt)
    inB bang, inF value, select : 'x' / '/' / '+' / '-'
  
*/


class Tickable {
  Ticking_pile pile = null;
  int layer;
  boolean active = true;
  Tickable() {}
  Tickable(Ticking_pile p) {
    layer = 0;
    pile = p;
    pile.tickables.add(this);
  }
  Tickable(Ticking_pile p, int l) {
    layer = l;
    pile = p;
    pile.tickables.add(this);
  }
  void clear() { if (pile != null) pile.tickables.remove(this); }
  Tickable setLayer(int l) {
    layer = l;
    return this;
  }
  void tick(float time) {}
}

class Ticking_pile {
  ArrayList<Tickable> tickables = new ArrayList<Tickable>();
  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;
  Ticking_pile() { }
  void tick() {
    current_time = millis();
    frame_length = current_time - prev_time;
    prev_time = current_time;
    int layer = 0;
    int run_count = 0;
    while (run_count < tickables.size()) {
      for (Tickable r : tickables) {
        if (r.layer == layer) {
          if (r.active) r.tick(frame_length);
          run_count++;
        }
      }
      layer++;
    }
  }
}
