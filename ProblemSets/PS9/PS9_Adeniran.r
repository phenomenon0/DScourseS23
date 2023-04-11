library(tidyverse)
library(tidymodels)
library(rsample)
install.packages('glmnet')
library(magrittr)
housing <- read_table("http://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data", col_names = FALSE)
names(housing) <- c("crim","zn","indus","chas","nox","rm","age","dis","rad","tax","ptratio","b","lstat","medv")
set.seed(12345)
housing_split <- initial_split(housing, prop = 0.8)
housing_train <- training(housing_split)
housing_test  <- testing(housing_split)
housing_recipe <- recipe (medv ~ ., data = housing ) %>%
  # convert outcome variable to logs
  step_log( all_outcomes ()) %>%
  # convert 0/1 chas to a factor
  step_bin2factor(chas) %>%
  # create interaction term between crime and nox
  step_interact( terms = ~ crim:zn:indus:rm:age:rad:tax:
                   ptratio :b: lstat:dis:nox) %>%
  # create square terms of some continuous variables
  step_poly(crim ,zn ,indus ,rm ,age ,rad ,tax ,ptratio ,b,
             lstat ,dis ,nox , degree =6)
# Run the recipe
housing_prep <- housing_recipe %>% prep( housing_train , retain
                                             = TRUE)
housing_train_prepped <- housing_prep %>% juice
housing_test_prepped <- housing_prep %>% bake(new_data = housing_test)



# create x and y training and test data
housing_train_x <- housing_train_prepped %>% select(-medv)
housing_test_x <- housing_test_prepped %>% select(-medv)
housing_train_y <- housing_train_prepped %>% select( medv)
housing_test_y <- housing_test_prepped %>% select( medv)




tune_spec <- linear_reg(
  penalty = tune(), # tuning parameter
  mixture = 1       # 1 = lasso, 0 = ridge
) %>% 
  set_engine("glmnet") %>%
  set_mode("regression")
# define a grid over which to try different values of lambda
lambda_grid <- grid_regular(penalty(), levels = 50)
# 10-fold cross-validation
rec_folds <- vfold_cv(housing_train_prepped, v = 10)
# Workflow
rec_wf <- workflow() %>%
  add_formula(log(medv) ~ .) %>%
  add_model(tune_spec) #%>%
#add_recipe(housing_recipe)
# Tuning results
rec_res <- rec_wf %>%
  tune_grid(
    resamples = rec_folds,
    grid = lambda_grid
  )
top_rmse  <- show_best(rec_res, metric = "rmse")
best_rmse <- select_best(rec_res, metric = "rmse")
# Now train with tuned lambda
final_lasso <- finalize_workflow(rec_wf, best_rmse)
# Print out results in test set
last_fit(final_lasso, split = housing_split) %>%
  collect_metrics() %>% print
# show best RMSE
top_rmse %>% print(n = 1)

# ... (previous code remains the same)

# Ridge regression
ridge_tune_spec <- linear_reg(
  penalty = tune(), # tuning parameter
  mixture = 0       # 0 = ridge
) %>% 
  set_engine("glmnet") %>%
  set_mode("regression")

# ... (rest of the code remains the same)

# Workflow
ridge_rec_wf <- workflow() %>%
  add_formula(log(medv) ~ .) %>%
  add_model(ridge_tune_spec)

# Tuning results
ridge_rec_res <- ridge_rec_wf %>%
  tune_grid(
    resamples = rec_folds,
    grid = lambda_grid
  )

ridge_top_rmse  <- show_best(ridge_rec_res, metric = "rmse")
ridge_best_rmse <- select_best(ridge_rec_res, metric = "rmse")

# Now train with tuned lambda
ridge_final_model <- finalize_workflow(ridge_rec_wf, ridge_best_rmse)

# Print out results in test set
ridge_last_fit <- last_fit(ridge_final_model, split = housing_split)
ridge_last_fit_metrics <- ridge_last_fit %>%
  collect_metrics()

# Output metrics
print(ridge_last_fit_metrics)

# Show best Ridge RMSE
print(ridge_top_rmse, n = 1)

