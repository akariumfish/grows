/*


  
  multiple bloc reduction levels :
    close : 
      only grab and connected co circles (arranged in 6 spot around grabber)
      co and bloc name by infobulle
      when hovered show an open button down
      losange / cut corner rect with darker outline
    open : show more
      panel with certain elements (with infobulle for descriptions) no fill grey outline
      name on hard back  with outline overlapp panel outline on down side right
      grabber overlap panel outline on top side left
      buttons to deploy/close opposite to grabber, deploy overlapp 2/3 to the exterior, close 1/3
      this is what is shown when on a sheet spot and the sheet is reducted (only open not deployed)
    deployed : 
      full pareters, inside blocs for sheet (soft back deployed)
  
  things are build around a grid when reducted, so they can be snapped together to form theire sheet panel

  grabber center or one side center
  snap to grid


connexion > element has method to send + runnable for receive
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

element > drawer
  has a text pour l'info bulle
  is a rectangle without back who can hold different function :
    button trigger / switch > runnable
    label for info or values > element has method to set
    selector : multi switch exclusives or not > runnable
    jauge and graph? 
    connexion
    
    1 small trig/switch > event
    

abstract extend shelfpanel
  can be selected and group dragged copy/pasted > template or deleted

bloc extend abstract
  shelfpanel of element
  methods to add and manipulate element for easy macro building
  
  show directly connected in/out to detect loop more easily 
    (cad show that an in will diectly send through an out of his bloc when receiving)
    use 2 axis aligned lines following elements outlines from connexions to connexions
  
sheet extend abstract
  shelfpanel of shown bloc
  receive frame call if asked (overwriten method? not for small sheet)
  will be extended to make Simulation and communitys
  methods for creating svalues > create corresponding bloc, but reducted for visibility
    create in grid around center
  methods for adding blocs inside
  
  can build a menu with all value manipulable with easy drawer
    can choose drawer type when creating value
    can set value limits
  
  has spot for blocs to display when reducted
    child bloc au dessus du panel can snap to spot
    
  no sheet co, stick to a free place in the hard back to make a co 
    
  quand une sheet est ouverte sont soft back est trensparent et sont parent est caché
  seulement une top sheet ouverte a la fois
  cant be grabbed when open

main
  is a sheet without grabber and with panel snapped to camera all time
  is extended to interface ? so work standalone with UI
  
  dont show soft back
  
  contain a valuebloc for storing templates
    and a valuebloc for the setup templates who is auto loaded
  
  sheet on the main sheet can be snapped to camera, 
    they will keep their place and size and show panel content
    only work when not deployed
  
  dedicted toolpanel on top left of screen
    has button :
      -delete selected blocs
      -save/paste template
      -drop down for basic macro
      -menu: see and organise template and sheet (goto sheet)



Template :
  -save selected sheet structure to template sValueBloc has sTmp
    popup for name with field and ok button
  -paste last template (or one selected in menu) in selected sheet, 
    if the sheet panel was selected when created it will produce a child sheet, 
    or replace it if the sheet panel is selected when pasting.
    otherwise it will create a group of blocs and sheets inside the selected sheet
  sTemplate : sTmp
    sValue template
    extended from sString
    can be send as packet
    macro can create macro !!!! > basic bloc create
  
basic bloc :
  data, memory, user set value, random,
  calc, comp, bool, not, bin(bang to bool),
  trigg, switch, keyboard, gate, delay, pulse
  pack / unpack > type transform like vec/float 
  setreset, counter, sequance, multigate : as template
  
MData : sValue access : only hold a string ref, search for corresponding svalue inside current sheet at creation
  if no value is found create one
  has in and out
  out can send on change or when receiving bang
  if it cible a vec, the bloc can follow the corresponding position 
  in can change value multiple way
    bool : set / switch
    num : set / mult / add
    vec : set / mult / add for values rotation and magnitude
    tmpl : in bang > build in same sheet / parent sheet
  
memory : when a packet is received, display and store it, send it when a bang is received
  can as disable bool input
  
macro turn:
  no tick anywhere > simulation gives tick
  no frame loop, works only by reacting to gui or input event (for keyboard create a keypress/release event)
    only time bloc have frame loop, delay and pulse need them, get it throug gui
    
  when at a frame an out whant to send :
    all out who want to send do it, input save msg
    if an out have multiple exit packet are send in input priority order
    once no out whant to send all input process msg in function of the corresponding output priority 
    order and mark their out for sending eventually
    once all in have processed their msg we start again if there is an out who want to send
    careful! loop can occur, 1 turn delays will fix them
    
  when in a connexion recursive loop count the depth to detect loop and break them 
    show a popup and desactivate everything somehow

*/
/*

 
             DESIGN
     !! MACRO ARE CRYSTALS !!
 
   hide labels! 
   forme carre > plus petit possible
   overlapp rectangles with those under them to show solidarity
 
 
   GUI to build
     widget jauge / graph
     widget qui englode auto des widget cible avec le mm parent que lui plus eventuellement sont parent
     drawer de losange
 
     grid snap grabber
     group grabbing
     group event call
 
     text asking popup
       build it
       call it.popup
       will respond with a runnable
 
 
 multiple bloc reduction levels :
   close : 
     only grab and connected co circles (arranged in 6 spot around grabber)
     co and bloc name by infobulle
     when hovered show an open button down
     losange / cut corner rect with darker outline
   open : show more
     panel with certain elements (with infobulle for descriptions) no fill grey outline
     name on hard back  with outline overlapp panel outline on down side right
     grabber overlap panel outline on top side left
     buttons to deploy/close opposite to grabber, deploy overlapp 2/3 to the exterior, close 1/3
     this is what is shown when on a sheet spot and the sheet is reducted (only open not deployed)
   deployed : 
     full pareters, inside blocs for sheet (soft back deployed)
 
   things are build around a grid when reducted, so they can be snapped together to form theire sheet panel
 
   snap to grid
 
 
 */



