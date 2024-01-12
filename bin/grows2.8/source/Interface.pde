/*
 Interface
   Inputs, DataHolding
   class CameraView 
     name
     pos and scale as svalue
     map<name, CameraView> : views
     name of current view as svalue
   
   drawing_pile screen_draw, cam_draw
   hover_pile screen and cam
   
   event hoverpilesearch both no find
   
   list<runnable> frameEvents
   
   frame()
     hover_pile.search() if screen found dont do cam
     run frameEvents
     update cam view from inputs
     clear screen
     draw grid if needed
     draw cam then screen from their pov
     to control when to screenshot maybe do it in a Drawer
 
 
 
 */

class User {
  String access = "admin";
  User() {}
  User(String a) { access = copy(a); }
}

class sInterface {

  void filesManagement() {
    if (files_panel == null) {
      files_panel = new nWindowPanel(screen_gui, taskpanel, "Files");
      files_panel.setSpace(0.25);
      files_panel.getShelf()
        .addSeparator(0.125)
        .addDrawer(0.6)
          .addModel("Label-S4", "Select File :                                   ").setPY(-0.2*ref_size).getShelf()
        .addDrawer(0.75)
          .addLinkedModel("Field-SS4", savepath).setLinkedValue(savepath_value).getShelf()
        .addDrawer(1)
          .addModel("Label-S4", "File datas :                                   ").getDrawer()
          .addCtrlModel("Button_Outline-S2", "Save")
            .setRunnable(new Runnable() { public void run() { file_explorer_save(); } } )
            .setPX(ref_size*4)
            .getDrawer()
          .addCtrlModel("Button_Outline-S2", "Load")
            .setRunnable(new Runnable() { public void run() { file_explorer_load(); } } )
            .setPX(ref_size*7)
            .getShelf()
            ;
        
      
      files_panel.addShelf()
        .addSeparator(0.5)
        .addDrawer(1)
          .addCtrlModel("Button_Small_Text_Outline-S3-P1", "close file")
            .setRunnable(new Runnable() { public void run() { 
              if (explored_bloc != null) explored_bloc.clear();
              explored_bloc.clear(); explored_bloc = null;
              file_explorer.setStrtBloc(null);
              file_explorer.update(); data_explorer.update(); update_list(); 
            } } )
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3-P2", "go to /")
            .setRunnable(new Runnable() { public void run() { 
              data_explorer.setStrtBloc(interface_bloc); 
              data_explorer.update(); update_list(); 
            } } )
            .getShelf()
        .addDrawer(10, 1)
          .addCtrlModel("Button_Small_Text_Outline-S3-P1", "delete file bloc")
            .setRunnable(new Runnable() { public void run() { 
              if (file_explorer.selected_bloc != null) { file_explorer.selected_bloc.clear(); }
              file_explorer.update();
            } } )
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3-P2", "dump data")
            .setRunnable(new Runnable() { public void run() { full_data_save(); } } ) //full_data_load();
            .getShelf()
        ;
        
      
      files_panel.getShelf(0)
        .addSeparator(0.25)
        .addDrawer(2)
          .addCtrlModel("Button_Small_Text_Outline-S3", "COPY BLOC\nINTO DATA")
            .setRunnable(new Runnable() { public void run() { copy_file_to_data(); } } )
            .setPX(ref_size*0).setSY(ref_size*2)
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "TRANSFER\nFILE VALUES\nTO DATA")
            .setRunnable(new Runnable() { public void run() { transfer_file_to_data(); } } )
            .setPX(ref_size*4).setSY(ref_size*2)
            ;
            
      match_flag = files_panel.getShelf(0)
        .getLastDrawer()
          .addModel("Label_DownLight_Back_Downlight_Outline-S3", "MATCHING\nBLOCS PRINT")
            .setPX(ref_size*8).setSY(ref_size*2);
      
      files_panel.getShelf(0)
        .getLastDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "TRANSFER\nDATA VALUES\nTO FILE")
            .setRunnable(new Runnable() { public void run() { transfer_data_to_file(); } } )
            .setPX(ref_size*12).setSY(ref_size*2)
            .getDrawer()
          .addCtrlModel("Button_Small_Text_Outline-S3", "COPY BLOC\nINTO FILE")
            .setRunnable(new Runnable() { public void run() { copy_data_to_file(); } } )
            .setPX(ref_size*16).setSY(ref_size*2)
            .getShelf()
        ;
        
