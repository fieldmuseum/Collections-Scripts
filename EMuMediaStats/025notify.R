# Send notifications that the script ran

# For help installing mailR & java on ubuntu, try:
# https://github.com/hannarud/r-best-practices/wiki/Installing-RJava-(Ubuntu)

# if (file.exists(paste0("auditErrorlog_", filerDate, ".txt"))) {

sender <- Sys.getenv("SENDER")
recipients <- c(Sys.getenv("RECIP1"),
                Sys.getenv("RECIP2"),
                Sys.getenv("RECIP3")) # Sys.getenv("RECIPTEST")

  send.mail(from = sender,
            to = recipients,
            subject = paste("EMu MM Stats for", Sys.Date()),
            body = " Monthly EMu MM Stats have run",
            encoding = "utf-8",
            smtp = list(host.name = "aspmx.l.google.com", port = 25), 
            # user.name = Sys.getenv("SENDER"),            
            # passwd = Sys.getenv("SENDPW"), ssl = TRUE),
            authenticate = FALSE,
            send = TRUE,
            attach.files = c(paste0("./", Sys.getenv("OUT_DIR"),"mmStats.csv")),
            file.descriptions = c("MM stats"), # optional parameter
            debug = TRUE)
  