##############################################################
# 1) Reading Data, Pre-Processing, and Exploratory Analysis
##############################################################

# Load all necessary R packages into current session
library(ggplot2)
library(dplyr)
library(GGally)
library(car)

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

# Check that the changers took hold
str(mtcars)

# Get correlation matrix of the continuous variables
mtcars[, c(1, 3:7)] %>% 
        ggcorr(label = T)

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

##############################################################
# 2) Regression Model Selection
##############################################################

# fit regression model with all regressors 
# We will use a backwards elimination method to improve the model by eliminating
# variables with high p-value
fit_all <- lm(mpg ~ ., mtcars)
summary(fit_all)

fit2 <- lm(mpg ~ . - cyl, mtcars)
summary(fit2)

fit3 <- lm(mpg ~ . - cyl - vs, mtcars)
summary(fit3)

fit4 <- lm(mpg ~ . - cyl - vs - carb, mtcars)
summary(fit4)

fit5 <- lm(mpg ~ . - cyl - vs - carb - gear, mtcars)
summary(fit5)

fit6 <- lm(mpg ~ . - cyl - vs - carb - gear - drat, mtcars)
summary(fit6)

fit7 <- lm(mpg ~ . - cyl - vs - carb - gear - drat - disp, mtcars)
summary(fit7)
# all models have been improving adjusted R-squared over previous models, except
# fit7
fit8 <- lm(mpg ~ . - cyl - vs - carb - gear - drat - disp - hp, mtcars)
summary(fit8)
# fit8 also got slightly worse, but the remaining regressors had coefficients 
# that became more significant. 
# some combo of am, wt, qseq, plus disp and hp produce the best fitting model

fit_wtqsec <- lm(mpg ~ am + wt + qsec, mtcars)
fit_wtqsechp <- lm(mpg ~ am + wt + qsec + hp, mtcars)
fit_wtqsecdisp <- lm(mpg ~ am + wt + qsec + disp, mtcars)
fit_wtqsechpdisp <- lm(mpg ~ am + wt + qsec + hp + disp, mtcars)

# we will do some ANOVA to compare the four models above
anova(fit, fit_wtqsec, fit_wtqsechp, fit_wtqsechpdisp)
anova(fit, fit_wtqsec, fit_wtqsecdisp, fit_wtqsechpdisp)

# look at variance inflation factor
sqrt(vif(fit_wtqsechpdisp))


##############################################################
# 3) Diagnostics
##############################################################