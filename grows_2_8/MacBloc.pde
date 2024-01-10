

//class MTemplate extends Macro_Bloc { 
//  MTemplate(Macro_Sheet _sheet, sValueBloc _bloc) { 
//    super(_sheet, "tmpl", "tmpl", _bloc); 
//  }
//  MTemplate clear() {
//    super.clear(); return this; }
//}

class MCursor extends Macro_Bloc { 
  sStr val_txt; 
  nLinkedWidget txt_field; nLinkedWidget show_widg;
  //Macro_Connexion in_p, in_d, out_p, out_d;
  nCursor cursor;
  MCursor(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "cursor", "cursor", _bloc); 
    cursor = new nCursor(gui, sheet, "cursor", "curs");
    if (sheet.sheet_viewer != null) sheet.sheet_viewer.update();
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "cursor");
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      cursor.clear(); 
      cursor = new nCursor(gui, sheet, val_txt.get(), "curs");
      cursor.show.set(show_widg.isOn());
      show_widg.setLinkedValue(cursor.show);
    } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    //out = addOutput(0, "load");
    show_widg = addEmptyS(0).addLinkedModel("MC_Element_SButton").setLinkedValue(cursor.show);
  }
  MCursor clear() {
    cursor.clear();
    if (sheet.sheet_viewer != null) sheet.sheet_viewer.update();
    super.clear(); return this; }
}


class MPreset extends Macro_Bloc { 
  sStr val_txt; 
  nLinkedWidget txt_field; nCtrlWidget load_widg;
  Macro_Connexion in;
  MPreset(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "prst", "prst", _bloc); 
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    in = addInput(0, "load").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) { load_prst(); }
    } });
    load_widg = addEmptyS(1).addCtrlModel("MC_Element_SButton")
      .setRunnable(new Runnable() { public void run() { load_prst(); }});
  }
  void load_prst() {
    for (Map.Entry me : mmain().saved_preset.blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      if (vb.ref.equals(val_txt.get())) {
        transfer_bloc_values(vb, sheet.value_bloc);
        break;
      }
    }
  }
  MPreset clear() {
    super.clear(); return this; }
}


//class MPanCstm extends MPanTool { 
  
//  void build_front_panel(nWindowPanel front_panel) {
//    if (front_panel != null) {
      
//    }
//  }
  
//  sStr val_txt;
//  nLinkedWidget txt_field; 
  
//  MPanCstm(Macro_Sheet _sheet, sValueBloc _bloc) { 
//    super(_sheet, "pancstm", "pancstm", _bloc); 
    
//    addEmptyS(1);
//    val_txt = newStr("txt", "txt", "");
//    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
//    txt_field.setInfo("text");
    
//  }
//  MPanCstm clear() {
//    super.clear(); return this; }
//}


class MPanGrph extends MPanTool { 
  
  nWatcherWidget pan_label;
  nWidget graph;
  void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 10.25);
      
      graph = dr.addModel("Field");
      graph.setPosition(ref_size * 2 / 16, ref_size * 2 / 16)
        .setSize(ref_size * 10, ref_size * 10);
        
      larg = int(graph.getLocalSX());
      graph_data = new float[larg];
      for (int i = 0; i < larg; i++) { 
        graph_data[i] = 0; 
      }
      gc = 0;
      max = 10;
      
      graph.setDrawable(new Drawable(front_panel.gui.drawing_pile, 0) { public void drawing() {
        fill(graph.look.standbyColor);
        noStroke();
        rect(graph.getX(), graph.getY(), graph.getSX(), graph.getSY());
        strokeWeight(ref_size / 40);
        stroke(255);
        for (int i = 1; i < larg; i++) if (i != gc) {
          //stroke(255);
          line( graph.getX() + (i-1), 
                graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[(i-1)] * (graph.getSY()-ref_size*5/4) / max), 
                graph.getX() + i, 
                graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[i] * (graph.getSY()-ref_size*5/4) / max) );
        }
        stroke(255, 0, 0);
        strokeWeight(ref_size / 6);
        if (gc != 0) {
          point(graph.getX() + gc-1, graph.getY() + graph.getSY() - ref_size / 4 - (graph_data[gc-1] * (graph.getSY()-ref_size*5/4) / max) );
        }
      } });
      
      pan_label = dr.addWatcherModel("Label-S3").setLinkedValue(val_label);
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; graph = null; } } );
    }
  }
  Macro_Connexion in_val, in_tick;
  
  sStr val_txt, val_label;
  nLinkedWidget txt_field; float flt;
  
  int larg = 0, gc = 0;
  float[] graph_data;
  float max = 10;
  
  MPanGrph(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pangrph", "pangrph", _bloc); 
    
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + trimStringFloat(flt)); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    
    in_val = addInput(0, "val").addEventReceive(new Runnable(this) { public void run() { 
      if (in_val.getLastPacket() != null && in_val.getLastPacket().isFloat()) {
        flt = in_val.getLastPacket().asFloat();
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
      }
      if (in_val.getLastPacket() != null && in_val.getLastPacket().isInt()) {
        flt = in_val.getLastPacket().asInt();
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
      }
    } });
    in_tick = addInput(0, "tick").addEventReceive(new Runnable(this) { public void run() { 
      if (in_tick.getLastPacket() != null && in_tick.getLastPacket().isBang()) {
        //enregistrement des donner dans les array
        float g = flt;
        if (max < g) max = g;
        if (graph_data[gc] == max) {
          max = 10;
          for (int i = 0; i < graph_data.length; i++) if (i != gc && max < graph_data[i]) max = graph_data[i];
        }
        graph_data[gc] = g;
      
        if (gc < larg-1) gc++; 
        else gc = 0;
      }
    } });
  }
  MPanGrph clear() {
    super.clear(); return this; }
}


class MPanSld extends MPanTool { 
  
  nWatcherWidget pan_label;
  nSlide slide;
  void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1);
      pan_label = dr.addWatcherModel("Label-S3").setLinkedValue(val_label);
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      
      slide = (nSlide)(dr.addWidget(new nSlide(front_panel.gui, ref_size * 6, ref_size * 0.75)));
      slide.setPosition(4*ref_size, ref_size * 2 / 16);
      
      slide.addEventSlide(new Runnable(this) { public void run(float c) { 
        flt = val_min.get() + c * (val_max.get() - val_min.get()); 
        
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
        out.send(newPacketFloat(flt));
      } } );
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; slide = null; } } );
    }
  }
  Macro_Connexion in, out;
  
  sStr val_txt, val_label;
  sFlt val_min, val_max;
  nLinkedWidget txt_field, min_field, max_field; 
  float flt = 0;
  
  MPanSld(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pansld", "pansld", _bloc); 
    
    addEmptyS(1);
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_min = newFlt("min", "min", 0);
    val_max = newFlt("max", "max", 1);
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + flt); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    min_field = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_min);
    min_field.setInfo("min");
    max_field = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_max);
    max_field.setInfo("max");
    
    in = addInput(0, "in");
    out = addOutput(1, "out");
    
    in.addEventReceive(new Runnable(this) { public void run() { 
      if (slide != null && !slide.curs.isGrabbed() && 
          in.getLastPacket() != null && in.getLastPacket().isFloat() && 
          in.getLastPacket().asFloat() != flt) {
        flt = in.getLastPacket().asFloat();
        if (flt < val_min.get()) flt = val_min.get();
        if (flt > val_max.get()) flt = val_max.get();
        
        slide.setValue((flt - val_min.get()) / (val_max.get() - val_min.get()));
        
        val_label.set(val_txt.get() + " " + trimStringFloat(flt) ); 
        out.send(newPacketFloat(flt));
      }
    } });
  }
  MPanSld clear() {
    super.clear(); return this; }
}

