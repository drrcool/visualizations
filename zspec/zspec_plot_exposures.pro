;;-- Use this code to read all the exposures and plot them
PRO primus_exposure_event, event
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex, subindex
    COMMON zspec_plotoptions, plotoptions
    COMMON sharestate, state
    
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
        
	      return
		end
	endcase
end



        

Pro select_pair, event
	COMMON sharestate, state
	COMMON exp_plotoptions, plotoptions

	widget_control, event.ID, get_uval=uval
	if uval eq plotoptions.pair then replot = 0 else replot=1
	plotoptions.pair = uval
	
	
	if replot then primus_zspec_1d_plot, state

	


END

    PRO select_exp_thickness, event

		COMMON sharestate, state

		;;-- Here I am using the catch function to make sure that the input was actually something compatible 
	 	;; with float.  I got this example from 
		;;http://www.dfanning.com/misc_tips/conversion_errors.html
		;; It seems to work, but I have to say I am not 100% sure how.

		catch, errorstatus

		widget_control, event.id, get_uvalue=uval
	    widget_control, uval, get_value=destination

		if errorstatus ne 0 then begin
			catch, /cancel
			bad_io:
			txt = "You did not enter a proper number.  No update"
			junk = dialog_message(txt, /error, /center)
			destination = 1.0
		endif
		; Set up file I/O error handling.
	    ON_IOError, bad_io

		!P.thick = float(destination)
		!X.thick = !P.thick
		!Y.thick = !X.thick

		primus_zspec_1d_plot, state



	END
    
  
PRO select_exp_symsize, event

	COMMON exp_plotoptions, plotoptions
	COMMON sharestate, state

	;;-- Here I am using the catch function to make sure that the input was actually something compatible 
 	;; with float.  I got this example from 
	;;http://www.dfanning.com/misc_tips/conversion_errors.html
	;; It seems to work, but I have to say I am not 100% sure how.

	catch, errorstatus

	widget_control, event.id, get_uvalue=uval
    widget_control, uval, get_value=destination

	if errorstatus ne 0 then begin
		catch, /cancel
		bad_io:
		txt = "You did not enter a proper number.  No update"
		junk = dialog_message(txt, /error, /center)
		destination = plotoptions.symsize
	endif
	; Set up file I/O error handling.
    ON_IOError, bad_io

	plotoptions.symsize = float(destination)
	primus_zspec_1d_plot, state



END  
    
PRO toggle_exp_speccolor, event
	COMMON sharestate, state

    COMMON exp_plotoptions, po
    widget_control, event.ID, get_uval=uval
  	po.color[uval-1] = event.index
	
	
	primus_zspec_1d_plot, state

 END
PRO toggle_rawwave, event
	COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval
	if po.rawwave eq 0 then po.rawwave = 1 else po.rawwave = 0

	primus_zspec_1d_plot, state

 END
PRO toggle_exp_specline, event
	COMMON sharestate, state

    COMMON exp_plotoptions, po
    widget_control, event.ID, get_uval=uval

  	po.line[uval-1] = event.index	
	
	primus_zspec_1d_plot, state

 END


PRO zspec_splot_exposures
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, $
      fullindex, subindex, cachererun, errorcode, cachenight
    common zspec_exposures, allext, out
    common zspec_plotoptions, plotoptions
	common exp_plotoptions, expoptions

    fileroots = primus_exposures(cachenight, cachemask, /nocoadd)
    extfiles = '$PRIMUS_REDUX/' + cachererun + '/' + cachenight + '/' + fileroots + '.extract.fits.gz'
    nfiles = n_elements(extfiles)

    reread = 0
    if n_elements(allext) gt 0 then begin
       if allext[0].mask ne cachemask or $
         allext[0].night ne cachenight or $
         allext[0].rerun ne cachererun then rerun = 1
    endif


    if n_elements(allext) eq 0 or reread then begin

       for ifile = 0, nfiles -1 do begin
          
          ext0 = mrdfits(extfiles[ifile], 1) 
          spherematch, ext0.ra, ext0.dec, ext.ra, ext.dec, 1.0/3600., m1, m2, dist
		  ext0 = ext0[m1[sort(m2)]]


          add = {fileroot : fileroots[ifile], $
            index : 0, $
            ifile : ifile, $
            mask : cachemask, $
            night : cachenight, $
            rerun : cachererun}
          add = replicate(add, n_elements(ext0))
          add.index = indgen(n_elements(ext0))
          ext0 = struct_addtags(ext0, add)
          
          
          
          if ifile eq 0 then allext = ext0 else allext = [allext, ext0]
          
       endfor
    endif

    keep = where(allext.index eq objindex[0], nkeep)
    pair = expoptions.pair
	if n_elements(out) gt 0 then begin
		if objindex[0] ne out[0].objindex or $
		   plotoptions.fluxing ne out[0].fluxing or $
		   pair ne out[0].pair then reread = 1
	endif else reread = 1
	
    for i = 0, nkeep-1 do begin
       
       out0 = zspec_perform_fluxing(allext[keep[i]], pair, photoinfo=photoinfo[objindex], /trim)
       add = replicate({objindex:objindex, fluxing:plotoptions.fluxing, pair:pair}, n_elements(out0))
     out0 = struct_addtags(out0, add)
  if i eq 0 then out = out0 else out = [out, out0]

   
    endfor

    splot, out.wave, out.flux, xrange=[4500, 9500], /xs, /ys, /nodata
    color = strlowcase(primus_chi2colors())
	color = color[expoptions.color]
	sym = expoptions.line
	k = where(sym eq 0, ct)
	if ct gt 0 then sym[k] = 10
    for i = 0, n_elements(out) -1 do $
      soplot, out[i].wave, out[i].flux, ps=sym[i+1], color=djs_icolor(color[i+1]), symsize=expoptions.symsize
   
	ext0 = zspec_perform_fluxing(ext[objindex], pair, photoinfo=photoinfo[objindex])
	soplot, ext0.wave, ext0.flux, ps=sym[0], color=djs_icolor(color[0]), symsize=expoptions.symsize


	

 END

