
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
      framerate
        median and current framerate
        frame duration
        frame and time counter total and resetable
        get frame number for delay of(ms)
      joystick / manette 
    frame()
  
  
  

*/



//#######################################################################
//##                             INPUT                                 ##
//#######################################################################



void mouseWheel(MouseEvent event) { 
  interf.mouseWheelEvent(event);
}  
void keyPressed() { 
  interf.keyPressedEvent();
}  
void keyReleased() { 
  interf.keyReleasedEvent();
}
void mousePressed() { 
  interf.mousePressedEvent();
}
void mouseReleased() { 
  interf.mouseReleasedEvent();
}
void mouseDragged() { 
  interf.mouseDraggedEvent();
}
void mouseMoved() { 
  interf.mouseMovedEvent();
}

public class sInput {

  boolean keyButton, keyClick, keyJClick, keyUClick, keyJUClick;
  boolean[] keysButtons, keysClick, keysJClick, keysUClick, keysJUClick;
  boolean[] mouseButtons, mouseClick, mouseJClick, mouseUClick, mouseJUClick;
  boolean mouseMove = false;
  boolean mouseWheelUp = false;
  boolean mouseWheelDown = false;
  char last_key = ' ';

  char[] keys_code = { 'a', 'b', 'c', 'd'};
  int keyNb = keys_code.length;

  boolean getButton(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysButtons[i]) return true;
    return false;
  }

  boolean getClick(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysClick[i]) return true;
    return false;
  }

  boolean getUnclick(char c) {
    for (int i = 0; i < keys_code.length; i++)
      if (keys_code[i] == c && keysUClick[i]) return true;
    return false;
  }

  public sInput() {//PApplet app) {
    //app.registerMethod("pre", this);
    keysButtons = new boolean[keyNb];
    keysClick = new boolean[keyNb]; 
    keysJClick = new boolean[keyNb];
    keysUClick = new boolean[keyNb]; 
    keysJUClick = new boolean[keyNb];

    for (int i = keyNb-1; i >= 0; i--) {
      keysButtons[i] = false;
      keysClick[i] = false; 
      keysJClick[i] = false;
      keysUClick[i] = false; 
      keysJUClick[i] = false;
    }

    keyButton = false;
    keyClick = false; 
    keyJClick = false;
    keyUClick = false; 
    keyJUClick = false;

    mouseButtons = new boolean[3];
    mouseClick = new boolean[3]; 
    mouseJClick = new boolean[3];
    mouseUClick = new boolean[3]; 
    mouseJUClick = new boolean[3];

    for (int i = 2; i >= 0; i--) {
      mouseButtons[i] = false;
      mouseClick[i] = false; 
      mouseJClick[i] = false;
      mouseUClick[i] = false; 
      mouseJUClick[i] = false;
    }
  }
  
  PVector mouse = new PVector();

  public void update() {
    mouse.x = mouseX; mouse.y = mouseY;
    mouseWheelUp = false; 
    mouseWheelDown = false;
    if (mouseX == pmouseX && mouseY == pmouseY) {
      mouseMove = false;
    }
    for (int i = 2; i >= 0; i--) {
      if (mouseClick[i] == true && mouseJClick[i] == false) {
        mouseJClick[i] = true;
      }
      if (mouseClick[i] == true && mouseJClick[i] == true) {
        mouseClick[i] = false; 
        mouseJClick[i] = false;
      }
      if (mouseUClick[i] == true && mouseJUClick[i] == false) {
        mouseJUClick[i] = true;
      }
      if (mouseUClick[i] == true && mouseJUClick[i] == true) {
        mouseUClick[i] = false; 
        mouseJUClick[i] = false;
      }
    }
    for (int i = keyNb-1; i >= 0; i--) {
      if (keysClick[i] == true) {
        keysJClick[i] = true;
      }
      if (keysClick[i] == true && keysJClick[i] == true) {
        keysClick[i] = false; 
        keysJClick[i] = false;
      }
      if (keysUClick[i] == true) {
        keysJUClick[i] = true;
      }
      if (keysUClick[i] == true && keysJUClick[i] == true) {
        keysUClick[i] = false; 
        keysJUClick[i] = false;
      }
    }
    if (keyClick == true) {
      keyJClick = true;
    }
    if (keyClick == true && keyJClick == true) {
      keyClick = false; 
      keyJClick = false;
    }
    if (keyUClick == true) {
      keyJUClick = true;
    }
    if (keyUClick == true && keyJUClick == true) {
      keyUClick = false; 
      keyJUClick = false;
    }
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

  void keyPressedEvent()
  {
    for (int i = 0; i < keyNb; i++)
      if (key==keys_code[i]) {
        keysButtons[i]=true;
        keysClick[i]=true;
      }
    keyButton=true;
    keyClick=true;
  }

  void keyReleasedEvent()
  {
    for (int i = 0; i < keyNb; i++)
      if (key==keys_code[i]) {
        keysButtons[0]=false;
        keysUClick[0]=true;
      }
    keyButton=false;
    keyUClick=true;
  }

  void mousePressedEvent()
  {
    if (mouseButton==LEFT) {
      mouseButtons[0]=true;
      mouseClick[0]=true;
    }
    if (mouseButton==RIGHT) {
      mouseButtons[1]=true;
      mouseClick[1]=true;
    }
    if (mouseButton==CENTER) {
      mouseButtons[2]=true;
      mouseClick[2]=true;
    }
  }

  void mouseReleasedEvent()
  {
    if (mouseButton==LEFT) {
      mouseButtons[0]=false;
      mouseUClick[0]=true;
    }
    if (mouseButton==RIGHT) {
      mouseButtons[1]=false;
      mouseUClick[1]=true;
    }
    if (mouseButton==CENTER) {
      mouseButtons[2]=false;
      mouseUClick[2]=true;
    }
  }

  void mouseDraggedEvent() { 
    mouseMove = true;
  }

  void mouseMovedEvent() { 
    mouseMove = true;
  }
}