      file_explorer = files_panel.getShelf(0)
        .addExplorer()
          .addEventChange(new Runnable() { public void run() { update_list(); } } )
          ;
          
      data_explorer = files_panel.getShelf(1)
        .addSeparator(2.375)
        .addExplorer()
          .setStrtBloc(data)
          .addEventChange(new Runnable() { public void run() { update_list(); } } )
          ;
      //files_panel.collapse();
      files_panel.addEventClose(new Runnable(this) { public void run() { files_panel = null; }});
      addEventSetup(new Runnable() { public void run() { data_explorer.update(); file_explorer.update(); } } );
    } else files_panel.popUp();
  }
  
  void copy_file_to_data() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null) {
      file_savebloc.clear();
      file_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      data_explorer.explored_bloc.newBloc(file_savebloc, "copy");
      data_explorer.update();
      //update_list();
    } 
  }
  void copy_data_to_file() {
    if (data_explorer.selected_bloc != null && explored_bloc != null) {
      file_savebloc.clear();
      data_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      explored_bloc.newBloc(file_savebloc, "copy");
      file_explorer.update();
      //update_list();
    } 
  }
  void transfer_file_to_data() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null &&
        file_explorer.selected_bloc.getHierarchy(true)
          .equals(data_explorer.selected_bloc.getHierarchy(true))) {
      file_savebloc.clear();
      file_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      data_explorer.selected_bloc.load_from_bloc(file_savebloc);
      data_explorer.update();
      //update_list();
    } 
  }
  void transfer_data_to_file() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null &&
        file_explorer.selected_bloc.getHierarchy(true)
          .equals(data_explorer.selected_bloc.getHierarchy(true))) {
      file_savebloc.clear();
      data_explorer.selected_bloc.preset_to_save_bloc(file_savebloc);
      file_explorer.selected_bloc.load_from_bloc(file_savebloc);
      file_explorer.update();
      //update_list();
    } 
  }

  void update_list() {
    if (data_explorer.selected_bloc != null && file_explorer.selected_bloc != null) {
      if (file_explorer.selected_bloc.getHierarchy(true)
            .equals(data_explorer.selected_bloc.getHierarchy(true))) {
        match_flag.setLook(screen_gui.theme, "Label_HightLight_Back_Highlight_Outline-S3");
      } else match_flag.setLook(screen_gui.theme, "Label_DownLight_Back_Downlight_Outline-S3");
    } else match_flag.setLook(screen_gui.theme, "Label_DownLight_Back_Downlight_Outline-S3");
  }
  
  void full_data_save() {
    file_savebloc.clear(); 
    interface_bloc.preset_to_save_bloc(file_savebloc); 
    file_savebloc.save_to(savepath); }
  void full_data_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    interface_bloc.load_from_bloc(file_savebloc);
    file_explorer.update(); data_explorer.update(); }
  
  void file_explorer_save() {
    if (explored_bloc != null) {
      file_savebloc.clear();
      explored_bloc.preset_to_save_bloc(file_savebloc);
      file_savebloc.save_to(savepath);
    }
  }
  void file_explorer_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    if (explored_bloc != null) explored_bloc.clear();
    explored_bloc = data.newBloc(file_savebloc, "file");
    file_explorer.setStrtBloc(explored_bloc);
  }
  
  void build_default_ui(float ref_size) {
    taskpanel = new nTaskPanel(screen_gui, ref_size, 0.125);
    
    if (!show_taskpanel.get()) taskpanel.reduc();
    taskpanel.addEventReduc(new Runnable() { public void run() { 
      show_taskpanel.set(!taskpanel.hide); }});
      
    savepath_value = new sStr(interface_bloc, savepath, "savepath", "spath");
    file_savebloc = new Save_Bloc(savepath);
    //filesManagement();
  }
  
  nWidget match_flag;
  nWindowPanel files_panel;
  String savepath = "save.sdata";
  sStr savepath_value;
  sBoo auto_load;
  Save_Bloc file_savebloc;
  sValueBloc explored_bloc, setup_bloc;
  nExplorer file_explorer, data_explorer;
  nTaskPanel taskpanel;
  float ref_size;
  
  sBoo show_taskpanel;
  
  

  sInput input;
  private DataHolder data; 
  sValueBloc interface_bloc;

  nTheme gui_theme;
  nGUI screen_gui, cam_gui;

  Camera cam;
  sFramerate framerate;

  Macro_Main macro_main;
  
  User user;
  /*
  method for sStr : pack unpack
    get string list + token > convert to string
    inversement
  
  */

  sInterface(float s) {
    ref_size = s;
    user = new User("user");
    input = new sInput();
    data = new DataHolder();
    interface_bloc = new sValueBloc(data, "Interface");
    gui_theme = new nTheme(ref_size);
    screen_gui = new nGUI(input, gui_theme, ref_size);
    cam_gui = new nGUI(input, gui_theme, ref_size);
    
    show_taskpanel = interface_bloc.newBoo("show_taskpanel", "taskpanel", true);
    show_taskpanel.addEventChange(new Runnable(this) { public void run() { 
      if (taskpanel != null && taskpanel.hide == show_taskpanel.get()) taskpanel.reduc();
    }});
    
    build_default_ui(ref_size);
    
    macro_main = new Macro_Main(this);
    
    framerate = new sFramerate(macro_main.value_bloc, 60);
    
    cam = new Camera(input, macro_main.value_bloc)
      .addEventZoom(new Runnable() { public void run() { cam_gui.updateView(); } } )
      .addEventMove(new Runnable() { public void run() { cam_gui.updateView(); } } );
    
    screen_gui.addEventFound(new Runnable() { public void run() { 
      cam.GRAB = false; cam_gui.hoverpile_passif = true; } } )
    .addEventNotFound(new Runnable() { public void run() { 
      cam.GRAB = true; cam_gui.hoverpile_passif = false; } } );
    
    cam_gui.setMouse(cam.mouse).setpMouse(cam.pmouse)
      .setView(cam.view)
      .addEventFound(new Runnable() { public void run() { cam.GRAB = false; } } )
      .addEventNotFound(new Runnable() { public void run() { 
        if (!screen_gui.hoverable_pile.found) { cam.GRAB = true; runEvents(eventsHoverNotFound); } } } );
    
    auto_load = macro_main.newBoo(false, "auto_load", "autoload");
    
    quicksave_run = macro_main.newRun("quicksave", "qsave", 
      new Runnable() { public void run() { full_data_save(); } } );
    quickload_run = macro_main.newRun("quickload", "qload", 
      new Runnable() { public void run() { addEventNextFrame(new Runnable() { 
      public void run() { setup_load(); } } ); } } );
    filesm_run = macro_main.newRun("files_management", "filesm", 
      new Runnable() { public void run() { filesManagement(); } } );
    
  }
  
  sRun quicksave_run, quickload_run, filesm_run;

  sInterface addToCamDrawerPile(Drawable d) { d.setPile(cam_gui.drawing_pile); return this; }
  sInterface addToScreenDrawerPile(Drawable d) { d.setPile(screen_gui.drawing_pile); return this; }
  
  sInterface addEventHoverNotFound(Runnable r) { eventsHoverNotFound.add(r); return this; }
  sInterface addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  sInterface removeEventFrame(Runnable r) { eventsFrame.remove(r); return this; }
  sInterface addEventNextFrame(Runnable r) { 
    if (active_nxtfrm_pile) eventsNextFrame1.add(r); else eventsNextFrame2.add(r); return this; }
  sInterface addEventSetup(Runnable r) { eventsSetup.add(r); return this; }
  
  String getAccess() { return user.access; }
  boolean canAccess(String a) { 
    if (getAccess().equals("admin") || getAccess().equals(a) || a.equals("all")) return true; 
    else return false; }
  
  sInterface addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  void setup_load() {
    file_savebloc.clear();
    file_savebloc.load_from(savepath);
    if (setup_bloc != null) setup_bloc.clear();
    setup_bloc = data.newBloc(file_savebloc, "setup");
    if (setup_bloc.getValue("auto_load") == null || 
        (setup_bloc.getValue("auto_load") != null && ((sBoo)setup_bloc.getValue("auto_load")).get())) {
      for (Runnable r : eventsSetupLoad) r.builder = setup_bloc;
      runEvents(eventsSetupLoad);
      macro_main.setup_load(setup_bloc);
      
      if (setup_bloc.getValue("show_taskpanel") != null) 
        show_taskpanel.set(((sBoo)setup_bloc.getValue("show_taskpanel")).get());
      
    }
    if (setup_bloc.getValue("auto_load") != null) 
      auto_load.set(((sBoo)setup_bloc.getValue("auto_load")).get());
    //setup_bloc.clear();
  }
  
  
  void addSpecializedSheet(Sheet_Specialize s) {
    macro_main.addSpecializedSheet(s); }
  Macro_Sheet addUniqueSheet(Sheet_Specialize s) {
    return macro_main.addUniqueSheet(s); }


  sValueBloc getTempBloc() {
    return new sValueBloc(data, "temp"); }


  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNextFrame1 = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsNextFrame2 = new ArrayList<Runnable>();
  boolean active_nxtfrm_pile = false;
  ArrayList<Runnable> eventsHoverNotFound = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsSetup = new ArrayList<Runnable>();
  boolean is_starting = true;
  boolean show_info = true;
  void frame() {
    input.frame_str(); // track mouse
    framerate.frame(); // calc last frame
    background(0);

    if (is_starting) { 
      is_starting = false; 
      runEvents(eventsSetup);
    }
    runEvents(eventsFrame); // << sim runs here
    if (!active_nxtfrm_pile) { runEvents(eventsNextFrame1); eventsNextFrame1.clear(); } 
    else { runEvents(eventsNextFrame2); eventsNextFrame2.clear(); } 
    active_nxtfrm_pile = !active_nxtfrm_pile;
    
    screen_gui.frame();
    cam.pushCam(); // matrice d'affichage
    cam_gui.frame();
    cam_gui.draw();
    cam.popCam();
    screen_gui.draw();

    //info:
    if (show_info) {
      fill(255); 
      textSize(18); 
      textAlign(LEFT);
      text(framerate.get() + " C " + trimStringFloat(cam.mouse.x) + 
        "," + trimStringFloat(cam.mouse.y), 10, 24 );
      text("S " + trimStringFloat(input.mouse.x) + 
        "," + trimStringFloat(input.mouse.y), 250, 24 );
    }
    
    data.frame(); // reset flags
    input.frame_end(); // reset flags
  }
}







