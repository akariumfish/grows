
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
      if (!mmain().show_macro.get()) for (Macro_Abstract m : mmain().child_macro) m.hide();
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
    }
    if (mmain().sheet_explorer != null) mmain().sheet_explorer.setBloc(value_bloc);
    return this;
  }
  Macro_Sheet deploy() {
    if (openning.get() != DEPLOY && 
        (!(openning.get() == HIDE) || (openning.get() == HIDE && mmain().canAccess(see_access))) ) {
      if (sheet != this && sheet.openning.get() != DEPLOY) sheet.deploy();
      openning.set(DEPLOY);
      title_fixe = true; 
      grabber.show(); panel.show(); back.show(); back_front.show();
      front.show(); title.show(); reduc.hide(); deployer.show();
      grabber.setLook(gui.theme.getLook("MC_Grabber_Deployed"));
      cancel_new_spot();
      for (Macro_Abstract m : child_macro) { m.show(); m.toLayerTop(); }
      updateBack(); 
      moving(); 
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
      cancel_new_spot();
      grabber.hide(); panel.hide(); back.hide(); back_front.hide();
      front.hide(); title.hide(); reduc.hide(); deployer.hide();
      if (mmain().show_macro.get() && mmain().selected_sheet == this && sheet != this && sheet != mmain()) 
        sheet.select();
    }
    for (Macro_Abstract m : child_macro) m.hide();
    return this;
  }
  Macro_Sheet toLayerTop() { 
    super.toLayerTop(); 
    panel.toLayerTop(); front.toLayerTop();
    if (child_macro != null) for (Macro_Abstract e : child_macro) e.toLayerTop(); 
    reduc.toLayerTop(); prio_sub.toLayerTop(); prio_add.toLayerTop(); prio_view.toLayerTop(); 
    grabber.toLayerTop(); deployer.toLayerTop();
    back_front.toLayerTop(); 
    return this;
  }
  
  void add_link(String in, String out) {
    String def = in+INFO_TOKEN+out+OBJ_TOKEN;
    links.set(links.get()+def);
    //redo_link();
  }
  void remove_link(String in, String out) {
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    String new_list = "";
    for (String l : links_list) {
      String[] link_l = splitTokens(l, INFO_TOKEN);
      String i = link_l[0]; String o = link_l[1];
      //logln("try "+i+" "+o+" for "+in+" "+out);
      if (!(i.equals(in) && o.equals(out))) new_list += l+OBJ_TOKEN;
    }
    links.set(new_list);
    //redo_link();
  }
  void clear_link() {
    for (Macro_Connexion co1 : child_connect) co1.clear_link();
        //for (Macro_Connexion co2 : child_connect) if (co1 != co2) co1.disconnect_from(co2);
    //logln("cleared links:"+links.get());
    links.set("");
  }
  void redo_link() {
    //logln("redo_link");
    String[] links_list = splitTokens(links.get(), OBJ_TOKEN);
    for (Macro_Connexion co1 : child_connect) co1.clear_link_array();
    links.set("");
    //clear_link();  
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
    String new_str = "";
    new_str += left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
    if (spot != null) {
      if (openning.get() != REDUC && openning.get() != HIDE) spot.show();
      else spot.hide();
    }
  }
  void remove_spot(String ref) {
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
    
    String new_str =  left_s+GROUP_TOKEN+right_s;
    spots.set(new_str);
    
    redo_spot();
  }
  void clear_spot() { //clear using and clear spot drawers
    spots.set(OBJ_TOKEN+GROUP_TOKEN+OBJ_TOKEN);
    //logln("clear_child_elem_spot");
    for (Macro_Element t : child_elements) t.clear_spot();
    
    //logln("clear_left");
    ArrayList<nDrawer> a = new ArrayList<nDrawer>();
    getShelf(0).removeDrawer(left_spot_drawer);
    for (nDrawer d : getShelf(0).drawers) a.add(d);
    for (nDrawer d : a) { getShelf(0).removeDrawer(d); d.clear(); }
    getShelf(0).insertDrawer(left_spot_drawer);
    
    //logln("clear_right");
    a.clear();
    getShelf(1).removeDrawer(right_spot_drawer);
    for (nDrawer d : getShelf(1).drawers) a.add(d);
    for (nDrawer d : a) { getShelf(1).removeDrawer(d); d.clear(); }
    getShelf(1).insertDrawer(right_spot_drawer);
    
    cancel_new_spot();
  }
  void redo_spot() {
    //logln("redo_spot");
    String[] spots_side_list = splitTokens(spots.get(), GROUP_TOKEN);
    String left_s = OBJ_TOKEN, right_s = OBJ_TOKEN;
    if (spots_side_list.length == 2) { 
      left_s = copy(spots_side_list[0]); right_s = copy(spots_side_list[1]); }
    
    //logln("clear_spot");
    clear_spot();
    
    //logln("addl_spot");
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
    //logln("endredo");
  }
  //when a spot is used the ref of the element and the nb and side of the spot are saved into the string
  //when the sheet is open click on a spot to reassign it, 
  //  right click to cancel, left click on empty to clear assignment
  //two add spot button > add_spot(side)
   
   
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
  void ask_packet_process(Macro_Connexion co) {
    if (co.type == OUTPUT) out_to_process.add(co);
    if (co.type == INPUT) in_to_process.add(co);
    //if (co.type == OUTPUT) logln(co.descr+" ask_packet_process OUT ");
    //if (co.type == INPUT) logln(co.descr+" ask_packet_process IN ");
    mmain().ask_packet_process(this);
  }
  
  LinkedBlockingQueue<Macro_Connexion> in_to_process = new LinkedBlockingQueue<Macro_Connexion>();
  LinkedBlockingQueue<Macro_Connexion> out_to_process = new LinkedBlockingQueue<Macro_Connexion>();
  boolean DEBUG_PACKETS = true;
  void process_packets() {
    if (!mmain().do_packet.get()) {
      in_to_process.clear();
      out_to_process.clear();
    } else {
      //logln(value_bloc.ref+" process start ");
      //String procc_resum = value_bloc.ref + " process resum ";
      //logln(send_resum);
      
      boolean done = false; int turn_count = 0, max_turn = 10;
      while (!done || turn_count > max_turn) {
        done = true;
        //logln("    turn " + turn_count + " start " + in_to_process.size() + "in" + out_to_process.size() + "out");
        while(out_to_process.size() > 0) {
          Macro_Connexion m = out_to_process.remove();
          done = m.process_send() && done;
          //procc_resum += m.process_resum;
        }
        //logln("    turn " + turn_count + " mid " + in_to_process.size() + "in" + out_to_process.size() + "out");
        while(in_to_process.size() > 0) {
          //logln("----IN");
          Macro_Connexion m = in_to_process.remove();
          //logln("     got "+m.descr);
          done = m.process_receive() && done;
          //procc_resum += m.process_resum;
        }
        //logln("    turn " + turn_count + " end " + in_to_process.size() + "in" + out_to_process.size() + "out");
        
        turn_count++;
      }
      
      //logln(procc_resum);
      
      //if (turn_count > max_turn) {
      //  String[] llink = splitTokens(mmain().last_created_link, INFO_TOKEN);
      //  if (llink.length == 2) mmain().last_link_sheet.remove_link(llink[0], llink[1]);
      //  logln("LOOP");
      //}
      
      for (Macro_Connexion m : child_connect) m.end_packet_process();
      
      //packet_process_asked = false;
    }
  }
  
  
   
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
  
  add screenshot shortcut to base templates
                  
  when loading link there is confusion between sheet connect,
    the bloc holding the sheet co need to check if his name is unique in his sheet parent too!!!
    event for sheet co descr look like :
      left :elem_name(bloc ref + num) ... token right: ...
    there his no mention that its a sheet co and that his bloc is on another sheet than the co
    >> just need to check inside child_sheet too
  
  its needed to group shapes to limit object nb
  
  MVar
    add a hideable (like com) param drawer : select variable type
    int str and vec better handling 
    
  MComment can log received data (auto text format with insertion token??)
  
  number formating!!!
  
  bloc a faire:
    cursor bloc : 
        (like menu) named, listed in mmain so global, 
        the bloc point to an existing cursor or can build a new
        custom setlinkedPosition(svec) setlinkedDir(svec) setlinkedShow(sboo)
        constrain (dir pos mag ..)
        registered independently from theirs sheet and easily accessible for
          new comus start
          global effect field
          multi comu objectif
        
        auto follow / point to objects, instent or chasing
        memorize path for display
        dif shape / look
        
    camview
      like a menu, name, click to go, 3 field for values, 
      when selected capture n store cam pos / scale
    frame delay / tick delay / packet process delay
    setreset, counter, sequance, multigate 
  
  TEST packet processing order for inputs
  
  redo link loop protection
    auto delete last link
  
  mesure and store the relative process time used by each special sheet
  
  sort explorer blocs n values alfabeticaly
    more entry and smaller height


                    R & D
                    
  Sending Object through link ??
    more like temporary and restricted access > need timed, volatile container
  
  infrastructure :
    structural model switchable (patch structure)
    need used value to be present  
    
  mtemplate : load / save
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  
  unique macro bloc custom build by the special sheet, non deletable, non duplicable
    ex: Canvas :
      will send each pixel throug this:
        4 out color of the neigbours
        1 out my color
        4 in color modif for the neigbours
        1 in color modif for myself
      by charging the pixels data on the inputs, forcibly running packet process, getting the outs
      need no exterior co and no packet delaying
      
  special sheet : effect field
    affect a canvas
    all pixel under his shape get a custom processing
                    
  make organism use a face as exemple for its shape
                    
  enregistrement de different POV camera entre lesquel on peut basquler
    vue macro / vue exploration / vue general
    macro camview
  
  change access
    low access hide certain sheet
    gain access by meeting enigmatic condition ??
  
  when selecting a preset auto hide uncompatible widget ? > need to redo explorer
  
  gameplay thinking :
    consumable is needed to influence the world :
      modifying svalues
      diplaying a shape
      processing data (running macro)
      packet hold consummable
    the canvas is the origin and destination of the consumable
    links connect consummable pool with restriction
      macro bloc are pool
      restriction on volume and quantity by tick
      transfer quality : some of the packet consummable is lost to the canvas
    displayed shape are pool
    collision between shape create pool link
      collision area influence link quality
    
    
    
  */
  
    
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
    clear_spot();
    for (int i = child_macro.size() - 1 ; i >= 0 ; i--) child_macro.get(i).clear();
    child_sheet.clear();
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
  nWidget match_flag;
  
  
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
          .addValuesModifier(mmain().inter.taskpanel)
          .addEventChange(new Runnable() { public void run() { 
              if (sheet_viewer.explored_bloc != value_bloc) {
                sheet_viewer.setStrtBloc(value_bloc);
              }
          } } )
          ;
      match_flag = sheet_front.addTab("Preset").getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1).addModel("Label-S3", "Presets :").setTextAlignment(LEFT, CENTER).getDrawer()
        .addCtrlModel("Button-S2-P3", "Delete").setRunnable(new Runnable() { public void run() { 
          preset_explorer.selected_bloc.clear(); 
          for (nExplorer e : mmain().presets_explorers) e.update(); } } )
          .setInfo("delete selected preset").getDrawer()
        .addModel("Label_DownLight_Back-S2-P2", "")
          .setInfo("selected preset compatibility with this sheet");
        
      match_flag.getShelf()
        .addSeparator()
        ;
      preset_explorer = sheet_front.getTab(1).getShelf(0)
        .addSeparator()
        .addExplorer()
          .setStrtBloc(mmain().saved_preset)
          //.hideGoBack()
          .addValuesModifier(mmain().inter.taskpanel)
          .addEventChange(new Runnable() { public void run() { 
            if (!(preset_explorer.explored_bloc == mmain().saved_preset ||
                preset_explorer.explored_bloc.parent == mmain().saved_preset)) 
              preset_explorer.setStrtBloc(mmain().saved_preset);
            if (preset_explorer.selected_bloc != null && 
                (values_found(value_bloc, preset_explorer.selected_bloc) || 
                values_found(preset_explorer.selected_bloc, value_bloc)) ) 
              match_flag.setLook(gui.theme.getLook("Label_HightLight_Back")).setText("matching");
            else match_flag.setLook(gui.theme.getLook("Label_DownLight_Back")).setText("");
          } } )
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
      
      custom_tab = sheet_front.addTab("Control");

      custom_tab.getShelf()
        .addDrawer(10.25, 0.75)
        .addModel("Label-S10/0.75", "-  Control  -").setFont(int(ref_size/1.5)).getShelf()
        .addSeparator(0.125)
        ;
      runEvents(eventsBuildMenu);
      
      build_custom_menu(sheet_front);
      
      sheet_front.addEventClose(new Runnable(this) { public void run() { 
        if (preset_explorer != null) mmain().presets_explorers.remove(preset_explorer);
        sheet_front = null; }});
    } else {
      sheet_front.popUp();
    }
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
  
  
  boolean canSetupFrom(sValueBloc bloc) {
    return super.canSetupFrom(bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("specialize")).get().equals(specialize.get());
  }
  
  void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      
      empty();
      
      //to store name change
      new_ref = "";
      //point to container of all blocs being added to filter name duplication
      blocs_to_add = bloc;
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      grabber.setPosition(((sVec)bloc.getBloc("settings").getValue("position")).get());
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
      
      bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        if (!(bloc.ref.equals("settings"))) {
          //search if existing bloc correspond >> unclearable >> setupFromBloc
          boolean found = false;
          if (value_bloc.getBloc(bloc.ref) != null) {
            for (Macro_Abstract m : child_macro) if (m.value_bloc.ref.equals(bloc.ref)) { 
              found = true; 
              m.setupFromBloc(bloc); 
              //break;
            }
          }
          if (!found) { //sinon
            addCopyofBloc(bloc);
          }
        }
      }});
      //logln("nref "+new_ref);
      
      // take apart saving string to apply name change then create corresponding link or spot
      if (bloc.getBloc("settings").getValue("links") != null) {
        String link_s = ((sStr)bloc.getBloc("settings").getValue("links")).get();
        rename_build_link(link_s, new_ref);
      }
      //redo_spot();
      //if (bloc.getBloc("settings").getValue("spots") != null) {
      //  String spot_s = ((sStr)bloc.getBloc("settings").getValue("spots")).get();
      //  rename_build_spot(spot_s, new_ref);
      //}
      redo_spot();
      redo_link();
      
      runEvents(eventsSetupLoad);
      
      //mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
        else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
        else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
        else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
        if (!mmain().show_macro.get()) hide();
      //} } );
      
      mmain().szone_clear_select();
    }
  }
  
  void rename_build_link(String link_s, String n_ref) {

    //  change bloc name in bloc links
    //String new_links = "";
    String[] change_list = splitTokens(n_ref, OBJ_TOKEN);
    String[] nlink_list = splitTokens(link_s, OBJ_TOKEN);
    //String newlink = "";
    for (String l : nlink_list) {
      //logln("link "+l);
      String[] linkpart = splitTokens(l, INFO_TOKEN);
      String newco = "";
      for (String k : linkpart) {
        String[] copart = splitTokens(k, BLOC_TOKEN);
        for (int i = 0 ; i < change_list.length ; i += 1) {
          String[] changepart = splitTokens(change_list[i], INFO_TOKEN);
          //logln("test change "+changepart[0] + " > "+changepart[1]);
          if (copart.length > 0 && copart[0].equals(changepart[0])) {
            copart[0] = changepart[1];
          }
        }
        if (copart.length > 1) {
          newco = newco + BLOC_TOKEN + copart[0] + BLOC_TOKEN + copart[1] + INFO_TOKEN;
        }
      }
      String[] newcopart = splitTokens(newco, INFO_TOKEN);
      if (newcopart.length > 1) {
        //logln("newco "+newcopart[0]+" "+newcopart[1]);
        add_link(newcopart[1], newcopart[0]);
        //redo_link();
      }
    }
  }
  void rename_build_spot(String spots_s, String n_ref) {
    String[] change_list = splitTokens(n_ref, OBJ_TOKEN);
    //String new_str = "";
    String[] spots_side_list = splitTokens(spots_s, GROUP_TOKEN);
    int side = 0;
    for (String spot_side : spots_side_list) {
      String[] elem_list = splitTokens(spot_side, OBJ_TOKEN);
      for (String elm : elem_list) {
        String[] elem_descr_l = splitTokens(elm, BLOC_TOKEN);
        for (String change : change_list) {
          String[] changepart = splitTokens(change, INFO_TOKEN);
          if (elem_descr_l.length == 2 && elem_descr_l[0].equals(changepart[0])) {
            elem_descr_l[0] = changepart[1];
          }
        }
        String new_elem = BLOC_TOKEN+elem_descr_l[0]+BLOC_TOKEN+elem_descr_l[1];
        Macro_Element e = null;
        for (Macro_Element t : child_elements) if (t.descr.equals(new_elem)) { e = t; break; }
        if (e != null && side == 0) add_spot("left", e);
        if (e != null && side == 1) add_spot("right", e);
      }
      
      side++;
    }
    
  }
  
  void addCopyofBlocContent(sValueBloc bloc) {
    
    //to store name change
    new_ref = "";
    //point to container of all blocs being added to filter name duplication
    blocs_to_add = bloc;
    
    bloc.runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc b) { 
      addCopyofBloc(b);
    }});
    
    //logln("nref "+new_ref);
    
    // take apart saving string to apply name change then create corresponding link or spot
    if (bloc.getValue("links") != null) {
      String link_s = ((sStr)bloc.getValue("links")).get();
      rename_build_link(link_s, new_ref);
    }
    //redo_spot();
    if (bloc.getValue("spots") != null) {
      String spot_s = ((sStr)bloc.getValue("spots")).get();
      rename_build_spot(spot_s, new_ref);
    }
    redo_spot();
    redo_link();
    mmain().szone_clear_select();
  }
  
  String new_ref = "";
  sValueBloc blocs_to_add;
  void addCopyofBloc(sValueBloc bloc) {
    if (!bloc.ref.equals("settings")) {
      
      //add bloc
      String n_ref = bloc.ref;
      if (bloc.getBloc("settings") != null && bloc.getBloc("settings").getValue("title") != null)
        n_ref = ((sStr)(bloc.getBloc("settings").getValue("title"))).get();
      int cn = 0;
      while (value_bloc.getBloc(n_ref) != null || 
             (blocs_to_add.getBloc(n_ref) != null && blocs_to_add.getBloc(n_ref) != bloc) || 
             (sheet != this && sheet.sheet.value_bloc.getBloc(n_ref) != null) ) {
        if (n_ref.length() > 0) while (n_ref.charAt(0) != '_') n_ref = n_ref.substring(1, n_ref.length());
        n_ref = cn + n_ref;
        cn++;
      }
      //logln("in "+value_bloc.ref+" new ref "+((sStr)(bloc.getBloc("settings").getValue("title"))).get()+" > "+n_ref);
      sValueBloc nbloc = copy_bloc(bloc, value_bloc, n_ref);
      
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
      if (a != null) new_ref = new_ref + OBJ_TOKEN + bloc.ref+INFO_TOKEN+nbloc.ref;
      
      //add copyed child to new macro
      if (a != null && a.val_type.get().equals("sheet")) {
        ((Macro_Sheet)a).addCopyofBlocContent(nbloc_child);
        for (Macro_Abstract m : ((Macro_Sheet)a).child_macro) m.szone_unselect();
        //((Macro_Sheet)a).redo_spot();
        //((Macro_Sheet)a).redo_link();
      }
      
      //no new macro = invalid bloc
      if (a == null) nbloc.clear();
      
      nbloc_child.clear();
      
      if (a != null && !mmain().is_setup_loading) a.szone_select();
    } 
  }
  //b need to be child of value_bloc and have setting/type + spe if sheet , everything else can be created
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
    //else if (t.equals("cursor")) return addCursor(b);
    else if (t.equals("com")) return addComment(b);
    //else if (t.equals("tmpl")) return addTmpl(b);
    else if (t.equals("preset")) return addPrst(b);
    else if (t.equals("midi")) return addMidi(b);
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
    else if (t.equals("ramp")) return addRamp(b);
    else if (t.equals("crossVec")) return addCrossVec(b);
    else if (t.equals("colRGB")) return addColRGB(b);
    return null;
  }
  
  MData addData(sValueBloc b) { MData m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) {
      m = new MData(this, b, sheet_viewer.selected_value);
      sheet_viewer.update(); }
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) {
      m = new MData(this, b, mmain().sheet_explorer.selected_value);
      mmain().sheet_explorer.update(); }
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
    if (sheet_viewer != null && sheet_viewer.selected_value != null) {
      m = new MNumCtrl(this, b, sheet_viewer.selected_value);
      sheet_viewer.update(); }
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) {
      m = new MNumCtrl(this, b, mmain().sheet_explorer.selected_value);
      mmain().sheet_explorer.update(); }
    else m = new MNumCtrl(this, b, null); return m; }
  MVecCtrl addVecCtrl(sValueBloc b) { MVecCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) {
      m = new MVecCtrl(this, b, sheet_viewer.selected_value);
      sheet_viewer.update(); }
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) {
      m = new MVecCtrl(this, b, mmain().sheet_explorer.selected_value);
      mmain().sheet_explorer.update(); }
    else m = new MVecCtrl(this, b, null); return m; }
  MRandom addRng(sValueBloc b) { MRandom m = new MRandom(this, b); return m; }
  MMouse addMouse(sValueBloc b) { MMouse m = new MMouse(this, b); return m; }
  //MCursor addCursor(sValueBloc b) { MCursor m = new MCursor(this, b); return m; }
  MComment addComment(sValueBloc b) { MComment m = new MComment(this, b); return m; }
  //MTemplate addTmpl(sValueBloc b) { MTemplate m = new MTemplate(this, b); return m; }
  MPreset addPrst(sValueBloc b) { MPreset m = new MPreset(this, b); return m; }
  MMIDI addMidi(sValueBloc b) { MMIDI m = new MMIDI(this, b); return m; }
  MMenu addMenu(sValueBloc b) { MMenu m = new MMenu(this, b); return m; }
  MTool addTool(sValueBloc b) { MTool m = new MTool(this, b); return m; }
  MToolBin addToolBin(sValueBloc b) { MToolBin m = new MToolBin(this, b); return m; }
  MToolTri addToolTri(sValueBloc b) { MToolTri m = new MToolTri(this, b); return m; }
  MToolNCtrl addToolNCtrl(sValueBloc b) { MToolNCtrl m = null;
    if (sheet_viewer != null && sheet_viewer.selected_value != null) { 
      m = new MToolNCtrl(this, b, sheet_viewer.selected_value);
      sheet_viewer.update(); }
    else if (mmain().sheet_explorer != null && mmain().sheet_explorer.explored_bloc == value_bloc &&
             mmain().sheet_explorer.selected_value != null) { 
      m = new MToolNCtrl(this, b, mmain().sheet_explorer.selected_value);
      mmain().sheet_explorer.update(); }
    else m = new MToolNCtrl(this, b, null); return m; }
  MPanel addPanel(sValueBloc b) { MPanel m = new MPanel(this, b); return m; }
  MPanBin addPanBin(sValueBloc b) { MPanBin m = new MPanBin(this, b); return m; }
  MPanSld addPanSld(sValueBloc b) { MPanSld m = new MPanSld(this, b); return m; }
  MPanGrph addPanGrph(sValueBloc b) { MPanGrph m = new MPanGrph(this, b); return m; }
  //MPanCstm addPanCstm(sValueBloc b) { MPanCstm m = new MPanCstm(this, b); return m; }
  MRamp addRamp(sValueBloc b) { MRamp m = new MRamp(this, b); return m; }
  MCrossVec addCrossVec(sValueBloc b) { MCrossVec m = new MCrossVec(this, b); return m; }
  MColRGB addColRGB(sValueBloc b) { MColRGB m = new MColRGB(this, b); return m; }
  
}





