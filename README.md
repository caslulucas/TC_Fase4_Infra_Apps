# Roteiro Privado - Tech Challenge Fase 4

> Material pessoal de apoio à gravação.  
> Não utilizar como entregável.

---

# 1. Estratégia do vídeo

O foco é a **Fase 4**.

A Fase 3 deve aparecer apenas como contexto.

Estrutura:

```text
Contexto rápido
    │
    ▼
Problema da Fase 4
    │
    ▼
Arquitetura de Observabilidade
    │
    ▼
OpenTelemetry
    │
    ▼
Prometheus + Loki + Grafana
    │
    ▼
New Relic
    │
    ▼
Alerting
    │
    ▼
PagerDuty + Discord
    │
    ▼
Self-Healing
    │
    ▼
HandsOn AWS
```

---

# 2. Tempo sugerido

| Bloco | Tempo |
|---|---:|
| Introdução | 1 min |
| Resumo Fase 3 | 1 min |
| Problema + arquitetura Fase 4 | 2 min |
| OTel + métricas + logs | 3 min |
| APM + Tracing | 2 min |
| Alerting + Self-Healing | 2 min |
| AWS/EKS/ArgoCD | 3 min |
| Grafana/Loki/OTel | 3 min |
| New Relic | 3 min |
| Prova Real | 4 min |
| Encerramento | 1 min |

Meta:

```text
23 a 24,5 minutos
```

---

# PARTE 1
# EXPLICAÇÃO DA FASE 4

---

# 3. Abertura

## Na tela

Abrir:

```text
README_FASE4.md
```

no VS Code.

## Falar

> "Olá, meu nome é Lucas Soares dos Santos, RM 373842, e este é o Tech Challenge da Fase 4 da Pós-Tech FIAP.
>
> Esta fase conclui o projeto ToggleMaster e o foco agora é Observabilidade Total e Resposta Ativa.
>
> Antes de iniciar a demonstração prática, vou explicar a arquitetura implementada nesta fase, como métricas, logs e traces percorrem o ambiente e como um alerta pode gerar automaticamente um incidente, uma notificação ChatOps e uma ação de Self-Healing.
>
> O ambiente AWS utilizado anteriormente foi excluído. Na parte prática vou iniciar um novo AWS Academy e reconstruir a base necessária via Terraform, mas a apresentação será concentrada principalmente nas novas funcionalidades da Fase 4."

---

# 4. Contexto da Fase 3

## Máximo 1 minuto

## Falar

> "Como contexto, o ToggleMaster já possuía cinco microsserviços conteinerizados: Auth, Flag, Targeting, Evaluation e Analytics.
>
> A infraestrutura já era definida com Terraform, as imagens passavam por pipelines CI/CD com DevSecOps e eram armazenadas no ECR, e a implantação no EKS era controlada por GitOps com ArgoCD.
>
> Eu não vou reapresentar essa implementação em detalhes porque o foco deste vídeo é a evolução realizada na Fase 4."

Mostrar rapidamente:

```text
Terraform -> AWS / EKS
GitHub Actions -> ECR
GitOps -> ArgoCD -> EKS
```

E seguir.

---

# 5. Problema novo da Fase 4

## Falar

> "O novo problema é operacional.
>
> Em um ambiente distribuído, um pod estar Running não significa necessariamente que a aplicação está saudável.
>
> Um serviço pode ficar lento, aumentar o consumo de recursos, retornar erros ou falhar silenciosamente."

Mostrar:

```text
Metrics -> o que está acontecendo?
Logs    -> o que foi registrado?
Traces  -> por onde a operação passou?
```

> "Depois de detectar o problema, precisamos também reagir. A Fase 4 acrescenta incident management, ChatOps e Self-Healing."

---

# 6. Arquitetura completa

Mostrar o diagrama principal do README.

Explicar de cima para baixo:

