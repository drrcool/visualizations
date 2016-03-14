PRO primus_zspec_help, event

  mess_txt = string(format='(%"%s\n%s\n%s")',  $
                    'Oops.  You thought I actually included documentation... ',  $
                    'I will write it someday.  For now refer to:',  $
                    'http://howdy.physics.nyu.edu/index.php/PRIMUS_zspec_plotting_package')

  res = dialog_message(mess_txt, dialog_parent=event.top)

END
