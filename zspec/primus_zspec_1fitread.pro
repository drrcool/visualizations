PRO primus_zspec_1fitread, mod1=mod1, mod2=mod2


    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, fullindex,$                                                          
      subindex, cachererun, errorcode, cachenight             
    COMMON zspec_plotoptions, plotoptions

    ;; selecting the best fit   JAA 11/19/09
    bfit=-1
    if plotoptions.fitnum eq 10 then begin
       if strtrim(oned[objindex].zprimus_class,2) eq "GALAXY" then bfit=0 $
       else if strtrim(oned[objindex].zprimus_class,2) eq "AGN" then bfit=2 $
       else if strtrim(oned[objindex].zprimus_class,2) eq "STAR" then bfit=3 $
       else bfit=0
    endif



    if plotoptions.fitnum eq 0 or bfit eq 0 then begin
       ;;-- best photoz
       mod1 = oned[objindex].fmod_photoz_gal1[*,0]
       mod2 = oned[objindex].fmod_photoz_gal2[*,0]

    endif else if plotoptions.fitnum eq 1 then begin
       ;;-- 2nd photoz
       mod1 = oned[objindex].fmod_photoz_gal1[*,1]
       mod2 = oned[objindex].fmod_photoz_gal2[*,1]

    endif else if plotoptions.fitnum eq 2 then begin
       ;;-- best non-photoz
       mod1 = oned[objindex].fmod_gal1[*,0]
       mod2 = oned[objindex].fmod_gal2[*,0]

    endif else if plotoptions.fitnum eq 3 then begin
       ;;-- 2nd photoz
       mod1 = oned[objindex].fmod_gal1[*,1]
       mod2 = oned[objindex].fmod_gal2[*,1]
    endif else if plotoptions.fitnum eq 4 or bfit eq 3 then begin
       ;;-- Best Star
       junk = min(oned[objindex].chi2_star, jmin)
       mod1 = oned[objindex].fmod_star1[*,jmin]
       mod2 = oned[objindex].fmod_star2[*,jmin]
    endif else if plotoptions.fitnum eq 5 or bfit eq 2 then begin
       ;;-- Best AGN
       mod1 = oned[objindex].fmod_agn1[*,0]
       mod2 = oned[objindex].fmod_agn2[*,0]
    endif else if plotoptions.fitnum eq 6 then begin
       ;;-- AGN 2nd locus
       mod1 = oned[objindex].fmod_agn1[*,1]
       mod2 = oned[objindex].fmod_agn2[*,1]
    endif else if plotoptions.fitnum eq 7 then begin
       ;;-- AGN 3rd locus
       mod1 = oned[objindex].fmod_agn1[*,2]
       mod2 = oned[objindex].fmod_agn2[*,2]
    endif else if plotoptions.fitnum eq 8 then begin
       ;;-- Best Power law
       junk = min(oned[objindex].chi2_pl, jmin)
       mod1 = oned[objindex].fmod_pl1[*,jmin]
       mod2 = oned[objindex].fmod_pl2[*,jmin]
    endif else if plotoptions.fitnum eq 9 then begin
       ;;-- Fit at the correct redshift
       mod1 = oned[objindex].fmod_knownz_gal1
       mod2 = oned[objindex].fmod_knownz_gal2
    endif 
    
    
    
    if plotoptions.fluxing eq 1 then begin
       objflux1 = primus2flambda(ext[objindex],pair=1,wave=wave1, $
         counts2flam=counts2flam1, night=cachenight)
       objflux2 = primus2flambda(ext[objindex],pair=2,wave=wave2, $
         counts2flam=counts2flam2, night=cachenight)
       scale = median(counts2flam2)/median(counts2flam1) ; normalize
       counts2flam1 = counts2flam1*scale
       counts2flam2 = counts2flam2*scale

       k = where(ext[objindex].wave1 lt 4000 or ext[objindex].wave1 gt 1e4, ct)	
       if ct gt 0 then ext[objindex].wave1[k] = 0.0
       k = where(ext[objindex].wave2 lt 4000 or ext[objindex].wave2 gt 1e4, ct)
       if ct gt 0 then ext[objindex].wave2[k] = 0.0
       good1 = where(wave1 gt 0)
       good2 = where(wave2 gt 0)
       cor1 = interpol(counts2flam1[good1], wave1[good1], ext[objindex].wave1)
       cor2 = interpol(counts2flam2[good2], wave2[good2], ext[objindex].wave2)
       
       mod1 = mod1 / (cor1 + (cor1 eq 0)) * (cor1 gt 0) * 1d17
       mod2 = mod2 / (cor2 + (cor2 eq 0)) * (cor2 gt 0) * 1d17

    endif else begin
       calib1 = ext[objindex].calib1
       calib2 = ext[objindex].calib2
       mod1 = mod1 *calib1
       mod2 = mod2 *calib2
    endelse



    return
 END
