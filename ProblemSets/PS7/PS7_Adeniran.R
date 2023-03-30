install.packages("mice")
install.packages("modelsummary")
library(modelsummary)
library(mice)

# set the working directory
data <- read.csv("C:\\Users\\Admin\\Documents\\DataEcons\\Femi -DS23\\ProblemSets\\PS7\\wages.csv")
data <- data[complete.cases(data[, c("hgc", "tenure")]), ]
head(data)
first<- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married, data = data)
modelsummary(first, output = 'first.tex')
datasummary_skim(data, output = 'summaryx.tex')


mod <- lm(logwage ~ married, data)
modelsummary(mod,output ='summary.tex')


data <- data[!is.na(mydata$logwage), ]
omitdata <- na.omit(data)

# fit a linear model to the data with tenure squared
omit<- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married, data = omitdata)
modelsummary(omit,output ='omittedf.tex')

data <- read.csv("C:\\Users\\Admin\\Documents\\DataEcons\\Femi -DS23\\ProblemSets\\PS7\\wages.csv")
data <- data[complete.cases(data[, c("hgc", "tenure")]), ]
mean_logwage <- mean(data$logwage, na.rm = TRUE)
imputed <- mice(data, method = "mean")
completed <- complete(imputed)
meanly<- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married, data = completed)
modelsummary(meanly,output ='mean.tex')

final <- list()
final[['first']] <- first
final[['listwise']] <- omit
final[['mean']] <-meanly
modelsummary(final,output ='final.tex')