PRO zspec_plot_exposures, event
    
	COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, $
      fullindex, subindex, cachererun, errorcode, cachenight
    COMMON zspec_plotoptions, plotoptions
	COMMON exp_plotoptions, expoptions
	COMMON sharestate, state
	common expshare, topbase


    widget_control, event.top, get_uvalue=state
	
    expfiles = primus_exposures(cachenight, cachemask, /nocoadd)
    expfiles = [cachemask, expfiles]
	nexp = n_elements(expfiles)
	values = ["Solid", "Dotted", "Dashed", "Dot-Dashed", "Dot-Dot-Dot-Dash"]
	values1 = ["Connected", '+', '*', '.', 'Diamond', 'Triangle', 'Square', 'X']
	colors = primus_chi2colors()
	
	if n_elements(expoptions) eq 0 then $
		expoptions = {color : indgen(10) mod n_elements(colors), line : indgen(10) mod n_elements(values1), $
		symsize : 2, pair:1, showerror:1}


    ;;--Turn off splotwindow
    plotoptions.splotvect = 3
    
    topbase = widget_base(/column, title='primus_exposure', xs=400, ys=700)


	
	sbase0 = widget_base(topbase, /row)
	label = widget_label(sbase0, value='', xs=100)
	label = widget_label(sbase0,value='Color', xs=100, /frame)
	label = widget_label(sbase0, value='Plotstyle', xs=150, /frame)
	
	for iexp = 0, nexp -1 do begin
		sbase = widget_base(topbase, /row)
		label = widget_label(sbase, value=expfiles[iexp], xs=100)
		color = widget_droplist(sbase, value=colors, $
			event_pro='toggle_exp_speccolor', xs=100, /frame, uvalue=iexp+1)
		line = widget_droplist(sbase, value=values1, $
			event_pro='toggle_exp_specline', xs=150, /frame, uvalue=iexp+1)
		widget_control, color, set_droplist=(expoptions.color[iexp])
		widget_control, line, set_droplist=(expoptions.line[iexp])
	endfor

	rbase = widget_base(topbase, /row)
	label = widget_label(rbase, value="Set Symbol Size", xsize=100)
	otext = widget_text(rbase, xsize=5, uvalue=0, event_pro='select_exp_symsize', /editable, $
		value=otext)
	button=widget_button(rbase, value="Set Size", event_pro='select_exp_symsize', xsize=100, uvalue=otext)
;	rbase1 = widget_base(topbase, /row);
;	label = widget_label(rbase1, value="Set Line Thickness", xsize=100)
;	otext1 = widget_text(rbase1, xsize=5, uvalue=0, event_pro='select_exp_thickness', /editable, $
;		value=otext1)
;	button=widget_button(rbase1, value="Set Thick", event_pro='select_exp_thickness', xsize=100, uvalue=otext1)
;
	rbase2a = widget_base(topbase, /row)
	label = widget_label(rbase2a, Value="Slit to Plot:", xsize=100)
	
	rbase2 = widget_base(rbase2a, /row, /exclusive)
	button1 = widget_button(rbase2, Value="Slit 1:", $
      event_pro='select_pair', uvalue=1, xs=100)
	button2 = widget_button(rbase2, Value="Slit 2:", $
    	event_pro='select_pair', uvalue=2, xs=100)
	widget_control, button1, set_button=(expoptions.pair eq 1)
	widget_control, button2, set_button=(expoptions.pair eq 2)
	
	ebase = widget_base(topbase, /colum, /nonexclusive)
	fillbutton=widget_button(ebase, value="Show Unshifted Wavelengths:", event_pro='toggle_rawwave',$;
		xsize=100)
	widget_control, fillbutton, set_button=plotoptions.rawwave
	base4 = widget_base(topbase, /row)
	 values=['Counts / s / Ang', 'Erg / s / cm2 / Ang']
	fluxing_select = widget_droplist(base4, value=values, $
      title='Fluxing:', $
      event_pro='primus_fluxing_select', /dynamic_resize, /frame)
	widget_control, fluxing_select, set_droplist=plotoptions.fluxing
    base_ex3 = widget_base(topbase, /column)   
    back = widget_button(base_ex3, value='Back', uvalue='BACK', xsize=230)
    next = widget_button(base_ex3, value='Next', uvalue='NEXT', xsize=230)
    finish = widget_button(base_ex3, value='Done', uvalue='DONE', xsize=230)

 
    widget_control, topbase, xoffset=100, yoffset=-100
    widget_control, topbase, /realize
    

    zspec_splot_exposures

    xmanager, 'primus_exposure', topbase
    
    return
    
    
    
 END

	
 

 
 
