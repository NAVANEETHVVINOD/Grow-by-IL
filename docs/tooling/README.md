# Reusable agent tooling

The installable source files live in `tooling/agent-kit`. The two Codex TOML
agents and two Claude Markdown agents are read-only by design. They inherit the
model and available connections; none embeds credentials or adds a network
endpoint. `AGENTS.md` and `CLAUDE.md` are short user-level guidance files.

Use the official [Codex subagent guide](https://developers.openai.com/codex/subagents)
and [Claude subagent guide](https://code.claude.com/docs/en/sub-agents) for the
current file formats. The reviewed agents are installed under
`%USERPROFILE%\.codex\agents` and `%USERPROFILE%\.claude\agents`, with user-level
guidance in each tool's home folder. They can be used from any project after
the tool reloads its configuration.

## Source snapshots

These Git repositories are downloaded under the shared user directory
`%USERPROFILE%\.agent-tool-sources` so other projects can inspect them. They are
reference material, not installed plugins,
active MCP servers, or trusted hooks. Review a selected file and its licence
before copying it into a global tool directory.

| Official source | Pinned commit | Selection | Licence note |
| --- | --- | --- | --- |
| [OpenAI plugins](https://github.com/openai/plugins) | `1dc195897af4161d039b80d8471ec0a10c9bbc89` | GitHub, OpenAI developer, and security plugin references | Check each plugin licence; no repository-wide licence assertion. |
| [Anthropic skills](https://github.com/anthropics/skills) | `34040c9c568585f6929bedeaad110ad08f079624` | MCP builder, skill creator, frontend design, web app testing | Mixed licences; document skills are source-available, not open source. |
| [GitHub MCP server](https://github.com/github/github-mcp-server) | `85598ba6e1256f7ebf4867b95d63b833c4549264` | Source checkout | MIT. |
| [Playwright MCP](https://github.com/microsoft/playwright-mcp) | `e73d72e01f162054a3d0a6b0fe8d4affffb095ee` | Source checkout | Apache-2.0. |

The Apache-2.0 Anthropic `mcp-builder` skill is installed under both user-level
skill folders. The official OpenAI developer-docs MCP endpoint is configured
globally for Codex and Claude; Claude reports it connected. Existing GitHub,
browser, Firebase, and Supabase integrations should be reused before adding an
overlapping MCP process. Local Codex config defined `penpot` and `penpots` for
the same endpoint; `penpot` remains enabled and `penpots` is disabled with a
private config backup beside the original.
Remote MCP tools can read or change live project data, so use account-scoped
authorization and review its permissions. Keep tokens in the tool's credential
store or environment, never in this repository.

Codex [requires explicit trust for changed hook definitions](https://developers.openai.com/codex/hooks),
and Claude [hooks run automatically at lifecycle events](https://code.claude.com/docs/en/hooks-guide).
No general-purpose command hook is bundled here: a hook that runs in every
project needs its own narrowly specified task, local test, and trust review.
