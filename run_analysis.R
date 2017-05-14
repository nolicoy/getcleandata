## initialize a temp file and download from web:
# temp <- tempfile()
# fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# download.file(fileUrl, temp, mode="wb")
# 
# ## unzip raw data into working directory:
# unzip(temp)
# 
# ## close connection to the url download:
# unlink(temp)

## list the files that were unzipped, selecting text (.txt) files in the 2 sub-directories, test and train:
test_files <- list.files("./test", pattern = "txt$", include.dirs = FALSE, full.names = TRUE)
train_files <- list.files("./train", pattern = "txt$", include.dirs = FALSE, full.names = TRUE)

## load the packages to enable functions:
library(plyr)  ## for ddply function
library(dplyr) ## for tbl_df function
library(reshape2)  ## for melt function
library(sqldf)  ## for sqldf function

## use tbl_df function to read the data into R for the test and train files in the subfolder test and train:
x_test <- tbl_df(read.table("./X_test.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE))
y_test <- tbl_df(read.table("./y_test.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE)) 
subject_test <- tbl_df(read.table("./subject_test.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE))

x_train <- tbl_df(read.table("./X_train.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE))
y_train <- tbl_df(read.table("./y_train.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE)) 
subject_train <- tbl_df(read.table("./subject_train.txt", sep="", header=TRUE, row.names = NULL, stringsAsFactors = FALSE))

## also read in features data into R into the subfolder with test and train:
features <- tbl_df(read.table("./features.txt", sep="", header=FALSE, row.names = NULL, stringsAsFactors = FALSE))
activity <- tbl_df(read.table("./activity_labels.txt", sep="", header=FALSE, row.names = NULL, stringsAsFactors = FALSE))

## change variable V1 from numeric to character which can be used to group the measurement by volunteer(subject) and activity: 
features$V1 <- as.character(features$V1)
activity$V1 <- as.character(activity$V1)

## rename the column variables to prepare merging test and train data: 
names(x_test) = c(1:561)
names(x_train) = c(1:561)
names(y_test) <- "Activity_id"
names(subject_test) <- "Volunteer_id"
names(y_train) <- "Activity_id"
names(subject_train) <- "Volunteer_id"
names(features) <- c("Signal_id", "Signal_label")
names(activity) <- c("Activity_id", "Activity_label")

## create data frames for test and train files:
alltest <- cbind(x_test, y_test, subject_test) ## 2946 rows
alltrain <- cbind(x_train, y_train, subject_train) ## 7351 rows

## merge test and train files into one dataset
combined <- rbind(alltest, alltrain)  ## 2946 + 7351 = 10297 rows

## extract mean and standard deviation for each measurement:
signal_mean <- sapply(combined, function(x) mean(x))
signal_sd <- sapply(combined, function(x) sd(x))

## from wide format to long format using reshape function and renaming columns ## 10297*561=5776617 rows:
df <- melt(combined, id.vars = c("Volunteer_id", "Activity_id"), variable.name = "Signal_id", value.name = "value")

finaldf <- sqldf("select df.Volunteer_id, activity.Activity_label, features.Signal_label, avg(value)
     from df 
     join features on df.Signal_id = features.Signal_id
     join activity on df.Activity_id = activity.Activity_id
     group by df.Volunteer_id, activity.Activity_label, features.Signal_label")

## validation count:
## length(finaldf$Signal_label) = 100980
## length(unique(finaldf$Signal_label)) = 477
## 30 volunteers * 6 activities * 477 signals = 85860 records

## write function to export data frame as a text document:
write.table(finaldf, "./analysis.txt", sep=",", row.names = FALSE)
