# Import Libraries ----
getwd()
library(dplyr)
library(ggplot2)
library(hms)
library(lubridate)
library(depmixS4)

# Preprocessing ----
my_df <- read.csv("Group_Assignment_Dataset.txt", header = TRUE)

# Columns in dataframe with electricity consumption data
data_cols <- colnames(my_df[, 3:ncol(my_df)])

# Data frame for storing Z-scores for each data point
z_score_df <- data.frame(
  Date = my_df$Date,
  Time = my_df$Time
)

# Compute Z-score for each feature, set point anomalies as NA to be
# interpolated later. Doing this instead of just removing anomalous rows
# allows us to avoid time gaps in our data.
for (i in data_cols) {
  z_score_df[[i]] <- scale(my_df[[i]], center = TRUE, scale = TRUE)
  my_df[[i]][z_score_df[[i]] > 3] <- NA
}

# Perform linear interpolation for the NA values in dataframe
xn <- seq_len(nrow(my_df))
for (i in data_cols) {
  my_df[[i]] <- data.frame(approx(xn, my_df[[i]], xn))$y
}

# Time Window Selection ----

# Convert date and time strings to a usable format
my_df$Date <- as.Date(dmy(my_df$Date))
my_df$Time <- as_hms(my_df$Time)

# Select all rows for the specified weekday and time
weekday <- 1
start_time <- as_hms("09:00:00")
end_time <- as_hms("17:00:00")
my_df <- my_df %>%
  filter(wday(Date) == weekday, between(Time, start_time, end_time))

# Calculate the number of observations per week
time_period <- as.numeric(difftime(end_time, start_time, units = "mins")) + 1

# Utility functions ----
set.seed(1)
time_series_length <- rep(time_period, each = 52)
coeff <- 10

# Define Model Training Function
hmm <- function(data, nstate, family) {
  model <- depmix(response = Global_active_power ~ 1,
                  data = data,
                  nstates = nstate,
                  family = family,
                  ntimes = time_series_length)
  fit_model <- fit(model)
  return(c(logLik(fit_model), BIC(fit_model)))
}

# Define Plotting Function
plot_loglik_bic <- function(data, plot_name) {
  ggplot(data = data, mapping = aes(x = nstate)) +
    geom_line(mapping = aes(y = logLik, color = "Log-Liklihood")) +
    geom_point(mapping = aes(y = logLik, color = "Log-Liklihood")) +
    labs(color = "Metrics") +
    scale_y_continuous(name = "Log-Likelihood")
  ggsave(filename = paste(plot_name, "LogLik.png", sep = " "), dpi = 600)
  ggplot(data = data, mapping = aes(x = nstate)) +
    geom_line(mapping = aes(y = BIC / coeff, color = "BIC")) +
    geom_point(mapping = aes(y = BIC / coeff, color = "BIC")) +
    labs(color = "Metrics") +
    scale_y_continuous(name = "BIC")
  ggsave(filename = paste(plot_name, "BIC.png", sep = " "), dpi = 600)
}

# Q1 Model Training ----
results <- data.frame(nstate = 4:16)
stats <- apply(results, 1, function(row) hmm(my_df, row[1], gaussian()))
results <- cbind(results, logLik = stats[1, ], BIC = stats[2, ])
plot_loglik_bic(results, "q1")

# Q2 Model Training ----
my_df_2 <- my_df
my_df_2$Global_active_power <- round(my_df_2$Global_active_power / 0.5) * 0.5
results2 <- data.frame(nstate = 4:16)
stats2 <- apply(results2, 1, function(row) hmm(my_df_2, row[1], multinomial()))
results2 <- cbind(results2, logLik = stats2[1, ], BIC = stats2[2, ])
plot_loglik_bic(results2, "q2")
