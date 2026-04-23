# StrongMind DevOps Exercise

## Overview
This repository contains a production-grade design for:
- Migrating Identity Server from Azure → AWS
- Standardizing Rails CI/CD on ECS Fargate
- Containerization best practices
- Observability and alerting strategy

## Design Principles
- Zero-downtime deployments
- Immutable infrastructure
- Least privilege access
- Automated rollback
- Observability-first approach

## Repository Structure
- ADR.md → Migration design and decisions
- .github/workflows/rails-deploy.yml → CI/CD pipeline
- Dockerfile → Optimized Rails container
- OBSERVABILITY.md → Monitoring, logging, alerting

## Assumptions
- AWS account and networking baseline already exist
- ECR repository is pre-created
- ECS cluster: strongmind-production
- Rails apps follow standard conventions

## Tradeoffs
- Fargate chosen over EC2 for reduced operational overhead
- SQL Server retained to avoid schema migration risk

## Future Improvements
- Introduce Terraform for infrastructure as code
- Add canary deployments
- Expand tracing with OpenTelemetry
