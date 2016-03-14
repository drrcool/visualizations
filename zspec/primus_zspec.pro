;+
; NAME:
;  primus_zspec
; PURPOSE:
;  Plot spectra of PRIMUS sources
; CALLING SEQUENCE:
;  primus_zspec,mask,rerun,[night=night, /nosplash,$
;        memnice=memnice, chunksize=chunksize,subset=subset]
; INPUTS:
;  mask, rerun
; KEYWORDS:
;  night
;  nosplash
;  memnice?
;  chunksize?
;  subset - indices identifying a subset of objects to plot.
;           The easiest way to get the right indices is first load up
;           zspec for the mask e.g.
;         IDL> primus_zspec,'cxma0196',2165
;           Then load the common block
;         IDL> COMMON zspec_objdata
;           Then pull out indices e.g.
;         IDL> sub=where(strtrim(oned.zprimus_class,2) eq 'AGN')
;         IDL> primus_zspec,'cxma0196',2165,subset=sub
;
;-  
PRO primus_zspec, mask, rerun, night=night, nosplash=nosplash, memnice=memnice, chunksize=chunksize,subset=subset
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex,$
 		subindex, cachererun, errorcode, cachenight
    
    
    ;;Suppress divide by zero errors
    !Except=0
    


    if n_elements(mask) eq 0 or n_elements(rerun) eq 0 then begin
       error_txt = "You need to specify a mask name and rerun number. " + $
         "IDL>primus_zspec, 'vvds0138', 9920"
       res = dialog_message(error_txt, /error, /center)
       return
    ENDIF
    
    if not keyword_set(nosplash) then begin
       ;;-- Display splash screen
       proceed = primus_splash()
       if proceed eq 0 then return
    endif
    
    
    
    ;;-- Check to see if data is stored and if it is the appropriate
    ;;   mask
    if n_elements(cachemask) eq 0 then cachemask = ''
	if n_elements(cachererun) eq 0 then cachererun =0

    if cachemask ne mask or cachererun ne rerun then begin
	 
       primus_read, mask, rerun, $
         ext=ext, oned=oned, slits=slits, photoinfo=photoinfo, zspecinfo=zspecinfo, errorcode=errorcode, $
		night=night;, chunksize=chunksize, nchunk=0, totalchunk=nchunk
; modified 7/29/09 - KW
	   cachenight = night
       cachemask = mask
       cachererun=rerun
		
		keep = where(ext.type eq 'SLIT')
		ext = ext[keep]
		oned = oned[keep]
		slits = slits[keep]
		photoinfo = photoinfo[keep]
	
	

  	endif
		if (errorcode and 1) gt 0 or $	
		  (errorcode and 4) gt 0 then begin
			error_txt = "That extraction doesn't seem to exist for the specified rerun."
			res = dialog_message(error_txt, /error, /center)
			return
		endif
		
		if (errorcode and 2) gt 0 then begin
			proceed=primus_nooned()
			if proceed eq 0 then return
		endif

	objindex = 0
    subindex= 0
    

    ; modified JAA 11/19/09
    ; - added optional keyword subset
    ; - allows selection of a subset of objects by index
    ; - resets to all objects if not included
    if n_elements(subset) eq 0 then fullindex = indgen(n_elements(ext)) $
    else begin
        fullindex=[subset]
        objindex=subset[0]
    endelse

    ;;-- Startup the widget
    primus_zspec_startup
    
    
    
    
    
 END

    
    
    
