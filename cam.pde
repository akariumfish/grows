PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 0.2; //facteur de grossicement
float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie

boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
//int shot_cnt = 0; //prevue pour la sauvegarde d'image avec des num coherent

void cam_input_update() {
  //permet le cliquer glisser le l'ecran
  if (mouseButtons[2]) {
    cam_pos.x += mouseX - pmouseX;
    cam_pos.y += mouseY - pmouseY;
  }
  
  //permet le zoom
  if (mouseWheelUp || keysClick[2]) {
    cam_scale *= ZOOM_FACTOR;
    cam_pos.x *= ZOOM_FACTOR;
    cam_pos.y *= ZOOM_FACTOR;
  }
  if (mouseWheelDown || keysClick[3]) {
    cam_scale /= ZOOM_FACTOR;
    cam_pos.x /= ZOOM_FACTOR;
    cam_pos.y /= ZOOM_FACTOR;
  }
}

void cam_movement() {
  translate((width - PANEL_WIDTH) / 2, height / 2);
  scale(cam_scale);
  translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
}

void try_screenshot() {
  // enregistrement d'un screenshot si le flag est true
  if (screenshot) {
    //String name = "shot" + shot_cnt + ".png";
    
    //File file = new File(sketchPath(name));
    //while (file.exists()) {
    //  shot_cnt++;
    //  name = "shot" + shot_cnt + ".png";
    //  file = new File(sketchPath(name));
    //}
    saveFrame("image/shot-########.png");
  }
  screenshot = false;
}
