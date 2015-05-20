# You will be required to submit: 1) a tidy data set as described below, 2) a
# link to a Github repository with your script for performing the analysis, and
# 3) a code book that describes the variables, the data, and any transformations
# or work that you performed to clean up the data called CodeBook.md. You should
# also include a README.md in the repo with your scripts. This repo explains how
# all of the scripts work and how they are connected.

# Tidy data set

# You should create one R script called run_analysis.R that does the following.
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second, independent tidy data set with the
# average of each variable for each activity and each subject.


########### DOWNLOAD AND UNZIP ##########

# Download the data if not already done it
library("RCurl")
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataDestFile <- "ActivityRecordData.zip"
if(!file.exists(dataDestFile)){
    print("Downloading the file. Please be patient.")
    download.file(dataURL,dataDestFile,method="curl")
}

# Unzip the file
library(utils)
if(!dir.exists("UCI HAR Dataset")){
    print("Unzip in progress.")
    unzip(dataDestFile)
    print("Finished unziping")
}


############## READ INFORMATION FILES THAT HELP CLEANING AND TIDYING UP ###############

# Read the names of the features from features.txt
featureNames <- read.table("UCI HAR Dataset/features.txt",header=FALSE,col.names=c("SERIAL_NO","FEATURE_NAME"),
                           colClasses=c("numeric","character"))

# Read the activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",header=FALSE,col.names=c("LABEL","ACTIVITY"))


################### FILTER THE MEAN AND STD ESTIMATES OF THE MEASUREMENTS ##########

# Select only the feature ids whose feature names include "-mean()"
relevantFeatureNamesId <- grep("-mean[(](+)[)]|-std[(](+)[)]",featureNames$FEATURE_NAME)


################# DISCRIPTIVE NAMES FOR THE MEAN AND STD VARIABLES ###########3

# Descriptive names for the columns to be retained are tabulated in the following
relevantFeatureNames <- featureNames$FEATURE_NAME[relevantFeatureNamesId]
relevantFeatureNames <- gsub("-mean[(](+)[)](+)[-]?","Mean",relevantFeatureNames)
relevantFeatureNames <- gsub("-std[(](+)[)](+)[-]?","Std",relevantFeatureNames)


########### FUNCTION TO READ TRAIN/TEST DATA ####################

# Function to read train/test activity record measurements The input variable
# 'dataType' specifies which data (training or test) to read. If training data
# is to be read, use dataType="TRAIN"; otherwise use dataType="TEST".
# The second input variable 'colsToRetain' contains the column indices of the
# feature data to be still retained (i.e., associated with the mean and std estimates).
# The third input variable 'retainedColNames' should contain the descriptive names for
# the retained columns.

readARData <- function(dataType="TRAIN",colsToRetain,retainedColNames){
    if(toupper(dataType)=="TRAIN"){
        subjDtPth <- "UCI HAR Dataset/train/subject_train.txt"
        measDtPth <- "UCI HAR Dataset/train/X_train.txt"
        actiDtPth <- "UCI HAR Dataset/train/y_train.txt"
    }else if(toupper(dataType)=="TEST"){
        subjDtPth <- "UCI HAR Dataset/test/subject_test.txt"
        measDtPth <- "UCI HAR Dataset/test/X_test.txt"
        actiDtPth <- "UCI HAR Dataset/test/y_test.txt"
    }
    subjectDt <- read.table(subjDtPth,header=FALSE,col.names="SUBJECT_ID",
                            colClasses="numeric")
    activityLabelDt <- read.table(actiDtPth,header=FALSE,col.names="ACTIVITY_LABEL",
                                  colClasses="numeric")
    measurementDt <- read.table(measDtPth,header=FALSE,
                            colClasses="numeric")
    measurementDt <- measurementDt[colsToRetain]
    colnames(measurementDt) <- retainedColNames
    data.frame(subjectDt,activityLabelDt,measurementDt)
}

############## READ AND MERGE THE TRAIN AND TEST DATA ################

# Read
trDt <- readARData("TRAIN",relevantFeatureNamesId,relevantFeatureNames)
teDt <- readARData("TEST",relevantFeatureNamesId,relevantFeatureNames)

# Merge
mergeDt <- rbind(trDt,teDt)
rm("trDt","teDt") # Release memory


############### REPLACE ACTIVITY LABELS BY DESCRIPTIVE LABELS ##########

# Combined with the next step

######### TIDY DATA: AVERAGE OF EACH VARIABLE FOR EACH ACTIVITY AND SUBJECT ####

library(dplyr)
tidyAvgARDt <- # Final result variable
mergeDt %>% # Use chain operations
    # Gather the measurements in single variable MEASUREMENT and the measured
    # values in VALUES
    gather(MEASUREMENT,VALUE,tBodyAccMeanX:fBodyBodyGyroJerkMagStd) %>%
    # Group the result by SUBJECT_ID, ACTIVITY, MEASUREMENT
    group_by(SUBJECT_ID,ACTIVITY_LABEL,MEASUREMENT) %>%
    # Compute the required average for measurement for activity for subject
    summarise(
        AVERAGE_VALUE=mean(VALUE)
        )%>%
    # Spread back the MEASUREMENT into different columns
    spread(MEASUREMENT,AVERAGE_VALUE) %>%
    # Replace ACTIVITY_LABEL with more descriptive values
    mutate(ACTIVITY_LABEL=activityLabels$ACTIVITY[ACTIVITY_LABEL])


########################## SAVE THE RESULT ##########################

write.table(tidyAvgARDt,"TidyAverageActivityData.txt",quote=FALSE,row.names=FALSE)