# 21 September 2026 Meeting Follow-up: In-house Work and Performance

This record combines the Gemini meeting notes with the transcript. Transcript timestamps are included so that product intent can be checked against the source. The checked-in `openapi_schema.json` is the API capability source used for the contract observations below.

## Verified frontend/API capabilities

| Area | Current contract evidence | Frontend implication |
| --- | --- | --- |
| Employee tasks | `/api/v1/my-tasks`, `/api/v1/my-tasks/{task_id}/status`; operations task listing exposes `assigned_to` and `milestone_id`. | Keep the employee task flow on these APIs. The OpenAPI contract does not promise an assignment-email side effect, so verify delivery at runtime before claiming it. |
| Work reports | `/api/v1/work-reports/` and `/api/v1/work-reports/{report_id}` expose day, hours, operational base, activities, task details, next-day plan, status, attachments, feedback, rating, and reviewer metadata. | Existing report create/edit/view/review flows can use those fields. Do not attach a report to a task, project, or work site: the report schemas have no `task_id`, `project_id`, or `worksite_id`. This is a backend dependency for the meeting's contextual report views (00:02:57–07:14). |
| Projects and work sites | `/api/v1/worksites` accepts a required `project_id`; its response also requires `project_id`. | The current contract does not support standalone work sites, despite the meeting describing both standalone and project-attached sites (00:01:04–01:29, 06:33–07:14). Do not simulate standalone sites in Flutter. |
| Task hierarchy | Task schemas expose optional `milestone_id`, `assigned_to`, and a project-filtered list operation. | Project/milestone task views are supported to the extent represented by these fields. A direct task-to-work-site field is not present in `TaskOutSchema`. |
| Attendance locations | Work-location responses include `is_active`, `is_expired`, and `can_be_used`; attendance records include location verification and the used location name. | Use backend eligibility fields for available locations. The published schemas do not define assignment-specific schedules or a project/task-based attendance permission, discussed at 00:32:07–39:29. Those behaviors require contract support before being presented as configurable. |
| Leave | Leave list/create/update/status and employee leave-stat endpoints are present. | Leave data can be displayed and reviewed using the API. The scorecard contract does not specify leave-adjusted denominators or how leave affects performance. |
| Scorecards | Employee scorecard and leaderboard endpoints are present. Score fields are attendance, task delivery, report accuracy, brand contribution, training progress, target score/achievement, overall score, and ranking. | Continue presenting these only as the current backend scorecard. Do not relabel them as the meeting's measures or calculate a replacement formula. |
| Marketing leads | Not audited in the Flutter contract fixture; Marketing is a separate application and API client. | Audit its live lead, assignment, follow-up, and activity endpoints in the Marketing repository before changing that workflow. |

## Transcript-derived product direction

- Build for in-house staff first (00:12:58, 00:32:07).
- Tasks, sprints, milestones, projects, work sites, and reports should have navigable context; the exact relationships must be supported by backend fields (00:00:00–07:14).
- Site clock-in should be an HR-controlled exception to branch-default attendance, informed by an employee's assignment and the work location (00:32:07–39:29).
- Performance discussion mentions punctuality, clocking quality, targets, KPI compliance, report quality, and colleague ratings, but the transcript does not settle the exact five measures, weights, or scoring criteria/formula (00:14:19–00:24:25, 00:29:21–31:29).
- Project/site expenses and budgets were discussed, but no frontend should report finance actuals without a supported data source (00:08:09–09:56).
- Specialized engineering/surveying forms depend on a template the CEO offered to provide (00:10:33–12:27).
- The final request to remove permissions/delete data does not identify the data, permission, or target list. **No data deletion or permission change is authorized by this record** (01:03:20).

## Safe next implementation steps

1. Keep the current API-backed employee task and work-report flows; test loading, empty, permission, retry, edit, and refresh behavior without live mutations.
2. Add report/project/site context only after the backend publishes association fields and corresponding endpoints.
3. Validate location eligibility and branch-default attendance behavior using current location APIs; treat assignment schedules/site-specific permissions as unsupported until contracted.
4. Improve performance screens only using the existing scorecard fields. Request product confirmation of the proposed criteria and formula before changing rankings or calculations.
5. Audit Marketing lead workflow separately. Defer rewards, penalties, data deletion, and unsupported specialized templates pending explicit rules or source material.

## Contract regression guard

`test/contracts/meeting_followup_capability_test.dart` checks the local OpenAPI fixture for the supported task/report/leave/scorecard paths and the missing report associations. If the published contract changes, update this capability record and add focused service/model tests before exposing the new behavior.
