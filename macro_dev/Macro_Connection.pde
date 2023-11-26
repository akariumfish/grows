







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



class Macro_Sheet_Input {
  Macro_Sheet sheet,parent;
  Macro_Input in = null;
  Macro_Output out = null;
  nWidget grabber;
  
  float enlarged_pos = 0;
  float reduc_pos = 0;
  
  Macro_Sheet_Input(nGUI _gui, Macro_Sheet _parent, Macro_Sheet _sheet) {
    gui = _gui;
    parent = _parent;
    sheet = _sheet;
    
    reduc_pos = sheet.macro_size / 8 + sheet.sheet_inCount * sheet.macro_size * 1.125;
    enlarged_pos = reduc_pos;
    sheet.sheet_inputs.add(this);
    sheet.sheet_inCount++;
    
    grabber = new nWidget(gui, 0, reduc_pos, sheet.macro_size * 0.75, sheet.macro_size)
      .setParent(sheet.inputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      ;
    if (parent == null) grabber.setPX(-sheet.macro_size);
    out = new Macro_Output(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer+3)
      ;
    out.connect.stackRight();
    
    if (parent != null) {
      in = new Macro_Input(gui, parent, 0, 0 )
        .setParent(grabber)
        .setLayer(sheet.layer)
        ;
      in.connect.stackLeft();
      sheet.extinputs.add(in);
      in.direct_connect(out);
    }
  }
  void reduc() {
    grabber.setPY(reduc_pos)
      .hide();
    out.hide();
    if (in != null) in.show();
  }
  void enlarg() {
    grabber.setPY(enlarged_pos)
      .show();
    out.show();
  }
  void hide() {
    grabber.hide();
  }
  void show() {
    grabber.show();
  }
  void clear() {
    sheet.extinputs.remove(in);
    sheet.sheet_inCount--;
    sheet.sheet_inputs.remove(this);
    if (in != null) in.clear();
    out.clear();
    grabber.clear();
  }
  void to_string(String[] s, int id) {
    s[id] = str(enlarged_pos);
    s[id+1] = str(reduc_pos);
    log("to string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  void from_string(String[] s, int id) {
    enlarged_pos = float(s[id]);
    reduc_pos = float(s[id+1]);
    log("from string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  int size() { return 2; }
  
  Macro_Sheet_Input setLayer(int l) {
    grabber.setLayer(l);
    if (in != null) in.setLayer(l-2);
    out.setLayer(l);
    return this;
  }
  
  void toLayerTop() {
    grabber.toLayerTop();
    if (in != null) in.toLayerTop();
    out.toLayerTop();
  }
  
}



class Macro_Sheet_Output {
  Macro_Sheet sheet,parent;
  Macro_Input in = null;
  Macro_Output out = null;
  nWidget grabber;
  
  float enlarged_pos = 0;
  float reduc_pos = 0;
  
  Macro_Sheet_Output(nGUI _gui, Macro_Sheet _parent, Macro_Sheet _sheet) {
    gui = _gui;
    parent = _parent;
    sheet = _sheet;
    
    reduc_pos = sheet.macro_size / 8 + sheet.sheet_outCount * sheet.macro_size * 1.125;
    enlarged_pos = reduc_pos;
    sheet.sheet_outputs.add(this);
    sheet.sheet_outCount++;
    
    grabber = new nWidget(gui, -sheet.macro_size * 0.75, reduc_pos, sheet.macro_size * 0.75, sheet.macro_size)
      .setParent(sheet.outputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      ;
    if (parent == null) grabber.setPX(sheet.macro_size * 0.25);
    if (parent != null) {
      out = new Macro_Output(gui, parent, 0, 0 )
        .setParent(grabber)
        .setLayer(sheet.layer+2)
        ;
      out.connect.stackRight();
      sheet.extoutputs.add(out);
    }
    
    in = new Macro_Input(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer)
      ;
    in.connect.stackLeft();
    in.direct_connect(out);
    
  }
  void reduc() {
    grabber.setPY(reduc_pos)
      .hide();
    in.hide();
    if (out != null) out.show();
  }
  void enlarg() {
    grabber.setPY(enlarged_pos)
      .show();
    in.show();
  }
  void hide() {
    grabber.hide();
  }
  void show() {
    grabber.show();
  }
  void clear() {
    sheet.extoutputs.remove(in);
    sheet.sheet_outCount--;
    sheet.sheet_outputs.remove(this);
    in.clear();
    if (out != null) out.clear();
    grabber.clear();
  }
  void to_string(String[] s, int id) {
    s[id] = str(enlarged_pos);
    s[id+1] = str(reduc_pos);
    log("to string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  void from_string(String[] s, int id) {
    enlarged_pos = float(s[id]);
    reduc_pos = float(s[id+1]);
    log("from string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  int size() { return 2; }
  
  Macro_Sheet_Output setLayer(int l) {
    grabber.setLayer(l);
    in.setLayer(l);
    if (out != null) out.setLayer(l-2);
    return this;
  }
  
  void toLayerTop() {
    grabber.toLayerTop();
    in.toLayerTop();
    if (out != null) out.toLayerTop();
  }
  
}






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
  Macro_Sheet macro;
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
  
  Macro_Output toLayerTop() {
    line_drawer.toLayerTop();
    connect.toLayerTop();
    return this;
  }
  
  Macro_Output(nGUI _gui, Macro_Sheet _s, float x, float y) {
    
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
      .setOutlineWeight(macro.macro_size/6)
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
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
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
  float getSize() { return connect.getSX() / 1.6; }
  Macro_Abstract getMacro() { return macro; }
  
  Macro_Output setParent(nWidget w) { connect.setParent(w); return this; }
  
  void send(Macro_Packet p) {
    sending = true;
    hasSend = 5;
    for (Macro_Input m : connected_inputs) m.receive(p);
  }
  
}







class Macro_Input {
  Macro_Sheet macro;
  nWidget connect;
  ArrayList<Macro_Output> connected_outputs = new ArrayList<Macro_Output>();
  int index = -1;
  Macro_Input(nGUI _gui, Macro_Sheet _s, float x, float y) {
    macro = _s;
    index = macro.getFreeInputIndex();
    macro.inputs.add(this);
    connect = new nWidget(_gui, x, y, macro.macro_size, macro.macro_size)
      .setLayer(macro.layer)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)      { fill(connect.clickedColor); } 
        else if (connect.isHovered) { fill(connect.hoveredColor); } 
        else                        { fill(connect.standbyColor); }
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        noStroke();
        fill(0);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
        if (DEBUG) {
          fill(255);
          textFont(getFont(int(macro.macro_size/4)));
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
  Macro_Input toLayerTop() {
    connect.toLayerTop();
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
