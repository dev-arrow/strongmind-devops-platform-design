# Observability Design

## SLOs

### Availability
- Target: 99.9%
- Measured via successful request rate

### Latency
- P95 < 200ms

If breached:
- Trigger alert
- Investigate via logs + traces

## Metrics & Alarms

### ECS
- CPU > 70% → scale out
- Memory > 80% → alert

### RDS
- CPU > 75%
- Free storage < 20%

### Application
- 5xx errors > 1% → critical alert
- Latency spike → warning

## Distributed Tracing
- Enable AWS X-Ray daemon in ECS
- Trace request path across services
- Identify slow DB queries or external calls

## Logging Strategy
- Centralized logs in CloudWatch
- Separate log groups per service
- Retention: 30 days

### Example Query
fields @timestamp, message
| filter status >= 500
| sort @timestamp desc

## Alerting Pipeline
- CloudWatch Alarm → SNS → OpsGenie

### Severity
- Critical → PagerDuty / On-call
- Warning → Slack notification

## Runbooks
- Each alert linked to runbook for faster recovery
