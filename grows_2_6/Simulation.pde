
/*

  Simulation(Input, Data, Interface)
    Build with interface
      toolPanel down left to down center with main function
        time control (tick by frame, pause, trigger tick by tick or frame by frame)
        restart control and RNG
        Quick save / load
        button to hide all guis (toolpanel reducted)
        Openning main dropdown menu to open main panels
          file selection panel
          communitys panel
            open save / load parameters panel
            basic info n param
            completed by each community type
          shortcut panel
            can link key to preselected button
      taskBar on down right side
      SelectZone working in camera
      Info
    TickPile
    one Drawer for all communitys in camera drawerpile
      simpler before more coding
    community
      has an adding point as an svalue and grabbable
      grower as also an adding direction
      floc an adding radius
    Entity
      position, direction, size
      custom parameters
      list of geometrical shapes and colors
        shapes contain energy???                            <<<<<< THE GAME MECHANIC MAKE HER ENTRY
        to excenge energy throug macro link output need a received method called by receiving input to
        confirm transfer 
      width 1200
      draw : invisible, particle 1px, pebble 5px, small 25px, med 100px, 
             big 400px, fullscreen 1100px, zoom in 3000px, micro 10 000px, too big 100 000px
    frame()
      drive ticking
    macro_main
      each community have her sheet inside whom community param and runnable can be acsessed
      maybe for each community her is an independent macro space who can acsess an entity
      property and who can be applyed to each entity of this commu
      there can be plane who take entity from different commu to make them interact
      
  Macro_Main(Input, Data, Interface)
    tick()
    addTickAskMethod
    add show/hide button in sim toolpanel ( go back n forth between two camera view )
    add entry to sim main menu to create macro main panel
    macro main panel
      tab file
        select save file
        clear/save/load all
      tab add to selected sheet
        child sheet
        sheet in/out
          can be named
        basic macro
        macro for svalue watch/ctrl
        macro to launch referanced runnables
      tab templates
        select template list file
        save selected sheet as template
        template list 
          trigger creation of selected template as child in selected sheet
          can trigger deletion of selected template
    
      
  

*/
