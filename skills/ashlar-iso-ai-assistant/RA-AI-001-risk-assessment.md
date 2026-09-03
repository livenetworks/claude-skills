# RA-AI-001: AI Assistant Risk Assessment

| Field            | Value                                      |
|------------------|--------------------------------------------|
| Document ID      | RA-AI-001                                  |
| Version          | 1.0                                        |
| Classification   | Confidential                               |
| Owner            | [IMS Manager]                              |
| Approved by      | [Top Management]                           |
| Assessment date  | [Date]                                     |
| Next review      | [Date + 12 months] or on significant change|
| Standards        | ISO/IEC 27001:2022 (6.1.2), ISO 9001 (6.1) |

---

## 1. Methodology

### 1.1 Risk Scoring

Risks are scored using the organization's standard risk matrix:

**Likelihood (L):**
| Score | Level      | Description                                    |
|-------|------------|------------------------------------------------|
| 1     | Rare       | Could occur in exceptional circumstances        |
| 2     | Unlikely   | Could occur but not expected                   |
| 3     | Possible   | Might occur at some time                        |
| 4     | Likely     | Will probably occur in most circumstances       |
| 5     | Almost certain | Expected to occur frequently              |

**Impact (I):**
| Score | Level      | Description                                    |
|-------|------------|------------------------------------------------|
| 1     | Negligible | Minimal effect on operations or reputation     |
| 2     | Minor      | Small financial or operational impact           |
| 3     | Moderate   | Noticeable service disruption or data exposure  |
| 4     | Major      | Significant breach, regulatory attention        |
| 5     | Severe     | Critical breach, legal action, loss of cert.   |

**Risk Level = L × I:**
| Risk Score | Level    | Action Required                              |
|------------|----------|----------------------------------------------|
| 1–4        | Low      | Accept — monitor during management review    |
| 5–9        | Medium   | Mitigate — implement controls within 90 days |
| 10–15      | High     | Mitigate — implement controls within 30 days |
| 16–25      | Critical | Avoid or transfer — immediate action needed  |

### 1.2 Scope

This assessment covers all AI assistant tools identified in AC-AI-001 §2,
deployed or planned for deployment at [Organization Name].

---

## 2. Asset Identification

| Asset ID  | Asset Description                      | Asset Owner      | Classification |
|-----------|----------------------------------------|------------------|----------------|
| AI-01     | Self-hosted AI gateway (OpenClaw)      | AI Administrator | Internal       |
| AI-02     | Cloud AI API subscription (Claude)     | AI Administrator | Internal       |
| AI-03     | AI-generated outputs (documents, code) | End users        | Varies         |
| AI-04     | AI interaction logs                    | IMS Manager      | Internal       |
| AI-05     | API keys / authentication tokens       | AI Administrator | Restricted     |

---

## 3. Risk Register

### R-AI-01: Data Leakage via AI Prompts

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-01                                                    |
| Threat             | User submits confidential/restricted data to AI service     |
| Vulnerability      | Lack of awareness, no input filtering, copy-paste habit     |
| Impact area        | Confidentiality                                            |
| Affected assets    | AI-02, AI-03                                               |
| Likelihood (L)     | 4 — Likely                                                 |
| Impact (I)         | 4 — Major                                                  |
| **Inherent Risk**  | **16 — Critical**                                          |
| Controls           | AC-AI-001 §4 (classification restrictions),                |
|                    | PR-AI-001 §5.2 (classification check),                    |
|                    | PR-AI-001 §5.3 (data masking),                            |
|                    | PR-AI-001 §7.2 (awareness training)                       |
| Residual L         | 2                                                          |
| Residual I         | 4                                                          |
| **Residual Risk**  | **8 — Medium**                                             |
| Risk owner         | [IMS Manager]                                              |
| Treatment          | Mitigate                                                   |

### R-AI-02: AI Hallucination in Deliverables

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-02                                                    |
| Threat             | AI generates inaccurate content accepted without review     |
| Vulnerability      | Over-reliance on AI, insufficient output validation        |
| Impact area        | Integrity, Quality                                         |
| Affected assets    | AI-03                                                      |
| Likelihood (L)     | 4 — Likely                                                 |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **12 — High**                                              |
| Controls           | PR-AI-001 §5.4 (output validation),                       |
|                    | PR-AI-001 §4.2 (no sole AI decisions)                     |
| Residual L         | 3                                                          |
| Residual I         | 2                                                          |
| **Residual Risk**  | **6 — Medium**                                             |
| Risk owner         | Department heads                                           |
| Treatment          | Mitigate                                                   |

