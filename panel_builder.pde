//easy building


Textlabel addText(Group g, String name, String label, float x, float y, int st) {
  return cp5.addTextlabel(name)
     .setText(label)
     .setPosition(x, y)
     .setColorValue(0xffffffff)
     .setFont(createFont("Arial",st))
     .setGroup(g)
     ;
}

Textlabel addText(Group g, String name, String label, float x, float y) {
  return addText(g, name, label, x, y, TEXT_SIZE);
}

Button addButton(Group g, String name, String label, float x, float y, int sx, int sy, int id, float st) {
  Button b = cp5.addButton(name)
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(g)
     .setId(id)
     ;
  b.getCaptionLabel().setText(label).setFont(createFont("Arial",st));
  return b;
}

// modify by a factor
void build_line_factor(Group g, String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(g, name + "-x2", "x2", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+1, TEXT_SIZE);
  addButton(g, name + "-x1", "x1.2", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+2, TEXT_SIZE);
  addButton(g, name + "-/1", "/1.2", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+3, TEXT_SIZE);
  addButton(g, name + "-/2", "/2", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+4, TEXT_SIZE);
  addText(g, name + "-label", name + ": " + val, x + 140, y + 10).setId(id);
}

// modify by increment
void build_line_incr(Group g, String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(g, name + "-min10", "-10", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+5, TEXT_SIZE);
  addButton(g, name + "-min1", "-1", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+6, TEXT_SIZE);
  addButton(g, name + "-maj1", "+1", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+7, TEXT_SIZE);
  addButton(g, name + "-maj10", "+10", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+8, TEXT_SIZE);
  addText(g, name + "-label", name + ": " + val, x + 140, y + 15).setId(id);
}
