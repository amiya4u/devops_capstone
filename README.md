# DevOps Capstone Project

A containerized Flask web application with a fully automated CI/CD pipeline.
Built as part of a self-directed DevOps/Platform Engineer learning path.

## Live Architecture

Developer (Mac)
|
| git push
↓
GitHub (devops-capstone repo)
|
| triggers automatically
↓
GitHub Actions (Ubuntu VM)
|── checkout code
|── configure AWS credentials
|── login to ECR
|── docker build (linux/amd64)
|── docker push → tagged with commit SHA
↓
AWS ECR (255093304980.dkr.ecr.us-east-1.amazonaws.com/flaskapp)
|
| docker pull
↓
AWS EC2 (t2.micro, us-east-1)
|
| docker run -p 80:5000
↓
Flask App (port 80)
|
↓
Browser: http://<ec2-public-ip>/

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python / Flask |
| Containerization | Docker |
| Image Registry | AWS ECR |
| CI/CD Pipeline | GitHub Actions |
| Infrastructure | AWS EC2 (t2.micro) |
| Networking | AWS VPC, Security Groups |

## Application Endpoints

| Endpoint | Description | Response |
|---|---|---|
| `/` | Home route | `DevOps Capstone v2 - pipeline is working!` |
| `/health` | Health check (used by load balancers) | `{"status": "healthy"}` |

## CI/CD Pipeline

Every push to `main` branch automatically:
1. Spins up a fresh Ubuntu VM on GitHub
2. Authenticates with AWS using IAM credentials
3. Logs Docker into ECR
4. Builds Docker image for `linux/amd64` architecture
5. Pushes image to ECR tagged with git commit SHA
6. VM shuts down — no manual steps needed

## Local Development

```bash
# Clone the repo
git clone https://github.com/amiya4u/devops-capstone.git
cd devops-capstone

# Run locally with Python
cd Flaskapp
pip install -r requirements.txt
python3 app.py

# Run locally with Docker
docker build -t flaskapp:latest .
docker run -p 6000:5000 flaskapp:latest
curl http://localhost:6000/health
```

## EC2 Setup (manual steps to deploy)

```bash
# 1. Launch t2.micro EC2 with IAM role: ec2-ecr-read-role
# 2. SSH into instance
ssh -i your-key.pem ubuntu@<ec2-public-ip>

# 3. Install dependencies
sudo apt update -y
sudo apt install docker.io awscli -y
sudo service docker start
sudo usermod -aG docker ubuntu
exit  # log out and back in

# 4. Login to ECR
aws ecr get-login-password --region us-east-1 | docker login \
  --username AWS \
  --password-stdin \
  255093304980.dkr.ecr.us-east-1.amazonaws.com

# 5. Pull and run
docker pull 255093304980.dkr.ecr.us-east-1.amazonaws.com/flaskapp:<commit-sha>
docker run -d -p 80:5000 255093304980.dkr.ecr.us-east-1.amazonaws.com/flaskapp:<commit-sha>

# 6. Test
curl http://localhost/
curl http://localhost/health
```

## Issues Encountered and Resolved

| Issue | Root Cause | Fix |
|---|---|---|
| Port conflict | Flask hardcoded to busy port | Used `os.environ.get('PORT', 5000)` |
| ARM64 vs AMD64 | Built on M1 Mac, ran on Intel EC2 | Used GitHub Actions (AMD64) to build |
| ECR auth failed | No IAM role on EC2 | Attached `ec2-ecr-read-role` to EC2 |
| Cross-account denied | EC2 and ECR in different AWS accounts | Kept both in same account |
| YAML syntax error | Space in variable name `ECR_ REPOSITORY` | Removed space |

## What I Would Add Next

- Terraform to provision VPC, EC2, ECR as code
- Auto Scaling Group for high availability across multiple AZs
- Application Load Balancer in front of EC2
- Prometheus + Grafana for monitoring
- Kubernetes deployment with Helm chart

## Author

Amiya Podder — transitioning from Support Engineer to DevOps/Platform Engineer
[GitHub](https://github.com/amiya4u)
