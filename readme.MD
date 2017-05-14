The repository contains 10 files:
activity_labels.txt
analysis.txt
codebook.MD
features.txt
run_analysis.R
subject_test.txt
subject_train.txt
X_test.txt
X_train.txt
y_test.txt
y_train.txt

The script run_analysis.R generates an analysis.txt file which provides the mean values of a group of 30 subjects performing 6 activities and measured in 561 categories. 

In summary, the script runs the following steps:  

1. The zipped dataset is downloaded and read into a working directory (lines 1 - 10). This is already completed and commented out so that the files are made available in the repository.
2. Starting in line 12, a set of library functions are enabled to manipulate data: plyr, dplyr, reshape2 and sqldf.
3. The test files from the X_test, y_test and subject_test files and train files are combined in a data frame using tbl_df function. It is done similarly for train files, features and activity files.
4. Variables are renamed to prepare for merge test and train into one data set and provide appropriate description.
5. Mean and standard deviation values were calculated from the combined dataset.
6. A tidy set is generated as a final result which also adds the average (mean) of each measurement for each volunteer for each activity.
 