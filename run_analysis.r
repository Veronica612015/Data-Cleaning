
#######################################################################################
# The following section of code reads in 7 files as listed beloww. These files are combined
# into a single data frame.
# 1. activity - contains the labels identifying the action as a factor. The factor is 
#               a key that links this file with 
#               the data set code in y_Test.txt and y_Train.txt
# 2. xTest -    contains the testing data set..
# 3. yTest -    contains a key that links to the activity data frame to identify the 
#               activity.
# 4. subjectsTest - identifies the subject for each row of data in xTest.
# 5. xTrain -   contains the training data set..
# 6. yTrain -   contains a key that links to the activity data frame to identify the 
#               activity.
# 7. subjectsTrain - identifies the subject for each row of data in xTrain.
# 8. features   contains the labels for the columns of xTest and xTrain
#

######################################################################################


#Download the zip file
install.packages("downloader")
library(downloader)
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "

download(fileurl, dest="dataset.zip", mode="wb") 
unzip ("dataset.zip", exdir = ".")

#Step 1:
#Merge the training and the test sets to create one data set.
# Read the test data 
# Get column classes for faster reading
xTest <- read.table("UCI HAR Dataset/test/X_test.txt", nrows=5)
xTest.classes <- lapply(xTest, class)
# Read the table
xTest <- read.table("UCI HAR Dataset/test/X_test.txt", colClasses=xTest.classes)

#Read the Training Set
# Get column classes
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt", nrows=5)
xTrain.classes <- lapply(xTrain, class)
# Read the table
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt", colClasses=xTrain.classes)

#Read in activity labels
activity <- read.table("UCI HAR Dataset/activity_labels.txt")

#read the column headings from features.txt
#assign column names to xTest
features = read.table("UCI HAR Dataset/features.txt", colClass= "character")

# Read the test set labels
yTest <- read.table("UCI HAR Dataset/test/y_test.txt")
# read in training set labels
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt")

#Read the tesing subject file
subjectsTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
#Read the tesing subject file
subjectsTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")

## combine the files
allSubject <- rbind(subjectsTrain, subjectsTest)
allActivity<- rbind(yTrain, yTest)
allFeatures<- rbind(xTrain, xTest)

#Assign labels to features
#Bulid a vector of column names
colnameV = vector(mode="character",length = 561)
for(i in 1:561){
  colnameV[i] = features$V2[i]
}
colnames(allFeatures) <- colnameV

names(allSubject)<-c("subject")
names(allActivity)<- c("activity")

#combine the subject and activity files
subjectActivity <- cbind(allSubject, allActivity)

#combine the features, subjject and activity
allData <- cbind(allFeatures,subjectActivity)


#Step 2:
#Extracts only the measurements on the mean and standard deviation for each measurement. 
# limit the data frame to just the mean and standard deviations

#use grep to limit the variables to just the mean or std
meanColumns = grep("mean()",colnameV, fixed=TRUE, value=TRUE)
stdColumns =  grep("std",colnameV, ignore.case=TRUE, value=TRUE)
#comnine into a single column heading file and use it to limit the columns in allData
keepColumns = c(as.character(meanColumns),as.character(stdColumns))
keepColumns = c(keepColumns,"subject", "activity")
#keepColumns = c(as.character(meanColumns),as.character(stdColumns),as.character("subject"))
allData = allData[keepColumns]



#Step 3: 
#Uses descriptive activity names to name the activities in the data set
#add activity factor levels to yTest based on activity_labels file
allData$activity = as.factor(allData$activity)
for(i in 1:nrow(activity)){
  levels(allData$activity)[i] <- levels(activity$V2)[i]
}

## Step 4:
#Appropriately labels the data set with descriptive variable names.
# Remove non-alphabetic characters and convert to lowercase
keepColumns <- tolower(gsub("[^[:alpha:]]", "", keepColumns))
# Rename the column names for allData using new names.
colnames(allData) <- keepColumns



## Step 5:
#From the data set in step 4, creates a second, independent tidy data set with the 
## average of each variable for each activity and each subject.
# summarize the data using aggregate
library(plyr);
tidyData<-aggregate(. ~subject + activity, allData, mean)
#sort the data by subject, activity
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
#Write out the file
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)


