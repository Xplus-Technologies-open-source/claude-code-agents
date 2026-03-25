---
name: ai-code-detection
description: Comprehensive AI code pattern detection catalog, humanization techniques, and git hygiene rules — primary knowledge base for HumanForge agent
---

# AI Code Detection — Knowledge Base

This skill provides the definitive pattern catalog for detecting AI-generated code and transforming it into authentic, human-looking code. It is the primary knowledge source for the HumanForge agent and must be loaded before every analysis.

## Detection Heuristic Scoring

Each file receives an AI confidence score based on pattern hits:

| Score | Confidence | Meaning |
|-------|-----------|---------|
| 0-15 | CLEAN | No significant AI patterns detected |
| 16-35 | LOW | Minor patterns — could be a careful developer |
| 36-60 | MEDIUM | Multiple patterns — likely AI-assisted |
| 61-85 | HIGH | Strong AI fingerprint — most of this was generated |
| 86-100 | OBVIOUS | Unmistakably AI-generated — no human writes like this |

### Scoring Rules

| Pattern Category | Points per Occurrence | Max per File |
|-----------------|----------------------|-------------|
| Obvious comment (restates code) | +3 | 15 |
| Generic variable name | +2 | 10 |
| Unnecessary try/catch | +4 | 12 |
| Over-structured simple function | +3 | 9 |
| Defensive type check in typed code | +5 | 10 |
| JSDoc on trivial function | +2 | 8 |
| Perfect consistent formatting (beyond tooling) | +3 | 6 |
| Generic error message | +3 | 9 |
| Unnecessary abstraction layer | +5 | 10 |
| "Step N:" comments in function | +4 | 8 |
| Constants file for single-use values | +3 | 3 |
| Barrel/index re-export file | +2 | 2 |

## Comment Patterns — Detailed Catalog

### Patterns That Scream "AI Wrote This"

```javascript
// OBVIOUS AI — Delete immediately
// Get the user from the database
const user = await db.users.findById(id);

// Check if the user exists
if (!user) {
  // Return a 404 error
  return res.status(404).json({ error: 'User not found' });
}

// Return the user data
return res.json(user);
```

```javascript
// HUMAN VERSION — The code speaks for itself
const user = await db.users.findById(id);
if (!user) return res.status(404).json({ error: 'User not found' });
return res.json(user);
```

### Comments That Humans Actually Write

```javascript
// HACK: timezone offset breaks during DST — revisit in Q2
// XXX: this silently swallows errors from the payment gateway, fix before launch
// NOTE: order matters here — auth middleware must run before rate limiter
// perf: cached because this query takes 800ms+ on cold start
// @see https://github.com/org/repo/issues/123
```

Humans comment to:
- Warn about non-obvious behavior or gotchas
- Reference external context (tickets, specs, RFCs)
- Mark technical debt with urgency
- Explain WHY, never WHAT

## Naming Patterns — Detailed Catalog

### AI Naming vs Human Naming

| AI Name | Human Name | Why |
|---------|-----------|-----|
| `fetchUserDataFromDatabase` | `getUser` | Humans assume context |
| `processAndValidateInputString` | `parseInput` or `validateInput` | Humans pick one verb |
| `handleButtonClickEvent` | `onSubmit` or `handleClick` | Humans abbreviate |
| `isUserAuthenticatedAndAuthorized` | `canAccess` | Humans use domain shorthand |
| `generateRandomUniqueIdentifier` | `genId` or `uuid` | Humans abbreviate known concepts |
| `applicationConfiguration` | `config` or `cfg` | Humans use common abbreviations |
| `temporaryStorageVariable` | `tmp` or `buf` | Humans don't explain temp vars |
| `errorMessageString` | `errMsg` or `msg` | Humans drop obvious type suffixes |
| `userEmailAddressInput` | `email` | Context makes redundancy obvious |
| `databaseConnectionPool` | `pool` or `db` | Domain context is implicit |

### Variables That Humans Use Naturally

```
req, res, ctx, cfg, opts, args, fn, cb, err, msg, buf, tmp, idx, len, val, ref, el, btn, nav, hdr
```

AI rarely uses these abbreviated forms. It prefers full words because tokens are cheap.

## Structure Patterns — Detailed Catalog

### The "AI Template" Anti-Pattern

AI generates functions that follow an invisible template:

```typescript
// AI PATTERN: Every function looks identical
async function createUser(data: CreateUserDTO): Promise<User> {
  try {
    // Validate the input data
    const validatedData = validateCreateUserData(data);

    // Create the user in the database
    const user = await userRepository.create(validatedData);

    // Log the successful creation
    logger.info(`User created successfully: ${user.id}`);

    // Return the created user
    return user;
  } catch (error) {
    // Log the error
    logger.error('Failed to create user:', error);

    // Re-throw the error
    throw error;
  }
}
```

```typescript
// HUMAN VERSION: Adapts structure to complexity
async function createUser(data: CreateUserDTO) {
  const user = await userRepo.create(validate(data));
  logger.info(`User created: ${user.id}`);
  return user;
}
```

