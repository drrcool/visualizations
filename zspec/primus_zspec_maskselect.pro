PRO primus_zspec_maskselect, event
	
	COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex,$
 		subindex, cachererun, errorcode, cachenight
    COMMON zspec_plotoptions, plotoptions
	
	
	widget_control, event.id, get_uvalue=uval
	widget_control, uval, get_value=destination
	widget_control, event.top, get_uvalue=state

 	if cachemask ne strtrim(destination, 2) then begin
	  destination = strtrim(destination[0], 2)
	  delvarx, ext
	  delvarx, oned
	delvarx, slits
	delvarx, photoinfo
	
	  primus_read, destination, cachererun, $
         ext=ext, oned=oned, slits=slits, photoinfo=photoinfo, errorcode=errorcode, night=night
    
		keep = where(ext.type eq 'SLIT')
		ext = ext[keep]
		oned = oned[keep]
		slits = slits[keep]
		photoinfo = photoinfo[keep]
		
   cachemask = destination
       cachenight = night
       objindex = 0
       subindex= 0
       fullindex = indgen(n_elements(ext))
	   plotoptions.obj_filter = 0
	 
	
		if (errorcode and 1) gt 0 or $	
		  (errorcode and 4) gt 0 then begin
			error_txt = "That extraction doesn't seem to exist for the specified rerun."
			res = dialog_message(error_txt, /error, /center)
			return
		endif

		if (errorcode and 2) gt 0 then begin
			proceed=primus_nooned()
		endif
	
	
	
    endif
	set_widget_control, state

	widget_control, /hourglass
	primus_zspec_1d_plot, state
	primus_zspec_showtext, state
	
	
	
END
		
					
	
	
