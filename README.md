# Mind-Wandering and Divergent Thinking

Final project for **PSYC 5323 RM: R in Psychology** 

**Completed May 2024**

This project explores the relationship between **mind-wandering** and **creative thinking ability** using data from the study *Executive Control, Mind Wandering, and Divergent Thinking*.  

Specifically, the analysis:
- Examines the correlation between the **commonality of responses** and **creativity ratings**
- Uses **ANOVA** to test whether measures of **mind-wandering** predict **creative thinking**
- Applies **linear regression** and **normality tests** to further explore these relationships

---

## 🧠 Data

**Source:** [Executive Control, Mind Wandering, and Divergent Thinking (OSF)](https://osf.io/at5gx/overview)

The dataset includes:
- **Creative thinking ratings (1–5)** on two tasks, scored by five raters  
- **Self-reported daily life off-task thinking**  
- **Task-unrelated thoughts** from executive control measures  
- **Participant IDs** present across multiple CSV files (~950 total)

The project reads in **three CSV files**, matches IDs across them, and merges selected columns into a single wide-format dataset.

Data processing involved:
- Renaming columns for consistency, merging three CSVs by `ID`
- Combining multiple responses into a single wide-format column for each task
- Averaging ratings across raters to create **CreativeResponseFreqBrick** and **CreativeResponseFreqKnife**
- Creating categorical variables `CommonBrick` and `CommonKnife` to flag frequent/common responses  

> *Cleaned data are not included due to research data restrictions.*
---

## 📊 Methods

Analyses performed in **R**:
- Data cleaning and merging with `dplyr` and `reshape2`
- Feature engineering for common vs. uncommon responses
- Visualizations with **ggplot2** (barplots and scatterplots)
- Linear regression models:
  - `CreativeResponseFreqBrick ~ CommonBrick`  
  - `CreativeResponseFreqKnife ~ CommonKnife`  
  - Combined model including mind-wandering rates as predictors
- Assumption checks:
  - **Shapiro-Wilk test** for normality  
  - **Levene’s test** for homogeneity of variance  
  - Residual, Q-Q, and scale-location plots  
- ANOVA to evaluate the effect of mind-wandering on creative thinking  
---

## 📁 Repository Contents

- [`FinalProject.R`](FinalProject.R) – main R script containing all data cleaning, analysis, and visualization code  
- [`Outputs+Visualization/`](Outputs+Visualization/) – folder with regression results, ANOVA tables, and plots  
- [`RM Project Writeup.pdf`](RM%20Project%20Writeup.pdf) – detailed project writeup describing workflow, analysis, and findings  
- [`README.md`](README.md) – project overview, methods, and references


---

## 🔍 Key Findings

- No significant effect of **response commonality** on creativity ratings  
- Some violations of regression assumptions:
  - Brick task: variance homogeneous (Levene’s p = 0.96), residuals suggest mild non-normality  
  - Knife task: variance not homogeneous (Levene’s p = 0.009), residuals show heteroscedasticity  
- Overall, mind-wandering measures did not significantly predict creativity in this dataset  
- Data illustrate the importance of assumption checks and rigorous preprocessing in behavioral research  

---

## 📚 References

Rodriguez‑Boerwinkle, R. M., Welhaf, M. S., Smeekens, B. A., Booth, R. A., Kwapil, T. R., Silvia, P. J., & Kane, M. J. (2024). *Variation in divergent thinking, executive‑control abilities, and mind‑wandering measured in and out of the laboratory.* Creativity Research Journal. https://doi.org/10.1080/10400419.2024.2326336  
Dataset contributors: Matt Welhaf, Michael J. Kane, Rachel A. Booth, Rebekah Rodriguez-Boerwinkle, Paul Silvia, Thomas Kwapil  
[Dataset link](https://osf.io/at5gx/overview)

---

## 🧩 Author

**Joy Kissell**  
Final Project, PSYC 5323: R in Psychology  
University of Virginia
