# ADR: Identity Server Migration (Azure → AWS)

## Context
The Identity Server is a critical authentication service currently running on Azure App Service with Azure SQL and Key Vault.

Challenges:
- Inconsistent observability
- Split cloud architecture (Azure + AWS)
- Manual operations and lack of standardization

## Decision
We will migrate to AWS using:
- ECS Fargate for compute
- RDS SQL Server (Multi-AZ)
- AWS Secrets Manager
- Route53 weighted routing for zero-downtime migration

## Migration Architecture

### ECS Design
- Task: 1 vCPU, 2GB memory
- Min tasks: 2 (HA)
- Auto Scaling:
  - Target CPU: 60%
  - Max tasks: 10
- ALB:
  - Health check: `/health`
  - Interval: 15s
  - Healthy threshold: 2

### RDS Configuration
- Engine: SQL Server Standard
- Multi-AZ enabled
- Instance: db.m5.large
- Storage: gp3 with autoscaling
- Backups: 7 days retention

### Secrets Management
- Store all secrets in AWS Secrets Manager
- Rotate credentials every 30 days
- ECS task role grants read-only access

### Networking
- ECS + RDS in private subnets
- ALB in public subnet
- NAT Gateway for outbound traffic

### IAM
- Task role scoped to:
  - SecretsManager:GetSecretValue
  - CloudWatch logs
- No wildcard permissions

## Traffic Cutover Strategy
- Use Route53 weighted routing:
  - Phase 1: AWS 10%
  - Phase 2: AWS 50%
  - Phase 3: AWS 100%

- Health validation between each phase

### Rollback Strategy
- Immediate DNS weight shift back to Azure
- ECS deployment rollback to previous task definition

## Database Migration
- Use AWS DMS (continuous replication)
- Steps:
  1. Full load
  2. CDC enabled
  3. Validate row counts + checksums
  4. Freeze writes briefly for final sync

- Expected downtime: < 2 minutes

## Risk Register

| Risk                | Likelihood | Impact | Mitigation                          |
|---------------------|------------|--------|-------------------------------------|
| Data inconsistency  | Medium     | High   | Validation + AWS DMS CDC            |
| Latency spike       | Medium     | Medium | Load testing + autoscaling          |
| Secrets misconfig   | Low        | High   | IAM least privilege + staging tests |

## Definition of Done
- 100% traffic served from AWS
- Error rate < 1%
- P95 latency < 200ms
- No auth failures reported
- Azure resources decommissioned
