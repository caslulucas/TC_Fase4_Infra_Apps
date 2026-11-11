# 🚀 ToggleMaster — Tech Challenge Fase 4

## Infraestrutura, Microsserviços, DevSecOps e OpenTelemetry

Projeto desenvolvido para o **Tech Challenge Fase 4 da Pós-Tech FIAP — DevOps & Arquitetura Cloud**.

A Fase 4 representa a evolução do ToggleMaster para um cenário de **Observabilidade Total e Resposta Ativa**, preservando a infraestrutura, os microsserviços, CI/CD, DevSecOps e GitOps construídos nas fases anteriores.

Este repositório concentra principalmente:

- Código-fonte dos microsserviços
- Instrumentação OpenTelemetry
- Dockerfiles
- Pipelines CI/CD e DevSecOps
- Infrastructure as Code com Terraform
- Recursos AWS
- Imagem e código da automação de Self-Healing

> O estado desejado do Kubernetes e toda a stack GitOps estão mantidos em um repositório separado: `TC_Fase4_GitOps`.

---

# 📖 Visão Geral

O **ToggleMaster** é uma plataforma distribuída para gerenciamento e avaliação de Feature Flags.

A plataforma é composta por cinco microsserviços:

| Serviço | Responsabilidade | Tecnologia principal |
|---|---|---|
| **Auth** | Autenticação e gerenciamento de API Keys | Go + PostgreSQL |
| **Flag** | CRUD e gerenciamento das Feature Flags | Python/Flask + PostgreSQL |
| **Targeting** | Regras de segmentação de usuários | Python/Flask + PostgreSQL |
| **Evaluation** | Avaliação das Feature Flags, hot path da plataforma | Go + Redis |
| **Analytics** | Processamento assíncrono dos eventos de avaliação | Python + SQS + DynamoDB |

O fluxo principal é:

```text
Cliente
   │
   ▼
Evaluation
   │
   ├────► Redis
   │
   ├────► Flag ─────────► Auth
   │
   ├────► Targeting ─────► Auth
   │
   ▼
Decisão da Feature Flag
   │
   ├────► Resposta ao cliente
   │
   └────► Amazon SQS
               │
               ▼
           Analytics
               │
               ▼
           DynamoDB
```

---

# 🎯 Objetivo da Fase 4

Nas fases anteriores, o ToggleMaster evoluiu de um MVP monolítico para uma arquitetura baseada em microsserviços, Kubernetes, Infrastructure as Code, DevSecOps e GitOps.

Na Fase 4 o novo desafio passa a ser operacional:

> Como identificar rapidamente uma degradação em um ambiente distribuído, descobrir sua causa e reagir automaticamente a uma condição crítica?

Para responder a esse problema foram implementados:

```text
Métricas
+
Logs centralizados
+
Distributed Tracing
+
APM
+
Alerting
+
Incident Management
+
ChatOps
+
Self-Healing
```

---

# 🏗️ Arquitetura Geral

```text
                         TOGGLEMASTER
                              │
              ┌───────────────┼───────────────┐
              │               │               │
            Logs           Metrics          Traces
              │               │               │
              ▼               │               │
         OTel Agent           │               │
              │               │               │
              └───────────────┼───────────────┘
                              │
                              ▼
                    OpenTelemetry Collector
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
            Loki         Span Metrics      New Relic
              │               │               │
              │               ▼               │
              │           Prometheus           │
              │               │               │
              └───────┬───────┘               │
                      │                       │
                      ▼                       ▼
                    Grafana              APM / Tracing
                      │
                      ▼
                Grafana Alerting
                 ╱      │       ╲
                ▼       ▼        ▼
           PagerDuty  Discord  Self-Healing
                                │
                                ▼
                          Kubernetes API
                                │
                                ▼
                         Evaluation Service
```

---

# 🔭 OpenTelemetry

O **OpenTelemetry** foi utilizado como padrão de instrumentação e transporte da telemetria.

O objetivo é evitar que os microsserviços fiquem diretamente acoplados aos backends de observabilidade.

```text
Microsserviços
      │
      ▼
OpenTelemetry
      │
      ▼
OTel Collector
      │
      ├────► Prometheus
      ├────► Loki
      └────► New Relic
```

