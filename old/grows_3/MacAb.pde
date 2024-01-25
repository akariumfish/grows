
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
      reduc.setPosition(-ref_size, ref_size*0.25);
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
  
  void szone_select() {
    if (mmain().selected_sheet != sheet) sheet.select();
    mmain().selected_macro.add(this);
    szone_selected = true;
    mmain().update_select_bound();
    if (openning.get() == REDUC) grab_front.setOutline(true);
    else front.setOutline(true);
    toLayerTop();
  }
  void szone_unselect() {//carefull! still need to remove from mmain.selected_macro and run mmain.update_select_bound
    szone_selected = false;
    front.setOutline(false);
    grab_front.setOutline(false);
  }
  
  void moving() { 
    sheet.movingChild(this); 
  }
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
    reduc.toLayerTop(); prio_sub.toLayerTop(); prio_add.toLayerTop(); prio_view.toLayerTop(); 
    front.toLayerTop(); grab_front.toLayerTop(); return this; }

  Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }
  
  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false, title_fixe = false, unclearable = false, pos_given = false;
  float ref_size = 40;
  sVec grab_pos; sStr val_type, val_descr, val_title;
  sInt priority, openning, openning_pre_hide; sObj val_self;
  float prev_x, prev_y; //for group dragging
  nLinkedWidget grabber, title; nCtrlWidget prio_sub, prio_add; nWatcherWidget prio_view;
  nWidget reduc, front, grab_front, back;
  sValueBloc value_bloc = null, setting_bloc;
  Runnable szone_st, szone_en;
  
