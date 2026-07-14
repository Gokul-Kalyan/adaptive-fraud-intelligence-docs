# Drift Detection

**Document ID:** AFIP-011

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Monitoring

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

Machine learning models are trained using historical datasets. However, the characteristics of production data may gradually change over time due to evolving user behavior, fraud patterns, or operational changes.

If these changes become significant, model performance may deteriorate even though the model itself has not changed.

To address this challenge, the Adaptive Fraud Intelligence Platform includes a lightweight data drift detection module that continuously compares production transaction data with the original training dataset.

This document describes the design, implementation, workflow, statistical methodology, and engineering decisions behind the drift detection component.

---

# 2. Why Drift Detection?

A deployed machine learning model should not be considered permanently reliable after deployment.

Several factors may alter the characteristics of production data, including:

- Changes in customer transaction behaviour.
- New fraud strategies.
- Seasonal spending patterns.
- Business growth.
- Market fluctuations.

When production data no longer resembles the data used during training, prediction quality may gradually decline.

Drift detection provides an early warning mechanism before model performance becomes significantly affected.

---

# 3. Types of Drift

Production machine learning systems commonly experience multiple forms of drift.

### Data Drift

Changes in the statistical distribution of input features.

Example:

```
Training Amounts

↓

100
150
200
250
```

Production

```
↓

5000
6500
8200
10000
```

The feature distribution has changed.

---

### Concept Drift

The relationship between the input variables and fraud labels changes.

Example:

Previously,

large transfers were usually fraudulent.

Later,

fraudsters begin making many small transfers.

Although the feature distribution may remain similar, the fraud patterns have changed.

The current implementation focuses only on **data drift**.

---

# 4. Monitoring Architecture

The drift detection module compares historical training data with production inference records.

```
Training Dataset
        │
        ▼
Transaction Amount
        │
        │
        │
Production Database
        │
        ▼
Prediction Amount
        │
        ▼
KS Statistical Test
        │
        ▼
Drift Decision
        │
        ▼
Dashboard Indicator
```

The module executes independently of the prediction service.

---

# 5. Data Sources

Two independent datasets are used.

## Training Data

Loaded from

```
data/raw/fraud.csv
```

Only the transaction amount column is used.

```
Training Dataset

↓

Amount
```

---

## Production Data

Loaded from PostgreSQL.

```
SELECT amount
FROM predictions
```

The production data consists of transaction amounts recorded after successful API predictions.

---

# 6. Why Monitor the Transaction Amount?

The current implementation monitors only the **transaction amount** feature.

This design was intentionally selected to provide a lightweight and interpretable demonstration of production monitoring.

The transaction amount is a continuous numerical feature that is well suited for statistical distribution comparison using the Kolmogorov–Smirnov Test.

Future versions may extend drift detection to multiple numerical features.

---

# 7. Kolmogorov–Smirnov Test

The platform uses the two-sample Kolmogorov–Smirnov (KS) Test.

```
ks_2samp()
```

The KS Test compares two numerical distributions.

```
Training Distribution

↓

Production Distribution

↓

Maximum Difference

↓

KS Statistic

↓

P-value
```

Unlike model evaluation metrics, the KS Test does not measure prediction accuracy.

Instead, it measures whether the statistical distribution of production data differs significantly from the training data.

---

# 8. Statistical Hypothesis

The KS Test evaluates two hypotheses.

### Null Hypothesis (H₀)

The training data and production data originate from the same distribution.

---

### Alternative Hypothesis (H₁)

The two datasets originate from different distributions.

---

Decision Rule

```
p-value ≥ 0.05

↓

NO DRIFT
```

```
p-value < 0.05

↓

DRIFT DETECTED
```

This threshold is implemented directly within the monitoring module.

---

# 9. Minimum Data Requirement

Before performing statistical testing, the module verifies that sufficient production data is available.

```
Production Records

↓

Less than 5

↓

NOT ENOUGH DATA
```

This prevents unreliable statistical conclusions from extremely small production samples.

---

# 10. Drift Detection Workflow

```
Load Training Data
        │
        ▼
Load Production Data
        │
        ▼
Check Sample Size
        │
        ▼
Run KS Test
        │
        ▼
Compute p-value
        │
        ▼
Determine Drift Status
        │
        ▼
Return Dashboard Status
```

The workflow is executed whenever drift status is requested.

---

# 11. Dashboard Integration

The monitoring dashboard retrieves drift status using

```
get_drift_status()
```

Possible outputs include:

```
🟢 NO DRIFT
```

```
🔴 DRIFT DETECTED
```

```
🟡 NOT ENOUGH DATA
```

This allows system operators to identify changes in production data without manually executing statistical analysis.

---

# 12. Engineering Decisions

Several engineering decisions influenced the implementation.

### Decision 1

The KS Test was selected because it provides a lightweight statistical method for comparing two numerical distributions without requiring model retraining.

---

### Decision 2

Only the transaction amount is monitored in the current implementation to keep the monitoring workflow computationally efficient and easy to interpret.

---

### Decision 3

Training data is loaded directly from the original dataset while production data is retrieved from PostgreSQL.

This provides a clear separation between historical and operational data.

---

### Decision 4

The drift detection module operates independently of the prediction API.

This prevents monitoring activities from affecting prediction latency.

---

# 13. Challenges

The primary challenges encountered during implementation included:

- Understanding statistical drift detection techniques.
- Comparing historical and production datasets.
- Selecting an appropriate statistical test.
- Integrating drift monitoring with the Streamlit dashboard.

---

# 14. Limitations

The current implementation has several limitations.

- Only one feature (transaction amount) is monitored.
- Concept drift is not detected.
- Automatic alerts are not implemented.
- Drift history is not stored.
- Automatic model retraining is not supported.

These limitations were accepted to maintain a lightweight monitoring architecture.

---

# 15. Lessons Learned

Implementing drift detection reinforced several important MLOps concepts.

- Machine learning models require continuous monitoring after deployment.
- Production data should be compared with training data.
- Statistical tests can identify distribution changes before model performance visibly degrades.
- Monitoring should remain independent from prediction services.

---

# 16. Future Improvements

Future versions may include:

- Multi-feature drift detection.
- Concept drift monitoring.
- Population Stability Index (PSI).
- Jensen–Shannon divergence.
- Automatic alert generation.
- Drift history visualization.
- Automatic model retraining recommendations.

---

# 17. Interview Questions

1. What is data drift?
2. What is the difference between data drift and concept drift?
3. Why did you choose the KS Test?
4. Why is only the transaction amount monitored?
5. Why is a minimum number of production records required?
6. What does a p-value below 0.05 indicate?
7. Why should drift detection remain separate from the prediction API?

---

# References

1. Scipy Statistics Documentation
2. Kolmogorov–Smirnov Test Documentation
3. Adaptive Fraud Intelligence Platform Source Code