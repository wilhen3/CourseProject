##Loading the dplyr and data.table packages and setting desired working directory
library(dplyr)
library(data.table)
getwd()
setwd("C:/Users/William/Desktop/DSToolbox/GettingandCleaningDataCourse/CourseProject")
getwd()

##Downloading the UCI Dataset files from the website, unzip the files, and give date and time of download
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()

##Reset the working directory to go to unzipped files and read them
setwd("C:/Users/William/Desktop/DSToolbox/GettingandCleaningDataCourse/CourseProject/UCIHARDataset")
getwd()

##Read each of the activity files for Test and Train and assign variables "ActivityTest" and "ActivityTrain"
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

##Read each of the features files for Test and Train and assign variables "FeaturesTest" and "FeaturesTrain"
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

##Read each of the subject files for Test and Train and assign variables "SubjectTest" and "SubjectTrain"
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

##Read the activity labels file and assign variable "ActivityLabels"
ActivityLabels <- read.table("./activity_labels.txt", header = F)

##Read the features file and assign variable "FeaturesNames"
FeaturesNames <- read.table("./features.txt", header = F)

##Merge and combine the rows for FeaturesTest and Features Train, SubjectTest and SubjectTrain, and ActivityTest and ActivityTrain
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

##Rename the columns for ActivityData and ActivityLabels Dataframes
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

##Finding a common factor for Activity names and assign it to variable "Activity"
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

##Rename the columns for SubjectData
names(SubjectData) <- "Subject"

##Rename the columns for FeaturesData
names(FeaturesData) <- FeaturesNames$V2

##Merge/combine datasets with variables SubjectData, Activity, and FeaturesData to create one Dataset
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

##Creating new datasets using only measurements for the mean and standard deviation for each column measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

##Renaming the columns of the newly created large Dataset to give clear descriptive activity measurement names
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

##Creating a second tidier dataset, separate from large dataset, giving the average for each variable, for each activity, and for each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

##Save tidy data text file to my local working file
write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)