PRO primus_1d_doplot, state, splot=splot
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex
    common zspec_plotoptions, plotoptions

    colors = strlowcase(primus_chi2colors())
    color = colors[plotoptions.speccolors[0:1]]
    sym = plotoptions.speclinestyle[0:1]
    symsize= plotoptions.symsize
    photcolor = colors[plotoptions.photcolor]
    photsym = plotoptions.photlinestyle

    primus_zspec_get1dspec, wave1=wave1, wave2=wave2, flux1=flux1, $
      flux2=flux2, ivar1=ivar1, ivar2=ivar2, lambda_eff=lambda_eff, refband=refband, $
      specscale=specscale
    maggies = photoinfo[objindex].maggies
    emaggies = 1d/sqrt(photoinfo[objindex].maggiesivar)
    photkeep = where(photoinfo[objindex].maggiesivar gt 0, photct)
    light = 2.99792458D18
    fnu2flam = 10^(-0.4*48.6)*light/lambda_eff^2.0*1d17

    ;;--Now, plot

    keep1 = where(wave1 gt 4500 and wave1 lt 9500 and ivar1 gt 0, nkeep1)
    keep2 = where(wave2 gt 4500 and wave2 lt 9500 and ivar2 gt 0, nkeep2)
    if nkeep1 lt 10 or nkeep2 lt 10 then begin
       ;;****************************************************************;;
       ;;NEED TO PUT AN ERROR MESSAGE HERE;;
       ;;****************************************;;
       error = "This object has no plotable spectrum"
       junk = dialog_message(error, /error, /center)
       if not keyword_set(splot) then plot, [0],[0], /nodata else $
         splot,[0],[0], /nodata
       return
    endif

    allwave = [wave1[keep1], wave2[keep2]]
    allflux = [flux1[keep1], flux2[keep2]]
    err1 = 1d / sqrt(ivar1[keep1]*(ivar1[keep1] gt 0)+(ivar1[keep1] le 0)) * $
      (ivar1[keep1] gt 0) 
    err2 = 1d / sqrt(ivar2[keep2]*(ivar2[keep2] gt 0)+(ivar2[keep2] le 0)) * $
      (ivar2[keep2] gt 0)


    if not keyword_set(splot) then begin
       wset, state.draw_1d_idx[0]
       
       plot, allwave,allflux, ps=1, $
         xrange=[4500, 9500], /xs, /nodata, $
         xtitle=textoidl('Wavelength (\AA)'), $
         ytitle=ytitle, yrange=yrange

       rjc_oploterr, wave1[keep1], flux1[keep1], ps=sym[0], $
         color=djs_icolor(color[0]), yerr=err1[keep1], /cap, symsize=symsize
       rjc_oploterr, wave2[keep2], flux2[keep2], ps=sym[1], $
         color=color[1], yerr=err2[keep2], /cap, symsize=symsize
       
       plotsym, photsym, fill=plotoptions.photfill
       if plotoptions.fluxing eq 1 and plotoptions.showphoto eq 1 and photct gt 1 then begin
          rjc_oploterr, [lambda_eff[photkeep]], [maggies[photkeep]*fnu2flam[photkeep]],$
            yerr=[emaggies[photkeep]*fnu2flam[photkeep]], color=photcolor, ps=8, sym=symsize
          
       endif
       
       
    endif else begin
       splot, allwave,allflux, ps=1, $
         xrange=[4500, 9500], /xs, /nodata, $
         xtitle=textoidl('Wavelength (\AA)'), $
         ytitle=ytitle, yrange=yrange, /invert
       soplot, wave1[keep1], flux1[keep1], ps=sym[0], $
         color=djs_icolor(color[0]), symsize=symsize
       soplot, wave2[keep2], flux2[keep2], ps=sym[1], $
         color=djs_icolor(color[1]), symsize=symsize
       for i = 0, n_elements(keep1) -1 do begin
          soplot, wave1[keep1(i)]*[1,1], flux1[keep1(i)]+err1[i]*[-1,1], color=djs_icolor(color[0])
       endfor
       for i = 0, n_elements(keep2) -1 do begin
          soplot, wave2[keep2(i)]*[1,1], flux2[keep2(i)]+err2[i]*[-1,1], color=djs_icolor(color[1])
       endfor
       plotsym, photsym, fill=plotoptions.photfill
       
       if plotoptions.fluxing eq 1 and plotoptions.showphoto eq 1 and photct gt 1 then begin
          soplot, [lambda_eff[photkeep]], [maggies[photkeep]*fnu2flam[photkeep]],$
            color=djs_icolor(photcolor), ps=photsym, sym=symsize

       endif

    endelse
    
    if n_elements(oned) gt 0 then begin
       if (plotoptions.model_plot eq 1) and (oned[objindex].zgrid_gal[10] gt 0) then $
         primus_zspec_1dfit, state, splot=splot
    endif
    
 END

	
