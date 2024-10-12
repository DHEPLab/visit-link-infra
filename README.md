# Visit link Infra

## Install hook locally

### 1. Install with brew

```bash
brew install pre-commit tflint tfsec trivy checkov detect-secrets
```

### 2. Install the git hook scripts

Go to root direcotry of project

```bash
pre-commit install
```

- now pre-commit will run automatically on git commit!

### 3. (Optional) Run against all the files

It's usually a good idea to run the hooks against all the files when adding new hooks (usually pre-commit will only run on the changed files during git hooks)

```bash
pre-commit run -a
```

## Provision infrastructure
### Introduction
This project is about to deploy below services on AWS via terraform:
* A backend server on ECS
* A frontend server on ECS
* A RDS database and its replica
* AN ALB to publish api and web app

The environment folder is the main module for different env where maintain the corresponding variables.

### Provision from local
1. Config your own AWS account
   ```bash
   export AWS_ACCESS_KEY_ID={your_access_key}
   export AWS_SECRET_ACCESS_KEY={your_secret_key}
   ```
2. Go into the `env` folder(ie: environments/dev)
3. Run terraform commands
   ```bash
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```
### Provision automatically
A Github workflow will be triggered after push codes to master branch, and its step:
1. Check secrets
2. Code scan, including: lint, vulnerability scan
3. Terraform format&validate
4. Apply to aws (Only if head commit message contains `[!go deploy!]`)

> Please notice:
> 1. The AWS account is configured in Github secret, you need to change to your own one
> 2. You don't have to follow these Github actions, and design your prefer.

## Deploy SonarQube on AWS EC2 Instance

SonarQube is the leading tool for continuously inspecting the Code Quality and Security of your codebases and guiding development teams during Code Reviews.

### Step 1: Create the EC2 Instance
Believe that you had the knowledge how to create a EC2 Instance in AWS.
Please notice the specifications for SonarQube
* CPU : 2 vCPU
* Volume : 20 GB
* RAM : 4 GB
> NOTE : The specifications provided are the minimum; however, feel free to increase them according to your needs.

### Step 2: Connect to EC2 instance
```cmd
ssh -i ${your_perm_key} ${user}@${ec2_ip}
```

### Step 3: Install JDK
```cmd
sudo yum install java-17-amazon-corretto
```
Verify java installed
```cmd
java --version
```

### Step 4: Install docker&docker-compose
Install docker
```cmd
sudo amazon-linux-extras install docker
sudo service docker start
```
Add current user to Docker group
```cmd
sudo usermod -a -G docker ${user}
```
Make docker auto-start
```cmd
sudo chkconfig docker on
```
You may always need Git
```cmd
sudo yum install -y git
```
Install docker-compose
```cmd
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
Verify docker-compose installed
```cmd
docker-compose version
```

### Step5: Install sonarqube with docker-compose
Prepare this configuration and save to docker-compose.yml
```yaml
version: "3"

services:
  sonarqube:
    image: sonarqube:lts-community
    depends_on:
      - sonar_db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://sonar_db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
  sonar_db:
    image: postgres:14
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    ports:
      - "5433:5432"
    volumes:
      - sonar_db:/var/lib/postgresql
      - sonar_db_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  sonar_db:
  sonar_db_data:
```
Update system config
```cmd
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
```
Start SonarQube
```cmd
docker-compose up -d
```
Connect to our Sonar server using the instance public-ip address along with the port that we had specified: 9000
