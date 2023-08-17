//ici on gere les menus
import controlP5.*; //la lib pour les menu

ControlP5 cp5; //l'objet main pour les menu

Group group_control; // la grande tab
Textlabel info_slide, info_framerate, info_turn;
Textfield textfieldSeed;

float mx = 0; float my = 0; //pour bouger les fenetres
int PANEL_WIDTH = 400; //largeur de la tab
PVector def_ctrlpanel_pos = new PVector(0, 0);
int TEXT_SIZE = 18;
int BTN_SIZE = 40;
int maxctrlerByLine = 10;
int utilctrlid = 1000;

void init_panel() {
  cp5 = new ControlP5(this);
  
  cp5.addButton("HIDE_MENUS")
     .setPosition(10, height - 30)
     .setSize(20,20)
     .setId(utilctrlid + 11)
     .getCaptionLabel().setText("M").setFont(createFont("Arial",16))
     ;
  
  group_control = cp5.addGroup("group_control")
             .setPosition(width - PANEL_WIDTH, height - 280)
             .setSize(PANEL_WIDTH, 10)
             .setBackgroundHeight(270)
             .setBackgroundColor(color(60, 200))
             .disableCollapse()
             ;
             
  addText(group_control, "ctrl_title1", "STRUCTURE GENERATOR", 5, 0, 30).setFont(createFont("Arial Bold",30));
  
  addButton(group_control, "prev_slide", "<", 10, 40, 90, 40, utilctrlid + 13, TEXT_SIZE * 2);
  addButton(group_control, "next_slide", ">", 300, 40, 90, 40, utilctrlid + 14, TEXT_SIZE * 2);
  info_slide = addText(group_control, "info_slide", "SLIDE: 1", 160, 50).setFont(createFont("Arial Bold",20));
  
  addText(group_control, "title_seed", "Seed", 20, 95, TEXT_SIZE);
  textfieldSeed = cp5.addTextfield("seed_input")
     .setPosition(90,90)
     .setSize(220,30)
     .setCaptionLabel("")
     .setValue("" + SEED)
     .setFont(createFont("Arial",TEXT_SIZE))
     .setColor(color(255))
     .setGroup(group_control)
     ;
  addButton(group_control, "readseed", "V", 320, 90, 30, 30, utilctrlid + 9, TEXT_SIZE);
  addButton(group_control, "rngseed", "R", 360, 90, 30, 30, utilctrlid + 10, TEXT_SIZE);
  
  info_framerate = addText(group_control, "info_framerate", " ", 50, 130);
  info_turn = addText(group_control, "info_turn", " ", 250, 130);
  
  build_line_factor(group_control, "SPEED", repeat_runAll, 10, 160, 5);
  
  Button b; //pointer
  
  b = addButton(group_control, "running", "p", 25, 210, 50, 50, utilctrlid + 3, TEXT_SIZE * 1.5)
    .setSwitch(true);
  if (pause) b.setOn();
  addButton(group_control, "reset", "RESET", 100, 210, 95, 50, utilctrlid + 1, TEXT_SIZE * 1.2);
  addButton(group_control, "reset-rng", "RNG", 205, 210, 95, 50, utilctrlid + 15, TEXT_SIZE * 1.2);
  addButton(group_control, "print", "I", 325, 210, 50, 50, utilctrlid + 2, TEXT_SIZE * 1.5);
  
  init_panel_grower();
  
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
  if (id == utilctrlid + 1) { reset(); } // boutton reset
  if (id == utilctrlid + 15) { // boutton rng + reset
    SEED = int(random(1000000000));
    textfieldSeed.setValue("" + SEED);
    reset();
  }
  if (id == utilctrlid + 2) { screenshot = true; }// boutton print
  if (id == utilctrlid + 3) { pause = ((Button)cp5.getController("running")).isOn(); }//button pause
  if (id == utilctrlid + 11) { // boutton hide
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); group_grow.show();
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
  
  if (line == 5) { repeat_runAll *= modifier; update_textlabel("SPEED", repeat_runAll); }
  
}

void update_all_menu() {
  // hide show panel with 'h'
  if (keysClick[9]) {
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); group_grow.show();
    } else {
      if (group_control.isVisible()) group_control.hide();
      if (group_grow.isVisible()) group_grow.hide();
    }
  }
  //moving control panel
  if (group_control.isMouseOver() && mouseClick[0]) {
    mx = group_control.getPosition()[0] - mouseX;
    my = group_control.getPosition()[1] - mouseY;
  }
  if (group_control.isMouseOver() && mouseButtons[0]) {
    group_control.setPosition(mouseX + mx,mouseY + my);
  }
  
  info_framerate.setText("framerate: " + int(frameRate));
  info_turn.setText("turn: " + counter);
  update_panel_grower();
}
