PRO zspec_splotoptions_event, event
	COMMON zspec_plotoptions, plotoptions
	
	widget_control, event.ID, get_uval=uval
	if (uval) eq 1 then widget_control, event.TOP, /destroy
	

end

Pro zspec_splot_radio_event, event
	COMMON sharestate, state
	
	COMMON zspec_plotoptions, plotoptions
    
	widget_control, event.ID, get_uval=uval
	plotoptions.splotvect = uval-1
	primus_zspec_1d_plot, state
	
	
END
PRO zspec_main_radio_event, event
	COMMON sharestate, state
	
	COMMON zspec_plotoptions, plotoptions
    
	widget_control, event.ID, get_uval=uval
	plotoptions.mainvect = uval-1

	primus_zspec_1d_plot, state
	
	
END
PRO zspec_opposite, event
	;;When clicked, rotate values of the plotopions.opposite button
	;;If set, opposite will automatically set the options for the other window
	COMMON sharestate, state
	
	common zspec_plotoptions, plotoptions
	if plotoptions.opposite eq 0 then $
		plotoptions.opposite = 1 else $
		plotoptions.opposite = 0
	
	primus_zspec_1d_plot, state
		
END

PRO zspec_setopposite, opt, splot=splot, main=main
	COMMON sharestate, state
	
	if opt.opposite eq 0 then return
	
	;;-- If splot is set, then that is where the command was issued from.
	;;-- Assume the splot settings are true and set the main accordingly
	if keyword_set(splot) then begin
		if opt.splotvect eq 0 then opt.mainvect = 1
		if opt.splotvect eq 1 then opt.mainvect = 0
	endif
	;;-- Now same logic for main
	if keyword_set(main) then begin
		if opt.mainvect eq 0 then opt.splotvect = 1
		if opt.mainvect eq 1 then opt.splotvect = 0
	endif
	
	primus_zspec_1d_plot, state
	
	return
	
END

	
	

PRO select_splot_data, event
    
    COMMON zspec_plotoptions, plotoptions

     Widget_control, event.TOP, get_uvalue=state
    
    topbase = widget_base(/column, title="Plotting Options", $
      group_leader=event.top, /modal, xs=300, ys=300)

    label = widget_label(topbase, value='Data to Show in Splot Window:')
    base1 = widget_base(topbase, /column, /exclusive, /frame)
    button1 = widget_button(base1, Value="Spectrum", $
      event_pro='zspec_splot_radio_event', uvalue=1)
    button2 = widget_button(base1, Value="Chi-squared",  $
      event_pro='zspec_splot_radio_event', uvalue=2)
    button3 = widget_button(base1, Value='None', $
      event_pro='zspec_splot_radio_event', uvalue=3)
    widget_control, button1, set_button=(plotoptions.splotvect eq 0)
    widget_control, button2, set_button=(plotoptions.splotvect eq 1)
    widget_control, button3, set_button=(plotoptions.splotvect eq 2)
    base3 = widget_base(topbase, /column, /nonexclusive, /frame)
	button7 = widget_button(base3, value='Show opposite in Main Window', $
	   event_pro='zspec_opposite')
	widget_control, button7, set_button=(plotoptions.opposite eq 1)
    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)
    
    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase 
	zspec_setopposite, plotoptions, /splot
	

    
 END