```text
Logs
 -> OTel Agent
 -> Collector
 -> Loki

Traces
 -> Collector
 -> New Relic

Traces
 -> Span Metrics
 -> Prometheus

Prometheus + Loki
 -> Grafana

Grafana Firing
 -> PagerDuty
 -> Discord
 -> Self-Healing
```

## Frase principal

> "O objetivo é construir uma cadeia que começa na geração da telemetria e termina, se necessário, numa ação corretiva."

---

# 7. OpenTelemetry

## Falar

> "OpenTelemetry não é um banco de métricas ou logs.
>
> OTel é o padrão utilizado para instrumentar as aplicações e transportar a telemetria."

> "A vantagem é reduzir acoplamento. Os serviços produzem telemetria padronizada e o Collector decide para qual backend enviar cada sinal."

---

# 8. Collector

## Falar

> "O Collector é o gateway central.
>
> Logs seguem para Loki.
>
> Traces seguem para New Relic.
>
> E esses mesmos traces também alimentam Span Metrics para gerar métricas no Prometheus."

Ponto de domínio:

> "Se futuramente eu decidir trocar o backend de APM, boa parte da mudança pode ficar concentrada no Collector."

---

# 9. OTel Agent e DaemonSet

## Falar

> "Logs possuem uma característica diferente. Eles existem fisicamente nos Nodes Kubernetes.
>
> Por isso foi utilizado um OTel Agent em DaemonSet."

Explique:

> "DaemonSet garante uma instância do Agent em cada Node."

Mostrar:

```text
Node A -> Agent
Node B -> Agent
Node C -> Agent
```

> "Cada Agent lê `/var/log/pods`, adiciona atributos Kubernetes e envia os registros ao Collector central."

---

# 10. Prometheus e Span Metrics

## Falar

> "Prometheus recebe as métricas de infraestrutura e também métricas da aplicação."

> "Para request rate e latência, utilizei Span Metrics."

Explicar:

> "Em vez de criar uma segunda instrumentação completamente separada para métricas, os spans usados no tracing são convertidos em contadores e histogramas."

Query:

```promql
sum by (service_name) (
  rate(traces_span_metrics_calls_total[5m])
)
```

Explicar:

> "Essa query calcula a taxa de crescimento do contador numa janela de cinco minutos e agrupa pelo nome do serviço."

---

# 11. Loki

## Falar

> "Loki centraliza os logs que antes estariam distribuídos em vários pods."

> "Como o OTel adiciona metadados Kubernetes, eu consigo pesquisar por namespace, pod, container ou serviço."

---

# 12. Grafana

## Falar

> "Grafana concentra a visualização da stack Open Source."

Dashboard:

```text
ToggleMaster Observability
```

Explicar rapidamente:

### Running Pods

> "Quantidade de pods ativos."

### CPU

> "Pressão computacional."

### Memory

> "Pressão de memória."

### Request Rate

> "Volume de chamadas por microsserviço."

### P95

> "Latência de cauda."

### Live Logs

> "Logs centralizados pelo Loki."

---

# 13. Explicar P95

## Falar

> "P95 é mais interessante do que apenas a média em muitos cenários.
>
> Aproximadamente 95% das observações ficam abaixo daquele valor.
>
> Isso ajuda a encontrar requisições lentas que poderiam ficar mascaradas pela média."

---

# 14. Instrumentação e tracing

## Falar

> "Os microsserviços foram instrumentados com OpenTelemetry.
>
> Uma requisição recebida cria um Span e o contexto é propagado para as dependências."

---

# 15. Trace x Span

## Falar

> "Trace e Span não são a mesma coisa."

```text
Trace = operação completa
Span  = uma etapa
```

Exemplo:

```text
Trace
 ├── Evaluation
 ├── Evaluation -> Flag
 ├── Flag
 ├── Flag -> Auth
 ├── Evaluation -> Targeting
 └── Targeting
```

---

# 16. New Relic

## Falar

> "New Relic foi escolhido como APM porque possui integração com OpenTelemetry/OTLP e oferece Distributed Tracing e Service Map."

---

# 17. Trace x Service Map

## Falar