Humans don't wrap three lines in try/catch, don't log AND re-throw, and don't comment every line.

### Over-Engineering Detection

| Signal | AI Score | Example |
|--------|---------|---------|
| Interface + single implementation | +5 | `IUserService` with only `UserService` |
| Factory for one product | +5 | `UserFactory.create()` when `new User()` works |
| Event emitter for two listeners | +4 | Custom event system for parent-child communication |
| Abstract class with one child | +5 | `BaseController` extended by `UserController` only |
| Strategy pattern for two options | +4 | `PaymentStrategy` when it's just card or bank |
| Builder for simple objects | +4 | `UserBuilder.withName().withEmail().build()` for a 3-field object |

## Git Hygiene — Complete Ruleset

### Commit Message Red Flags

```
CRITICAL — Must never appear in public git history:
- "Co-Authored-By: Claude" (any variant)
- "Co-Authored-By: GitHub Copilot"
- "Co-Authored-By: .*[Bb]ot"
- "Co-Authored-By: .*AI"
- "Co-Authored-By: .*Assistant"
- "Co-Authored-By: .*Anthropic"
- "Co-Authored-By: .*OpenAI"
- "Generated by AI/Claude/GPT/Copilot"
- "AI-assisted implementation"
- "Automated by Claude Code"

HIGH — Suspicious, should be reviewed:
- Commit messages that read like changelogs
- Messages starting with "Implement", "Add", "Create" followed by a complete feature description
- Messages longer than 100 characters that sound like documentation
- Perfectly formatted conventional commits from a developer who previously didn't use them
```

### File-Level Red Flags

```
Files that should NEVER be committed:
- .github/copilot/**
- .copilot*
- .cursor/rules
- .aider*
- .continue/**
- .claude/** (agent configs are fine, conversation logs are not)
- Any file with "generated", "ai-output", or "claude" in the name

Code comments that must be cleaned:
- "// Generated by Copilot"
- "// Claude suggestion"
- "// AI-assisted"
- "// ChatGPT"
- "/* Generated with AI assistance */"
- "# Auto-generated by LLM"
```

### PR Description Red Flags

```
Phrases that identify AI-generated PR descriptions:
- "As an AI language model..."
- "I've implemented..." (first-person from non-human perspective)
- "Here's what this PR does:" (overly helpful tone)
- "This implementation provides..." (marketing language)
- Sections with headers like "Changes Made:", "Testing Done:", "Impact Analysis:"
  (when the project doesn't normally use these)
- Bullet points that sound like task completion reports
- Mentions of "best practices" without specific justification
```

## Humanization Techniques

### The 3-Second Rule

A human developer, reading code they didn't write, forms an opinion in 3 seconds:
- Lots of comments → "Over-engineered" or "Written by someone who doesn't trust the reader"
- Generic names → "Rushed" or "Template code"
- Uniform structure → "Generated"
- Short, punchy code → "Experienced developer"
- Opinionated choices → "Someone who knows what they're doing"

Your humanization should pass the 3-second sniff test.

### Humanization Checklist (Per File)

1. Delete every comment that restates the code (90% of AI comments)
2. Shorten all names that are longer than needed in context
3. Remove try/catch that wraps non-throwing code
4. Inline constants used once
5. Collapse simple functions to one-liners where readable
6. Remove type assertions/guards the compiler already handles
7. Vary function structure (not every function needs the same shape)
8. Add one or two genuine comments where behavior is non-obvious
9. Use framework idioms instead of generic patterns
10. Allow minor style inconsistency (real codebases have this)

### Framework-Specific Humanization

**React/Next.js**
```
AI: Every component has PropTypes AND TypeScript AND JSDoc
Human: TypeScript types only — the rest is redundant

AI: useEffect with cleanup for every effect
Human: Cleanup only when there's something to clean up

AI: Separate files for component, styles, types, constants, utils
Human: Colocate until it gets unwieldy
```

**Python/FastAPI**
```
AI: Docstring on every function including __init__
Human: Docstrings on public API, not on internal methods

AI: Type hints on every variable including obvious ones
Human: Type hints on function signatures, let inference handle locals

AI: Custom exception class for every error type
Human: Use built-in exceptions, custom only for domain-specific errors
```

**Go**
```
AI: Comments on every exported function that restate the function name
Human: Godoc comments only when they add information beyond the name

AI: if err != nil { return fmt.Errorf("failed to X: %w", err) } on every call
Human: Wrap errors at boundaries, let trivial ones propagate

AI: Interface defined before the concrete type
Human: Interface defined where it's consumed, not where it's implemented
```

## Continuous Learning

This skill should be updated as AI code patterns evolve. New LLM versions produce different patterns. Track:
- Changes in default AI coding style across model versions
- New AI tools that leave different fingerprints
- Framework-specific patterns that newer AI models get right (remove from detection)
- Community-reported false positives (add to exclusion list)
