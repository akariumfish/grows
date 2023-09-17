

//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

float crandom(float d) {
  return pow(random(1.0), d) ;
}

/* crandom results :
difficulty   nb > 0.5 pour 1000
       0.04 999
       0.08 999
       0.16 986
       0.32 885
       0.64 661
       1.28 418
       2.56 236
       5.12 126
      10.24 65
      20.48 33
      40.96 16
      81.92 8
     163.84 4
     327.68 2
     655.36 1
    1310.72 0
    2621.44 0
*/

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
//for (String s : PFont.list()) println(s); // liste toute les police de text qui existe



//#######################################################################
//##                         CALLABLE CLASS                            ##
//#######################################################################

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



//#######################################################################
//##                         WATCHABLE VALUE                           ##
//#######################################################################

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



//#######################################################################
//##                         RUNNABLE EXEMPLE                          ##
//#######################################################################

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



//#######################################################################
//##                       SAVABLE VALUE TREE                          ##
//#######################################################################

class SavableValueTree {
  ArrayList<SVTEntry> entrys = new ArrayList<SVTEntry>();
  SVTNode root = new SVTNode("root");
  String name;
  SavableValueTree(String n) { name = n; }
  SavableValueTree add(SVTEntry e) {
    for (SVTEntry i : entrys) if (i.name == e.name) return null;
    entrys.add(e); root.add(e); return this;
  }
  SavableValueTree add(SVTEntry e, String nodeName) {
    for (SVTEntry i : entrys) if (i.name.equals(e.name)) return null;
    for (SVTEntry i : entrys) if (i.name.equals(nodeName) && i.isNode()) {
      entrys.add(e); ((SVTNode)i).add(e); return this;
    }
    return null;
  }
  SavableValueTree add(String s)                             { return add(new SVTNode   (s)); }
  SavableValueTree add(String s, String nodeName)            { return add(new SVTNode   (s), nodeName); }
  SavableValueTree add(String s, int v)                      { return add(new SVTInt    (s, v)); }
  SavableValueTree add(String s, int v, String nodeName)     { return add(new SVTInt    (s, v), nodeName); }
  SavableValueTree add(String s, float v)                    { return add(new SVTFloat  (s, v)); }
  SavableValueTree add(String s, float v, String nodeName)   { return add(new SVTFloat  (s, v), nodeName); }
  SavableValueTree add(String s, boolean v)                  { return add(new SVTBoolean(s, v)); }
  SavableValueTree add(String s, boolean v, String nodeName) { return add(new SVTBoolean(s, v), nodeName); }
  
  String[] to_string() {
    String[] s = new String[0];
    s = appnd(s, "Tree\t" + name);
    s = appnd(s, root.to_string());
    s = appnd(s, "EndTree\t" + name);
    return s;
  }
  void clear() { entrys.clear(); }
  void save_to_file(String filename) {
    saveStrings(filename, to_string());
  }
  void load_from_file(String filename) {
    clear();
    String[] s = loadStrings(filename);
    int i = 0;
    
  }
}

String[] appnd(String[] s1, String s2) {
  String[] s = new String[s1.length + 1];
  for (int i = 0; i < s1.length; i++) s[i] = s1[i];
  s[s1.length] = s2;
  return s;
}

String[] appnd(String[] s1, String[] s2) {
  String[] s = new String[s1.length + s2.length];
  for (int i = 0; i < s1.length; i++) s[i] = s1[i];
  for (int i = 0; i < s2.length; i++) s[s1.length + i] = s2[i];
  return s;
}

abstract class SVTEntry {
  String name;
  SVTEntry(String n) { name = n; }
  abstract String[] to_string();
  abstract boolean isNode();
}

class SVTNode extends SVTEntry {
  ArrayList<SVTEntry> entrys = new ArrayList<SVTEntry>();
  SVTNode(String n) { super(n); }
  SVTNode add(SVTEntry e) {
    for (SVTEntry i : entrys) if (i.name == e.name) return null;
    entrys.add(e); return this;
  }
  String[] to_string() {
    String[] s = new String[0];
    s = appnd(s, "Node\t" + name);
    for (SVTEntry e : entrys) s = appnd(s, e.to_string());
    s = appnd(s, "EndNode\t" + name);
    return s;
  }
  boolean isNode() { return true; }
}

abstract class SVTValue extends SVTEntry {
  SVTValue(String n) { super(n); }
  abstract String[] to_string();
  boolean isNode() { return false; }
}

class SVTFloat extends SVTValue {
  float value = 0;
  SVTFloat(String n) { super(n); }
  SVTFloat(String n, float v) { super(n); value = v; }
  String[] to_string() {
    String[] s = new String[0];
    s = (String[])append(s, "float\t" + name + "\t" + value);
    return s;
  }
}

class SVTInt extends SVTValue {
  int value = 0;
  SVTInt(String n, int v) { super(n); value = v; }
  String[] to_string() {
    String[] s = new String[0];
    s = (String[])append(s, "int\t" + name + "\t" + value);
    return s;
  }
}

class SVTBoolean extends SVTValue {
  boolean value = false;
  SVTBoolean(String n, boolean v) { super(n); value = v; }
  String[] to_string() {
    String[] s = new String[0];
    s = (String[])append(s, "boolean\t" + name + "\t" + value);
    return s;
  }
}

//            OLD OLD OLD

//StringList file = new StringList(0);

//void saving() {
//  file.append("start");
//  simcontrol_to_strings();
//  //grower_to_strings();
//  //baselist_to_strings(); //ok mais lour, illisible
//  //mworld.macroWorld_to_string();
//  String[] sl = new String[file.size()];
//  for (int i = 0 ; i < file.size() ; i++)
//    sl[i] = file.get(i);
//  //saveStrings("save.txt", sl);
//  //println(file);
//  //mworld.clear();
//  //if (mworld.build_from_string(file)) println("loading complete");
//  //else println("error");
//  file.clear();
//}

//void save_parameters() {
//  String[] sl = loadStrings("param.txt");
//  for (int i = 0 ; i < sl.length ; i++)
//    file.append(sl[i]);
//  file.append("Parameters:");
//  simcontrol_to_strings();
//  //grower_to_strings();
//  sl = new String[file.size()];
//  for (int i = 0 ; i < file.size() ; i++)
//    sl[i] = file.get(i);
//  saveStrings("param.txt", sl);
//  file.clear();
//}

//file = loadStrings("save.txt"); //String[]

//saveStrings("save.txt", file);
