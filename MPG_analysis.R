# Load all necessary R packages into current session
library(ggplot2)
library(dplyr)

# Read data into R
data("mtcars")

# Take a look at the data
head(mtcars)
?mtcars
summary(mtcars)

# Preliminary model fit: mpg ~ am
fit <- lm(mpg ~ am, mtcars)
fit$coef

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

# At first glance it may seem auto transmission is associated with a 7.245
# increase in mpg, and this is significant with p-value = 0.000285

summary(lm(mpg ~ ., mtcars))
