# Code of Conduct

Code of Conduct on working on this project.

## Workflow

Use the GitHub Project to see what cards are available.

Strive to make the app look like the mock up as close as possible!
Discuss with each other if the mockup is unattainable.

### Adding new cards

To add a new card, simply open the repository (not the project) and create a new issue. An action handles adding the issue to the kanban in the project.

ALWAYS create a new branch for an issue. That way we always know where errors come from.
Strive to test the implementations. (idk exactly how to do dis, but TDD is god u know hehe).

### How the kanban works

In case you haven't used a kanban like this before here is a quick run down:

#### Backlog

Cards / user stories that explain a functionality.
These should be refactored if possible to be "programmatic" tasks when they are ready.

#### Ready

Refactored Backlog tasks. Tasks are moved here when they are able to be done.
This means, there shouldn't be a card in here that is dependant on a card in the Backlog or another card already in the Ready section.

#### In Progress

Tasks that are being worked on obviously hehe.

#### In Review

Tasks that are done, that needs to be reviewed by someone else. Lets strive to not push to main before it has been reviewed by both of us. Sometimes this is not possible if one is absent and doing actual important stuff like playing video games or doing actual school work. Then if the functionality is major, it is okay to just force the push to main.

#### Done

Tasks that have been succesfully completed. If i have done the workflow actions correctly. Tasks that then tasks should automatically be added here whenever they have been pushed to main.

#### Refactoring Backlog Tasks

To refactor a backlog task, simply open the task by clicking the title and create a list of subtasks as a comment. This is done by:

```TEXT
- [ ] Subtask Description
```

All subtasks will be in one comment, so we just edit the same comment.

Subtasks should be smaller programming tasks. All subtasks should fulfill the Backlog Task title.

## Pull Requests

When creating a pull request for a branch to be pulled into main. The Backlog task should be complete. In the event. Write a description when creating the pull request containing one of the following words:
 - close
 - closes
 - closed

This makes the issue automatically close, and also moves the task to the Done part of the kanban board.
