







/*
objets des connection in et out linkable
objet out 
  cree et affiche les links
  envois les packet
  
objet in
  peut register des runnable a exec quand un packet est recus

objet packet : est transporté
    string definition plus array de string
*/






Macro_Packet newBang() { return new Macro_Packet("bang"); }
Macro_Packet newFloat(float f) { return new Macro_Packet("float").addMsg(str(f)); }
Macro_Packet newFloat(String f) { return new Macro_Packet("float").addMsg(f); }

class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  Macro_Packet addMsg(String m) { messages.add(m); return this; }
  boolean isBang() { return def.equals("bang"); }
  boolean isFloat() { return def.equals("float"); }
  float asFloat() { return float(messages.get(0)); }
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
  
  Macro_Output setLayer(int l) {
    line_drawer.setLayer(l + 1);
    connect.setLayer(l);
    return this;
  }
  
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
        if (DEBUG) {
          fill(255);
          textFont(getFont(6));
          text(""+index, connect.getX()+20, connect.getY()+6);
        }
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
  
  void hide() { connect.hide(); line_drawer.active = false; }
  void show() { connect.show(); line_drawer.active = true; }
  
  void connect_to(Macro_Input m) {
    connected_inputs.add(m);
    m.connected_outputs.add(this); }
  void disconnect_from(Macro_Input m) {
    connected_inputs.remove(m);
    m.connected_outputs.remove(this); }
  
  void to_string(String[] s, int id) {
    s[id] = str(index);
    log("to string output " + id + " index " + s[id]);
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
    log("from string output " + id + " index " + s[id]);
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
        if (DEBUG) {
          fill(255);
          textFont(getFont(6));
          text(""+index, connect.getX()-5, connect.getY()+6);
        }
      } } )
      .setTrigger()
      ;
    
  }
  Macro_Input setLayer(int l) {
    connect.setLayer(l);
    return this;
  }
  void hide() { connect.hide(); }
  void show() { connect.show(); }
  void to_string(String[] s, int id) {
    s[id] = str(index);
    log("to string input " + id + " index " + s[id]);
    
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
    log("from string input " + id + " index " + s[id]);
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
