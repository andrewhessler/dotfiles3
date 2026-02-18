---
name: jira
description: Interact with Jira using the Atlassian CLI (acli). Use when the user wants to view, create, edit, search, comment on, or transition Jira work items. Also supports browsing sprints, boards, and projects. Trigger on Jira ticket keys (e.g. ME-12345), Jira URLs, or any request about work items, stories, bugs, tasks, or sprints.
---

# Jira (Atlassian CLI)

Interact with Jira Cloud via the `acli` CLI tool installed at `/opt/homebrew/bin/acli`.

## Prerequisites

Must be authenticated. Check with:
```bash
acli auth status
```

If not authenticated:
```bash
acli auth login
```

## Work Items

### View a work item

```bash
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --json
acli jira workitem view KEY-123 --fields summary,status,description,comment
acli jira workitem view KEY-123 --fields '*all' --json
acli jira workitem view KEY-123 --web   # open in browser
```

Default fields: `key, issuetype, summary, status, assignee, description`

### Search work items (JQL)

```bash
acli jira workitem search --jql "project = ME" --limit 10
acli jira workitem search --jql "project = ME AND assignee = currentUser() AND status = 'In Progress'" --json
acli jira workitem search --jql "project = ME AND sprint in openSprints()" --fields "key,summary,status,assignee" --limit 50
acli jira workitem search --jql "project = ME" --count   # just the count
acli jira workitem search --jql "project = ME" --csv      # CSV output
acli jira workitem search --jql "project = ME" --paginate  # fetch all pages
acli jira workitem search --filter 10001                   # use a saved filter
```

### Create a work item

```bash
acli jira workitem create --project "ME" --type "Story" --summary "Title here" --description "Details" --assignee "@me"
acli jira workitem create --project "ME" --type "Task" --summary "Subtask" --parent KEY-123
acli jira workitem create --project "ME" --type "Bug" --summary "Bug title" --label "bug,cli" --assignee "user@example.com"
acli jira workitem create --from-json workitem.json   # from JSON file
acli jira workitem create --generate-json             # generate example JSON structure
```

Flags: `--project`, `--type` (Epic/Story/Task/Bug), `--summary`, `--description`, `--description-file`, `--assignee`, `--label`, `--parent`, `--json`

### Edit a work item

```bash
acli jira workitem edit --key KEY-123 --summary "New title"
acli jira workitem edit --key KEY-123 --description "Updated description"
acli jira workitem edit --key KEY-123 --assignee "user@example.com"
acli jira workitem edit --key KEY-123 --assignee "@me"
acli jira workitem edit --key "KEY-1,KEY-2" --labels "label1,label2"   # bulk edit
acli jira workitem edit --jql "project = ME AND status = 'To Do'" --assignee "@me" --yes  # bulk via JQL
```

### Transition (change status)

```bash
acli jira workitem transition --key KEY-123 --status "In Progress"
acli jira workitem transition --key KEY-123 --status "Done"
acli jira workitem transition --key "KEY-1,KEY-2" --status "To Do"  # bulk
acli jira workitem transition --jql "project = ME AND assignee = currentUser()" --status "Done" --yes
```

### Assign

```bash
acli jira workitem assign --key KEY-123 --assignee "@me"
acli jira workitem assign --key KEY-123 --assignee "user@example.com"
acli jira workitem assign --key KEY-123 --remove-assignee
```

### Delete

```bash
acli jira workitem delete --key KEY-123 --yes
acli jira workitem delete --key "KEY-1,KEY-2" --yes
```

Always use `--yes` to skip interactive prompts.

## Comments

### List comments

```bash
acli jira workitem comment list --key KEY-123
acli jira workitem comment list --key KEY-123 --json
acli jira workitem comment list --key KEY-123 --limit 10
```

### Add a comment

```bash
acli jira workitem comment create --key KEY-123 --body "This is a comment"
acli jira workitem comment create --key KEY-123 --body-file comment.txt
```

### Update last comment

```bash
acli jira workitem comment create --key KEY-123 --body "Updated text" --edit-last
```

### Delete a comment

```bash
acli jira workitem comment delete --key KEY-123 --comment-id 12345
```

## Links

### List links

```bash
acli jira workitem link list --key KEY-123
acli jira workitem link list --key KEY-123 --json
```

### Create a link

```bash
acli jira workitem link create --out KEY-123 --in KEY-456 --type "Blocks"
acli jira workitem link create --out KEY-123 --in KEY-456 --type "is blocked by"
```

### Get available link types

```bash
acli jira workitem link type
acli jira workitem link type --json
```

## Sprints

### List sprints on a board

```bash
acli jira board list-sprints --id BOARD_ID
acli jira board list-sprints --id BOARD_ID --state active
acli jira board list-sprints --id BOARD_ID --state active,closed --json
```

### View sprint details

```bash
acli jira sprint view --id SPRINT_ID --board BOARD_ID
```

### List work items in a sprint

```bash
acli jira sprint list-workitems --sprint SPRINT_ID --board BOARD_ID
acli jira sprint list-workitems --sprint SPRINT_ID --board BOARD_ID --json
acli jira sprint list-workitems --sprint SPRINT_ID --board BOARD_ID --fields "key,summary,status,assignee"
acli jira sprint list-workitems --sprint SPRINT_ID --board BOARD_ID --paginate  # all items
```

## Projects

```bash
acli jira project list                    # list projects
acli jira project list --recent           # recently viewed (up to 20)
acli jira project list --json
acli jira project view --key ME           # view project details
acli jira project view --key ME --json
```

## Boards

```bash
acli jira board search                    # list all boards
acli jira board get --id BOARD_ID         # board details
acli jira board list-projects --id BOARD_ID  # projects on a board
```

## Tips

- Always use `--json` when you need to parse output programmatically or extract specific fields.
- Use `--yes` on mutating commands (edit, transition, delete, assign) to skip interactive confirmation prompts.
- Jira URLs like `https://site.atlassian.net/browse/KEY-123` — extract the key (e.g. `KEY-123`) and use it directly.
- Use `--paginate` on search/list commands when you need all results, not just the first page.
- JQL reference: `assignee = currentUser()`, `sprint in openSprints()`, `status = "In Progress"`, `created >= -7d`, `ORDER BY priority DESC`.
