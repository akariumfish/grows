// ici on gere les fichiers

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
