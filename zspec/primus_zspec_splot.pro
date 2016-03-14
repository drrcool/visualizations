PRO primus_zspec_splot, event
	
	common zspec_plotoptions, plotoptions

  	widget_control, event.TOP, get_uvalue=state
  
	if plotoptions.splotvect eq 3 then plotoptions.splotvect = 0
	primus_zspec_1d_plot, state, /splot
	
	
END
