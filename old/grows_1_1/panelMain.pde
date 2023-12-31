//ici on gere les menus
//plus bas il y a les graphs


import controlP5.*; //la lib pour les menu

ControlP5 cp5; //l'objet main pour les menu

Group group_control; // la grande tab
Textlabel info_slide, info_framerate, info_turn, info_repeat;
Textfield textfieldSeed;

float mx = 0; 
float my = 0; //pour bouger les fenetres
int PANEL_WIDTH = 400; //largeur de la tab
PVector def_ctrlpanel_pos = new PVector(0, 0);
int TEXT_SIZE = 18;
int BTN_SIZE = 40;
int maxctrlerByLine = 10;
int utilctrlid = 1000;

void init_panel() {
  cp5 = new ControlP5(this);

  cp5.addTab("Menu")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;
  cp5.addTab("Macros")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;

  cp5.getTab("default")
    // .activateEvent(true)
    .setLabel("Main")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;
  cp5.getTab("Menu").bringToFront();

  init_panel_grower();
  init_macro();

  cp5.addButton("HIDE_MENUS")
    .setPosition(35, height - 27)
    .setSize(20, 20)
    .setId(utilctrlid + 11)
    .setTab("Menu")
    .getCaptionLabel().setText("M").setFont(createFont("Arial", 16))
    ;

  group_control = cp5.addGroup("group_control")
    .setPosition(width - (PANEL_WIDTH), 10)
    .setSize(PANEL_WIDTH, 10)
    .setBackgroundHeight(310)
    .setBackgroundColor(color(60, 200))
    .disableCollapse()
    .moveTo("Menu")
    ;
  group_control.getCaptionLabel().setText("");

  addText(group_control, "ctrl_title1", "STRUCTURE GENERATOR", 5, 7, 30).setFont(createFont("Arial Bold", 30));

  //addButton(group_control, "prev_slide", "<", 10, 40, 90, 40, utilctrlid + 13, TEXT_SIZE * 2);
  //addButton(group_control, "next_slide", ">", 300, 40, 90, 40, utilctrlid + 14, TEXT_SIZE * 2);
  //info_slide = addText(group_control, "info_slide", "SLIDE: 1", 160, 50).setFont(createFont("Arial Bold",20));

  addText(group_control, "title_seed", "Seed", 20, 55, TEXT_SIZE);
  textfieldSeed = cp5.addTextfield("seed_input")
    .setPosition(90, 50)
    .setSize(220, 30)
    .setCaptionLabel("")
    .setValue("" + SEED)
    .setFont(createFont("Arial", TEXT_SIZE))
    .setColor(color(255))
    .setGroup(group_control)
    ;
  addButton(group_control, "readseed", "V", 320, 50, 30, 30, utilctrlid + 9, TEXT_SIZE);
  addButton(group_control, "rngseed", "R", 360, 50, 30, 30, utilctrlid + 10, TEXT_SIZE);

  info_framerate = addText(group_control, "info_framerate", " ", 50, 90);
  info_turn = addText(group_control, "info_turn", " ", 250, 90);

  build_line_factor(group_control, "SPEED", " ", repeat_runAll, 10, 120, 5);

  Button b; //pointer

  b = addButton(group_control, "running", "p", 25, 170, 50, 50, utilctrlid + 3, TEXT_SIZE * 1.5)
    .setSwitch(true);
  if (pause) b.setOn();
  addButton(group_control, "reset", "RESET", 100, 170, 95, 50, utilctrlid + 1, TEXT_SIZE * 1.2);
  addButton(group_control, "reset-rng", "RNG", 205, 170, 95, 50, utilctrlid + 15, TEXT_SIZE * 1.2);
  addButton(group_control, "saveframe", "I", 325, 170, 50, 50, utilctrlid + 2, TEXT_SIZE * 1.5);

  //addButton(group_control, "save-param", "S", 100, 270, 95, 50, utilctrlid + 16, TEXT_SIZE * 1.5);
  //addButton(group_control, "load-param", "L", 205, 270, 95, 50, utilctrlid + 17, TEXT_SIZE * 1.5);

  b = addButton(group_control, "repeat", "RP", 10, 230, 50, 18, utilctrlid + 18, TEXT_SIZE)
    .setSwitch(true);
  if (auto_repeat) b.setOn();
  b = addButton(group_control, "repeatrng", "RNG", 10, 254, 50, 18, utilctrlid + 21, TEXT_SIZE)
    .setSwitch(true);
  if (repeat_random) b.setOn();
  addButton(group_control, "repeat-100", "-100", 80, 230, 60, 40, utilctrlid + 20, TEXT_SIZE * 1.2);
  addButton(group_control, "repeat+100", "+100", 330, 230, 60, 40, utilctrlid + 19, TEXT_SIZE * 1.2);
  info_repeat = addText(group_control, "info_repeat", "repeat at turn " + repeat_turn, 150, 240);
  addText(group_control, "info_fullscreen", "space : pause  ;  H : hide  ;  clic then ESC : quit", 10, 280);

  //cp5.printControllerMap(); // print all ui element
}

