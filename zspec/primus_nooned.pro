PRO primus_nooned_event, event

  COMMON splash_COMMON, proceed

  widget_control, event.id, get_uvalue=uval
  IF(uval EQ 'EXIT') THEN BEGIN
    proceed = 0
    widget_control, event.TOP, /destroy
  ENDIF ELSE BEGIN
    proceed = 1
    widget_control, event.TOP, /destroy
  ENDELSE

END

FUNCTION primus_nooned
    
    common splash_COMMON, proceed
    
    base = widget_base(/column,title='1d ERROR')
  	string1 = "This mask doesn't apper to have oned information"
	string2 = "You can continue, but no oned data will be used."
	string3 = "continue?"
	blank =''
    text4 = widget_text(base,xsize=55,ysize=16)

  	widget_control, text4, set_value=string1
    widget_control, text4, set_value=string2, /append
	widget_control, text4, set_value=string3, /append
    widget_control, text4, set_value=blank, /append

    but2  = widget_button(base, value='Continue', uvalue='CONT', xsize=60)
    
    widget_control, base, /realize
    xmanager, 'primus_nooned', base
    
  return, proceed
END
