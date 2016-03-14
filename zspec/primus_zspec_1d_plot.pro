PRO primus_zspec_1d_plot, state, splot=splot, noexp=noexp
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex
    COMMON zspec_plotoptions, plotoptions
    
    ;;--setup the device
   

	if n_elements(splot) eq 0 then splot = 0
	if plotoptions.mainvect eq 0 and splot eq 0 then begin
		primus_1d_doplot, state
	endif 
	if plotoptions.splotvect eq 0 and splot eq 1 then begin
		primus_1d_doplot, state, /splot
	endif
	
	if plotoptions.mainvect eq 1 and splot eq 0 then begin
		primus_zspec_chi2doplot, state
	endif
	if plotoptions.splotvect eq 1 and splot eq 1 then begin
		primus_zspec_chi2doplot, state, /splot
	endif
	
	
	if n_elements(noexp) eq 0 then noexp = 0
	
	if (xregistered('atv')) then primus_zspec_skysub, state
	if splot eq 0 and  (xregistered('splot')) then primus_zspec_1d_plot, state, /splot, /noexp
    if (xregistered('primus_exposure')) and noexp eq 0 then zspec_splot_exposures
        primus_zspec_showtext, state
	
 END

    
       
       
       
      
    
