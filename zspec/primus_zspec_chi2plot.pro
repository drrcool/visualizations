PRO primus_zspec_chi2_plot, event, splot=splot
	
	
	
	COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex
    COMMON zspec_plotoptions, plotoptions

    ;;--setup the device
	widget_control, event.top, get_uvalue=state
    wset, state.draw_1d_idx[0]
    device, decompose=0
    color=['red','blue']
    sym=[2,4]

	if n_elements(splot) eq 0 then splot = 0

	if plotoptions.mainvect eq 1 then begin
		primus_zspec_chi2doplot, event
	endif 
	if plotoptions.splotvect eq 1 then begin
		primus_zspec_chi2doplot, event, /splot
	endif
	
		
	
	
END

	
