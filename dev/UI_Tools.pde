import controlP5.*; //la lib pour les menu
import java.util.Iterator;

ControlP5 cp5; //l'objet main pour les menu

//int TEXT_SIZE = 18;
//int BTN_SIZE = 40;

String STARTING_TAB = "Menu";

//       ----- INIT -----
void init_UI() {
  cp5 = new ControlP5(this);
  cp5.addTab("Menu")
     .getCaptionLabel().setFont(getFont(16))
     ;
  cp5.getTab("default")
     .setLabel("Main")
     .getCaptionLabel().setFont(getFont(16))
     ;
  cp5.getTab(STARTING_TAB).bringToFront();
}

//       ----- EVENT -----
ArrayList<UIEvent> UIEventList = new ArrayList<UIEvent>();
class UIEvent { int id; Channel chan; float value; }
void addUIEvent(int i, Channel c, float v) {
  UIEvent e = new UIEvent();
  e.id = i; e.chan = c; e.value = v;
  UIEventList.add(e); }

public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getId();
  for (UIEvent e : UIEventList)
    if (e.id == id) callChannel(e.chan, e.value);
}

//       ----- BUILDER -----
//panels
int PANEL_WIDTH = 400;
Panel addPanel(String title, float x, float y) {
  Panel p = new Panel(cp5, title, x, y);
  return p; }
class Panel extends Callable {
  float mx = 0; float my = 0;
  Group g;
  float line_total_height = 0;
  Panel(ControlP5 c, String title, float x, float y) {
    g = new Group(c, "panel" + get_free_id());
    g.setPosition(x, y)
        .setSize(PANEL_WIDTH, 10)
        .setBackgroundHeight(10)
        .setBackgroundColor(color(60, 200))
        .disableCollapse()
        .moveTo("Menu")
        .activateEvent(true)
        //.setMoveable(true)
        .getCaptionLabel().setText("");
        
    this.addText(title, 24);
    
    this.addChannel(frame_chan);
  }
  
  void addLine(float h) {
    line_total_height += h;
    g.setBackgroundHeight(int(line_total_height) + 20);
  }
  
  Textlabel addText(String label, int st) {
    int tl = int(label.length() * st / 1.6);
    addLine(st);
    return cp5.addTextlabel("textlabel" + get_free_id())
       .setText(label)
       .setPosition(10 + ( (PANEL_WIDTH - tl - 20) / 2 ), 10 + line_total_height - st)
       .setColorValue(0xffffffff)
       .setFont(getFont(st))
       .setGroup(g)
       ;
  }

  //todo
  Button addButton(String label, int st, 
                   float x, float y, int sx, int sy, 
                   Channel c, float v) {
    Button b = addButton(label, st, x, y, sx, sy);
    addUIEvent(b.getId(), c, v);
    return b;
  }
  Button addButton(String label, int st, 
                   float x, float y, int sx, int sy, 
                   ControlListener c) {
    Button b = addButton(label, st, x, y, sx, sy);
    b.addListener(c);
    return b;
  }
  Button addButton(String label, int st, 
                   float x, float y, int sx, int sy) {
    addLine(sy + 10);
    int id = get_free_id();
    Button b = cp5.addButton("button" + get_free_id())
       .setPosition(x, y)
       .setSize(sx,sy)
       .setGroup(g)
       .setId(id)
       ;
    b.getCaptionLabel().setText(label).setFont(getFont(st));
    return b;
  }
  
  void answer(Channel channel, float value) {
    //moving control panel
    if (g.isMouseOver()) {
      if (mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        GRAB = false; //deactive le deplacement camera
      } else if (mouseUClick[0]) {
        GRAB = true;
      }
      if (mouseButtons[0]) {
        g.setPosition(mouseX + mx,mouseY + my);
      }
    }
  }
}

Textlabel addText(Group g, String label, float x, float y, int st) {
  return cp5.addTextlabel("textlabel" + get_free_id())
     .setText(label)
     .setPosition(x, y)
     .setSize(10, st)
     .setColorValue(0xffffffff)
     .setFont(getFont(st))
     .setGroup(g)
     ;
}

void addIncrButtons(Group g, int st, float x, float y, int sx, int sy, Channel c) {
  addButton(g, "/2", st, x, y, sx, sy, c, 0.5);
  addButton(g, "x2", st, x+sx, y, sx, sy, c, 2);
}

Button addButton(Group g, String label, int st, 
                 float x, float y, int sx, int sy, 
                 Channel c, float v) {
  int id = get_free_id();
  Button b = cp5.addButton("button" + get_free_id())
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(g)
     .setId(id)
     .addListener(new ControlListener() {
          public void controlEvent(final ControlEvent ev) {  
            
          }
        })
     ;
  b.getCaptionLabel().setText(label).setFont(getFont(st));
  addUIEvent(id, c, v);
  return b;
}

Button addswitch( Group g, String label, int st, 
                  float x, float y, int sx, int sy, 
                  Channel c, boolean on ) {
  int id = get_free_id();
  Button b = cp5.addButton("switch" + get_free_id())
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(g)
     .setId(id)
     .setSwitch(true)
     ;
  if (on) b.setOn();
  b.getCaptionLabel().setText(label).setFont(getFont(st));
  addUIEvent(id, c, 0);
  return b;
}