//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


class Camera {
  sInput input;
  Rect view;
  sVec cam_pos; //position de la camera
  sFlt cam_scale; //facteur de grossicement
  float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true, grabbed = false;
  sBoo grid; //show grid
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
  boolean matrixPushed = false; //track if in or out of the cam matrix

  Camera(sInput i, sValueBloc d) { 
    grid = new sBoo(d, true, "show grid", "grid");
    cam_scale = new sFlt(d, 1.0, "cam scale", "scale");
    cam_scale.addEventChange(new Runnable() { public void run() {
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos)); 
      runEvents(eventsZoom);
      runEvents(eventsMove); }});
    cam_pos = new sVec(d, "cam pos", "pos");
    cam_pos.addEventChange(new Runnable() { public void run() {
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos)); 
      runEvents(eventsZoom);
      runEvents(eventsMove); }});
    view = new Rect(0, 0, width, height);
    view.pos.set(screen_to_cam(new PVector(0, 0)));
    view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
    input = i;
  }

  ArrayList<Runnable> eventsZoom = new ArrayList<Runnable>();
  Camera addEventZoom(Runnable r) { 
    eventsZoom.add(r); 
    return this;
  }
  ArrayList<Runnable> eventsMove = new ArrayList<Runnable>();
  Camera addEventMove(Runnable r) { 
    eventsMove.add(r); 
    return this;
  }

  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement

  void pushCam(float x, float y) {
    cam_pos.add(x*cam_scale.get(), y*cam_scale.get());
  }

  void pushCam() {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale.get());
    translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));
    matrixPushed = true;

    if (grid.get() && cam_scale.get() > 0.0008) {
      int spacing = 200;
      if (cam_scale.get() > 2) spacing /= 5;
      if (cam_scale.get() < 0.2) spacing *= 5;
      if (cam_scale.get() < 0.04) spacing *= 5;
      if (cam_scale.get() < 0.008) spacing *= 5;
      stroke(100);
      strokeWeight(2.0 / cam_scale.get());
      PVector s = screen_to_cam(new PVector(-spacing * cam_scale.get(), -spacing * cam_scale.get()));
      s.x -= s.x%spacing; 
      s.y -= s.y%spacing;
      PVector m = screen_to_cam( new PVector(width, height) );
      for (float x = s.x; x < m.x; x += spacing) {
        if ( ( (x-(x%spacing)) / spacing) % 5 == 0 ) stroke(100); 
        else stroke(70);
        if (x == 0) stroke(150, 0, 0);
        line(x, s.y, x, m.y);
      }
      for (float y = s.y; y < m.y; y += spacing) {
        if ( ( (y-(y%spacing)) / spacing) % 5 == 0 ) stroke(100); 
        else stroke(70);
        if (y == 0) stroke(150, 0, 0);
        line(s.x, y, m.x, y);
      }
    }
  }

  void popCam() {
    popMatrix();
    matrixPushed = false;
    if (screenshot) { 
      saveFrame("image/shot-########.png");
    }
    screenshot = false;

    PVector tm = screen_to_cam(input.mouse);
    PVector tpm = screen_to_cam(input.pmouse);
    PVector tmm = screen_to_cam(input.mmouse);
    mouse.x = tm.x; 
    mouse.y = tm.y;
    pmouse.x = tpm.x; 
    pmouse.y = tpm.y;
    mmouse.x = tmm.x; 
    mmouse.y = tmm.y;

    //permet le cliquer glisser le l'ecran
    if (input.getClick("MouseLeft") && GRAB) grabbed = true; 
    if (!input.getState("MouseLeft") && grabbed) grabbed = false; 
    if (input.getState("MouseLeft") && grabbed) { 
      cam_pos.add((mouse.x - pmouse.x)*cam_scale.get(), (mouse.y - pmouse.y)*cam_scale.get());
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
    }

    //permet le zoom
    if (input.mouseWheelUp && GRAB) { 
      cam_scale.set(cam_scale.get()*1/ZOOM_FACTOR); 
      cam_pos.mult(1/ZOOM_FACTOR); 
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
      runEvents(eventsZoom);
    }
    if (input.mouseWheelDown && GRAB) {
      cam_scale.set(cam_scale.get()*ZOOM_FACTOR); 
      cam_pos.mult(ZOOM_FACTOR); 
      view.pos.set(screen_to_cam(new PVector(0, 0)));
      view.size.set(screen_to_cam(new PVector(width, height)).sub(view.pos));
      runEvents(eventsMove);
      runEvents(eventsZoom);
    }
  }

  PVector cam_to_screen(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
    } else {
      pushMatrix();
      translate(width / 2, height / 2);
      scale(cam_scale.get());
      translate((cam_pos.x() / cam_scale.get()), (cam_pos.y() / cam_scale.get()));

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);

      popMatrix();
    }
    return r;
  }

  PVector screen_to_cam(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      pushMatrix();
      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);

      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    } else {
      pushMatrix();
      translate(-(cam_pos.x() / cam_scale.get()), -(cam_pos.y() / cam_scale.get()));
      scale(1/cam_scale.get());
      translate(-width / 2, -height / 2);
      r.x = screenX(p.x, p.y); 
      r.y = screenY(p.x, p.y);
      popMatrix();
    }
    return r;
  }
}


