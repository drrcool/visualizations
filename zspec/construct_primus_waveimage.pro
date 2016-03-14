FUNCTION construct_primus_waveimage, ext, ccd
	
	;;-based on the extraction for the image, construct a two-d image with wavelength information
	
	nx = 2048
	ny = 4096
	waveimage = fltarr(nx, ny+10)
	keep = where(ext.ccdnum eq ccd)
	
	for jobj = 0, n_elements(keep) -1 do begin
		iobj = keep[jobj]
		xc = ext[iobj].xcorner
		yc = ext[iobj].ycorner+[5,5]
		if ext[iobj].yaobj gt ext[iobj].ybobj then begin
			wave1 = ext[iobj].wave1 
			wave2 = ext[iobj].wave2
		endif else begin
			wave2 = ext[iobj].wave1
			wave1 = ext[iobj].wave2
		endelse
		
		xc[0] = xc[0]>0
		xc[1] = xc[1] < 2047
		
		yc1 = yc
		yc2 = yc
		
		yc1[0] = long(yc[1]) > 0 
		yc1[1] = (long(yc[1])+5) < 4101
		
		yc2[0] = (long(yc[0])-5) > 0 
		yc2[1] = (long(yc[0])) < 4101
		
		xpix = xc[1]-xc[0] 
		ypix1 = yc1[1]-yc1[0]  
		ypix2 = yc2[1]-yc2[0] 
		
		xstart = 0
		if xc[0] eq 0 then xstart = 149-xpix

 		wave1 = wave1[xstart:(xstart+xpix-1)]
		wave2 = wave2[xstart:(xstart+xpix-1)]
 		xxwave1 = rebin(wave1, xpix, ypix1)
		xxwave2 = rebin(wave2, xpix, ypix2)
		
		waveimage[xc[0]:(xc[1]-1), yc1[0]:(yc1[1]-1)] = xxwave1
		waveimage[xc[0]:(xc[1]-1), (yc2[0]+1):(yc2[1])] = xxwave2
		
	endfor
	
	return, waveimage
	
END