void myTheme_MACRO(nTheme theme, float ref_size) {
  theme.addModel("mc_ref", new nWidget()
    .setPassif()
    .setLabelColor(color(200, 200, 220))
    .setFont(int(ref_size/1.6))
    );
  theme.addModel("MC_Panel", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(105))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    .setOutline(true)
    );
  
  theme.addModel("MC_Title", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(80))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setFont(int(ref_size/1.6))
    .setText("--")
    .setSize(ref_size*2, ref_size*0.75).setPosition(ref_size*1.0, ref_size*0.5)
    );
  theme.addModel("MC_Front", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(200))
    .setOutlineWeight(ref_size * 1.0 / 16.0)
    .setPassif()
    );
  theme.addModel("MC_Front_Sheet", theme.newWidget("MC_Front")
    .setOutlineColor(color(200, 200, 0))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    );
  theme.addModel("MC_Panel_Spot", theme.newWidget("mc_ref")
    .setStandbyColor(color(50))
    .setOutlineColor(color(105, 105, 80))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    .setSize(ref_size*2, ref_size)
    .setOutline(true)
    );
  theme.addModel("MC_Sheet_Soft_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(180, 60))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Sheet_Hard_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(45))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Element", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setOutlineColor(color(90))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setPosition(-ref_size*0.5, 0)
    );
  theme.addModel("MC_Element_For_Spot", theme.newWidget("MC_Element")
    .setOutlineColor(color(150, 150, 0))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  theme.addModel("MC_Element_At_Spot", theme.newWidget("MC_Element")
    .setOutlineColor(color(120, 70, 0))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    );
  theme.addModel("MC_Element_Single", theme.newWidget("MC_Element")
    .setSize(ref_size*2, ref_size)
    );
  theme.addModel("MC_Element_Double", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125, ref_size)
    );
  theme.addModel("MC_Element_Fillright", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(ref_size*1.25, -ref_size*0.25)
    );
  theme.addModel("MC_Element_Fillleft", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(-ref_size*2.875, -ref_size*0.25)
    );
  theme.addModel("MC_Element_Field", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(140))
    .setOutlineSelectedColor(color(200))
    .setOutlineWeight(ref_size / 16)
    .setPosition(ref_size*0, ref_size * 1 / 16)
    .setSize(ref_size*3.125, ref_size*0.875)
    );
  theme.addModel("MC_Element_SField", theme.newWidget("MC_Element_Field")
    .setPosition(-ref_size*0.25, ref_size * 1 / 16)
    .setSize(ref_size*1.625, ref_size*0.875)
    );
  theme.addModel("MC_Grabber", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setHoveredColor(color(100))
    .setClickedColor(color(130))
    .setOutlineWeight(ref_size / 9)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setSize(ref_size*1, ref_size*0.75)
    .setGrabbable()
    );
  theme.addModel("MC_Grabber_Deployed", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(70, 70, 0))
    .setOutlineColor(color(150, 150, 0))
    );
  theme.addModel("MC_Grabber_Selected", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(220, 220, 0))
    .setOutlineColor(color(150, 150, 0))
    );
  theme.addModel("MC_Basic", theme.newWidget("mc_ref")
    .setStandbyColor(color(100))
    .setHoveredColor(color(125))
    .setClickedColor(color(150))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setTrigger()
    .setSize(ref_size*0.75, ref_size*0.75)
    .setPosition(-ref_size*0.375, -ref_size*0.375)
    );
  theme.addModel("MC_Reduc", theme.newWidget("MC_Basic")
    .setStandbyColor(color(60))
    .setHoveredColor(color(120))
    .setClickedColor(color(160))
    .setOutlineWeight(ref_size / 12)
    .setSX(ref_size*0.5).setPosition(-ref_size*1.0, ref_size*0.375)
    );
  theme.addModel("MC_Deploy", theme.newWidget("MC_Reduc")
    .setSize(ref_size*0.75, ref_size*0.5).setPosition(-ref_size*0.375, -ref_size*0.5)
    );
  theme.addModel("MC_Connect_Out_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(90))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Out_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_In_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(110))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_In_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Link", theme.newWidget("mc_ref")
    .setStandbyColor(color(200))
    .setHoveredColor(color(205, 205, 200))
    .setClickedColor(color(220, 220, 200))
    .setOutlineColor(color(200, 100, 100))
    .setOutlineSelectedColor(color(200, 200, 0))
    .setOutlineWeight(ref_size / 10)
    .setOutline(true)
    .setRound(true)
    );
  theme.addModel("MC_Connect_View", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutline(false)
    .setPosition(0, -ref_size*4/16)
    .setSize(ref_size*1.5, ref_size*0.75)
    );
}

import java.util.Map;



void mySetup_MACRO(sInterface inter) {
  Macro_Main mmain = inter.macro_main;
  
  //Macro_Sheet s1 = mmain.addSheet();
  //s1.addSheet();
  //mmain.addData();
  
}






/*
abstract extend shelfpanel
 can be selected and group dragged copy/pasted > template or deleted
 
 */
class Macro_Abstract extends nShelfPanel implements Macro_Interf {
  
  Macro_Abstract deploy() { open(); return this; }
  Macro_Abstract open() {
    if (openning.get() != OPEN) {
      openning.set(OPEN);
      grabber.show(); panel.show(); back.hide(); 
      front.show(); title.show(); reduc.show(); 
      reduc.setPosition(-ref_size, ref_size*0.375);
      moving();
    }
    return this;
  }
  Macro_Abstract reduc() {
    if (openning.get() != REDUC) {
      openning.set(REDUC);
      grabber.show(); panel.hide(); back.hide(); 
      front.hide(); title.hide(); reduc.show(); 
      reduc.show().setPosition(ref_size * 0.75, ref_size*0.75);
      moving();
    }
    return this;
  }
  Macro_Abstract show() {
    if (openning.get() == HIDE) { 
      if (openning_pre_hide.get() == REDUC) reduc();
      else if (openning_pre_hide.get() == OPEN) open();
      else if (openning_pre_hide.get() == DEPLOY) open();
      //else reduc();
    }
    return this;
  }
  Macro_Abstract hide() {
    if (openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
    }
    grabber.hide(); panel.hide(); back.hide(); 
    front.hide(); title.hide(); reduc.hide(); 
    return this;
  }
  Macro_Abstract changeOpenning() {
    if (openning.get() == OPEN) { reduc(); }
    else if (openning.get() == REDUC) { open(); }
    else if (openning.get() == DEPLOY) { open(); }
    return this; }
  
