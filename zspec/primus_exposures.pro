function primus_exposures, cachenight, cachemask, nocoadd=nocoadd
	
	;;--for a given night and mask, find all of the primus exposures

	qfilename = primus_filename('batch')
	qfile = yanny_readone(qfilename, /anonymous)
	keep = where(qfile.date eq long(strmid(cachenight, 2, 6)) and $
		qfile.mask eq cachemask, ct)
	if ct eq 0 then begin
		error_txt = "No entries found for date " + cachenight + ' and mask ' + $
			cachemask + '.'
   		res = dialog_message(error_txt, /error, /center)
		return, '0'
	endif

	exposures = qfile[keep(0)].files[where(qfile[keep(0)].files ne 0)]
	exposures = 'ccd' + string(exposures, format='(i4.4)')
	if not keyword_set(nocoadd) then $
		exposures = [cachemask + '_coadd', exposures]
		
	return, exposures
	
	
end
