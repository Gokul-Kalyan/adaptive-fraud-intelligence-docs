# Challenges Encountered

**Document ID:** AFIP-013

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Project Management

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

Developing an end-to-end machine learning system extends beyond model training. Throughout the implementation of the Adaptive Fraud Intelligence Platform, several technical and engineering challenges were encountered across data preparation, model development, deployment, monitoring, and infrastructure.

This document summarizes the major challenges, their root causes, the adopted solutions, and the key lessons learned.

---

# Challenge 1

## Problem

The fraud detection dataset is extremely imbalanced.

```
Legitimate Transactions : 6,354,407

Fraudulent Transactions : 8,213
```

Fraudulent transactions represent only a very small fraction of the overall dataset.

---

## Root Cause

Most machine learning algorithms tend to favor the majority class, leading to poor fraud detection performance.

---

## Initial Solution

SMOTE (Synthetic Minority Oversampling Technique) was initially applied to generate synthetic fraud samples and balance the dataset.

---

## New Challenge

Although SMOTE improved class balance, it significantly increased memory consumption due to the very large dataset.

Training became computationally expensive and less practical for production-oriented experimentation.

---

## Final Solution

SMOTE was removed from the production training pipeline.

Instead, CatBoost's built-in

```python
auto_class_weights="Balanced"
```

was used to automatically compensate for class imbalance during training.

---

## Lesson Learned

Built-in algorithmic support for class imbalance can simplify the training pipeline while reducing computational overhead.

---

# Challenge 2

## Problem

Selecting the most appropriate machine learning model.

---

## Root Cause

Multiple algorithms demonstrated strong performance, making model selection dependent on factors beyond accuracy alone.

---

## Solution

Random Forest, XGBoost, and CatBoost were evaluated.

The final selection considered:

- Predictive performance
- Memory efficiency
- Simplicity of deployment
- Native imbalance handling

CatBoost provided the best overall balance.

---

## Lesson Learned

Model selection should consider deployment requirements in addition to evaluation metrics.

---

# Challenge 3

## Problem

Tracking machine learning experiments became increasingly difficult as multiple training runs were performed.

---

## Root Cause

Without centralized experiment tracking, comparing hyperparameters, metrics, and models becomes error-prone.

---

## Solution

MLflow was introduced to automatically record:

- Hyperparameters
- Evaluation metrics
- Model artifacts

This established a reproducible experiment history.

---

## Lesson Learned

Experiment tracking is an essential component of modern MLOps workflows.

---

# Challenge 4

## Problem

Automatic model registration within MLflow did not function as expected during implementation.

---

## Root Cause

Integration issues prevented reliable automatic registration.

---

## Solution

The trained model was successfully logged as an MLflow artifact.

Model registration and version management were then completed manually through the MLflow user interface.

---

## Lesson Learned

Production workflows sometimes require practical workarounds while maintaining correct model lifecycle management.

---

# Challenge 5

## Problem

Integrating the trained model into a REST API while maintaining consistency with the training pipeline.

---

## Root Cause

Production inference must use exactly the same feature preparation steps applied during training.

Any inconsistency could lead to incorrect predictions.

---

## Solution

A dedicated feature preparation pipeline was implemented for inference to ensure feature consistency.

---

## Lesson Learned

Training and inference pipelines must remain synchronized throughout the project lifecycle.

---

# Challenge 6

## Problem

Understanding Docker networking.

---

## Root Cause

The FastAPI container initially attempted to connect to PostgreSQL using

```
localhost
```

However, each Docker container has its own isolated network namespace.

---

## Solution

Docker Compose service discovery was used.

The FastAPI container connects using

```
DB_HOST=postgres
```

where **postgres** is the Docker service name.

---

## Lesson Learned

Within Docker Compose, containers communicate using service names rather than localhost.

---

# Challenge 7

## Problem

Designing a database suitable for production prediction logging.

---

## Root Cause

Machine learning tutorials frequently store predictions in CSV files, which are not suitable for production monitoring.

---

## Solution

A PostgreSQL database was introduced as the platform's persistent storage layer.

Prediction history is now shared by:

- FastAPI
- Monitoring Dashboard
- Drift Detection

---

## Lesson Learned

Persistent databases enable modular system architectures.

---

# Challenge 8

## Problem

Understanding production monitoring concepts.

---

## Root Cause

Model deployment alone does not provide visibility into operational behaviour.

---

## Solution

A Streamlit monitoring dashboard was developed to display:

- Prediction statistics
- Operational metrics
- Recent predictions
- Drift status

---

## Lesson Learned

Deployment should always be accompanied by operational monitoring.

---

# Challenge 9

## Problem

Detecting changes in production data.

---

## Root Cause

Production transaction characteristics may change over time, reducing model reliability.

---

## Solution

A lightweight drift detection module based on the Kolmogorov–Smirnov Test was implemented.

The module compares transaction amount distributions between the training dataset and production predictions.

---

## Lesson Learned

Monitoring production data is as important as monitoring model accuracy.

---

# Challenge 10

## Problem

Transforming a notebook-based machine learning project into a production-oriented application.

---

## Root Cause

Traditional machine learning workflows often conclude after model evaluation.

Production systems require considerably more infrastructure.

---

## Solution

The project was expanded to include:

- FastAPI
- PostgreSQL
- Docker
- MLflow
- Streamlit
- Drift Detection

resulting in a complete end-to-end machine learning platform.

---

## Lesson Learned

Successful machine learning systems require software engineering, deployment, monitoring, and operational management in addition to model development.

---

# Overall Reflection

The challenges encountered during this project extended well beyond predictive modelling.

The implementation required integrating machine learning, backend development, databases, containerization, experiment tracking, and production monitoring into a unified system.

Resolving these challenges significantly improved both the technical quality of the platform and the understanding of real-world MLOps practices.

---

# References

1. Adaptive Fraud Intelligence Platform Source Code
2. MLflow Documentation
3. Docker Documentation
4. PostgreSQL Documentation
5. FastAPI Documentation