Macro_Abstract(Macro_Sheet _sheet, String ty, String n, sValueBloc _bloc) {
    super(_sheet.gui, _sheet.ref_size, 0.25);
    gui = _sheet.gui; ref_size = _sheet.ref_size; sheet = _sheet; 
    sheet_depth = sheet.sheet_depth + 1;
    
    if (_bloc == null) {
      String n_suff = "";
      if (n == null) n_suff = ty;
      else n_suff = n;
      String n_ref = "0_" + n_suff;
      if (sheet == mmain() && mmain().child_sheet != null && mmain().child_sheet.size() == 0 ) {
        
      } else {
        int cn = -1;
        n_ref = cn + "_" + n_suff;
        //mlogln(n_suff + " search new name");
        boolean is_in_other_sheet = true;
        while (is_in_other_sheet ||
               (sheet.sheet.value_bloc.getBloc(n_ref) != null) || // && sheet != mmain()
               sheet.value_bloc.getBloc(n_ref) != null) {
          cn++;
          n_ref = cn + "_" + n_suff;
          //mlogln("try name " + n_ref);
          
          is_in_other_sheet = false;
          if (sheet.child_sheet != null) for (Macro_Sheet m : sheet.child_sheet)
            is_in_other_sheet = m.value_bloc.getBloc(n_ref) != null || is_in_other_sheet;
          
          /*if (sheet != mmain())*/ 
          if (sheet.sheet.child_sheet != null) for (Macro_Sheet m : sheet.sheet.child_sheet) {
            is_in_other_sheet = m.value_bloc.getBloc(n_ref) != null || is_in_other_sheet;
            for (Macro_Sheet mc : m.child_sheet)
              is_in_other_sheet = mc.value_bloc.getBloc(n_ref) != null || is_in_other_sheet;
          }
          
        }
        //mlogln(n_ref + " found his name");
      }
      value_bloc = sheet.value_bloc.newBloc(n_ref);
      
    } else value_bloc = _bloc;
    
    mlogln("build abstract "+ty+" "+n+" "+ _bloc+"    as "+value_bloc.ref);
    
    setting_bloc = value_bloc.getBloc("settings");
    if (setting_bloc == null) setting_bloc = value_bloc.newBloc("settings");
    
    val_type = ((sStr)(setting_bloc.getValue("type"))); 
    val_descr = ((sStr)(setting_bloc.getValue("description"))); 
    val_title = ((sStr)(setting_bloc.getValue("title"))); 
    grab_pos = ((sVec)(setting_bloc.getValue("position"))); 
    openning = ((sInt)(setting_bloc.getValue("open"))); 
    openning_pre_hide = ((sInt)(setting_bloc.getValue("pre_open"))); 
    val_self = ((sObj)(setting_bloc.getValue("self"))); 
    priority = ((sInt)(setting_bloc.getValue("priority"))); 
    
    if (val_type == null) val_type = setting_bloc.newStr("type", "type", ty);
    if (val_descr == null) val_descr = setting_bloc.newStr("description", "descr", "macro");
    //if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", n);
    if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", value_bloc.ref);
    else val_title.set(value_bloc.ref);
    if (grab_pos == null) grab_pos = setting_bloc.newVec("position", "pos");
    else pos_given = true;
    
    if (!pos_given && sheet != this && !(sheet.child_macro.size() == 0) ) {
      PVector sc_pos = new PVector(mmain().screen_gui.view.pos.x + mmain().screen_gui.view.size.x * 1.0 / 2.0, 
                                   mmain().screen_gui.view.pos.y + mmain().screen_gui.view.size.y / 3.0);
      sc_pos = mmain().inter.cam.screen_to_cam(sc_pos);
      grab_pos.set(sc_pos.x - sheet.grabber.getX(), sc_pos.y - sheet.grabber.getY());
      grab_pos.setx(grab_pos.x() - grab_pos.x()%(ref_size * 0.5));
      grab_pos.sety(grab_pos.y() - grab_pos.y()%(ref_size * 0.5));
    }
    
    if (openning == null) openning = setting_bloc.newInt("open", "op", OPEN);
    if (openning_pre_hide == null) openning_pre_hide = setting_bloc.newInt("pre_open", "pop", OPEN);
    if (val_self == null) val_self = setting_bloc.newObj("self", this);
    else val_self.set(this);
    if (priority == null) priority = setting_bloc.newInt("priority", "prio", 0);
    build_ui();
  }
  Macro_Abstract(sInterface _int) { // FOR MACRO_MAIN ONLY
    super(_int.cam_gui, _int.ref_size, 0.125);
    
    mlogln("build main abstract ");
    
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
    prio_view = addWatcherModel("mc_ref");
    prio_sub = addCtrlModel("mc_ref");
    prio_add = addCtrlModel("mc_ref");
    
    value_bloc = _int.interface_bloc.newBloc("Main_Sheet");
    setting_bloc = value_bloc.newBloc("settings");
    val_type = setting_bloc.newStr("type", "type", "main");
    val_descr = setting_bloc.newStr("description", "descr", "macro main");
    val_title = setting_bloc.newStr("title", "ttl", "macro main");
    grab_pos = setting_bloc.newVec("position", "pos");
    openning = setting_bloc.newInt("open", "op", DEPLOY);
    openning_pre_hide = setting_bloc.newInt("pre_open", "pop", DEPLOY);
    val_self = setting_bloc.newObj("self", this);
    priority = setting_bloc.newInt("priority", "prio", 0);
    
    //_int.addEventNextFrame(new Runnable() { public void run() { 
    //  openning.set(OPEN); 
    //  deploy();
    //  //if (!mmain().show_macro.get()) hide();
    //  toLayerTop(); 
    //} } );
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
      moving(); 
    } });
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
    
    
    prio_sub = addCtrlModel("MC_Prio_Sub")
      .setRunnable(new Runnable() { public void run() { if (priority.get() > 0) priority.add(-1); } });
    prio_sub.setParent(panel);
    prio_sub.stackUp().alignRight();
    prio_add = addCtrlModel("MC_Prio_Add")
      .setRunnable(new Runnable() { public void run() { if (priority.get() < 9) priority.add(1); } });
    prio_add.setParent(panel);
    prio_add.stackUp().alignRight();
    
    prio_view = addWatcherModel("MC_Prio_View")
      .setLinkedValue(priority);
    prio_view.setParent(panel);
    prio_view.stackUp().alignRight().setInfo("priority");
    
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
      szone_unselect(); } } ;
    szone_en = new Runnable(this) { public void run() { 
      if (mmain().selected_sheet == sheet && 
          ((openning.get() != REDUC && mmain().szone.isUnder(front) ) || 
           (openning.get() == REDUC && mmain().szone.isUnder(grab_front) )) )  {
        szone_select(); } } } ;
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
      if (!pos_given) find_place(); 
      if (openning.get() != HIDE && !mmain().is_paste_loading) { 
        mmain().szone_clear_select();
        szone_select();
      }
      if (!mmain().show_macro.get()) hide();
      
      if (mmain().sheet_explorer != null) mmain().sheet_explorer.update(); 
      runEvents(eventsSetupLoad); 
      toLayerTop(); 
    } } );
  }
  void find_place() {
    
    grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
    grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
    
    int adding_v = 0;
    boolean found = false;
    while (!found) {
      if (adding_v > 0) setPosition(grabber.getLocalX() - ref_size * 3, grabber.getLocalY());
      adding_v++; 
      if (adding_v == 6) { 
        adding_v = 0; setPosition(grabber.getLocalX() + ref_size * 15, grabber.getLocalY() + ref_size * 3); }
      boolean col = false;
      float phf = 0.5;
      for (Macro_Abstract c : sheet.child_macro) 
        if (c != this && c.openning.get() == DEPLOY 
            && rectCollide(panel.getRect(), c.back.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == REDUC 
                 && rectCollide(panel.getRect(), c.grabber.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == OPEN 
                 && rectCollide(panel.getRect(), c.panel.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == DEPLOY
                 && rectCollide(panel.getPhantomRect(), c.back.getPhantomRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == REDUC
                 && rectCollide(panel.getPhantomRect(), c.grabber.getPhantomRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == OPEN
                 && rectCollide(panel.getPhantomRect(), c.panel.getPhantomRect(), ref_size * phf)) col = true;
      if (sheet != mmain() && openning.get() == HIDE 
          && rectCollide(panel.getPhantomRect(), sheet.panel.getPhantomRect(), ref_size * phf*2)) col = true;
      if (sheet != mmain() && openning.get() != HIDE 
          && rectCollide(panel.getRect(), sheet.panel.getRect(), ref_size * phf*2)) col = true;
      if (!col) found = true;
    }
    sheet.updateBack();
  }
  Macro_Abstract clear() {
    if (!unclearable) {
      super.clear();
      val_type.clear(); val_descr.clear(); val_title.clear(); grab_pos.clear();
      openning.clear(); openning_pre_hide.clear(); val_self.clear();
      priority.clear();
      value_bloc.clear(); 
      sheet.child_macro.remove(this);
      sheet.redo_link();
      sheet.redo_spot();
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

 bloc extend abstract
 shelfpanel of element
 methods to add and manipulate element for easy macro building
 
 */
class Macro_Bloc extends Macro_Abstract {
  Macro_Bloc(Macro_Sheet _sheet, String t, String n, sValueBloc _bloc) {
    super(_sheet, t, n, _bloc);
    mlogln("build bloc "+t+" "+n+" "+ _bloc);
    addShelf(); 
    addShelf();
  }

  Macro_Element addSelectS(int c, sBoo v1, sBoo v2, String s1, String s2) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    nWidget w1 = m.addLinkedModel("MC_Element_Button_Selector_1", s1).setLinkedValue(v1);
    nWidget w2 = m.addLinkedModel("MC_Element_Button_Selector_2", s2).setLinkedValue(v2);
    w1.addExclude(w2);
    w2.addExclude(w1);
    return m;
  }
  

  Macro_Element addSelectL(int c, sBoo v1, sBoo v2, sBoo v3, sBoo v4, 
                           String s1, String s2, String s3, String s4) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    nWidget w1 = m.addLinkedModel("MC_Element_Button_Selector_1", s1).setLinkedValue(v1);
    nWidget w2 = m.addLinkedModel("MC_Element_Button_Selector_2", s2).setLinkedValue(v2);
    nWidget w3 = m.addLinkedModel("MC_Element_Button_Selector_3", s3).setLinkedValue(v3);
    nWidget w4 = m.addLinkedModel("MC_Element_Button_Selector_4", s4).setLinkedValue(v4);
    w1.addExclude(w2).addExclude(w3).addExclude(w4);
    w2.addExclude(w1).addExclude(w3).addExclude(w4);
    w3.addExclude(w2).addExclude(w1).addExclude(w4);
    w4.addExclude(w2).addExclude(w3).addExclude(w1);
    return m;
  }
  
  Macro_Element addEmptyS(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyXL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Triple", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyB(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Big", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyXB(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Bigger", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  nWidget addEmpty(int c) { 
    Macro_Element m = new Macro_Element(this, "", "mc_ref", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addFillR(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillright", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }
  nWidget addFillL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillleft", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addLabelS(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m.back;
  }
  nWidget addLabelL(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  Macro_Connexion addInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Connexion addOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Element addSheetInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m;
  }
  Macro_Element addSheetOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m;
  }


  Macro_Element addElement(int c, Macro_Element m) {
    if (c >= 0 && c < 3) {
      if (c == 2 && shelfs.size() < 3) addShelf();
      elements.add(m);
      getShelf(c).insertDrawer(m);
      if (c == 0 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(-ref_size*0.0);
      if (c == 1 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size*0.5);
      if (c == 2 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size);
      if (openning.get() == OPEN) for (Macro_Element e : elements) e.show();
      toLayerTop();
      return m;
    } else return null;
  }
  
  String resum_link() { 
    String r = "";
    for (Macro_Element m : elements) {
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_inputs) 
        r += co.descr + INFO_TOKEN + m.connect.descr + OBJ_TOKEN;
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_outputs) 
        r += m.connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_inputs) 
      //  r += co.descr + INFO_TOKEN + m.sheet_connect.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_outputs) 
      //  r += m.sheet_connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
    }
    return r; 
  }
  
  ArrayList<Macro_Element> elements = new ArrayList<Macro_Element>();
  Macro_Bloc toLayerTop() { 
    super.toLayerTop(); 
    for (Macro_Element e : elements) e.toLayerTop(); 
    grabber.toLayerTop(); 
    return this;
  }
  Macro_Bloc clear() {
    for (Macro_Element e : elements) e.clear();
    super.clear(); return this; }

  Macro_Bloc open() {
    super.open();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  Macro_Bloc reduc() {
    super.reduc();
    for (Macro_Element m : elements) m.reduc();
    toLayerTop();
    return this;
  }
  Macro_Bloc show() {
    super.show();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  Macro_Bloc hide() {
    super.hide(); 
    for (Macro_Element m : elements) m.hide();
    //toLayerTop();
    return this;
  }
}






    
