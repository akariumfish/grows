



import java.util.Map;


//#############    RUNNABLE    #############
abstract class Runnable {
  Object builder = null; Runnable() {} Runnable(Object p) { builder = p; } 
  public void run() {}
  public void run(float v) {} }
  
void runEvents(ArrayList<Runnable> e) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(); }
void runEvents(ArrayList<Runnable> e, float v) { for (int i = e.size() - 1 ; i >= 0 ; i--) e.get(i).run(v); }

//execution ordonné en layer et timer


class EventPile {
  void addEvent(Runnable r, int l) { events.add(new Event(r, l)); }
  //execution order
  void addEventFirst(Runnable r)       { events.add(0, new Event(r, 0)); }
  void addEventMiddleFirst(Runnable r) { events.add(0, new Event(r, 1)); }
  void addEventMiddleLast(Runnable r)  { events.add(new Event(r, 1)); }
  void addEventLast(Runnable r)        { events.add(new Event(r, 2)); }
  
  class Event { Runnable r; int layer; Event(Runnable _r, int l) { r = _r; layer = l; } }
  ArrayList<Event> events = new ArrayList<Event>();
  
  EventPile() { }
  void run() {
    int layer = 0, run_count = 0;
    while (run_count < events.size()) {
      for (Event r : events) if (r.layer == layer) { r.r.run(); run_count++; } 
      layer++; } }
  void run(float v) {
    int layer = 0, run_count = 0;
    while (run_count < events.size()) {
      for (Event r : events) if (r.layer == layer) { r.r.run(v); run_count++; } 
      layer++; } }
  
}


/*
  class special value : svalue
    ref, type, val, changeevents(call one by changing frame)
    can has limits (min max, float precision, vect mag or angle ...)
    
    for bool int float string vector color(is int?)
    
    
   
*/

abstract class sValue {
  sValueBloc getBloc() { return bloc; }
  abstract String getString();
  void clear() { 
    clean();
    bloc.values.remove(ref, this); 
  }
  void clean() { 
    if (doevent) runEvents(eventsDelete);
    if (bloc.doevent) runEvents(bloc.eventsDelVal);
  }
  sValue doEvent(boolean v) { doevent = v; return this; }
  sValue addEventDelete(Runnable r) { eventsDelete.add(r); return this; }
  sValue addEventChange(Runnable r) { eventsChange.add(r); return this; }
  sValue addEventAllChange(Runnable r) { eventsAllChange.add(r); return this; }
  void doChange() { if (doevent) runEvents(eventsAllChange); has_changed = true; }
  sValueBloc bloc;
  boolean has_changed = false, doevent = true;
  String ref, type, shrt;
  //abstract Object def;
  sValue(sValueBloc b, String t, String r, String s) { 
    bloc = b; 
    while (bloc.values.get(r) != null) r = r + "'";
    type = t; ref = r; shrt = s;
    bloc.values.put(ref, this); if (bloc.doevent) runEvents(bloc.eventsAddVal); }
  void frame() { if (has_changed) { if (doevent) runEvents(eventsChange); } has_changed = false; }
  ArrayList<Runnable> eventsChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsAllChange = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelete = new ArrayList<Runnable>();
  void save_to_bloc(Save_Bloc sb) {
    vlogln("sv save " + ref);
    sb.newData("ref", ref);
    sb.newData("typ", type);
    sb.newData("shr", shrt);
  }
  void load_from_bloc(Save_Bloc svb) {
    vlogln("sv load " + ref);
    ref = svb.getData("ref");
    type = svb.getData("typ");
    shrt = svb.getData("shr");
    has_changed = true;
  }
}


class sInt extends sValue {
  boolean limited_min = false, limited_max = false; int min, max;
  sInt set_limit(int mi, int ma) { limited_min = true; limited_max = true; min = mi; max = ma; return this; }
  sInt set_min(int mi) { limited_min = true; min = mi; return this; }
  sInt set_max(int ma) { limited_max = true; max = ma; return this; }
  String getString() { return str(val); }
  void clear() { super.clear(); val = def; }
  int val = 0, def;
  sInt(sValueBloc b, int v, String n, String s) { super(b, "int", n, s); val = v; def = val; }
  int get() { return val; }
  void set(int v) { 
    if (limited_max && v > max) v = max; if (limited_min && v < min) v = min;
    if (v != val) { val = v; doChange(); } }
  void add(int v) { set(get()+v); }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getInt("val"));
  }
}

