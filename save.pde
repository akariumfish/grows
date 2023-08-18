// ici on gere les fichiers


StringList file = new StringList(0);

void saving() {
  file.append("start");
  simcontrol_to_strings();
  grower_to_strings();
  baselist_to_strings();
  mworld.macroWorld_to_string();
  String[] sl = new String[file.size()];
  for (int i = 0 ; i < file.size() ; i++)
    sl[i] = file.get(i);
  //saveStrings("save.txt", sl);
  //println(file);
  //mworld.clear();
  //if (mworld.build_from_string(file)) println("loading complete");
  //else println("error");
  file.clear();
}

void save_parameters() {
  String[] sl = loadStrings("param.txt");
  for (int i = 0 ; i < sl.length ; i++)
    file.append(sl[i]);
  file.append("Parameters:");
  simcontrol_to_strings();
  grower_to_strings();
  sl = new String[file.size()];
  for (int i = 0 ; i < file.size() ; i++)
    sl[i] = file.get(i);
  saveStrings("param.txt", sl);
  file.clear();
}

//file = loadStrings("save.txt"); //String[]

//saveStrings("save.txt", file);
