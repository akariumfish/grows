



//ArrayList<Test> builderlist = new ArrayList<Test>();

//void mysetup() {
  
//}

//class Test {
//  Test() {
//  }
//  void to_string(String[] s, int id) {}
//  void from_string(String[] s, int id) {}
//  void clear() {}
//  int size() { return 0; }
//}


//void save(String file, ArrayList<Test> tl) {
//  String[] sl = new String[tl.size()];
//  int id = 0;
//  sl[0] = str(tl.size());
//  id++;
//  for (Test v : tl) {
//    v.to_string(sl, id);
//    id += v.size();
//  }
//  saveStrings(file, sl);
//}

//void load(String file, ArrayList<Test> tl) {
//  for (Test t : tl) t.clear();
//  tl.clear();
//  String[] sl = loadStrings(file);
//  int id = 1;
//  for (int i = 1; i < int(sl[0]) ; i++) {
//    Test t = new Test();
//    tl.add(t);
//    t.from_string(sl, id);
//    id += t.size();
//  }
//}




//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################

String copy(String s) { return s.substring(0, s.length()); }

String trimStringFloat(float f) {
  String s;
  if (f%1.0 == 0.0) s = nfc(int(f)); else s = str(f);
  String end = "";
  for (int i = s.length()-1; i > 0 ; i--) {
    if (s.charAt(i) == 'E') {
      end = s.substring(i, s.length());
    }
  }
  for (int i = 0; i < s.length() ; i++) {
    if (s.charAt(i) == '.' && s.length() - i > 4) {
      int m = 4;
      if (f >= 10) m -= 1;
      if (f >= 100) m -= 1;
      if (f >= 1000) m -= 2;
      s = s.substring(0, i+m);
      s = s + end;
      return s;
    }
  }
  return s;
}

float soothedcurve(float rad, float dst) {
  float val = max(0, rad*rad - dst*dst);
  return val * val * val;
}

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

float crandom(float d) { return pow(random(1.0), d); }

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
//##                        CALLABLE CLASS V2                          ##
//#######################################################################


void callChannel(Channel chan, float val) {
  for (int i = 0; i < chan.calls.size() ; i++) chan.calls.get(i).answer(chan, val); }
void callChannel(Channel chan) { callChannel(chan, 0); }
class Channel { ArrayList<Callable> calls = new ArrayList<Callable>(); }
abstract class Callable {
  Callable() {}   Callable(Channel c) {addChannel(c);}
  void addChannel(Channel c) { c.calls.add(this); }
  void removeChannel(Channel c) { c.calls.remove(this); }
  public abstract void answer(Channel channel, float value); }
  
//Channel test_chan = new Channel();
//new Callable(test_chan) { public void answer(Channel c, float v) { print("test"); }};




//#############    RUNNABLE    #############
abstract class Runnable {
  Object builder = null; Runnable() {} Runnable(Object p) { builder = p; } 
  public abstract void run(); }
  
void runEvents(ArrayList<Runnable> e) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(); }




//#######################################################################
//##                         SPECIAL VALUE                             ##
//#######################################################################


class SpecialValue {
  ArrayList<sInt> sintlist = new ArrayList<sInt>();
  ArrayList<sFlt> sfltlist = new ArrayList<sFlt>();
  ArrayList<sBoo> sboolist = new ArrayList<sBoo>();
  ArrayList<sVec> sveclist = new ArrayList<sVec>();
  ArrayList<sStr> sstrlist = new ArrayList<sStr>();
  void unFlagChange() {
    for (sInt i : sintlist) i.has_changed = false;
    for (sFlt i : sfltlist) i.has_changed = false;
    for (sBoo i : sboolist) i.has_changed = false;
    for (sVec i : sveclist) i.has_changed = false; 
    for (sStr i : sstrlist) i.has_changed = false; }
}


