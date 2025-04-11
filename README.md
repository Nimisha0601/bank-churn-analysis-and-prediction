# Bank Churn Analysis and Prediction

This project analyzes customer churn for a bank using a combination of SQL-based data analysis and machine learning models in Python. The aim is to understand why customers leave and to predict churn, enabling proactive retention strategies.

## Tools Used
- **SQL (Microsoft SQL Server)** – for data exploration and insight generation  
- **Python** – for EDA, feature engineering, model building & evaluation  
- **GitHub** – for version control and project sharing  

## Project Highlights
- Explored key churn patterns across gender, age, region, balance, and products using SQL
- Performed hypothesis testing (Chi-Square, t-test, ANOVA) to validate churn factors
- Built and tuned ML models: Random Forest, XGBoost, and Gradient Boosting
- Selected XGBoost as the final model with **88.9% recall** and **94.4% ROC AUC**

## Business Use Case
Banks lose significant revenue when valuable customers churn. This model helps:
- Identify at-risk customers
- Understand churn-driving features
- Empower data-driven retention efforts

## File Structure
- `bank_churn_sql_analysis.sql` – SQL queries for churn analysis  
- `bank_churn_modeling.py` – Python code for preprocessing, modeling, evaluation  
- `README.md` – Project summary and instructions  
- `Bank_Churn.csv` - Dataset file in csv

## Final Model Metrics (XGBoost)
- Accuracy: **87.13%**
- Precision: **86.15%**
- Recall: **88.92%**
- F1 Score: **87.69%**
- ROC AUC: **94.49%**

## Conclusion
- XGBoost outperformed all other models after tuning
- Key churn drivers: high balance, multiple products, female customers, certain regions
- Model can be used by banks to reduce churn and improve customer retention