//#######################################################################
//##                           FRAMERATE                               ##
//#######################################################################

/*
framerate
 median and current framerate
 frame duration
 frame and time counter total and resetable
 get frame number for delay of(ms)
 */

class sFramerate {
  int frameRate_cible = 60;
  float[] frameR_history;
  int hist_it = 0;
  int frameR_update_rate = 10; // frames between update 
  int frameR_update_counter = frameR_update_rate;

  float current_time = 0;
  float prev_time = 0;
  float frame_length = 0;

  float frame_median = 0;

  float reset_time = 0;
  int frame_counter = 0;

  sFlt median_framerate, current_framerate, frame_duration;
  sInt sec_since_reset, frame_since_reset;

  int frameNbForMsDelay(int d) { 
    return int(d * median_framerate.get() / 1000);
  }

  int get() { 
    return int(median_framerate.get());
  }

  sFramerate(sValueBloc d, int c) {
    frameRate_cible = c;
    frameRate(frameRate_cible);
    frameR_history = new float[frameRate_cible];
    for (int i = 0; i < frameR_history.length; i++) frameR_history[i] = 1000/frameRate_cible;

    sec_since_reset = new sInt(d, 0, "sec_since_reset", "sec");
    frame_since_reset = new sInt(d, 0, "frame_since_reset", "frsr");
    median_framerate = new sFlt(d, 0, "median_framerate", "mfr");
    current_framerate = new sFlt(d, 0, "current_framerate", "cfr");
    frame_duration = new sFlt(d, 0, "frame_duration", "fdur");
  }
  void reset() { 
    sec_since_reset.set(0); 
    reset_time = millis(); 
    frame_counter = 0;
  }