class sInt {
  boolean has_changed = false;
  SpecialValue save;
  int val = 0;
  int id = 0;
  String name = "int";
  sInt(SpecialValue s, int v) { save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  sInt(SpecialValue s, int v, String n) { name = n; save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  int get() { return val; }
  void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  String name = "flt";
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  sFlt(SpecialValue s, float v, String n) { name = n; save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  float get() { return val; }
  void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  String name = "boo";
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  sBoo(SpecialValue s, boolean v, String n) { name = n; save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}

class sVec {
  boolean has_changed = false;
  SpecialValue save;
  PVector val = new PVector();
  int id = 0;
  String name = "vec";
  sVec(SpecialValue s, PVector v) { save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  sVec(SpecialValue s, PVector v, String n) { name = n; save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
  PVector get() { return new PVector(val.x, val.y); }
  void set(PVector v) { if (v.x != val.x || v.y != val.y) { has_changed = true; val.x = v.x; val.y = v.y; } }
}

class sStr {
  boolean has_changed = false;
  SpecialValue save;
  String val = new String();
  int id = 0;
  String name = "str";
  sStr(SpecialValue s, String v) { save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  sStr(SpecialValue s, String v, String n) { name = n; save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
  String get() { return new String(val); }
  void set(String v) { if (!v.equals(val)) { has_changed = true; val = v; } }
}



//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


int SV_start_bloc = 3;

void saving(SpecialValue sv, String file) {
  String[] sl = new String[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + sv.sboolist.size()];
  sl[0] = str(sv.sintlist.size());
  sl[1] = str(sv.sfltlist.size());
  sl[2] = str(sv.sboolist.size());
  for (sInt i : sv.sintlist) {
    sl[SV_start_bloc + i.id] = str(i.get());
  }
  for (sFlt i : sv.sfltlist) {
    sl[SV_start_bloc + sv.sintlist.size() + i.id] = str(i.get());
  }
  for (sBoo i : sv.sboolist) {
    sl[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + i.id] = str(i.get());
  }
  saveStrings(file, sl);
}
void loading(SpecialValue s, String file) {
  
  String[] sl = loadStrings(file);
  
  int intlsize = int(sl[0]);
  int fltlsize = int(sl[1]);
  int boolsize = int(sl[2]);
  
  if (intlsize != s.sintlist.size()) return;
  if (fltlsize != s.sfltlist.size()) return;
  if (boolsize != s.sboolist.size()) return;
  if (sl.length < SV_start_bloc + intlsize + fltlsize + boolsize) return;
  
  for (sInt i : s.sintlist) {
    i.set(int(sl[SV_start_bloc + i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(float(sl[SV_start_bloc + s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(boolean(sl[SV_start_bloc + s.sintlist.size() + s.sfltlist.size() + i.id]));
  }
}





//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################


class sGraph {
  int larg =             1200;
  int[] graph  = new int[larg];
  int[] graph2 = new int[larg];
  int gc = 0;
  int max = 10;
  
  sBoo SHOW_GRAPH = new sBoo(simval, false);// affichage du graph a un bp
  
  void init() {
    //initialisation des array des graph
    for (int i = 0; i < larg; i++) { 
      graph[i] = 0; 
      graph2[i] = 0;
    }
    max = 10;
    //addChannel(c);
  }
  
  void draw() {
    if (SHOW_GRAPH.get()) { // && !cp5.getTab("default").isActive()) {
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
  
  void update(int val1, int val2) {
    //enregistrement des donner dans les array
    graph[gc] = val1;
  
    int g = val2;
    if (max < g) max = g;
    if (graph2[gc] == max) {
      max = 10;
      for (int i = 0; i < graph2.length; i++) if (i != gc && max < graph2[i]) max = graph2[i];
    }
    graph2[gc] = g;
  
    if (gc < larg-1) gc++; 
    else gc = 0;
  }
}





  



//void mysetup() {
//  Save_List sl = new Save_List();
//  Save_Bloc sb = new Save_Bloc("save data");
  
//  int a = 0, b = 1, c = 2;
//  println("start: a " + a + " b " + b + " c " + c);
  
//  //gather datas
//  sb.newData("a",str(a));
//  sb.newData("b",str(b));
//  sb.newData("c",str(c));
  
//  //change data
//  sb.setData("b",str(5));
  
//  //save
//  sb.save_to("savetest.txt");
  
//  //load
//  sb.load_from("savetest.txt");
  
//  //retrieve data
//  a = int(sb.getData("a"));
//  b = int(sb.getData("b"));
//  c = int(sb.getData("c"));
  
//  println("end: a " + a + " b " + b + " c " + c);
//}


class Save_List {
  String[] list;
  int index = 0;
  
  void put(String log, String s) { 
    list[index] = copy(s); 
    log("put " + log + " " + index + " " + s); 
    index++; }
  String get(String log) { 
    log("get " + log + " " + index + " " + list[index]); 
    index++; 
    return list[index-1]; }
  int getInt(String log) { return int(get(log)); }
  
  void init(int size) { list = new String[size]; index = 0; }
  void init(String[] l) { list = l; index = 0; }
}


class Save_Data {
  String name, data;
  Save_Data(String n, String d) { name = copy(n); data = copy(d); }
  int size() { return 2; }
  String get() { return data; }
  void set(String d) { data = copy(d); }
  void clear() { }
}


class Save_Bloc {
  String name;
  int index;
  ArrayList<Save_Data> datas = new ArrayList<Save_Data>();
  ArrayList<Save_Bloc> blocs = new ArrayList<Save_Bloc>();
  
  void clear() {
    for (Save_Data d : datas) d.clear();
    datas.clear();
    for (Save_Bloc b : blocs) b.clear();
    blocs.clear();
  }
  
  //Save_Bloc(String n, int i) { name = copy(n); index = i; }
  Save_Bloc(String n) { name = copy(n); index = 0; }
  
  void save_to(String savepath) { 
    log("bloc - save to");
    Save_List sl = new Save_List();
    sl.init(size());
    to_list(sl);
    saveStrings(savepath, sl.list);
  }
  void load_from(String savepath) { 
    log("bloc - load from");
    clear();
    String[] load = loadStrings(savepath);
    Save_List sl = new Save_List();
    sl.init(load);
    from_list(sl);
  }
  
  void to_list(Save_List sl) {
    log("Bloc - to string - start");
    sl.put("name", name);
    sl.put("total size", str(size()));
    
    sl.put("datas nb", str(datas.size()));
    int leng = 0;
    for (Save_Data sd : datas) leng += sd.size();
    sl.put("datas total size", str(leng));
    log("datas to string start");
    for (Save_Data sd : datas) { sl.put("name", sd.name); sl.put("data", sd.data); }
    log("datas to string end");
    
    sl.put("child blocs nb", str(blocs.size()));
    leng = 0;
    for (Save_Bloc sd : blocs) leng += sd.size();
    sl.put("child blocs total size", str(leng));
    log("child blocs to string start");
    for (Save_Bloc sb : blocs) sb.to_list(sl);
    log("child blocs to string end");
    
    log("Bloc - to string - end");
  }
  
  int total_size = 0;
  int datas_nb = 0;
  int data_size = 0;
  int bloc_nb = 0;
  int blocs_total_size = 0;
  
  void from_list(Save_List sl) {
    log("Bloc - from string - start");
    
    name = sl.get("name");
    total_size = sl.getInt("total size");
    
    datas_nb = sl.getInt("datas nb");
    data_size = sl.getInt("datas total size");
    log("datas from string start");
    for (int i = 0; i < datas_nb ; i++) newData(sl.get("name"), sl.get("data"));
    log("datas from string end");
    
    bloc_nb = sl.getInt("blocs nb");
    blocs_total_size = sl.getInt("child blocs total size");
    log("child blocs from string start");
    for (int i = 0; i < bloc_nb ; i++) {
      Save_Bloc sb = newBloc("");
      sb.from_list(sl);
    }
    log("child blocs from string end");
    
    log("Bloc - from string - end");
  }
  
  
  
  int size() { 
    int s = 6;
    for (Save_Data sd : datas) s += sd.size();
    for (Save_Bloc sb : blocs) s += sb.size();
    return s; 
  }
  
  Save_Data newData(String n, String d) {
    Save_Data sd = new Save_Data(n, d); datas.add(sd); return sd; }
    
  Save_Data newData(String n, int d) { return newData(n, str(d)); } 
  Save_Data newData(String n, float d) { return newData(n, str(d)); } 
  Save_Data newData(String n, boolean d) { if (d) return newData(n, "1"); else return newData(n, "0"); } 
  
  Save_Bloc newBloc(String n) {
    Save_Bloc sd = new Save_Bloc(n); blocs.add(sd); return sd; }//, blocs.size()
  Save_Bloc addBloc(Save_Bloc n) {
    blocs.add(n); return n; }
  
  void setData(String n, String d) { for (Save_Data sd : datas) if (sd.name.equals(n)) { sd.set(d); return; } }
  
  String getData(String n) { for (Save_Data sd : datas) if (sd.name.equals(n)) return sd.get(); return null; }
  int getInt(String n) { return int(getData(n)); }
  float getFloat(String n) { return float(getData(n)); }
  boolean getBoolean(String n) { if (getData(n).equals("1")) return true; else return false; }
  
  Save_Bloc getBloc(String n) { for (Save_Bloc sd : blocs) if (sd.name.equals(n)) return sd; return null; }
  
  void runIterator(Iterator<Save_Bloc> i) { 
    int count = 0;
    for (Save_Bloc b : blocs) { count++; i.run(b); i.run(b, count); }
  }
}

class Iterator<T> { public void run(T t) {} public void run(T t, int c) {} }





   
