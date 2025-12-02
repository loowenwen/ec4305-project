# EC4305 Applied Econometrics Project

Applied econometrics project on Singapore HDB resale prices for EC4305. The repo contains notebooks and scripts for exploratory data analysis and a suite of machine learning models.

## Project layout
- `data/`: input dataset `HDB_data_2021_sample.xlsx` plus derived CSVs (e.g., `summary_statistics.csv`).
- `figures/`: plots exported from the notebooks.
- `src/`: analysis notebooks (`regression_models.ipynb`, `tree_models.ipynb`, `penalised_regression.ipynb`, `knn_pcr_nn.ipynb`, `hybrid_learning.ipynb`), R EDA script (`eda.R`), and helper Python scripts for filtering/aggregation.

## Running the notebooks and scripts
- The notebooks and R script load data via a relative path defined inside each file, typically `../data/HDB_data_2021_sample.xlsx`. Run them from the `src` directory (e.g., `jupyter lab src/penalised_regression.ipynb`) so the path resolves. If you prefer running from the repo root, update the `DATA_PATH` variable in the notebooks to `data/HDB_data_2021_sample.xlsx`.
- Python dependencies: `pandas`, `numpy`, `scikit-learn`, `matplotlib`, `seaborn`, `jupyter` (install with `pip install pandas numpy scikit-learn matplotlib seaborn jupyter`).
- R dependencies for `eda.R`: `readxl`, `dplyr`, `tidyr`, `ggplot2`, `stringr`, `reshape2`.

## What’s inside
- Regression baselines and polynomial features: `regression_models.ipynb`
- Tree-based models and stacking: `tree_models.ipynb`
- Lasso/Ridge/ElasticNet with scaling and PCA: `penalised_regression.ipynb`
- KNN, principal components regression, and MLP neural net: `knn_pcr_nn.ipynb`
- Hybrid workflows combining feature engineering and regularisation: `hybrid_learning.ipynb`
- Data prep utilities: `file_filter_only.py`, `file_filter_with_agg.py`, `append_inflation.py` (CSV filtering/aggregation)
