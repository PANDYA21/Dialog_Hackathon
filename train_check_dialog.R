## train the dialog service, and check the functionality.

################################    START THE PIZZA PARTY  #########

source("udfs_dialog.R")

####### What Dialog ID's already exist?
watson.dialog.listapps()

###### TEST FUNCTION OK ACTION: Create a new Dialog!  (200 = Good outcome) - 
##### Where to get files and background?  here: http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/doc/dialog/

##### https://github.com/watson-developer-cloud/dialog-tool/blob/master/dialogs/pizza_sample.xml  # not all XML created equal - careful
thefile <- "ex1.xml"   #you'll need a local, 'good' Dialog XML file, in the right directory,
thename <- "hack7"
response <-  watson.dialog.uploadfile(thefile,thename)  # Pushes XML to dialog API - should return NEW dialog_id if OK
response #201?  if so, that's good
content(response, "text") # "{\"dialog_id\": 
#### end of test

watson.dialog.listapps() # do you see what i see?

### OK - let's extract the dialog ID so we can start a conversation  
data <- watson.dialog.listapps() # returns FULL LIST of them, could be up to 10
dialog_id <- data$dialog_id[grepl(thename, as.character(data$dialog_name))] #tail(data$dialog_id,1) ### LETS TAKE THE LATEST LAST ONE IF MORE THAN ONE DIALOG_ID
dialog_id <- paste(dialog_id) # gets rid of levels

dialog_id <- gsub("languagepacks", "", dialog_id)
dialog_id

# dialog_id <- "18f13a4f-2485-4d6b-ad5d-d8e2bfc5b38e"

## ACTION - Let's start a conversation!  LET'S BEGIN
conv_id <- "" # needs to be blank to trigger new
cl_id <- "" # needs to be blank to trigger new
text_input <- "Good day!"# "*" # "Hi" # doesnt really matter what our first input is 
response <-  watson.dialog.converse(dialog_id,conv_id,cl_id,text_input)  # first time through this should be blank (spawn a new one)
response
# cat(gsub(",", ",.\n", content(response, "text")))
cat(getResponse(response))
## OK NOW WE"RE COOKING (Pizza!)
## response\":[\"Hi, I'm Watson! I can help you order a pizza, what size would you like?\"]}"

### EXTRACT INFO FOR CONVERSATION ANCHOR - EXTRACT the conv Id and client id to CONTINUE - EXTRACT INFORMATION TO KEY OFF OF - Segue
data <- content(response,"text")
data <- as.data.frame(strsplit(as.character(data),'\"'))
setnames(data,c("V1"))
data$V1 <- str_replace_all(data$V1, "[[:punct:]]", "") 
data <- data[c(3,5,14), ] # cherry pick what we want - conv_id, client_id, and reponse
data <- data.frame(matrix(data)) # can tidy this method later
setnames(data,c("V1"))
conv_id <- toString(data$V1[1])
cl_id <- toString(data$V1[2])
watson_response <-toString(data$V1[3])
dialog_id # should still have this from opening round
###### OK - we've extracted key information - can continue dialog!
print(cat("This is your CONVERSATION ANCHOR:", "\n", "dialog_id = ", paste(dialog_id), "\n",
          "conversation_id = ", conv_id, "\n", "client_id = ", cl_id ,"\n", "watson_response = ",watson_response,"\n"))

#  watson_response =  Hi Im Watson I can help you order a pizza what size would you like 

## ACTION - Let's CONTINUE the conversation!
text_input <- "what cloths do you have?" # spelling error intentional- dialog has some spelling skills
response <-  watson.dialog.converse(dialog_id,conv_id,cl_id,text_input)
cat(getResponse(response))

text_input <- "i am a girl"
response <-  watson.dialog.converse(dialog_id,conv_id,cl_id,text_input)
cat(getResponse(response))
response.middle <- response

text_input <- "I am 26"
response <-  watson.dialog.converse(dialog_id,conv_id,cl_id,text_input)
cat(getResponse(response))
response.last <- response

############# DANGER ZONE
############# DANGER ZONE

# ## EXECUTE FUNCTION TO DELETES ONE DIALOG_ID - Just one - CAREFUL
# watson.dialog.listapps() # find one to kill
# dialog_id 
# watson.dialog.deletedialogID(dialog_id)
# watson.dialog.listapps() # did we kill it? should be gone now
# ## working 9/15/2015

# ########## EXECUTE BE --  DANGER ---  DANGER ---   
# watson.dialog.listapps() # we who are about to be deleted, salute you
# watson.dialog.deletedialogALL()  ## CARFUL  - this is NUCLEAR Option - kills ALL! DANGER 200 Status = the job is done
# watson.dialog.listapps() # did we kill it? should be gone now

#EOF