PRO primus_zspec_selectz, event
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, objindex
    common zspec_plotoptions, plotoptions
    
    widget_control, event.top, get_uvalue=state
    plotoptions.fitnum = event.index
    
    primus_zspec_1d_plot, state
    
 END
