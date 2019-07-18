# Setup .Renviron 
#   - follow https://csgillespie.github.io/efficientR/3-3-r-startup.html#r-startup
# NOTE: Make sure to add .Renviron to .gitignore

proj_renviron = path.expand(file.path(getwd(), ".Renviron"))
if(!file.exists(proj_renviron)) { # check to see if the file already exists
  
  file.create(proj_renviron)
  writeLines(c("## Server variables",
               "",
               "SERVER_IP = 'server-ip-address'",
               "SERVER_ID = 'id'",
               "SERVER_PW = 'pw'",
               "EMU_DIR = 'path/to/emu/stats-export/directory/'",
               "OUT_DIR = 'output/'",
               "EMU_LOC = '/stats-export/'",
               "EMU_DIR_MM = 'path/to/emu/mm-export/directory/'",
               "EMU_LOC_MM = '/mm-export/'",
               "SENDER = 'youremail@address.com'",
               "RECIP1 = 'recip1@email.com'",
               "RECIP2 = 'recip2@email.com",
               "SENDPW = 'yourmailpw'"
  ),
  proj_renviron)
  
  file.edit(proj_renviron) # open with another text editor if this fails
  
}


