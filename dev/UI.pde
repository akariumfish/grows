import controlP5.*; //la lib pour les menu
import java.util.Iterator;

ControlP5 cp5; //l'objet main pour les menu

int TEXT_SIZE = 18;
int BTN_SIZE = 40;

class savableValueTree {
  ArrayList<SVTEntry> entrys = new ArrayList<SVTEntry>();
  
  void to_string() {
    for (SVTEntry e : entrys) e.to_string();
  }
  
  void save_to_file(String file) {}
  void load_from_file(String file) {}
}

abstract class SVTEntry {
  abstract void to_string();
}

class SVTNode extends SVTEntry {
  ArrayList<SVTEntry> entrys = new ArrayList<SVTEntry>();
  void to_string() {
    for (SVTEntry e : entrys) e.to_string();
  }
}

abstract class SVTValue extends SVTEntry {
  abstract void to_string();
}

ArrayList<Callable> callables = new ArrayList<Callable>();
void callChannel(Channel chan, float val) {
  for (Callable c : callables) for (Channel i : c.chan) 
    if (i == chan) c.answer(chan, val); }
void callChannel(Channel chan) { callChannel(chan, 0); }
void callChannel(Channel[] chan, float val) {
  for (Channel c : chan) callChannel(c, val); }
class Channel {}
abstract class Callable {
  Channel[] chan = new Channel[0];
  Callable() { callables.add(this); }
  Channel[] getChannel() { return chan; }
  void setChannel(Channel[] c) { chan = c; }
  void addChannel(Channel c) { chan = (Channel[])append(chan, c); }
  void clearChannel() { chan = new Channel[0]; }
  abstract void answer(Channel channel, float value); }


abstract class WatchableValue {
  ArrayList<Channel> watchers = new ArrayList<Channel>();
  void addWatcher(Channel c) { watchers.add(c); }
}

class WatchableFloat extends WatchableValue {
  private float value = 0;
  WatchableFloat() {}
  WatchableFloat(float v) { value = v; }
  void set( float v) {
    if (v != value) for (Channel c : watchers) callChannel(c, v);
    value = v;
  }
  float get() { return value; }
}

class WatchableBool extends WatchableValue {
  private boolean value = false;
  WatchableBool() {}
  WatchableBool(boolean v) { value = v; }
  void set( boolean v) {
    if (v != value) for (Channel c : watchers) if (v) callChannel(c, 1); else callChannel(c, 0);
    value = v;
  }
  boolean get() { return value; }
}

ArrayList<Runnable> runs = new ArrayList<Runnable>();
void new_runnable() {
  runs.add(new Runnable() { public void run() {
    //run
  }});
}
void post() {
  Iterator<Runnable> it = runs.iterator();
  while (it.hasNext ()) {
    it.next().run();
    it.remove();
  }
}

// auto indexing
int used_index = 0;
int get_free_id() { used_index++; return used_index - 1; }

// gestion des polices de caractére
ArrayList<myFont> existingFont = new ArrayList<myFont>();
class myFont { PFont f; int st; }
PFont getFont(int st) {
  for (myFont f : existingFont) if (f.st == st) return f.f;
  myFont f = new myFont();
  f.f = createFont("Arial",st); f.st = st;
  return f.f; }

void init_UI() {
  cp5 = new ControlP5(this);
  cp5.addTab("Menu")
     .getCaptionLabel().setFont(getFont(16))
     ;
  cp5.getTab("default")
    // .activateEvent(true)
     .setLabel("Main")
     .getCaptionLabel().setFont(getFont(16))
     ;
  cp5.getTab("Menu").bringToFront();
}

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
  float v = 0;
  if (on) v = 1;
  addUIEvent(id, c, v);
  return b;
}

//panels
float mx = 0; float my = 0; //pour bouger les fenetres
Group addPanel(float x, float y, int sx, int sy) {
  Group g = cp5.addGroup("group" + get_free_id())
             .setPosition(x, y)
             .setSize(sx, 10)
             .setBackgroundHeight(sy)
             .setBackgroundColor(color(60, 200))
             .disableCollapse()
             .moveTo("Menu")
             ;
  g.getCaptionLabel().setText("");
  return g;
}
void update_panel(Group g) {
  //moving control panel
  if (g.isMouseOver() && mouseClick[0]) {
    mx = g.getPosition()[0] - mouseX;
    my = g.getPosition()[1] - mouseY;
    GRAB = false;//deactive le deplacement camera
  }
  if (g.isMouseOver() && mouseUClick[0]) {
    GRAB = true;
  }
  if (g.isMouseOver() && mouseButtons[0]) {
    g.setPosition(mouseX + mx,mouseY + my);
  }
}
