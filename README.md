Tidying Up of Activity Record Data
==================================

# Introduction

This work was done as a part of the course Getting and Cleaning Data offered through coursera by John Hopkins University, Baltimore.

### Objective

The objective of this work was to download, clean and tidy up the activity record data collected from the accelerometers from the Samsung Galaxy S smartphone. The data was originally obtained from the UCI website for Machine Learning repository available at the following link:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

This readme explains the steps followed for cleaning and tidying up the data. Particularly, it explains the steps followed in the associated R script run_analysis.R available in this repository.

### Instructions Given

The instructions given for tidying up the data are reproduced below.

`You should create one R script called run_analysis.R that does the following. `

`1.Merges the training and the test sets to create one data set. `

`2.Extracts only the measurements on the mean and standard deviation for each measurement.`

`3.Uses descriptive activity names to name the activities in the data set `

`4.Appropriately labels the data set with descriptive variable names. `

`5.From the data set in step 4, creates a second, independent tidy data set with the average` 
`of each variable for each activity and each subject.`

The associated R script does not follow the above steps linearly. Instead, it divides the steps into smaller tasks, which are performed in convenient order. However, the final result meet the tidy-up criterion stated in step 5 above.

### Data

The data was collected by Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio and Luca Oneto at Smartlab - Non Linear Complex Systems Laboratory, DITEN - Universita degli Studi di Genova, Via Opera Pia 11A, I-16145, Genoa, Italy (email: activityrecognition@smartlab.ws, weblink: http://www.smartlab.ws). The dataset is publicly available and more details are available in the following citation:

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

# Steps Followed for Cleaning and Tidying the Data

All the steps were performed using a single R script (run_analysis.R). The steps followed in the R script are explained below one by one.

### DOWNLOAD AND UNZIP

The R script first downloads the data from the weblink given below and unzips the compressed file. The name of the downloaded file is **ActivityRecordData.zip** and the uncompressed folder is **UCI HAR Dataset**. These steps are skipped if the download/unzip was already performed and the data are available on in the path.

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### READ INFORMATION FILES THAT HELP CLEANING AND TIDYING UP

Each recording of the activity measures 561 features. These features are stored in certain order. The names of the features and the recording order are given in **UCI HAR Dataset/features.txt**. This file is read to R as a data frame named featureNames.

There are 6 types of activity recorded: walking, walking upstairs, walking downstairs, sitting, standing and laying (resting). Each activity is given an number label. This information is stored in  **UCI HAR Dataset/activity_labels.txt**, which is read to a variable named activityLabels.

### FILTER THE MEAN AND STD ESTIMATES OF THE MEASUREMENTS

The instruction step 2 requires to extract only the measurements on mean and standard deviations for each measurements. According to the help files included with the data, the mean and standard deviation measurements are distinguished by the feature labels (stored in **UCI HAR Dataset/features.txt**, as explained above) by including respectively the following string expressions:

- "-mean()"
- "-std()"

There are feature labels that include the string "meanFreq". However, these report the estimates of the mean frequency of the measured signal for each recording interval. Whether to include these feature labels in the final result is a matter of data interpretation. Since the instructions state "measurements on the mean and standard deviation for each measurement", in the following, labels with the string "meanFreq" are not considered.

The R script uses `grep("-mean[()]|-std[()]",featureNames$FEATURE_NAME)` to select the mean and standard deviation estimates and the result is stored in a variable relevantFeatureNamesId.

### DISCRIPTIVE NAMES FOR THE MEAN AND STD VARIABLES

The instruction 4 is to appropriately label the data variable names using descriptive names. From the help files that come along with the data, it is evident that the naming of the features are already systematic and descriptive. So, here we use the same feature names but with slight modification. Especially, the names contains strings, namely, "mean" and "std", conjoined with more descriptive parts of the variable names through hyphens ("-"). The R script completely removes all the hyphens and replaces "mean" and "std" respectively with "Mean" and "Std". 

Descriptions for each variable is available in a separate CodeBook.md in this repo.

### FUNCTION TO READ TRAIN/TEST DATA

The 561 measurements for each subject and each recording are stored at **UCI HAR Dataset/train** and **UCI HAR Dataset/test** folders, where the former stores training data and the latter stores the test data. In these folders, **subject_train.txt** stores the subject number for each measurement, **X_train.txt** contains all the measurements and **y_train.txt** contains the activity label for each measurement. 

A function 'readARData' is written to read all the three files mentioned above and store the results in a data frame. The function takes three input variables. The first one specifies whether the training data or test data is to be read. The second argument specifies the columns to be selected and retained in the measurement data (X_train.txt). The measurement columns are labelled by descriptive names, which must be given as the third input argument to the function. The subject labels column is named as SUBJECT_ID and the activity labels column is named as ACTIVITY_LABEL.  The resulting data frame is returned to the calling function.

### READ AND MERGE THE TRAIN AND TEST DATA

Next, the R script reads the train and test data using the readARData function written above. Subsequently, the train and test data are combined into one data frame called mergeDt.

### USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATA SET

Instruction 3 requires to replace the activity labels, which takes numbers from 1 to 6 as their values, by more descriptive names. The file **UCI HAR Dataset/activity_labels.txt**, which was read earlier in the R script, contains number label to proper descriptive label mapping. This is used to replace the activity names. However, since the number of rows in the merged data is huge (10299), to replace each activity label is a time-consuming process. The final result required is a tidied-up data that contains average of each variable for each activity and subject. This will be a smaller data set. Therefore, the replacement of activity labels is deferred to the next section. Particularly, it is combined with the step of creating the final result.

### TIDY DATA: AVERAGE OF EACH VARIABLE FOR EACH ACTIVITY AND SUBJECT

This is the final step in the R scrip and produces the tidy data as described in instruction 5. It contains the average of each measurement for each activity and each subject.

### SAVE THE RESULT 

The results are saved into TidyAverageActivityData.txt using the `write.table()` function. To read the contents of this file into R, type

`data <- read.table("TidyAverageActivityData.txt",header = TRUE)`