class MPanBin extends MPanTool {  
  nWidget pan_button; 
  nWatcherWidget pan_label;
  
  Runnable wtch_in_run, trig_widg_run, trig_in_run, swch_widg_run, swch_in_run;
  
  void build_front_panel(nWindowPanel front_panel) {
    if (front_panel != null) {
      
      nDrawer dr = front_panel.getShelf()
        .addSeparator(0.125)
        .addDrawer(10.25, 1);
      pan_label = dr.addWatcherModel("Label-S3");
      pan_label.setTextAlignment(LEFT, CENTER).getShelf()
        .addSeparator()
        ;
      pan_button = dr.addModel("Button-S2-P3");
      
      if (val_butt_txt != null) pan_button.setText(val_butt_txt.get());
      
      param();
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        pan_label = null; pan_button = null; } } );
    }
  }
  
  nLinkedWidget widgWTCH, widgSWCH, widgTRIG; 
  sBoo valWTCH, valSWCH, valTRIG;
  Macro_Connexion in, out;
  
  sStr val_txt, val_butt_txt, val_label; 
  String msg = "";
  nLinkedWidget txt_field, butt_txt_field; 
  
  MPanBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "panbin", "panbin", _bloc); 
    
    valWTCH = newBoo("valWTCH", "valWTCH", false);
    valSWCH = newBoo("valSWCH", "valSWCH", false);
    valTRIG = newBoo("valTRIG", "valTRIG", false);
    
    val_txt = newStr("txt", "txt", "");
    val_label = newStr("lbl", "lbl", "");
    val_butt_txt = newStr("b_txt", "b_txt", "");
    
    valWTCH.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valSWCH.addEventChange(new Runnable(this) { public void run() { param(); } } );
    valTRIG.addEventChange(new Runnable(this) { public void run() { param(); } } );
    
    trig_widg_run = new Runnable(this) { public void run() { out.send(newPacketBang()); } };
    
    trig_in_run = new Runnable(this) { public void run() { ; } };
    
    swch_widg_run = new Runnable(this) { public void run() { 
      if (pan_button != null) out.send(newPacketBool(pan_button.isOn())); } };
    
    swch_in_run = new Runnable(this) { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool() && pan_button != null) { 
        pan_button.setSwitchState(in.getLastPacket().asBool()); }
    } };
    
    wtch_in_run = new Runnable(this) { public void run() { 
      if (in.getLastPacket() != null) { 
        msg = in.getLastPacket().getText();
        val_label.set(val_txt.get() + " " + msg); } } };
    
    addEmptyS(1);
    val_txt.addEventChange(new Runnable(this) { public void run() { 
      val_label.set(val_txt.get() + " " + msg); } });
    txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_txt);
    txt_field.setInfo("description");
    
    addEmptyS(1);
    val_butt_txt.addEventChange(new Runnable(this) { public void run() { 
      if (pan_button != null) pan_button.setText(val_butt_txt.get()); } });
    butt_txt_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_butt_txt);
    butt_txt_field.setInfo("button text");
    
    addEmptyS(1);
    Macro_Element e2 = addEmptyL(0);
    widgWTCH = e2.addLinkedModel("MC_Element_Button_Selector_1", "W").setLinkedValue(valWTCH);
    widgSWCH = e2.addLinkedModel("MC_Element_Button_Selector_2", "S").setLinkedValue(valSWCH);
    widgTRIG = e2.addLinkedModel("MC_Element_Button_Selector_3", "T").setLinkedValue(valTRIG);
    //widgWTCH.addExclude(widgSWCH).addExclude(widgTRIG);
    widgSWCH.addExclude(widgTRIG);
    widgTRIG.addExclude(widgSWCH);
    
    in = addInput(0, "in");
    
    out = addOutput(1, "out");
    
    param();
    
  }
  void param() {
    if (valWTCH.get()) {
      if (pan_label != null) pan_label.setLinkedValue(val_label);
      val_label.set(val_txt.get());
      in.addEventReceive(wtch_in_run);
    } else {
      if (pan_label != null) pan_label.setLinkedValue(val_txt);
      in.removeEventReceive(wtch_in_run);
    }
    if (valSWCH.get()) {
      if (pan_button != null) pan_button
        .setSwitch()
        .clearEventTrigger()
        .addEventSwitchOn(swch_widg_run)
        .addEventSwitchOff(swch_widg_run)
        .show();
      in.addEventReceive(swch_in_run);
      in.removeEventReceive(trig_in_run);
      
    } else if (valTRIG.get()) {
      if (pan_button != null) pan_button
        .setTrigger()
        .clearEventSwitchOn()
        .clearEventSwitchOff()
        .addEventTrigger(trig_widg_run)
        .show();
      //in.setFilterBang().addEventReceive(trig_in_run);
      in.removeEventReceive(swch_in_run);
    } else {
      if (pan_button != null) pan_button.hide();
    }
  }
  MPanBin clear() {
    super.clear(); return this; }
}
abstract class MPanTool extends Macro_Bloc {  
  abstract void build_front_panel(nWindowPanel front_panel);
  
  MPanel mpanel;
  
  sStr val_pan_title; 
  nLinkedWidget title_field; 
  
  MPanTool(Macro_Sheet _sheet, String r, String s, sValueBloc _bloc) { 
    super(_sheet, r, s, _bloc); 
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "");
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      search_panel();
    } });
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("panel cible title");
    
    mmain().inter.addEventNextFrame(new Runnable(this) { public void run() { 
      search_panel();
    } });
  }
  void search_panel() {
    if (val_pan_title.get().length() > 0) {
      for (MPanel m : mmain().pan_macros) 
        if (m != mpanel && m.val_pan_title.get().equals(val_pan_title.get())) {
          if (mpanel != null) mpanel.tool_macros.remove(this);
          if (mpanel != null) mpanel.rebuild();
          mpanel = m;
          mpanel.tool_macros.add(this);
          mpanel.rebuild();
          break;
        }
    }
  }
  MPanTool clear() {
    if (mpanel != null) mpanel.tool_macros.remove(this);
    if (mpanel != null) mpanel.rebuild();
    super.clear(); return this; }
}

class MPanel extends Macro_Bloc {  
  nWindowPanel front_panel;  
  