  void frame() {
    frame_counter++;
    frame_since_reset.set(frame_counter);

    current_time = millis();
    frame_length = current_time - prev_time;
    frame_duration.set(frame_length);
    current_framerate.set(frame_length / 1000);
    prev_time = current_time;

    sec_since_reset.set(int((current_time - reset_time) / 1000));

    frameR_history[hist_it] = frame_length;
    hist_it++;
    if (hist_it >= frameR_history.length) { 
      hist_it = 0;
    }

    if (frameR_update_counter == frameR_update_rate) {
      frame_median = 0;
      for (int i = 0; i < frameR_history.length; i++)  frame_median += frameR_history[i];
      frame_median /= frameR_history.length;
      median_framerate.set(1000/frame_median);

      frameR_update_counter = 0;
    }
    frameR_update_counter++;
  }
}


//#######################################################################
//##                             INPUT                                 ##
//#######################################################################

/*
Inputs
 information disponible as variable / get methods / svalue
 keyboard
 getbool for each key state and triggers
 mouse
 getbool for each key state and triggers
 double click (delay set in real time)
 getWheel  getPointerPos  getPointerLastMove
 getbool for pointer movement state and trigger
 joystick / manette 
 frame()
 */

class sInput_Button {
  boolean state = false, trigClick = false, trigUClick = false;
  //boolean trigJClick = false, trigJUClick = false;
  char key_char;
  String ref;
  sInput_Button(String r, char c) { 
    ref = copy(r); 
    key_char = c;
  }
  sInput_Button(String r) { 
    ref = copy(r);
  }
  void eventPress() {
    state=true;
    trigClick=true;
  }
  void eventRelease() {
    state=false;
    trigUClick=true;
  }
  void frame() {
    trigClick = false; 
    trigUClick = false;
  }
}

