PRO primus_splash_event, event

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

FUNCTION primus_splash
    
    common splash_COMMON, proceed
    
    base = widget_base(/column,title='Welcome')
    title = widget_label(base, value='PRIMUS zspec', font='lucidasans-24')
    text1 = widget_label(base, value='Programmed by Richard Cool')
    text2 = widget_label(base, value='  rcool@astro.princeton.edu  ')
    text3 = widget_label(base, value='Based on DEEP2 zspec')
    blank = widget_label(base, value='  ')
    blank = widget_label(base, value='  ')
    text4 = widget_text(base,xsize=55,ysize=16)


    idlutils_dir = getenv('IDLSPEC1D_DIR')
    primus_dir = getenv('PRIMUS_DATA')
    primus_redux = getenv('PRIMUS_REDUX')
       
    string01 = 'Note:'
    string02 = '-----'
    blank = ''
    string1 = 'This program makes use of a number of ' 
    string2 = 'environment variables.'
    string3 = '  $IDLUTILS_RESULTS = ' + idlutils_dir
    string4 = '  $PRIMUS_DIR   = ' + primus_dir
    string5 = '  $PRIMUS_REDUX = ' + primus_redux
    string6 = 'If these are not correct then please exit the program'
    string7 = 'and set them to their correct values before proceeding.'
    string8 = 'If you need more information please refer to the '
    string9 = 'documentation for this program.'
    
    widget_control, text4, set_value=string01
    widget_control, text4, set_value=string02, /append
    widget_control, text4, set_value=blank, /append
    widget_control, text4, set_value=string1, /append
    widget_control, text4, set_value=string2, /append
    widget_control, text4, set_value=blank, /append
    widget_control, text4, set_value=string3, /append
    widget_control, text4, set_value=string4, /append
    widget_control, text4, set_value=blank, /append
    widget_control, text4, set_value=string5, /append
    widget_control, text4, set_value=string6, /append
    widget_control, text4, set_value=blank, /append
    widget_control, text4, set_value=string7, /append
    widget_control, text4, set_value=blank, /append
    widget_control, text4, set_value=string8, /append
    widget_control, text4, set_value=string9, /append
    done  = widget_button(base, value='Exit zspec', uvalue='EXIT', xsize=60)
    but2  = widget_button(base, value='Continue', uvalue='CONT', xsize=60)
    
    widget_control, base, /realize
    xmanager, 'primus_splash', base
    
  return, proceed
END