PRO select_main_data, event
    
    
    COMMON zspec_plotoptions, plotoptions
    
    Widget_control, event.TOP, get_uvalue=state
    
    topbase = widget_base(/column, title="Plotting Options", $
      group_leader=event.top, /modal, xs=300, ys=300)
    
    label = widget_label(topbase, value='Data to Show in Main Window:')
    base2 = widget_base(topbase, /column, /exclusive, /frame)
     button4 = widget_button(base2, Value='Spectrum', $
      event_pro='zspec_main_radio_event', uvalue=1)
    button5 = widget_button(base2, value='chi2-squared', $
      event_pro='zspec_main_radio_event', uvalue=2)
    button6 = widget_button(base2, value='None', $
      event_pro='zspec_main_radio_event', uvalue=3)
    widget_control, button4, set_button=(plotoptions.mainvect eq 0)
    widget_control, button5, set_button=(plotoptions.mainvect eq 1)
    widget_control, button6, set_button=(plotoptions.mainvect eq 2)
    base3 = widget_base(topbase, /column, /nonexclusive, /frame)
	button7 = widget_button(base3, value='Show opposite in Splot Window', $
	   event_pro='zspec_opposite')
	widget_control, button7, set_button=(plotoptions.opposite eq 1)
    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)
    
    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase 
	zspec_setopposite, plotoptions, /main
	

	
 END

PRO toggle_model, event
	COMMON sharestate, state
	
	COMMON zspec_plotoptions, po
	widget_control, event.ID, get_uval=uval
	
	if po.chi2models[uval-2] eq 0 then $
	   po.chi2models[uval-2] = 1 else $
	   po.chi2models[uval-2] = 0
	primus_zspec_1d_plot, state
	
	
End




PRO select_chi2_models, event
	
	COMMON zspec_plotoptions, plotoptions
    
	;;--Choose which of the chi2 models should be plotted
	widget_control, event.top, get_uvalue=state
	topbase=widget_base(/column, title="Select Models to be Plotted",  xs=300, ys=300)
	base = widget_base(topbase, /column, /nonexclusive, title='Select Models to be Plotted')
	button1 = widget_button(base, Value='Photoz Galaxy', uvalue=2, event_pro='toggle_model')
	button2 = widget_button(base, Value='Non-Photoz Galaxy', uvalue=3, event_pro='toggle_model')
	button3 = widget_button(base, Value='AGN', uvalue=4, event_pro='toggle_model')
	widget_control, button1, set_button=(plotoptions.chi2models[0] eq 1)
	widget_control, button2, set_button=(plotoptions.chi2models[1] eq 1)
	widget_control, button3, set_button=(plotoptions.chi2models[2] eq 1)
	button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)

    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase

END

PRO toggle_norm, event
    COMMON sharestate, state
	
    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval
    
    Po.chi2norm = [uval-2]
    primus_zspec_1d_plot, state
	
     
 end



PRO select_chi2_norm, event
    
    COMMON zspec_plotoptions, po
    
    ;;--Choose how to normalize the chi2 grids
    Widget_control, event.top, get_uvalue=state
    topbase=widget_base(/column, title="Select How to Normalize Chi2",  xs=300, ys=300)
    base = widget_base(topbase, /column, /exclusive, title='Select How to Scale')
    button1 = widget_button(base, Value='Square Root from Plotted Global Minimum', uvalue=2, event_pro='toggle_norm')
    button2 = widget_button(base, Value='Linear from Plotted Global Minimum', uvalue=3, event_pro='toggle_norm')
    button3 = widget_button(base, value='Square Root - Each Grid Normalized', uvalue=4, event_pro='toggle_norm')
    button4 = widget_button(base, value='Linear - Each Grid Normalized', uvalue=5, event_pro='toggle_norm')
    widget_control, button1, set_button=(po.chi2norm eq 0)
    widget_control, button2, set_button=(po.chi2norm eq 1)
    widget_control, button3, set_button=(po.chi2norm eq 2)
    widget_control, button4, set_button=(po.chi2norm eq 3)
    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)

    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase
  
    
 END

PRO toggle_color, event
    COMMON sharestate, state
	
    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval

    po.chi2colors[uval-2] = event.index
    primus_zspec_1d_plot, state
		
    
 END
PRO select_photfill, event
    COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval
	
	if po.photfill eq 0 then $
	   po.photfill = 1 else $
	   po.photfill = 0
    primus_zspec_1d_plot, state


 END
