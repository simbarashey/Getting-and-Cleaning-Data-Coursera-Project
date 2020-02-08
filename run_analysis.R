# Script for Getting and Cleaning Data project

#Task is to write a script to do the following

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


#install and load data.table package
#install.packages("data.table")
library(data.table)

#download and unzip the data set
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "./projectdataset.zip")
unzip(zipfile = "projectdataset.zip")

#read the activity labels from downloaded data
actLabels <- data.table::fread("./UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))

#read the selected activity features
features <- data.table::fread("./UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))
#featuresselected <- grep("(mean|std)\\(\\)", features[, featureNames]) # vector of indices of the selected features
featuresselected <- grep("([Mm]ean|[Ss]td)", features[, featureNames]) # vector of indices of the selected features
measurements <- features[featuresselected, featureNames] # vector of the selected variable names or measurements

#read the train data
traina <- data.table::fread("./UCI HAR Dataset/train/X_train.txt")
trainb <- traina[,featuresselected, with = FALSE]  #with = FALSE is necessary else data.table treats featuresselected as a col name
data.table::setnames(trainb, colnames(trainb), measurements)
trainActivities <- data.table::fread("./UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
trainSubjects <- data.table::fread("./UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
traindata <- cbind(trainSubjects, trainActivities, trainb)

#read the test data
testa <- data.table::fread("./UCI HAR Dataset/test/X_test.txt")
testb <- testa[,featuresselected, with = FALSE]
data.table::setnames(testb, colnames(testb), measurements)
testActivities <- data.table::fread("UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
testSubjects <- data.table::fread("UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
testdata <- cbind(testSubjects, testActivities, testb)

#merge the two data sets
mergedDT <- rbind(traindata, testdata)

#add descriptive names to the activity variables
mergedDT[["Activity"]] <- factor(mergedDT$Activity, levels = actLabels$classLabels, labels = actLabels$activityName)
mergedDT[["SubjectNum"]] <- as.factor(mergedDT[, SubjectNum])

# Step 5
#install.packages("dplyr")
library(dplyr)

merged_grouped <- group_by(mergedDT, SubjectNum, Activity)
finaldata <- summarise_all(merged_grouped, funs(mean) )
write.csv(finaldata, "finaldata.txt", row.names=FALSE)