  nLinkedWidget stp_view; sBoo setup_send, menu_reduc; sVec menu_pos;
  Runnable grab_run, reduc_run;
  
  sStr val_pan_title; 
  nLinkedWidget title_field; 
  
  ArrayList<MPanTool> tool_macros = new ArrayList<MPanTool>();
  
  MPanel(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pan", "pan", _bloc); 
    setup_send = newBoo("stp_snd", "stp_snd", false);
    menu_reduc = newBoo("menu_reduc", "menu_reduc", false);
    menu_pos = newVec("menu_pos", "menu_pos");
    
    grab_run = new Runnable() { public void run() {
      if (front_panel != null) 
        menu_pos.set(front_panel.grabber.getLocalX(), front_panel.grabber.getLocalY()); } };
    reduc_run = new Runnable() { public void run() {
      if (front_panel != null) menu_reduc.set(front_panel.collapsed); } };
    
    addEmptyS(1);
    Macro_Element e = addEmptyL(0);
    e.addCtrlModel("MC_Element_Button", "panel").setRunnable(new Runnable() { public void run() { menu(); } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    addEmptyS(1);
    val_pan_title = newStr("pan_title", "pan_title", "pan_"+mmain().pan_nb);
    val_pan_title.addEventChange(new Runnable(this) { public void run() { 
      if (front_panel != null) front_panel.clear();
      for (MPanTool m : tool_macros) m.val_pan_title.set(val_pan_title.get());
      menu();
      if (front_panel != null) front_panel.grabber.setPosition(menu_pos.get());
    } });
    title_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_pan_title);
    title_field.setInfo("panel title");
    
    //addEmptyS(1).addCtrlModel("MC_Element_SButton", "bin")
    //  .setRunnable(new Runnable() { public void run() {
    //    MPanBin m = sheet.addPanBin(null);
    //    m.val_pan_title.set(val_pan_title.get());
    //} });
    
    mmain().pan_macros.add(this);
    mmain().pan_nb++;
    
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() { menu(); } });
    
  }
  void rebuild() {
    if (front_panel != null) front_panel.clear();
    menu();
    if (front_panel != null) front_panel.grabber.setPosition(menu_pos.get());
  }
  void menu() {
    if (front_panel == null) {
      front_panel = new nWindowPanel(mmain().screen_gui, mmain().inter.taskpanel, val_pan_title.get());
      front_panel.getShelf(0).addDrawer(4, 0);
      
      if (setup_send.get()) front_panel.grabber.setPosition(menu_pos.get());
      if (setup_send.get() && menu_reduc.get()) front_panel.collapse();
      if (setup_send.get() && !menu_reduc.get()) front_panel.popUp();
      
      front_panel.addEventClose(new Runnable(this) { public void run() { 
        front_panel = null; setup_send.set(false); } } );
      
      front_panel.grabber.addEventDrag(grab_run); 
      front_panel.addEventCollapse(reduc_run); 
      
      for (MPanTool m : tool_macros) m.build_front_panel(front_panel);
      
      setup_send.set(true);
      
    } else front_panel.popUp();
  }
  MPanel clear() {
    if (front_panel != null) front_panel.clear();
    mmain().pan_macros.remove(this);
    super.clear(); return this; }
}

class MMenu extends Macro_Bloc {  
  nLinkedWidget stp_view; sBoo setup_send, menu_reduc; sVec menu_pos;
  Runnable grab_run, reduc_run, close_run;
  MMenu(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "menu", "menu", _bloc); 
    setup_send = newBoo("stp_snd", "stp_snd", false);
    menu_reduc = newBoo("menu_reduc", "menu_reduc", false);
    menu_pos = newVec("menu_pos", "menu_pos");
    addEmptyS(1);
    Macro_Element e = addEmptyL(0);
    e.addCtrlModel("MC_Element_Button", "menu").setRunnable(new Runnable() { public void run() {
      menu(); } }).setInfo("open sheet general menu");
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    grab_run = new Runnable() { public void run() {
      if (sheet.sheet_front != null) 
        menu_pos.set(sheet.sheet_front.grabber.getLocalX(), sheet.sheet_front.grabber.getLocalY());
    } };
    reduc_run = new Runnable() { public void run() {
      if (sheet.sheet_front != null) 
        menu_reduc.set(sheet.sheet_front.collapsed);
    } };
    close_run = new Runnable() { public void run() { setup_send.set(false); } };
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      menu();
    } });
  }
  void menu() {
    sheet.build_sheet_menu();
    if (sheet.sheet_front != null) { 
      if (setup_send.get()) sheet.sheet_front.grabber.setPosition(menu_pos.get());
      if (setup_send.get() && menu_reduc.get()) sheet.sheet_front.collapse();
      if (setup_send.get() && !menu_reduc.get()) sheet.sheet_front.popUp();
      setup_send.set(true);
      sheet.sheet_front.grabber.addEventDrag(grab_run); 
      sheet.sheet_front.addEventCollapse(reduc_run);  
      sheet.sheet_front.addEventClose(close_run); 
    }
  }
  MMenu clear() {
    if (sheet.sheet_front != null) sheet.sheet_front.grabber.removeEventDrag(grab_run);
    if (sheet.sheet_front != null) sheet.sheet_front.removeEventCollapse(reduc_run); 
    if (sheet.sheet_front != null) sheet.sheet_front.removeEventClose(close_run); 
    if (sheet.sheet_front != null) sheet.sheet_front.clear();
    super.clear(); return this; }
}