Os microsserviços utilizam bibliotecas OpenTelemetry específicas para Go e Python.

O contexto da requisição é propagado entre os serviços, permitindo que diferentes operações sejam correlacionadas através do mesmo **Trace ID**.

---

# 🔎 Distributed Tracing

O Distributed Tracing permite acompanhar o caminho executado por uma requisição através da arquitetura distribuída.

Exemplo:

```text
Evaluation
   │
   ├────► Flag
   │        │
   │        └────► Auth
   │
   └────► Targeting
            │
            └────► Auth
```

O fluxo assíncrono também envolve:

```text
Evaluation
   │
   ▼
Amazon SQS
   │
   ▼
Analytics
   │
   ▼
DynamoDB
```

Os traces são enviados para o OpenTelemetry Collector e posteriormente exportados para o New Relic.

---

# 📊 Span Metrics

Além de Distributed Tracing, os spans são reutilizados para produzir métricas de aplicação.

O **Span Metrics Connector** transforma traces em métricas Prometheus.

Exemplo:

```promql
traces_span_metrics_calls_total
```

Request rate por serviço:

```promql
sum by (service_name) (
  rate(traces_span_metrics_calls_total[5m])
)
```

Durante a validação foram observadas métricas provenientes dos cinco microsserviços:

```text
auth-service
flag-service
targeting-service
evaluation-service
analytics-service
```

---

# ☁️ Infraestrutura AWS

Toda a infraestrutura é provisionada utilizando **Terraform**.

## Networking

- Amazon VPC
- Subnets públicas
- Subnets privadas
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups

## Kubernetes

- Amazon EKS
- Managed Node Groups

## Persistência

- 3x Amazon RDS PostgreSQL
  - Auth
  - Flag
  - Targeting
- Amazon ElastiCache Redis
- Amazon DynamoDB

## Mensageria

- Amazon SQS

## Container Registry

- Amazon ECR

Repositórios utilizados:

```text
togglemaster-auth
togglemaster-flag
togglemaster-targeting
togglemaster-evaluation
togglemaster-analytics
togglemaster-self-healing
```

## Terraform State

O `terraform.tfstate` da infraestrutura principal utiliza backend remoto no Amazon S3.

---

# 📁 Estrutura Terraform

```text
01-terraform/
│
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
│
├── environments/
│   ├── academy/
│   └── personal/
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── redis/
│   ├── dynamodb/
│   ├── sqs/
│   └── ecr/
│
├── backend.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
└── versions.tf
```

A organização modular permite reutilização, manutenção e reconstrução completa do ambiente.

---

# 🎓 AWS Academy

O projeto possui compatibilidade específica com o AWS Academy.

Devido às restrições de IAM do ambiente acadêmico, o Terraform não cria novas Roles ou Policies quando executado em:

```text
environment = academy
```

Nesse cenário é reutilizada a:

```text
LabRole
```

para:

- EKS Cluster
- Managed Node Groups

Credenciais temporárias do AWS Academy não são versionadas no repositório.

---

# 🔐 DevSecOps

Os pipelines GitHub Actions incorporam controles de qualidade e segurança antes da publicação das imagens.

Fluxo:

```text
Código
  │
  ├────► Build
  ├────► Unit Tests
  ├────► Lint
  ├────► SAST
  ├────► SCA
  ├────► Docker Build
  └────► Container Scan
              │
              ▼
          Amazon ECR
```

Ferramentas utilizadas incluem:

- GitHub Actions
- Trivy
- Gosec
- Bandit
- GolangCI-Lint
- Docker

---

# 🐳 Containers

Cada microsserviço possui sua própria imagem Docker.

Na Fase 4 as imagens também incluem os componentes necessários à instrumentação OpenTelemetry.

Fluxo:

```text
Código-fonte
    │
    ▼
Docker Build
    │
    ▼
Security Scan
    │
    ▼
Amazon ECR
    │
    ▼
GitOps
    │
    ▼
Amazon EKS
```

---

# 🧠 Self-Healing

A Fase 4 adiciona uma automação própria de **Self-Healing**.

O serviço recebe um webhook do Grafana quando um alerta chega ao estado `Firing`.

Fluxo:

