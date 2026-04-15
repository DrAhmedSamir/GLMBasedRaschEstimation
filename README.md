# GLMBasedRaschEstimation <img src="man/figures/logo.png" align="right" height="139" />

**GLMBasedRaschEstimation**  is an R package developed for educational psychologists and psychometricians. It provides a robust framework for estimating Rasch Model parameters using Generalized Linear Models (GLM).
By leveraging the logistic link function within the GLM framework, this package offers an accessible yet mathematically rigorous alternative to specialized IRT software (like BILOG-MG or MINISTEP) for binary response data.

## Key Features

1. **Data Preprocessing**: Automated cleaning and sorting of binary response matrices.

2. **GLM Estimation**: Item parameter estimation (Difficulty and Slope) using stats::glm.

3. **Rasch Logit Transformation**: Conversion of predicted probabilities into Logit units for individual ability estimation.

4. **Visualization**: High-quality Item Characteristic Curves (ICC) and Rasch difficulty plots.

5. **Ordered Reporting**: Extraction of item difficulty parameters in the original sequence of the test items.

## Installation
Install the development version from GitHub:
Installation

You can install the development version of GLMBasedRaschEstimation from GitHub with:

## install.packages("devtools")
devtools::install_github("DrAhmedSamir/GLMBasedRaschEstimation")

## Example
The following example demonstrates how to use the package for conducting a basic Rasch analysis on binary data:
library(GLMBasedRaschEstimation)

# 1. *Prepare your binary data (Assuming 'my_data' is your 0/1 matrix)*
prepared <- prepare_data(my_data)

# 2. *Fit the Rasch-based GLM model*
results <- fit_binary_irt(prepared$matrix, prepared$total_score)

# 3. *Compute probabilities and Logit abilities*
probs <- compute_Modified_probabilities(results, prepared$total_score)
logits <- rasch_logit(probs)

# 4. *Extract Item Difficulty Table (Logits)*
item_diffs <- extract_rasch_difficulties_ordered(logits)
print(item_diffs)

# 5. *Visualize Rasch Curves (Logit Scores)*
plot_rasch_curves(probs, logits)

# 6. *Visualize Item Curves (Raw Scores - ICC)*
plot_item_curves(prepared$total_score, probs, results)


## Citation:

If you use this package in your research, please cite it as:

**Megahed, A. S.,Khalaf, M., A. & Mougy, I., M. (2026). "GLMBasedRaschEstimation" package for estimating Rasch Model parameters using Generalized Linear Models (GLM).**

## Authors:

**Dr. Ahmed Samir Megahed** (Maintainer) Assistant Professor of Educational Psychology, Faculty of Education, Zagazig University, Egypt.

**Dr. Mustafa Ali Khalaf** Associate Professor Department of Psychology, College of Education Sultan Qaboos University, Muscat, Oman.

**Dr. Ibraheem Mohamed Mougy** Lecturer Department of Psychology College of Education Zagazig University Egypt.