### R-AI-03: Prompt Injection on Self-Hosted Agent

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-03                                                    |
| Threat             | Malicious input causes AI agent to execute unintended actions |
| Vulnerability      | Inherent LLM vulnerability, third-party skills             |
| Impact area        | Confidentiality, Integrity, Availability                   |
| Affected assets    | AI-01                                                      |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 4 — Major                                                  |
| **Inherent Risk**  | **12 — High**                                              |
| Controls           | AC-AI-001 §6 (self-hosted hardening),                      |
|                    | PR-AI-001 §8 (change mgmt for skills),                    |
|                    | Network segmentation, exec approvals on agent              |
| Residual L         | 2                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **6 — Medium**                                             |
| Risk owner         | AI Administrator                                           |
| Treatment          | Mitigate                                                   |

### R-AI-04: AI Service Unavailability

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-04                                                    |
| Threat             | Cloud AI provider outage or rate limiting                  |
| Vulnerability      | Dependency on single external provider                     |
| Impact area        | Availability                                               |
| Affected assets    | AI-02                                                      |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 2 — Minor                                                  |
| **Inherent Risk**  | **6 — Medium**                                             |
| Controls           | SLA-AI-001 (service level monitoring),                     |
|                    | Fallback to manual process,                                |
|                    | Model failover configuration                               |
| Residual L         | 2                                                          |
| Residual I         | 2                                                          |
| **Residual Risk**  | **4 — Low**                                                |
| Risk owner         | AI Administrator                                           |
| Treatment          | Accept                                                     |

### R-AI-05: Unauthorized AI Usage (Shadow AI)

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-05                                                    |
| Threat             | Personnel use unapproved AI tools with organizational data |
| Vulnerability      | Free AI tools widely available, lack of monitoring         |
| Impact area        | Confidentiality, Compliance                                |
| Affected assets    | AI-03                                                      |
| Likelihood (L)     | 4 — Likely                                                 |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **12 — High**                                              |
| Controls           | AC-AI-001 (approved tools only),                           |
|                    | PR-AI-001 §4.2 (prohibited uses),                         |
|                    | PR-AI-001 §7.2 (awareness training),                      |
|                    | Network filtering of unapproved AI domains (optional)     |
| Residual L         | 3                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **9 — Medium**                                             |
| Risk owner         | [IMS Manager]                                              |
| Treatment          | Mitigate                                                   |

### R-AI-06: Intellectual Property Violation

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-06                                                    |
| Threat             | AI generates content that infringes copyright or patents   |
| Vulnerability      | LLM trained on public data, user unaware of IP origins     |
| Impact area        | Legal, Reputation                                          |
| Affected assets    | AI-03                                                      |
| Likelihood (L)     | 2 — Unlikely                                               |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **6 — Medium**                                             |
| Controls           | PR-AI-001 §5.4 (IP check in output validation)            |
| Residual L         | 1                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **3 — Low**                                                |
| Risk owner         | Department heads                                           |
| Treatment          | Accept                                                     |

### R-AI-07: API Key Compromise

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-07                                                    |
| Threat             | AI API key leaked, stolen, or misused                      |
| Vulnerability      | Keys stored insecurely, shared between users               |
| Impact area        | Confidentiality, Financial                                 |
| Affected assets    | AI-05                                                      |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **9 — Medium**                                             |
| Controls           | AC-AI-001 §5 (key management),                            |
|                    | Secrets manager, 90-day rotation                           |
| Residual L         | 1                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **3 — Low**                                                |
| Risk owner         | AI Administrator                                           |
| Treatment          | Mitigate                                                   |

---

## 4. Risk Treatment Summary

| Risk ID  | Inherent | Treatment | Residual | Status        |
|----------|----------|-----------|----------|---------------|
| R-AI-01  | 16 Crit  | Mitigate  | 8 Med    | Controls active |
| R-AI-02  | 12 High  | Mitigate  | 6 Med    | Controls active |
| R-AI-03  | 12 High  | Mitigate  | 6 Med    | Controls active |
| R-AI-04  | 6 Med    | Accept    | 4 Low    | Monitored      |
| R-AI-05  | 12 High  | Mitigate  | 9 Med    | Controls active |
| R-AI-06  | 6 Med    | Accept    | 3 Low    | Monitored      |
| R-AI-07  | 9 Med    | Mitigate  | 3 Low    | Controls active |

## 5. Review and Approval

| Role              | Name      | Signature | Date |
|-------------------|-----------|-----------|------|
| Prepared by       | [Name]    |           |      |
| Reviewed by       | [Name]    |           |      |
| Approved by       | [Name]    |           |      |

---

*This risk assessment is a living document. It must be updated when new AI tools are
introduced, incidents occur, or during the scheduled annual review.*
