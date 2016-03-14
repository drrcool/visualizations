PRO primus_zspec_chi2doplot, state,  splot=splot
    
    COMMON zspec_objdata, ext, oned, slits, photoinfo, zspecinfo, cachemask, objindex
    COMMON zspec_plotoptions, plotoptions
    
    wset, state.draw_1d_idx[0]
    
    if n_elements(oned) eq 0 then begin
       res_txt = "This mask doesn't appear to have any oned information. " + $
         "Defaulting to plotting spectrum only."
       plotoptions.mainvect = 0
       plotoptions.splotvect = 0
       res = dialog_message(res_txt, /error, /center)
       return
       
    endif
    
    ;;-- Now extract the models that we need to plot
    color = primus_chi2colors()
    color = strlowcase(color)
    pgalchi2 = oned[objindex].chi2_photoz_gal
    galchi2 = oned[objindex].chi2_gal
    agnchi2 = oned[objindex].chi2_agn
    agngrid = oned[objindex].zgrid_agn
    galgrid = oned[objindex].zgrid_gal
    
      
    if total(plotoptions.chi2models) eq 0 then begin
       txt = "You have specified no chi2 grids to be plotted."
       res = dialog_message(res_txt, /error, /center)
       return
    endif
    
    allgrid = [-100]
    allchi2 = [0]
    if plotoptions.chi2models[0] eq 1 then begin
       allgrid = [allgrid, galgrid]
       allchi2 = [allchi2, pgalchi2]
    endif 
    if plotoptions.chi2models[1] eq 1 then begin
       allgrid = [allgrid, galgrid]
       allchi2 = [allchi2, galchi2]
    endif 
    if plotoptions.chi2models[2] eq 1 then begin
       allgrid = [allgrid, agngrid]
       allchi2 = [allchi2, agnchi2]
    endif
       
    ngrid = n_elements(allgrid)
    allgrid = allgrid[1:(ngrid-1)]
    allchi2 = allchi2[1:(ngrid-1)]
    
    ;;--Now normalize
    if plotoptions.chi2norm eq 0 then begin
       ;;--global sqrt
       min = min(allchi2)
       pgalchi2 = sqrt((pgalchi2-min)>0)
       galchi2 = sqrt((galchi2-min)>0)
       agnchi2 = sqrt((agnchi2-min)>0)
       allchi2 = sqrt((allchi2 - min)>0)
       ytitle='(\chi^2 - \chi^2_{min, global})^{1/2}'
    endif
    
    if plotoptions.chi2norm eq 1 then begin
        ;;--global sqrt
       min = min(allchi2)
       pgalchi2 = (pgalchi2-min)
       galchi2 = ((galchi2-min))
       agnchi2 = ((agnchi2-min))
       allchi2 = ((allchi2 - min))
       ytitle='(\chi^2 - \chi^2_{min, global})'
    endif
    if plotoptions.chi2norm eq 2 then begin
       ;;--global sqrt
       
       pgalchi2 = sqrt((pgalchi2-min(pgalchi2))>0)
       galchi2 = sqrt((galchi2-min(galchi2))>0)
       agnchi2 = sqrt((agnchi2-min(agnchi2))>0)
       allgrid = [-100]
       allchi2 = [0]
       if plotoptions.chi2models[0] eq 1 then begin
          allgrid = [allgrid, galgrid]
          allchi2 = [allchi2, pgalchi2]
       endif 
       if plotoptions.chi2models[1] eq 1 then begin
          allgrid = [allgrid, galgrid]
          allchi2 = [allchi2, galchi2]
       endif 
       if plotoptions.chi2models[2] eq 1 then begin
          allgrid = [allgrid, agngrid]
          allchi2 = [allchi2, agnchi2]
       endif
       
       ngrid = n_elements(allgrid)
       allgrid = allgrid[1:(ngrid-1)]
       allchi2 = allchi2[1:(ngrid-1)]
       
              
       ytitle='(\chi^2 - \chi^2_{min, model})^{1/2}'
    endif
 
      
    if plotoptions.chi2norm eq 3 then begin
        ;;--global sqrt
       min = min(allchi2)
       pgalchi2 = (pgalchi2-min(pgalchi2))
       galchi2 = ((galchi2-min(galchi2)))
       agnchi2 = ((agnchi2-min(agnchi2)))
       
       allgrid = [-100]
       allchi2 = [0]
       if plotoptions.chi2models[0] eq 1 then begin
          allgrid = [allgrid, galgrid]
          allchi2 = [allchi2, pgalchi2]
       endif 
       if plotoptions.chi2models[1] eq 1 then begin
          allgrid = [allgrid, galgrid]
          allchi2 = [allchi2, galchi2]
       endif 
       if plotoptions.chi2models[2] eq 1 then begin
          allgrid = [allgrid, agngrid]
          allchi2 = [allchi2, agnchi2]
       endif
       
       ngrid = n_elements(allgrid)
       allgrid = allgrid[1:(ngrid-1)]
       allchi2 = allchi2[1:(ngrid-1)]
       
       
       ytitle='(\chi^2 - \chi^2_{min, model})'
    endif
    
    
    
    
    if not keyword_set(splot) then begin
       ;;-- Plotting in the main window
       
       djs_plot, allgrid, allchi2, /nodata, /xs, /ys, $
         xtitle="Redshift", ytitle=textoidl(ytitle), charthick=1
       
       if plotoptions.chi2models[0] eq 1 then begin
          djs_oplot, galgrid, pgalchi2, ps=10, $
            lines=plotoptions.chi2linestyle[0], $
            color=djs_icolor(color[plotoptions.chi2colors[0]])
       endif
       
       if plotoptions.chi2models[1] eq 1 then begin
          djs_oplot, galgrid, galchi2, ps=10, $
            lines=plotoptions.chi2linestyle[1], $
            color=djs_icolor(color[plotoptions.chi2colors[1]])
       endif
       
       if plotoptions.chi2models[2] eq 1 then begin
          djs_oplot, agngrid, agnchi2, ps=10, $
            lines=plotoptions.chi2linestyle[2], $
            color=djs_icolor(color[plotoptions.chi2colors[2]])
       endif
       
       
    endif else begin
       ;;-- Plotting in splot window
       splot, allgrid, allchi2, /nodata, /xs, /ys, $
         xtitle="Redshift", ytitle=textoidl(ytitle), charthick=1
       
       if plotoptions.chi2models[0] eq 1 then begin
          soplot, galgrid, pgalchi2, ps=10, $
            lines=plotoptions.chi2linestyle[0], $
            color=djs_icolor(color[plotoptions.chi2colors[0]])
       endif
       
       if plotoptions.chi2models[1] eq 1 then begin
          soplot, galgrid, galchi2, ps=10, $
            lines=plotoptions.chi2linestyle[1], $
            color=djs_icolor(color[plotoptions.chi2colors[1]])
       endif
       
       if plotoptions.chi2models[2] eq 1 then begin
          soplot, agngrid, agnchi2, ps=10, $
            lines=plotoptions.chi2linestyle[2], $
            color=djs_icolor(color[plotoptions.chi2colors[2]])
       endif
    endelse
    
    
 end