class MVecCtrl extends Macro_Bloc { 
  void setValue(sValue v) {
    if (v.type.equals("vec")) {
      if (val_run != null && cible != null) cible.removeEventChange(val_run);
      if (in1_run != null) in1.removeEventReceive(in1_run);
      if (in2_run != null) in2.removeEventReceive(in2_run);
      val_cible.set(v.ref);
      cible = v; val_field.setLinkedValue(cible);
      vval = (sVec)cible;
      out.send(newPacketVec(vval.get()));
      val_run = new Runnable() { public void run() { out.send(newPacketVec(vval.get())); }};
      in1_run = new Runnable() { public void run() { 
        if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
          if (valMAG.get()) {
            PVector p = new PVector().set(vval.get());
            p.setMag(p.mag() + mod_f);
            vval.set(p);
          } else if (valROT.get()) {
            PVector p = new PVector(vval.get().mag(), 0);
            p.rotate(vval.get().heading() + mod_f);
            vval.set(p);
          } else if (valADD.get()) {
            PVector p = new PVector().set(vval.get());
            p.x += mod_vec.x; p.y += mod_vec.y;
            vval.set(p);
          } 
        }
      } };
      in2_run = new Runnable() { public void run() { 
        if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
          if (valMAG.get()) {
            PVector p = new PVector().set(vval.get());
            p.setMag(p.mag() - mod_f);
            vval.set(p);
          } else if (valROT.get()) {
            PVector p = new PVector(vval.get().mag(), 0);
            p.rotate(vval.get().heading() - mod_f);
            vval.set(p);
          } else if (valADD.get()) {
            PVector p = new PVector().set(vval.get());
            p.x -= mod_vec.x; p.y -= mod_vec.y;
            vval.set(p);
          } 
        }
      } };
      v.addEventChange(val_run);
      in1.addEventReceive(in1_run);
      in2.addEventReceive(in2_run);
    }
  }
  Runnable val_run, in1_run, in2_run;
  sVec vval;
  Macro_Connexion in1, in2, in_m, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field;
  nWatcherWidget val_field;
  nLinkedWidget widgMAG, widgROT, widgADD; 
  sBoo valMAG, valROT, valADD;
  float mod_f = 0; PVector mod_vec;
  nLinkedWidget mod_view1, mod_view2;
  sStr val_mod1, val_mod2; 
  MVecCtrl(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "vecCtrl", "vecCtrl", _bloc); 
    
    val_cible = newStr("cible", "cible", "");
    mod_vec = new PVector();
    val_mod1 = newStr("mod1", "mod1", "0");
    String t = val_mod1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod_f = 0; mod_vec.x = 0; }
      else if (float(t) != 0) { mod_f = float(t); mod_vec.x = mod_f; }
    }
    val_mod2 = newStr("mod2", "mod2", "0");
    t = val_mod2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod_vec.y = 0; }
      else if (float(t) != 0) { mod_vec.y = float(t); }
    }
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_cible.addEventChange(new Runnable(this) { public void run() { 
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible); } } );
    
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Field");
    addEmpty(1); addEmpty(1);
    
    in1 = addInput(0, "+").setFilterBang();
    in2 = addInput(0, "-").setFilterBang();
    in_m = addInput(0, "modifier").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && in_m.getLastPacket().isFloat() && 
          in_m.getLastPacket().asFloat() != mod_f) {
        mod_f = in_m.getLastPacket().asFloat(); 
        mod_view1.setText(trimStringFloat(mod_f)); 
        mod_view2.setText("-"); 
      } else if (in_m.getLastPacket() != null && in_m.getLastPacket().isVec() && 
          !in_m.getLastPacket().equalsVec(mod_vec)) {
        mod_vec.set(in_m.getLastPacket().asVec()); 
        mod_view1.setText(trimStringFloat(mod_vec.x)); 
        mod_view2.setText(trimStringFloat(mod_vec.y)); 
      }
    } });
    
    
    out = addOutput(1, "out");
    
    mod_view1 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod1);
    mod_view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view1.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod_f = 0; mod_vec.x = 0; }
        else if (float(t) != 0) { mod_f = float(t); mod_vec.x = mod_f; }
      }
    } });
    mod_view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod2);
    mod_view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view2.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod_vec.y = 0; }
        else if (float(t) != 0) { mod_vec.y = float(t); }
      }
    } });
    
    valMAG = newBoo("valMAG", "valMAG", false);
    valROT = newBoo("valROT", "valROT", false);
    valADD = newBoo("valADD", "valADD", false);
    
    Macro_Element e = addEmptyL(0);
    widgMAG = e.addLinkedModel("MC_Element_Button_Selector_1", "Mag").setLinkedValue(valMAG);
    widgROT = e.addLinkedModel("MC_Element_Button_Selector_2", "Rot").setLinkedValue(valROT);
    widgADD = e.addLinkedModel("MC_Element_Button_Selector_4", "Add").setLinkedValue(valADD);
    widgMAG.addExclude(widgROT).addExclude(widgADD);
    widgROT.addExclude(widgMAG).addExclude(widgADD);
    widgADD.addExclude(widgROT).addExclude(widgMAG);
    
    if (v != null) setValue(v);
    else {
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible);
    }
  }
  MVecCtrl clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}

class MComp extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgSUP, widgINF, widgEQ; 
  sBoo valSUP, valINF, valEQ;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MComp(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "comp", "comp", _bloc); 
    
    valSUP = newBoo("valSUP", "valSUP", false);
    valINF = newBoo("valINF", "valINF", false);
    valEQ = newBoo("valEQ", "valEQ", false);
    
    valSUP.addEventChange(new Runnable() { public void run() { if (valSUP.get()) receive(); } });
    valINF.addEventChange(new Runnable() { public void run() { if (valINF.get()) receive(); } });
    valEQ.addEventChange(new Runnable() { public void run() { if (valEQ.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterNumber().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
          in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); 
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isInt() && 
                 in1.getLastPacket().asInt() != pin1) {
        pin1 = in1.getLastPacket().asInt(); receive(); 
      } 
    } });
    in2 = addInput(0, "in").setFilterNumber().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
          in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); 
      } else if (in2.getLastPacket() != null && in2.getLastPacket().isInt() && 
                 in2.getLastPacket().asInt() != pin2) {
        pin2 = in2.getLastPacket().asInt(); receive(); 
      } 
    } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = newStr("val", "val", "");
    
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (float(t) != 0) { pin2 = float(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    
    Macro_Element e = addEmptyL(0);
    widgSUP = e.addLinkedModel("MC_Element_Button_Selector_1", ">").setLinkedValue(valSUP);
    widgINF = e.addLinkedModel("MC_Element_Button_Selector_2", "<").setLinkedValue(valINF);
    widgEQ = e.addLinkedModel("MC_Element_Button_Selector_4", "=").setLinkedValue(valEQ);
    widgSUP.addExclude(widgINF);
    widgINF.addExclude(widgSUP);
    
  }
  void receive() { 
    if      (valSUP.get() && (pin1 > pin2)) out.send(newPacketBool(true));
    else if (valINF.get() && (pin1 < pin2)) out.send(newPacketBool(true));
    else if (valEQ.get() && (pin1 == pin2)) out.send(newPacketBool(true));
    else                                    out.send(newPacketBool(false));
  }
  MComp clear() {
    super.clear(); return this; }
}


