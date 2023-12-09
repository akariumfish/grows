



import java.util.Map;


//#############    RUNNABLE    #############
abstract class Runnable {
  Object builder = null; Runnable() {} Runnable(Object p) { builder = p; } 
  public abstract void run(); }
  
void runEvents(ArrayList<Runnable> e) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(); }

//HashMap<String, Runnable> custom_runnable_map = new HashMap<String, Runnable>();
//void addCustomRunnable(String k, Runnable r) { custom_runnable_map.put(k, r); }



/*
  class special value : svalue
    ref, type, val, changeevents(call one by changing frame)
    can has limits (min max, float precision, vect mag or angle ...)
    
    for bool int float string vector color(is int?)
*/
class sValue {
  sValueBloc bloc;
  boolean has_changed = false;
  String ref, type;
  sValue(sValueBloc b, String t, String r) { 
    bloc = b; 
    while (bloc.values.get(r) != null) r = r + "'";
    type = t; ref = r; 
    bloc.values.put(ref, this); }
  void frame() { if (has_changed) runEvents(eventsChange); has_changed = false; }
  sValue addEventChange(Runnable r) { eventsChange.add(r); return this; }
  ArrayList<Runnable> eventsChange = new ArrayList<Runnable>();
}


class sInt extends sValue {
  int val = 0;
  sInt(sValueBloc b, int v, String n) { super(b, "int", n); val = v; }
  int get() { return val; }
  void set(int v) { if (v != val) has_changed = true; val = v; }
  void add(int v) { if (v != 0) has_changed = true; val += v; }
}

class sFlt extends sValue {
  float val = 0;
  sFlt(sValueBloc b, float v, String n) { super(b, "flt", n); val = v; }
  float get() { return val; }
  void set(float v) { if (v != val) has_changed = true; val = v; }
  void add(float v) { if (v != 0) has_changed = true; val += v; }
}

class sBoo extends sValue {
  boolean val = false;
  sBoo(sValueBloc b, boolean v, String n) { super(b, "boo", n); val = v; }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}

class sStr extends sValue {
  String val = null;
  sStr(sValueBloc b, String v, String n) { super(b, "str", n); val = copy(v); }
  String get() { return copy(val); }
  void set(String v) { if (!v.equals(val)) { has_changed = true; val = copy(v); } }
}

class sVec extends sValue {
  private PVector val = new PVector();
  sVec(sValueBloc b, String n) { super(b, "vec", n); }
  float x() { return val.x; }
  float y() { return val.y; }
  sVec x(float v) { if (v != val.x) { has_changed = true; val.x = v; } return this; }
  sVec y(float v) { if (v != val.y) { has_changed = true; val.y = v; } return this; }
  sVec set(PVector v) { x(v.x); y(v.y); return this; }
  sVec set(float _x, float _y) { x(_x); y(_y); return this; }
  sVec add(float _x, float _y) { x(_x+val.x); y(_y+val.y); return this; }
  sVec mult(float m) { x(val.x*m); y(val.y*m); return this; }
}

/*
  class svalue bloc : svaluebloc
    string ref
    svalbloc parent
    svalbloc map child bloc
    svalue map<string name, svalue>
*/
class sValueBloc {
  DataHolder data;
  sValueBloc parent = null;
  String ref;
  HashMap<String, sValue> values = new HashMap<String, sValue>();
  HashMap<String, sValueBloc> blocs = new HashMap<String, sValueBloc>();
  sValueBloc(DataHolder d, String r) { 
    data = d; 
    while (data.blocs.get(r) != null) r = r + "'";
    ref = r; 
    data.blocs.put(ref, this);
  }
  sValueBloc(sValueBloc b, String r) { 
    data = b.data; parent = b;
    while (b.blocs.get(r) != null) r = r + "'";
    ref = r; 
    b.blocs.put(ref, this);
  }
  void frame() {
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.frame(); }
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.frame(); }
  }
}
/*
  
DataHolding
  svalue bloc map<string name, bloc>   each bloc loaded and saved independently
  runnables map<string name, run>      string-referanced runnables for saving
  
  frame()
    for bloc : map runFrameEventsIf() unFlagChanges()
*/

class DataHolder {
  HashMap<String, sValueBloc> blocs = new HashMap<String, sValueBloc>();
  sValueBloc newBloc(String r) { return new sValueBloc(this, r); }
  HashMap<String, Runnable> refered_runnable_map = new HashMap<String, Runnable>();
  void addReferedRunnable(String k, Runnable r) { refered_runnable_map.put(k, r); }
  void frame() {
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.frame(); }
  }
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





 
