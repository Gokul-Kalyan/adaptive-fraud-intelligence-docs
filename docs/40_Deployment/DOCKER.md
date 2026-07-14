# Docker Containerization

**Document ID:** AFIP-009

**Project:** Adaptive Fraud Intelligence Platform

**Module:** Deployment

**Document Version:** 1.0

**Status:** Final

---

# 1. Purpose

Deploying machine learning applications requires more than training an accurate model. The deployment environment must provide consistent dependencies, reproducible execution, and reliable communication between application components.

To achieve this, the Adaptive Fraud Intelligence Platform uses **Docker** to package the FastAPI inference service and **Docker Compose** to orchestrate the FastAPI and PostgreSQL services as a multi-container application.

This document describes the containerization architecture, deployment workflow, networking model, persistent storage strategy, and engineering decisions adopted during implementation.

---

# 2. Why Docker?

Machine learning projects often suffer from dependency conflicts and environment inconsistencies across development and deployment machines.

Docker solves these challenges by packaging the application together with its runtime environment.

The benefits include:

- Platform-independent deployment.
- Consistent execution environment.
- Dependency isolation.
- Reproducible builds.
- Simplified deployment.
- Easy integration with databases and other services.

Instead of configuring every machine manually, the application can be deployed using the same Docker image.

---

# 3. Deployment Architecture

The platform uses a multi-container architecture managed by Docker Compose.

```
                    Docker Compose
                           │
          ┌────────────────┴────────────────┐
          ▼                                 ▼
   fraud-api Container             fraud-postgres Container
          │                                 │
          ▼                                 ▼
     FastAPI Service                  PostgreSQL 16
          │
          ▼
   CatBoost Prediction Model
```

Each service executes within its own isolated container while communicating through Docker's internal network.

---

# 4. Docker Components

The deployment consists of two independent containers.

## FastAPI Container

Responsibilities:

- Load trained CatBoost model
- Receive prediction requests
- Perform inference
- Apply business rules
- Store prediction history

Container Name

```
fraud-api
```

---

## PostgreSQL Container

Responsibilities:

- Store prediction records
- Provide persistent storage
- Support monitoring dashboard
- Support drift detection

Container Name

```
fraud-postgres
```

---

# 5. Dockerfile

The FastAPI application is packaged using the following workflow.

```
Python 3.11 Slim
        │
        ▼
Create Working Directory
        │
        ▼
Install Dependencies
        │
        ▼
Copy Source Code
        │
        ▼
Copy Trained Model
        │
        ▼
Expose Port 8000
        │
        ▼
Start Uvicorn Server
```

The Dockerfile performs the following tasks:

- Uses the lightweight Python 3.11 image.
- Creates the application working directory.
- Installs project dependencies.
- Copies source code.
- Copies the trained CatBoost model.
- Exposes the FastAPI service.
- Starts the Uvicorn server.

---

# 6. Docker Compose

Docker Compose orchestrates multiple containers as a single application.

The platform defines two services:

```
services

├── fraud-api
└── postgres
```

Docker Compose automatically:

- Builds the FastAPI image.
- Creates the PostgreSQL container.
- Creates a shared Docker network.
- Starts both containers.
- Connects the services together.

This removes the need to manually configure networking between containers.

---

# 7. Container Networking

One of the most important aspects of Docker Compose is automatic service discovery.

The FastAPI container connects to PostgreSQL using

```
DB_HOST=postgres
```

instead of

```
localhost
```

This is because each Docker container has its own isolated network namespace.

```
fraud-api Container

localhost

↓

FastAPI
```

```
fraud-postgres Container

localhost

↓

PostgreSQL
```

Inside a container, **localhost always refers to the container itself**.

Docker Compose automatically creates an internal network where each service name becomes a hostname.

Therefore,

```
postgres
```

is automatically resolved to the PostgreSQL container.

This enables communication without manually configuring IP addresses.

---

# 8. Service Dependency

The FastAPI container depends on the PostgreSQL container.

```
depends_on

↓

postgres
```

This ensures that Docker starts the PostgreSQL service before starting the FastAPI service.

Without this dependency, the API could attempt to connect before the database becomes available.

---

# 9. Persistent Storage

The PostgreSQL container uses a named Docker volume.

```
postgres_data
```

mounted to

```
/var/lib/postgresql/data
```

This provides persistent database storage.

```
PostgreSQL
      │
      ▼
Docker Volume
      │
      ▼
Persistent Database
```

Even if the PostgreSQL container is recreated, the prediction history remains preserved inside the Docker volume.

---

# 10. Deployment Workflow

The deployment process follows the workflow below.

```
Project Source
       │
       ▼
Docker Build
       │
       ▼
Docker Image
       │
       ▼
Docker Compose
       │
       ▼
Container Creation
       │
       ▼
FastAPI + PostgreSQL
       │
       ▼
Prediction Service
```

The application is started using:

```bash
docker compose up --build
```

Docker builds the FastAPI image, creates the containers, establishes networking, and starts both services.

---

# 11. Runtime Workflow

Once deployed, prediction requests follow this execution path.

```
Client
      │
      ▼
FastAPI Container
      │
      ▼
CatBoost Model
      │
      ▼
Decision Engine
      │
      ▼
PostgreSQL Container
      │
      ▼
Persistent Storage
```

Both containers communicate through Docker's internal network.

---

# 12. Engineering Decisions

Several engineering decisions influenced the deployment architecture.

### Decision 1

A lightweight Python Slim image was selected to reduce image size while maintaining compatibility with the required libraries.

---

### Decision 2

The API and database were deployed as separate containers.

This improves modularity, isolation, and maintainability.

---

### Decision 3

Docker Compose was selected instead of manually running containers to simplify orchestration and networking.

---

### Decision 4

Named Docker volumes were used to preserve PostgreSQL data even when containers are recreated.

---

### Decision 5

The FastAPI container communicates with PostgreSQL using the Docker service name rather than localhost.

This leverages Docker's built-in DNS service discovery.

---

# 13. Challenges

The primary challenges encountered during implementation included:

- Understanding Docker networking.
- Configuring communication between FastAPI and PostgreSQL.
- Managing environment variables.
- Persisting PostgreSQL data across container restarts.

---

# 14. Lessons Learned

Containerization demonstrated several important deployment concepts.

- Machine learning applications should be isolated from the host environment.
- Multi-container architectures simplify service separation.
- Docker networking eliminates manual IP management.
- Persistent volumes protect application data.
- Docker Compose greatly simplifies deployment of interconnected services.

---

# 15. Future Improvements

Future versions of the deployment architecture may include:

- Cloud deployment on AWS, Azure, or Google Cloud.
- Container orchestration using Kubernetes.
- Nginx reverse proxy.
- HTTPS support.
- Automated CI/CD deployment.
- Docker image versioning.
- Health checks for container orchestration.

---

# 16. Interview Questions

1. Why did you choose Docker for deployment?
2. Why are FastAPI and PostgreSQL deployed in separate containers?
3. Why is `DB_HOST=postgres` instead of `localhost`?
4. What is Docker Compose?
5. What problem does `depends_on` solve?
6. Why are Docker volumes required?
7. What happens if the PostgreSQL container is deleted?
8. How does Docker Compose allow containers to communicate?

---

# References

1. Docker Documentation
2. Docker Compose Documentation
3. PostgreSQL Documentation
4. Adaptive Fraud Intelligence Platform Source Code