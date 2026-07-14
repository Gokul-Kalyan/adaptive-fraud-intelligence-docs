# FastAPI Service

**Document ID:** AFIP-007

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Backend

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

The Adaptive Fraud Intelligence Platform requires an interface through which external applications can submit financial transaction data and receive fraud predictions in real time.

FastAPI was selected to expose the trained CatBoost model as a RESTful web service. The API acts as the entry point to the production inference pipeline by validating incoming requests, executing model inference, applying business decision rules, recording prediction logs, and returning structured JSON responses.

This document describes the architecture, workflow, implementation, and engineering decisions of the FastAPI backend.

---

# 2. Why FastAPI?

Several Python web frameworks are available for deploying machine learning models, including Flask, Django, and FastAPI.

FastAPI was selected because it provides:

- High-performance asynchronous request handling.
- Automatic request validation using Pydantic.
- Automatic OpenAPI documentation.
- Interactive Swagger UI.
- Native support for JSON-based REST APIs.
- Clean integration with machine learning models.

These features make FastAPI suitable for deploying real-time prediction services.

---

# 3. Backend Architecture

The FastAPI service acts as the communication layer between external clients and the fraud detection model.

```
                Client
                   │
                   ▼
             FastAPI Service
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
Input Validation        Load Model
        │                     │
        └──────────┬──────────┘
                   ▼
          Feature Preparation
                   │
                   ▼
           CatBoost Prediction
                   │
                   ▼
            Decision Engine
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
 PostgreSQL Logger      JSON Response
```

The API separates validation, prediction, business logic, and persistence into independent components.

---

# 4. API Startup Lifecycle

When the FastAPI application starts, the trained CatBoost model is loaded into memory.

```python
model = load_model()
```

The model is loaded only once during application startup.

Startup sequence:

```
Start FastAPI
      │
      ▼
Import api.py
      │
      ▼
Load CatBoost Model
      │
      ▼
Model Loaded into Memory
      │
      ▼
API Ready
```

Loading the model once eliminates repeated disk access during prediction requests and significantly improves inference performance.

---

# 5. API Endpoints

The platform exposes three REST endpoints.

| Method | Endpoint | Purpose |
|---------|----------|---------|
| GET | `/` | Service information |
| GET | `/health` | Health check |
| POST | `/predict` | Fraud prediction |

---

## 5.1 Home Endpoint

```
GET /
```

Returns a simple confirmation that the API is running.

Example response:

```json
{
    "message": "Fraud Detection API Running"
}
```

---

## 5.2 Health Endpoint

```
GET /health
```

Returns the operational status of the service.

Example response:

```json
{
    "status": "healthy",
    "model_loaded": true
}
```

This endpoint enables monitoring systems to verify service availability.

---

## 5.3 Prediction Endpoint

```
POST /predict
```

This endpoint performs real-time fraud prediction.

Input Schema

```json
{
  "step": 0,
  "type": "TRANSFER",
  "amount": 1000,
  "oldbalanceOrg": 5000,
  "newbalanceOrig": 4000,
  "oldbalanceDest": 100,
  "newbalanceDest": 1100
}
```

Output

```json
{
    "fraud_probability": 0.8235,
    "decision": "BLOCK"
}
```

---

# 6. Request Processing Workflow

Every prediction request follows the workflow below.

```
Client Request
      │
      ▼
Pydantic Validation
      │
      ▼
Feature Preparation
      │
      ▼
CatBoost Prediction
      │
      ▼
Fraud Probability
      │
      ▼
Decision Engine
      │
      ▼
Prediction Logging
      │
      ▼
JSON Response
```

Each stage performs a single responsibility, improving maintainability and readability.

---

# 7. Request Validation

Incoming JSON requests are validated using a Pydantic schema.

The schema ensures that every prediction request contains the required transaction attributes before inference begins.

If required fields are missing or invalid, FastAPI automatically returns an HTTP validation error.

The project relies on FastAPI's built-in validation mechanisms and does not implement custom exception handlers.

---

# 8. Feature Preparation

After successful validation, the incoming request is converted into the same feature representation used during model training.

The prediction pipeline reuses the preprocessing logic to maintain consistency between training and inference.

This guarantees that the deployed model receives features in the same format used during model development.

---

# 9. Model Inference

The prepared transaction is passed to the trained CatBoost model.

```
Probability = model.predict_proba(features)
```

The model returns the probability that the transaction is fraudulent.

This probability becomes the input to the business decision engine.

---

# 10. Decision Engine

The platform converts fraud probabilities into operational decisions.

Decision thresholds:

| Fraud Probability | Decision |
|------------------:|----------|
| < 0.30 | APPROVE |
| 0.30 – 0.69 | VERIFY |
| ≥ 0.70 | BLOCK |

Unlike conventional binary classifiers, the platform introduces an intermediate **VERIFY** state.

This enables suspicious transactions to undergo additional verification (for example, OTP verification) before being approved.

The three-level decision system better represents real-world fraud prevention workflows.

---

# 11. Prediction Logging

After generating the decision, every prediction is recorded in PostgreSQL.

The stored information includes:

- Timestamp
- Transaction amount
- Transaction type
- Fraud probability
- Decision

Recording prediction history enables monitoring, dashboard visualization, and drift detection.

---

# 12. Swagger Documentation

FastAPI automatically generates interactive API documentation.

The Swagger interface allows developers to:

- View endpoint definitions.
- Inspect request schemas.
- Execute API requests directly from the browser.
- Validate JSON responses.

This significantly simplifies API testing during development.

---

# 13. Engineering Decisions

Several design decisions influenced the backend architecture.

### Decision 1

The model is loaded once during application startup rather than for every prediction request.

This minimizes inference latency by avoiding repeated disk I/O.

---

### Decision 2

FastAPI's built-in request validation is used instead of implementing custom validation logic.

This reduces boilerplate code while ensuring robust request validation.

---

### Decision 3

Business decisions are separated from model probabilities.

This allows operational policies to change without retraining the machine learning model.

---

### Decision 4

Prediction logging is performed immediately after inference.

This creates a complete prediction history for monitoring and analytics.

---

# 14. Challenges

The primary challenges encountered during backend development included:

- Integrating the trained CatBoost model with FastAPI.
- Maintaining consistency between training and inference preprocessing.
- Designing a three-level business decision engine.
- Recording prediction history without affecting API responsiveness.

---

# 15. Lessons Learned

Developing the FastAPI service reinforced several engineering principles.

- Machine learning models should be exposed through well-defined APIs.
- Training and inference pipelines must remain consistent.
- Business logic should remain separate from model prediction.
- Persistent logging enables effective monitoring and future analysis.

---

# 16. Future Improvements

Future versions of the backend may include:

- JWT-based authentication.
- Batch prediction endpoints.
- Asynchronous prediction logging.
- Rate limiting.
- Cloud deployment.
- Automatic API versioning.

---

# 17. Interview Questions

1. Why was FastAPI selected instead of Flask?
2. Why is the model loaded during application startup?
3. What is the purpose of the `/health` endpoint?
4. Why is request validation important?
5. Why is the decision engine separated from the machine learning model?
6. Why does the system include a VERIFY state instead of only APPROVE and BLOCK?
7. Why is every prediction stored in PostgreSQL?

---

# References

1. FastAPI Documentation
2. Pydantic Documentation
3. Adaptive Fraud Intelligence Platform Source Code