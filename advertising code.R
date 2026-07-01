# SALES FORECASTING: COMPLETE ANALYSIS

rm(list = ls()) 
set.seed(123) 

library(tidyverse) 
library(GGally)    
library(car)      
library(MASS)      
library(caret)     


advertising <- read.csv("C:/Users/ASUS/Downloads/Telegram Desktop/Advertising.csv")


if ("X" %in% names(advertising)) {
  advertising <- advertising %>% select(-X)
}


#EXPLORATORY DATA ANALYSIS (EDA)
eda_summary <- advertising %>%
  summarise(across(everything(), list(mean = mean, sd = sd, min = min, max = max)))
print(eda_summary)

# Histograms
advertising %>%
  pivot_longer(cols = everything()) %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 20, fill = "steelblue", color = "white") +
  facet_wrap(~name, scales = "free") +
  theme_minimal() +
  labs(title = "Distribution of Variables")

# Correlation matrix and pairwise scatterplots
GGally::ggpairs(
  advertising,
  lower = list(continuous = wrap("points", color = "steelblue", alpha = 0.7)),
  diag  = list(continuous = wrap("densityDiag", fill = "steelblue"))
)


ggplot(advertising, aes(TV, Sales)) +
  geom_point(color = "steelblue", alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  theme_minimal() +
  labs(title = "Sales vs TV Advertising")

ggplot(advertising, aes(Radio, Sales)) +
  geom_point(color = "steelblue", alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  theme_minimal() +
  labs(title = "Sales vs Radio Advertising")


ggplot(advertising, aes(Newspaper, Sales)) +
  geom_point(color = "steelblue", alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  theme_minimal() +
  labs(title = "Sales vs Newspaper Advertising")


#MODELING
model_full <- lm(Sales ~ TV + Radio + Newspaper, data = advertising)
summary(model_full)


model_reduced <- lm(Sales ~ TV + Radio, data = advertising)
summary(model_reduced)


cat("Adj R-Squared Full:", summary(model_full)$adj.r.squared, "\n")
cat("Adj R-Squared Reduced:", summary(model_reduced)$adj.r.squared, "\n")





#DIAGNOSTICS AND SELECTION

# Visual diagnostics (Residuals, Normality, etc.)
par(mfrow = c(2, 2))
plot(model_full, col = "blue", col.smooth = "red") 
par(mfrow = c(1, 1))

#Cook's Distance Block
plot(cooks.distance(model_full),
     type = "h",                  
     main = "Cook's Distance",
     ylab = "Cook's Distance",
     col = "blue")                 
abline(h = 4 / nrow(advertising), col = "red", lty = 2) 


# Check for Multicollinearity (VIF)
vif(model_full)

# Partial F-test to compare Full and Reduced models
anova(model_reduced, model_full)

# Automated Stepwise Selection using AIC
model_step <- stepAIC(model_full, direction = "both", trace = FALSE)
summary(model_step)



#FINAL MODEL EVALUATION
final_model <- model_reduced
summary(final_model)


confint(final_model)


predictions <- predict(final_model, newdata = advertising)


results <- data.frame(
  Actual = advertising$Sales,
  Predicted = predictions
)

# Plot Actual vs Predicted Sales
ggplot(results, aes(Actual, Predicted)) +
  geom_point(color = "steelblue", alpha = 0.7) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Actual vs Predicted Sales", x = "Actual Sales", y = "Predicted Sales")

cat("Final RMSE:", RMSE(predictions, advertising$Sales), "\n")
cat("Final R2:", R2(predictions, advertising$Sales), "\n")