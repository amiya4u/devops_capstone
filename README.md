# DevOps Capstone Project

A containerized Flask application with automated CI/CD pipeline.

## Architecture
- Flask app with `/` and `/health` endpoints
- Containerized with Docker
- Docker image stored in AWS ECR
- GitHub Actions automatically builds and pushes on every commit

## Tech Stack
- Python / Flask
- Docker
- AWS ECR
- GitHub Actions

## CI/CD Pipeline
Every push to main branch automatically:
1. Spins up a fresh Ubuntu VM on GitHub
2. Authenticates with AWS
3. Builds Docker image
4. Pushes to ECR tagged with commit SHA
5. VM shuts down

## Local Development
```bash
# Run locally
python3 app.py

# Build Docker image
docker build -t flaskapp:latest .

# Run container
docker run -p 6000:5000 flaskapp:latest
```

## ECR Repository
255093304980.dkr.ecr.us-east-1.amazonaws.com/flaskapp
