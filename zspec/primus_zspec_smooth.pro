PRO primus_zspec_smooth, event
    
    ;;-- Toggle Smoothing
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, objindex
    common zspec_plotoptions, plotoptions
    
    widget_control, event.top, get_uvalue=state
    widget_control, event.id, get_uval=uval
    
    plotoptions.smoothing = event.index
   
    primus_zspec_1d_plot, state
    
    
 END
