# RA-AI-001 Supplement: Software Development Risks

These risks extend the base AI risk register (RA-AI-001) with software
development-specific threats. Add these to the main risk register when
the organization uses AI tools for development activities.

---

### R-AI-08: Vulnerable Code from AI

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-08                                                    |
| Threat             | AI generates code with security vulnerabilities (SQLi, XSS, IDOR, insecure crypto) |
| Vulnerability      | AI trained on public code including vulnerable patterns; developer trusts output |
| Impact area        | Confidentiality, Integrity                                 |
| Affected assets    | Production systems, customer data                          |
| Likelihood (L)     | 4 — Likely                                                 |
| Impact (I)         | 4 — Major                                                  |
| **Inherent Risk**  | **16 — Critical**                                          |
| Controls           | PR-AI-002 §5.4 Gate 1 (SAST/security scan),               |
|                    | PR-AI-002 §5.5 (mandatory testing for L2+),               |
|                    | PR-AI-002 §5.6 (environment separation),                  |
|                    | PR-AI-002 §9 (developer security training)                |
| Residual L         | 2                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **6 — Medium**                                             |
| Risk owner         | Lead Developer                                             |
| Treatment          | Mitigate                                                   |

### R-AI-09: License Contamination

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-09                                                    |
| Threat             | AI reproduces copyleft-licensed or copyrighted code, contaminating proprietary codebase |
| Vulnerability      | AI trained on open-source code; no inherent license awareness |
| Impact area        | Legal, Financial                                           |
| Affected assets    | Source code, intellectual property                          |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **9 — Medium**                                             |
| Controls           | PR-AI-002 §5.4 Gate 3 (license scan),                     |
|                    | SCA tooling in CI/CD pipeline                              |
| Residual L         | 2                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **6 — Medium**                                             |
| Risk owner         | Lead Developer                                             |
| Treatment          | Mitigate                                                   |

### R-AI-10: AI Hallucinated APIs / Dependencies

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-10                                                    |
| Threat             | AI references non-existent packages, methods, or APIs; developer installs malicious typosquat package |
| Vulnerability      | AI hallucination + auto-complete trust; malicious packages on npm/Packagist |
| Impact area        | Integrity, Confidentiality (supply chain attack)           |
| Affected assets    | Development environment, production systems                |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 4 — Major                                                  |
| **Inherent Risk**  | **12 — High**                                              |
| Controls           | PR-AI-002 §5.4 Gate 2 (hallucination checklist),          |
|                    | Composer audit / npm audit in CI/CD,                       |
|                    | Lockfile review in code review process                     |
| Residual L         | 2                                                          |
| Residual I         | 3                                                          |
| **Residual Risk**  | **6 — Medium**                                             |
| Risk owner         | Lead Developer                                             |
| Treatment          | Mitigate                                                   |

### R-AI-11: Production Data Exposure via AI Debugging

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-11                                                    |
| Threat             | Developer pastes production logs, stack traces, or database dumps into AI for debugging |
| Vulnerability      | Debugging pressure, habit, lack of synthetic data          |
| Impact area        | Confidentiality                                            |
| Affected assets    | Customer PII, production credentials                       |
| Likelihood (L)     | 4 — Likely                                                 |
| Impact (I)         | 4 — Major                                                  |
| **Inherent Risk**  | **16 — Critical**                                          |
| Controls           | PR-AI-001 §5.3 (data masking),                            |
|                    | PR-AI-002 §5.2 (dev data protection rules),               |
|                    | PR-AI-002 §6 (prohibited: sharing prod data),             |
|                    | PR-AI-002 §9 (training)                                   |
| Residual L         | 2                                                          |
| Residual I         | 4                                                          |
| **Residual Risk**  | **8 — Medium**                                             |
| Risk owner         | Lead Developer                                             |
| Treatment          | Mitigate                                                   |

### R-AI-12: Uncontrolled AI Agent Actions

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-12                                                    |
| Threat             | AI agent in development mode executes destructive commands (rm, DROP, git push --force) |
| Vulnerability      | Agent has shell access; broad file system permissions       |
| Impact area        | Integrity, Availability                                    |
| Affected assets    | Source code repository, development infrastructure          |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 3 — Moderate                                               |
| **Inherent Risk**  | **9 — Medium**                                             |
| Controls           | PR-AI-002 §7.1 (agent controls: sandbox, scope, approval), |
|                    | Execution approval required for shell commands,            |
|                    | Git branch protection rules                                |
| Residual L         | 1                                                          |
| Residual I         | 2                                                          |
| **Residual Risk**  | **2 — Low**                                                |
| Risk owner         | AI Administrator                                           |
| Treatment          | Mitigate                                                   |

### R-AI-13: Overreliance on AI — Skill Degradation

| Field              | Value                                                      |
|--------------------|------------------------------------------------------------|
| Risk ID            | R-AI-13                                                    |
| Threat             | Developers lose ability to write/debug code independently; critical when AI is unavailable |
| Vulnerability      | Convenience dependency, reduced manual practice            |
| Impact area        | Quality, Business Continuity                               |
| Affected assets    | Development capability, organizational knowledge            |
| Likelihood (L)     | 3 — Possible                                               |
| Impact (I)         | 2 — Minor                                                  |
| **Inherent Risk**  | **6 — Medium**                                             |
| Controls           | PR-AI-002 §5.1 (complexity assessment — high/critical = human first), |
|                    | SLA-AI-001 §6 (fallback to manual process),               |
|                    | Regular code reviews enforce understanding                 |
| Residual L         | 2                                                          |
| Residual I         | 2                                                          |
| **Residual Risk**  | **4 — Low**                                                |
| Risk owner         | [IMS Manager]                                              |
| Treatment          | Accept + Monitor                                           |

---

## Updated Risk Treatment Summary (Development Supplement)

| Risk ID  | Description                            | Inherent | Treatment | Residual |
|----------|----------------------------------------|----------|-----------|----------|
| R-AI-08  | Vulnerable code from AI               | 16 Crit  | Mitigate  | 6 Med    |
| R-AI-09  | License contamination                  | 9 Med    | Mitigate  | 6 Med    |
| R-AI-10  | Hallucinated APIs / dependencies       | 12 High  | Mitigate  | 6 Med    |
| R-AI-11  | Production data in AI debugging        | 16 Crit  | Mitigate  | 8 Med    |
| R-AI-12  | Uncontrolled AI agent actions          | 9 Med    | Mitigate  | 2 Low    |
| R-AI-13  | Skill degradation / overreliance       | 6 Med    | Accept    | 4 Low    |
