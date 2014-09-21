#Defining file names and places

data.file <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
local.data.file <- './original-dataset.zip'
local.data.dir <- './UCI HAR Dataset'
tidy.data.file <- './tidy-UCI-HAR-dataset.csv'
tidy.avgs.data.file <- './tidy-UCI-HAR-avgs-dataset.csv'

# Making sure the original data file is in the working directory, downloading it if it is not
if (! file.exists(local.data.file)) {
    if (download.file.automatically) {
        download.file(data.file,
                      destfile = local.data.file, method = 'curl')
    }
}

# Warning if file is not present
if (! file.exists(local.data.file)) {
    stop(paste(local.data.file, 'not present in working directory.'))
}

# Unzip the downloaded file
if (! file.exists(local.data.dir)) {
    unzip(local.data.file)
}

# Warning if unzip failed
if (! file.exists(local.data.dir)) {
    stop(paste('Unable to unpack the compressed data.'))
}

# Reading labels (activities)
activ <- read.table(paste(local.data.dir, 'activity_labels.txt', sep = '/'),
                 header = FALSE)
names(activ) <- c('id', 'name')

# Reading labels (features)
features <- read.table(paste(local.data.dir, 'features.txt', sep = '/'),
                 header = FALSE)
names(features) <- c('id', 'name')

# Reading the data files, assigning meaningful column names
train.X <- read.table(paste(local.data.dir, 'train', 'X_train.txt', sep = '/'),
                      header = FALSE)
names(train.X) <- features$name
train.y <- read.table(paste(local.data.dir, 'train', 'y_train.txt', sep = '/'),
                      header = FALSE)
names(train.y) <- c('activity')
train.subject <- read.table(paste(local.data.dir, 'train', 'subject_train.txt',
                                  sep = '/'),
                            header = FALSE)
names(train.subject) <- c('subject')
test.X <- read.table(paste(local.data.dir, 'test', 'X_test.txt', sep = '/'),
                      header = FALSE)
names(test.X) <- features$name
test.y <- read.table(paste(local.data.dir, 'test', 'y_test.txt', sep = '/'),
                      header = FALSE)
names(test.y) <- c('activity')
test.subject <- read.table(paste(local.data.dir, 'test', 'subject_test.txt',
                                  sep = '/'),
                            header = FALSE)
names(test.subject) <- c('subject')

# Merging the training and test sets
X <- rbind(train.X, test.X)
y <- rbind(train.y, test.y)
subject <- rbind(train.subject, test.subject)

# Extracting only the mean and SD features
X <- X[, grep('mean|std', features$name)]

# Converting activity labels to meaningful names
y$activity <- activ[y$activity,]$name

# Merging partial data sets together
tidy.data.set <- cbind(subject, y, X)

# Dumping the full data set
write.csv(tidy.data.set, tidy.data.file)

# Compute the averages grouped by subject and activity
tidy.avgs.data.set <- aggregate(tidy.data.set[, 3:dim(tidy.data.set)[2]],
                                list(tidy.data.set$subject,
                                     tidy.data.set$activity),
                                mean)
names(tidy.avgs.data.set)[1:2] <- c('subject', 'activity')

# Dumping the final (calculated) data set
write.csv(tidy.avgs.data.set, tidy.avgs.data.file)