class sFlt extends sValue {
  boolean limited_min = false, limited_max = false; int min, max;
  sFlt set_limit(int mi, int ma) { limited_min = true; limited_max = true; min = mi; max = ma; return this; }
  sFlt set_min(int mi) { limited_min = true; min = mi; return this; }
  sFlt set_max(int ma) { limited_max = true; max = ma; return this; }
  String getString() { return trimStringFloat(val); }
  void clear() { super.clear(); val = def; }
  float val = 0, def;
  sFlt(sValueBloc b, float v, String n, String s) { super(b, "flt", n, s); val = v; def = val; }
  float get() { return val; }
  void set(float v) { 
    if (limited_max && v > max) v = max; if (limited_min && v < min) v = min;
    if (v != val) { val = v; doChange(); } }
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
  void clear() { super.clear(); val = def; }
  boolean val = false, def;
  sBoo(sValueBloc b, boolean v, String n, String s) { super(b, "boo", n, s); val = v; def = val; }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { val = v; doChange(); } }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getBoolean("val"));
  }
}

class sStr extends sValue {
  boolean limited; int max;
  sStr set_limit(int ma) { limited = true; max = ma; return this; }
  sStr clear_limit() { limited = false; return this; }
  String getString() { return copy(val); }
  void clear() { super.clear(); val = copy(def); }
  String val = null, def;
  sStr(sValueBloc b, String v, String n, String s) { super(b, "str", n, s); val = copy(v); def = copy(val); }
  String get() { return copy(val); }
  void set(String v) { if (!v.equals(val)) { 
    if (limited && v.length() > max) val = v.substring(0, max); else val = copy(v); doChange(); } }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("val", val);
  }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getData("val"));
  }
}

class sVec extends sValue {
  String getString() { return trimStringFloat(val.x) + "," + trimStringFloat(val.y); }
  void clear() { super.clear(); val.x = def.x; val.y = def.y; }
  private PVector val = new PVector(), def = new PVector();
  sVec(sValueBloc b, String n, String s) { super(b, "vec", n, s); }
  float x() { return val.x; }
  float y() { return val.y; }
  PVector get() { return new PVector(val.x, val.y); }
  sVec setx(float v) { if (v != val.x) { val.x = v; doChange(); } return this; }
  sVec sety(float v) { if (v != val.y) { val.y = v; doChange(); } return this; }
  sVec set(float _x, float _y) { 
    if (_x != val.x || _y != val.y) {
      val.x = _x; 
      val.y = _y; 
      doChange(); 
    } 
    return this;
  }
  sVec set(PVector v) { set(v.x, v.y); return this; }
  sVec addx(float _x) { setx(val.x+_x); return this; }
  sVec addy(float _y) { sety(val.y+_y); return this; }
  sVec add(float _x, float _y) { set(val.x+_x, val.y+_y); return this; }
  sVec add(PVector v) { add(v.x, v.y); return this; }
  sVec add(sVec v) { add(v.x(), v.y()); return this; }
  sVec mult(float m) { set(val.x*m, val.y*m); return this; }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb);
    svb.newData("x", val.x);
    svb.newData("y", val.y); }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb);
    set(svb.getFloat("x"), svb.getFloat("y")); }
}

class sRun extends sValue {
  String getString() { return ref; }
  void clear() { super.clear(); }
  private Runnable val;
  sRun(sValueBloc b, String n, String s, Runnable r) { super(b, "run", n, s);  val = r; }
  sRun run() { val.run(); doChange(); return this; }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb); }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb); }
}

class sObj extends sValue {
  String getString() { return ref; }
  void clear() { super.clear(); }
  private Object val = null;
  sObj(sValueBloc b, String n, Object r) { super(b, "obj", n, "obj");  val = r; }
  sObj set(Object r) { val = r; return this; }
  Object get() { return val; }
  void save_to_bloc(Save_Bloc svb) { super.save_to_bloc(svb); }
  void load_from_bloc(Save_Bloc svb) { super.load_from_bloc(svb); }
}