class MNumCtrl extends Macro_Bloc { 
  void setValue(sValue v) {
    if (v.type.equals("flt") || v.type.equals("int")) {
      if (val_run != null && cible != null) cible.removeEventChange(val_run);
      if (in1_run != null) in1.removeEventReceive(in1_run);
      if (in2_run != null) in2.removeEventReceive(in2_run);
      val_cible.set(v.ref);
      cible = v; val_field.setLinkedValue(cible);
      if (cible.type.equals("flt")) setValue((sFlt)cible);
      if (cible.type.equals("int")) setValue((sInt)cible);
    }
  }
  void setValue(sFlt v) {
    fval = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(fval.get())); }};
    in1_run = new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
        if (valFAC.get()) fval.set(fval.get()*mod); 
        if (valINC.get()) fval.set(fval.get()+mod); }
    } };
    in2_run = new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
        if (valINC.get()) fval.set(fval.get()-mod); 
        if (valFAC.get() && mod != 0) fval.set(fval.get()/mod); }
    } };
    v.addEventChange(val_run);
    in1.addEventReceive(in1_run);
    in2.addEventReceive(in2_run);
  }
  void setValue(sInt v) {
    ival = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(ival.get())); }};
    in1_run = new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBang()) { 
        if (valFAC.get()) ival.set(int(ival.get()*mod)); 
        if (valINC.get()) ival.set(int(ival.get()+mod)); }
    } };
    in2_run = new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBang()) { 
        if (valINC.get()) ival.set(int(ival.get()-mod)); 
        if (valFAC.get() && mod != 0) ival.set(int(ival.get()/mod)); }
    } };
    v.addEventChange(val_run);
    in1.addEventReceive(in1_run);
    in2.addEventReceive(in2_run);
  }
  Runnable val_run, in1_run, in2_run;
  sInt ival; sFlt fval;
  Macro_Connexion in1, in2, in_m, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field, val_field;
  nLinkedWidget widgFAC, widgINC; 
  sBoo valFAC, valINC;
  float mod = 0;
  nLinkedWidget mod_view;
  sStr val_mod; 
  MNumCtrl(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "numCtrl", "numCtrl", _bloc); 
    
    val_cible = newStr("cible", "cible", "");
    
    val_mod = newStr("mod", "mod", "2");
    String t = val_mod.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mod = 0; }
      else if (float(t) != 0) { mod = float(t); }
    }
    
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addLinkedModel("MC_Element_Field");
    val_cible.addEventChange(new Runnable(this) { public void run() { 
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible); } } );
    
    addEmpty(1); addEmpty(1);
    
    in1 = addInput(0, "+/x").setFilterBang();
    in2 = addInput(0, "-//").setFilterBang();
    in_m = addInput(0, "modifier").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && in_m.getLastPacket().isFloat() && 
          in_m.getLastPacket().asFloat() != mod) {
        mod = in_m.getLastPacket().asFloat(); mod_view.setText(trimStringFloat(mod)); } } });
    
    
    out = addOutput(1, "out");
    
    mod_view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_mod);
    mod_view.addEventFieldChange(new Runnable() { public void run() { 
      String t = mod_view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mod = 0; }
        else if (float(t) != 0) { mod = float(t); }
      }
    } });
    
    valFAC = newBoo("valFAC", "valFAC", false);
    valINC = newBoo("valINC", "valINC", false);
    
    Macro_Element e = addEmptyS(1);
    widgFAC = e.addLinkedModel("MC_Element_Button_Selector_1", "x /").setLinkedValue(valFAC);
    widgINC = e.addLinkedModel("MC_Element_Button_Selector_2", "+ -").setLinkedValue(valINC);
    widgFAC.addExclude(widgINC);
    widgINC.addExclude(widgFAC);
    
    if (v != null) setValue(v);
    else {
      cible = sheet.value_bloc.getValue(val_cible.get());
      if (cible != null) setValue(cible);
    }
  }
  MNumCtrl clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}