  void moving() { sheet.movingChild(this); }
  void group_move(float x, float y) { 
    grabber.setPY(grabber.getLocalY() + y); grabber.setPX(grabber.getLocalX() + x); }
  Macro_Abstract setPosition(float x, float y) { 
    grab_pos.doEvent(false);
    grabber.setPosition(x, y); grab_pos.set(x, y);
    grab_pos.doEvent(true);
    return this; }
  Macro_Abstract setParent(Macro_Sheet s) { grabber.clearParent(); grabber.setParent(s.grabber); return this; }
  Macro_Abstract toLayerTop() { 
    super.toLayerTop(); title.toLayerTop(); grabber.toLayerTop(); reduc.toLayerTop(); front.toLayerTop(); return this; }

  Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }

  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false, title_fixe = false, unclearable = false;
  float ref_size = 40;
  sVec grab_pos; sStr val_type, val_descr, val_title;
  sInt openning, openning_pre_hide; sObj val_self;
  float prev_x, prev_y; //for group dragging
  nLinkedWidget grabber, title;
  nWidget reduc, front, back;
  sValueBloc value_bloc = null, setting_bloc;
  Runnable szone_st, szone_en;
Macro_Abstract(Macro_Sheet _sheet, String ty, String n, sValueBloc _bloc) {
    super(_sheet.gui, _sheet.ref_size, 0.25);
    gui = _sheet.gui; ref_size = _sheet.ref_size; sheet = _sheet; 
    sheet_depth = sheet.sheet_depth + 1;
    
    if (_bloc == null) {
      if (n == null) value_bloc = sheet.value_bloc.newBloc(sheet.child_macro.size()+"_"+ty);
      else value_bloc = sheet.value_bloc.newBloc(sheet.child_macro.size()+"_"+n);
    } else value_bloc = _bloc;
    
    setting_bloc = value_bloc.getBloc("settings");
    if (setting_bloc == null) setting_bloc = value_bloc.newBloc("settings");
    
    val_type = ((sStr)(setting_bloc.getValue("type"))); 
    val_descr = ((sStr)(setting_bloc.getValue("description"))); 
    val_title = ((sStr)(setting_bloc.getValue("title"))); 
    grab_pos = ((sVec)(setting_bloc.getValue("position"))); 
    openning = ((sInt)(setting_bloc.getValue("open"))); 
    openning_pre_hide = ((sInt)(setting_bloc.getValue("pre_open"))); 
    val_self = ((sObj)(setting_bloc.getValue("self"))); 
    
    if (val_type == null) val_type = setting_bloc.newStr("type", "type", ty);
    if (val_descr == null) val_descr = setting_bloc.newStr("description", "descr", "macro");
    if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", n);
    if (grab_pos == null) grab_pos = setting_bloc.newVec("position", "pos");
    if (openning == null) openning = setting_bloc.newInt("open", "op", OPEN);
    if (openning_pre_hide == null) openning_pre_hide = setting_bloc.newInt("pre_open", "pop", OPEN);
    if (val_self == null) val_self = setting_bloc.newObj("self", this);
    else val_self.set(this);
    build_ui();
  }
  Macro_Abstract(sInterface _int) { // FOR MACRO_MAIN ONLY
    super(_int.cam_gui, _int.ref_size, 0.125);
    gui = _int.cam_gui; 
    ref_size = _int.ref_size; 
    sheet = (Macro_Main)this;
    myTheme_MACRO(gui.theme, ref_size); 
    panel.copy(gui.theme.getModel("mc_ref"));
    grabber = addLinkedModel("mc_ref");
    grabber.clearParent();
    reduc = addModel("mc_ref");
    panel.hide(); 
    grabber.setSize(0, 0).setPassif().setOutline(false);
    front = addModel("mc_ref");
    title = addLinkedModel("mc_ref");
    back = addModel("mc_ref");
    
    value_bloc = _int.interface_bloc.newBloc("Main_Sheet");
    setting_bloc = value_bloc.newBloc("settings");
    val_type = setting_bloc.newStr("type", "type", "main");
    val_descr = setting_bloc.newStr("description", "descr", "macro main");
    val_title = setting_bloc.newStr("title", "ttl", "macro main");
    grab_pos = setting_bloc.newVec("position", "pos");
    openning = setting_bloc.newInt("open", "op", DEPLOY);
    openning_pre_hide = setting_bloc.newInt("pre_open", "pop", DEPLOY);
    val_self = setting_bloc.newObj("self", this);
  }
  void build_ui() {
    grabber = addLinkedModel("MC_Grabber")
      .setLinkedValue(grab_pos);
      
    grabber.clearParent().addEventDrag(new Runnable(this) { public void run() { 
      title.hide();
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
      
      if (mmain().selected_macro.contains(((Macro_Abstract)builder)))
        for (Macro_Abstract m : mmain().selected_macro) if (m != ((Macro_Abstract)builder))
          m.group_move(grabber.getLocalX() - prev_x, grabber.getLocalY() - prev_y);
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY();
      moving(); } });
    grabber.addEventGrab(new Runnable() { public void run() { 
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY(); } });
    
    panel.copy(gui.theme.getModel("MC_Panel"));
    panel.setParent(grabber);
    panel.setPosition(-grabber.getLocalSX()/4, grabber.getLocalSY()/2 + ref_size * 1 / 8)
      .addEventShapeChange(new Runnable() { public void run() {
        front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } )
      .addEventVisibilityChange(new Runnable() { public void run() {
      if (panel.isHided()) front.setSize(0, 0);
      else front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } );
    
    back = addModel("MC_Sheet_Soft_Back");
    back.clearParent();
    back.setParent(grabber).hide();
    
    reduc = addModel("MC_Reduc").clearParent();
    reduc.setParent(panel);
    reduc.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { changeOpenning(); } });
    
    title = addLinkedModel("MC_Title").setLinkedValue(val_title);
    title.clearParent();
    title.setParent(panel);
    title.alignDown().stackLeft();
    grabber.addEventMouseEnter(new Runnable() { public void run() { 
      if (openning.get() == REDUC) title.show(); } });
    grabber.addEventMouseLeave(new Runnable() { public void run() { 
      if (openning.get() == REDUC && !title_fixe) title.hide(); } });
    
    front = addModel("MC_Front")
      .setParent(panel)
      .addEventFrame(new Runnable() { public void run() { 
        if (mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(front)) front.setOutline(true);
          else front.setOutline(false); } } } )
      ;
    szone_st = new Runnable() { public void run() { 
      szone_selected = false;
      front.setOutline(false); } } ;
    szone_en = new Runnable(this) { public void run() { 
      if (mmain().selected_sheet == sheet && mmain().szone.isUnder(front))  {
        mmain().selected_macro.add(((Macro_Abstract)builder));
        szone_selected = true; toLayerTop(); } } } ;
    if (mmain() != this) {
      mmain().szone.addEventStartSelect(szone_st);
      mmain().szone.addEventEndSelect(szone_en);
    }
    
    setParent(sheet); 
    sheet.child_macro.add(this); 
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
      if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
      else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
      else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
      else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
      if (mmain().sheet_explorer != null) mmain().sheet_explorer.update(); 
      toLayerTop(); find_place(); sheet.deploy(); sheet.updateBack(); } } );
    
  }
  void find_place() {
    int adding_v = 0;
    boolean found = false;
    while (!found) {
      if (adding_v > 0) setPosition(grabber.getLocalX() + ref_size * 6, grabber.getLocalY());
      adding_v++; 
      if (adding_v == 4) { 
        adding_v = 0; setPosition(grabber.getLocalX() - ref_size * 18, grabber.getLocalY() + ref_size * 6); }
      boolean col = false;
      for (Macro_Abstract c : sheet.child_macro) 
        if (c != this && c.openning.get() == DEPLOY && rectCollide(panel.getRect(), c.back.getRect())) col = true;
        else if (c != this && c.openning.get() == REDUC && rectCollide(panel.getRect(), c.grabber.getRect())) col = true;
        else if (c != this && c.openning.get() == OPEN && rectCollide(panel.getRect(), c.panel.getRect())) col = true;
      if (sheet != mmain() && rectCollide(panel.getRect(), sheet.panel.getRect())) col = true;
      if (!col) found = true;
    }
    sheet.updateBack();
  }
  Macro_Abstract clear() {
    if (!unclearable) {
      super.clear();
      val_type.clear(); val_descr.clear(); val_title.clear(); grab_pos.clear();
      openning.clear(); openning_pre_hide.clear(); val_self.clear();
      value_bloc.clear(); 
      sheet.child_macro.remove(this);
      sheet.updateBack();
      if (mmain() != this) {
        mmain().szone.removeEventStartSelect(szone_st);
        mmain().szone.removeEventEndSelect(szone_en);
      }
    }
    return this;
  }
  
}

