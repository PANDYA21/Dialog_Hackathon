## UDFs for creating, training, and querying  dialog service

library(RCurl) # install.packages("RCurl") # if the package is not already installed
library(httr)
library(XML)
library(data.table)
library(reshape2)
library(dplyr)
library(stringr)
# setwd("/Users/ryan/Documents/Project Daisy")

#"DIALOG ORANGE SERVICE credentials": { UNBOUND
base_url= "https://gateway.watsonplatform.net/dialog/api/v1"
username = "61d28f24-7fa7-4030-a055-7d8eae02dbcb" # from Bluemix Service Credentials
password = "Bx7R3enYAUBl"
username_password = paste(username,":",password,sep="")
dialog_id=""

####### FUNCTION - New LIST APPS
watson.dialog.listapps <- function() 
{ data <- getURL(paste(base_url,"/dialogs",sep=""),userpwd = username_password )
data <- as.data.frame(strsplit(as.character(data),"name"))
data <- data[-c(1), ] # remove dud first row
data <- data.frame(matrix(data)) # can tidy this method later - IF YOU HAVE MORE THAN ONE DIALOG - YOU"LL GET MULTIPLE HERE
data <- strsplit(as.character(data$matrix.data),"dialog_id")
data <- t(data.frame(data)) # can tidy this method later
rownames(data) <- NULL
# tidy up (there is a better way later)
print(data)
data[,1] <- str_replace_all(data[,1], "[[:punct:]]", "") 
data[,2] <- gsub("-"," ",data[,2]) 
data[,2] <- str_replace_all(data[,2], "[[:punct:]]", "") 
data[,2] <- gsub(" ","-",data[,2]) 
data <- data.frame(data)
setnames(data,c("dialog_name","dialog_id"))
return(data)
}

####### FUNCTION - New Dialog - UPLOAD XML FILE
watson.dialog.uploadfile <- function(file,name) 
{ return(POST(url=paste(base_url,"/dialogs",sep=""),
              authenticate(username,password),
              body = list(file = upload_file(file),
                          name = name
              ) ))  }


####### FUNCTION - CONVERSE - Used to obtain a response from the system for a submitted input message. Also used to start new conversations
watson.dialog.converse <- function(dialog_id, conv_id, cl_id, text_input) 
{
  segue <- list(
    conversation_id = conv_id,
    client_id = cl_id,
    input = text_input
  )
  return
  ( POST(url=paste(base_url,"/dialogs/",dialog_id,"/conversation",sep=""), 
         authenticate(username,password),
         body = segue, encode = "form")
  )}
### end of function 

####### FUNCTION - DELTETE *ONE* DIALOG ID's - WORKING
watson.dialog.deletedialogID <- function(kill_dialogID) 
{ return( DELETE(url=paste(base_url,"/dialogs/",kill_dialogID,sep=""),userpwd = username_password)
)  }
### end of function declaration 

######## FUNCTION TO  DELETE ALL DIALOGS (ALL!) > delete /dialogs > Used to close an entire all Dialog applications associated with the service instance.
watson.dialog.deletedialogALL <- function() {
  return( DELETE(url="https://gateway.watsonplatform.net/dialog-beta/api/v1/dialogs",userpwd = username_password) )}
### end of function declaration 


#### get nice JSON text based response
getResponse <- function(response){
  return(gsub(",", ",.\n", content(response, "text")))
}

################################    END OF FUNCTION DECLARATIONS #########
################################    END OF FUNCTION DECLARATIONS #########