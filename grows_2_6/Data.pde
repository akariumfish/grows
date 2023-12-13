



import java.util.Map;


//#############    RUNNABLE    #############
abstract class Runnable {
  Object builder = null; Runnable() {} Runnable(Object p) { builder = p; } 
  public void run() {}
  public void run(float v) {} }
  
void runEvents(ArrayList<Runnable> e) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(); }
void runEvents(ArrayList<Runnable> e, float v) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(v); }

//HashMap<String, Runnable> custom_runnable_map = new HashMap<String, Runnable>();
//void addCustomRunnable(String k, Runnable r) { custom_runnable_map.put(k, r); }



/*
  class special value : svalue
    ref, type, val, changeevents(call one by changing frame)
    can has limits (min max, float precision, vect mag or angle ...)
    
    for bool int float string vector color(is int?)
*/
abstract class sValue {
  abstract String getString();
  abstract void clear();
  sValue addEventChange(Runnable r) { eventsChange.add(r); return this; }
  sValueBloc bloc;
  boolean has_changed = false;
  String ref, type;
  //abstract Object def;
  sValue(sValueBloc b, String t, String r) { 
    bloc = b; 
    while (bloc.values.get(r) != null) r = r + "'";
    type = t; ref = r; 
    bloc.values.put(ref, this); }
  void frame() { if (has_changed) runEvents(eventsChange); has_changed = false; }
  ArrayList<Runnable> eventsChange = new ArrayList<Runnable>();
  void save_to_bloc(Save_Bloc svb) {
    svb.newData("ref", ref);
    svb.newData("typ", type);
  }
  void load_from_bloc(Save_Bloc svb) {
    logln("sv load " + ref);
    ref = svb.getData("ref");
    type = svb.getData("typ");
    has_changed = true;
  }
}


class sInt extends sValue {
  boolean limited = false; int min, max;
  sInt set_limit(int mi, int ma) { limited = true; min = mi; max = ma; return this; }
  String getString() { return str(val); }
  void clear() { val = def; }
  int val = 0, def;
  sInt(sValueBloc b, int v, String n) { super(b, "int", n); val = v; def = val; }
  int get() { return val; }
  void set(int v) { 
    if (limited) { if (v > max) v = max; if (v < min) v = min; }
    if (v != val) has_changed = true; val = v; }
  void add(int v) { set(get()+v); }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getInt("val"));
  }
}

class sFlt extends sValue {
  boolean limited = false; float min, max;
  sFlt set_limit(float mi, float ma) { limited = true; min = mi; max = ma; return this; }
  String getString() { return trimStringFloat(val); }
  void clear() { val = def; }
  float val = 0, def;
  sFlt(sValueBloc b, float v, String n) { super(b, "flt", n); val = v; def = val; }
  float get() { return val; }
  void set(float v) { 
    if (limited) { if (v > max) v = max; if (v < min) v = min; }
    if (v != val) has_changed = true; val = v; }
  void add(float v) { set(get()+v); }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getFloat("val"));
  }
}

class sBoo extends sValue {
  String getString() { return str(val); }
  void clear() { val = def; }
  boolean val = false, def;
  sBoo(sValueBloc b, boolean v, String n) { super(b, "boo", n); val = v; def = val; }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getBoolean("val"));
  }
}

class sStr extends sValue {
  String getString() { return copy(val); }
  void clear() { val = copy(def); }
  String val = null, def;
  sStr(sValueBloc b, String v, String n) { super(b, "str", n); val = copy(v); def = copy(val); }
  String get() { return copy(val); }
  void set(String v) { if (!v.equals(val)) { has_changed = true; val = copy(v); } }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getData("val"));
  }
}