/*




 sheet extend abstract
 shelfpanel of shown bloc
 
 
 methods for adding blocs inside
 
 has spot for blocs to display when reducted
 child bloc au dessus du panel can snap to spot
 
 no sheet co, stick to a free place in the hard back to make a co 
 
 quand une sheet est ouverte sont soft back est trensparent et sont parent est caché
 seulement une top sheet ouverte a la fois
 cant be grabbed when open
 
 */
class Macro_Sheet extends Macro_Abstract {
  
  void moving() { updateBack(); sheet.movingChild(this); }
  void movingChild(Macro_Abstract m) { updateBack(); }
  void updateBack() {
    if (openning.get() == DEPLOY) {
      float elem_space = ref_size*2.5;
      float minx = -elem_space, miny = -elem_space, 
            maxx = panel.getLocalX() + panel.getLocalSX() + elem_space, 
            maxy = panel.getLocalY() + panel.getLocalSY() + elem_space;
      
      for (Macro_Abstract m : child_macro) if (m.openning.get() == DEPLOY) {
        if (minx > m.grabber.getLocalX() + m.back.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() + m.back.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() + m.back.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() + m.back.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space;
      } else if (m.openning.get() == OPEN) {
        if (minx > m.grabber.getLocalX() + m.panel.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() + m.panel.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() + m.panel.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() + m.panel.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space;
      } else if (m.openning.get() == REDUC) {
        if (minx > m.grabber.getLocalX() - elem_space) 
          minx = m.grabber.getLocalX() - elem_space;
        if (miny > m.grabber.getLocalY() - elem_space) 
          miny = m.grabber.getLocalY() - elem_space;
        if (maxx < m.grabber.getLocalX() + m.grabber.getLocalSX() + elem_space) 
          maxx = m.grabber.getLocalX() + m.grabber.getLocalSX() + elem_space;
        if (maxy < m.grabber.getLocalY() + m.grabber.getLocalSY() + elem_space) 
          maxy = m.grabber.getLocalY() + m.grabber.getLocalSY() + elem_space;
      }
      
      back.setPosition(minx, miny);
      back.setSize(maxx - minx, maxy - miny);
      if (sheet != this) sheet.updateBack();
    }
  }
  Macro_Sheet select() {
    if (mmain().selected_sheet != this) { 
      if (sheet != this && openning.get() != DEPLOY) deploy();
      mmain().selected_sheet.back_front.setOutline(false);
      if (mmain().selected_sheet.openning.get() == DEPLOY)
        mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      else mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber"));
      mmain().selected_macro.clear();
      mmain().selected_sheet = this;
      back_front.setOutline(true);
      grabber.setLook(gui.theme.getLook("MC_Grabber_Selected"));
      toLayerTop();
      //if (mmain() != this && mmain().preset_explorer != null) mmain().preset_explorer.setBloc(preset_bloc);
    }
    if (mmain().sheet_explorer != null) mmain().sheet_explorer.setBloc(value_bloc);
    return this;
  }
  Macro_Sheet deploy() {
    if (sheet != this && openning.get() != DEPLOY) {
      if (sheet.openning.get() != DEPLOY) sheet.deploy();
      openning.set(DEPLOY);
      title_fixe = true; 
      grabber.show(); panel.show(); back.show(); back_front.show();
      front.show(); title.show(); reduc.hide(); deployer.show();
      grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      last_spot_left.setSwitch(); last_spot_right.setSwitch(); 
      for (Macro_Abstract m : child_macro) m.show(); 
      updateBack(); 
      moving(); toLayerTop();
    }
    return this;
  }
  Macro_Sheet open() {
    if (sheet != this && openning.get() != OPEN) {
      openning.set(OPEN);
      title_fixe = true; 
      grabber.show(); panel.show(); back.hide(); back_front.hide();
      front.show(); title.show(); reduc.show(); deployer.show();
      reduc.setPosition(-ref_size, ref_size*0.375);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      last_spot_left.setBackground(); last_spot_right.setBackground(); 
      for (Macro_Abstract m : child_macro) m.hide();
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
      moving(); toLayerTop();
    }
    return this;
  }
  Macro_Sheet reduc() {
    if (sheet != this && openning.get() != REDUC) {
      openning.set(REDUC);
      title_fixe = false; 
      grabber.show(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.show(); deployer.hide();
      reduc.setPosition(ref_size * 0.75, ref_size*0.75);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      last_spot_left.setBackground(); last_spot_right.setBackground(); 
      for (Macro_Abstract m : child_macro) m.hide();
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
      moving(); toLayerTop();
    }
    return this;
  }
  Macro_Sheet hide() {
    if (sheet != this && openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
      title_fixe = false; 
      for (Macro_Abstract m : child_macro) m.hide();
      last_spot_left.setBackground(); last_spot_right.setBackground(); 
      grabber.hide(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.hide(); deployer.hide();
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
    }
    return this;
  }
  Macro_Sheet toLayerTop() { 
    super.toLayerTop(); 
    grabber.toLayerTop(); deployer.toLayerTop();
    if (child_macro != null) for (Macro_Abstract e : child_macro) e.toLayerTop(); 
    back_front.toLayerTop(); 
    return this;
  }
  
  
  void selecting_spot() {
    if (last_spot_left.isOn()) {
      last_spot_right.setBackground();
      for (Macro_Element m : child_elements) if (m.sheet_viewable) {
        m.back.setTrigger().setLook("MC_Element_For_Spot"); /*event in init de l'element*/ }
      
    } else if (last_spot_right.isOn()) {
      last_spot_left.setBackground();
      for (Macro_Element m : child_elements) if (m.sheet_viewable) {
        m.back.setTrigger().setLook("MC_Element_For_Spot"); /*event in init de l'element*/ }
      
    }
  }
  void selecting_element(Macro_Element elem) {
    for (Macro_Element m : child_elements) if (m.sheet_viewable) {
        m.back.setBackground().setLook("MC_Element"); }
    if (last_spot_left.isOn()) {
      elem.select(last_spot_left);
      last_spot_left.setOff(); last_spot_left.setBackground(); last_spot_right.setSwitch();
      last_spot_left = getShelf(0).addDrawer(2, 1).addModel("MC_Panel_Spot").setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() { selecting_spot(); } });
    }
    if (last_spot_right.isOn()) {
      elem.select(last_spot_right);
      last_spot_right.setOff(); last_spot_right.setBackground(); last_spot_left.setSwitch();
      last_spot_right = getShelf(1).addDrawer(2, 1).addModel("MC_Panel_Spot").setSwitch()
        .addEventSwitchOn(new Runnable() { public void run() { selecting_spot(); } });
    }
  }
  nWidget last_spot_left, last_spot_right;
  
  
  boolean new_bloc_balance = false, new_bloc_detected1 = false, new_bloc_detected2 = false;
  ArrayList<sValueBloc> new_bloc1 = new ArrayList<sValueBloc>(0);
  ArrayList<sValueBloc> new_bloc2 = new ArrayList<sValueBloc>(0);
  void new_bloc_detected(sValueBloc b) {
    if (new_bloc_balance) {
      new_bloc1.add(b);
      if (!new_bloc_detected1) mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
        new_bloc_balance = !new_bloc_balance; process_new_bloc(new_bloc1); new_bloc_detected1 = false; } });
      new_bloc_detected1 = true; 
    } else {
      new_bloc2.add(b);
      if (!new_bloc_detected2) mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
        new_bloc_balance = !new_bloc_balance; process_new_bloc(new_bloc2); new_bloc_detected2 = false; } });
      new_bloc_detected2 = true;
    }
  }
  void process_new_bloc(ArrayList<sValueBloc> new_bloc) {
    for (sValueBloc nbloc : new_bloc) {
      //logln("sheet bloc: " + value_bloc.base_ref + " found bloc: " + nbloc.base_ref);
      if (nbloc.getBloc("settings") != null && 
          nbloc.getBloc("settings").getValue("type") != null && 
          nbloc.getBloc("settings").getValue("self") != null && 
          ((sObj)(nbloc.getBloc("settings").getValue("self"))).get() == null) {
        //log(" > found new sheet bloc >");
        value_bloc.doEvent(false);
        addByType(((sStr)nbloc.getBloc("settings").getValue("type")).get(), nbloc);
        value_bloc.doEvent(true);
        updateBack();
        if (mmain().sheet_explorer != null) mmain().sheet_explorer.update();
      }
    }
    new_bloc.clear();
  }
  ArrayList<Macro_Connexion> child_connect = new ArrayList<Macro_Connexion>(0);
  ArrayList<Macro_Element> child_elements = new ArrayList<Macro_Element>(0);
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  ArrayList<Macro_Sheet> child_sheet = new ArrayList<Macro_Sheet>(0);
  
  nWidget back_front, deployer;
  sValueBloc preset_bloc;
  Runnable szone_run;
  
