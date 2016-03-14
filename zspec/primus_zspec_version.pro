PRO primus_zspec_version_event, event
  widget_control, event.top, /destroy
END


PRO primus_zspec_version, event

  base  = widget_base(/column,title='PRIMUS ZSPEC',group_leader=event.top)
  title = widget_label(base, value='PRIMUS ZSPEC Alpha (v0_1)', font='lucidasans-24')
  text1 = widget_label(base, value='Programmed by: Richard Cool')
  text2 = widget_label(base, value='  rcool@astro.princeton.edu ')
  text3 = widget_label(base, value='Based Heavily on the DEEP2 zSPEC code')

  done  = widget_button(base, value='Close', xsize=60)

  widget_control, base, /realize
  xmanager, 'primus_zspec_version', base

END