> "Distributed Trace mostra uma execução específica."

> "Service Map apresenta uma visão agregada das dependências observadas."

Na demonstração:

```text
Auth
Flag
Targeting
Evaluation
Analytics
```

precisam aparecer no mapa.

---

# 18. Analytics

## Falar

> "Analytics possui um fluxo diferente porque trabalha de forma assíncrona."

```text
Evaluation
 -> SQS
 -> Analytics
 -> DynamoDB
```

> "A vantagem é não adicionar o tempo de processamento analítico ao tempo de resposta da avaliação."

---

# 19. Alerting

## Falar

> "A próxima evolução é deixar de depender de alguém olhando o dashboard."

Fluxo:

```text
Normal
 ↓
Pending
 ↓
Firing
```

### Explicar Pending

> "Pending evita reagir imediatamente a um pico transitório. A condição precisa continuar verdadeira durante um período definido."

---

# 20. PagerDuty

## Falar

> "Em Firing, um Contact Point envia o evento ao PagerDuty."

> "O PagerDuty transforma o alerta técnico em um incidente operacional rastreável."

---

# 21. Discord

## Falar

> "Outro receiver envia a mesma condição ao Discord para ChatOps."

> "Isso aproxima a informação do canal acompanhado pela equipe."

---

# 22. Self-Healing

## Falar

> "A terceira saída é o Self-Healing."

> "O serviço foi desenvolvido em Python/Flask e roda dentro do cluster Kubernetes."

> "Ele utiliza uma ServiceAccount e RBAC de privilégio mínimo."

Ação:

```text
Webhook
 ↓
Self-Healing
 ↓
Kubernetes API
 ↓
Patch Deployment
 ↓
Novo ReplicaSet
 ↓
Novo Pod
```

---

# 23. RBAC

## Falar

> "A automação não recebe acesso administrativo ao cluster."

> "O RBAC limita as operações que o ServiceAccount pode realizar."

Isso mostra preocupação com segurança operacional.

---

# 24. Cooldown

## Falar

> "Durante os testes identifiquei um restart storm."

> "Como a condição permanecia Firing, múltiplas notificações provocavam vários restarts."

Correção:

```text
Cooldown = 600 segundos
```

> "O primeiro evento executa o healing. Eventos seguintes dentro da janela são ignorados."

Frase importante:

> "Self-Healing é mitigação inicial, não substitui causa raiz."

---

# 25. Resumo antes da prática

Falar pausadamente:

> "Resumindo a arquitetura da Fase 4:
>
> os microsserviços produzem telemetria com OpenTelemetry;
>
> Agents coletam logs em cada Node;
>
> o Collector central processa e roteia os sinais;
>
> Loki centraliza logs;
>
> Prometheus armazena métricas;
>
> New Relic fornece tracing e mapa de dependências;
>
> Grafana centraliza visualização e alerting;
>
> e em uma condição crítica PagerDuty, Discord e Self-Healing são acionados automaticamente."

Transição:

> "Agora vou reconstruir rapidamente a base AWS necessária e demonstrar essa arquitetura funcionando."

---

# PARTE 2
# PREPARAÇÃO OPERACIONAL ANTES DE GRAVAR

Esta parte deve estar pronta **antes de iniciar a demonstração prática**.

---

# 26. Terminais recomendados

Usar terminais separados.

```text
Terminal 1 -> INFRA_APPS / Terraform / AWS
Terminal 2 -> GITOPS / kubectl
Terminal 3 -> ArgoCD port-forward
Terminal 4 -> Grafana port-forward
Terminal 5 -> Loki ou Prometheus, quando necessário
Terminal 6 -> Self-Healing logs
Terminal 7 -> Pod Watch
```

Não tente reutilizar o mesmo terminal durante a Prova Real.

---

# 27. Terminal 1: INFRA_APPS

Abrir:

```bash
cd ~/TC_Fase4_Infra_Apps
```

Validar:

```bash
git status
```

Depois:

```bash
cd ~/TC_Fase4_Infra_Apps/01-terraform
```