class MData extends Macro_Bloc {
  void setValue(sValue v) {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    if (in_run != null) in.removeEventReceive(in_run);
    val_cible.set(v.ref);
    cible = v; val_field.setLinkedValue(cible);
    if (cible.type.equals("flt")) setValue((sFlt)cible);
    if (cible.type.equals("int")) setValue((sInt)cible);
    if (cible.type.equals("boo")) setValue((sBoo)cible);
    if (cible.type.equals("str")) setValue((sStr)cible);
    if (cible.type.equals("run")) setValue((sRun)cible);
    if (cible.type.equals("vec")) setValue((sVec)cible);
  }
  void setValue(sFlt v) {
    fval = v;
    out.send(newPacketFloat(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketFloat(fval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isFloat()) { 
        fval.set(in.getLastPacket().asFloat()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  void setValue(sInt v) {
    ival = v;
    out.send(newPacketInt(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketInt(ival.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isInt()) { 
        ival.set(in.getLastPacket().asInt()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  void setValue(sBoo v) {
    bval = v;
    out.send(newPacketBool(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketBool(bval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) { 
        bval.set(in.getLastPacket().asBool()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  void setValue(sStr v) {
    sval = v;
    out.send(newPacketStr(v.get()));
    val_run = new Runnable() { public void run() { out.send(newPacketStr(sval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isStr()) { 
        sval.set(in.getLastPacket().asStr()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  void setValue(sRun v) {
    rval = v;
    val_run = new Runnable() { public void run() { out.send(newPacketBang()); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) { 
        rval.doEvent(false); 
        rval.run(); 
        rval.doEvent(true); 
      }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  void setValue(sVec v) {
    vval = v;
    out.send(newPacketVec(v.get()));
    
    val_run = new Runnable() { public void run() { out.send(newPacketVec(vval.get())); }};
    in_run = new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isVec()) { 
        vval.set(in.getLastPacket().asVec()); }
    } };
    v.addEventChange(val_run);
    in.addEventReceive(in_run);
  }
  Runnable val_run, in_run;
  sBoo bval; sInt ival; sFlt fval; sStr sval; sVec vval; sRun rval;
  Macro_Connexion in, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field; 
  nWatcherWidget val_field;
  MData(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "data", "data", _bloc); 
    val_cible = newStr("cible", "cible", "");
    init();
    if (v != null) setValue(v);
  }
  void init() {
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Text");
    val_cible.addEventChange(new Runnable(this) { public void run() { get_cible(); } } );
    addEmpty(1); addEmpty(1);
    in = addInput(0, "in");
    out = addOutput(1, "out");
    get_cible();
  }
  void get_cible() {
    cible = sheet.value_bloc.getValue(val_cible.get());
    if (cible != null) setValue(cible);
  }
  MData clear() {
    if (val_run != null && cible != null) cible.removeEventChange(val_run);
    super.clear(); return this; }
}

class MVecXY extends Macro_Bloc {
  Macro_Connexion in1,in2,out1,out2;
  float x = 0, y = 0;
  PVector vec;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MVecXY(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "vecXY", "vecXY", _bloc); 
    
    in1 = addInput(0, "v/x").addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isVec() && 
          (in1.getLastPacket().asVec().x != vec.x || in1.getLastPacket().asVec().y != vec.y)) {
        vec.set(in1.getLastPacket().asVec());
        float m = vec.x; float d = vec.y;
        if (m != x) { x = m; out1.send(newPacketFloat(m)); }
        if (d != y) { y = d; out2.send(newPacketFloat(d)); }
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
                 in1.getLastPacket().asFloat() != x) {
        x = in1.getLastPacket().asFloat();
        view1.changeText(trimStringFloat(x)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    in2 = addInput(0, "y").addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
                 in2.getLastPacket().asFloat() != y) {
        y = in2.getLastPacket().asFloat();
        view2.changeText(trimStringFloat(y)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    out1 = addOutput(1, "v/x");
    out2 = addOutput(1, "y");
    
    vec = new PVector(1, 0);
    
    val_view1 = newStr("x", "x", "0");
    val_view2 = newStr("y", "y", "0");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { x = 0; }
      else if (float(t) != 0) { x = float(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { y = 0; }
      else if (float(t) != 0) { y = float(t); }
    }
    vec.set(x, y);
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("x");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      float a = x;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { x = 0; }
        else if (float(t) != 0) { x = float(t); }
      }
      if (x != a) {
        //view1.changeText(trimStringFloat(x)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("y");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      float a = y;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { y = 0; }
        else if (float(t) != 0) { y = float(t); }
      }
      if (y != a) {
        //view2.changeText(trimStringFloat(y)); 
        vec.set(x, y);
        out1.send(newPacketVec(vec));
      }
    } });
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out1.send(newPacketVec(vec));
    } });
  }
  MVecXY clear() {
    super.clear(); return this; }
}
class MVecMD extends Macro_Bloc {
  Macro_Connexion in1,in2,out1,out2;
  float mag = 1, dir = 0;
  PVector vec;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MVecMD(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "vecMD", "vecMD", _bloc); 
    
    in1 = addInput(0, "v/mag").addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isVec() && 
          (in1.getLastPacket().asVec().x != vec.x || in1.getLastPacket().asVec().y != vec.y)) {
        vec.set(in1.getLastPacket().asVec());
        float m = vec.mag(); float d = vec.heading();
        if (m != mag) { mag = m; out1.send(newPacketFloat(m)); }
        if (d != dir) { dir = d; out2.send(newPacketFloat(d)); }
      } else if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && 
                 in1.getLastPacket().asFloat() != mag) {
        mag = in1.getLastPacket().asFloat();
        view1.changeText(trimStringFloat(mag)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    in2 = addInput(0, "dir").addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && 
                 in2.getLastPacket().asFloat() != dir) {
        dir = in2.getLastPacket().asFloat();
        view2.changeText(trimStringFloat(dir)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    out1 = addOutput(1, "v/mag");
    out2 = addOutput(1, "dir");
    
    vec = new PVector(1, 0);
    
    val_view1 = newStr("mag", "mag", "1");
    val_view2 = newStr("dir", "dir", "0");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { mag = 0; }
      else if (float(t) != 0) { mag = float(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { dir = 0; }
      else if (float(t) != 0) { dir = float(t); }
    }
    vec.set(mag, 0).rotate(dir);
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("mag");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      float a = mag;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { mag = 0; }
        else if (float(t) != 0) { mag = float(t); }
      }
      if (mag != a) {
        //view1.changeText(trimStringFloat(mag)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("dir");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      float a = dir;
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { dir = 0; }
        else if (float(t) != 0) { dir = float(t); }
      }
      if (dir != a) {
        //view2.changeText(trimStringFloat(dir)); 
        vec.set(mag, 0).rotate(dir);
        out1.send(newPacketVec(vec));
      }
    } });
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out1.send(newPacketVec(vec));
    } });
  }
  MVecMD clear() {
    super.clear(); return this; }
}

class MRandom extends Macro_Bloc { 
  Macro_Connexion in, out;
  float min = 0, max = 1;
  nLinkedWidget view1, view2;
  sStr val_view1, val_view2; 
  MRandom(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "rng", "rng", _bloc); 
    
    in = addInput(0, "bang").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        out.send(newPacketFloat(random(min, max))); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view1 = newStr("min", "min", "0");
    val_view2 = newStr("max", "max", "1");
    
    String t = val_view1.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { min = 0; }
      else if (float(t) != 0) { min = float(t); }
    }
    t = val_view2.get();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { max = 0; }
      else if (float(t) != 0) { max = float(t); }
    }
    view1 = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view1);
    view1.setInfo("min");
    view1.addEventFieldChange(new Runnable() { public void run() { 
      String t = view1.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { min = 0; }
        else if (float(t) != 0) { min = float(t); }
      }
      if (min > max) { float a = min; min = max; max = a; }
      //view1.setText(trimStringFloat(min)); 
      //view2.setText(trimStringFloat(max)); 
    } });
    view2 = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view2);
    view2.setInfo("max");
    view2.addEventFieldChange(new Runnable() { public void run() { 
      String t = view2.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { max = 0; }
        else if (float(t) != 0) { max = float(t); }
      }
      if (min > max) { float a = min; min = max; max = a; }
      //view1.setText(trimStringFloat(min)); 
      //view2.setText(trimStringFloat(max)); 
    } });
  }
  MRandom clear() {
    super.clear(); return this; }
}

class MMouse extends Macro_Bloc { 
  Macro_Connexion out1, out2, out3;
  Runnable run;
  PVector m, pm, mm, v;
  MMouse(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "mouse", "mouse", _bloc); 
    out1 = addOutput(0, "pos"); out2 = addOutput(0, "ppos"); out3 = addOutput(0, "mouv");
    m = new PVector(0, 0); pm = new PVector(0, 0); mm = new PVector(0, 0); v = new PVector(0, 0);
    run = new Runnable() { public void run() { 
      if (m.x != gui.mouseVector.x || m.y != gui.mouseVector.y) { 
        out1.send(newPacketVec(gui.mouseVector));
        m.set(gui.mouseVector); }
      if (pm.x != gui.pmouseVector.x || pm.y != gui.pmouseVector.y) { 
        out2.send(newPacketVec(gui.pmouseVector));
        pm.set(gui.pmouseVector); }
      v.set(gui.mouseVector);
      v = v.sub(gui.pmouseVector);
      if (mm.x != v.x || mm.y != v.y) { 
        out3.send(newPacketVec(v));
        mm.set(v); }
    } };
    mmain().inter.addEventFrame(run);
  }
  MMouse clear() {
    mmain().inter.removeEventFrame(run);
    super.clear(); return this; }
}
class MComment extends Macro_Bloc { 
  sStr val_cible; 
  nLinkedWidget ref_field; 
  MComment(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "com", "com", _bloc); 
    val_cible = newStr("cible", "cible", "");
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    addEmpty(1); 
  }
  MComment clear() {
    super.clear(); return this; }
}
/*
channel call / listen : 
  packet whormhole
  each channel is linked to his creating sheet
  can be accessed with sheet name + channel name from anywhere
*/

class MChan extends Macro_Bloc { 
  Macro_Connexion in, out;
  sStr val_cible; 
  nLinkedWidget ref_field; 
  MChan(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "chan", "chan", _bloc); 
    val_cible = newStr("cible", "cible", "");
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    addEmpty(1); 
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) receive(in.getLastPacket());
    } });
    out = addOutput(1, "out");
    
    mmain().chan_macros.add(this);
  }
  void receive(Macro_Packet p) {
    out.send(p);
    for (MChan m : mmain().chan_macros) 
      if (m != this && m.val_cible.get().equals(val_cible.get())) m.out.send(p);
  }
  MChan clear() {
    super.clear(); 
    mmain().chan_macros.remove(this); return this; }
}