```text
Grafana Firing
      │
      ▼
Webhook /heal
      │
      ▼
Self-Healing
      │
      ▼
Kubernetes API
      │
      ▼
Patch no Deployment
      │
      ▼
Novo ReplicaSet
      │
      ▼
Novo Pod
```

Na validação final, o alvo utilizado foi:

```text
namespace: evaluation
deployment: evaluation-deployment
```

---

# 🛡️ Segurança do Self-Healing

O serviço utiliza:

- ServiceAccount
- Role
- RoleBinding

A permissão utiliza o princípio do menor privilégio.

A automação possui apenas:

```text
get
patch
```

sobre:

```text
evaluation-deployment
```

no namespace:

```text
evaluation
```

---

# ⏳ Cooldown

Para evitar um **restart storm**, foi implementado cooldown de:

```text
600 segundos
```

Fluxo:

```text
Primeiro alerta Firing
       │
       ▼
Self-Healing executado
       │
       ▼
Pod reiniciado

Novos alertas dentro de 600s
       │
       ▼
Evento ignorado
```

---

# 🔄 Integração com GitOps

Este repositório contém a aplicação, infraestrutura e componentes de automação.

O estado desejado do Kubernetes fica no repositório:

```text
TC_Fase4_GitOps
```

Fluxo:

```text
Infra_Apps
    │
    ├────► CI / DevSecOps
    │
    └────► Amazon ECR
               │
               ▼
           GitOps Repo
               │
               ▼
             ArgoCD
               │
               ▼
          Amazon EKS
```

---

# 🧰 Tecnologias

## Cloud

- AWS
- Amazon EKS
- Amazon ECR
- Amazon RDS PostgreSQL
- Amazon ElastiCache Redis
- Amazon DynamoDB
- Amazon SQS
- Amazon S3

## Infrastructure as Code

- Terraform

## Aplicações

- Go
- Python
- Flask
- Gunicorn

## Containers

- Docker
- Kubernetes

## DevSecOps

- GitHub Actions
- Trivy
- Gosec
- Bandit
- GolangCI-Lint

## Observabilidade

- OpenTelemetry
- OTLP
- Span Metrics
- Prometheus
- Grafana
- Loki
- New Relic

## Incident Management

- Grafana Alerting
- PagerDuty
- Discord

## Automação

- Python
- Flask
- Kubernetes API
- RBAC
- Self-Healing

---

# ✅ Principais Resultados

- Infraestrutura AWS reproduzível via Terraform
- Amazon EKS criado via IaC
- Cinco microsserviços executando em Kubernetes
- Imagens instrumentadas com OpenTelemetry
- Telemetria dos cinco serviços processada pelo OTel Collector
- Métricas de aplicação derivadas dos traces
- Distributed Tracing no New Relic
- Integração com GitOps e ArgoCD
- Self-Healing executado automaticamente a partir de alertas
- RBAC com privilégio mínimo
- Cooldown contra restart storm

---

# 📦 Repositórios

A solução da Fase 4 é dividida em dois repositórios.

## Infraestrutura e aplicações

```text
TC_Fase4_Infra_Apps
```

Responsável por:

- microsserviços;
- Terraform;
- Docker;
- instrumentação;
- CI/DevSecOps;
- Self-Healing.

## GitOps

```text
TC_Fase4_GitOps
```

Responsável por:

- manifestos Kubernetes;
- ArgoCD;
- Prometheus;
- Grafana;
- Loki;
- OTel Collector;
- OTel Agent;
- Alerting;
- configuração Kubernetes do Self-Healing.

---

# 🏁 Conclusão

A Fase 4 transforma o ToggleMaster em uma plataforma capaz não apenas de ser provisionada e implantada automaticamente, mas também de **observar seu próprio comportamento e reagir a condições críticas**.

A integração entre OpenTelemetry, Prometheus, Grafana, Loki, New Relic, PagerDuty, Discord e Self-Healing estabelece uma arquitetura completa de:

```text
Observabilidade
+
Distributed Tracing
+
Incident Management
+
ChatOps
+
Resposta Ativa
```

O resultado é uma plataforma Cloud Native mais observável, rastreável, resiliente e alinhada às práticas modernas de DevOps e SRE.