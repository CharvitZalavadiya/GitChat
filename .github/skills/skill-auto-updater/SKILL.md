---
name: skill-auto-updater
description: "Use when code changes introduce, remove, or modify any patterns, tokens, or conventions in the codebase (such as design tokens, architecture, naming, or best practices), to automatically update all relevant skills so their documentation and enforcement rules match the current codebase. Trigger phrases: auto-update skills, sync skills with code, update skill docs, update all skills."
---


# Skill Auto-Updater

## Purpose
Automatically keep all workspace skills in sync with the actual codebase—covering design tokens, architecture, naming conventions, best practices, and any other patterns enforced by skills.

## When to Use
- When new patterns, conventions, or tokens are added, removed, or renamed in the codebase (e.g., design tokens, architecture, naming, folder structure, best practices, etc.).
- When a skill's documentation or enforcement rules become outdated due to code changes of any kind.

## Workflow
1. Detect changes to any codebase patterns, tokens, or conventions (e.g., CSS variables, architecture, folder structure, naming, etc.).
2. Identify all skills that reference or enforce those patterns.
3. Update the relevant skill files to:
   - Add new patterns/tokens/conventions to documentation and enforcement rules.
   - Remove or mark as deprecated any that are no longer present in code.
   - Update examples and templates to match the current codebase.
4. Summarize the changes made to each skill.

## Example Triggers
- New color variable `--accent-bg-main` added to globals.css → Add to brand-color-enforcer skill.
- Font size `--text-xxl` removed → Remove from all skills referencing it.
- New folder structure or architectural pattern introduced → Update codebase-architecture skill.
- Naming convention changed for components → Update all skills referencing naming.
- Token renamed from `--primary-bg-main` to `--brand-primary-bg` → Update all skills accordingly.

## Completion Checklist
- All skills referencing codebase patterns, tokens, or conventions are up to date with the codebase.
- No outdated or missing references in skill documentation or enforcement rules.
- Changes are summarized for review.
