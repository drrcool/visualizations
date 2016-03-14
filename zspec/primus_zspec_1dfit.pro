PRO primus_zspec_1dfit, state, splot=splot
    
    common zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, $
      fullindex, subindex, cachererun
    common zspec_plotoptions, plotoptions
    common fit_data, template_data, agn_template_data, star_template_data
    

    rerun_params = yanny_readone("$PRIMUS_DIR/data/primus_rerun_parameters.par")
    


    wset, state.draw_1d_idx[0]
    device, decompose=0
    colors = strlowcase(primus_chi2colors())
    color = colors[plotoptions.speccolors[2:3]]
    lines = plotoptions.speclinestyle[2:3]
    highrescolor = colors[plotoptions.highrescolor]
    filterlist = strtrim(photoinfo[objindex].filterlist, 2)
    primus_zspec_get1dspec, wave1=wave1, wave2=wave2, flux1=flux1, $
      flux2=flux2, ivar1=ivar1, ivar2=ivar2, specscale=specscale, $
      refband=refband, lambda_eff=lambda_eff
    primus_zspec_1fitread, mod1=mod1, mod2=mod2


    keep1 = where(ext[objindex].wave1 gt 4500 and ext[objindex].wave1 lt 9500 and $
      ext[objindex].fivar1 gt 0, ct1)
    keep2 = where(ext[objindex].wave2 gt 4500 and ext[objindex].wave2 lt 9500 and $
      ext[objindex].fivar2 gt 0, ct2)
    
    k = where(rerun_params.rerun eq cachererun, ct)
    galtemp = rerun_params[k[0]].galtemplatever
    agntemp = rerun_params[k[0]].agntemplatever



    ;;-- High res and photometry
    if n_elements(template_data) le 1 then $
      template_data = mrdfits(getenv('PRIMUS_DATA')+$
      '/template_basis/' + galtemp + '.fits.gz',1)
      
      ;;Need to look for gziped and non-zgipped
    if n_elements(agn_template_data) le 1 then $
        agn_template_data = mrdfits(getenv('PRIMUS_DATA') + $
        '/template_basis/'+agntemp+'.fits.gz', 1)
        
    ;;read in the stats
    if n_elements(star_template_data) le 1 then $
        star_template_data = mrdfits(getenv('PRIMUS_DATA') + $
        '/template_basis/pickles.fits', 1)


    ;;--Here, we will *assume* the measured spectrum stays the same and we scale the phot
    ;;  and model to that
    
    ;; selecting the best fit   JAA 11/19/09
    bfit=-1
    if plotoptions.fitnum eq 10 then begin
       if strtrim(oned[objindex].zprimus_class,2) eq "GALAXY" then bfit=0 $
       else if strtrim(oned[objindex].zprimus_class,2) eq "AGN" then bfit=2 $
       else if strtrim(oned[objindex].zprimus_class,2) eq "STAR" then bfit=3 $
       else bfit=0
    endif
    
      if plotoptions.fitnum eq 0 or bfit eq 0 then begin
       ;tempphot = template_data[oned[objindex].index_photoz_gal[0]] ; photometric template
       ptempindx=oned[objindex].index_photoz_gal[0]
       z = oned[objindex].zmin_photoz_gal[0]
       modelmaggies = k_project_filters(k_lambda_to_edges(template_data.highwave*(1+z)), $
         template_data.highflux[*,ptempindx], filterlist=filterlist[refband], /silent)
       modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
       mwave = template_data.highwave*(1.0+z)
       mflux = template_data.highflux[*,ptempindx] * modelscale[0]
    endif
    
    if plotoptions.fitnum eq 1 then begin
       ;tempphot = template_data[oned[objindex].index_photoz_gal[1]] ; photometric template
       ptempindx=oned[objindex].index_photoz_gal[1] ; photometric template
       
       z = oned[objindex].zmin_photoz_gal[1]
       modelmaggies = k_project_filters(k_lambda_to_edges(templ.highwave*(1+z)), $
         template_data.highflux[*,ptempindx], filterlist=filterlist[refband], /silent)
       modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
       mwave = template_data.highwave*(1.0+z)
       mflux = template_data.highflux[*,ptempindx] * modelscale[0]
    endif
    if plotoptions.fitnum eq 2 then begin
       ;tempspec = template_data[oned[objindex].index_gal[0]] ; spectroscopic template
       ptempindx=oned[objindex].index_gal[0]

       z = oned[objindex].zmin_gal[0]
       modelmaggies = k_project_filters(k_lambda_to_edges(template_data.highwave*(1+z)), $
         template_data.highflux[*,ptempindx], filterlist=filterlist[refband], /silent)
       modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
       mwave = template_data.highwave*(1.0+z)
       mflux = template_data.highflux[*,ptempindx] * modelscale[0]
    endif
    if plotoptions.fitnum eq 3 then begin
       ;tempspec = template_data[oned[objindex].index_gal[1]] ; spectroscopic template
       ptempindx=oned[objindex].index_gal[1] 

       z = oned[objindex].zmin_gal[1]
       modelmaggies = k_project_filters(k_lambda_to_edges(template_data.highwave*(1+z)), $
         template_data.highflux[*,ptempindx], filterlist=filterlist[refband], /silent)
       modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
       mwave = template_data.highwave*(1.0+z)
       mflux = template_data.highflux[*,ptempindx] * modelscale[0] 
    endif
    if plotoptions.fitnum eq 5 or bfit eq 2 then begin ;;read the agn 
        z = oned[objindex].zmin_agn[0]
        tempspec = agn_template_data[oned[objindex].index_agn[0]]
        modelmaggies = k_project_filters(k_lambda_to_edges(tempspec.qwave*(1+z)), $
            tempspec.qflux, filterlist=filterlist[refband], /silent)
        modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
        mwave = tempspec.qwave*(1.0+z)
        mflux = tempspec.qflux*modelscale[0]
    endif
    if plotoptions.fitnum eq 6 then begin ;;read the agn 2nd locus
        z = oned[objindex].zmin_agn[1]
        tempspec = agn_template_data[oned[objindex].index_agn[1]]
        modelmaggies = k_project_filters(k_lambda_to_edges(tempspec.qwave*(1+z)), $
            tempspec.qflux, filterlist=filterlist[refband], /silent)
        modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
        mwave = tempspec.qwave*(1.0+z)
        mflux = tempspec.qflux*modelscale[0]
    endif
    if plotoptions.fitnum eq 7 then begin ;;read the agn 3rd locus
        z = oned[objindex].zmin_agn[2]
        tempspec = agn_template_data[oned[objindex].index_agn[2]]
        modelmaggies = k_project_filters(k_lambda_to_edges(tempspec.qwave*(1+z)), $
            tempspec.qflux, filterlist=filterlist[refband], /silent)
        modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
        mwave = tempspec.qwave*(1.0+z)
        mflux = tempspec.qflux*modelscale[0]
    endif

    if plotoptions.fitnum eq 4 or bfit eq 3 then begin ;; for stars
        junk = min(oned[objindex].chi2_star, jmin)
        tempspec = star_template_data[jmin]
        modelmaggies = k_project_filters(k_lambda_to_edges(tempspec.wave), $
            tempspec.flux, filterlist=filterlist[refband], /silent)
        modelscale = photoinfo[objindex].maggies[refband]/modelmaggies
        mwave = tempspec.wave
        mflux = tempspec.flux*modelscale[0]
    endif        
    
    
    if not keyword_set(splot) then begin
       if ct1 gt 10 then djs_oplot, ext[objindex].wave1[keep1], $
         mod1[keep1]*specscale[0], ps=10, color=color[0], lines=lines[0]
       if ct2 gt 10 then djs_oplot, ext[objindex].wave2[keep2], $
         mod2[keep2]*specscale[1], ps=10, color=color[1], lines=lines[1]
       if plotoptions.fluxing eq 1 and ((plotoptions.fitnum le 4) or (plotoptions.fitnum eq 5) or (plotoptions.fitnum eq 8)) and $
         plotoptions.highres eq 1 then $
           djs_oplot, mwave, mflux*1d17, color=highrescolor, ps=10, $
         linestyle=plotoptions.highreslinestyle
         
    endif else begin
       if ct1 gt 10 then soplot, ext[objindex].wave1[keep1], $
         mod1[keep1]*specscale[0], ps=10, color=djs_icolor(color[0]), lines=lines[0]
       if ct2 gt 10 then soplot, ext[objindex].wave2[keep2], $
       mod2[keep2]*specscale[1], ps=10, color=djs_icolor(color[1]), lines=lines[1]
       if plotoptions.fluxing eq 1 and ((plotoptions.fitnum le 4)  or (plotoptions.fitnum eq 5) or (plotoptions.fitnum eq 8)) and $
         plotoptions.highres eq 1 then $
           soplot, mwave, mflux*1d17, color=djs_icolor(highrescolor), $
         ps=10, linestyle=plotoptions.highreslinestyle
    endelse

    
    


    




 END

    
    
