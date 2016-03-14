PRO primus_zspec_skysub, event
    
    COMMON zspec_twod_data, skysubfiles, currentfile, currentccd, skysubimage, skymask, skynight, $
      waveimage, showwave, pixmask, badpixfiles, skyextract, skyextfiles
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex, $
      fullindex, subindex, cachererun, errorcode, cachenight
    COMMON zspec_plotoptions, plotoptions
    common devstate, mean, sigma
    
    loadct, 0, /silent
    widget_control, /hourglass
    ;;-- Find all the skysubtracted fits files and load the relavent one into memory.  
    reduxdir = getenv("PRIMUS_REDUX") + '/' + string(cachererun, format='(i4.4)') + '/' + $
      string(cachenight) + '/'
    
    
    ;;-- Get exposures
    if n_elements(skymask) eq 0 then skymask =''
    if n_elements(skynight) eq 0 then skynight = ''
    if n_elements(showwave) eq 0 then showwave = plotoptions.showwave

    if (skymask ne cachemask) or (skynight ne cachenight) then begin
       delvarx, skysubimage
       skysubfiles0 = primus_exposures(cachenight, cachemask)
       if skysubfiles0[0] eq '0' then return
       skysubfiles = skysubfiles0 + '_skyimage.fits'
       badpixfiles = 'badpix/' + skysubfiles0 + '_badpixc' 
       skyextfiles = skysubfiles0 + '.extract.fits.gz'
       for ifile = 0, n_elements(skysubfiles) -1 do begin
          skysubfiles[ifile] = lookforgzip(reduxdir + skysubfiles[ifile])
          
       endfor
       skynight = cachenight
       skymask = cachemask
       
    endif
    
    if n_elements(currentfile) eq 0 then currentfile = plotoptions.skysubfile
    if n_elements(currentccd) eq 0 then currentccd = -1
    
    ;;-- Check and see if the skyimage is memory is the one we want. If not, or there is no image in 
    ;;memory, then read it in
    if (n_elements(skysubimage) eq 0) or $
      (currentfile ne plotoptions.skysubfile) or $
      (currentccd ne ext[objindex].ccdnum) or $
      (showwave ne plotoptions.showwave) then begin
       
       print, "Please Hold: Reading and caching sky subtracted image"
       skysubimage = mrdfits(skysubfiles[currentfile], ext[objindex].ccdnum-1, /silent)
       if file_test(reduxdir+badpixfiles[currentfile]+ $
         string(ext[objindex].ccdnum, format='(i1.1)')+'.fits.gz') eq 1 then $
           badpiximage = mrdfits(reduxdir + badpixfiles[currentfile] + $
         string(ext[objindex].ccdnum, format='(i1.1)')+'.fits.gz', /silent) else $
           badpiximage = skysubimage * 0.0
       skyextract = mrdfits(reduxdir+skyextfiles[currentfile], 1, /silent, columns=['yasky', 'xasky', $
         'ybsky','xbsky', 'xaobj','xbobj','yaobj','ybobj', 'umod', 'ra','dec', 'tilt'])
       spherematch, ext.ra, ext.dec, skyextract.ra, skyextract.dec, 1.0/3600., m1, m2, dist
       skyextract = skyextract[m2]
       
       skysubimage = skysubimage *(badpiximage eq 0)
       skysubimage = extrac(skysubimage, 0, -5, 2048, 4096+10)
       currentfile = plotoptions.skysubfile
       currentccd = ext[objindex].ccdnum
       
    endif
    
    ;;-- Now, figure out how much of the image we want to show
    fullregion =  [0, 2047, 4, 4099]

    subregion  = [ext[objindex].xcorner, ext[objindex].ycorner+5]
    if plotoptions.fullccd eq 1 then begin $
      region = fullregion
       centerpix = [median(ext[objindex].xcorner), median(ext[objindex].ycorner)]
    endif
    
    if plotoptions.fullccd eq 0 then begin
       region = subregion
       centerpix = [(region[1]-region[0])/2, (region[3]-region[2])/2]
    endif
    
    
    subregion = [subregion[0] > 0, subregion[1]<2047, $
      subregion[2] > 0, subregion[3]<4105]

    if not xregistered('atv') then djs_iterstat, skysubimage, mean=mean, sigma=sigma

    
    
    region = [region[0] > 0, region[1]<2047, $
      region[2] > 0, region[3]<4105]
    xim = skysubimage[region[0]:region[1], (region[2]-4):(region[3])+4]
    primus_atv, xim, /stretch, /align, $
      min=-20, max=200, centerpix=centerpix
    
    xc = ext[objindex].xcorner
    yc = ext[objindex].ycorner+5
    
    if plotoptions.fullccd eq 1 then begin
       color=djs_icolor('magenta')
       atvplot, xc, yc[0]*[1,1], color=color
       atvplot, xc, yc[1]*[1,1], color=color
       atvplot, xc[0]*[1,1], yc, color=color
       atvplot, xc[1]*[1,1], yc, color=color
       loadct, 0, /silent
    endif
    
    nx = xc[1]-xc[0]
    yy = findgen(nx)+long(xc[0])
    
    xfit = [[skyextract[objindex].yasky + (yy - skyextract[objindex].xasky)*skyextract[objindex].tilt], $
      [skyextract[objindex].yaobj + (yy - skyextract[objindex].xaobj)*skyextract[objindex].tilt], $
      [skyextract[objindex].ybobj + (yy - skyextract[objindex].xbobj)*skyextract[objindex].tilt], $
      [skyextract[objindex].ybsky + (yy - skyextract[objindex].xbsky)*skyextract[objindex].tilt]] 
    
    if plotoptions.fullccd eq 0 then offset = [0, yc[0]-9]
    if plotoptions.fullccd eq 1 then offset = [xc[0], -5]
    
    if plotoptions.showtrace eq 1 then begin
       color = djs_icolor('red')
       atvplot, findgen(nx)+offset[0], $
         xfit[*,1]+skyextract[objindex].umod[1,0]-offset[1], thick=2, color=color
       atvplot, findgen(nx)+offset[0], $
         xfit[*,2]+skyextract[objindex].umod[1,1]-offset[1],  thick=2, color=color
       loadct, 0, /silent
    endif
    
    cachedevice=!d
    
 END

	