class sSvb extends sValue {
  String getString() { return ref; }
  void clear() { super.clear(); }
  private Save_Bloc val = new Save_Bloc("");
  sSvb(sValueBloc b, String n, String s, Save_Bloc r) { super(b, "svb", n, s);  val.copy_from(r); }
  void set(Save_Bloc r) { val.copy_from(r); }
  Save_Bloc get() { Save_Bloc b = new Save_Bloc(""); b.copy_from(val); return b; }
  void save_to_bloc(Save_Bloc svb) { 
    super.save_to_bloc(svb); 
    svb.newBloc("").copy_from(val);
  }
  void load_from_bloc(Save_Bloc svb) { 
    super.load_from_bloc(svb); 
    val.copy_from(svb.blocs.get(0));
  }
}


/*
  class svalue bloc : svaluebloc
    string ref
    svalbloc parent
    svalbloc map child bloc
    svalue map<string name, svalue>
*/


boolean DEBUG_SVALUE = false;
void vlog(String s) {
  if (DEBUG_SVALUE) print(s);
}
void vlogln(String s) {
  if (DEBUG_SVALUE) println(s);
}


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
  void runBlocIterator(Iterator<sValueBloc> i) { 
    for (Map.Entry me : blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      i.run(vb); } }
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
  
  /*
   bloc event
      add val
      add bloc
      delete val
      delete bloc
      delete
      
    val event
      change 
      delete
  */
  
  sValueBloc doEvent(boolean t) { doevent = t; return this; }
  sValueBloc addEventAddValue_Builder(Runnable r) { r.builder = this; eventsAddVal.add(r); return this; }
  sValueBloc addEventAddBloc_Builder(Runnable r) { r.builder = this; eventsAddBloc.add(r); return this; }
  sValueBloc addEventDelValue_Builder(Runnable r) { r.builder = this; eventsDelVal.add(r); return this; }
  sValueBloc addEventDelBloc_Builder(Runnable r) { r.builder = this; eventsDelBloc.add(r); return this; }
  sValueBloc addEventDelete_Builder(Runnable r) { r.builder = this; eventsDelete.add(r); return this; }
  ArrayList<Runnable> eventsAddVal = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsAddBloc = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelVal = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelBloc = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsDelete = new ArrayList<Runnable>();
  
  sValueBloc getBloc(String r) { return blocs.get(r); }
  sValueBloc getLastBloc() { return last_created_bloc; }
  sValue getValue(String r) { return values.get(r); }
  sValueBloc newBloc(String n) { return new sValueBloc(this, n); }
  sInt newInt(String n, String s, int v)      { return new sInt(this, v, n, s); }
  sFlt newFlt(String n, String s, float v)    { return new sFlt(this, v, n, s); }
  sBoo newBoo(String n, String s, boolean v)  { return new sBoo(this, v, n, s); }
  sInt newInt(int v, String n, String s)      { return new sInt(this, v, n, s); }
  sFlt newFlt(float v, String n, String s)    { return new sFlt(this, v, n, s); }
  sBoo newBoo(boolean v, String n, String s)  { return new sBoo(this, v, n, s); }
  sStr newStr(String n, String s, String v)   { return new sStr(this, v, n, s); }
  sVec newVec(String n, String s, PVector v)  { return new sVec(this, n, s).set(v); }
  sVec newVec(String n, String s)             { return new sVec(this, n, s); }
  sRun newRun(String n, String s, Runnable v) { return new sRun(this, n, s, v); }
  sSvb newSvb(String n, String s, Save_Bloc v) { return new sSvb(this, n, s, v); }
  sObj newObj(String n, Object v) { return new sObj(this, n, v); }
  
  DataHolder data; sValueBloc parent = null, last_created_bloc = null; 
  String ref, base_ref, type = "def", use = "";
  HashMap<String, sValue> values = new HashMap<String, sValue>();
  HashMap<String, sValueBloc> blocs = new HashMap<String, sValueBloc>();
  String adress; boolean doevent = true;
  sValueBloc() {}    //only for superclass dataholder and saving
  sValueBloc(DataHolder d, String r) { base_ref = r;
    while (d.blocs.get(r) != null) r = r + "_";
    d.blocs.put(r, this); data = d; parent = d; ref = r; adress = "data/";}
  sValueBloc(sValueBloc b, String r) { base_ref = r;
    while (b.blocs.get(r) != null) r = r + "'";
    b.blocs.put(r, this); data = b.data; parent = b; 
    ref = r; adress = b.adress + b.ref + "/"; 
    if (parent.doevent) parent.last_created_bloc = this; 
    if (parent.doevent) runEvents(parent.eventsAddBloc); }
  void frame() {
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.frame(); }
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.frame(); } }
  void clear() {
    clean();
    parent.blocs.remove(ref, this);
  }
  void clean() {
    //parent.blocs.remove(ref, this);
    for (Map.Entry b : blocs.entrySet()) { sValueBloc s = (sValueBloc)b.getValue(); s.clean(); } 
    for (Map.Entry b : values.entrySet()) { sValue s = (sValue)b.getValue(); s.clean(); } 
    blocs.clear(); values.clear();
    if (doevent) runEvents(eventsDelete); 
    if (parent.doevent) runEvents(parent.eventsDelBloc);
  }
  
  void load_from_bloc(Save_Bloc sb) {
    vlogln("svb load " + ref + "  /svb " + sb.blocs.size() + " /sv " + sb.datas.size());
    
    for (Map.Entry b : blocs.entrySet()) { 
      sValueBloc s = (sValueBloc)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
    
    for (Map.Entry b : values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
  }
  
  void load_values_from_bloc(Save_Bloc sb) {
    vlogln("svb load " + ref + "  /svb " + sb.blocs.size() + " /sv " + sb.datas.size());
    
    for (Map.Entry b : values.entrySet()) { 
      sValue s = (sValue)b.getValue(); 
      vlogln("test vb "+ s.ref);
      Save_Bloc child_blocs = sb.getBloc(s.ref);
      if (child_blocs != null) {
        vlogln("got save bloc ");
        s.load_from_bloc(child_blocs);
      }
    }
  }
  void preset_value_to_save_bloc(Save_Bloc sb) {
    dlog("valuebloc " + ref + " saving to savebloc > clearing savebloc >");
    sb.clear();
    dlogln(" saving ref typ >");
    sb.newData("__bloc_type", type);
    sb.newData("__bloc_ref", ref);
    sb.newData("__bloc_bas", base_ref);
    sb.newData("__bloc_use", use);
    
    dlogln("saving under values >");
    for (Map.Entry me : values.entrySet()) { 
      sValue s = (sValue)me.getValue(); 
      Save_Bloc sbv = sb.newBloc((String)me.getKey());
      sbv.newData("__bloc_type", "val");
      s.save_to_bloc(sbv); } 
    
    dlogln("done saving " + ref + " to savebloc");
  }
  
  String getHierarchy(boolean print_ref) {
    String struct = "<bloc_"+type;
    if (print_ref) struct += "_"+ref;
    struct += ":"+"values<";
    for (Map.Entry me : values.entrySet()) { 
      sValue v = (sValue)me.getValue(); 
      struct += "<val_"+v.type;
      if (print_ref) struct += "_"+v.ref;
      struct += ">";
    } 
    struct += ">blocs<";
    for (Map.Entry me : blocs.entrySet()) { 
      sValueBloc vb = (sValueBloc)me.getValue(); 
      struct += vb.getHierarchy(print_ref);
      struct += "-";
    } 
    struct += ">>";
    return struct;
  }
  
  
  
  int preset_to_save_bloc(Save_Bloc sb) { return preset_to_save_bloc(sb, 0); }
  int preset_to_save_bloc(Save_Bloc sb, int cnt) {
    dlog("valuebloc " + ref + " saving to savebloc > val counter: " + cnt + " > clearing savebloc >");
    sb.clear();
    dlogln(" saving ref typ >");
    sb.newData("__bloc_type", type);
    sb.newData("__bloc_ref", ref);
    sb.newData("__bloc_bas", base_ref);
    sb.newData("__bloc_use", use);
    
    dlogln("saving under blocs >");
    for (Map.Entry me : blocs.entrySet()) { 
      sValueBloc svb = (sValueBloc)me.getValue(); 
      Save_Bloc sb2 = sb.newBloc(svb.ref);
      cnt = svb.preset_to_save_bloc(sb2, cnt); 
    } 
    dlogln("saving under values >");
    for (Map.Entry me : values.entrySet()) { 
      sValue s = (sValue)me.getValue(); 
      Save_Bloc sbv = sb.newBloc((String)me.getKey());
      sbv.newData("__bloc_type", "val");
      cnt++;
      s.save_to_bloc(sbv); } 
    
    dlogln("done saving " + ref + " to savebloc");
    return cnt;
  }

  
  sValue newValue(Save_Bloc sb) {
    sValue nv = null;
    if (sb.getData("__bloc_type").equals("val")) {
      String n = sb.getData("ref");
      String s = sb.getData("shr");
      String t = sb.getData("typ");
      if (t.equals("int")) { nv = new sInt(this, 0, n, s);      nv.load_from_bloc(sb); }
      if (t.equals("flt")) { nv = new sFlt(this, 0, n, s);      nv.load_from_bloc(sb); }
      if (t.equals("boo")) { nv = new sBoo(this, false, n, s);  nv.load_from_bloc(sb); }
      if (t.equals("str")) { nv = new sStr(this, "", n, s);     nv.load_from_bloc(sb); }
      if (t.equals("vec")) { nv = new sVec(this, n, s);         nv.load_from_bloc(sb); }
      if (t.equals("run")) { nv = new sRun(this, n, s, null);   nv.load_from_bloc(sb); }
      if (t.equals("svb")) { nv = new sSvb(this, n, s, null);   nv.load_from_bloc(sb); }
      if (t.equals("obj")) { nv = new sObj(this, n, null);   nv.load_from_bloc(sb); }
    }
    return nv;
  }
  
  sValueBloc newBloc(Save_Bloc sb) {
    dlogln("newbloc");
    if (sb.getData("__bloc_type") != null && sb.getData("__bloc_ref") != null && 
        sb.getData("__bloc_bas") != null && sb.getData("__bloc_use") != null && 
        sb.getData("__bloc_type").equals("def")) {
      dlogln("got it");
      String b = sb.getData("__bloc_bas");
      String u = sb.getData("__bloc_use");
      sValueBloc vb = new sValueBloc(this, b);
      vb.use = u;
      for (Save_Bloc csb : sb.blocs) {
        String type = csb.getData("__bloc_type");
        if      (type != null && type.equals("def")) { vb.newBloc(csb); } 
        else if (type != null && type.equals("val")) { vb.newValue(csb); }
      }
      return vb;
    }
    return null;
  }
  
  sValueBloc newBloc(Save_Bloc sb, String n) {
    dlogln("newbloc");
    if (sb.getData("__bloc_type") != null && sb.getData("__bloc_ref") != null && 
        sb.getData("__bloc_bas") != null && sb.getData("__bloc_use") != null && 
        sb.getData("__bloc_type").equals("def")) {
      dlogln("got it");
      //String b = sb.getData("__bloc_bas");
      String u = sb.getData("__bloc_use");
      sValueBloc vb = new sValueBloc(this, n);
      vb.use = u;
      for (Save_Bloc csb : sb.blocs) {
        String type = csb.getData("__bloc_type");
        if      (type != null && type.equals("def")) { vb.newBloc(csb); } 
        else if (type != null && type.equals("val")) { vb.newValue(csb); }
      }
      return vb;
    }
    return null;
  }
  
}
/*
  
DataHolding
  svalue bloc map<string name, bloc>   each bloc loaded and saved independently
  runnables map<string name, run>      string-referanced runnables for saving
  
  frame()
    for bloc : map runFrameEventsIf() unFlagChanges()
*/

boolean DEBUG_DATA = false;
void dlog(String s) {
  if (DEBUG_DATA) print(s);
}
void dlogln(String s) {
  if (DEBUG_DATA) println(s);
}

class DataHolder extends sValueBloc {
  
  DataHolder() {
    super(); ref = "data"; parent = this; 
  }
  String[] types = {"flt", "int", "boo", "str", "vec", "run", "svb", "obj"};
  
  int to_save_bloc(Save_Bloc sb) { 
    dlogln("DataHolder saving to savebloc");
    int cnt = super.preset_to_save_bloc(sb); 
    dlogln("saved " + cnt + " values");
    return cnt;
  }
}


void copy_bloc(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    to.newBloc(b, from.base_ref);
  } 
}
void copy_bloc(sValueBloc from, sValueBloc to, String n) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    to.newBloc(b, n);
  } 
}
void transfer_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null &&
      from.getHierarchy(true).equals(to.getHierarchy(true))) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_to_save_bloc(b);
    to.load_from_bloc(b);
  } 
}

