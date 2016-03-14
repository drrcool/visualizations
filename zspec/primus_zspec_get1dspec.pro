PRO primus_zspec_get1dspec, wave1=wave1, wave2=wave2, flux1=flux1, flux2=flux2, ivar1=ivar1, ivar2=ivar2, $
  lambda_eff=lambda_eff, refband=refband, specscale=specscale
    

    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex,$  
      subindex, cachererun, errorcode, cachenight
    COMMON zspec_plotoptions, plotoptions
    
    specscale = [1d, 1d]
    lambda_eff = k_lambda_eff(filterlist=strtrim(photoinfo[objindex].filterlist, 2))
    if max(photoinfo[objindex].maggies) eq 0 then photoinfo[objindex].maggies = 1d-9
    ldist = abs(lambda_eff-8000) + 1e5*(photoinfo[objindex].maggiesivar eq 0) + 1e5*(lambda_eff gt 9000) 
    junk = min(ldist, refband)


    ; making sure the night matches the mask for obindex
    obsfile = getenv('PRIMUS_DIR') + '/data/primus_observed_mask_details.par'
    obstruct = yanny_readone(obsfile)
    wobst=where(obstruct.mask eq strmid(ext[objindex].infile,0,8),nw)
    if nw gt 0 then cachenight=obstruct[wobst[0]].date

    for ispec = 0, 1 do begin


       if ispec eq  0 then begin
          wave = ext[objindex].wave1
          fopt = ext[objindex].fopt1
          calib = ext[objindex].calib1
          fivar = ext[objindex].fivar1
          mask = ext[objindex].mask1
       endif else begin
          wave = ext[objindex].wave2
          fopt = ext[objindex].fopt2
          calib = ext[objindex].calib2
          fivar = ext[objindex].fivar2
          mask = ext[objindex].mask2

       endelse

       ;;Setup the proper fluxing
       if plotoptions.fluxing eq 0 then begin
          flux = fopt*calib
          ivar = fivar/(calib + (calib eq 0))^2. * (calib gt 0)
          ytitle=textoidl('Counts/s/\AA')
       endif else if plotoptions.fluxing eq 1 then begin
          outflux = primus2flambda(ext[objindex],wave=wave,pair=ispec+1,$
            fivar=outivar, night=cachenight) ; /norm)
          ytitle=textoidl('erg/s/cm^2/\AA x 10^7')
          
          ;;-- Find the closest good filter to 7000A with good photometry
          ;; -- Use this to set the refband
          
          keep = where(wave gt 4500 and outivar gt 0 and $
            wave lt 9500, ct)
          if ct gt 10 then begin
             specmaggies = k_project_filters(k_lambda_to_edges(wave[keep]), $
               outflux[keep], filterlist=strtrim(photoinfo[objindex].filterlist[refband], 2), /silent)
             photoscale = photoinfo[objindex].maggies[refband]/specmaggies
             
             Specscale[ispec] = photoscale[0]
             outflux  = outflux*photoscale[0]
             outivar =  10d^(alog10(outivar)-34)
             outivar = double(outivar)/photoscale[0]^2
             flux = outflux*1d17
             ivar = outivar
             wave = wave
          endif else begin
             wave = outflux*0.0
             flux = outflux*0.0
             ivar = outflux*0.0
          endelse
       endif
       

       if plotoptions.smoothing eq 1 then begin
          blue_smooth, wave, flux, ivar, swave, sflux, sfivar, $
            smooth_scale=25.0
       endif else if plotoptions.smoothing eq 2 then begin
          blue_smooth, wave, flux, ivar, swave, sflux, sfivar, $
            smooth_scale=50.0
       endif else if plotoptions.smoothing eq 0 then begin
          swave = wave
          sflux = flux
          sfivar = ivar
       endif

       outflux = sflux
       outivar = sfivar


       if ispec eq 0 then begin
          wave1 = swave
          flux1 = outflux
          ivar1 = outivar
       endif else begin
          wave2 = swave
          flux2 = outflux
          ivar2 = outivar
       endelse



    endfor
    return
 END

