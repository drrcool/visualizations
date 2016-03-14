PRO primus_zspec_event, event
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex, subindex
    COMMON zspec_plotoptions, plotoptions
	common expshare, exp_base
    common specshare, specbase
	common navbase, nav_base
	common navstate, navstate
	
    if n_elements(navstate) eq 0 then widget_control, event.TOP, get_uvalue=state else state = navstate
    widget_control, event.ID, get_uvalue=uval
    nslit = n_elements(fullindex)
    
    
    CASE uval of 
       'NEXT': begin
          
          ;;--If you aren't at the last slit, then increment,
          ;;otherwise, return.
          if (subindex lt nslit -1) then begin
             subindex++ 
             objindex = fullindex[subindex]
          endif else begin
             res=dialog_message("No more slits to view", $
               dialog_parent=event.TOP)
             return
          endelse
          
          
          set_widget_control, state
          widget_control, /hourglass
          
          primus_zspec_1d_plot, state
          primus_zspec_showtext, state
          
       END
       'BACK' : BEGIN
          
          ;;--If you aren't at the last slit, then increment,
          ;;otherwise, return.
          if (subindex gt  0) then begin
             subindex-- 
             objindex = fullindex[subindex]
          endif else begin
             res=dialog_message("No more slits to view", $
               dialog_parent=event.TOP)
             return
          endelse
          
          
          set_widget_control, state
          widget_control, /hourglass
          
          primus_zspec_1d_plot, state
          primus_zspec_showtext, state
          
       END
       
       'DONE' : BEGIN
          widget_control, event.TOP, /destroy
          if (xregistered('splot')) then splot_shutdown
          if (xregistered('atv')) then atv_shutdown
		  if (xregistered('primus_exposure')) then widget_control, exp_base, /destroy
		  if (xregistered('zspec_splotoptions')) then widget_control, specbase, /destroy
		  if (xregistered('zpsec_nav')) then widget_control, nav_base, /destroy
          return
       END
       
	'CLOSE' : BEGIN
		widget_control, nav_base, /destroy
	END
	
       
       
    ENDCASE
    
 END

    
    
    
    