Macro_Sheet(Macro_Sheet p, String n, sValueBloc _bloc) { 
    super(p, "sheet", n, _bloc); init(); }
  Macro_Sheet(sInterface _int) {
    super(_int);
    preset_bloc = value_bloc.newBloc("presets");
    new_preset_name = setting_bloc.newStr("preset_name", "preset", "preset");
    
    value_bloc.addEventAddBloc_Builder(new Runnable() { public void run() { 
      logln("sheet bloc: " + value_bloc.base_ref + " found bloc: " + value_bloc.last_created_bloc.base_ref);
      new_bloc_detected(value_bloc.last_created_bloc); } } );
    
    back_front = addModel("mc_ref");
    deployer = addModel("mc_ref"); }
  void init() {
    sheet.child_sheet.add(this);
    
    preset_bloc = value_bloc.getBloc("presets");
    
    value_bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
      if (bloc != setting_bloc && bloc != preset_bloc) new_bloc_detected(bloc); }});
    
    if (preset_bloc == null) preset_bloc = value_bloc.newBloc("presets");
    
    new_preset_name = ((sStr)(setting_bloc.getValue("preset_name"))); 
    if (new_preset_name == null) new_preset_name = setting_bloc.newStr("preset_name", "preset", "default");
    new_preset_name.set("default");
    save_preset();
    new_preset_name.set("new");
    for (Macro_Sheet m : sheet.child_sheet) 
      if (m != this && m.preset_bloc != preset_bloc && m.preset_bloc.getBloc("default").getHierarchy(true)
          .equals(preset_bloc.getBloc("default").getHierarchy(true))) {
        preset_bloc.runBlocIterator(new Iterator<sValueBloc>(m) { public void run(sValueBloc bloc) { 
          if (((Macro_Sheet)builder).preset_bloc.getBloc(bloc.ref) == null) 
            copy_bloc(bloc, ((Macro_Sheet)builder).preset_bloc); }});
        preset_bloc.clear();
        preset_bloc = m.preset_bloc;
        preset_folder = m; m.is_preset_folder = true;
        if (preset_explorer != null) preset_explorer.update();
        if (m.preset_explorer != null) m.preset_explorer.update();
    }
    
    
    value_bloc.addEventAddBloc_Builder(new Runnable() { public void run() { 
      logln("sheet bloc: " + value_bloc.base_ref + " found bloc: " + value_bloc.last_created_bloc.base_ref);
      new_bloc_detected(value_bloc.last_created_bloc); } } );
    
    back_front = addModel("MC_Front_Sheet")
      .clearParent();
    back_front.setParent(back);
    back.addEventShapeChange(new Runnable() { public void run() {
      back_front.setSize(back.getLocalSX(), back.getLocalSY()); } } );
    
    deployer = addModel("MC_Deploy").clearParent();
    deployer.setParent(panel);
    deployer.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { 
      if (openning.get() == DEPLOY) open(); else { deploy(); select(); } } });
    
    last_spot_left = addShelf().addDrawer(2, 1).addModel("MC_Panel_Spot")
      .addEventSwitchOn(new Runnable() { public void run() { selecting_spot(); } });
    last_spot_right = addShelf().addDrawer(2, 1).addModel("MC_Panel_Spot")
      .addEventSwitchOn(new Runnable() { public void run() { selecting_spot(); } });
    
    szone_run = new Runnable(this) { public void run() { 
      if (openning.get() != REDUC && mmain().search_sheet.sheet_depth < sheet_depth && 
          mmain().szone.isUnder(back_front)) { 
        mmain().search_sheet = ((Macro_Sheet)builder);
      }
    } };
    
    mmain().szone.addEventStartSelect(szone_run);
    
    updateBack();
  }
  Macro_Abstract addByType(String t) { return addByType(t, null); }
  Macro_Abstract addByType(String t, sValueBloc b) { 
    if (t.equals("sheet")) return addSheet(b);
    else if (t.equals("data")) return addData(b);
    else if (t.equals("connect")) return addSheetCo(b);
    else if (t.equals("keyb")) return addKey(b);
    
    return null;
  }
  Macro_Sheet addSheet(sValueBloc b) { 
    Macro_Sheet m = new Macro_Sheet(this, "sheet", b); return m; }
  MData addData(sValueBloc b) { MData m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MData(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MData(this, b, mmain().sheet_explorer.selected_value);
    else m = new MData(this, b, null); return m; }
  MSheetCo addSheetCo(sValueBloc b) { MSheetCo m = new MSheetCo(this, b); return m; }
  MKeyboard addKey(sValueBloc b) { MKeyboard m = new MKeyboard(this, b); return m; }
  
  Macro_Sheet clear() {
    if (!unclearable) {
      super.clear();
      sheet.child_sheet.remove(this);
      empty();
      value_bloc.clear();
      if (mmain() != this) mmain().szone.removeEventStartSelect(szone_run);
      if (is_preset_folder) {
        //try to copy preset to another similar sheet
      }
    }
    return this;
  }
  Macro_Sheet empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    child_sheet.clear();
    updateBack();
    return this;
  }
  
  Macro_Sheet addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  
  void setup_load(sValueBloc b) {
    sValueBloc bloc = b.getBloc(value_bloc.ref);
    if (bloc != null) {
      //logln(value_bloc.ref + " found");
      transfer_bloc_values(bloc, value_bloc);
      sValueBloc tbloc = bloc.getBloc("presets");
      if (tbloc != null) {
        preset_bloc.clean();
        tbloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
          copy_bloc(bloc, preset_bloc); }});
      }
      sValueBloc sbloc = bloc.getBloc("settings");
      if (sbloc != null) transfer_bloc_values(sbloc, setting_bloc);
      
      for (Macro_Sheet m : child_sheet) m.setup_load(bloc);
      for (Runnable r : eventsSetupLoad) r.builder = bloc;
      runEvents(eventsSetupLoad);
    }

  }
  
  
  nFrontPanel sheet_front;  
  nExplorer sheet_viewer, preset_explorer;
  sStr new_preset_name;
  
  void build_custom_menu(nFrontPanel sheet_front) {}
  
  void build_sheet_menu() {
    if (sheet_front == null) {
      sheet_front = new nFrontPanel(mmain().screen_gui, mmain().inter.taskpanel, val_title.get());
      
      sheet_front.addTab("Sheet").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "sheet :").setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      sheet_viewer = sheet_front.getTab(0).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setBloc(value_bloc)
          .addEventChange(new Runnable() { public void run() { 
              if (sheet_viewer.starting_bloc != sheet_viewer.explored_bloc) {
                sheet_viewer.setBloc(value_bloc);
              }
          } } )
          ;
      sheet_front.addTab("Preset").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "Sheet preset :").setTextAlignment(LEFT, CENTER).getDrawer()
        .addCtrlModel("Button-S2-P3", "Delete").setRunnable(new Runnable() { public void run() { 
          if (!preset_explorer.selected_bloc.ref.equals("default")) {
            preset_explorer.selected_bloc.clear(); preset_explorer.update(); } } } ).getShelf()
        .addSeparator()
        ;
      preset_explorer = sheet_front.getTab(1).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setBloc(preset_bloc)
          .addEventChange(new Runnable() { public void run() { 
              //if (sheet_explorer.starting_bloc != sheet_explorer.selected_bloc && 
              //    sheet_explorer.selected_bloc != null && sheet_explorer.selected_bloc.getValue("self") != null && 
              //    sheet_explorer.selected_bloc.getValue("type") != null && 
              //    ((sStr)sheet_explorer.selected_bloc.getValue("type")).get().equals("sheet")) {
              //  Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc.getValue("self"))).get());
              //  if (selected_sheet != mmain()) selected_sheet.open();
              //  s.select();
              //}
          } } )
          ;
      preset_explorer.getShelf()
        .addSeparator(0.25)
        .addDrawer(1)
          .addCtrlModel("Button-S2-P1", "Save").setRunnable(new Runnable() { public void run() { 
            save_preset(); } } ).getDrawer()
          .addLinkedModel("Field-S2-P2").setLinkedValue(new_preset_name).getDrawer()
          .addCtrlModel("Button-S2-P3", "Load").setRunnable(new Runnable() { public void run() { 
            load_preset(); } } ).getDrawer()
          .getShelf()
        .addSeparator(0.25)
        ;
      //sheet_front.setPosition(
      //  screen_gui.view.pos.x + screen_gui.view.size.x - sheet_front.grabber.getLocalSX() - ref_size * 3, 
      //  screen_gui.view.pos.y + ref_size * 2 );
      
      build_custom_menu(sheet_front);
      
      sheet_front.addEventClose(new Runnable(this) { public void run() { sheet_front = null; }});
    } else sheet_front.popUp();
  }
  
  Macro_Sheet preset_folder;
  boolean is_preset_folder = false;
  
  void save_preset() {
    Save_Bloc b = new Save_Bloc("");
    value_bloc.preset_value_to_save_bloc(b);
    preset_bloc.newBloc(b, new_preset_name.get());
    if (preset_explorer != null) preset_explorer.setBloc(preset_bloc).update();
    if (preset_explorer != null) preset_explorer.selectEntry(new_preset_name.get());
    if (preset_folder != null) {
      if (preset_folder.preset_explorer != null) preset_folder.preset_explorer.setBloc(preset_bloc).update();
      if (preset_folder.preset_explorer != null) preset_folder.preset_explorer.selectEntry(new_preset_name.get());
    }
  }
  void load_preset() {
    if (preset_explorer.selected_bloc != null) {
      transfer_bloc_values(preset_explorer.selected_bloc, value_bloc);
    }
  }
}