Quando AWS Academy estiver ativo, carregar as credenciais temporárias sem exibi-las no vídeo.

Confirmar:

```bash
aws sts get-caller-identity
```

---

# 28. Terraform

Executar:

```bash
terraform init
```

```bash
terraform fmt -check -recursive
```

```bash
terraform validate
```

```bash
terraform plan \
  -var-file="environments/academy/academy.tfvars"
```

Depois de revisar:

```bash
terraform apply \
  -var-file="environments/academy/academy.tfvars"
```

Se o `apply` demorar muito durante a gravação:

1. mostrar início;
2. pausar/cortar a espera;
3. retomar mostrando resultado.

---

# 29. Kubeconfig EKS

Depois da criação:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name togglemaster-academy
```

Confirmar:

```bash
kubectl get nodes
```

---

# 30. Terminal 2: GITOPS

```bash
cd ~/TC_Fase4_GitOps
```

Executar antes da demonstração:

```bash
git status
```

```bash
kubectl config current-context
```

```bash
kubectl get nodes
```

```bash
kubectl get pods -A
```

---

# 31. Validar microsserviços

```bash
kubectl get pods -A \
  | grep -E "auth|flag|targeting|evaluation|analytics"
```

Precisamos ver os cinco workloads funcionando.

---

# 32. Validar observabilidade

```bash
kubectl get pods -n monitoring
```

Esperado:

```text
Grafana
Loki
Prometheus
OTel Collector
OTel Agent
Self-Healing
```

---

# 33. Validar ArgoCD

```bash
kubectl get applications -n argocd
```

Objetivo:

```text
Synced
Healthy
```

---

# 34. Terminal 3: ArgoCD

Deixar aberto:

```bash
kubectl port-forward \
  svc/argocd-server \
  -n argocd \
  8080:443
```

Navegador:

```text
https://localhost:8080
```

Não fechar o terminal durante a demonstração.

---

# 35. Terminal 4: Grafana

Deixar aberto:

```bash
kubectl port-forward \
  svc/grafana \
  -n monitoring \
  3000:80
```

Navegador:

```text
http://localhost:3000
```

Abrir previamente:

```text
Dashboards
 -> ToggleMaster Observability
```

---

# 36. Terminal 5: Loki, se necessário

```bash
kubectl port-forward \
  svc/loki \
  -n monitoring \
  3100:3100
```

Teste:

```bash
curl -s \
  http://localhost:3100/loki/api/v1/labels
```

Query para Grafana:

```logql
{k8s_namespace_name=~"auth|flag|targeting|evaluation|analytics"}
```

---

# 37. Prometheus, se quiser demonstrar query diretamente

```bash
kubectl port-forward \
  svc/prometheus-kube-prometheus-prometheus \
  -n monitoring \
  9090:9090
```

Abrir:

```text
http://localhost:9090
```

Query:

```promql
sum by (service_name) (
  rate(traces_span_metrics_calls_total[5m])
)
```

---

# 38. Abrir ferramentas externas antes da Prova Real

Deixar abertas abas separadas:

### New Relic

Abrir:

```text
APM / Services
Traces
Service Map
```

### PagerDuty

Abrir página de:

```text
Incidents
```

### Discord

Abrir:

```text
#togglemaster-alerts
```

### Grafana

Abrir:

```text
Alerting
 -> Alert rules
```

---

# 39. Terminal 6: Self-Healing

Deixar rodando antes de provocar o problema:

```bash
kubectl logs -n monitoring \
  deployment/togglemaster-self-healing \
  -f
```

Esse terminal deve permanecer limpo.

Não executar outros comandos nele durante a prova.

---

# 40. Terminal 7: Pod Watch

Para o workload escolhido como alvo do Self-Healing.

Exemplo Evaluation:

```bash
kubectl get pods -n evaluation -w
```

Se a label estiver configurada:

```bash
kubectl get pods -n evaluation \
  -l app=evaluation \
  -w
