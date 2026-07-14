# Engineering Design Decisions

**Document ID:** AFIP-012

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Project Management

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

Engineering projects involve numerous design decisions that influence system performance, maintainability, scalability, and deployment.

Rather than selecting technologies arbitrarily, each component of the Adaptive Fraud Intelligence Platform was chosen after considering project requirements, implementation complexity, and future extensibility.

This document records the major engineering decisions, alternatives considered, technical justifications, and associated trade-offs.

---

# Design Decision 1

## Problem

The fraud detection model must accurately identify highly imbalanced fraudulent transactions while remaining computationally efficient for production deployment.

---

## Alternatives Considered

- Random Forest
- XGBoost
- CatBoost

---

## Selected Solution

CatBoost Classifier

---

## Justification

Initial experiments included Random Forest, XGBoost, and CatBoost.

SMOTE was initially used to balance the highly imbalanced fraud dataset. Although this improved minority class representation, it significantly increased memory consumption during training.

CatBoost provides built-in class weighting through:

```python
auto_class_weights="Balanced"
```

This eliminated the need for synthetic oversampling while maintaining excellent predictive performance.

The final CatBoost model achieved:

- Precision: 0.91
- Recall: 0.9976
- F1 Score: 0.9521

while simplifying the training pipeline.

---

## Trade-offs

Advantages

- Handles class imbalance without SMOTE.
- Lower memory usage.
- Simple production pipeline.
- Strong fraud detection performance.

Disadvantages

- Slightly longer training time than simpler tree models.
- More limited community examples compared to XGBoost.

---

# Design Decision 2

## Problem

The trained machine learning model must be exposed as a production-ready inference service.

---

## Alternatives Considered

- Flask
- Django
- FastAPI

---

## Selected Solution

FastAPI

---

## Justification

FastAPI provides several features that simplify machine learning deployment.

These include:

- Automatic request validation using Pydantic.
- Interactive Swagger documentation.
- OpenAPI specification generation.
- High-performance request handling.
- Minimal boilerplate code.

These capabilities significantly reduce development effort while improving API usability.

---

## Trade-offs

Advantages

- Automatic API documentation.
- Strong request validation.
- Lightweight framework.
- Excellent developer experience.

Disadvantages

- Smaller ecosystem compared to Flask.
- Slight learning curve for asynchronous concepts.

---

# Design Decision 3

## Problem

Prediction history must be stored for monitoring, auditing, and production analytics.

---

## Alternatives Considered

- CSV files
- SQLite
- PostgreSQL

---

## Selected Solution

PostgreSQL

---

## Justification

A relational database provides persistent storage and enables multiple components to access the same production data.

Within this platform, PostgreSQL serves as the central persistence layer supporting:

- Prediction logging
- Monitoring dashboard
- Drift detection

Unlike CSV-based storage, PostgreSQL allows structured querying and future scalability.

---

## Trade-offs

Advantages

- Persistent storage.
- Efficient querying.
- Scalable.
- ACID-compliant transactions.

Disadvantages

- Additional setup compared to CSV files.
- Requires database administration.

---

# Design Decision 4

## Problem

The application should execute consistently across different development and deployment environments.

---

## Alternatives Considered

- Local installation
- Virtual environments
- Docker

---

## Selected Solution

Docker with Docker Compose

---

## Justification

Docker packages the application together with all dependencies, eliminating environment-specific issues.

Docker Compose further simplifies deployment by orchestrating both the FastAPI and PostgreSQL containers.

The resulting architecture separates application logic from database services while maintaining reliable communication through Docker networking.

---

## Trade-offs

Advantages

- Reproducible environments.
- Service isolation.
- Simplified deployment.
- Multi-container support.

Disadvantages

- Additional learning curve.
- Increased image build time.

---

# Design Decision 5

## Problem

Machine learning experiments should be reproducible and easily comparable.

---

## Alternatives Considered

- Manual documentation
- Text files
- Spreadsheet tracking
- MLflow

---

## Selected Solution

MLflow

---

## Justification

MLflow automatically records:

- Hyperparameters
- Evaluation metrics
- Trained model artifacts

This centralizes experiment history and simplifies comparison between multiple training runs.

The trained model was subsequently registered in the MLflow Model Registry to enable version management.

---

## Trade-offs

Advantages

- Centralized experiment tracking.
- Model versioning.
- Improved reproducibility.
- Better collaboration.

Disadvantages

- Requires an additional tracking server.
- Model registration was completed manually due to implementation limitations.

---

# Design Decision 6

## Problem

