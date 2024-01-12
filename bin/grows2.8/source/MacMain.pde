/*


  

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
    
abstract extend shelfpanel
  can be selected and group dragged copy/pasted > template or deleted

bloc extend abstract
  shelfpanel of element
  methods to add and manipulate element for easy macro building
  show directly connected in/out to detect loop more easily 
    (cad show that an in will directly send through an out of his bloc when receiving)
    use 2 axis aligned lines following elements outlines from connexions to connexions
  
sheet extend abstract
  extended to make Simulation and communitys
  methods for creating blocs inside
    create in grid around center
  can build a menu with all value manipulable with easy drawer
    can choose drawer type when creating value
    can set value limits
  has spot for blocs to display when reducted

main
  is a sheet without grabber and with panel snapped to camera all time
  is extended to interface ? so work standalone with UI
  dont show soft back
  sheet on the main sheet can be snapped to camera, 
    they will keep their place and size and show panel content
    only work when not deployed
  dedicted toolpanel on top left of screen



Template :
  -save to template sValueBloc
    popup for name with field and ok button ?
  -paste last template (or one selected in menu) in selected sheet, 
    if no macro group was selected when created it will copy sheet selected at creation, 
    otherwise it will copy the group of blocs and sheets who was selected
  bloc for auto saving/loading template by name?
    macro can create macro !!!! > basic bloc create

preset :
  -save to preset sValueBloc
    popup for name with field and ok button ?
  bloc for auto saving/loading preset by name?
  saving partial preset, some value marqued as unsavable
    some value choosen to be ignored

basic bloc :
  data, var, random,
  calc, comp, bool, not, bin,
  trigg, switch, keyboard, gate, delay/pulse

complexe bloc : ( in another menu ? )
  template management
    template choosen by name added to selected sheet on bang
  preset save / load
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  setreset, counter, sequance, multigate 
  
MData : sValue access : only hold a string ref, search for corresponding svalue inside current sheet at creation
  ?? if no value is found create one ??
  has in and out
  out can send on change or when receiving bang
  if it cible a vec, the bloc can follow the corresponding position 

MDataCtrl : sValue ctrl : only in + value view
  in can change value multiple way
    bool : set / switch
    num : set / mult / add
    vec : set / mult / add for values rotation and magnitude
    tmpl : in bang > build in same sheet / parent sheet
  
MVar : when a packet is received, display and store it, send it when a bang is received
  can as disable bool input
  
*/
/*

 
             DESIGN
     !! MACRO ARE CRYSTALS !!
 
   hide labels! 
   forme carre > plus petit possible
   overlapp rectangles with those under them to show solidarity
 
 
   GUI to build
     widget jauge / graph
 
     text asking popup
       build it
       call it.popup
       will respond with a runnable
       
 */



void myTheme_MACRO(nTheme theme, float ref_size) {
  theme.addModel("mc_ref", new nWidget()
    .setPassif()
    .setLabelColor(color(200, 200, 220))
    .setFont(int(ref_size/1.6))
    .setOutlineWeight(0)
    .setOutlineColor(color(255, 0))
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
    .setOutlineSelectedColor(color(160))
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
  theme.addModel("MC_Panel_Spot_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(60))
    .setOutlineColor(color(105, 105, 80))
    .setOutlineWeight(ref_size * 1.0 / 16.0)
    .setSize(ref_size*2, ref_size)
    .setFont(int(ref_size/2))
    .setOutline(true)
    );
  theme.addModel("MC_Add_Spot_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(120, 70, 0))
    .setHoveredColor(color(180, 90, 10))
    .setSize(ref_size*2, ref_size*0.5)
    );
  theme.addModel("MC_Add_Spot_Passif", theme.newWidget("MC_Add_Spot_Actif")
    .setStandbyColor(color(50))
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
    .setStandbyColor(color(120, 70, 0))
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
  theme.addModel("MC_Element_Big", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125, ref_size*4.125)
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
    .setStandbyColor(color(10, 40, 80))
    .setOutlineColor(color(10, 110, 220))
    .setOutlineSelectedColor(color(130, 230, 240))
    .setOutlineWeight(ref_size / 16)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*3.125, ref_size*0.875)
    );
  theme.addModel("MC_Element_SField", theme.newWidget("MC_Element_Field")
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*1.375, ref_size*0.875)
    );
  theme.addModel("MC_Element_Text", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(140))
    .setOutlineSelectedColor(color(200))
    .setOutlineWeight(ref_size / 16)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125, ref_size*0.75)
    );
  theme.addModel("MC_Element_SText", theme.newWidget("MC_Element_Text")
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*1.375, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button", theme.newWidget("mc_ref")
    .setStandbyColor(color(10, 40, 80))
    .setHoveredColor(color(10, 110, 220))
    .setClickedColor(color(10, 90, 180))
    .setOutlineColor(color(10, 50, 100))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125, ref_size*0.75)
    );
  theme.addModel("MC_Element_SButton", theme.newWidget("MC_Element_Button")
    //.setPX(-ref_size*0.25)
    .setSize(ref_size*1.375, ref_size*0.75)
    );
  theme.addModel("MC_Element_MiniButton", theme.newWidget("MC_Element_Button")
    .setPosition(ref_size*1 / 16, ref_size * 4 / 16)
    .setSize(ref_size*6 / 16, ref_size*0.5)
    .setFont(int(ref_size/3))
    );
  theme.addModel("MC_Element_Button_Selector_1", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 1 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_2", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 17 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_3", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 35 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_4", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 51 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
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
  theme.addModel("MC_Connect_Default", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(100))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Out_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_Out_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
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
    .setFont(int(ref_size/2))
    .setStandbyColor(color(40))
    .setOutline(false)
    .setPosition(0, -ref_size*4/16)
    .setSize(ref_size*1.5, ref_size*0.75)
    );
}

import java.util.Map;

/*
abstract extend shelfpanel
 can be selected and group dragged copy/pasted > template or deleted
 
 */
class Macro_Abstract extends nShelfPanel implements Macro_Interf {
  
