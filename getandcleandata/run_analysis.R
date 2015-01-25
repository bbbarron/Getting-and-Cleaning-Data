## Coursera - Getting and Cleaning Data - getdata -010
## January, 2015

## Course project to demonstrate ability to collect, organize and clean field data. Goal is to 
## prepare "Tidy Data" per the course instructions so that others may analyse the data". Program
## consists of one R script that performs the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the
##    average of each varibleCreates a second, independent tidy data set with the average
##    of each variable for each activity and each subject.

## Verify and install data packages if necessary
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")

## Load the given activity labels
activity_labels <- read.table("./UCIdata/activity_labels.txt")[,2]

## Load the data features column (variable) names
features <- read.table("./UCIdata/features.txt")[,2]

## Extract the required features from the data set.
extract_features <- grepl("mean|std", features)

## Load, read and process the X_test & y_test data.
X_test <- read.table("./UCIdata/test/X_test.txt")
y_test <- read.table("./UCIdata/test/y_test.txt")
subject_test <- read.table("./UCIdata/test/subject_test.txt")

names(X_test) = features

# Extract the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Load and apply the activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind the subject data together
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Read and process X_train & y_train data.
X_train <- read.table("./UCIdata/train/X_train.txt")
y_train <- read.table("./UCIdata/train/y_train.txt")
subject_train <- read.table("./UCIdata/train/subject_train.txt")
names(X_train) = features

# Extract the mean and standard deviation information.
X_train = X_train[,extract_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function from reshape2
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt") ## Solution data table for assignment