PRO primus_zspec_jump, event
	
	COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex, subindex
    COMMON zspec_plotoptions, plotoptions
	
	
	widget_control, event.id, get_uvalue=uval
	widget_control, uval, get_value=destination
	widget_control, event.top, get_uvalue=state

	;;--format the destination slit name
	destination = string(destination)
	if strmid(destination, 0, 2) ne 'ob' then destination = 'ob' + string(destination, format='(i5.5)')

	;;--Check to be sure this slit exists
	kmatch = where(strtrim(ext.name, 2) eq destination, ct)
	if ct eq 0 then begin
		mess_txt = string( $
			"Sorry, but that slit doesn't appear to exist on this mask. Please double check the object number" + $
			" and try again")
		res = dialog_message(mess_txt, /center)
		return
	endif
	
	
	;;--Now check that its in this set
	if max(fullindex eq kmatch[0]) eq 0 then begin
		mess_txt = string("Sorry, but that slit isn't in your current object subset")
		res = dialog_message(mess_txt, /center)
		return
	endif
	
	objindex = fullindex[where(fullindex eq kmatch[0])]
	subindex = where(fullindex eq kmatch[0])
	widget_control, /hourglass
	primus_zspec_1d_plot, state
	primus_zspec_showtext, state
	
	
	
END
		
					
	
	
