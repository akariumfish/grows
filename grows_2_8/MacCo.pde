




Macro_Packet newPacketBang() { return new Macro_Packet("bang"); }

Macro_Packet newPacketFloat(float f) { return new Macro_Packet("float").addMsg(str(f)); }
Macro_Packet newPacketFloat(String f) { return new Macro_Packet("float").addMsg(f); }

Macro_Packet newPacketInt(int f) { return new Macro_Packet("int").addMsg(str(f)); }

Macro_Packet newPacketVec(PVector p) { return new Macro_Packet("vec").addMsg(str(p.x)).addMsg(str(p.y)); }

Macro_Packet newPacketBool(boolean b) { 
  String r; 
  if (b) r = "T"; else r = "F"; 
  return new Macro_Packet("bool").addMsg(r); }

class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  Macro_Packet addMsg(String m) { messages.add(m); return this; }
  
  boolean isBang()  { return def.equals("bang"); }
  boolean isFloat() { return def.equals("float"); }
  boolean isInt()   { return def.equals("int"); }
  boolean isBool()  { return def.equals("bool"); }
  boolean isVec()   { return def.equals("vec"); }
  
  PVector asVec()   { 
    if (isVec()) return new PVector(float(messages.get(0)), float(messages.get(1))); else return null; }
  float   asFloat()   { if (isFloat()) return float(messages.get(0)); else return 0; }
  int     asInt()   { if (isInt()) return int(messages.get(0)); else return 0; }
  boolean asBool()   {
    if (isBool() && messages.get(0).equals("T")) return true; else return false; }
    
  String getText() {
    if (isBang()) return "bang";
    else if (isFloat()) return trimStringFloat(asFloat());
    else if (isInt()) return str(asInt());
    else if (isBool() && messages.get(0).equals("T")) return "true";
    else if (isBool() && !messages.get(0).equals("T")) return "false";
    return "";
  }
}





/*
connexion 
 circle, hard outline, transparent, mode in or out, exist in a sheet, has an unique number
 has a label with no back for a short description and a field acsessible or not for displaying values
 the label and values are aligned, either of them can be on the left or right
 the connexion circle is on the left right top or down side center of
 the rectangle formed by the label and values
 priority button
 2 round button on top of eachother on left top corner of the connect
 1 round widget covering half of each button with the priority layer
 highlight connectable in when creating link
 package info on top of connections
 
 */
class Macro_Connexion extends nBuilder implements Macro_Interf {
  Macro_Element getElement() { return elem; }

  Macro_Connexion toLayerTop() { 
    super.toLayerTop(); 
    msg_view.toLayerTop(); 
    lens.toLayerTop(); 
    ref.toLayerTop();
    return this;
  }

