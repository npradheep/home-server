# Personal Cloud Infrastructure

A self-hosted, production-grade home infrastructure platform running on a dedicated Windows PC (WSL2) and a Raspberry Pi. Designed around enterprise patterns — zero-trust networking, SSO with 2FA, centralized monitoring, automated alerting, and on-call incident response. Used daily by 3 roommates and a handful of friends.

**95% uptime over the past 12 months**, tracked via Uptime Kuma and alerted through PagerDuty.

---

## Architecture

```
Internet (users / remote access)
        │                        │
  Cloudflare Tunnel         Tailscale VPN
  (*.pradheep.me)           (remote desktop / admin)
        │                        │
  Authentik SSO (2FA)            │
        │                        │
        └──────────┬─────────────┘
                   │
         Dedicated PC (WSL2)
         Docker + Portainer
```

> Full architecture diagram in [`/docs/architecture.svg`](./docs/architecture.svg)

---

## Stack

### Networking & Access
| Service | Purpose |
|---|---|
| **Cloudflare Tunnel** | Zero-trust proxy — all services exposed publicly sit behind Cloudflare, no open ports on the router |
| **Authentik** | SSO identity provider with 2FA enforcement for all web-facing services |
| **Tailscale** | Mesh VPN — used for remote desktop access and internal admin without exposing RDP publicly |

### Core Services
| Service | Purpose |
|---|---|
| **Nextcloud AIO** | Self-hosted file storage and NAS — per-user private storage for household members |
| **Homarr** | Unified dashboard for all running services |
| **n8n** | Workflow automation platform |
| **Ollama + Open WebUI** | Local LLM inference — private AI workflows without sending data to external providers |

### Observability & Incident Response
| Service | Purpose |
|---|---|
| **New Relic** | Infrastructure metrics, custom dashboards, and alerting |
| **Uptime Kuma** | Uptime checks for all exposed services |
| **PagerDuty** | On-call alerting — Uptime Kuma triggers PagerDuty incidents for outages |
| **Fluent Bit** | Log shipping and aggregation |

### Management
| Service | Purpose |
|---|---|
| **Portainer** | Docker container management — all stacks defined as Docker Compose and managed via Portainer UI |

---

## Raspberry Pi — Home Assistant

A separate Raspberry Pi running **Home Assistant OS** handles smart home automation:

- Controls lighting, thermostat, and access workflows
- Exposed via its own dedicated **Cloudflare Tunnel** on a separate subdomain under `pradheep.me`
- Integrated into the same Cloudflare account as the main server for centralized DNS and access control

---

## Infrastructure Setup

### Host Environment
All Docker containers run inside **WSL2** on a dedicated Windows PC. The PC is assigned a **local static IP** via the router's DHCP reservation, making it consistently reachable on the home network without manual configuration.

### Remote Access
Two paths depending on context:

| Scenario | Method |
|---|---|
| Local network | Direct RDP to static IP — no overhead, full speed |
| Remote / external | Tailscale mesh VPN — connect to the Tailscale network first, then RDP over the encrypted tunnel |

This keeps RDP off the public internet entirely. No port forwarding, no exposed RDP endpoint.

### Network Design
All web-facing services are accessible via subdomains under `pradheep.me`. The access flow is:

```
User → Cloudflare (DNS + proxy) → cloudflared agent (container) → Authentik SSO → Service
```

- No ports are exposed directly on the router — all inbound traffic flows through Cloudflare Tunnel
- Every web-facing service requires Authentik SSO authentication with 2FA
- Tailscale handles direct encrypted access for admin and remote desktop use cases

---

## Incident Response

This runs like a production service:

- **Uptime Kuma** checks all services on a schedule and fires webhooks on failures
- **PagerDuty** receives those webhooks and sends on-call alerts
- **New Relic** monitors host-level metrics (CPU, memory, disk, network) with threshold-based alerting
- Incidents are triaged, resolved, and tracked — same workflow as professional on-call

**Availability: 95% over the past 12 months**

---

## Key Design Decisions

**Why Cloudflare Tunnel over port forwarding?**
Zero exposed ports on the home router. Cloudflare terminates TLS and proxies traffic to the cloudflared agent running as a container. Combined with Authentik SSO in front of every service, the attack surface is minimal.

**Why Tailscale for remote desktop instead of exposing RDP?**
RDP exposed to the internet is a significant attack surface. Tailscale creates a direct encrypted tunnel between devices — remote desktop works over it at full speed with no public exposure.

**Why WSL2 instead of a dedicated Linux machine?**
Practical for a shared household PC. WSL2 gives a full Linux environment with Docker support while keeping Windows available for everyday use. Static DHCP reservation ensures the host is always reachable at the same IP on the local network.

**Why Ollama locally instead of cloud APIs?**
All AI inference stays on the local machine. No prompts or documents leave the network. Used for testing private workflows, prompt engineering, and AI-assisted productivity without relying on external providers.

**Why Portainer for container management?**
All stacks are defined as Docker Compose files and managed through Portainer. This mirrors how teams manage containers in production — declarative, version-controlled — while providing a UI for quick inspection and restarts.

---

## Repository Structure

```
├── stacks/
│   ├── authentik/          # Authentik SSO stack
│   ├── nextcloud/          # Nextcloud AIO
│   ├── n8n/                # Workflow automation
│   ├── ollama/             # Local LLM + Open WebUI
│   ├── monitoring/         # New Relic, Uptime Kuma, Fluent Bit
│   └── dashboard/          # Homarr
├── docs/
│   └── architecture.svg    # Full architecture diagram
└── README.md
```

---

## Tech Stack

`Docker` · `WSL2` · `Portainer` · `Cloudflare Tunnel` · `Tailscale` · `Authentik SSO` · `Nextcloud` · `Ollama` · `n8n` · `New Relic` · `Uptime Kuma` · `PagerDuty` · `Fluent Bit` · `Home Assistant`
