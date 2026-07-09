# Experiment Tracking

**Document ID:** AFIP-006

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Machine Learning

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

Machine learning development is inherently iterative. Multiple experiments are often conducted to evaluate different algorithms, feature engineering strategies, and hyperparameter configurations before selecting a model suitable for deployment.

The purpose of this document is to describe how **MLflow** was integrated into the Adaptive Fraud Intelligence Platform to provide experiment tracking, parameter logging, metric logging, model artifact management, and model versioning.

Unlike conventional machine learning projects that preserve only the final trained model, this platform records every experiment together with its associated metadata, enabling reproducibility and traceability throughout the machine learning lifecycle.

---

# 2. Why Experiment Tracking?

During model development, several questions naturally arise:

- Which experiment produced the best performance?
- Which hyperparameters were used?
- Which trained model belongs to a particular experiment?
- How can a previous experiment be reproduced?
- How should different versions of the model be managed?

Without an experiment tracking framework, answering these questions becomes increasingly difficult as the number of experiments grows.

MLflow was introduced to solve these challenges by maintaining a complete history of every training run.

---

# 3. MLflow Architecture

The Adaptive Fraud Intelligence Platform integrates MLflow within the offline training pipeline.

```
Fraud Dataset
      │
      ▼
Feature Engineering
      │
      ▼
CatBoost Training
      │
      ▼
Model Evaluation
      │
      ▼
MLflow Experiment Tracking
      │
      ├── Parameters
      ├── Metrics
      └── Model Artifact
      │
      ▼
MLflow Model Registry
      │
      ▼
Model Versioning
      │
      ▼
Deployment Packaging (Joblib)
```

MLflow serves as the experiment management layer of the platform, while the exported Joblib model is used by the production inference service.

---

# 4. MLflow Configuration

The training pipeline connects to a local MLflow Tracking Server.

```python
mlflow.set_tracking_uri("http://127.0.0.1:5000")
mlflow.set_experiment("FraudDetection")
```

Each execution of the training pipeline automatically creates a new experiment run under the **FraudDetection** experiment.

Every run maintains an independent record of the training process.

---

# 5. Experiment Lifecycle

The implemented experiment lifecycle is shown below.

```
Train CatBoost Model
        │
        ▼
Evaluate Model
        │
        ▼
Start MLflow Run
        │
        ├── Log Parameters
        ├── Log Metrics
        └── Log Model Artifact
        │
        ▼
Experiment Stored
        │
        ▼
Manual Model Registration
        │
        ▼
Model Version Created
        │
        ▼
Export Model using Joblib
```

Each experiment remains independently accessible, allowing comparison with previous runs.

---

# 6. Parameter Logging

MLflow records the important hyperparameters used during model training.

The logged parameters include:

| Parameter | Value |
|-----------|------:|
| iterations | 200 |
| depth | 6 |
| learning_rate | 0.10 |

Recording hyperparameters enables every experiment to be reproduced using the same training configuration.

This improves reproducibility and simplifies future experimentation.

---

# 7. Metric Logging

After model evaluation, the following performance metrics are logged to MLflow.

- Precision
- Recall
- F1 Score

These metrics provide a comprehensive assessment of fraud detection performance and enable objective comparison between different experiments.

Unlike accuracy, these metrics better represent model performance on highly imbalanced fraud datasets.

---

# 8. Model Artifact Logging

In addition to numerical evaluation metrics, the trained CatBoost model is stored as an MLflow artifact.

```python
mlflow.catboost.log_model(
    cb_model=model,
    name="fraud_detector_model"
)
```

Logging the trained model alongside the experiment ensures that every run contains:

- Training configuration
- Evaluation results
- Corresponding trained model

This guarantees complete experiment reproducibility.

---

# 9. MLflow Model Registry

Experiment tracking and model management serve different purposes.

While experiment tracking records the history of model development, the **Model Registry** manages approved model versions.

After successful model training, the preferred model was manually registered using the MLflow Model Registry interface.

The registered model was named:

```
FraudDetector
```

The registry maintains version history independently from individual experiment runs.

During development, multiple registered versions were created, demonstrating model version management within the MLflow ecosystem.

Model registration was performed manually through the MLflow UI after encountering challenges with programmatic registration.

This approach allowed the project to demonstrate the complete model governance workflow while maintaining a stable implementation.

---

# 10. Model Versioning

The Model Registry maintains versioned instances of the registered model.

Instead of overwriting previously registered models, MLflow creates sequential model versions.

Example:

```
FraudDetector

│

├── Version 1

└── Version 2
```

Model versioning provides several engineering benefits:

- Traceability
- Version history
- Controlled model evolution
- Easier rollback if required

Although this project manually manages model registration, the versioning workflow reflects the practices used in production machine learning systems.

---

# 11. Deployment Packaging

The deployed FastAPI service loads a serialized Joblib model.

```
Training
      │
      ▼
MLflow Tracking
      │
      ▼
Model Registry
      │
      ▼
Export Model (Joblib)
      │
      ▼
FastAPI Inference
```

Separating experiment management from runtime inference keeps the prediction service lightweight and removes the requirement for a continuously running MLflow server during deployment.

---

# 12. Engineering Decisions

Several engineering decisions influenced the experiment tracking workflow.

### Decision 1

MLflow was selected because it combines experiment tracking, artifact management, and model versioning within a single framework.

---

### Decision 2

Only meaningful training parameters and evaluation metrics were logged to keep experiment records concise and interpretable.

---

### Decision 3

Model registration was performed manually through the MLflow user interface after encountering challenges with programmatic registration.

---

### Decision 4

The deployed inference service loads a serialized Joblib model rather than querying the MLflow Tracking Server at runtime.

This simplifies deployment and improves operational reliability.

---

# 13. Challenges

The primary challenges encountered during implementation included:

- Understanding the MLflow experiment lifecycle.
- Managing experiment metadata.
- Registering models programmatically.
- Integrating model versioning into the workflow.

Despite these challenges, MLflow was successfully incorporated into the end-to-end machine learning pipeline.

---

# 14. Lessons Learned

The integration of MLflow reinforced several important MLOps practices.

- Every experiment should be reproducible.
- Parameters, metrics, and models should always be stored together.
- Experiment tracking and deployment are separate responsibilities.
- Model versioning improves governance and maintainability.
- Production inference should remain independent of experiment tracking infrastructure.

---

# 15. Future Improvements

Future versions of the platform may include:

- Automatic model registration through Python APIs.
- Automatic promotion of production models.
- Direct loading of production models from the MLflow Model Registry.
- Remote MLflow Tracking Server.
- CI/CD integration for automated model deployment.

---

# 16. Interview Questions

1. Why is experiment tracking important in machine learning?
2. Why did you choose MLflow?
3. What information is logged during every MLflow run?
4. What is the difference between experiment tracking and the Model Registry?
5. Why is model versioning important?
6. Why did you register the model manually?
7. Why does the deployed API load a Joblib model instead of querying MLflow?

---

# References

1. MLflow Documentation
2. CatBoost Documentation
3. Adaptive Fraud Intelligence Platform Source Code