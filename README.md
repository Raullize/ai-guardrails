# AI Guardrails

Repositório centralizado de governança, regras e capacidades para otimização de assistentes de IA (Trae, OpenCode, Cursor). Focado em redução de custo de tokens, consistência arquitetural e eliminação de padrões visuais genéricos de IA.

## Estrutura do Repositório

- rules/: Diretrizes de estilo e restrições de segurança (o "como" escrever).
- skills/: Blocos de instruções especializados em tarefas específicas (ex: gerador de novas skills).
- template/: Modelos base para a criação de novos componentes de IA.

## Configuração e Uso Local

Para utilizar estas configurações em qualquer repositório local sem duplicar arquivos, **sem sujar o repositório e sem alterar o `.gitignore`**, utilize os scripts de automação.

Eles usam um recurso chamado `.git/info/exclude`, que ignora os arquivos das regras apenas na sua máquina local.

### Para ativar as regras em um projeto:
Vá até a pasta do projeto que você quer configurar e rode:
```bash
~/Projects/ai-guardrails/scripts/apply.sh
```
Isso criará um link simbólico invisível para o Git.

### Para desativar as regras:
Se quiser remover as configurações de IA do projeto:
```bash
~/Projects/ai-guardrails/scripts/remove.sh
```

## Diretrizes de Desempenho e Custo

1. Respostas Diretas: Toda instrução deve forçar a IA a omitir saudações e explicações redundantes, economizando tokens de saída.
2. Isolamento de Contexto: Ao criar links simbólicos apenas para as regras necessárias da stack do projeto atual, evita-se o envio de contextos massivos e irrelevantes para a API.