```

Precisamos conseguir mostrar claramente:

```text
pod antigo -> Terminating
pod novo   -> Running
```

---

# 41. Validar RBAC antes de gravar

Antes da gravação final:

```bash
kubectl auth can-i patch \
  deployment/evaluation-deployment \
  -n evaluation \
  --as=system:serviceaccount:monitoring:togglemaster-self-healing
```

Esperado:

```text
yes
```

Se retornar `no`, não iniciar a Prova Real.

---

# 42. Gerar requisição para tracing

Utilizar endpoint real do Evaluation:

```bash
curl -i \
  "<ENDPOINT-EVALUATION>/evaluate?user_id=video-demo&flag_name=<FLAG-DEMO>"
```

Esperado:

```text
HTTP 200
```

Depois acessar New Relic e localizar trace recente.

---

# 43. Gerar tráfego para o dashboard

Se necessário:

```bash
for i in $(seq 1 20); do
  curl -s \
    "<ENDPOINT-EVALUATION>/evaluate?user_id=video-$i&flag_name=<FLAG-DEMO>" \
    > /dev/null

  sleep 1
done
```

Isso ajuda a criar atividade visível em Request Rate e tracing.

---

# PARTE 3
# ORDEM DA DEMONSTRAÇÃO PRÁTICA

---

# 44. AWS Academy

Mostrar rapidamente:

```bash
aws sts get-caller-identity
```

Sem mostrar chaves.

Mostrar Terraform:

```text
init
validate
plan
apply
```

Depois mostrar recursos prontos.

Não gastar vários minutos no Console AWS.

---

# 45. EKS

```bash
kubectl get nodes
```

Falar:

> "A base necessária foi reconstruída e agora o foco passa para a stack da Fase 4."

---

# 46. ArgoCD

Mostrar:

```text
Auth
Flag
Targeting
Evaluation
Analytics
Prometheus
Loki
Grafana
OTel Collector
OTel Agent
Self-Healing
```

Mostrar estados:

```text
Synced
Healthy
```

---

# 47. Grafana

Abrir:

```text
ToggleMaster Observability
```

Explicar rapidamente os seis painéis.

Fala:

> "Aqui consigo correlacionar saúde do cluster, comportamento dos microsserviços e logs."

---

# 48. Loki

Abrir painel de logs ou Explore.

Mostrar logs reais.

Fala:

> "Esses registros saíram dos pods, foram coletados pelos Agents, passaram pelo Collector e foram centralizados no Loki."

---

# 49. OTel

Mostrar rapidamente no GitOps/ArgoCD:

```text
otel-agent
otel-collector
```

Fala:

> "Agents realizam a coleta distribuída e o Collector concentra processamento e roteamento."

Não gastar muito tempo lendo YAML.

---

# 50. New Relic

Mostrar primeiro:

```text
Service Map
```

Cinco serviços.

Depois executar chamada ao Evaluation.

Abrir trace.

Falar:

> "Agora saio da topologia agregada para analisar uma execução específica."

Mostrar:

- Trace ID;
- Spans;
- serviços;
- duração;
- relações pai/filho.

---

# 51. Preparar a Prova Real

Antes de provocar a falha:

### Tela 1

Grafana Alert Rules.

### Tela 2

PagerDuty Incidents.

### Tela 3

Discord.

### Terminal

Self-Healing logs.

### Terminal

Pod Watch.

Não provocar a falha antes de tudo estar visível.

---

# 52. Provocar o problema

Usar apenas mecanismo já testado anteriormente.

Objetivo:

```text
Normal
  ↓
Pending
  ↓
