---
name: iso-ai-assistant
description: >
  ISO-compliant AI assistant integration workflow for organizations with ISO 9001, ISO/IEC 20000-1,
  and ISO/IEC 27001 management systems. Use this skill whenever the user needs to create, review,
  or update documentation for AI assistant usage (OpenClaw, ChatGPT, Claude, Copilot, or any LLM-based tool)
  within a certified management system. Triggers on any mention of: AI policy, AI procedure, AI risk assessment,
  AI acceptable use, AI access control, LLM governance, AI in ISO, chatbot compliance, AI SLA,
  AI incident management, or integrating AI tools into QMS/ISMS/SMS. Also use when auditing or
  reviewing existing AI usage documentation for ISO compliance gaps.
---

# ISO AI Assistant Integration Skill

## Purpose

This skill provides a complete document set for integrating AI assistant tools into an
organization's Integrated Management System (IMS) covering:

- **ISO 9001:2015** — Quality Management System
- **ISO/IEC 20000-1:2018** — IT Service Management System
- **ISO/IEC 27001:2022** — Information Security Management System

## When to Use

- Client is implementing AI assistants and holds (or is pursuing) any of the 3 certifications
- Internal deployment of AI tools (OpenClaw, Claude, ChatGPT, Copilot, etc.)
- Surveillance/recertification audit prep where AI usage needs to be documented
- Gap analysis of existing AI usage against ISO requirements

## Document Set Overview

| Document ID   | Title                              | Primary Standard(s)               |
|---------------|------------------------------------|------------------------------------|
| AC-AI-001     | AI Assistant Access Control Policy | 27001 A.5.15, A.8.2, A.8.3        |
| PR-AI-001     | AI Assistant Usage Procedure       | 9001, 20000-1, 27001              |
| PR-AI-002     | AI-Assisted Software Dev Procedure | 9001 8.3, 27001 A.8.25–A.8.28     |
| RA-AI-001     | AI Assistant Risk Assessment       | 27001 6.1.2, 9001 6.1             |
| RA-AI-001-S   | Risk Supplement: Software Dev      | 27001 6.1.2, 9001 6.1             |
| SLA-AI-001    | AI Assistant Service Level         | 20000-1 8.3, 8.5.1                |

## Workflow

```
1. Read AC-AI-001 template → customize access roles and permissions
2. Read RA-AI-001 template → identify and score risks for client context
3. Read PR-AI-001 template → define the operational procedure
4. Read SLA-AI-001 template → set service levels and monitoring
5. Generate flowchart from PR-AI-001 for visual reference
6. Cross-check all documents against ISO clause mapping table below
```

## ISO Clause Mapping

### ISO 9001:2015
| Clause | Requirement               | Addressed In     |
|--------|---------------------------|------------------|
| 6.1    | Risk-based thinking       | RA-AI-001        |
| 7.1.6  | Organizational knowledge  | PR-AI-001 §6     |
| 7.5    | Documented information    | All documents    |
| 8.1    | Operational planning      | PR-AI-001 §5     |
| 8.3    | Design and development    | PR-AI-002        |
| 8.5    | Production/service provision | PR-AI-002 §5.6 |
| 8.7    | Nonconforming outputs     | PR-AI-001 §5.4, PR-AI-002 §5.4 |
| 10.1   | Improvement               | PR-AI-001 §7     |

### ISO/IEC 20000-1:2018
| Clause | Requirement                      | Addressed In     |
|--------|----------------------------------|------------------|
| 7.5    | Knowledge management             | PR-AI-001 §6     |
| 8.2.4  | Supplier/3rd party management    | SLA-AI-001 §4    |
| 8.3    | Service level management         | SLA-AI-001       |
| 8.5.1  | Change management                | PR-AI-001 §8, PR-AI-002 §10 |
| 8.5.2  | Release management               | PR-AI-002 §5.7   |
| 8.6    | Availability/continuity mgmt     | SLA-AI-001 §3    |
| 8.7.1  | Incident management              | PR-AI-001 §5.5   |

### ISO/IEC 27001:2022
| Clause/Annex | Requirement                     | Addressed In     |
|--------------|----------------------------------|------------------|
| 6.1.2        | Risk assessment                 | RA-AI-001, RA-AI-001-S |
| A.5.10       | Acceptable use of assets        | PR-AI-001 §4     |
| A.5.12       | Classification of information   | PR-AI-001 §5.2   |
| A.5.15       | Access control                  | AC-AI-001        |
| A.8.2        | Privileged access rights        | AC-AI-001 §3     |
| A.8.3        | Information access restriction  | AC-AI-001 §4     |
| A.8.11       | Data masking                    | PR-AI-001 §5.3   |
| A.8.12       | Data leakage prevention         | PR-AI-001 §5.4   |
| A.8.15       | Logging                         | PR-AI-001 §6     |
| A.8.25       | Secure development lifecycle    | PR-AI-002        |
| A.8.26       | Application security req.       | PR-AI-002 §5.4   |
| A.8.27       | Secure system architecture      | PR-AI-002 §5.1   |
| A.8.28       | Secure coding                   | PR-AI-002 §5.4 Gate 1 |
| A.8.31       | Separation of environments      | PR-AI-002 §5.6   |
| A.8.33       | Test information                | PR-AI-002 §5.5   |

## Customization Instructions

When generating documents for a specific client:

1. Replace `[Organization Name]` with the client name
2. Replace `[IMS Manager]` with the responsible person/role
3. Adjust risk scores in RA-AI-001 based on client context:
   - Government/regulated → raise Confidentiality impact scores
   - Software dev → raise Integrity impact scores (code quality)
   - Service desk → raise Availability impact scores
4. Adjust SLA targets in SLA-AI-001 based on AI provider chosen
5. Add client-specific prohibited data categories in PR-AI-001 §4
6. Review and confirm access roles in AC-AI-001 match client org chart

## Templates

All templates are in `templates/` directory:
- `templates/AC-AI-001-access-control.md`
- `templates/PR-AI-001-procedure.md`
- `templates/PR-AI-002-dev-procedure.md`
- `templates/RA-AI-001-risk-assessment.md`
- `templates/RA-AI-001-supplement-dev.md`
- `templates/SLA-AI-001-service-level.md`

Read each template, customize per instructions above, and export to client's preferred format.
