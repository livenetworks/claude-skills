# SLA-AI-001: AI Assistant Service Level

| Field            | Value                                      |
|------------------|--------------------------------------------|
| Document ID      | SLA-AI-001                                 |
| Version          | 1.0                                        |
| Classification   | Internal                                   |
| Owner            | [IMS Manager]                              |
| Approved by      | [Top Management]                           |
| Effective date   | [Date]                                     |
| Review cycle     | Annual or on provider change               |
| Standards        | ISO/IEC 20000-1:2018 (8.3, 8.2.4, 8.6)    |

---

## 1. Purpose

This document defines service level targets, monitoring, and reporting for AI assistant
services used within [Organization Name], ensuring alignment with IT service management
requirements.

## 2. Service Description

| Attribute           | Description                                              |
|---------------------|----------------------------------------------------------|
| Service name        | AI Assistant Service                                     |
| Service type        | Supporting service (non-critical)                        |
| Service owner       | [IMS Manager]                                            |
| Technical owner     | AI Administrator                                         |
| Users               | Personnel with assigned AI access roles (AC-AI-001)      |
| Service hours       | 24/7 (cloud) / Business hours (self-hosted, if applicable) |
| Dependencies        | Internet connectivity, AI provider API, self-hosted infra |

### 2.1 Service Components

| Component               | Type          | Provider           | Criticality |
|--------------------------|---------------|--------------------|-------------|
| Cloud AI API (Claude)    | External      | Anthropic          | Medium      |
| Self-hosted AI (OpenClaw)| Internal      | [Organization]     | Low-Medium  |
| AI Gateway server        | Internal      | [Organization]     | Low-Medium  |
| API key management       | Internal      | [Organization]     | High        |
| Usage logging system     | Internal      | [Organization]     | Medium      |

## 3. Service Level Targets

### 3.1 Availability

| Metric                            | Target        | Measurement                    |
|-----------------------------------|---------------|--------------------------------|
| Cloud AI API uptime               | 99.5%/month   | Provider status page + own monitoring |
| Self-hosted AI gateway uptime     | 99.0%/month   | Internal monitoring            |
| Planned maintenance window        | Max 4h/month  | Pre-announced 48h in advance   |

**Note:** AI assistant is classified as a *supporting* service. Temporary unavailability
does not constitute a critical incident — users fall back to manual processes.

### 3.2 Performance

| Metric                            | Target        | Measurement                    |
|-----------------------------------|---------------|--------------------------------|
| Response time (simple query)      | < 5 seconds   | Median, measured at gateway    |
| Response time (complex/agent)     | < 60 seconds  | 90th percentile                |
| Throughput (tokens/minute)        | Per provider tier | Provider dashboard          |
| Error rate                        | < 2%          | Failed API calls / total calls |

### 3.3 Support

| Metric                                | Target        |
|----------------------------------------|---------------|
| AI-related incident response (High)    | 1 hour        |
| AI-related incident response (Medium)  | 4 hours       |
| AI-related incident response (Low)     | Next business day |
| Access provisioning (new user)         | 2 business days |
| API key rotation (scheduled)           | Within maintenance window |
| API key revocation (emergency)         | 1 hour        |

## 4. Provider Management

### 4.1 Provider Evaluation Criteria

Before adopting any AI provider, evaluate against:

| Criterion                  | Requirement                                           |
|----------------------------|-------------------------------------------------------|
| Data processing terms      | Provider must NOT use submitted data for training     |
| Data residency             | EU preferred; US acceptable with data masking          |
| Data retention             | Provider retains data max 30 days (or zero retention) |
| Security certifications    | SOC 2 Type II minimum; ISO 27001 preferred            |
| Incident notification      | Provider must notify of breaches within 72 hours      |
| API availability SLA       | Provider must publish uptime commitment ≥ 99.5%       |
| Pricing transparency       | Per-token pricing must be documented and predictable  |

### 4.2 Provider Review Schedule

| Activity                          | Frequency     | Responsible        |
|-----------------------------------|---------------|--------------------|
| Provider SLA compliance review    | Quarterly     | AI Administrator   |
| Provider terms of service review  | On change + annually | IMS Manager   |
| Provider security posture review  | Annually      | IMS Manager        |
| Cost analysis and optimization    | Quarterly     | AI Administrator   |

### 4.3 Provider Incident Handling

When the AI provider experiences an incident:

1. Detect via monitoring or provider status page
2. Log as external service incident
3. Notify affected users if downtime > 15 minutes
4. Activate fallback (manual process or alternative provider)
5. Track provider's RCA and update risk assessment if needed

## 5. Capacity Management

### 5.1 Usage Monitoring

| Metric                  | Threshold (warning)  | Threshold (critical) | Action               |
|-------------------------|----------------------|----------------------|----------------------|
| Monthly API spend       | 80% of budget        | 95% of budget        | Notify IMS Manager   |
| Daily token consumption | 2x daily average     | 5x daily average     | Investigate anomaly  |
| Rate limit hits         | > 5/day              | > 20/day             | Upgrade tier or optimize |
| Self-hosted CPU/RAM     | 80% sustained        | 95% sustained        | Scale or optimize    |

### 5.2 Capacity Planning

- Monthly usage trends are tracked and projected quarterly
- Budget allocation for AI services is reviewed during management review
- Capacity plan is updated when:
  - New user groups are given AI access
  - New AI use cases are deployed
  - Provider pricing changes

## 6. Continuity and Fallback

### 6.1 Fallback Procedures

| Scenario                           | Fallback Action                                |
|------------------------------------|------------------------------------------------|
| Cloud AI provider outage           | Use alternative provider or manual process     |
| Self-hosted AI gateway failure     | Failover to cloud API or manual process        |
| API key compromised                | Revoke → rotate → resume within 1 hour         |
| Provider terms become unacceptable | Migrate to alternative provider within 30 days |
| Budget exhausted                   | Restrict to essential use only + manual fallback|

### 6.2 Recovery Priorities

AI assistant service is **not** business-critical. Recovery priority during
a major incident or disaster:

| Priority | Service                    |
|----------|----------------------------|
| 1        | Core business systems      |
| 2        | Email and communication    |
| 3        | Document management        |
| 4        | **AI assistant services**  |

## 7. Reporting

### 7.1 Service Report Contents

Monthly service report includes:

- Availability vs target (uptime percentage)
- Performance vs target (response times)
- Total interactions and token consumption
- Cost summary (actual vs budget)
- Incidents (count, severity, resolution time)
- SLA breaches (if any)

### 7.2 Reporting Schedule

| Report                  | Frequency | Audience            | Delivered by       |
|-------------------------|-----------|---------------------|--------------------|
| AI Usage Dashboard      | Monthly   | IMS Manager         | AI Administrator   |
| SLA Compliance Report   | Quarterly | Management Review   | IMS Manager        |
| Provider Review         | Annually  | Top Management      | IMS Manager        |
| Cost Optimization       | Quarterly | IMS Manager         | AI Administrator   |

## 8. Related Documents

| Document       | Title                                  |
|----------------|----------------------------------------|
| AC-AI-001      | AI Assistant Access Control Policy     |
| PR-AI-001      | AI Assistant Usage Procedure           |
| RA-AI-001      | AI Assistant Risk Assessment           |
| [Org ref]      | Service Level Management Procedure     |
| [Org ref]      | Supplier Management Procedure          |
| [Org ref]      | Capacity Management Procedure          |
| [Org ref]      | Business Continuity Plan               |

---

*Document control: This document is subject to the organization's document control
procedure. Printed copies are uncontrolled.*