Firing
```

---

# 53. Mostrar Grafana Firing

Fala:

> "A condição permaneceu acima do limite configurado e a regra chegou a Firing."

---

# 54. Mostrar PagerDuty

Fala:

> "O mesmo evento abriu automaticamente um incidente no PagerDuty."

---

# 55. Mostrar Discord

Fala:

> "Em paralelo, o alerta foi encaminhado ao canal ChatOps."

---

# 56. Mostrar Self-Healing

No terminal:

```text
SELF-HEALING triggered
```

Falar:

> "O terceiro receiver acionou a automação de Self-Healing."

---

# 57. Mostrar restart

Terminal Pod Watch:

```text
old pod -> Terminating
new pod -> Running
```

Falar:

> "A recuperação ocorreu sem executar manualmente kubectl rollout restart."

---

# 58. Mostrar cooldown

Se o Grafana repetir a notificação:

```text
SELF-HEALING ignored: cooldown active
```

Falar:

> "Notificações adicionais não geram novos restarts durante a janela de proteção."

---

# 59. Encerramento

Falar:

> "Com isso, a Fase 4 acrescenta ao ToggleMaster uma camada completa de Observabilidade Total e Resposta Ativa.
>
> OpenTelemetry padroniza e centraliza a telemetria, Prometheus e Loki fornecem métricas e logs, Grafana oferece visualização e Alerting, New Relic fornece APM e tracing distribuído e PagerDuty, Discord e Self-Healing fecham o ciclo de resposta operacional.
>
> O resultado é uma plataforma com maior visibilidade, diagnóstico mais rápido e uma primeira capacidade automatizada de mitigação."

---

# 60. Checklist final

Não finalizar a gravação sem mostrar:

- [ ] Contexto Fase 3 em menos de 1 minuto
- [ ] Arquitetura Fase 4
- [ ] Amazon EKS
- [ ] ArgoCD
- [ ] Prometheus
- [ ] Grafana Dashboard
- [ ] Loki
- [ ] Logs reais
- [ ] OTel Agent
- [ ] OTel Collector
- [ ] New Relic
- [ ] Service Map 5/5
- [ ] Chamada Evaluation
- [ ] Distributed Trace
- [ ] Firing
- [ ] PagerDuty Incident
- [ ] Discord
- [ ] SELF-HEALING triggered
- [ ] Pod reiniciando
- [ ] Novo Pod Running
- [ ] Cooldown explicado

---

# 61. Não mostrar durante o vídeo

Nunca mostrar valores de:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
db_password
NEW_RELIC_LICENSE_KEY
PD_ROUTING_KEY
DISCORD_WEBHOOK_URL
```

Não executar na gravação:

```bash
kubectl get secret ... -o yaml
```

Não abrir:

```text
academy.tfvars
```

se o arquivo contiver senha.

---

# 62. Se algum port-forward cair

## Grafana

```bash
kubectl port-forward \
  svc/grafana \
  -n monitoring \
  3000:80
```

## ArgoCD

```bash
kubectl port-forward \
  svc/argocd-server \
  -n argocd \
  8080:443
```

## Loki

```bash
kubectl port-forward \
  svc/loki \
  -n monitoring \
  3100:3100
```

---

# 63. Se algo falhar durante a gravação

Não transformar o vídeo em troubleshooting.

Procedimento:

```text
Parar gravação
   ↓
Corrigir
   ↓
Validar
   ↓
Retomar do checkpoint
```

---

# 64. Frases úteis para demonstrar conhecimento

1. **OpenTelemetry padroniza telemetria, mas não é um backend de armazenamento.**
2. **Collector e Agent possuem funções diferentes.**
3. **DaemonSet garante coleta de logs em cada Node.**
4. **Trace representa a operação completa e Span representa uma etapa.**
5. **Service Map é agregado e Distributed Trace representa uma execução.**
6. **Span Metrics reutiliza tracing para produzir métricas.**
7. **P95 mostra melhor a cauda de latência do que uma média simples.**
8. **Pending evita reação a picos passageiros.**
9. **PagerDuty transforma o alerta técnico em incidente operacional.**
10. **ChatOps leva a condição para o canal do time.**
11. **RBAC limita a superfície de ação do Self-Healing.**
12. **Cooldown reduz o risco de restart storm.**
13. **Self-Healing é mitigação inicial, não substitui causa raiz.**
14. **GitOps impede que dashboard e Alerting dependam de configuração manual efêmera.**