  nWidget ref, lens, msg_view;
  Macro_Element elem; Macro_Sheet sheet;
  int type = INPUT;
  Macro_Connexion(Macro_Element _elem, Macro_Sheet _sheet, int _type, String _info) {
    super(_elem.gui, _elem.ref_size); 
    type = _type; elem = _elem; sheet = _sheet;
    lens = addModel("MC_Connect_In_Passif")
      .setSize(ref_size*14/16, ref_size*14/16)
      .setPosition(-ref_size*5/16, -ref_size*5/16)
      .addEventPress(new Runnable() { public void run() {
        if (type == OUTPUT) {
          buildingLine = true;
          for (Macro_Connexion i : sheet.child_connect) 
            if (i.type == INPUT) i.lens.setTrigger().setLook(gui.theme.getLook("MC_Connect_In_Actif")); 
            else if (i.type == OUTPUT) i.lens.setBackground()
              .setLook(gui.theme.getLook("MC_Connect_Out_Passif")); 
        }
      } } )
      .addEventFrame(new Runnable(this) { public void run() {
        sending = false;
        if (buildingLine) {
          newLine.x = elem.bloc.mmain().gui.mouseVector.x;
          newLine.y = elem.bloc.mmain().gui.mouseVector.y;
          if (elem.bloc.mmain().gui.in.getClick("MouseRight")) { 
            buildingLine = false; 
            for (Macro_Connexion i : sheet.child_connect) 
              if (i.type == INPUT) i.lens.setBackground().setLook(gui.theme.getLook("MC_Connect_In_Passif")); 
              else if (i.type == OUTPUT) i.lens.setTrigger()
                .setLook(gui.theme.getLook("MC_Connect_Out_Actif")); 
          }
          if (elem.bloc.mmain().gui.in.getClick("MouseLeft")) {
            boolean found = false;
            for (Macro_Connexion m : sheet.child_connect) if (m.type == INPUT) {
              for (Macro_Connexion n : connected_inputs)
                if (m == n) found = true;
              if (!found && m.lens.isHovered()) {
                connect_to(m);
                buildingLine = false;
                for (Macro_Connexion i : sheet.child_connect) 
                  if (i.type == INPUT) i.lens.setBackground().setLook(gui.theme.getLook("MC_Connect_In_Passif")); 
                  else if (i.type == OUTPUT) i.lens.setTrigger()
                    .setLook(gui.theme.getLook("MC_Connect_Out_Actif")); 
                found = true;
              }
            }
            if (!found && !lens.isHovered()) {
              buildingLine = false;
              for (Macro_Connexion i : sheet.child_connect) 
                if (i.type == INPUT) i.lens.setBackground().setLook(gui.theme.getLook("MC_Connect_In_Passif")); 
                else if (i.type == OUTPUT) i.lens.setTrigger()
                  .setLook(gui.theme.getLook("MC_Connect_Out_Actif")); 
            }
          }
        }
        if (elem.bloc.mmain().gui.in.getClick("MouseRight")) for (Macro_Connexion m : connected_inputs) {
          if (distancePointToLine(elem.bloc.mmain().gui.mouseVector.x, elem.bloc.mmain().gui.mouseVector.y, 
              getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < ref.look.outlineWeight) {
            disconnect_from(m);
            break;
          }
        }
      } } )
      ;
    ref = addModel("MC_Connect_Link")
      .setSize(ref_size*4/16, ref_size*4/16)
      .setPosition(-ref_size*6/16, ref_size*6/16)
      .setDrawable(new Drawable(gui.drawing_pile, 0) { 
      public void drawing() {
        if (lens.isClicked) fill(ref.look.pressColor);
        else if (lens.isHovered) fill(ref.look.hoveredColor);
        else fill(ref.look.standbyColor);
        noStroke(); ellipseMode(CORNER);
        ellipse(ref.getX(), ref.getY(), ref.getSX(), ref.getSY());
        if (lens.isClicked) stroke(ref.look.pressColor);
        else if (lens.isHovered) stroke(ref.look.hoveredColor);
        else noStroke();
        noFill(); strokeWeight(ref.look.outlineWeight);
        ellipse(ref.getX() - ref.look.outlineWeight, ref.getY() - ref.look.outlineWeight, 
          ref.getSX() + ref.look.outlineWeight * 2, ref.getSY() + ref.look.outlineWeight * 2);
          
        if (type == OUTPUT) fill(0); else fill(255);
        textFont(getFont(int(elem.bloc.ref_size/2.5)));
        textAlign(CENTER, CENTER);
        if (last_def != null) text(last_def, ref.getX()+ref.getSX()/2, ref.getY()+ref.getSY()/2);
        if (filter != null) text(filter, ref.getX()+ref.getSX()/2, ref.getY()+ref.getSY()/2);
        if (DEBUG) {
          fill(255);
          textFont(getFont(int(elem.bloc.ref_size/4)));
          if (type == OUTPUT) text(""+index, ref.getX()+ref.getSX()*1.5 , ref.getY()+ref.getSY()/2);
          else text(""+index, ref.getX()-ref.getSX()*0.5, ref.getY()+ref.getSY()/2);
        }
          
        if (buildingLine) {
          stroke(ref.look.outlineColor);
          strokeWeight(ref.look.outlineWeight);
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
        for (Macro_Connexion m : connected_inputs) {
          if (distancePointToLine(elem.bloc.mmain().gui.mouseVector.x, elem.bloc.mmain().gui.mouseVector.y, 
              getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < ref.look.outlineWeight ) { 
            if (pack_info != null && hasSend > 0) elem.bloc.mmain().info.showText(pack_info);
            fill(ref.look.outlineSelectedColor); stroke(ref.look.outlineSelectedColor); 
          }
          else 
          if (sending || hasSend > 0)
            { fill(ref.look.outlineColor); stroke(ref.look.outlineColor); }
          else { fill(color(255, 120)); stroke(color(255, 120)); }
          strokeWeight(ref.look.outlineWeight);
          PVector l = new PVector(m.getCenterX() - getCenterX(), m.getCenterY() - getCenterY());
          PVector lm = new PVector(l.x, l.y);
          lm.setMag(getSize()/2);
          line(getCenterX()+lm.x, getCenterY()+lm.y, 
               getCenterX()+l.x-lm.x, getCenterY()+l.y-lm.y);
          ellipseMode(CENTER);
          fill(255, 0);
          ellipse(m.getCenterX(), m.getCenterY(), 
                  getSize(), getSize() );
          fill(255, 0);
          ellipse(getCenterX(), getCenterY(), 
                  getSize(), getSize() );
        }
        if (hasSend > 0) hasSend--;
      }
    });
    if (_info != null) lens.setInfo(_info);
    ref.setParent(elem.back);
    msg_view = addModel("MC_Connect_View").clearParent();
    msg_view.setParent(ref);
    if (type == OUTPUT) { 
      msg_view.stackLeft();
      elem.back.setTextAlignment(LEFT, CENTER);
      ref.alignRight().setPX(-ref.getLocalX()); 
      lens.setTrigger().setLook(gui.theme.getLook("MC_Connect_Out_Actif")); } 
    else {
      msg_view.stackRight();
      elem.back.setTextAlignment(RIGHT, CENTER);
    }
    lens.setParent(ref);
    int i = 0; boolean found = true;
    while (found) {
      found = false;
      for (Macro_Connexion m : sheet.child_connect) if (m.index == i) found = true;
      if (found) i++;
    }
    index = i;
    sheet.child_connect.add(this);
  }
  float getCenterX() { return ref.getX()+ref.getSX()/2; }
  float getCenterY() { return ref.getY()+ref.getSY()/2; }
  float getSize() { return ref.getSY(); }
  
  int index = -1;
  
  void connect_to(Macro_Connexion m) {
    connected_inputs.add(m);
    m.connected_outputs.add(this); }
  void disconnect_from(Macro_Connexion m) {
    connected_inputs.remove(m);
    m.connected_outputs.remove(this); }
  
  boolean buildingLine = false;
  PVector newLine = new PVector();
  
  ArrayList<Macro_Connexion> connected_inputs = new ArrayList<Macro_Connexion>();
  ArrayList<Macro_Connexion> connected_outputs = new ArrayList<Macro_Connexion>();
  
  boolean sending = false;
  int hasSend = 0;
  
  String last_def = null;
  
  String pack_info = null;
  
  Macro_Connexion send(Macro_Packet p) {
    msg_view.setText(p.getText());
    last_def = copy(p.def);
    pack_info = copy(p.def);
    for (String m : p.messages) pack_info = pack_info + " " + m;
    sending = true;
    hasSend = 5;
    for (Macro_Connexion m : connected_inputs) m.receive(p);
    return this;
  }
  
  Macro_Connexion sendBang() { send(newPacketBang()); return this; }
  Macro_Connexion sendFloat(float v) { send(newPacketFloat(v)); return this; }
  Macro_Connexion sendInt(int v) { send(newPacketInt(v)); return this; }
  Macro_Connexion sendBool(boolean v) { send(newPacketBool(v)); return this; }
  Macro_Connexion setDefBang() { last_def = "bang"; return this; }
  Macro_Connexion setDefBool() { last_def = "bool"; return this; }
  Macro_Connexion setDefBin() { last_def = "bin"; return this; }
  Macro_Connexion setDefInt() { last_def = "int"; return this; }
  Macro_Connexion setDefFloat() { last_def = "float"; return this; }
  Macro_Connexion setDefNumber() { last_def = "num"; return this; }
  Macro_Connexion setDefVal() { last_def = "val"; return this; }
  Macro_Connexion setDefVec() { last_def = "vec"; return this; }
  
  
  
  

  Macro_Packet last_packet = null;
  
  Macro_Packet getLastPacket() { return last_packet; }
  
  void receive(Macro_Packet p) {
    if (filter == null || p.def.equals(filter) || 
        (filter.equals("bin") && (p.def.equals("bool") || p.def.equals("bang"))) ||
        (filter.equals("num") && (p.def.equals("float") || p.def.equals("int"))) ||
        (filter.equals("val") && (p.def.equals("float") || p.def.equals("int") || p.def.equals("bool"))) ) {
      last_packet = p;
      for (Runnable r : eventReceiveRun) r.run();
      if (direct_out != null) direct_out.send(p);
      msg_view.setText(p.getText());
    }
  }
  
  ArrayList<Runnable> eventReceiveRun = new ArrayList<Runnable>();
  Macro_Connexion addEventReceive(Runnable r)    { eventReceiveRun.add(r); return this; }
  Macro_Connexion removeEventReceive(Runnable r) { eventReceiveRun.remove(r); return this; }
  
  Macro_Connexion direct_out = null;
  void direct_connect(Macro_Connexion o) { direct_out = o; }
  
  String filter = null;
  
  Macro_Connexion setFilter(String f) {
    filter = copy(f);
    return this; }
  Macro_Connexion clearFilter() {
    filter = null;
    return this; }
  Macro_Connexion setFilterBang() {
    filter = "bang";
    return this; }
  Macro_Connexion setFilterInt() {
    filter = "int";
    return this; }
  Macro_Connexion setFilterFloat() {
    filter = "float";
    return this; }
  Macro_Connexion setFilterNumber() { //int and float
    filter = "num";
    return this; }
  Macro_Connexion setFilterBool() {
    filter = "bool";
    return this; }
  Macro_Connexion setFilterBin() {
    filter = "bin";
    return this; }
  Macro_Connexion setFilterValue() { //bool int and float
    filter = "val";
    return this; }
  Macro_Connexion setFilterVec() { //bool int and float
    filter = "vec";
    return this; }
  
}

/*

 element > drawer
 has a text pour l'info bulle
 is a rectangle without back who can hold different function :
 button trigger / switch > runnable
 label for info or values > element has method to set
 selector : multi switch exclusives or not > runnable
 slide?
 jauge and graph? 
 connexions 4 places possible
 
 */
class Macro_Element extends nDrawer implements Macro_Interf {
  Macro_Bloc getBloc() { return bloc; }

  nWidget back = null, spot = null;
  Macro_Connexion connect = null, sheet_connect = null;
  Macro_Bloc bloc;
  boolean sheet_viewable = false;
  Macro_Element(Macro_Bloc _bloc, String _ref, String _model, String _info, int co_side, int sco_side, boolean sheet_view) {
    super(_bloc.getShelf(), _bloc.ref_size*1.375, _bloc.ref_size);
    bloc = _bloc; sheet_viewable = sheet_view;
    back = addModel(_model).setText(_ref); 
    back.addEventTrigger(new Runnable(this) { public void run() { 
          bloc.sheet.selecting_element((Macro_Element)builder); } });
    if (sheet_view) bloc.sheet.child_elements.add(this);
    if (back != null && co_side != NO_CO) connect = new Macro_Connexion(this, bloc.sheet, co_side, _info); 
    if (back != null && sco_side != NO_CO) sheet_connect = new Macro_Connexion(this, bloc.sheet.sheet, sco_side, _info); 
  }
  void select(nWidget _spot) { 
    spot = _spot; spot.setLook("MC_Element_At_Spot"); back.setLook("MC_Element_At_Spot"); 
    sheet_viewable = false; }
  
  Macro_Element show() {
    back.clearParent(); back.setParent(ref).toLayerTop(); 
      back.setPX(-ref_size*0.5);
      if (connect != null) { connect.ref.show(); connect.toLayerTop(); }
      if (sheet_connect != null)  { sheet_connect.ref.hide(); }
    return this;
  }
  Macro_Element hide() {
    if (bloc.sheet.openning.get() == OPEN && spot != null) {
      back.clearParent(); back.setParent(spot).show().toLayerTop(); 
      back.setPX(0);
      if (connect != null)  { connect.ref.hide(); }
      if (sheet_connect != null)  { sheet_connect.ref.show(); sheet_connect.toLayerTop(); }
    }
    return this;
  }
  
  Macro_Element toLayerTop() { 
    super.toLayerTop(); 
    if (connect != null) connect.toLayerTop(); 
    if (sheet_connect != null) sheet_connect.toLayerTop(); 
    return this;
  }
  Macro_Element clear() { 
    super.clear(); 
    if (connect != null) bloc.sheet.child_connect.remove(connect);
    bloc.sheet.child_elements.remove(this);
    return this;
  }
}