class MFrame extends Macro_Bloc { 
  Macro_Connexion in, out;
  Macro_Packet packet1, packet2;
  boolean pack_balance = false;
  MFrame(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "frame", "frame", _bloc); 
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) { 
        if (pack_balance) { 
          pack_balance = false;
          packet1 = in.getLastPacket();
          mmain().inter.addEventNextFrame(new Runnable() { public void run() { out.send(packet1); }});
        } else {
          pack_balance = true;
          packet2 = in.getLastPacket();
          mmain().inter.addEventNextFrame(new Runnable() { public void run() { out.send(packet2); }});
        }
      } 
    } });
        
    out = addOutput(1, "out");
  }
  MFrame clear() {
    super.clear(); return this; }
}



class MPulse extends Macro_Bloc { //let throug only 1 bang every <delay> bang
  Macro_Connexion in, out;
  sInt delay;
  nLinkedWidget del_field;
  int count = 0;
  MPulse(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pulse", "pulse", _bloc); 
    
    delay = newInt("delay", "delay", 100);
    
    addEmptyS(1);
    del_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(delay);
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        count++;
        if (count > delay.get()) { count = 0; out.send(newPacketBang()); }
      } else if (in.getLastPacket() != null && in.getLastPacket().isFloat()) {
        count = 0;
        delay.set(int(in.getLastPacket().asFloat()));
      } else if (in.getLastPacket() != null && in.getLastPacket().isInt()) {
        count = 0;
        delay.set(in.getLastPacket().asInt());
      } 
    } });
        
    out = addOutput(1, "out")
      .setDefBool();
  }
  MPulse clear() {
    super.clear(); return this; }
}






class MCalc extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgADD, widgSUB, widgMUL, widgDEV; 
  sBoo valADD, valSUB, valMUL, valDEV;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MCalc(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "calc", "calc", _bloc); 
    
    valADD = newBoo("valADD", "valADD", false);
    valSUB = newBoo("valSUB", "valSUB", false);
    valMUL = newBoo("valMUL", "valMUL", false);
    valDEV = newBoo("valDEV", "valDEV", false);
    
    valADD.addEventChange(new Runnable() { public void run() { if (valADD.get()) receive(); } });
    valSUB.addEventChange(new Runnable() { public void run() { if (valSUB.get()) receive(); } });
    valMUL.addEventChange(new Runnable() { public void run() { if (valMUL.get()) receive(); } });
    valDEV.addEventChange(new Runnable() { public void run() { if (valDEV.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); } } });
    in2 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = newStr("val", "val", "");
    
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (float(t) != 0) { pin2 = float(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    String t = view.getText();
    if (t.length() > 0) {
      if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); }
      else if (float(t) != 0) { pin2 = float(t); in2.setLastFloat(pin2); }  }
    Macro_Element e = addEmptyL(0);
    widgADD = e.addLinkedModel("MC_Element_Button_Selector_1", "+").setLinkedValue(valADD);
    widgSUB = e.addLinkedModel("MC_Element_Button_Selector_2", "-").setLinkedValue(valSUB);
    widgMUL = e.addLinkedModel("MC_Element_Button_Selector_3", "X").setLinkedValue(valMUL);
    widgDEV = e.addLinkedModel("MC_Element_Button_Selector_4", "/").setLinkedValue(valDEV);
    widgADD.addExclude(widgDEV).addExclude(widgSUB).addExclude(widgMUL);
    widgSUB.addExclude(widgADD).addExclude(widgDEV).addExclude(widgMUL);
    widgMUL.addExclude(widgADD).addExclude(widgSUB).addExclude(widgDEV);
    widgDEV.addExclude(widgADD).addExclude(widgSUB).addExclude(widgMUL);
    
  }
  void receive() { 
    if      (valADD.get()) out.send(newPacketFloat(pin1 + pin2));
    else if (valSUB.get()) out.send(newPacketFloat(pin1 - pin2));
    else if (valMUL.get()) out.send(newPacketFloat(pin1 * pin2));
    else if (valDEV.get() && pin2 != 0) out.send(newPacketFloat(pin1 / pin2));
  }
  MCalc clear() {
    super.clear(); return this; }
}

class MBool extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgAND, widgOR; 
  sBoo valAND, valOR;
  boolean pin1 = false, pin2 = false;
  MBool(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bool", "bool", _bloc); 
    
    valAND = newBoo("valAND", "valAND", false);
    valOR = newBoo("valOR", "valOR", false);
    
    in1 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBool() && in1.getLastPacket().asBool() != pin1) {
        pin1 = in1.getLastPacket().asBool(); receive(); } } });
    in2 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBool() && in2.getLastPacket().asBool() != pin2) {
        pin2 = in2.getLastPacket().asBool(); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefBool();
    
    Macro_Element e = addEmptyS(1);
    widgAND = e.addLinkedModel("MC_Element_Button_Selector_1", "&&").setLinkedValue(valAND);
    widgOR = e.addLinkedModel("MC_Element_Button_Selector_2", "||").setLinkedValue(valOR);
    widgAND.addExclude(widgOR);
    widgOR.addExclude(widgAND);
    
  }
  void receive() { 
    if (valAND.get() && (pin1 && pin2)) 
        out.send(newPacketBool(true));
    else if (valOR.get() && (pin1 || pin2)) 
      out.send(newPacketBool(true));
    else if (valAND.get() || valOR.get()) 
      out.send(newPacketBool(false));
  }
  MBool clear() {
    super.clear(); return this; }
}


class MBin extends Macro_Bloc {
  Macro_Connexion in, out;
  MBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bin", "bin", _bloc); 
    
    in = addInput(0, "in").setFilterBin().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool() && 
          in.getLastPacket().asBool()) out.send(newPacketBang()); 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) out.send(newPacketBool(true)); } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  MBin clear() {
    super.clear(); return this; }
}

class MNot extends Macro_Bloc {
  Macro_Connexion in, out;
  MNot(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "not", "not", _bloc); 
    
    in = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) {
        if (in.getLastPacket().asBool()) out.send(newPacketBool(false)); 
        else out.send(newPacketBool(true)); } } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  MNot clear() {
    super.clear(); return this; }
}

class MGate extends Macro_Bloc {
  Macro_Connexion in_m, in_b, out;
  nLinkedWidget swtch; 
  sBoo state;
  MGate(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "gate", "gate", _bloc); 
    
    state = newBoo("state", "state", false);
    
    in_m = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in_m.getLastPacket() != null && state.get()) out.send(in_m.getLastPacket());
    } });
    in_b = addInput(0, "gate").addEventReceive(new Runnable() { public void run() { 
      if (in_b.getLastPacket() != null && in_b.getLastPacket().isBool()) 
        state.set(in_b.getLastPacket().asBool()); 
    } });
    out = addOutput(1, "out");
    
    swtch = addEmptyS(1).addLinkedModel("MC_Element_SButton").setLinkedValue(state);
    
  }
  MGate clear() {
    super.clear(); return this; }
}

class MVar extends Macro_Bloc {
  Macro_Connexion in, out;
  Macro_Packet packet;
  nLinkedWidget view, stp_view;
  sStr val_view; sBoo setup_send;
  MVar(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "var", "var", _bloc); 
    packet = newPacketFloat(0); 
    