PRO select_highres, event
	 COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval

	if po.highres eq 0 then $
	   po.highres = 1 else $
	   po.highres = 0
    primus_zspec_1d_plot, state


 END
PRO select_showphoto, event
	 COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval

	if po.showphoto eq 0 then $
	   po.showphoto = 1 else $
	   po.showphoto = 0
    primus_zspec_1d_plot, state


 END
PRO toggle_line, event
    COMMON sharestate, state
	
    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval


    	po.chi2linestyle[uval-2] = event.index
    	primus_zspec_1d_plot, state
    
 END
 
PRO select_thickness, event

	COMMON zspec_plotoptions, plotoptions
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

	!P.thick = float(destination)
	!X.thick = !P.thick
	!Y.thick = !X.thick
	
	primus_zspec_1d_plot, state



END
PRO toggle_speccolor, event
	COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval

	if uval lt 6 then begin
    	po.speccolors[uval-2] = event.index
	endif else if uval eq 6 then begin
		po.photcolor = event.index
	endif else if uval eq 7 then begin
		po.highrescolor = event.index
	endif
	
	
	primus_zspec_1d_plot, state

 END

PRO toggle_specline, event
	COMMON sharestate, state

    COMMON zspec_plotoptions, po
    widget_control, event.ID, get_uval=uval

	if uval lt 6 then begin
    	po.speclinestyle[uval-2] = event.index
	endif else if uval eq 6 then begin
		valu = [0, 3, 4, 5, 8]
		po.photlinestyle = valu[event.index]
	endif else if uval eq 7 then begin
		po.highreslinestyle = event.index
	endif
	
	
	primus_zspec_1d_plot, state

 END  
  
PRO select_chi2_line, event
    
    COMMON zspec_plotoptions, po
    ;;--Choose what Colors to use
    widget_control, event.top, get_uvalue=state
    topbase=widget_base(/column, title="What linestyles should be used?", xs=500, ys=300)

    
    values = ["Solid", "Dotted", "Dashed", "Dot-Dashed", "Dot-Dot-Dot-Dash"]
colors = primus_chi2colors()
	sbase0 = widget_base(topbase, /row)
	label = widget_label(sbase0, value='', xs=100)
	label = widget_label(sbase0, value='Color', /frame, xs=100)
	label = widget_label(sbase0, value='Linestyle', /frame, xs=150)

    sbase1 = widget_base(topbase, /row)
  label = widget_label(sbase1, value="Photoz Gal:", xs=100)
  color1 = widget_droplist(sbase1, value=colors, $
      event_pro='toggle_color', xs=100, /frame, uvalue=2)
    line1 = widget_droplist(sbase1, value=values, $
      event_pro='toggle_line', xs=150, /frame, uvalue=2)


	sbase2 = widget_base(topbase, /row)
	label = widget_label(sbase2, value='Non-Photoz Gal:', xs=100)
  color2 = widget_droplist(sbase2, value=colors, $
      event_pro='toggle_color', xs=100, /frame, uvalue=3)
  line2 = widget_droplist(sbase2, value=values, $
      event_pro='toggle_line', xs=150, /frame, uvalue=3)

	sbase3 = widget_base(topbase, /row)
  label = widget_label(sbase3, value='AGN:', xs=100)
  color3 = widget_droplist(sbase3, value=colors, $
    event_pro='toggle_color', xs=100, /frame, uvalue=4)
  line3 = widget_droplist(sbase3, value=values, $
      event_pro='toggle_line', xs=150, /frame, uvalue=4)
	

    
    widget_control, line1, set_droplist=po.chi2linestyle[0]
    widget_control, line2, set_droplist=po.chi2linestyle[1]
    widget_control, line3, set_droplist=po.chi2linestyle[2]
    
    widget_control, color1, set_droplist=po.chi2colors[0]
    widget_control, color2, set_droplist=po.chi2colors[1]
    widget_control, color3, set_droplist=po.chi2colors[2]
    
    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)

    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase
    
    
 END  



