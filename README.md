# CMPT 318 – Assignment 3: Continuous and Discrete HMMs


## Overview

This project explores the use of **Hidden Markov Models (HMMs)** on electricity consumption data, specifically analyzing the `Global_active_power` variable. Two HMM configurations were evaluated: one using **continuous variables** and one using **discretized variables**. The analysis involved evaluating model performance across a range of hidden states (nstate = 4 to 16) using the `depmixS4` package in R.

---

## 📊 Question 1: Continuous HMM

- **Data:** 8-hour window from 9am–5pm on Mondays across 52 weeks (total of 481 observations).
- **Method:** Trained 13 univariate HMMs using `depmixS4` with continuous `Global_active_power`.
- **States:** Models ranged from 4 to 16 states.
- **Findings:**
  - **Max Log-Likelihood:** -5535.1058 (at 16 states)
  - **Min BIC:** 13976.6925 (at 16 states)
  - **Trend:** Increasing states improved log-likelihood and reduced BIC.

---

## 🧠 Question 2: Discrete HMM

### 🔎 Theory: Positive Log-Likelihood in Continuous HMMs

- Positive log-likelihoods can appear with continuous HMMs because probability **density functions (PDFs)** can yield values > 1.
- In contrast, discrete HMMs use **probability mass functions (PMFs)**, which are always ≤ 1, ensuring log-likelihoods ≤ 0.

### 🔧 Practical: Discretization Strategy

- **Step 1:** Round `Global_active_power` to nearest **0.5**.
- **Step 2:** Train 13 HMMs (4 to 16 states) with `multinomial()` distribution.
- **Result:**
  - **Max Log-Likelihood:** -25257.9336 (at 16 states)
  - **Min BIC:** 54556.5844 (at 16 states)
  - Discretized models performed **worse** than continuous due to potential loss of information during rounding.

### 🧪 Experiment: Alternate Rounding

- Compared rounding to:
  - Nearest **0.25**
  - Nearest **1 (integer)**
- For `nstate = 4`:
  - Integer rounding yielded better log-likelihood and BIC than 0.25.
  - Indicates the importance of **thoughtful discretization** to retain information.


