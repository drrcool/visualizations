PRO set_widget_control, state

    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex
    COMMON zspec_plotoptions, plotoptions

    widget_control, state.fluxing_select, $                                 
      set_droplist_select=plotoptions.fluxing  
    widget_control, state.redshift_select, $                                                             
      set_droplist_select=plotoptions.fitnum                                            
    widget_control, state.smoothing_select, $                                          
      set_droplist_select=plotoptions.smoothing                                                          
    widget_control, state.model_plot, $         
      set_droplist_select=plotoptions.model_plot   
    widget_control, state.obj_filter, $
      set_droplist_select=plotoptions.obj_filter

    
 END
