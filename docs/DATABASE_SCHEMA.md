# Orbit Database Schema

Entities:

Workspace

* id
* name
* description
* createdAt
* updatedAt

WorkspaceMember

* id
* workspaceId
* userId
* role
* createdAt

Project

* id
* workspaceId
* name
* description
* color
* createdAt
* updatedAt

Milestone

* id
* projectId
* name
* description
* dueDate
* createdAt
* updatedAt

Task

* id
* milestoneId
* parentTaskId (nullable for nested subtasks)
* title
* description
* assigneeId
* priority
* status
* startDate
* dueDate
* createdAt
* updatedAt

User

* id
* name
* email
* avatarUrl
* createdAt

Relationships:
Workspace → Projects
Project → Milestones
Milestone → Tasks
Task → Subtasks (self relation)

Task nesting is recursive using parentTaskId.
