PRO primus_zspec_startup
    
    ;;Carries out all of the initiailizations of the widgets
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, $
      objindex, fullindex, subindex, rerun
    common zspec_plotoptions, plotoptions
    COMMON sharestate, state
    
    
    base = widget_base(/column, title='PRIMUS zspec Alpha', mbar=menu)
    
    ;;--make menu
    menu1 = widget_button(menu, value='File', /menu, xsize=200)
    button = widget_button(menu1, value='Quit', uvalue='DONE')
    
    
    ;;--view menu
    menu2 = widget_button(menu, value='View', /menu, xsize=200)
    button = widget_button(menu2, value='Show Sky Subtracted 2d Image', $
      event_PRO='primus_zspec_skysub')
    
    
    ;;--Help Menu
    menu4 = widget_button(menu, value='Help', /menu, xsize=200)
    button = widget_button(menu4, value='Show Help', $
      event_PRO='primus_zspec_help')
    button = widget_button(menu4, value='Version', $
      event_PRO='primus_zspec_version')
    
    ;;--Place for the spectrum
    draw_base1 = widget_base(base, /row)
    draw_1d_wid = widget_draw(draw_base1, xsize=1000, ys=350)


    
    
    ;;--Information tab
    basex = widget_base(base, /row)
    maintext = widget_text(basex, xsize=40, ysize=20, frame=1)
    
    
    ;;--Redshifts:
    ;;This section containts a drop list for selecting the fit to
    ;;plot.
    basex2 = widget_base(basex, /column)
    base4 = widget_base(basex2, /row)
    sbase = widget_base(basex2, /row, title="Smoothing Options")
    values = ["Photoz Best", "Photoz 2nd", "Non-Photoz Best", $
      "Non-Photoz 1st", "Star", "AGN","AGN 2nd","AGN 3rd","Powerlaw", "Known","BEST"]

    redshift_select = widget_droplist(sbase, value=values, $
      title="Model Selection:", $
      event_pro='primus_zspec_selectz', /dynamic_resize, /frame)
    values=['Counts / s / Ang', 'Erg / s / cm2 / Ang']
    
    model_plot = widget_droplist(sbase, value=['Off', 'On'], $
      title='Display Model :', $
      event_pro='primus_zspec_modelstate', /dynamic_resize, /frame)
    
    fluxing_select = widget_droplist(base4, value=values, $
      title='Fluxing:', $
      event_pro='primus_fluxing_select', /dynamic_resize, /frame)
    
    
    
    
    ;;--Smoothing:
    ;;The user can specify the amount of smoothing to be applied to
    ;;the blue end of the spectra

    values=['None', '25 Angstrom', '50 Angstrom']
    smoothing_select = widget_droplist(base4, value=values, $
      title='Blue Smoothing:', $
      event_pro='primus_zspec_smooth', /dynamic_resize, /frame)
    values=['All','Fitted']
    obj_filter = widget_droplist(base4, value=values, $
      title='Object Set:', $
      event_pro='primus_zspec_objfilter', /dynamic_resize ,/frame)
    
    ;;Object/Mask selection
    base_ex4 = widget_base(basex2, /row)
    mask_select = widget_label(base_ex4, value="New Mask Name:", xsize=100)
    mtext = widget_text(base_ex4, xsize=10, uvalue=0L, $
      event_PRO='primus_zspec_maskselect', $
      value=mtext, /editable)
    widget_control, mtext, set_uvalue=mtext
    button=widget_button(base_ex4,value='Load Mask', uvalue=mtext, $
      event_pro='primus_zspec_maskselect', xsize=100)
    button=widget_button(base_ex4, value="Show 2d image", $
      event_pro='primus_zspec_skysub', $
      xsize=100)
    button=widget_button(base_ex4, value='2d Options',$
      event_pro='primus_zspec_2doptions', $
      xsize=200)

    base_ex5 = widget_base(basex2, /row)
    label = widget_label(base_ex5, value="Jump to Object:", xsize=100)
    otext = widget_text(base_ex5, xsize=10, uvalue=0L, $
      event_PRO='primus_zspec_jump', $
      /editable, value=otext)
    widget_control, otext, set_uvalue=otext
    button=widget_button(base_ex5, value='Jump Obj', uvalue=otext, $
      event_pro='primus_zspec_jump', xsize=100)
    button = widget_button(base_ex5, value="Open Splot", $
      event_pro='primus_zspec_splot', $
      xsize=100)
    button = widget_button(base_ex5, value="Plotting Options", $
      event_pro='primus_zspec_splotoptions', $
      xsize=200, uval=1)
    base_ex6 = widget_base(basex2, /row)
    button = widget_button(base_ex6, value="Plot Legend", $
      event_pro='primus_zspec_splotoptions', $
      xsize=200, uval=2)
    exposures = widget_button(base_ex6, value="Show Sub-Exposures", $
      event_pro='zspec_plot_exposures', $
      xs=200)
                                ;  navigation = widget_button(base_ex6, value="Open Navigation Panel", $
                                ;    event_pro='zspec_navigation', xs=200)
    
    
    ;;--Move between sequential objects
    base_ex3 = widget_base(base, /row)   
    back = widget_button(base_ex3, value='Back', uvalue='BACK', xsize=230)
    next = widget_button(base_ex3, value='Next', uvalue='NEXT', xsize=230)
    finish = widget_button(base_ex3, value='Done', uvalue='DONE', xsize=230)
    
    
    
    
    widget_control, base, xoffset=100, yoffset=-100
    widget_control, base, /realize

    ;;--Now that everything is setup, grab the needed states and the
    ;;values for each drawable area
    widget_control, draw_1d_wid, get_value=draw_1d
    draw_1d_idx = draw_1d
    
    
    state = {base : base, $
      maintext : maintext, $    ; Textual widget for object
      draw1d : draw_1d_wid, $   ; widget ids of 1d plot
      draw_1d_idx : draw_1d_idx, $
      zselect : 0, $            ;currently selected z index
      smoothing_select : smoothing_select, $
      redshift_select : redshift_select, $
      redshift_flag : 0, $
      cleanonly : 0, $
      fluxing_select : fluxing_select, $
      model_plot : model_plot, $
      obj_filter: obj_filter}

    
    widget_control, base, set_uvalue=state
    
    ;;--Plot the first spectrum
    ;;----------------------------------------
    
    plotoptions = {fluxing : 1, $
      smoothing : 1, $
      model_plot : 1, $
      fitnum : 0, $
      obj_filter: 0, $
      skysubfile : 0, $
      fullccd : 0, $ 
      showwave : 1, $
      splotvect : 3, $
      mainvect : 0, $
      opposite : 1, $
      chi2models : [1,1,0], $
      chi2colors : [0, 1, 2], $
      chi2norm : 2, $
      chi2linestyle : intarr(3), $
      speccolors : [0, 1, 2, 3], $
      speclinestyle : [2, 2, 0, 0], $
      symsize : 2, $
      showtrace : 0, $
      photcolor : 2, $
      photlinestyle : 8, $
      photfill : 1, $
      highres : 1, $
      highrescolor : 8, $
      highreslinestyle : 0, $
      showphoto : 1, $
      rawwave : 0}
    
    set_widget_control, state
    
    widget_control, /hourglass

    primus_zspec_1d_plot, state
    
    
    xmanager, 'primus_zspec', base
    
    
    
 END
