# Feature Engineering

**Document ID:** AFIP-004

**Project:** Adaptive Fraud Intelligence Platform

**Document Version:** 1.0

**Status:** Draft

---

# 1. Purpose

This document describes the feature engineering pipeline developed for the Adaptive Fraud Intelligence Platform. It explains how raw transaction data is transformed into meaningful machine learning features that improve fraud detection performance while maintaining consistency between model training and production inference.

---

# 2. Background

Raw transaction data rarely contains features that are immediately suitable for machine learning models. Feature engineering transforms raw attributes into representations that better capture underlying behavioural patterns associated with fraudulent activity.

The feature engineering pipeline developed in this project emphasizes behavioural characteristics rather than customer identifiers, improving the model's ability to generalize to previously unseen transactions.

---

# 3. Feature Engineering Pipeline

The preprocessing pipeline consists of five sequential stages:

1. Data Cleaning
2. Categorical Encoding
3. Behavioural Feature Engineering
4. Ratio Feature Engineering
5. Rule-Based Feature Engineering

The same pipeline is reused during both model training and API inference to ensure consistent feature generation.

---

# 4. Data Cleaning

The following columns were removed before model training.

| Feature | Reason |
|----------|--------|
| nameOrig | Sender account identifier. Excluded because identifiers do not generalize to unseen customers. |
| nameDest | Destination account identifier. Excluded to avoid learning account-specific patterns. |
| isFlaggedFraud | Rule-based fraud flag removed to prevent information leakage. |

---

# 5. Transaction Type Encoding

Transaction categories were converted into numerical values using manual mapping.

| Transaction Type | Encoded Value |
|------------------|--------------:|
| PAYMENT | 0 |
| TRANSFER | 1 |
| CASH_OUT | 2 |
| DEBIT | 3 |
| CASH_IN | 4 |

Manual encoding was selected because the transaction categories are fixed, well-defined, and known in advance, providing a simple and efficient representation for the preprocessing pipeline.

---

# 6. Engineered Features

Three new behavioural features were created.

## 6.1 Sender Balance Difference

```
balance_diff_org =
oldbalanceOrg - newbalanceOrig
```

Measures the amount deducted from the sender's account.

---

## 6.2 Receiver Balance Difference

```
balance_diff_dest =
newbalanceDest - oldbalanceDest
```

Measures the amount credited to the destination account.

---

## 6.3 Amount-to-Balance Ratio

```
amount_balance_ratio =
amount /
(oldbalanceOrg + 1)
```

Represents the transaction amount relative to the sender's available balance.

Adding 1 prevents division by zero.

---

## 6.4 Full Balance Transfer Flag

```
full_balance_transfer =
amount >= 95% of oldbalanceOrg
```

Creates a binary feature indicating whether nearly the entire sender balance was transferred.

This feature captures suspicious transaction behaviour commonly associated with fraudulent activity.

---

# 7. Engineering Decisions

## No Feature Scaling

Feature scaling was intentionally omitted because CatBoost is a tree-based ensemble algorithm that does not require normalized input features.

---

## No Outlier Removal

Large transaction amounts are characteristic of financial fraud rather than data errors.

Removing these observations could reduce the model's ability to detect fraudulent behaviour.

---

## Stratified Train-Test Split

The dataset was divided using an 80:20 stratified split.

This preserves the original fraud-to-non-fraud ratio in both training and testing datasets, ensuring a representative evaluation.

---

## Consistent Preprocessing

The `build_features()` pipeline is reused during both model training and FastAPI inference.

This guarantees that incoming API requests undergo the same transformations as the training data, preventing training-serving skew.

---

# 8. Challenges

Key challenges during feature engineering included:

- Selecting features that generalize to unseen transactions.
- Avoiding information leakage.
- Handling severe class imbalance.
- Designing reusable preprocessing for production inference.

---

# 9. Lessons Learned

Feature engineering significantly influenced model performance.

Behavioural features proved more valuable than raw identifiers, reinforcing the importance of domain knowledge when designing fraud detection systems.

---

# 10. Future Improvements

Future feature engineering enhancements may include:

- Customer transaction frequency
- Transaction velocity
- Historical fraud rate
- Time-based behavioural features
- Network-based account features

---

# 11. Interview Questions

1. Why were identifier columns removed?
2. Why was scaling unnecessary?
3. Explain the purpose of `amount_balance_ratio`.
4. Why create `full_balance_transfer`?
5. How do you ensure preprocessing consistency between training and inference?

---

# References

1. Fraud Detection Dataset – Kaggle
2. CatBoost Documentation