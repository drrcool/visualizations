PRO primus_zspec_showtext, state

    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, mask, objindex
    COMMON zspec_plotoptions, plotoptions
    
    widID = state.maintext
    
    if n_elements(oned) gt 0 then $
      dchi2 = oned[objindex].chi2min_photoz_gal[1]-oned[objindex].chi2min_photoz_gal[0] else $
        dchi2 = -1

;    if slits[objindex].currz ne 0 then $
;      currz = string(slits[objindex].currz, format='(f6.4)') else currz=''
    if n_elements(zspecinfo) gt 0 then begin
       if zspecinfo[objindex].z_spec ne 0 then $
          currz = string(zspecinfo[objindex].z_spec, format='(f6.4)') else currz=''
    endif else currz=''
; modified 7/29/09 - KW
; fixed so does not require a zspecinfo structure - JAA 11/19/09
    
    zval = -1.0
    if plotoptions.fitnum eq 0 then zval = oned[objindex].zmin_photoz_gal[0]
    if plotoptions.fitnum eq 1 then zval = oned[objindex].zmin_photoz_gal[1]
    if plotoptions.fitnum eq 2 then zval = oned[objindex].zmin_gal[0]
    if plotoptions.fitnum eq 3 then zval = oned[objindex].zmin_gal[2]
    if plotoptions.fitnum eq 5 then zval = oned[objindex].zmin_agn[0]
    if plotoptions.fitnum eq 6 then zval = oned[objindex].zmin_agn[1]
    if plotoptions.fitnum eq 7 then zval = oned[objindex].zmin_agn[2]
;    if plotoptions.fitnum eq 7 then zval = slits[objindex].currz
    if plotoptions.fitnum eq 9 then begin
       if n_elements(zspecinfo) eq 0 then zval=-1 $
       else zval = zspecinfo[objindex].z_spec
    endif
    if plotoptions.fitnum eq 10 then zval = oned[objindex].zprimus
    ; added BEST option JAA 11/19/09
; modified 7/29/09 - KW
    
    if tag_exist(oned, 'chi2_knownz') then chi2known = oned[objindex].chi2_knownz else chi2known = -1
    zval = string(zval, format='(f7.4)')


    string0 = 'Extraction Info:'
    string1 = 'Mask : ' + photoinfo[objindex].mask
    string2 = 'Object Number : ' + ext[objindex].name
    string3 = 'RA (J2000) : ' + string(ext[objindex].ra, format='(f10.6)')
    string4 = 'DEC (J2000) : ' + string(ext[objindex].dec, format='(f10.6)')
    string5 = 'S/N A : ' + string(ext[objindex].sn1, format='(f6.2)')
    string6 = 'S/N B : ' + string(ext[objindex].sn2, format='(f6.2)')
    string7 = 'BADEXTRACT : ' + string(ext[objindex].badextract, format='(i6)')
    string8 = '----------------------------------'
    string9 = 'Fitting Info:'
    if n_elements(oned) gt 0 then $
       string9a= '   BEST model = '+oned[objindex].zprimus_class $
    else string9a=''
    ; added BEST model JAA 11/19/09
    string10 = '   PHOTOZ delta chi^2 = ' + string(dchi2, format='(f6.2)') 
    if n_elements(oned) gt 0 then $
      string11a = 'Redshift of Plotted Model : ' + $
      string(zval) else string11a=''
    if n_elements(oned) gt 0 then string11 = $
      '   chi^2 of best galaxy model = ' + $
      string(oned[objindex].chi2min_photoz_gal[0], $
      format='(f6.1)') else string11 = ''
    string11b = '   chi^2 at known redshift = ' + $
      string(chi2known, format='(f6.1)')     
    string12 = '   known redshift = ' + currz
    if n_elements(oned) gt 0 then string13 = $
      '   ZPRIMUS_ZWARNING : ' + string(oned[objindex].zprimus_zwarning, format='(i6)') $
    else string13=''
    stringblank = ''
    string14 = 'No fit for this object'
    if n_elements(oned) gt 0 then string14a = $
      '   QUALITY : ' + string(oned[objindex].zconf_photoz_gal, format='(i1.1)') $
      else string14a = string14

    widget_control, widID, set_value=string0
    widget_control, widID, set_value=string1, /append
    widget_control, widID, set_value=string2, /append
    widget_control, widID, set_value=string3, /append
    widget_control, widID, set_value=string4, /append
    widget_control, widID, set_value=string5, /append
    widget_control, widID, set_value=string6, /append
    widget_control, widID, set_value=string7, /append
    widget_control, widID, set_value=string8, /append
    widget_control, widID, set_value=stringblank, /append
    widget_control, widID, set_value=string9, /append
    widget_control, widID, set_value=string11a, /append
    widget_control, widID, set_value=string11, /append
    widget_control, widID, set_value=string11b, /append
    widget_control, widID, set_value=string10, /append
    widget_control, widID, set_value=string9a, /append

;    if slits[objindex].currz ne -1 then widget_control, widID,
;    set_value=string12, /append
    if n_elements(zspecinfo) gt 0 then $
       if zspecinfo[objindex].z_spec ne -1 then widget_control, widID, set_value=string12, /append
; modified 7/29/09 - KW - fixed for no zspecinfo str JAA 11/19/09
    widget_control, widID, set_value=string13, /append
    widget_control, widID, set_value=string14a, /append
    if n_elements(oned) gt 0 then $
      if oned[objindex].zgrid_gal[10] eq 0 then widget_control, widID, set_value=string14, /append
    
    
 END
