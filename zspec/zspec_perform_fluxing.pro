FUNCTION zspec_perform_fluxing, ext, pair, photoinfo=photoinfo, trim=trim
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex,$                                                        
      subindex, cachererun, errorcode, cachenight             
    COMMON zspec_plotoptions, plotoptions


 if pair eq 1 then begin
	flux = ext.fopt1
	fivar = ext.fivar1
	if plotoptions.rawwave then wave = ext.wave1_raw else wave = ext.wave1
	calib = ext.calib1
endif else if pair eq 2 then begin
	flux = ext.fopt2
	fivar = ext.fivar2
	if plotoptions.rawwave then wave = ext.wave2_raw else wave = ext.wave2
	calib = ext.calib2
endif

keep = where(fivar gt 0)
maggies = k_project_filters(wave[keep], flux[keep], filterlist=strtrim(photoinfo.filterlist, 2), /silent)
lambda_eff = k_lambda_eff(filterlist=strtrim(photoinfo.filterlist, 2))
if max(photoinfo.maggies) eq 0 then photoinfo.maggies = 1d-9
ldist = abs(lambda_eff-8000) + 1e5*(photoinfo.maggiesivar eq 0) + 1e5*(lambda_eff gt 9000) + $
	1e5*(1-finite(maggies))
junk = min(ldist, refband)

 ;;Setup the proper fluxing
   if plotoptions.fluxing eq 0 then begin
       flux = flux*calib
       ivar = fivar/(calib + (calib eq 0))^2. * (calib gt 0)
       ytitle=textoidl('Counts/s/\AA')
    endif else if plotoptions.fluxing eq 1 then begin
       outflux = primus2flambda(ext,wave=wave,pair=pair,$
         counts2flam=counts2flam,fivar=outivar, night=cachenight)
       ytitle=textoidl('erg/s/cm^2/\AA x 10^7')
	
		;;-- Find the closest good filter to 7000A with good photometry
		;; -- Use this to set the refband
	
		keep = where(wave gt 4500 and outivar gt 0 and $
					 wave lt 9500, ct)
		if ct gt 10 then begin
		specmaggies = k_project_filters(k_lambda_to_edges(wave[keep]), $
			outflux[keep], filterlist=strtrim(photoinfo.filterlist[refband], 2), /silent)
		photoscale = photoinfo.maggies[refband]/specmaggies
	
		specscale = photoscale[0]
		outflux  = outflux*photoscale[0]
		outivar = outivar/(1d34)
     	ivar = outivar/photoscale[0]^2
		flux = outflux*1d17
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
	keep = where(swave gt 0 and sflux ne 0, ct)
	if ct gt 0 then begin
		swave =  swave[keep]
		sflux = sflux[keep]
		sfivar = sfivar[keep]
	endif

	swave0 = fltarr(200)
	sflux0 = fltarr(200)
	sfivar0 = fltarr(200)
	npix = n_elements(swave)-1
	if keyword_set(trim) then begin
		swave0[0:npix] = swave
		sflux0[0:npix] = sflux
		sfivar0[0:npix] = sfivar
		swave = swave0
		sflux = sflux0
		sfivar = sfivar0
	endif


	output = {wave : swave, $
			  flux : sflux, $
			  fivar : sfivar}
			
	return, output
	
END





