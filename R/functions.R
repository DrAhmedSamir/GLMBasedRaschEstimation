#' Prepare Data for IRT Analysis
#' @param data A data frame or matrix of binary responses (0 and 1).
#' @return A list containing the numeric matrix and the calculated total scores.
#' @export
prepare_data <- function(data) {
  data_mat <- as.matrix(as.data.frame(data))
  data_mat <- apply(data_mat, 2, as.numeric)
  total_score <- rowSums(data_mat)

  if (is.unsorted(rev(total_score))) {
    order_index <- order(total_score, decreasing = TRUE)
    data_mat <- data_mat[order_index, ]
    total_score <- rowSums(data_mat)
  }
  return(list(matrix = data_mat, total_score = total_score))
}

#' Fit Binary IRT Model using GLM
#' @param data_mat A numeric matrix of responses.
#' @param total_score A numeric vector of total scores.
#' @return A data frame containing Intercept, Slope, and Threshold for each item.
#' @export
fit_binary_irt <- function(data_mat, total_score) {
  results <- data.frame(Item = colnames(data_mat), Intercept = NA, Slope = NA)
  for(i in 1:ncol(data_mat)) {
    model <- stats::glm(data_mat[,i] ~ total_score, family = stats::binomial(link = "logit"))
    results$Intercept[i] <- stats::coef(model)[1]
    results$Slope[i]     <- stats::coef(model)[2]
  }
  results$threshold <- -results$Intercept / results$Slope
  return(results)
}

#' Compute Modified Item Response Probabilities
#' @param results The data frame returned by fit_binary_irt.
#' @param theta_all A numeric vector representing ability levels (total scores).
#' @return A matrix of predicted probabilities.
#' @export
compute_Modified_probabilities <- function(results, theta_all) {
  Modified_prob_matrix <- matrix(NA, nrow = length(theta_all), ncol = nrow(results))
  for(i in 1:nrow(results)) {
    Modified_logit <- theta_all - results$threshold[i]
    Modified_prob_matrix[, i] <- exp(Modified_logit) / (1 + exp(Modified_logit))
  }
  colnames(Modified_prob_matrix) <- results$Item
  return(Modified_prob_matrix)
}

#' Plot Item Characteristic Curves (ICC)
#' @param theta_all A numeric vector of ability levels.
#' @param Modified_prob_matrix The matrix returned by compute_Modified_probabilities.
#' @param results The data frame returned by fit_binary_irt.
#' @export
plot_item_curves <- function(theta_all, Modified_prob_matrix, results) {
  graphics::par(mfrow = c(1, 1))
  for (i in 1:ncol(Modified_prob_matrix)) {
    ord <- order(theta_all)
    graphics::plot(theta_all[ord], Modified_prob_matrix[ord, i], type = "l", lwd = 2,
                   col = "blue", ylim = c(0, 1),
                   xlab = "Ability (Total Score)", ylab = "Probability",
                   main = paste("ICC for Item:", colnames(Modified_prob_matrix)[i]))
    graphics::grid()
    graphics::abline(h = 0.5, v = results$threshold[i], col = "red", lty = 2)

    if(i < ncol(Modified_prob_matrix)) readline(prompt="Press [Enter] for next plot...")
  }
}

#' Compute Logit and Row Means
#' @param prob_matrix The matrix returned by compute_Modified_probabilities.
#' @return A matrix of logits with an added column for row means (Student Ability).
#' @export
rasch_logit <- function(prob_matrix) {
  # 1. تحويل الاحتمالات إلى لوجيت
  logit_matrix <- log(prob_matrix / (1 - prob_matrix))
  # 2. حساب متوسط كل صف
  row_means <- rowMeans(logit_matrix, na.rm = TRUE)
  # 3. إضافة المتوسط كعمود جديد
  final_matrix <- cbind(logit_matrix, Row_Mean_Logit = row_means)
  colnames(final_matrix)[1:ncol(logit_matrix)] <- colnames(prob_matrix)
  return(final_matrix)
}

#' Plot Rasch Item Curves
#' @param prob_matrix The matrix returned by compute_Modified_probabilities.
#' @param final_logit_matrix The matrix returned by rasch_logit.
#' @export
plot_rasch_curves <- function(prob_matrix, final_logit_matrix) {
  last_col_idx <- ncol(final_logit_matrix)
  row_mean_logit <- final_logit_matrix[, last_col_idx]
  num_items <- ncol(prob_matrix)

  graphics::par(mfrow = c(1, 1))
  for (i in 1:num_items) {
    item_probs <- prob_matrix[, i]
    item_name <- colnames(prob_matrix)[i]
    difficulty_value <- (final_logit_matrix[, last_col_idx] - final_logit_matrix[, i])[1]

    ord <- order(row_mean_logit)
    graphics::plot(row_mean_logit[ord], item_probs[ord],
                   type = "l", lwd = 2, col = "blue",
                   ylim = c(0, 1),
                   xlab = "Student Ability (Row Mean Logit)",
                   ylab = "Probability of Correct Response",
                   main = paste("Rasch Curve for Item:", item_name))
    graphics::grid()
    graphics::abline(h = 0.5, col = "red", lty = 2)
    graphics::abline(v = difficulty_value, col = "darkgreen", lty = 3, lwd = 2)
    graphics::text(x = difficulty_value, y = 0.2,
                   labels = paste("Difficulty =", round(difficulty_value, 2)),
                   col = "darkgreen", pos = 4, cex = 0.8)

    if (i < num_items) {
      readline(prompt = "Press [Enter] to see the next item curve...")
    }
  }
}

#' Extract Rasch Item Difficulties in Original Order
#' @param final_logit_matrix The matrix returned by rasch_logit.
#' @return A data frame of item difficulties.
#' @export
extract_rasch_difficulties_ordered <- function(final_logit_matrix) {
  last_col_idx <- ncol(final_logit_matrix)
  num_items <- last_col_idx - 1
  diff_values <- numeric(num_items)
  item_names <- colnames(final_logit_matrix)[1:num_items]

  for (i in 1:num_items) {
    diff_values[i] <- (final_logit_matrix[, last_col_idx] - final_logit_matrix[, i])[1]
  }

  difficulty_table <- data.frame(
    Item_Number = 1:num_items,
    Item_Name = item_names,
    Difficulty_Logit = round(diff_values, 4)
  )
  return(difficulty_table)
}