class sVec extends sValue {
  String getString() { return trimStringFloat(val.x) + "," + trimStringFloat(val.y); }
  void clear() { val.x = def.x; val.y = def.y; }
  private PVector val = new PVector(), def = new PVector();
  sVec(sValueBloc b, String n) { super(b, "vec", n); }
  float x() { return val.x; }
  float y() { return val.y; }
  sVec x(float v) { if (v != val.x) { has_changed = true; val.x = v; } return this; }
  sVec y(float v) { if (v != val.y) { has_changed = true; val.y = v; } return this; }
  sVec set(PVector v) { x(v.x); y(v.y); return this; }
  sVec set(float _x, float _y) { x(_x); y(_y); return this; }
  sVec add(float _x, float _y) { x(_x+val.x); y(_y+val.y); return this; }
  sVec mult(float m) { x(val.x*m); y(val.y*m); return this; }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("x", val.x);
    svb.newData("y", val.y);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getFloat("x"), svb.getFloat("y"));
  }
}

/*
  class svalue bloc : svaluebloc
    string ref
    svalbloc parent
    svalbloc map child bloc
    svalue map<string name, svalue>
*/


class Iterator<T> { 
  Object builder;
  Iterator() {}
  Iterator(Object _b) { builder = _b; }
  public void run(T t) {} 
  public void run(T t, int c) {} 
}


