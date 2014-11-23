#loading train data
train_s = read.table("UCI HAR Dataset/train/subject_train.txt", col.names=c("subject_id"))
train_s$ID <- as.numeric(rownames(train_s))

train_x = read.table("UCI HAR Dataset/train/X_train.txt")
train_x$ID <- as.numeric(rownames(train_x))

train_y = read.table("UCI HAR Dataset/train/y_train.txt", col.names=c("activity_id"))
train_y$ID <- as.numeric(rownames(train_y))

#loading test data
test_s = read.table("UCI HAR Dataset/test/subject_test.txt", col.names=c("subject_id"))
test_s$ID <- as.numeric(rownames(test_s))

test_x = read.table("UCI HAR Dataset/test/X_test.txt")
test_x$ID <- as.numeric(rownames(test_x))

test_y = read.table("UCI HAR Dataset/test/y_test.txt", col.names=c("activity_id"))
test_y$ID <- as.numeric(rownames(test_y))

#merging data
data_s <- merge(train_s, test_s, all=TRUE)
data_x <- merge(train_x, test_x, all=TRUE)
data_y <- merge(train_y, test_y, all=TRUE)

data <- merge(data_s, data_y, all=TRUE)
data <- merge(data, train_x, all=TRUE)
summary(data)

#loading features
features = read.table("UCI HAR Dataset/features.txt", col.names=c("feature_id", "feature_label"),)

#extracting mean and std measurements
features_sel <- features[grepl("mean\\(\\)", features$feature_label) | grepl("std\\(\\)", features$feature_label), ]

data <- data[, c(c(1, 2, 3), features_sel$feature_id + 3) ]
summary(data)

#loading and merging labels
labels = read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activity_id", "activity_label"),)
data = merge(data, labels)

features_sel$feature_label = gsub("\\(\\)", "", features_sel$feature_label)
features_sel$feature_label = gsub("-", ".", features_sel$feature_label)

for (i in 1: length(selected_features$feature_label)){
    colnames(data)[i + 3] <- features_sel$feature_label[i]
}

#creating tidy data
data_not <- c("ID","activity_label")
data <- data[,!(names(data) %in% data_not)]
data_agg <-aggregate(data, by=list(subject = data$subject_id, activity = data$activity_id), FUN=mean, na.rm=TRUE)
data_not <- c("subject","activity")
data_agg <- data_agg[,!(names(data_agg) %in% data_not)]
data_agg = merge(data_agg, labels)

#writting tidy data
write.table(data_agg, file="tidy_data.txt", row.name=FALSE)