  Macro_Abstract deploy() { open(); return this; }
  Macro_Abstract open() {
    if (openning.get() != OPEN) {
      openning.set(OPEN);
      grabber.show(); grab_front.show(); panel.show(); back.hide(); 
      front.show(); title.show(); reduc.show(); 
      reduc.setPosition(-ref_size, ref_size*0.375);
      moving();
    }
    toLayerTop();
    return this;
  }
  Macro_Abstract reduc() {
    if (openning.get() != REDUC) {
      openning.set(REDUC);
      grabber.show(); grab_front.show(); panel.hide(); back.hide(); 
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
      else if (openning_pre_hide.get() == DEPLOY) deploy();
      //else reduc();
    }
    return this;
  }
  Macro_Abstract hide() {
    if (openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
    }
    grabber.hide(); grab_front.hide(); panel.hide(); back.hide(); 
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
    super.toLayerTop(); panel.toLayerTop(); title.toLayerTop(); grabber.toLayerTop(); 
    reduc.toLayerTop(); front.toLayerTop(); grab_front.toLayerTop(); return this; }

  Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }
  
  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false, title_fixe = false, unclearable = false, pos_given = false;
  float ref_size = 40;
  sVec grab_pos; sStr val_type, val_descr, val_title;
  sInt openning, openning_pre_hide; sObj val_self;
  float prev_x, prev_y; //for group dragging
  nLinkedWidget grabber, title;
  nWidget reduc, front, grab_front, back;
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
    //if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", n);
    if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", value_bloc.base_ref);
    if (grab_pos == null) grab_pos = setting_bloc.newVec("position", "pos");
    else pos_given = true;
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
    grab_front = addModel("mc_ref");
    
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
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
      
      if (mmain().selected_macro.contains(((Macro_Abstract)builder)))
        for (Macro_Abstract m : mmain().selected_macro) if (m != ((Macro_Abstract)builder))
          m.group_move(grabber.getLocalX() - prev_x, grabber.getLocalY() - prev_y);
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY();
      moving(); } });
    grabber.addEventGrab(new Runnable() { public void run() { 
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY(); toLayerTop(); } });
    
    panel.copy(gui.theme.getModel("MC_Panel"));
    panel.setParent(grabber).setPassif();
    panel.setPosition(-grabber.getLocalSX()/4, grabber.getLocalSY()/2 + ref_size * 1 / 8)
      .addEventShapeChange(new Runnable() { public void run() {
        front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } )
      .addEventVisibilityChange(new Runnable() { public void run() {
      if (panel.isHided()) front.setSize(0, 0);
      else front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } );
    
    back = addModel("MC_Sheet_Soft_Back");
    back.clearParent().setPassif();
    back.setParent(grabber).hide();
    
    reduc = addModel("MC_Reduc").clearParent();
    reduc.setParent(panel);
    reduc.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { changeOpenning(); } });
    
    title = addLinkedModel("MC_Title").setLinkedValue(val_title);
    title.addEventFieldChange(new Runnable() { public void run() { title.setOutline(true); } });
    title.clearParent().setParent(panel);
    title.alignDown().stackLeft();
    grabber.addEventMouseEnter(new Runnable() { public void run() { 
      if (openning.get() == REDUC) title.show(); } });
    grabber.addEventMouseLeave(new Runnable() { public void run() { 
      if (openning.get() == REDUC && !title_fixe) title.hide(); } });
    
    front = addModel("MC_Front")
      .setParent(panel).setPassif()
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() != REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(front)) front.setOutline(true);
          else front.setOutline(false); } } } )
      ;
    grab_front = addModel("MC_Front")
      .setParent(grabber).setPassif()
      .setSize(grabber.getLocalSX(), grabber.getLocalSY())
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(grab_front)) grab_front.setOutline(true);
          else grab_front.setOutline(false); } } } )
      ;
    szone_st = new Runnable() { public void run() { 
      szone_selected = false;
      front.setOutline(false); grab_front.setOutline(false); } } ;
    szone_en = new Runnable(this) { public void run() { 
      if (mmain().selected_sheet == sheet && 
          ((openning.get() != REDUC && mmain().szone.isUnder(front) ) || 
           (openning.get() == REDUC && mmain().szone.isUnder(grab_front) )) )  {
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
      if (!mmain().show_macro.get()) hide();
      if (mmain().sheet_explorer != null) mmain().sheet_explorer.update(); 
      if (!pos_given) find_place(); 
      //if (mmain().show_macro.get()) sheet.updateBack(); 
      runEvents(eventsSetupLoad); 
      toLayerTop(); 
    } } );
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
        if (c != this && c.openning.get() == DEPLOY 
            && rectCollide(panel.getRect(), c.back.getRect())) col = true;
        else if (c != this && c.openning.get() == REDUC 
                 && rectCollide(panel.getRect(), c.grabber.getRect())) col = true;
        else if (c != this && c.openning.get() == OPEN 
                 && rectCollide(panel.getRect(), c.panel.getRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == DEPLOY
                 && rectCollide(panel.getPhantomRect(), c.back.getPhantomRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == REDUC
                 && rectCollide(panel.getPhantomRect(), c.grabber.getPhantomRect())) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == OPEN
                 && rectCollide(panel.getPhantomRect(), c.panel.getPhantomRect())) col = true;
      if (sheet != mmain() && openning.get() == HIDE 
          && rectCollide(panel.getPhantomRect(), sheet.panel.getPhantomRect())) col = true;
      if (sheet != mmain() && openning.get() != HIDE 
          && rectCollide(panel.getRect(), sheet.panel.getRect())) col = true;
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
  
  String resum_link() { return ""; }
  
  
  sBoo newBoo(boolean d, String r, String s) { return newBoo(r, s, d); }
  sBoo newBoo(boolean d, String r) { return newBoo(r, r, d); }
  sBoo newBoo(String r, boolean d) { return newBoo(r, r, d); }
  sInt newInt(int d, String r, String s) { return newInt(r, s, d); }
  sFlt newFlt(float d, String r, String s) { return newFlt(r, s, d); }
  sRun newRun(Runnable d, String r, String s) { return newRun(r, s, d); }
  
  sBoo newBoo(String r, String s, boolean d) {
    sBoo v = ((sBoo)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newBoo(r, s, d);
    return v; }
  sInt newInt(String r, String s, int d) {
    sInt v = ((sInt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newInt(r, s, d);
    return v; }
  sFlt newFlt(String r, String s, float d) {
    sFlt v = ((sFlt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newFlt(r, s, d);
    return v; }
  sStr newStr(String r, String s, String d) {
    sStr v = ((sStr)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newStr(r, s, d);
    return v; }
  sVec newVec(String r, String s) {
    sVec v = ((sVec)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newVec(r, s);
    return v; }
  sCol newCol(String r, String s, color d) {
    sCol v = ((sCol)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newCol(r, s, d);
    return v; }
  sRun newRun(String r, String s, Runnable d) {
    sRun v = ((sRun)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newRun(r, s, d);
    else v.set(d);
    return v; }
    
  
  Macro_Abstract addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  
  boolean canSetupFrom(sValueBloc bloc) {
    boolean b = (bloc != null && bloc.getBloc("settings") != null && 
    //        values_found(setting_bloc, bloc.getBloc("settings")) && 
    //        values_found(value_bloc, bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("type")).get().equals(val_type.get()));
    //if (b) log("t"); else log("f");
    return b;
    //return true;
  }
  
  void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      runEvents(eventsSetupLoad);
    }
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
      Macro_Sheet prev_selected = mmain().selected_sheet;
      mmain().selected_sheet.back_front.setOutline(false);
      if (mmain().selected_sheet.openning.get() == DEPLOY)
        mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      else mmain().selected_sheet.grabber.setLook(gui.theme.getLook("MC_Grabber"));
      mmain().selected_macro.clear();
      mmain().selected_sheet = this;
      back_front.setOutline(true);
      grabber.setLook(gui.theme.getLook("MC_Grabber_Selected"));
      prev_selected.cancel_new_spot();
      cancel_new_spot();
      toLayerTop();
      //if (mmain() != this && mmain().preset_explorer != null) mmain().preset_explorer.setBloc(preset_bloc);
    }
    if (mmain().sheet_explorer != null) mmain().sheet_explorer.setBloc(value_bloc);
    return this;
  }
  Macro_Sheet deploy() {
    if (sheet != this && openning.get() != DEPLOY && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      if (sheet.openning.get() != DEPLOY) sheet.deploy();
      openning.set(DEPLOY);
      title_fixe = true; 
      grabber.show(); panel.show(); back.show(); back_front.show();
      front.show(); title.show(); reduc.hide(); deployer.show();
      grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) { m.show(); m.toLayerTop(); }
      //for (Macro_Element m : child_elements) if (m.sheet_connect != null) m.sheet_connect.show();
      updateBack(); 
      moving(); //toLayerTop();
    }
    toLayerTop();
    return this;
  }
  Macro_Sheet open() {
    if (sheet != this && openning.get() != OPEN && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      openning.set(OPEN);
      title_fixe = true; 
      grabber.show(); panel.show(); back.hide(); back_front.hide();
      front.show(); title.show(); reduc.show(); deployer.show();
      reduc.setPosition(-ref_size, ref_size*0.375);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) m.hide();
      //for (Macro_Element m : child_elements) {
      //  if (m.sheet_connect != null && m.spot != null) m.sheet_connect.show();
      //  else if (m.sheet_connect != null && m.spot == null) m.sheet_connect.hide();
      //}
      if (mmain().selected_sheet == this && sheet != this) sheet.select();
      moving(); toLayerTop();
    }
    return this;
  }
  Macro_Sheet reduc() {
    if (sheet != this && openning.get() != REDUC && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      openning.set(REDUC);
      title_fixe = false; 
      grabber.show(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.show(); deployer.hide();
      reduc.setPosition(ref_size * 0.75, ref_size*0.75);
      grabber.setLook(gui.theme.getLook("MC_Grabber"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) m.hide();
      //for (Macro_Element m : child_elements) {
      //  if (m.sheet_connect != null && m.spot != null) m.sheet_connect.reduc();
      //  else if (m.sheet_connect != null && m.spot == null) m.sheet_connect.hide();
      //}
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
      //for (Macro_Element m : child_elements) if (m.sheet_connect != null) m.sheet_connect.hide();
      cancel_new_spot();
      grabber.hide(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.hide(); deployer.hide();
      if (mmain().show_macro.get() && mmain().selected_sheet == this && sheet != this && sheet != mmain()) 
        sheet.select();
    }
    return this;
  }
  Macro_Sheet toLayerTop() { 
    super.toLayerTop(); 
    panel.toLayerTop(); front.toLayerTop();
    grabber.toLayerTop(); deployer.toLayerTop();
    if (child_macro != null) for (Macro_Abstract e : child_macro) e.toLayerTop(); 
    back_front.toLayerTop(); 
    return this;
  }
  
  void add_link(String in, String out) {
    String def = in+INFO_TOKEN+out+OBJ_TOKEN;
    links.set(links.get()+def);
  }
  void remove_link(String in, String out) {
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    String new_list = "";
    for (String l : links_list) {
      String[] link_l = splitTokens(l, INFO_TOKEN);
      String i = link_l[0]; String o = link_l[1];
      //logln("try "+i+" "+o+" for "+in+" "+out);
      if (!i.equals(in) && !o.equals(out)) new_list += l+OBJ_TOKEN;
    }
    links.set(new_list);
  }
  void clear_link() {
    for (Macro_Connexion co1 : child_connect) 
      for (Macro_Connexion co2 : child_connect) if (co1 != co2) co1.disconnect_from(co2);
  }
  void redo_link() {
    //logln("redo_link");
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    clear_link();
    for (String l : links_list) {
      //logln("link "+l);
      String[] link_l = splitTokens(l, INFO_TOKEN);
      if (link_l.length == 2) {
        String i = link_l[0]; String o = link_l[1];
        //logln("in "+i+" out "+o);
        Macro_Connexion in = null, out = null;
        for (Macro_Connexion co : child_connect) {
          if (co.descr.equals(i)) in = co;
          if (co.descr.equals(o)) out = co;
        }
        if (in != null && out != null) {
          //logln("connect");
          in.connect_to(out);
        }
      }
    }
  }
  
  //call by add_spot widget
  void new_spot(String side) {
    left_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); 
    right_spot_add.setBackground().setLook("MC_Add_Spot_Passif");
    for (Macro_Element m : child_elements) if (m.sheet_viewable) {
      m.back.setTrigger().setLook("MC_Element_For_Spot"); /*event in init de l'element*/ }
    building_spot = true;
    new_spot_side = side;
    mmain().inter.addEventFrame(new_spot_run);
  }
  void selecting_element(Macro_Element elem) { // called by eventTrigger of elem.back
    add_spot(new_spot_side, elem);
    cancel_new_spot();
  }
  void cancel_new_spot() {
    
    for (Macro_Element m : child_elements) if (m.sheet_viewable) {
      m.back.setBackground().setLook("MC_Element"); }
    
    mmain().inter.removeEventFrame(new_spot_run);
    if (openning.get() == DEPLOY && mmain().selected_sheet == this) {
      left_spot_add.setTrigger().setLook("MC_Add_Spot_Actif"); 
      right_spot_add.setTrigger().setLook("MC_Add_Spot_Actif"); }
    else {
      left_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); 
      right_spot_add.setBackground().setLook("MC_Add_Spot_Passif"); }
    
    building_spot = false; new_spot_side = "";
  }
  
  void add_spot(String side, Macro_Element elem) {
    String new_str = "";
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    nWidget spot = null;
    if (side.equals("left")) {
      left_s += elem.descr + OBJ_TOKEN;
      
      getShelf(0).removeDrawer(left_spot_drawer);
      spot = getShelf(0).addDrawer(2, 1).addModel("MC_Panel_Spot_Back");
      getShelf(0).insertDrawer(left_spot_drawer);
    } else if (side.equals("right")) {
      right_s += elem.descr + OBJ_TOKEN;
      
      getShelf(1).removeDrawer(right_spot_drawer);
      spot = getShelf(1).addDrawer(2, 1).addModel("MC_Panel_Spot_Back");
      getShelf(1).insertDrawer(right_spot_drawer);
    }
    
    elem.set_spot(spot);
    new_str += left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
  }
  void remove_spot(String ref) {
    String new_str = "";
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    String[] list = splitTokens(left_s, OBJ_TOKEN);
    left_s = OBJ_TOKEN;
    for (String s : list) if (!s.equals(ref)) left_s += s + OBJ_TOKEN;
    
    list = splitTokens(right_s, OBJ_TOKEN);
    right_s = OBJ_TOKEN;
    for (String s : list) if (!s.equals(ref)) right_s += s + OBJ_TOKEN;
    
    new_str += left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
    
    redo_spot();
  }
  void clear_spot() { //clear using and clear spot drawers
    spots.set(OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    for (Macro_Element t : child_elements) t.clear_spot();
    
    getShelf(0).removeDrawer(left_spot_drawer);
    while (getShelf(0).drawers.size() > 0) {
      nDrawer d = getShelf(0).drawers.get(0);
      getShelf(0).removeDrawer(d); d.clear();
    }
    getShelf(0).insertDrawer(left_spot_drawer);
    getShelf(1).removeDrawer(right_spot_drawer);
    while (getShelf(1).drawers.size() > 0) {
      nDrawer d = getShelf(1).drawers.get(0);
      getShelf(1).removeDrawer(d); d.clear();
    }
    getShelf(1).insertDrawer(right_spot_drawer);
    
    cancel_new_spot();
  }
  void redo_spot() {
    //logln("rredo_spot");
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    clear_spot();
    
    String[] list = splitTokens(left_s, OBJ_TOKEN);
    for (String elem_ref : list) {
      Macro_Element e = null;
      for (Macro_Element t : child_elements) if (t.descr.equals(elem_ref)) { e = t; break; }
      if (e != null) add_spot("left", e);
    }
    
    list = splitTokens(right_s, OBJ_TOKEN);
    for (String elem_ref : list) {
      Macro_Element e = null;
      for (Macro_Element t : child_elements) if (t.descr.equals(elem_ref)) { e = t; break; }
      if (e != null) add_spot("right", e);
    }
  }
  //when a spot is used the ref of the element and the nb and side of the spot are saved into the string
  //when the sheet is open click on a spot to reassign it, 
  //  right click to cancel, left click on empty to clear assignment
  //two add spot button > add_spot(side)
   
   
   
  /*
  access system :
    sheet can only be deployed if you have access to them, a low access score can even hide a sheet to you
    introduce the "user" consept (just a keyword for now)
    each sheet have a str with keywords for complete and restricted access
      complete mean can deploy restricted mean can see it
  */
  String see_access = "all", deploy_access = "all";
  Macro_Sheet setSeeAccess(String a) {
    see_access = a;
    if (!mmain().canAccess(a) && openning.get() != HIDE) hide();
    return this;
  }
  Macro_Sheet setDeployAccess(String a) {
    deploy_access = a;
    if (!mmain().canAccess(a) && openning.get() == DEPLOY) open();
    return this;
  }
  
  sStr links;
  sStr spots;
  nWidget right_spot_add, left_spot_add;
  boolean building_spot = false;
  String new_spot_side = "";
  Runnable new_spot_run;
  nDrawer right_spot_drawer, left_spot_drawer;
  
  ArrayList<Macro_Connexion> child_connect = new ArrayList<Macro_Connexion>(0);
  ArrayList<Macro_Element> child_elements = new ArrayList<Macro_Element>(0);
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  ArrayList<Macro_Sheet> child_sheet = new ArrayList<Macro_Sheet>(0);
  
  nWidget back_front, deployer;
  Runnable szone_run;
  
  sStr specialize;
  Sheet_Specialize sheet_specialize = null;
  
  
  
  
 
  /*
  
                  TO DO
  
  develop cursor
    auto size
    dif shape / look
    constrain (dir pos mag ..)
    registered and accessible for
      new comus start
      global effect field
      multi comu objectif
    auto follow / point to objects, instent or chasing
  
  following widgets: > cursors and such
    two widget of different gui will stay at the same relative position
    
  infrastructure :
    structural model switchable (patch structure)
    need used value to be present
  
  link copy when group template
  
  MRamp
    in tick, in reset, out flt, out end
    field for float start, finish ; int length
    driven by tick ramp out from strt to finish
    option : repeat(dents de scie), invert(dents de scie decroissante), loop (aller retour)
  

                    R & D
  
  mtemplate
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  setreset, counter, sequance, multigate 
  
  when selecting a preset a flag widget tell if the values structure is compatible
    auto hide uncompatible widget ? > need to redo explorer < no just filter at list update
  
  mvar should be able to send string packet / should save given value > used for user set val
  
  
  
    
  */
  
    
  /*macro turn:
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
  boolean packet_process_asked = false;
  void ask_packet_process() {
    if (!packet_process_asked) {
      packet_process_asked = true;
      mmain().inter.addEventNextFrame(new Runnable() { public void run() { process_packets(); } });
    }
  }
  
  boolean DEBUG_PACKETS = true;
  void process_packets() {
    boolean done = false; int turn_count = 0, max_turn = 100;
    //String send_resum = value_bloc.ref + " send process resum ";
    //logln(send_resum);
    while (!done || turn_count > max_turn) {
      done = true;
      for (Macro_Connexion m : child_connect) if (m.type == OUTPUT) {
        done = done && m.process_send();
        //send_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == INPUT) {
        done = done && m.process_receive();
        //receive_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == OUTPUT) {
        done = done && m.process_send();
        //send_resum += m.process_resum;
        //log(m.process_resum);
      }
      for (Macro_Connexion m : child_connect) if (m.type == INPUT) {
        done = done && m.process_receive();
        //receive_resum += m.process_resum;
        //log(m.process_resum);
      }
      turn_count++;
    }
    
    if (turn_count > max_turn) {
      String[] llink = splitTokens(mmain().last_created_link, INFO_TOKEN);
      if (llink.length == 2) mmain().last_link_sheet.remove_link(llink[0], llink[1]);
      logln("LOOP");
    }
    
    for (Macro_Connexion m : child_connect) m.end_packet_process();
    
    //logln("turn_count "+turn_count);
    //logln("");
    
    
    if (DEBUG_PACKETS) { //if (turn_count > max_turn && 
      
    }
    packet_process_asked = false;
  }
  
  
Macro_Sheet(Macro_Sheet p, String n, sValueBloc _bloc) { 
    super(p, "sheet", n, _bloc); init(); 
    if (_bloc == null) mmain().inter.addEventNextFrame(new Runnable(this) { public void run() { select(); } });
  }
  Macro_Sheet(sInterface _int) {
    super(_int);
    new_preset_name = setting_bloc.newStr("preset_name", "preset", "preset");
    
    specialize = setting_bloc.newStr("specialize", "specialize", "");
    
    links = setting_bloc.newStr("links", "links", "");
    spots = setting_bloc.newStr("spots", "spots", OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    
    addShelf(); addShelf();
    
    left_spot_add = addModel("mc_ref");
    right_spot_add = addModel("mc_ref");
    back_front = addModel("mc_ref");
    deployer = addModel("mc_ref"); }
  void init() {
    sheet.child_sheet.add(this);
    
    links = ((sStr)(setting_bloc.getValue("links"))); 
    if (links == null) links = setting_bloc.newStr("links", "links", "");
    
    spots = ((sStr)(setting_bloc.getValue("spots"))); 
    if (spots == null) spots = setting_bloc.newStr("spots", "spots", OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    
    new_preset_name = ((sStr)(setting_bloc.getValue("preset_name"))); 
    if (new_preset_name == null) new_preset_name = setting_bloc.newStr("preset_name", "preset", "new");
    specialize = ((sStr)(setting_bloc.getValue("specialize"))); 
    if (specialize == null) specialize = setting_bloc.newStr("specialize", "specialize", "sheet");
    
    back_front = addModel("MC_Front_Sheet")
      .clearParent().setPassif();
    back_front.setParent(back);
    back.addEventShapeChange(new Runnable() { public void run() {
      back_front.setSize(back.getLocalSX(), back.getLocalSY()); } } );
    
    deployer = addModel("MC_Deploy").clearParent();
    deployer.setParent(panel);
    deployer.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { 
      if (openning.get() == DEPLOY) open(); else { deploy(); select(); } } });
    
    left_spot_drawer = addShelf().addDrawer(2, 0.5);
    left_spot_add = left_spot_drawer.addModel("MC_Add_Spot_Passif")
      .addEventTrigger(new Runnable() { public void run() { 
        new_spot("left"); 
      } });
    right_spot_drawer = addShelf().addDrawer(2, 0.5);
    right_spot_add = right_spot_drawer.addModel("MC_Add_Spot_Passif")
      .addEventTrigger(new Runnable() { public void run() { 
        new_spot("right");
      } });
    
    new_spot_run = new Runnable() { public void run() { 
        if (mmain().inter.input.getClick("MouseRight")) cancel_new_spot(); } };
    
    szone_run = new Runnable(this) { public void run() { 
      if (openning.get() != REDUC && mmain().search_sheet.sheet_depth < sheet_depth && 
          mmain().szone.isUnder(back_front)) { 
        mmain().search_sheet = ((Macro_Sheet)builder);
      }
    } };
    
    mmain().szone.addEventStartSelect(szone_run);
    
    updateBack();
    
  }
  
  
  boolean canSetupFrom(sValueBloc bloc) {
    return super.canSetupFrom(bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("specialize")).get().equals(specialize.get());
  }
  
  void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      empty();
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      
      bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        if (!(bloc.ref.equals("settings"))) {
          //search if existing bloc correspond >> unclearable >> setupFromBloc
          boolean found = false;
          if (value_bloc.getBloc(bloc.ref) != null) {
            for (Macro_Abstract m : child_macro) if (m.value_bloc.ref.equals(bloc.ref)) { 
              found = true; 
              m.setupFromBloc(bloc); 
            }
          }
          if (!found) { //sinon
            //add bloc
            sValueBloc nbloc = copy_bloc(bloc, value_bloc, bloc.base_ref);
            
            sValueBloc nbloc_child = mmain().inter.getTempBloc();
            //get nbloc child
            for (Map.Entry me : nbloc.blocs.entrySet()) {
              sValueBloc vb = ((sValueBloc)me.getValue());
              if (!vb.base_ref.equals("settings")) copy_bloc(vb, nbloc_child);
            }
            
            //empty nbloc
            sValueBloc sett_temp = mmain().inter.getTempBloc();
            sValueBloc sbloc = copy_bloc(bloc.getBloc("settings"), sett_temp, "settings");
            for (Map.Entry b : nbloc.blocs.entrySet()) { 
              sValueBloc s = (sValueBloc)b.getValue(); s.clean();
            } 
            nbloc.blocs.clear();
            copy_bloc(sbloc, nbloc);
            sett_temp.clear();
            
            //logln("adding of "+nbloc.ref+" valbloc.blocs size : "+mmain().value_bloc.blocs.size());
            
            //add macro
            Macro_Abstract a = addByBloc(nbloc);
            
            //logln("added    "+nbloc.ref+" valbloc.blocs size : "+mmain().value_bloc.blocs.size());
            
            //add copyed child to new macro
            if (a != null && a.val_type.get().equals("sheet")) {
              ((Macro_Sheet)a).addCopyofBlocContent(nbloc_child);
            }
            
            //no new macro = invalid bloc
            if (a == null) nbloc.clear();
        
            nbloc_child.clear();
          }
        }
      }});
      
      redo_link();
      redo_spot();
      
      runEvents(eventsSetupLoad);
      
      //mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
        else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
        else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
        else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
        if (!mmain().show_macro.get()) hide();
      //} } );
    }
  }
  
  
  Macro_Sheet clear() {
    //an unclearable sheet still need to clear child macro
    empty();
    if (!unclearable) {
      super.clear();
      sheet.child_sheet.remove(this);
      value_bloc.clear();
      if (mmain() != this) mmain().szone.removeEventStartSelect(szone_run);
      if (preset_explorer != null) mmain().presets_explorers.remove(preset_explorer);
      sheet_specialize.sheet_count--;
    }
    return this;
  }
  Macro_Sheet empty() {
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    child_sheet.clear();
    //clear spots
    updateBack();
    return this;
  }
  
  nFrontTab custom_tab;
  
  Macro_Sheet addEventsBuildMenu(Runnable r) { eventsBuildMenu.add(r); return this; }
  ArrayList<Runnable> eventsBuildMenu = new ArrayList<Runnable>();

  sInt menuIntSlide(int v, int _min, int _max, String r) {
    sInt f = newInt(v, r, r);
    f.set_limit(_min, _max);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf().addDrawer(10, 1)
      .addModel("Label_Small_Text-S1-P1", ((sInt)builder).ref)
        .setTextAlignment(LEFT, CENTER).getDrawer()
      .addWatcherModel("Auto_Watch_Label-S1-P3")
        .setLinkedValue(((sInt)builder))
        .setTextAlignment(CENTER, CENTER).getDrawer()
      .addWidget(new nSlide(custom_tab.gui, ref_size * 6, ref_size * 0.75)
        .setValue( float( ((sInt)builder).get() - ((sInt)builder).getmin() ) / 
                   float( ((sInt)builder).getmax() - ((sInt)builder).getmin() ) )
        .addEventSlide(new Runnable(((sInt)builder)) { public void run(float c) { 
          ((sInt)builder).set( int( ((sInt)builder).getmin() + 
                                    c * (((sInt)builder).getmax() - ((sInt)builder).getmin()) ) ); 
        } } )
        .setPosition(4*ref_size, ref_size * 2 / 16) ).getShelf()
      .addSeparator(0.125);
    } });
    return f;
  }
  sFlt menuFltSlide(float v, float _min, float _max, String r) {
    sFlt f = newFlt(v, r, r);
    f.set_limit(_min, _max);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf().addDrawer(10, 1)
      .addModel("Label_Small_Text-S1-P1", ((sFlt)builder).ref)
        .setTextAlignment(LEFT, CENTER).getDrawer()
      .addWatcherModel("Auto_Watch_Label-S1-P3")
        .setLinkedValue(((sFlt)builder))
        .setTextAlignment(CENTER, CENTER).getDrawer()
      .addWidget(new nSlide(custom_tab.gui, ref_size * 6, ref_size * 0.75)
        .setValue( ( ((sFlt)builder).get() - ((sFlt)builder).getmin() ) / 
                   ( ((sFlt)builder).getmax() - ((sFlt)builder).getmin() ) )
        .addEventSlide(new Runnable(((sFlt)builder)) { public void run(float c) { 
          ((sFlt)builder).set( ((sFlt)builder).getmin() + 
                               c * (((sFlt)builder).getmax() - ((sFlt)builder).getmin()) ); 
        } } )
        .setPosition(4*ref_size, ref_size * 2 / 16) ).getShelf()
      .addSeparator(0.125);
    } });
    return f;
  }
  sCol menuColor(color v, String r) {
    sCol f = newCol(r, r, v);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
        .addDrawer(10, 1)
        .addCtrlModel("Auto_Button-S2-P3", "choose").setRunnable(new Runnable(builder) { public void run() { 
          new nColorPanel(custom_tab.gui, mmain().inter.taskpanel, ((sCol)builder));
        } } ).getDrawer()
        .addWatcherModel("Auto_Watch_Label-S6/1", "Color picker: " + ((sCol)builder).ref)
          .setLinkedValue(((sCol)builder))
          .setTextAlignment(LEFT, CENTER).getDrawer()
        .getShelf()
        .addSeparator(0.125);
    } });
    return f;
  }
  sInt menuIntWatch(int v, String r) {
    sInt f = newInt(v, r, r);
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerWatch(((sInt)builder), 10, 1)
      .addSeparator(0.125);
    } });
    return f;
  }
  sFlt menuFltIncr(float v, float _f, String r) {
    sFlt f = newFlt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerIncrValue(((sFlt)builder), ((sFlt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125);
    } });
    return f;
  }
  sFlt menuFltFact(float v, float _f, String r) {
    sFlt f = newFlt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerFactValue(((sFlt)builder), ((sFlt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125);
    } });
    return f;
  }
  sInt menuIntIncr(int v, float _f, String r) {
    sInt f = newInt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerIncrValue(((sInt)builder), ((sInt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125);
    } });
    return f;
  }
  sInt menuIntFact(int v, float _f, String r) {
    sInt f = newInt(v, r, r);
    f.ctrl_factor = _f;
    addEventsBuildMenu(new Runnable(f) { public void run() { 
      if (custom_tab != null) custom_tab.getShelf()
      .addDrawerFactValue(((sInt)builder), ((sInt)builder).ctrl_factor, 10, 1)
      .addSeparator(0.125);
    } });
    return f;
  }
  
  nFrontPanel sheet_front;  
  nExplorer sheet_viewer, preset_explorer;
  sStr new_preset_name;
  
  
  void build_custom_menu(nFrontPanel sheet_front) {}
  
  void build_sheet_menu() {
    if (sheet_front == null) {
      sheet_front = new nFrontPanel(mmain().screen_gui, mmain().inter.taskpanel, val_title.get());
      
      sheet_front.addTab("View").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "sheet view :").setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      sheet_viewer = sheet_front.getTab(0).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setChildAccess(false)
          .setStrtBloc(value_bloc)
          .addEventChange(new Runnable() { public void run() { 
              if (sheet_viewer.explored_bloc != value_bloc) {
                sheet_viewer.setStrtBloc(value_bloc);
              }
          } } )
          ;
      sheet_front.addTab("Preset").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "Sheet values preset :").setTextAlignment(LEFT, CENTER).getDrawer()
        .addCtrlModel("Button-S2-P3", "Delete").setRunnable(new Runnable() { public void run() { 
          preset_explorer.selected_bloc.clear(); 
          for (nExplorer e : mmain().presets_explorers) e.update(); } } )
          .setInfo("delete selected preset").getShelf()
        .addSeparator()
        ;
      preset_explorer = sheet_front.getTab(1).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setStrtBloc(mmain().saved_preset)
          //.addEventChange(new Runnable() { public void run() { 
          //} } )
          ;
      mmain().presets_explorers.add(preset_explorer);
      
      preset_explorer.getShelf()
        .addSeparator(0.25)
        .addDrawer(1)
          .addCtrlModel("Button-S2-P1", "Save").setRunnable(new Runnable() { public void run() { 
            save_preset(); } } ).setInfo("Save sheet values as preset").getDrawer()
          .addLinkedModel("Field-S2-P2").setLinkedValue(new_preset_name).getDrawer()
          .addCtrlModel("Button-S2-P3", "Load").setRunnable(new Runnable() { public void run() { 
            load_preset(); } } ).setInfo("load corresponding preset values into sheet values").getDrawer()
          .getShelf()
        .addSeparator(0.25)
        ;
      //sheet_front.setPosition(
      //  screen_gui.view.pos.x + screen_gui.view.size.x - sheet_front.grabber.getLocalSX() - ref_size * 3, 
      //  screen_gui.view.pos.y + ref_size * 2 );
      
      custom_tab = sheet_front.addTab("User");

      custom_tab.getShelf()
        .addDrawer(10.25, 1)
        .addModel("Label-S4", "-  Control  -").setFont(int(ref_size/1.8)).getShelf()
        .addSeparator(0.125)
        ;
      runEvents(eventsBuildMenu);
      
      build_custom_menu(sheet_front);
      
      sheet_front.addEventClose(new Runnable(this) { public void run() { 
        if (preset_explorer != null) mmain().presets_explorers.remove(preset_explorer);
        sheet_front = null; }});
    } else sheet_front.popUp();
  }
  
  void save_preset() {
    Save_Bloc b = new Save_Bloc("");
    value_bloc.preset_value_to_save_bloc(b);
    mmain().saved_preset.newBloc(b, new_preset_name.get());
    for (nExplorer e : mmain().presets_explorers) { 
      e.update();
      e.selectEntry(new_preset_name.get());
    }
  }
  void load_preset() {
    if (preset_explorer.selected_bloc != null) {
      transfer_bloc_values(preset_explorer.selected_bloc, value_bloc);
    }
  }
  
  String new_ref = "";
  
  void addCopyofBlocContent(sValueBloc bloc) {
    //copy under bloc to value_bloc, do addByBloc with the copy, save new ref change if any
    new_ref = "";
    bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
      if (!bloc.ref.equals("settings")) {
        
        //add bloc
        sValueBloc nbloc = copy_bloc(bloc, value_bloc, bloc.base_ref);
        
        sValueBloc nbloc_child = mmain().inter.getTempBloc();
        //get nbloc child
        for (Map.Entry me : nbloc.blocs.entrySet()) {
          sValueBloc vb = ((sValueBloc)me.getValue());
          if (!vb.base_ref.equals("settings")) copy_bloc(vb, nbloc_child);
        }
        
        //empty nbloc
        sValueBloc sett_temp = mmain().inter.getTempBloc();
        sValueBloc sbloc = copy_bloc(bloc.getBloc("settings"), sett_temp, "settings");
        for (Map.Entry b : nbloc.blocs.entrySet()) { 
          sValueBloc s = (sValueBloc)b.getValue(); s.clean();
        } 
        nbloc.blocs.clear();
        copy_bloc(sbloc, nbloc);
        sett_temp.clear();
        
        //add macro
        Macro_Abstract a = addByBloc(nbloc);
        if (a != null) new_ref = new_ref + OBJ_TOKEN + bloc.base_ref+OBJ_TOKEN+nbloc.ref;
        
        //add copyed child to new macro
        if (a != null && a.val_type.get().equals("sheet")) 
          ((Macro_Sheet)a).addCopyofBlocContent(nbloc_child);
        
        //no new macro = invalid bloc
        if (a == null) nbloc.clear();
        
        nbloc_child.clear();
      } 
    }});
    
    
    //si bloc/links 
    if (bloc.getValue("links") != null) {
      String link_s = ((sStr)bloc.getValue("links")).get();
      //  change bloc name in bloc links
      //String new_links = "";
      String[] change_list = splitTokens(new_ref, OBJ_TOKEN);
      String[] nlink_list = splitTokens(link_s, OBJ_TOKEN);
      //String newlink = "";
      for (String l : nlink_list) {
        String[] linkpart = splitTokens(l, INFO_TOKEN);
        //String newco = "";
        for (String k : linkpart) {
          String[] copart = splitTokens(k, BLOC_TOKEN);
          for (int i = 0 ; i < change_list.length ; i += 2) {
            if (copart.length > 0 && copart[0].equals(change_list[i])) {
              copart[0] = change_list[i+1];
            }
            if (copart.length > 1 && copart[1].equals(change_list[i])) {
              copart[1] = change_list[i+1];
            }
          }
          if (copart.length > 1) {
            add_link(copart[0], copart[1]);
          }
        }
      }
    }
    redo_link();
    redo_spot();
  }
  
  //b need to be child of value_bloc and have setting/type + spe , everything else can be created
  Macro_Abstract addByBloc(sValueBloc b) { 
    if (b != null && b.parent == value_bloc && b.getBloc("settings") != null && 
        b.getBloc("settings").getValue("type") != null) {
      
      String typ = ((sStr)b.getBloc("settings").getValue("type")).get();
      
      if (!typ.equals("sheet"))   return addByType(typ, b);
      
      else if (b.getBloc("settings").getValue("specialize") != null) {
        
        String spe = ((sStr)b.getBloc("settings").getValue("specialize")).get();
        
        for (Sheet_Specialize t : Sheet_Specialize.prints) if (!t.unique && t.name.equals(spe))
          return t.add_new(this, b, null);
      }
    }
    return null; 
  }
  
  Macro_Abstract addByType(String t) { return addByType(t, null); }
  Macro_Abstract addByType(String t, sValueBloc b) { 
    if (t.equals("data")) return addData(b);
    else if (t.equals("in")) return addSheetIn(b);
    else if (t.equals("out")) return addSheetOut(b);
    else if (t.equals("keyb")) return addKey(b);
    else if (t.equals("switch")) return addSwitch(b);
    else if (t.equals("trig")) return addTrig(b);
    else if (t.equals("gate")) return addGate(b);
    else if (t.equals("not")) return addNot(b);
    else if (t.equals("bin")) return addBin(b);
    else if (t.equals("bool")) return addBool(b);
    else if (t.equals("var")) return addVar(b);
    else if (t.equals("pulse")) return addPulse(b);
    else if (t.equals("calc")) return addCalc(b);
    else if (t.equals("comp")) return addComp(b);
    else if (t.equals("chan")) return addChan(b);
    else if (t.equals("vecXY")) return addVecXY(b);
    else if (t.equals("vecMD")) return addVecMD(b);
    else if (t.equals("frame")) return addFrame(b);
    else if (t.equals("numCtrl")) return addNumCtrl(b);
    else if (t.equals("vecCtrl")) return addVecCtrl(b);
    else if (t.equals("rng")) return addRng(b);
    else if (t.equals("mouse")) return addMouse(b);
    else if (t.equals("cursor")) return addCursor(b);
    else if (t.equals("com")) return addComment(b);
    //else if (t.equals("tmpl")) return addTmpl(b);
    else if (t.equals("prst")) return addPrst(b);
    else if (t.equals("menu")) return addMenu(b);
    else if (t.equals("tool")) return addTool(b);
    else if (t.equals("toolbin")) return addToolBin(b);
    else if (t.equals("tooltri")) return addToolTri(b);
    else if (t.equals("toolNC")) return addToolNCtrl(b);
    else if (t.equals("pan")) return addPanel(b);
    else if (t.equals("panbin")) return addPanBin(b);
    else if (t.equals("pansld")) return addPanSld(b);
    else if (t.equals("pangrph")) return addPanGrph(b);
    //else if (t.equals("pancstm")) return addPanCstm(b);
    return null;
  }
  
  MData addData(sValueBloc b) { MData m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MData(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MData(this, b, mmain().sheet_explorer.selected_value);
    else m = new MData(this, b, null); return m; }
  MSheetIn addSheetIn(sValueBloc b) { MSheetIn m = new MSheetIn(this, b); return m; }
  MSheetOut addSheetOut(sValueBloc b) { MSheetOut m = new MSheetOut(this, b); return m; }
  MKeyboard addKey(sValueBloc b) { MKeyboard m = new MKeyboard(this, b); return m; }
  MSwitch addSwitch(sValueBloc b) { MSwitch m = new MSwitch(this, b); return m; }
  MTrig addTrig(sValueBloc b) { MTrig m = new MTrig(this, b); return m; }
  MGate addGate(sValueBloc b) { MGate m = new MGate(this, b); return m; }
  MNot addNot(sValueBloc b) { MNot m = new MNot(this, b); return m; }
  MBin addBin(sValueBloc b) { MBin m = new MBin(this, b); return m; }
  MBool addBool(sValueBloc b) { MBool m = new MBool(this, b); return m; }
  MVar addVar(sValueBloc b) { MVar m = new MVar(this, b); return m; }
  MPulse addPulse(sValueBloc b) { MPulse m = new MPulse(this, b); return m; }
  MCalc addCalc(sValueBloc b) { MCalc m = new MCalc(this, b); return m; }
  MComp addComp(sValueBloc b) { MComp m = new MComp(this, b); return m; }
  MChan addChan(sValueBloc b) { MChan m = new MChan(this, b); return m; }
  MVecXY addVecXY(sValueBloc b) { MVecXY m = new MVecXY(this, b); return m; }
  MVecMD addVecMD(sValueBloc b) { MVecMD m = new MVecMD(this, b); return m; }
  MFrame addFrame(sValueBloc b) { MFrame m = new MFrame(this, b); return m; }
  MNumCtrl addNumCtrl(sValueBloc b) { MNumCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MNumCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MNumCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MNumCtrl(this, b, null); return m; }
  MVecCtrl addVecCtrl(sValueBloc b) { MVecCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MVecCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MVecCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MVecCtrl(this, b, null); return m; }
  MRandom addRng(sValueBloc b) { MRandom m = new MRandom(this, b); return m; }
  MMouse addMouse(sValueBloc b) { MMouse m = new MMouse(this, b); return m; }
  MCursor addCursor(sValueBloc b) { MCursor m = new MCursor(this, b); return m; }
  MComment addComment(sValueBloc b) { MComment m = new MComment(this, b); return m; }
  //MTemplate addTmpl(sValueBloc b) { MTemplate m = new MTemplate(this, b); return m; }
  MPreset addPrst(sValueBloc b) { MPreset m = new MPreset(this, b); return m; }
  MMenu addMenu(sValueBloc b) { MMenu m = new MMenu(this, b); return m; }
  MTool addTool(sValueBloc b) { MTool m = new MTool(this, b); return m; }
  MToolBin addToolBin(sValueBloc b) { MToolBin m = new MToolBin(this, b); return m; }
  MToolTri addToolTri(sValueBloc b) { MToolTri m = new MToolTri(this, b); return m; }
  MToolNCtrl addToolNCtrl(sValueBloc b) { MToolNCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) 
      m = new MToolNCtrl(this, b, sheet_viewer.selected_value);
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) 
      m = new MToolNCtrl(this, b, mmain().sheet_explorer.selected_value);
    else m = new MToolNCtrl(this, b, null); return m; }
  MPanel addPanel(sValueBloc b) { MPanel m = new MPanel(this, b); return m; }
  MPanBin addPanBin(sValueBloc b) { MPanBin m = new MPanBin(this, b); return m; }
  MPanSld addPanSld(sValueBloc b) { MPanSld m = new MPanSld(this, b); return m; }
  MPanGrph addPanGrph(sValueBloc b) { MPanGrph m = new MPanGrph(this, b); return m; }
  //MPanCstm addPanCstm(sValueBloc b) { MPanCstm m = new MPanCstm(this, b); return m; }
  
}





interface Macro_Interf {
  static final int INPUT = 0, OUTPUT = 1, NO_CO = 2;
  static final int HIDE = 0, REDUC = 1, OPEN = 2, DEPLOY = 3;
  static final String OBJ_TOKEN = "@", GROUP_TOKEN = "¤", INFO_TOKEN = "#", BLOC_TOKEN = "~";
  final String[] bloc_types1 = {"in", "out", "trig", "switch", "gate", "not", "pulse", "frame", 
                                "bin", "bool", "var", "rng", "calc", "comp", "chan", "data" };
  final String[] bloc_types2 = {"com", "vecXY", "vecMD", "vecCtrl", "numCtrl", "mouse", "keyb", 
                                "cursor", "prst", "tool", "tooltri", "toolbin", "toolNC", "pan", 
                                "panbin", "pansld", "pangrph", "menu"}; //, "pancstm", "tmpl"
}






static abstract class Sheet_Specialize {
  static int count = 0;
  static ArrayList<Sheet_Specialize> prints = new ArrayList<Sheet_Specialize>();
  
  Macro_Main mmain;
  String name, build_access = "all";
  int sheet_count = -1;
  boolean unique = false;
  
  Sheet_Specialize(String n) { name = n;  
    prints.add(this); 
    count++;
  }
  
  Macro_Sheet add_new(Macro_Sheet s, sValueBloc b, Macro_Sheet p ) { 
    if (mmain.canAccess(build_access) && (!unique || (unique && sheet_count == -1))) { 
      sheet_count++; 
      Macro_Sheet m = null;
      if (b == null && p == null) m = get_new(s, name + "_" + sheet_count, (sValueBloc)null);
      else if (b != null) m = get_new(s, b.base_ref, (sValueBloc)b);
      else if (p != null) m = get_new(s, p.value_bloc.base_ref, p);
      m.sheet_specialize = this; m.specialize.set(name); if (unique) m.unclearable = true;
      return m; } 
    else return null; }
  protected abstract Macro_Sheet get_new(Macro_Sheet s, String n, sValueBloc b);
  protected Macro_Sheet get_new(Macro_Sheet s, String n, Macro_Sheet b) { return null; }
}



class SheetPrint extends Sheet_Specialize {
  SheetPrint() { super("sheet"); }
  Macro_Sheet get_new(Macro_Sheet s, String n, sValueBloc b) { return new Macro_Sheet(s, n, b); }
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
  //nFrontPanel macro_front;  
  nToolPanel macro_tool, build_tool, sheet_tool;
  nExplorer template_explorer, sheet_explorer;
  sValueBloc pastebin = null;
  
  ArrayList<nExplorer> presets_explorers = new ArrayList<nExplorer>();
  
  void copy_to_tmpl() {
    if (selected_macro.size() > 0) {
      sValueBloc bloc = saved_template.newBloc("group_"+selected_macro.size());
      for (Macro_Abstract m : selected_macro) copy_bloc(m.value_bloc, bloc);
      pastebin = saved_template.last_created_bloc;
      sStr tmp_link = new sStr(pastebin, "links", "links", "");
      for (Macro_Abstract m : selected_macro) {
        tmp_link.set(tmp_link.get() + m.resum_link());
      }
      for (Map.Entry me : pastebin.blocs.entrySet()) {
        sValueBloc vb = ((sValueBloc)me.getValue());
        if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
          sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
          v.setx(v.x() + ref_size * 2); v.sety(v.y() + ref_size * 3);
        }
      }
    } else if (selected_sheet != this) {
      sValueBloc bloc = saved_template.newBloc("sheet_"+selected_sheet.val_title.get());
      copy_bloc(selected_sheet.value_bloc, bloc);
      pastebin = saved_template.last_created_bloc;
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(selected_sheet.value_bloc.base_ref); }
    }
  }
  void paste_tmpl() {
    if (template_explorer != null && template_explorer.selected_bloc != null) {
      selected_sheet.addCopyofBlocContent(template_explorer.selected_bloc);
      if (sheet_explorer != null) sheet_explorer.update();
    }
    else if (pastebin != null) {
      selected_sheet.addCopyofBlocContent(pastebin);
    }
  }

  void build_macro_menus() {
    if (macro_tool != null) macro_tool.clear();
    macro_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    macro_tool.addShelf().addDrawer(4.375, 1)
        .addLinkedModel("Menu_Button_Small_Outline-S1-P1", "S")
          .setLinkedValue(show_macro)
          .setInfo("show/hide macros").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "X")
          .setRunnable(new Runnable() { public void run() { 
          for (Macro_Abstract m : selected_macro) m.clear(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("delete selected bloc").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "E")
          .setRunnable(new Runnable() { public void run() { 
            selected_sheet.empty(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("Empty selected sheet").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P4", "C")
          .setRunnable(new Runnable() { public void run() { copy_to_tmpl(); }})
          .setInfo("copy selected blocs or sheet to template").setFont(int(ref_size/1.7)).getShelfPanel()
      .addShelf().addDrawer(2.125, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "P")
          .setRunnable(new Runnable() { public void run() { paste_tmpl(); }})
          .setInfo("Paste selected template in selected sheet").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "M")
          .setRunnable(new Runnable() { public void run() { build_sheet_menu(); }})
          .setInfo("Template management and sheets overview").setFont(int(ref_size/1.7)).getShelfPanel()
      .addShelf().addDrawer(2.125, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "QS")
          .setRunnable(new Runnable() { public void run() { inter.full_data_save(); }})
          .setInfo("Quick Save").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "QL")
          .setRunnable(new Runnable() { public void run() { inter.setup_load(); }})
          .setInfo("Quick Load").setFont(int(ref_size/1.9));
    if (!show_macro_tool.get()) macro_tool.reduc();
    macro_tool.addEventReduc(new Runnable() { public void run() { 
      show_macro_tool.set(!macro_tool.hide); }});
    
    if (build_tool != null) build_tool.clear();
    build_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    build_tool.addShelf();
    for (String t : bloc_types2) build_tool.getShelf(0).addDrawer(2.5, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(int(ref_size/2)).setTextAlignment(LEFT, CENTER)
        ;
    build_tool.addShelf();
    for (String t : bloc_types1) build_tool.getShelf(1).addDrawer(2.5, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(int(ref_size/2)).setTextAlignment(LEFT, CENTER)
        ;
    if (!show_build_tool.get()) build_tool.reduc();
    build_tool.addEventReduc(new Runnable() { public void run() { 
      show_build_tool.set(!build_tool.hide); }});
    build_tool.panel.setPY(ref_size*1.625);
    
    if (sheet_tool != null) sheet_tool.clear();
    sheet_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    sheet_tool.addShelf();
    
    for (Sheet_Specialize t : Sheet_Specialize.prints) if (!t.unique) sheet_tool.getShelf(0).addDrawer(3, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S3/0.75", t.name)
        .setRunnable(new Runnable(t) { public void run() { 
          ((Sheet_Specialize)builder).add_new(selected_sheet, null, null); }})
        .setFont(int(ref_size/2));
        ;
    
    if (!show_sheet_tool.get()) sheet_tool.reduc();
    sheet_tool.addEventReduc(new Runnable() { public void run() { 
      show_sheet_tool.set(!sheet_tool.hide); }});
    sheet_tool.panel.setPY(ref_size*16.75);
  }
  void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Interface");
    tab.getShelf()
      .addDrawer(10.25, 1)
      .addModel("Label-S4", "- Interface -").setFont(int(ref_size/1.4)).getShelf()
      .addSeparator(0.125)
      .addDrawerDoubleButton(inter.auto_load, inter.filesm_run, 10, 1)
      .addSeparator(0.125)
      .addDrawerDoubleButton(inter.quickload_run, inter.quicksave_run, 10, 1)
      .addSeparator(0.125)
      ;
    
    tab = sheet_front.addTab("Explorer");
    tab.getShelf()
      .addSeparator(0.125)
      .addDrawer(10.25, 1).addModel("Label-S3", "sheets explorer :").setTextAlignment(LEFT, CENTER).getShelf()
      .addSeparator()
      ;
    sheet_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(value_bloc)
        .addEventChange(new Runnable() { public void run() { 
            if (value_bloc != sheet_explorer.selected_bloc && 
                sheet_explorer.selected_bloc != null && 
                sheet_explorer.selected_bloc.getBloc("settings") != null &&
                sheet_explorer.selected_bloc.getBloc("settings").getValue("self") != null && 
                sheet_explorer.selected_bloc.getBloc("settings").getValue("type") != null && 
                ((sStr)sheet_explorer.selected_bloc.getBloc("settings").getValue("type")).get().equals("sheet")) {
              Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc
                .getBloc("settings").getValue("self"))).get());
              selected_sheet.open();
              if (s != null) s.select();
            } else if (value_bloc == sheet_explorer.explored_bloc) {
              selected_sheet.open();
              select();
            }
        } } )
        ;
        
    tab = sheet_front.addTab("Template");
    tab.getShelf()
      .addSeparator(0.125)
      .addDrawer(10.25, 1).addModel("Label-S3", "Templates :").setTextAlignment(LEFT, CENTER).getShelf()
      .addSeparator()
      ;
    template_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(saved_template)
        .addEventChange(new Runnable() { public void run() { } } )
        ;
    if (pastebin != null) template_explorer.selectEntry(pastebin.ref);
    template_explorer.getShelf()
      .addSeparator(0.25)
        ;
    
  }
  /*
  setup loading : 
    clear everything
      macro, template, presets, clear call to simulation
    search setup file:
      interface data : transfer values
      template, preset : copy blocs
      for blocs inside main sheet :
        sheet bloc : (has all settings)
          allready same name n spe sheet : transfer value, copy inside blocs and values
          no same name sheet : copy full bloc, build sheet with 
          same name but diff spe : delete it then do as if no same name sheet
        not a sheet bloc : delete it
    load corresponding gui property
  
  */
  void setup_load(sValueBloc b) {
    if (b.getBloc("Template") != null) {
      saved_template.clean();
      b.getBloc("Template").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_template.newBloc(b, bloc.base_ref);
      }});
    }if (b.getBloc("Preset") != null) {
      saved_preset.clean();
      b.getBloc("Preset").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_preset.newBloc(b, bloc.base_ref);
      }});//
    }
    
    setupFromBloc(b.getBloc(value_bloc.base_ref));

    if (b.getValue("show_macro") != null) 
      show_macro.set(((sBoo)b.getValue("show_macro")).get());
    if (b.getValue("show_build_tool") != null) 
      show_build_tool.set(((sBoo)b.getValue("show_build_tool")).get());
    if (b.getValue("show_sheet_tool") != null) 
      show_sheet_tool.set(((sBoo)b.getValue("show_sheet_tool")).get());
    if (b.getValue("show_macro_tool") != null) 
      show_macro_tool.set(((sBoo)b.getValue("show_macro_tool")).get());
    
    if (sheet_explorer != null) sheet_explorer.update();
    inter.addEventNextFrame(new Runnable() { public void run() { 
      inter.addEventNextFrame(new Runnable() { public void run() { select(); } } ); } } );
  }
  
  sBoo show_gui, show_macro, show_build_tool, show_sheet_tool, show_macro_tool;
  //sInt val_scale;
  sInterface inter;
  sValueBloc saved_template, saved_preset;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  Macro_Sheet selected_sheet = this, search_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  boolean buildingLine = false;
  String access;
  boolean canAccess(String a) { return inter.canAccess(a); }
  String last_created_link = "";
  ArrayList<MChan> chan_macros = new ArrayList<MChan>();
  ArrayList<MPanel> pan_macros = new ArrayList<MPanel>();
  ArrayList<MTool> tool_macros = new ArrayList<MTool>();
  int pan_nb = 0, tool_nb = 0;
  Macro_Sheet last_link_sheet = null;
  
  void updateBack() {}
  
Macro_Main(sInterface _int) {
    super(_int);
    inter = _int; 
    access = inter.getAccess();
    cam_gui = inter.cam_gui; 
    screen_gui = inter.screen_gui;
    info = new nInfo(cam_gui, ref_size);
    saved_template = inter.interface_bloc.newBloc("Template");
    saved_preset = inter.interface_bloc.newBloc("Preset");
    
    show_macro = setting_bloc.newBoo("show_macro", "show", true);
    show_macro.addEventChange(new Runnable(this) { public void run() { 
      if (show_macro.get()) for (Macro_Abstract m : child_macro) m.show();
      else for (Macro_Abstract m : child_macro) m.hide();
    }});
    
    show_build_tool = setting_bloc.newBoo("show_build_tool", "build tool", true);
    show_build_tool.addEventChange(new Runnable(this) { public void run() { 
      if (build_tool != null && build_tool.hide == show_build_tool.get()) build_tool.reduc();
    }});
    show_sheet_tool = setting_bloc.newBoo("show_sheet_tool", "sheet tool", true);
    show_sheet_tool.addEventChange(new Runnable(this) { public void run() { 
      if (sheet_tool != null && sheet_tool.hide == show_sheet_tool.get()) sheet_tool.reduc();
    }});
    show_macro_tool = setting_bloc.newBoo("show_macro_tool", "macro tool", true);
    show_macro_tool.addEventChange(new Runnable(this) { public void run() { 
      if (macro_tool != null && macro_tool.hide == show_macro_tool.get()) macro_tool.reduc();
    }});
    show_gui = newBoo("show_gui", "show gui", true);
    show_gui.addEventChange(new Runnable(this) { public void run() { 
      screen_gui.isShown = show_gui.get();
      inter.show_info = show_gui.get();
    }});
    
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable(this) { public void run() { 
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable(this) { public void run() {
      search_sheet.select();
      search_sheet = ((Macro_Sheet)builder);
    }});
    
    addSpecializedSheet(new SheetPrint());
    
    //val_scale = menuIntSlide(int(ref_size), 1, 100, "val_scale");
    //val_scale.addEventChange(new Runnable(this) { public void run() {
    //  boolean b = int(ref_size) == val_scale.get();
    //  ref_size = val_scale.get();
    //  if (b) inter.quicksave_run.run();
    //  //if (b) inter.quickload_run.run();
    //}});

    inter.addEventSetupLoad(new Runnable() { 
      public void run() { 
        
        //ref_size = val_scale.get();
      }
    } 
    );
  }
  
  void addSpecializedSheet(Sheet_Specialize s) {
    s.mmain = this;
    build_macro_menus();
  }
  Macro_Sheet addUniqueSheet(Sheet_Specialize s) {
    s.mmain = this;
    s.unique = true;
    build_macro_menus();
    return s.add_new(this, null, null);
  }
}



























      