class sValueBloc {
  void runIterator(Iterator<sValue> i) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      i.run(v);
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      vb.runIterator(i);
    }
  }
  int runIterator_Counted(Iterator<sValue> i) { return runIterator_Counted(i, 0); }
  int runIterator_Counted(Iterator<sValue> i, int c) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      i.run(v, c); c++;
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.runIterator_Counted(i, c);
    }
    return c;
  }
  void runIterator_Filter(String t, Iterator<sValue> i) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) i.run(v);
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      vb.runIterator_Filter(t, i);
    }
  }
  int runIterator_Filter_Counted(String t, Iterator<sValue> i) { return runIterator_Filter_Counted(t, i, 0); }
  int runIterator_Filter_Counted(String t, Iterator<sValue> i, int c) { 
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) { i.run(v, c); c++; }
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.runIterator_Filter_Counted(t, i, c);
    }
    return c;
  }
  sValue searchValue(String t) { 
    sValue e = values.get(t);
    if (e != null) return e;
    for (Map.Entry me : blocs.entrySet()) {
      e = ( (sValueBloc)(me.getValue()) ).searchValue(t);
      if (e != null) return e; }
    return null;
  }
  int getCountOfType(String t) { return getCountOfType(t, 0); }
  int getCountOfType(String t, int c) {
    for (Map.Entry mev : values.entrySet()) {
      sValue v = ((sValue)mev.getValue());
      if (v.type.equals(t)) c++;
    }
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      c = vb.getCountOfType(t, c);
    }
    return c;
  }
  sValueBloc getBloc(String r) { return blocs.get(r); }
  sValue getValue(String r) { return values.get(r); }
  
  DataHolder data; sValueBloc parent = null; String ref;
  HashMap<String, sValue> values = new HashMap<String, sValue>();
  HashMap<String, sValueBloc> blocs = new HashMap<String, sValueBloc>();
  sValueBloc() {}    //only for superclass dataholder
  sValueBloc(DataHolder d, String r) { 
    while (d.blocs.get(r) != null) r = r + "'";
    d.blocs.put(r, this); data = d; ref = r; }
  sValueBloc(sValueBloc b, String r) { 
    while (b.blocs.get(r) != null) r = r + "'";
    b.blocs.put(r, this); data = b.data; parent = b; ref = r; }
  void frame() {
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.frame(); }
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.frame(); } }
  void clear() {
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.clear(); } 
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.clear(); } 
  }
  void save_to_bloc(Save_Bloc sb) {
    Save_Bloc sb2 = sb.newBloc(ref);
    for (Map.Entry me : blocs.entrySet()) { sValueBloc svb = (sValueBloc)me.getValue(); svb.save_to_bloc(sb2); } 
    for (Map.Entry me : values.entrySet()) { 
      sValue s = (sValue)me.getValue(); 
      Save_Bloc sbv = sb2.newBloc(s.ref);
      s.save_to_bloc(sbv); } 
  }
  void load_from_bloc(Save_Bloc svb) {
    logln("svb load " + ref);
    
    for (Map.Entry b : blocs.entrySet()) { 
      sValueBloc s = (sValueBloc)b.getValue(); 
      logln("test vb "+ s.ref);
      Save_Bloc child_blocs = svb.getBloc(s.ref);
      if (child_blocs != null) {
        logln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
    
    for (Map.Entry b : values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      logln("test vb "+ s.ref);
      Save_Bloc child_blocs = svb.getBloc(s.ref);
      if (child_blocs != null) {
        logln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
    
    //for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.load_from_bloc(svb); } 
    //for (Map.Entry b : values.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.load_from_bloc(svb); } 
  }
}
/*
  
DataHolding
  svalue bloc map<string name, bloc>   each bloc loaded and saved independently
  runnables map<string name, run>      string-referanced runnables for saving
  
  frame()
    for bloc : map runFrameEventsIf() unFlagChanges()
*/

class DataHolder extends sValueBloc {
  void addReferedRunnable(String k, Runnable r) { refered_runnable_map.put(k, r); }
  Runnable getReferedRunnable(String t) { return refered_runnable_map.get(t); }
  
  HashMap<String, Runnable> refered_runnable_map = new HashMap<String, Runnable>();
  
  void frame() { super.frame(); }
  void clear() { super.clear(); }
}







//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################

/*
  class sdata
    string ref data
  class sdatabloc
    string ref
    list<sdata>
    list<sbloc>
  save and load sdatabloc from file methods
  svaluebloc To sdatabloc  /  svaluebloc From sdatabloc()
*/


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
  
  void runIterator(Iterator<Save_Bloc> i) { 
    int count = 0;
    for (Save_Bloc b : blocs) { count++; i.run(b); i.run(b, count); }
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
  
  void clear() {
    for (Save_Data d : datas) d.clear();
    datas.clear();
    for (Save_Bloc b : blocs) b.clear();
    blocs.clear();
  }
  
  
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
  
  //Save_Bloc(String n, int i) { name = copy(n); index = i; }
  Save_Bloc(String n) { name = copy(n); index = 0; }
  
  String name;
  int index;
  ArrayList<Save_Data> datas = new ArrayList<Save_Data>();
  ArrayList<Save_Bloc> blocs = new ArrayList<Save_Bloc>();
  
  
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

/*
 //* Listing files in directories and subdirectories
 //* by Daniel Shiffman.  
 //* 
 //* This example has three functions:<br />
 //* 1) List the names of files in a directory<br />
 //* 2) List the names along with metadata (size, lastModified)<br /> 
 //*    of files in a directory<br />
 //* 3) List the names along with metadata (size, lastModified)<br />
 //*    of files in a directory and all subdirectories (using recursion) 


import java.util.Date;

void setup() {

  // Using just the path of this sketch to demonstrate,
  // but you can list any directory you like.
  String path = sketchPath();

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  printArray(filenames);

  println("\nListing info about all files in a directory: ");
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    println("Name: " + f.getName());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  println("\nListing info about all files in a directory and all subdirectories: ");
  ArrayList<File> allFiles = listFilesRecursive(path);

  for (File f : allFiles) {
    println("Name: " + f.getName());
    println("Full path: " + f.getAbsolutePath());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  noLoop();
}

// Nothing is drawn in this program and the draw() doesn't loop because
// of the noLoop() in setup()
void draw() {
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

// Function to get a list of all files in a directory and all subdirectories
ArrayList<File> listFilesRecursive(String dir) {
  ArrayList<File> fileList = new ArrayList<File>(); 
  recurseDir(fileList, dir);
  return fileList;
}

// Recursive function to traverse subdirectories
void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    // If you want to include directories in the list
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      // Call this function on all files in this directory
      recurseDir(a, subfiles[i].getAbsolutePath());
    }
  } else {
    a.add(file);
  }
}
*/





 
