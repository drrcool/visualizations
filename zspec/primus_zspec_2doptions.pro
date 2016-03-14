PRO zspec_2doptions_event, event
	COMMON zspec_plotoptions, plotoptions
	
	widget_control, event.ID, get_uval=uval
	if (uval) eq 1 then widget_control, event.TOP, /destroy
	

end

FUNCTION zspec_fullccd, event
	COMMON sharestate, state
	
	COMMON zspec_plotoptions, plotoptions
	if plotoptions.fullccd eq 0 then plotoptions.fullccd = 1 else $
		plotoptions.fullccd  = 0
	primus_zspec_1d_plot, state
    
	
END	
FUNCTION zspec_showtrace, event
	COMMON sharestate, state

		COMMON zspec_plotoptions, plotoptions
		if plotoptions.showtrace eq 0 then plotoptions.showtrace = 1 else $
			plotoptions.showtrace  = 0
		primus_zspec_1d_plot, state
        

	END
PRO zspec_exp_radio_event, event
	
	COMMON zspec_plotoptions, plotoptions
    COMMON sharestate, state
	
	widget_control, event.ID, get_uval=uval
	plotoptions.skysubfile = uval
	primus_zspec_1d_plot, state
    
	
END

PRO select_2d_display, event
    
    COMMON zspec_plotoptions, plotoptions

     Widget_control, event.TOP, get_uvalue=state
    
    topbase = widget_base(/column, title="Display Options", $
      group_leader=event.top, /modal, xs=300, ys=300)

    label = widget_label(topbase, value='Select Display Options')
   	base1 = widget_base(topbase,  uvalue=result, /nonexclusive)
	button1 = widget_button(base1, Value="Fullccd", event_func='zspec_fullccd')
	widget_control, button1, set_button=(plotoptions.fullccd)
	button2 = widget_button(base1, Value="Show Trace", event_func='zspec_showtrace')
	widget_control, button2, set_button=(plotoptions.showtrace)
		
    button = widget_button(topbase, value="Done", event_pro='zspec_2doptions_event', $
      uvalue=1)
    
    widget_control, topbase, /realize
    xmanager, 'zspec_2doptions', topbase 
    
 END

PRO select_2d_exposure, event
	
	COMMON zspec_twod_data, skysubfiles, currentfile, currentccd, skysubimage, skymask, skynight, $
		waveimage, showwave, pixmask, badpixfiles, skyextract, skyextfiles
	COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, $
	                fullindex, subindex, cachererun, errorcode, cachenight
	
    
    COMMON zspec_plotoptions, plotoptions
    
    Widget_control, event.TOP, get_uvalue=state
    
    topbase = widget_base(/column, title="Select Exposure to Display", $
      xs=300, ys=300)
    
    label = widget_label(topbase, value='Select 2d Exposure to Display:')
    base2 = widget_base(topbase, /column, /exclusive, /frame)
	exp = primus_exposures(cachenight, cachemask)
	for iexp = 0, n_elements(exp) -1 do begin
		button = widget_button(base2, Value=exp[iexp], $
			event_pro='zspec_exp_radio_event', uvalue=iexp)
		widget_control, button, set_button=(plotoptions.skysubfile eq iexp)
	endfor
	
   
    button = widget_button(topbase, value="Done", event_pro='zspec_2doptions_event', $
      uvalue=1)
    
    widget_control, topbase, /realize
    xmanager, 'zspec_2doptions', topbase 
 END

    
PRO primus_zspec_2doptions, event
    COMMON sharestate, state
    
    COMMON zspec_plotoptions, plotoptions
    
    
    Widget_control, event.TOP, get_uvalue=state
    
    topbase = widget_base(/column, title="Two-d Options", $
      group_leader=event.top, /modal, xs=300, ys=300)
    button1 = widget_button(topbase, Value="Select Exposure to Display", $
      xsize=300, event_pro='select_2d_exposure')
    button2 = widget_button(topbase, value="Change Display Options", $
      xsize=300, event_pro='select_2d_display')
    
    
    button = widget_button(topbase, value="Done", event_pro='zspec_2doptions_event', $
      uvalue=1)
    
    widget_control, topbase, /realize
    xmanager, 'zspec_2doptions_event', topbase 
    if (xregistered('atv')) then primus_zspec_skysub, state
	
        
    
 END
