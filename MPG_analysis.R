# Load all necessary R packages into current session
library(ggplot2)
library(dplyr)
library(GGally)

# Read data into R
data("mtcars")

# Take a look at the data
head(mtcars)
?mtcars
summary(mtcars)
str(mtcars)
# It seems like vs & am are binary factor variables
# cyl, gear, & carb are multi level factor variables

# Convert to factor variables
mtcars$vs <- as.factor(mtcars$vs)
mtcars$am <- as.factor(mtcars$am)
mtcars$cyl <- as.factor(mtcars$cyl)
mtcars$gear <- as.factor(mtcars$gear)
mtcars$carb <- as.factor(mtcars$carb)

# Check that the changers took hold
str(mtcars)

# Preliminary model fit: mpg ~ am
fit <- lm(mpg ~ am, mtcars)

# Plot mpg vs am
ggplot(mtcars,
       aes(x = am,
           y = mpg)) +
        geom_point()

# Look at the mean mpg for cars with/without automatic 
mtcars %>% group_by(am) %>%
        summarize(mean = mean(mpg))

# Take another look at the model/coefficients
summary(fit)

# At first glance it may seem manual transmission is associated with a 7.245
# increase in mpg, and this is significant with p-value = 0.000285

# fit regression model with all regressors 
fit_all <- lm(mpg ~ ., mtcars)
summary(fit_all)

# Get smaller dataframe with only the continuous variables
mt_cont <- mtcars[, c(1, 3:7)]
mt_cat <- mtcars[, c(2, 8:11)]

ggpairs(mt_cont)
ggcorr(mt_cont, label = T)

# We will use a backwards elimination method to improve the model by eliminating
# variables with high p-value
fit2 <- lm(mpg ~ . - cyl, mtcars)
fit3 <- lm(mpg ~ . - cyl - vs, mtcars)
fit4 <- lm(mpg ~ . - cyl - vs - carb, mtcars)
fit5 <- lm(mpg ~ . - cyl - vs - carb - gear, mtcars)
fit6 <- lm(mpg ~ . - cyl - vs - carb - gear - drat, mtcars)
fit7 <- lm(mpg ~ . - cyl - vs - carb - gear - drat - disp, mtcars)
# all models have been improving adjusted R-squared over previous models, except
# fit7
fit8 <- lm(mpg ~ . - cyl - vs - carb - gear - drat - disp - hp, mtcars)
# fit8 also got slightly worse, but the remaining regressors had coefficients 
# that became more significant. 
# some combo of am, wt, qseq, plus wt and hp produce the best fitting model
