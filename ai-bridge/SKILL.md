# LN AI Bridge — Claude Code Skill

> Package: `livenetworks/ln-ai-bridge`
> Namespace: `LiveNetworks\LnAiBridge`
> PHP 8.3+ | Laravel 11+/12+ | Guzzle 7.8+ (no external AI SDKs)

## What this is

Unified AI provider abstraction for Laravel apps. Dumb pipe — sends requests to AI providers (Claude, OpenAI, custom), manages conversation history, summarization, and usage tracking. Does NOT contain business logic.

## Architecture
```
App Controller
  → App Models (gather context)
  → App SystemPromptBuilder (compose system prompt)
  → AiBridge::prompt()          ← bridge starts here
    → PromptBuilder (enrich with context, history)
    → AiBridgeManager (resolve provider, delegate)
    → Provider (Claude/OpenAI/custom)
    → External AI API
  → AiResponse                  ← bridge ends here
  → UsageTracker (log tokens per tenant)
```

Context enrichment happens in the APP CONTROLLER, never in the bridge.

## Key classes

| Class | Location | Role |
|---|---|---|
| `AiBridgeManager` | `src/` | Singleton orchestrator. `prompt()`, `send()`, `register()` |
| `PromptBuilder` | `src/` | Fluent builder: `.prompt()`, `.system()`, `.context()`, `.history()`, `.temperature()`, `.maxTokens()`, `.meta()`, `.build()` |
| `AiRequest` | `src/DTO/` | Readonly: prompt, system, context[], history[], temperature, maxTokens, meta[] |
| `AiResponse` | `src/DTO/` | Readonly: content, provider, model, success, error, stopReason, usage[], raw[]. Static `ok()` / `fail()`. Method `totalTokens()` |
| `Message` | `src/DTO/` | Readonly: role, content. Static `user()` / `assistant()` |
| `AiProviderInterface` | `src/Contracts/` | Contract: `send(AiRequest): AiResponse`, `name()`, `model()` |
| `AbstractProvider` | `src/Providers/` | Base HTTP logic. Subclasses: `buildHeaders()`, `buildPayload()`, `parseResponse()` |
| `ClaudeProvider` | `src/Providers/` | Anthropic Messages API |
| `OpenAiProvider` | `src/Providers/` | OpenAI Chat Completions API |
| `ConversationManager` | `src/Services/` | `startConversation()`, `sendMessage()`, `getHistory()` |
| `SummarizationService` | `src/Services/` | `shouldSummarize()`, `summarize()` — uses AI to summarize old messages |
| `UsageTracker` | `src/Services/` | `log()`, `getTenantUsage()`, `getUserUsage()` |

## Database tables (publishable migrations)

| Table | Purpose | Key columns |
|---|---|---|
| `ai_conversations` | Conversation sessions | uuid PK, tenant_id (nullable, billing only), user_id, context_type, context_id, provider, model, system_prompt, status, message_count, total_tokens |
| `ai_messages` | Individual messages | uuid PK, conversation_id FK, role, content, tokens, is_summarized |
| `ai_conversation_summaries` | Summarized older messages | uuid PK, conversation_id FK, summary, messages_from, messages_until, messages_count, tokens_saved |
| `ai_usage_log` | Token consumption tracking | auto PK, tenant_id, user_id, provider, model, input_tokens, output_tokens, conversation_id |

## Usage patterns

### Single request (no history)
```php
use LiveNetworks\LnAiBridge\Facades\AiBridge;

$request = AiBridge::prompt('Generate an ISO 27001 scope statement')
    ->system('You are an ISO documentation assistant.')
    ->context('organization', $org->toArray())
    ->context('existing_docs', $docs->pluck('title'))
    ->temperature(0.3)
    ->build();

$response = AiBridge::send($request);
```

### Multi-turn conversation
```php
$cm = app(ConversationManager::class);

// Start
$conv = $cm->startConversation(
    tenantId: $tenant->id,
    userId: auth()->id(),
    systemPrompt: $systemPrompt,
    contextType: 'document',
    contextId: $document->id,
);

// Send (auto-saves history, tracks tokens, triggers summarization)
$response = $cm->sendMessage($conv, $userMessage);
```

### Custom provider
```php
// In AppServiceProvider::boot()
AiBridge::register('mistral', MistralProvider::class);

// Use it
$response = AiBridge::send($request, 'mistral');
```

## Context enrichment via XML tags

`PromptBuilder->context(key, value)` wraps data as:
```xml
<context key="document">
{"title":"ISO 27001 Policy","sections":["scope","controls"]}
</context>

User prompt goes here after all context blocks.
```

## Summarization flow

1. After each `sendMessage()`, checks unsummarized count > threshold (default 20)
2. Takes old messages (keeps last 6 fresh)
3. Sends them to AI with "summarize this conversation" prompt
4. Stores summary in `ai_conversation_summaries`
5. Marks old messages as `is_summarized = true`
6. Next request gets: summary + last 6 messages (instead of all 50+)

## Config (config/ai-bridge.php)
```php
'default' => env('AI_PROVIDER', 'claude'),
'providers' => [
    'claude' => ['driver' => 'claude', 'api_key' => env('...'), 'model' => '...'],
    'openai' => ['driver' => 'openai', 'api_key' => env('...'), 'model' => '...'],
],
'conversation' => [
    'summarize_threshold' => 20,  // after how many unsummarized messages
    'keep_recent' => 6,           // how many to keep fresh
    'summary_max_tokens' => 500,
],
'usage' => [
    'tracking_enabled' => true,
],
```

## Rules for Claude Code

- NEVER put business logic in the bridge (no ISO knowledge, no document types, no tenant scoping)
- NEVER access app models from bridge code
- Context flows ONE direction: App → Bridge → Provider
- AiRequest and AiResponse are immutable (readonly)
- Provider instances are cached (singleton per driver name)
- All provider API errors are caught and returned as AiResponse::fail()
- tenant_id in bridge is ONLY for billing/tracking, never for filtering
- Summarization is an AI call — it uses AiBridgeManager internally
- Messages are immutable (no updated_at, only created_at)
- Usage log is append-only

## App integration pattern

The consuming app (DocuFlow, AuditBase) is responsible for:
- SystemPromptBuilder (composing multi-layer system prompts)
- Tenant scoping (global scope on bridge models)
- Adding tenant_id column if not present (own migration)
- AiController with business logic
- Extending bridge models with BelongsToTenant or similar traits
- ISO/domain-specific context gathering from app models