PRO select_symsize, event

	COMMON zspec_plotoptions, plotoptions
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


PRO select_spec_line, event

	common specshare, topbase
    COMMON zspec_plotoptions, po
    ;;--Choose what Colors to use
    widget_control, event.top, get_uvalue=state
    topbase=widget_base(/column, title="zspec_splotoptions",  $
       xs=400, ys=600)


    values = ["Solid", "Dotted", "Dashed", "Dot-Dashed", "Dot-Dot-Dot-Dash"]
	values1 = ["Connected", '+', '*', '.', 'Diamond', 'Triangle', 'Square', 'X']
	colors = primus_chi2colors()
	
	sbase0 = widget_base(topbase, /row)
	label = widget_label(sbase0, value='', xs=100)
	label = widget_label(sbase0,value='Color', xs=100, /frame)
	label = widget_label(sbase0, value='Plotstyle', xs=150, /frame)
	
	
    sbase1 = widget_base(topbase, /row)
	label = widget_label(sbase1, value='Data 1:', xs=100)
	color1 = widget_droplist(sbase1, value=colors, $
      event_pro='toggle_speccolor', xs=100, /frame, uvalue=2)
	line1 = widget_droplist(sbase1, value=values1, $
         event_pro='toggle_specline', xs=150, /frame, uvalue=2)

    sbase2 = widget_base(topbase, /row)
	label = widget_label(sbase2, value='Data 2:', xs=100)
    color2 = widget_droplist(sbase2, value=colors, $
      event_pro='toggle_speccolor', xs=100, /frame, uvalue=3)
  	line2 = widget_droplist(sbase2, value=values1, $
    	 event_pro='toggle_specline', xs=150, /frame, uvalue=3)

    sbase3 = widget_base(topbase, /row)
	label = widget_label(sbase3, value='Model 1:', xs=100)
    color3 = widget_droplist(sbase3, value=colors, $
          	event_pro='toggle_speccolor', xs=100, /frame, uvalue=4)
  	line3 = widget_droplist(sbase3, value=values, $
    	event_pro='toggle_specline', xs=150, /frame, uvalue=4)

    sbase4 = widget_base(topbase, /row)
	label = widget_label(sbase4, value='Model 2:', xs=100)
  	color4 = widget_droplist(sbase4, value=colors, $
    event_pro='toggle_speccolor', xs=100, /frame, uvalue=5)
	line4 = widget_droplist(sbase4, value=values, $
  		 event_pro='toggle_specline', xs=150, /frame, uvalue=5)
   
    sbase4a = widget_base(topbase, /row)
	label = widget_label(sbase4a, value='High Res:', xs=100)
  	color4a = widget_droplist(sbase4a, value=colors, $
    event_pro='toggle_speccolor', xs=100, /frame, uvalue=7)
	line4a = widget_droplist(sbase4a, value=values, $
  		 event_pro='toggle_specline', xs=150, /frame, uvalue=7)


	value2 = ['Circle', 'Star', 'Up Triangle','Down Triangle', 'Square']
 	sbase5 = widget_base(topbase, /row)
	label = widget_label(sbase5, value='Photometry', xs=100)
  	color5 = widget_droplist(sbase5, value=colors, $
    event_pro='toggle_speccolor', xs=100, /frame, uvalue=6)
	line5 = widget_droplist(sbase5, value=value2, $
  		 event_pro='toggle_specline', xs=150, /frame, uvalue=6)



    widget_control, color1, set_droplist=po.speccolors[0]
    widget_control, color2, set_droplist=po.speccolors[1]
    widget_control, color3, set_droplist=po.speccolors[2]
    widget_control, color4, set_droplist=po.speccolors[3]
    widget_control, line1, set_droplist=po.speclinestyle[0]
    widget_control, line2, set_droplist=po.speclinestyle[1]
    widget_control, line3, set_droplist=po.speclinestyle[2]
    widget_control, line4, set_droplist=po.speclinestyle[3]
	widget_control, line5, set_droplist=po.photlinestyle
	widget_control, color5, set_droplist=po.photcolor
	widget_control, line4a, set_droplist=po.highreslinestyle
	widget_control, color4a, set_droplist=po.highrescolor
	
	ebase = widget_base(topbase, /colum, /nonexclusive)
	fillbutton=widget_button(ebase, value="Fill Photometric Points:", event_pro='select_photfill',$
		xsize=100)
	highresbutton=widget_button(ebase, value="Show Highres Model:", event_pro='select_highres',$
			xsize=100)
	photobutton=widget_button(ebase, value="Show Photometry:", event_pro='select_showphoto',$
					xsize=100)
	widget_control, fillbutton, set_button=(po.photfill)
	widget_control, highresbutton, set_button=(po.highres)
	widget_control, photobutton, set_button=(po.showphoto)
	rbase = widget_base(topbase, /row)
	label = widget_label(rbase, value="Set Symbol Size", xsize=100)
	otext = widget_text(rbase, xsize=5, uvalue=0, event_pro='select_symsize', /editable, $
		value=otext)
	button=widget_button(rbase, value="Set Size", event_pro='select_symsize', xsize=100, uvalue=otext)
	rbase1 = widget_base(topbase, /row)
	label = widget_label(rbase1, value="Set Line Thickness", xsize=100)
	otext1 = widget_text(rbase1, xsize=5, uvalue=0, event_pro='select_thickness', /editable, $
		value=otext1)
	button=widget_button(rbase1, value="Set Size", event_pro='select_thickness', xsize=100, uvalue=otext1)


    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)

	widget_control, topbase, xoffset=250, yoffset=250
    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase
	

 END  



    