////#######################################################################
////##                           FRAMERATE                               ##
////#######################################################################


//class sFramerate {
//  int frameRate_cible = 60;
  
//  float[] frameR_history = new float[frameRate_cible];
//  int hist_it = 0;
//  int frameR_update_rate = 10; // frames between update 
//  int frameR_update_counter = frameR_update_rate;
  
//  float current_time = 0;
//  float prev_time = 0;
//  float frame_length = 0;
  
//  float frame_median = 0;
//  sInt value = new sInt(simval, 0, "sFramerate");
  
//  sInt time = new sInt(simval, 0);
//  float reset_time = 0;
  
//  sFlt tickrate = new sFlt(simval, 0);
  
//  sFramerate(int c) {
//    frameRate_cible = c;
//    frameRate(frameRate_cible);
//    for (int i = 0 ; i < frameR_history.length ; i++) frameR_history[i] = 1000/frameRate_cible;
//  }
  
//  float get() { return value.get(); }
  
//  void reset() { time.set(0); reset_time = millis(); }
  
//  void update() {
    
//    current_time = millis();
//    frame_length = current_time - prev_time;
//    prev_time = current_time;
    
//    time.set(int((current_time - reset_time) / 1000));
    
//    frameR_history[hist_it] = frame_length;
//    hist_it++;
//    if (hist_it >= frameR_history.length) { hist_it = 0; }
    
//    if (frameR_update_counter == frameR_update_rate) {
//      frame_median = 0;
//      for (int i = 0 ; i < frameR_history.length ; i++)  frame_median += frameR_history[i];
//      frame_median /= frameR_history.length;
//      value.set(int(1000/frame_median));
//      tickrate.set(value.get() * sim.tick_by_frame.get());
//      frameR_update_counter = 0;
//    }
//    frameR_update_counter++;
//  }
//}






 
