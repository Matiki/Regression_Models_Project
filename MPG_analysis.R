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

# Plot mpg vs am
ggplot(mtcars,
       aes(x = am,
           y = mpg)) +
        geom_point()

# Look at the mean mpg for cars with/without automatic 
mtcars %>% group_by(am) %>%
        summarize(mean = mean(mpg))

# Check to see if mpg is normally distributed
ggplot(mtcars, aes(mpg)) +
        geom_density() +
        xlim(0, 50) + 
        geom_vline(xintercept = mean(mtcars$mpg),
                   color = "red",
                   linetype = "dashed") +
        geom_vline(xintercept = mean(mtcars$mpg) - 2 * sd(mtcars$mpg),
                   color = "blue",
                   linetype = "dashed") +
        geom_vline(xintercept = mean(mtcars$mpg) + 2 * sd(mtcars$mpg),
                   color = "blue",
                   linetype = "dashed") 

# Welch Two Sample T test
t.test(mpg ~ am, data= mtcars, 
       var.equal = FALSE, paired=FALSE, conf.level = .95)

# Preliminary model fit: mpg ~ am
fit <- lm(mpg ~ am, mtcars)

# Take a look at the model/coefficients
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
summary(fit_wtqsec)
fit_wtqsechp <- lm(mpg ~ am + wt + qsec + hp, mtcars)
summary(fit_wtqsechp)
fit_wtqsecdisp <- lm(mpg ~ am + wt + qsec + disp, mtcars)
summary(fit_wtqsecdisp)
fit_wtqsechpdisp <- lm(mpg ~ am + wt + qsec + hp + disp, mtcars)
summary(fit_wtqsechpdisp)

# we will do some ANOVA to compare the four models above
fit_wt <- lm(mpg ~ am + wt, mtcars)
anova(fit, fit_wt, fit_wtqsec, fit_wtqsechp, fit_wtqsechpdisp)
anova(fit, fit_wt, fit_wtqsec, fit_wtqsecdisp, fit_wtqsechpdisp)

# look at variance inflation factor
sqrt(vif(fit_wtqsec))
sqrt(vif(fit_wtqsechp))
sqrt(vif(fit_wtqsecdisp))
sqrt(vif(fit_wtqsechpdisp))

# ANOVA seems to indicate there is not a statistically significant difference 
# between fit_wtqsec and other models which include hp and disp as regressors
# Therefore we choose to include only am, wt, and qsec in our regression model
fit_final <- lm(mpg ~ am + wt + qsec, mtcars)
summary(fit_final)

##############################################################
# 3) Diagnostics
##############################################################

# We'll do some diagnostics plots looking for any patterns with GGplot2
# Residuals vs fitted values
ggplot(fit_final,
       aes(x = .fitted, y = .resid)) +
        geom_point() +
        geom_smooth() + 
        geom_hline(yintercept = 0,
                   col = "red",
                   linetype = "dashed") +
        labs(title = "Residuals vs Fitted Values",
             x = "Fitted Values",
             y = "Residuals")

# Normal QQ plot
ggplot(fit_final) +
        geom_qq(aes(sample = .stdresid)) +
        geom_abline(intercept = 0, slope = 1, 
                    linetype = "dashed", col = "red") +
        labs(title = "Normal Q-Q Plot",
             x = "Theoretical Quantiles",
             y = "Standardized Residuals") 

# Scale location plot
ggplot(fit_final,
       aes(y = sqrt(abs(.stdresid)),
           x = .fitted)) + 
        geom_point() +
        geom_smooth() +
        labs(title = "Scale Location Plot",
             x = "Fitted Values",
             y = expression(sqrt("|Standardized residuals|")))


# same plots using base R
# par(mfrow = c(3, 2))
# plot(fit_final) 
plot(fit_final, which = 4)
plot(fit_final, which = 6)


##############################################################
# 4) Inference
##############################################################
summary(fit_final)$coef
confint(fit_final)

# We expect on average, cars with manual transmission to get 2.94 mpg more than
# cars with automatic transmission, while holding other regressors fixed.
# Our estimate is statistically significant for alpha = 0.05, and has a 
# p-value of 0.0467. 
# We can construct a 95% confidence interval and see that we are 95% confident 
# that our estimate of the increase in mpg in manual transmission cars lies 
# between 0.0457 and 5.823.
# Therefore we conclude that manual transmission is associated with better mpg