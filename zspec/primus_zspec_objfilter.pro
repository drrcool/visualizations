PRO primus_zspec_objfilter, event
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, objindex, fullindex, subindex
    common zspec_plotoptions, plotoptions    
    
    widget_control, event.top, get_uvalue=state
    plotoptions.obj_filter = event.index
    
    if plotoptions.obj_filter eq 0 then begin
       fullindex = indgen(n_elements(ext))
       subindex = 0
       objindex = 0
    endif else if plotoptions.obj_filter eq 1 and n_elements(oned) gt 0 then begin
       fullindex = where(oned.zgrid_gal[10] gt 0)
       subindex = 0
       objindex = fullindex[0]
    endif else if plotoptions.obj_filter eq 1 and n_elements(oned) eq 0 then begin
	 	error_txt = "This mask has no oned information loaded.  I cannot do that, Dave."
        res = dialog_message(error_txt, /error, /center)
		plotoptions.obj_filter=0
	endif
	
    primus_zspec_1d_plot, state
    
 END

       
      