PRO select_chi2_options, event
	
	;;--Customize the chi2 options
	widget_control, event.top, get_uvalue=state
	topbase = widget_base(/column, title='Chi-Squared Plotting Options', $
		 xs=300, ys=300)
	button1 = widget_button(topbase, value="Select Grids to Plot", event_pro='select_chi2_models', $
		xs=300)
	button2 = widget_button(topbase, value="Select Normalization Method", event_pro='select_chi2_norm', $
		xs=300)
	button3 = widget_button(topbase, value="Choose Colors and Linestyle", event_pro='select_chi2_line', xs=300)
	
	
	button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
		uvalue=1)
	widget_control, topbase, /realize
	xmanager, 'zspec_plotoptions', topbase
	
END


    
PRO primus_zspec_splotoptions, event
    
    COMMON zspec_plotoptions, plotoptions
    COMMON sharestate, state
    
    Widget_control, event.TOP, get_uvalue=state
    widget_control, event.id, get_uvalue=uval
	
	if uval eq 1 then begin
    topbase = widget_base(/column, title="Plotting Options", $
      xs=300, ys=300)
   	button2 = widget_button(topbase, value="Select Main Window Data", $
      xsize=300, event_pro='select_main_data')
    button1 = widget_button(topbase, Value="Select Splot Data", $
      xsize=300, event_pro='select_splot_data')
	button4 = widget_button(topbase, value="Customize Spectrum Plot Settings", $
		xsize=300, event_pro='select_spec_line')
	button3 = widget_button(topbase, Value="Customize Chi-Squared Plot Settings", $
	  xsize=300, event_pro='select_chi2_options')
	
    
    button = widget_button(topbase, value="Done", event_pro='zspec_splotoptions_event', $
      uvalue=1)
    
	widget_control, topbase, xoffset=500, yoffset=500
    widget_control, topbase, /realize
    xmanager, 'zspec_splotoptions', topbase 
	
	primus_zspec_1d_plot, state
endif else select_spec_line, event
    
        
    
 END
