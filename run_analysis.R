library(reshape2)

datafile <- "getdata_dataset.zip"

## Download and unzip the dataset:

if (!file.exists(datafile)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(datafile)
}


# Load labels + features

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# Extract only the needed data

featuresNeeded <- grep(".*mean.*|.*std.*", features[,2])
featuresNeeded.names <- features[featuresNeeded,2]
featuresNeeded.names = gsub('-mean', 'Mean', featuresNeeded.names)
featuresNeeded.names = gsub('-std', 'Std', featuresNeeded.names)
featuresNeeded.names <- gsub('[-()]', '', featuresNeeded.names)


# Load the datasets

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresNeeded]
Y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(subject_train, Y_train, X_train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresNeeded]
Y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subject_test, Y_test, X_test)


# merge datasets and add labels

allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresNeeded.names)


# turn activities & subjects into factors

allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)


# create file

write.table(allData.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)
