PRO primus_fluxing_select, event
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, objindex
    common zspec_plotoptions, plotoptions
    COMMON sharestate, state
	
    plotoptions.fluxing = event.index
    
    primus_zspec_1d_plot, state
    
    
 END
