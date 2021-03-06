install.packages("caret")
library(caret)

## Import files
setwd("C:\\Users\\Mahesha\\Desktop\\Desktop\\Data_Science\\Courseera\\Practical Machine learning\\Project")

trainds <- read.csv("pml-training.csv",na.strings=c("NA","#DIV/0!","")) 
testds <- read.csv("pml-testing.csv",na.strings=c("NA","#DIV/0!",""))

dim(trainds)
dim(testds)

## Data explore
#str(trainds)
#summary(trainds)

## Data cleaning

# remove variables with nearly zero variance
nzv <- nearZeroVar(trainds)
trainds <- trainds[, -nzv]

# remove variables that are mostly NA
mostlyNA <- sapply(trainds, function(x) mean(is.na(x))) > 0.75
trainds <- trainds[, mostlyNA==F]

# remove variables which won't contribute much for prediction, in this case 1:5 variables are of no use.
trainds <- trainds[, -(1:5)]

dim(trainds)

# Data Split
set.seed(123)
traindssplit <- createDataPartition(y=trainds$classe, p=0.6, list=F)
trainds1 <- trainds[traindssplit, ]
trainds2 <- trainds[-traindssplit, ]

dim(trainds1)
dim(trainds2)

##Build model , i am using Random forest, Decision Trees and Boosting
## Model with Random forest
install.packages("randomForest")
library(randomForest)

#  use 3-fold CV to select optimal tuning parameters
fitControl <- trainControl(method="cv", number=3, verboseIter=F)

#  model on trainds1
install.packages("e1071")
library(e1071)
model1 <- train(classe ~ ., data=trainds1, method="rf", trControl=fitControl)

# print final model to see tuning parameters it chose
model1$finalModel

# use model1 to predict classe in validation set (trainds2)
preds1 <- predict(model1, newdata=trainds2)

# show confusion matrix to get estimate of out-of-sample error
confusionMatrix(trainds2$classe, preds1)

##################################
## Model with Decision Trees
library(rpart)
set.seed(123)
model2 <- rpart(classe ~ ., data=trainds1, method="class")
preds2 <- predict(model2, trainds2, type = "class")
confusionMatrix(trainds2$classe, preds2)

#######################################
## Model with GBM (Generalised Boosting)
install.packages("gbm")
library(gbm)
set.seed(123)
fitControl <- trainControl(method = "repeatedcv",
                           number = 3,
                           repeats = 1)

model3 <- train(classe ~ ., data=trainds1, method = "gbm",
                 trControl = fitControl,
                 verbose = FALSE)


gbmFinMod3 <- model3$finalModel

preds3 <- predict(model3, newdata=trainds2)
confusionMatrix(trainds2$classe, preds3)

## Models Comparison
## Considering the Accuracy , model1 ( Random Forest) looks better compared to model2 and model3.

## Prediction for test dataset using model1

## Data cleaning for test dataset just like training dataset

# remove variables with nearly zero variance
nzv2 <- nearZeroVar(testds)
testds <- testds[, -nzv2]

# remove variables that are mostly NA
mostlyNA2 <- sapply(testds, function(x) mean(is.na(x))) > 0.75
testds <- testds[, mostlyNA2==F]

# remove variables which won't contribute much for prediction, in this case 1:5 variables are of no use.
testds <- testds[, -(1:5)]

dim(testds)

## Final prediction for test dataset
predsfinal <- predict(model1, newdata=testds)
predsfinal 

## writing to a file
write.table(predsfinal,"Outputfinal1.txt")
write.table(predsfinal,"Outputfinal2.csv")

## writing to individual files
# convert predictions to character vector
predsfinal <- as.character(predsfinal)

# create function to write predictions to files
pml_write_files <- function(x) {
  n <- length(x)
  for(i in 1:n) {
    filename <- paste0("problem_id_", i, ".txt")
    write.table(x[i], file=filename, quote=F, row.names=F, col.names=F)
  }
}

# create prediction files to submit
#pml_write_files(predsfinal)