interface Macro_Interf {
  static final int INPUT = 1, OUTPUT = 2, NO_CO = 3;
  static final int HIDE = 0, REDUC = 1, OPEN = 2, DEPLOY = 3;
  static final String OBJ_TOKEN = "@", GROUP_TOKEN = "¤", INFO_TOKEN = "#", BLOC_TOKEN = "~";
  final String[] bloc_types1 = {"com", "in", "out", "trig", "switch", "gate", "not", "pulse", "frame", 
                                "bin", "bool", "var", "rng", "calc", "comp", "ramp", "chan", "data" };
  final String[] bloc_types2 = {"vecXY", "vecMD", "vecCtrl", "numCtrl", "mouse", "keyb", "crossVec", 
                                "midi", "preset", "tool", "tooltri", "toolbin", "toolNC", "pan", 
                                "panbin", "pansld", "pangrph", "menu"}; //"cursor", "pancstm", "tmpl", 
  final String[] bloc_types3 = {"colRGB"};
                                
  final String[] bloc_info1 = {"commentary", "sheet input", "sheet output", 
                               "trigger > bang", "switch > bool", "can control msg circulation", 
                               "invert bool", "let one bang of many pass", "retard msg for one frame", 
                               "bang <> bool", "AND OR operator", "store received msg, send copy at bang", 
                               "random numbers", "arythmetic calculator", "comparator", 
                               "lerp value from a to b, driven by bang, multiple ranpe shape", 
                               "invisible connexion by keywords", 
                               "access sheet sValue, can modify and get change" };
  final String[] bloc_info2 = {"vector <> x / y coords", "vector <> magnitude and heading", 
                               "easy modify vector sValue", "easy modify numbers sValue", 
                               "get mouse info", "get selected keyboard inputs", 
                               "keyboard direction cross ZQSD > vec", 
                               "not working", "load selected preset at bang", "create a new toolpanel", 
                               "up to 3 toolpanel triggers", "up to 2 toopanel switchs", 
                               "add an incr/fact numerical sValue controller to the toolpanel", 
                               "create a new windowpanel", 
                               "windowpanel binary ctrl", "add a slider to the windowpanel", 
                               "save consecutive inputs as a graph displayed in a windowpanel", 
                               "can open sheet menu"};
  final String[] bloc_info3 = {"color <> r / g / b"};
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









      