public class sInput {

  //keyboard letters
  boolean getState(char k) { 
    return getKeyboardButton(k).state;
  }
  boolean getClick(char k) { 
    return getKeyboardButton(k).trigClick;
  }
  boolean getUnClick(char k) { 
    return getKeyboardButton(k).trigUClick;
  }

  //mouse n specials
  boolean getState(String k) { 
    return getButton(k).state;
  }
  boolean getClick(String k) { 
    return getButton(k).trigClick;
  }
  boolean getUnClick(String k) { 
    return getButton(k).trigUClick;
  }

  char getLastKey() { 
    return last_key;
  }

  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    mouseLeft = getButton("MouseLeft");
    mouseRight = getButton("MouseRight");
    mouseCenter = getButton("MouseCenter");
    keyBackspace = getButton("Backspace"); 
    keyEnter = getButton("Enter");
    keyLeft = getButton("Left"); 
    keyRight = getButton("Right");
    keyUp = getButton("Up"); 
    keyDown = getButton("Down");
    keyAll = getButton("All"); //any key
  }

  PVector mouse = new PVector();
  PVector pmouse = new PVector(); //prev pos
  PVector mmouse = new PVector(); //mouvement
  boolean mouseWheelUp, mouseWheelDown;
  ArrayList<sInput_Button> pressed_keys = new ArrayList<sInput_Button>();
  char last_key = ' ';

  ArrayList<sInput_Button> buttons = new ArrayList<sInput_Button>();
  sInput_Button mouseLeft, mouseRight, mouseCenter, 
    keyBackspace, keyEnter, keyLeft, keyRight, keyUp, keyDown, keyAll;

  sInput_Button getButton(String r) {
    for (sInput_Button b : buttons) if (b.ref.equals(r)) return b;
    sInput_Button n = new sInput_Button(r); 
    buttons.add(n);
    return n;
  }
  sInput_Button getKeyboardButton(char k) {
    for (sInput_Button b : buttons) if (b.ref.equals("k") && k == b.key_char) return b;
    sInput_Button n = new sInput_Button("k", k); 
    buttons.add(n);
    return n;
  }

  void frame_str() {
    mouse.x = mouseX; 
    mouse.y = mouseY; 
    pmouse.x = pmouseX; 
    pmouse.y = pmouseY;
    mmouse.x = mouseX - pmouseX; 
    mmouse.y = mouseY - pmouseY;
  }
  void frame_end() {
    mouseWheelUp = false; 
    mouseWheelDown = false;
    for (sInput_Button b : buttons) b.frame();
  }

  void mouseWheelEvent(MouseEvent event) {
    float e = event.getAmount();
    if (e>0) { 
      mouseWheelUp =true; 
      mouseWheelDown =false;
    }
    if (e<0) { 
      mouseWheelDown = true; 
      mouseWheelUp=false;
    }
  }  

  void keyPressedEvent() { 
    for (sInput_Button b : buttons) 
      if (b.ref.equals("k") && b.key_char == key) { b.eventPress(); pressed_keys.add(b); }
    if (key == CODED) {
      if (keyCode == LEFT) keyLeft.eventPress();
      if (keyCode == RIGHT) keyRight.eventPress();
      if (keyCode == UP) keyUp.eventPress();
      if (keyCode == DOWN) keyDown.eventPress();
    } else {
      if (key == BACKSPACE) keyBackspace.eventPress();
      if (key == ENTER) keyEnter.eventPress();
      keyAll.eventPress();
      last_key = key;
    }
  }

  void keyReleasedEvent() { 
    for (sInput_Button b : buttons) 
      if (b.ref.equals("k") && b.key_char == key) { b.eventRelease(); pressed_keys.remove(b); }
    if (key == CODED) {
      if (keyCode == LEFT) keyLeft.eventRelease();
      if (keyCode == RIGHT) keyRight.eventRelease();
      if (keyCode == UP) keyUp.eventRelease();
      if (keyCode == DOWN) keyDown.eventRelease();
    } else {
      if (key == BACKSPACE) keyBackspace.eventRelease();
      if (key == ENTER) keyEnter.eventRelease();
      boolean ks = false;
      for (sInput_Button b : buttons) ks = ks && b.state;
      if (!ks) keyAll.eventRelease();
    }
  }

  void mousePressedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventPress();
    if (mouseButton==RIGHT) mouseRight.eventPress();
    if (mouseButton==CENTER) mouseCenter.eventPress();
  }

  void mouseReleasedEvent()
  {
    if (mouseButton==LEFT) mouseLeft.eventRelease();
    if (mouseButton==RIGHT) mouseRight.eventRelease();
    if (mouseButton==CENTER) mouseCenter.eventRelease();
  }
}
