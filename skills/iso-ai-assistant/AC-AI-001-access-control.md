# AC-AI-001: AI Assistant Access Control Policy

| Field            | Value                                      |
|------------------|--------------------------------------------|
| Document ID      | AC-AI-001                                  |
| Version          | 1.0                                        |
| Classification   | Internal                                   |
| Owner            | [IMS Manager]                              |
| Approved by      | [Top Management]                           |
| Effective date   | [Date]                                     |
| Review cycle     | Annual or on significant change            |
| Standards        | ISO/IEC 27001:2022 A.5.15, A.8.2, A.8.3   |

---

## 1. Purpose

This policy defines who may access AI assistant services, under what conditions,
and with what restrictions, ensuring that AI tool usage aligns with the organization's
information security objectives and risk appetite.

## 2. Scope

This policy applies to all AI assistant tools used within [Organization Name], including
but not limited to:

- Self-hosted AI agents (e.g., OpenClaw)
- Cloud-based AI assistants (e.g., Claude, ChatGPT, Copilot)
- AI-powered features embedded in existing tools (e.g., IDE assistants, email AI)
- Any tool that sends organizational data to a Large Language Model (LLM)

## 3. Access Roles

### 3.1 Role Definitions

| Role              | Description                                                    | Approval Required |
|-------------------|----------------------------------------------------------------|-------------------|
| AI Administrator  | Configures AI platform, manages API keys, monitors usage       | Top Management    |
| AI Power User     | Full access to AI assistants for operational tasks             | IMS Manager       |
| AI Standard User  | Basic access with data classification restrictions             | Department Head   |
| AI Viewer         | Can view AI-generated outputs but cannot interact directly     | N/A               |
| No Access         | Default for all personnel until explicitly granted             | N/A               |

### 3.2 Role Assignments

- All new personnel default to **No Access**
- Access is granted through formal request to [IMS Manager]
- Each role assignment must be documented with: name, role, date, approver, justification
- Role assignments are reviewed quarterly by [IMS Manager]

## 4. Access Restrictions by Data Classification

| Data Classification | AI Standard User        | AI Power User           | AI Administrator |
|---------------------|-------------------------|-------------------------|------------------|
| Public              | ✅ Allowed               | ✅ Allowed               | ✅ Allowed        |
| Internal            | ✅ With masking          | ✅ With masking          | ✅ With masking   |
| Confidential        | ❌ Prohibited            | ⚠️ Only with approval   | ⚠️ Only with approval |
| Restricted          | ❌ Prohibited            | ❌ Prohibited            | ❌ Prohibited     |

### 4.1 Prohibited Data Categories (all roles)

The following data types must NEVER be submitted to any AI assistant:

- Passwords, API keys, tokens, certificates, or cryptographic material
- Personal identification numbers (EMBG, passport, ID card numbers)
- Payment card data (PAN, CVV, expiry)
- Health records or medical data
- Data classified as Restricted in the organization's classification scheme
- Client data under NDA unless the NDA explicitly permits AI processing
- Unredacted audit findings or nonconformity reports

## 5. API Key Management

### 5.1 Key Provisioning

- API keys for AI services are provisioned by the AI Administrator only
- Each key must be associated with a named individual or service account
- Shared API keys are prohibited
- Keys are stored in an approved secrets manager — never in source code, config files, or chat

### 5.2 Key Lifecycle

| Event                | Action                                              |
|----------------------|-----------------------------------------------------|
| New key issued       | Log in access register, set expiry (max 90 days)    |
| Key rotation         | Rotate every 90 days or on personnel change         |
| Personnel departure  | Revoke within 24 hours of departure notification    |
| Suspected compromise | Revoke immediately, log security event, rotate      |
| Decommissioning      | Revoke, confirm zero usage for 7 days, archive log  |

## 6. Self-Hosted AI (OpenClaw / Local LLM)

When the organization operates a self-hosted AI assistant:

- The host system must be included in the asset inventory (27001 A.5.9)
- Network access to the AI gateway must be restricted to authorized networks/VPNs
- Admin access to the AI gateway requires multi-factor authentication
- AI gateway logs must be retained per the organization's log retention policy
- The AI gateway must be included in vulnerability management scope (27001 A.8.8)
- Container/OS updates must follow the organization's patch management process

## 7. Cloud-Based AI Services

When using third-party AI services:

- The provider must be evaluated per the organization's supplier management process
- Terms of service must be reviewed for data processing, retention, and training clauses
- Data residency requirements must be confirmed (EU providers preferred where applicable)
- Usage must comply with the organization's acceptable use policy (27001 A.5.10)

## 8. Monitoring and Audit

- All AI assistant interactions are logged (user, timestamp, model, token count, purpose tag)
- Usage logs are reviewed monthly by [IMS Manager]
- Anomalous patterns (unusual hours, excessive tokens, restricted data keywords) trigger review
- Access control records are audited during internal audits per the IMS audit program
- Quarterly access review: confirm all assigned roles are still appropriate

## 9. Violations

Violations of this policy are handled per the organization's disciplinary procedure:

| Severity | Example                                        | Action                              |
|----------|------------------------------------------------|--------------------------------------|
| Minor    | Using AI without logging purpose               | Warning + retraining                |
| Major    | Submitting Internal data without masking        | Access suspension + investigation   |
| Critical | Submitting Restricted/Confidential data to AI  | Immediate revocation + incident mgmt|

## 10. Related Documents

| Document       | Title                                  |
|----------------|----------------------------------------|
| PR-AI-001      | AI Assistant Usage Procedure           |
| RA-AI-001      | AI Assistant Risk Assessment           |
| SLA-AI-001     | AI Assistant Service Level             |
| [Org ref]      | Information Classification Policy      |
| [Org ref]      | Acceptable Use Policy                  |
| [Org ref]      | Supplier Management Procedure          |

---

*Document control: This document is subject to the organization's document control
procedure. Printed copies are uncontrolled.*