interface Macro_Interf {
  static final int INPUT = 0, OUTPUT = 1, NO_CO = 2;
  static final int HIDE = 0, REDUC = 1, OPEN = 2, DEPLOY = 3;
  final String[] bloc_types = {"sheet", "data", "connect", "keyb"};
}





/*
main
 is a sheet without grabber and with panel snapped to camera all time
 is extended to interface ? so work standalone with UI
 
 dont show soft back
 
 sheet on the main sheet can be snapped to camera, 
 they will keep their place and size and show panel content
 only work when not deployed
 
 dedicated toolpanel on top left of screen
 has button :
 -delete selected blocs
 -save/paste template
 -drop down for basic macro
 -menu: see and organise template and sheet (goto sheet)
 
 
 
 
 
 
 
 */
class Macro_Main extends Macro_Sheet {
  nFrontPanel macro_front;  
  nToolPanel macro_tool, build_tool;
  nExplorer template_explorer, sheet_explorer;
  sValueBloc pastebin = null;
  
  void copy_to_tmpl() {
    if (selected_sheet != this) {
      copy_bloc(selected_sheet.value_bloc, saved_template);
      pastebin = saved_template.last_created_bloc;
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(selected_sheet.value_bloc.base_ref); }
    }
  }
  void paste_tmpl() {
    if (template_explorer != null && template_explorer.selected_bloc != null) {
      copy_bloc(template_explorer.selected_bloc, selected_sheet.value_bloc, 
        selected_sheet.child_macro.size() + "_" + template_explorer.selected_bloc.base_ref);
      if (sheet_explorer != null) sheet_explorer.update();
    }
    else if (pastebin != null) {
      copy_bloc(pastebin, selected_sheet.value_bloc,
        selected_sheet.child_macro.size() + "_" + pastebin.base_ref);
    }
  }

  void build_macro_menus() {
    
    macro_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    macro_tool.addShelf().addDrawer(3.25, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "X")
          .setRunnable(new Runnable() { public void run() { 
          for (Macro_Abstract m : selected_macro) m.clear(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("delete selected bloc").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "E")
          .setRunnable(new Runnable() { public void run() { 
            selected_sheet.empty(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("Empty selected sheet").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "C")
          .setRunnable(new Runnable() { public void run() { copy_to_tmpl(); }})
          .setInfo("copy selected sheet to template").setFont(int(ref_size/1.7)).getShelfPanel()
      .addShelf().addDrawer(3.25, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "P")
          .setRunnable(new Runnable() { public void run() { paste_tmpl(); }})
          .setInfo("Paste selected template in selected sheet").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "M")
          .setRunnable(new Runnable() { public void run() { selected_sheet.build_sheet_menu(); }})
          .setInfo("Selected sheet auto menu").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "T")
          .setRunnable(new Runnable() { public void run() { build_macro_frontpanel(); }})
          .setInfo("Template and value selection").setFont(int(ref_size/1.7));
    //macro_tool.reduc();
    
    build_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    build_tool.addShelf();
    
    for (String t : bloc_types) build_tool.getShelf(0).addDrawer(2, 1)
      .addCtrlModel("Menu_Button_Small_Outline-S2/1", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        ;
    
    //build_tool.reduc();
    build_tool.panel.setPY(ref_size*2);
  }
    
  
  void build_macro_frontpanel() {
    if (macro_front == null) {
      macro_front = new nFrontPanel(screen_gui, inter.taskpanel, "MACRO");
      macro_front.addTab("Template").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "Templates :").setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      template_explorer = macro_front.getTab(0).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setBloc(saved_template)
          .addEventChange(new Runnable() { public void run() { } } )
          ;
      if (pastebin != null) template_explorer.selectEntry(pastebin.ref);
      template_explorer.getShelf()
        .addSeparator(0.25)
          ;
      
      macro_front.addTab("Sheet").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "sheet :").setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      sheet_explorer = macro_front.getTab(1).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setBloc(value_bloc)
          .addEventChange(new Runnable() { public void run() { 
              if (sheet_explorer.starting_bloc != sheet_explorer.selected_bloc && 
                  sheet_explorer.selected_bloc != null && 
                  sheet_explorer.selected_bloc.getBloc("settings") != null &&
                  sheet_explorer.selected_bloc.getBloc("settings").getValue("self") != null && 
                  sheet_explorer.selected_bloc.getBloc("settings").getValue("type") != null && 
                  ((sStr)sheet_explorer.selected_bloc.getBloc("settings").getValue("type")).get().equals("sheet")) {
                Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc
                  .getBloc("settings").getValue("self"))).get());
                if (selected_sheet != mmain()) selected_sheet.open();
                if (s != null) s.select();
              }
          } } )
          ;
      //macro_front.addTab("Preset").getShelf()
      //  .addSeparator(0.125)
      //  .addDrawer(10.25, 1).addModel("Label-S3", "Sheet preset :").setTextAlignment(LEFT, CENTER).getShelf()
      //  .addSeparator()
      //  ;
      //preset_explorer = macro_front.getTab(2).getShelf(0)
      //  .addSeparator()
      //  .addExplorer()
      //    .setBloc(preset_bloc)
      //    .addEventChange(new Runnable() { public void run() { 
      //        //if (sheet_explorer.starting_bloc != sheet_explorer.selected_bloc && 
      //        //    sheet_explorer.selected_bloc != null && sheet_explorer.selected_bloc.getValue("self") != null && 
      //        //    sheet_explorer.selected_bloc.getValue("type") != null && 
      //        //    ((sStr)sheet_explorer.selected_bloc.getValue("type")).get().equals("sheet")) {
      //        //  Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc.getValue("self"))).get());
      //        //  if (selected_sheet != mmain()) selected_sheet.open();
      //        //  s.select();
      //        //}
      //    } } )
      //    ;
      //preset_explorer.getShelf()
      //  .addSeparator(0.25)
      //  .addDrawer(1)
      //    .addCtrlModel("Button-S2-P1", "Save").setRunnable(new Runnable() { public void run() { 
      //      save_preset(); } } ).getDrawer()
      //    .addLinkedModel("Field-S2-P2").setLinkedValue(new_preset_name).getDrawer()
      //    .addCtrlModel("Button-S2-P3", "Load").setRunnable(new Runnable() { public void run() { 
      //      load_preset(); } } ).getDrawer()
      //    .getShelf()
      //  .addSeparator(0.25)
      //  ;
      macro_front.setPosition(
        screen_gui.view.pos.x + screen_gui.view.size.x - macro_front.grabber.getLocalSX() - ref_size * 3, 
        screen_gui.view.pos.y + ref_size * 2 );
      
      macro_front.addEventClose(new Runnable(this) { public void run() { macro_front = null; }});
    } else macro_front.popUp();
  }
  
  void setup_load(sValueBloc b) {
    if (b.getBloc("Macro_Template") != null) {
      saved_template.clean();
      b.getBloc("Macro_Template").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_template.newBloc(b, bloc.base_ref);
      }});
    }
    if (b.getBloc("Main_Sheet") != null) {
      for (Macro_Sheet m : child_sheet) m.setup_load(b.getBloc("Main_Sheet"));
      for (Runnable r : eventsSetupLoad) r.builder = b.getBloc("Main_Sheet");
      runEvents(eventsSetupLoad);
    }
  }
  
  sInterface inter;
  sValueBloc saved_template;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  Macro_Sheet selected_sheet = this, search_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  
  void updateBack() {}
  
Macro_Main(sInterface _int) {
    super(_int);
    inter = _int; 
    cam_gui = inter.cam_gui; 
    screen_gui = inter.screen_gui;
    info = new nInfo(cam_gui, ref_size);
    saved_template = inter.interface_bloc.newBloc("Macro_Template");
      
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable(this) { public void run() { 
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable(this) { public void run() {
      search_sheet.select();
      search_sheet = ((Macro_Sheet)builder);
    }});

    build_macro_menus();

    inter.screen_gui.addEventSetup(new Runnable() { 
      public void run() { 
        //inter.cam.cam_pos.setx(-width / 4);
        //inter.cam.cam_pos.sety(-height / 5);
        //inter.cam.cam_scale.set(0.7);
        
        //build_macro_frontpanel();
      }
    } 
    );
  }
}



























      