Operational predictions should be monitored through a simple user interface.

---

## Alternatives Considered

- Flask frontend
- Dash
- React
- Streamlit

---

## Selected Solution

Streamlit

---

## Justification

The objective was to rapidly build a lightweight operational dashboard without developing a dedicated frontend application.

Streamlit integrates naturally with Python, Pandas, and PostgreSQL while providing an intuitive interface for displaying production metrics.

---

## Trade-offs

Advantages

- Rapid development.
- Python-only implementation.
- Minimal frontend development.

Disadvantages

- Limited UI customization.
- Manual refresh in the current implementation.

---

# Design Decision 7

## Problem

Production data should be monitored to identify distribution changes after deployment.

---

## Alternatives Considered

- Population Stability Index (PSI)
- Jensen–Shannon Divergence
- Kolmogorov–Smirnov Test

---

## Selected Solution

Kolmogorov–Smirnov (KS) Test

---

## Justification

The KS Test provides a lightweight statistical approach for comparing numerical feature distributions.

The implementation compares the distribution of transaction amounts between the training dataset and production predictions.

The test is computationally inexpensive and suitable for demonstrating production data drift monitoring.

---

## Trade-offs

Advantages

- Lightweight.
- Simple implementation.
- No model retraining required.

Disadvantages

- Current implementation monitors only one feature.
- Detects data drift but not concept drift.

---

# Design Decision 8

## Problem

Binary fraud classification does not accurately reflect real-world banking workflows.

---

## Alternatives Considered

- APPROVE / BLOCK
- APPROVE / VERIFY / BLOCK

---

## Selected Solution

Three-Level Decision Engine

---

## Justification

Instead of immediately blocking every suspicious transaction, the platform introduces an intermediate **VERIFY** state.

Transactions with moderate fraud probability can undergo additional verification (such as OTP authentication) before a final decision is made.

This approach more closely resembles operational fraud prevention systems used in financial institutions.

---

## Trade-offs

Advantages

- Better reflects real-world workflows.
- Reduces unnecessary transaction blocking.
- Supports additional verification mechanisms.

Disadvantages

- Requires threshold selection.
- Business rules become slightly more complex.

---

# Design Decision 9

## Problem

Prediction history should support monitoring and future analytics.

---

## Alternatives Considered

- Return prediction only.
- Persist every prediction.

---

## Selected Solution

Persist every prediction in PostgreSQL.

---

## Justification

Every production prediction is stored immediately after inference.

This enables:

- Dashboard reporting.
- Drift detection.
- Operational auditing.
- Historical analysis.

The database therefore acts as the central persistence layer of the platform.

---

## Trade-offs

Advantages

- Complete operational history.
- Supports monitoring.
- Enables future analytics.

Disadvantages

- Increased storage requirements over time.

---

# Design Decision 10

## Problem

Model loading should not increase prediction latency.

---

## Alternatives Considered

- Load model for every request.
- Load model once during startup.

---

## Selected Solution

Load the model during FastAPI startup.

---

## Justification

The trained CatBoost model is loaded once when the API starts.

Subsequent prediction requests reuse the in-memory model, eliminating repeated disk access and reducing inference latency.

---

## Trade-offs

Advantages

- Faster predictions.
- Lower disk I/O.
- Improved throughput.

Disadvantages

- Higher memory usage during application runtime.

---

# Design Decision 11

## Problem

Trained models should be versioned for future reference.

---

## Alternatives Considered

- Store only local model files.
- Register models in MLflow.

---

## Selected Solution

MLflow Model Registry

---

## Justification

Training runs automatically log parameters, metrics, and model artifacts.

The selected model is then registered through the MLflow Model Registry to provide version control and improve model lifecycle management.

Model registration was completed manually due to implementation issues encountered during automated registration.

---

## Trade-offs

Advantages

- Model version management.
- Improved reproducibility.
- Clear deployment history.

Disadvantages

- Manual registration step in the current implementation.

---

# Summary

The engineering decisions documented above collectively shaped the architecture of the Adaptive Fraud Intelligence Platform.

Rather than optimizing for a single objective, each decision balanced implementation complexity, maintainability, deployment readiness, and educational value.

The resulting architecture demonstrates an end-to-end machine learning system encompassing data processing, model development, experiment tracking, API deployment, database integration, containerization, monitoring, and operational analytics.

---

# References

1. FastAPI Documentation
2. PostgreSQL Documentation
3. Docker Documentation
4. MLflow Documentation
5. CatBoost Documentation
6. Adaptive Fraud Intelligence Platform Source Code