void copy_bloc_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_value_to_save_bloc(b);
    to.newBloc(b, "copy");
  } 
}
void transfer_bloc_values(sValueBloc from, sValueBloc to) {
  if (from != null && to != null) {
    Save_Bloc b = new Save_Bloc("");
    from.preset_value_to_save_bloc(b);
    to.load_values_from_bloc(b);
  } 
}




//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


boolean DEBUG_SAVE_FULL = false;
void slog(String s) {
  if (DEBUG_SAVE_FULL) print(s);
}
void slogln(String s) {
  if (DEBUG_SAVE_FULL) println(s);
}

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
    slog("put " + log + " " + index + " " + s); 
    index++; }
  String get(String log) { 
    slog("get " + log + " " + index + " " + list[index]); 
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
  
  
  void copy_from(Save_Bloc svb) { 
    slog("bloc - copy from");
    clear();
    name = copy(svb.name); index = svb.index; 
    Save_List sl = new Save_List();
    sl.init(svb.size());
    svb.to_list(sl);
    from_list(sl);
  }
  
  void save_to(String savepath) { 
    slog("bloc - save to");
    Save_List sl = new Save_List();
    sl.init(size());
    to_list(sl);
    saveStrings(savepath, sl.list);
  }
  void load_from(String savepath) { 
    slog("bloc - load from");
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
    slog("Bloc - to string - start");
    sl.put("name", name);
    sl.put("total size", str(size()));
    
    sl.put("datas nb", str(datas.size()));
    int leng = 0;
    for (Save_Data sd : datas) leng += sd.size();
    sl.put("datas total size", str(leng));
    slog("datas to string start");
    for (Save_Data sd : datas) { sl.put("name", sd.name); sl.put("data", sd.data); }
    slog("datas to string end");
    
    sl.put("child blocs nb", str(blocs.size()));
    leng = 0;
    for (Save_Bloc sd : blocs) leng += sd.size();
    sl.put("child blocs total size", str(leng));
    slog("child blocs to string start");
    for (Save_Bloc sb : blocs) sb.to_list(sl);
    slog("child blocs to string end");
    
    slog("Bloc - to string - end");
  }
  
  int total_size = 0;
  int datas_nb = 0;
  int data_size = 0;
  int bloc_nb = 0;
  int blocs_total_size = 0;
  
  void from_list(Save_List sl) {
    slog("Bloc - from string - start");
    
    name = sl.get("name");
    total_size = sl.getInt("total size");
    
    datas_nb = sl.getInt("datas nb");
    data_size = sl.getInt("datas total size");
    slog("datas from string start");
    for (int i = 0; i < datas_nb ; i++) newData(sl.get("name"), sl.get("data"));
    slog("datas from string end");
    
    bloc_nb = sl.getInt("blocs nb");
    blocs_total_size = sl.getInt("child blocs total size");
    slog("child blocs from string start");
    for (int i = 0; i < bloc_nb ; i++) {
      Save_Bloc sb = newBloc("");
      sb.from_list(sl);
    }
    slog("child blocs from string end");
    
    slog("Bloc - from string - end");
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





 