public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getId(); //on va retrouver le controlleur corespondant par sont id

  //find the right ctrl
  int line = int((float)id / (float)maxctrlerByLine);
  int ctrl = id - (line * maxctrlerByLine);
  float modifier = 1.0;
  if (ctrl == 1) modifier = 2.0;
  if (ctrl == 2) modifier = 1.2;
  if (ctrl == 3) modifier = 0.833;
  if (ctrl == 4) modifier = 0.5;
  if (ctrl == 5) modifier = -10;
  if (ctrl == 6) modifier = -1;
  if (ctrl == 7) modifier = 1;
  if (ctrl == 8) modifier = 10;

  event_panel_grower(id, line, modifier);


  if (id == utilctrlid + 18) { // boutton repeat
    auto_repeat = ((Button)cp5.getController("repeat")).isOn();
  }
  if (id == utilctrlid + 21) { // boutton repeat
    repeat_random = ((Button)cp5.getController("repeatrng")).isOn();
  }
  if (id == utilctrlid + 19) { // boutton +100
    repeat_turn += 100;
    info_repeat.setText("repeat at turn " + repeat_turn);
  }
  if (id == utilctrlid + 20) { // boutton -100
    repeat_turn -= 100;
    info_repeat.setText("repeat at turn " + repeat_turn);
  }
  if (id == utilctrlid + 16) { // boutton save
    save_parameters();
  }
  if (id == utilctrlid + 17) { // boutton load

    reset();
  }
  if (id == utilctrlid + 13) { // boutton < slide
    slide = constrain(slide - 1, 0, maxSlide);
    info_slide.setText("SLIDE: " + (slide + 1));
    reset();
  }
  if (id == utilctrlid + 14) { // boutton > slide
    slide = constrain(slide + 1, 0, maxSlide);
    info_slide.setText("SLIDE: " + (slide + 1));
    reset();
  }
  if (id == utilctrlid + 1) { 
    reset();
  } // boutton reset
  if (id == utilctrlid + 15) { // boutton rng + reset
    SEED = int(random(1000000000));
    textfieldSeed.setValue("" + SEED);
    reset();
  }
  if (id == utilctrlid + 2) { 
    screenshot = true;
  }// boutton print
  if (id == utilctrlid + 3) { 
    pause = ((Button)cp5.getController("running")).isOn();
  }//button pause
  if (id == utilctrlid + 11) { // boutton hide
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); 
      group_grow.show();
    } else {
      if (group_control.isVisible()) group_control.hide();
      if (group_grow.isVisible()) group_grow.hide();
    }
  }

  //button seed
  if (id == utilctrlid + 9) { //read
    int val = int(textfieldSeed.getText());
    if (val != 0) {
      SEED = val;
      textfieldSeed.setColor(color(255));
    } else {
      textfieldSeed.setColor(color(255, 0, 0));
    }
  }
  if (id == utilctrlid + 10) { //rng
    SEED = int(random(1000000000));
    textfieldSeed.setValue("" + SEED);
  }

  if (line == 5) { 
    repeat_runAll *= modifier; 
    update_textlabel("SPEED", " ", repeat_runAll);
  }
}

boolean BACK_SHOW_GRAPH = true;

void update_all_menu() {
  // hide show panel with 'h'
  if (keysClick[9]) {
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); 
      group_grow.show();
      cp5.getTab("Macros").show();
      cp5.getTab("Menu").show();
      cp5.getTab("default").show();
      SHOW_GRAPH = BACK_SHOW_GRAPH;
    } else {
      if (group_control.isVisible()) group_control.hide();
      if (group_grow.isVisible()) group_grow.hide();
      cp5.getTab("Macros").hide();
      cp5.getTab("Menu").hide();
      cp5.getTab("default").hide();
      BACK_SHOW_GRAPH = SHOW_GRAPH;
      SHOW_GRAPH = false;
    }
  }
  //moving control panel
  if (group_control.isMouseOver() && mouseClick[0]) {
    mx = group_control.getPosition()[0] - mouseX;
    my = group_control.getPosition()[1] - mouseY;
    GRAB = false;//deactive le deplacement camera
  }
  if (group_control.isMouseOver() && mouseUClick[0]) {
    GRAB = true;
  }
  if (group_control.isMouseOver() && mouseButtons[0]) {
    group_control.setPosition(mouseX + mx, mouseY + my);
  }

  info_framerate.setText("framerate: " + int(frameRate));
  info_turn.setText("turn: " + counter);
  update_panel_grower();
}






//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################

//permet l'enregistrement de donné pour le graphique
int larg =             1200;
int[] graph  = new int[1200];
int[] graph2 = new int[1200];
int gc = 0;
int max = 10;

boolean SHOW_GRAPH = false;// affichage du graph a un bp

void init_graphs() {
  //initialisation des array des graph
  for (int i = 0; i < larg; i++) { 
    graph[i] = 0; 
    graph2[i] = 0;
  }
  max = 10;
}

void draw_graphs() {
  if (SHOW_GRAPH && !cp5.getTab("default").isActive()) {
    strokeWeight(0.5);
    stroke(255);
    for (int i = 1; i < larg; i++) if (i != gc) {
      stroke(255);
      line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000), 
        i, height - 10 - (graph[i] * (height-20) / 5000) );
      stroke(255, 255, 0);
      line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / max), 
        i, height - 10 - (graph2[i] * (height-20) / max) );
    }
    stroke(255, 0, 0);
    strokeWeight(7);
    if (gc != 0) {
      point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
      point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / max) );
    }
  }
}

void update_graph() {
  //enregistrement des donner dans les array
  graph[gc] = baseNb();

  int g = growsNb();
  if (max < g) max = g;
  if (graph2[gc] == max) {
    max = 10;
    for (int i = 0; i < graph2.length; i++) if (i != gc && max < graph2[i]) max = graph2[i];
  }
  graph2[gc] = g;

  if (gc < larg-1) gc++; 
  else gc = 0;
}
