library(jsonlite)
library(RCurl)
library(dplyr)
DEV<-FALSE
PROD<-TRUE
collectLocalWMI<-function(PSCommand)
{
  cmd<-paste0("powershell -command \"get-wmiobject ", PSCommand)
  cat(cmd)
  command<-system(cmd,intern=TRUE)
  return(fromJSON(command))
}
while(TRUE)
{
  try(
    {
      result<-collectLocalWMI("Win32_NetworkAdapterConfiguration |select macaddress,ipaddress,Description |ConvertTo-Json \"")
      result[is.na(result)]<-""
      result[result=="NULL"]<-""
      result<-result%>%filter(ipaddress!="")
      
      payloadcontent<-URLencode(base64_enc(serialize(result,NULL)))
      if(DEV) getForm("http://127.0.0.1:4738/upload",table="computer",mergekey="macaddress",payload=payloadcontent)
      if(PROD) getForm("http://192.168.1.150:1500/upload",table="computer",mergekey="macaddress",payload=payloadcontent)
      Sys.sleep(3000)
    }
  )
}