    val_view = newStr("val", "val", "0");
    String t = val_view.get();
    if (t.length() > 0) {
      if (t.equals("true")) packet = newPacketBool(true);
      else if (t.equals("false")) packet = newPacketBool(false);
      else if (t.equals("0")) packet = newPacketFloat(0);
      else if (t.equals("0.0")) packet = newPacketFloat(0);
      else if (float(t) != 0) packet = newPacketFloat(float(t));
    }
    
    setup_send = newBoo("stp_snd", "stp_snd", true);
    
    Macro_Element e = addEmptyS(1);
    e.addCtrlModel("MC_Element_SButton")
      .setRunnable(new Runnable() { public void run() { if (packet != null) out.send(packet); } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    view = addEmptyS(0).addLinkedModel("MC_Element_SField");
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("true")) packet = newPacketBool(true);
        else if (t.equals("false")) packet = newPacketBool(false);
        else if (t.equals("0")) packet = newPacketFloat(0);
        else if (t.equals("0.0")) packet = newPacketFloat(0);
        else if (float(t) != 0) packet = newPacketFloat(float(t));
      }
    } });
    view.setLinkedValue(val_view);
    
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) {
        if (in.getLastPacket().isBang() && packet != null) out.send(packet);
        else { packet = in.getLastPacket(); view.setText(packet.getText()); } }
    } });
    out = addOutput(1, "out");
    
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      if (packet != null) out.send(packet);
    } });
  }
  MVar clear() {
    super.clear(); return this; }
}
class MTrig extends Macro_Bloc {
  Macro_Connexion out_t;
  nCtrlWidget trig; 
  nLinkedWidget stp_view; sBoo setup_send;
  MTrig(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "trig", "trig", _bloc); 
    setup_send = newBoo("stp_snd", "stp_snd", false);
    
    Macro_Element e = addEmptyS(0);
    trig = e.addCtrlModel("MC_Element_SButton").setRunnable(new Runnable() { public void run() {
      out_t.send(newPacketBang());
    } });
    e.addLinkedModel("MC_Element_MiniButton", "st").setLinkedValue(setup_send);
    
    out_t = addOutput(1, "trig")
      .setDefBang();
    if (setup_send.get()) mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out_t.send(newPacketBang());
    } });
  }
  MTrig clear() {
    super.clear(); return this; }
}
class MSwitch extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget swtch; 
  sBoo state;
  MSwitch(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "switch", "switch", _bloc); 
    
    state = newBoo("state", "state", false);
    
    swtch = addEmptyS(0).addLinkedModel("MC_Element_SButton").setLinkedValue(state);
    
    state.addEventChange(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
    out_t = addOutput(1, "out")
      .setDefBool();
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
  }
  MSwitch clear() {
    super.clear(); return this; }
}

class MKeyboard extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget key_field; 
  sStr val_cible; 
  MKeyboard(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "keyb", "keyb", _bloc); 
    val_cible = newStr("cible", "cible", "");
    init();
  }
  void init() {
    key_field = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_cible);
    out_t = addOutput(1, "trig")
      .setDefBang();
    key_field.addEventFrame(new Runnable() { public void run() {
      if (mmain().inter.input.keyAll.state && key_field.getText().length() > 0 && 
          key_field.getText().charAt(0) == mmain().inter.input.getLastKey()) 
        out_t.send(newPacketBang());
    } } );
  }
  MKeyboard clear() {
    super.clear(); return this; }
  
}




class MSheetIn extends Macro_Bloc {
  Macro_Element elem;
  MSheetIn(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "in", "in", _bloc); 
    init();
  }
  void init() {
    elem = addSheetInput(0, "in");
    val_title.addEventChange(new Runnable() { public void run() { 
    if (elem.sheet_connect != null) elem.sheet_connect.setInfo(val_title.get()); } });
  }
  MSheetIn clear() {
    super.clear(); return this; }
}

class MSheetOut extends Macro_Bloc {
  Macro_Element elem;
  MSheetOut(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "out", "out", _bloc); 
    init();
  }
  void init() {
    elem = addSheetOutput(0, "out");
    val_title.addEventChange(new Runnable() { public void run() { 
    if (elem.sheet_connect != null) elem.sheet_connect.setInfo(val_title.get()); } });
  }
  MSheetOut clear() {
    super.clear(); return this; }
}


/*

 bloc extend abstract
 shelfpanel of element
 methods to add and manipulate element for easy macro building
 
 */
class Macro_Bloc extends Macro_Abstract {
  Macro_Bloc(Macro_Sheet _sheet, String t, String n, sValueBloc _bloc) {
    super(_sheet, t, n, _bloc);
    addShelf(); 
    addShelf();
  }

  Macro_Element addEmptyS(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyB(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Big", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  nWidget addEmpty(int c) { 
    Macro_Element m = new Macro_Element(this, "", "mc_ref", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addFillR(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillright", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }
  nWidget addFillL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillleft", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addLabelS(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m.back;
  }
  nWidget addLabelL(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  Macro_Connexion addInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Connexion addOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Element addSheetInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m;
  }
  Macro_Element addSheetOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m;
  }


  Macro_Element addElement(int c, Macro_Element m) {
    if (c >= 0 && c < 3) {
      if (c == 2 && shelfs.size() < 3) addShelf();
      elements.add(m);
      getShelf(c).insertDrawer(m);
      if (c == 0 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(-ref_size*0.0);
      if (c == 1 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size*0.5);
      if (c == 2 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size);
      if (openning.get() == OPEN) for (Macro_Element e : elements) e.show();
      toLayerTop();
      return m;
    } else return null;
  }
  
  String resum_link() { 
    String r = "";
    for (Macro_Element m : elements) {
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_inputs) 
        r += co.descr + INFO_TOKEN + m.connect.descr + OBJ_TOKEN;
      if (m.connect != null) for (Macro_Connexion co : m.connect.connected_outputs) 
        r += m.connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_inputs) 
      //  r += co.descr + INFO_TOKEN + m.sheet_connect.descr + OBJ_TOKEN;
      //if (m.sheet_connect != null) for (Macro_Connexion co : m.sheet_connect.connected_outputs) 
      //  r += m.sheet_connect.descr + INFO_TOKEN + co.descr + OBJ_TOKEN;
    }
    return r; 
  }
  
  ArrayList<Macro_Element> elements = new ArrayList<Macro_Element>();
  Macro_Bloc toLayerTop() { 
    super.toLayerTop(); 
    for (Macro_Element e : elements) e.toLayerTop(); 
    grabber.toLayerTop(); 
    return this;
  }

  Macro_Bloc open() {
    super.open();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  Macro_Bloc reduc() {
    super.reduc();
    for (Macro_Element m : elements) m.reduc();
    toLayerTop();
    return this;
  }
  Macro_Bloc show() {
    super.show();
    for (Macro_Element m : elements) m.show();
    toLayerTop();
    return this;
  }
  Macro_Bloc hide() {
    super.hide(); 
    for (Macro_Element m : elements) m.hide();
    //toLayerTop();
    return this;
  }
}
