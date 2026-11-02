# QA User and Role Catalog

This catalog describes the test identities that can be created by the local backend seed commands. It is not a snapshot of every account currently in a shared database: accounts are mutable, and the database stores password hashes rather than recoverable passwords. Use the live account listing procedure below when a test needs to find another existing identity.

## Safety and scope

- Use these accounts only after verifying the backend runtime and database are non-production. The user has authorized creating, changing, resetting, and deleting synthetic QA users and data in that test database without asking for each action.
- Do not use a listed test password on any external service. Do not copy passwords, password hashes, session tokens, OTPs, or private user details into screenshots, reports, or unrelated documentation.
- The full-access seed is deliberately privileged. Use the least-privileged scenario that can verify the requested behavior.
- Before running any seed command, inspect its source and safety guard, verify the active database target, and record the command and affected fixture IDs in the test notes.

## Known seeded identities

### Existing local database snapshot — 2026-10-23

The verified local development SQLite database contained **59 user accounts** when this catalog was checked: 2 administrator accounts, 2 QA employee accounts, 19 local staff-scenario accounts, 35 seed client/lead accounts without employee roles, and 1 unverified account without an employee role. All 59 had a usable password hash; that does not reveal the password value. The shell listing below gives the full current roster when needed, since names, statuses, and seed rows can change.

### Test administrator

| Login                | Seed role                                              | Password                             | Source and effect                                    |
| -------------------- | ------------------------------------------------------ | ------------------------------------ | ---------------------------------------------------- |
| `admin@gmail.com`    | Test Main Full Access Admin; unscoped full permissions | `password` (local test fixture only) | `user/management/commands/ensure_test_admin.py`      |
| `ejimovc9@gmail.com` | Super Admin; unscoped full permissions                 | Unknown; password hash only          | Existing account; not created by the QA seed command |

From `bomach_os_backend`, run `.venv/bin/python manage.py ensure_test_admin` only when full-admin access is needed. The command rejects runtime modes other than `local`, `development`, and `test`; it creates or updates this user, resets its password, marks the account verified/staff/superuser, grants the role all permissions, clears that role's branch assignments, and creates or updates its employee record. Verify the database target separately: the command's runtime guard is not proof that a configured database is safe.

Prefer `admin@gmail.com` for full-access UI work. Do not reset or use the existing Super Admin account for test coverage unless its synthetic test identity has been confirmed; its password is not recoverable from the database.

### Existing QA employee identities

These two local identities were present in the verified database. Their passwords are hashes with unknown values; use the current local secret source if one exists, or reset a dedicated QA account before relying on it. Do not try to recover a password from the hash.

| Login                          | Role                    | Employee ID           | Branch | Relevant permissions                                                            |
| ------------------------------ | ----------------------- | --------------------- | ------ | ------------------------------------------------------------------------------- |
| `qa.attendance@example.test`   | QA Attendance Workflows | `QA-ATT-001`          | Enugu  | Own attendance/leaves/work locations; branch list/view                          |
| `qa.role.preview@example.test` | QA Role Page Preview    | `QA-ROLE-PREVIEW-001` | Enugu  | Own role description, KPIs, routines, reporting, resources, SOPs, and templates |

### Other accounts in the snapshot

These are current local database records without employee-role permissions. They are not substitutes for employee permission personas. Their password hashes are not recoverable; prefer the dedicated local client/lead seed instructions for the related module when a client login needs testing.

| Login(s)                                                              | Count | Role/access profile                                                     | Password           |
| --------------------------------------------------------------------- | ----: | ----------------------------------------------------------------------- | ------------------ |
| `seed.client.*@bomach.seed`                                           |    20 | Seed client identities; no employee role                                | Unknown; hash only |
| `seed.lead.unlinked.01`, `.02`, `.18`, `.19`, `.20` at `@bomach.seed` |     5 | Seed lead identities; no employee role                                  | Unknown; hash only |
| `seed.linked.client.01` through `.10` at `@bomach.seed`               |    10 | Seed linked-client identities; no employee role                         | Unknown; hash only |
| `ejimovc@gmail.com`                                                   |     1 | Unverified account without an employee record or role; not a QA persona | Unknown; hash only |

These grouped counts plus the two administrators, two QA employees, and 19 staff scenario logins account for all 59 users observed in the snapshot. Run the live listing below for exact seeded client/lead logins and current changes.

Exact client/lead login roster observed in that snapshot; each had no employee record or employee role and an unknown password hash:

```text
seed.client.company.lagos.hospitality@bomach.seed
seed.client.company.lagos.logistics@bomach.seed
seed.client.company.lagos.retail@bomach.seed
seed.client.company.lagos.tech@bomach.seed
seed.client.company.phc.construction@bomach.seed
seed.client.company.phc.manufacturing@bomach.seed
seed.client.cooperative.enu.agric@bomach.seed
seed.client.cooperative.housing.enu@bomach.seed
seed.client.diaspora.uk@bomach.seed
seed.client.family.abuja@bomach.seed
seed.client.family.land.enu@bomach.seed
seed.client.government.abuja@bomach.seed
seed.client.government.ministry@bomach.seed
seed.client.hnw.lagos@bomach.seed
seed.client.individual.enu@bomach.seed
seed.client.ngo.phc@bomach.seed
seed.client.realtor.lagos@bomach.seed
seed.client.referral.enu@bomach.seed
seed.client.student.enu@bomach.seed
seed.client.walkin.abuja@bomach.seed
seed.lead.unlinked.01@bomach.seed
seed.lead.unlinked.02@bomach.seed
seed.lead.unlinked.18@bomach.seed
seed.lead.unlinked.19@bomach.seed
seed.lead.unlinked.20@bomach.seed
seed.linked.client.01@bomach.seed
seed.linked.client.02@bomach.seed
seed.linked.client.03@bomach.seed
seed.linked.client.04@bomach.seed
seed.linked.client.05@bomach.seed
seed.linked.client.06@bomach.seed
seed.linked.client.07@bomach.seed
seed.linked.client.08@bomach.seed
seed.linked.client.09@bomach.seed
seed.linked.client.10@bomach.seed
```

These are seed identities for client/lead modules, not employees who can test Company/HR permission levels. Their login hashes are usable but their password values are unknown; use their owning module's safe seed command or create a dedicated synthetic login if authenticated client behavior must be checked.

### Local staff scenario

The `seed_local_staff_scenario` command creates or refreshes 19 synthetic staff logins. It requires a shared password through `--password`; there is no fixed password to recover from existing database accounts. Choose a temporary local-only value when seeding. The command prints the supplied password at the end, so do not paste its terminal output into logs or reports.

| Login               | Role                           | Assigned branch | Permission profile                      |
| ------------------- | ------------------------------ | --------------- | --------------------------------------- |
| `staff1@gmail.com`  | People Operations Manager      | Lagos           | Staff baseline plus manager permissions |
| `staff2@gmail.com`  | Business Development Executive | Lagos           | Staff baseline                          |
| `staff3@gmail.com`  | Business Development Executive | Enugu           | Staff baseline                          |
| `staff4@gmail.com`  | Finance Officer                | Abuja           | Staff baseline                          |
| `staff5@gmail.com`  | Operations Coordinator         | Lagos           | Staff baseline                          |
| `staff6@gmail.com`  | Project Delivery Lead          | Enugu           | Staff baseline                          |
| `staff7@gmail.com`  | Legal Associate                | Abuja           | Staff baseline                          |
| `staff8@gmail.com`  | Marketing Strategist           | Port Harcourt   | Staff baseline                          |
| `staff9@gmail.com`  | Client Relations Officer       | Port Harcourt   | Staff baseline                          |
| `staff10@gmail.com` | Business Development Executive | Lagos           | Staff baseline                          |
| `staff11@gmail.com` | Finance Officer                | Abuja           | Staff baseline                          |
| `staff12@gmail.com` | Operations Coordinator         | Enugu           | Staff baseline                          |
| `staff13@gmail.com` | Project Delivery Lead          | Lagos           | Staff baseline                          |
| `staff14@gmail.com` | Legal Associate                | Lagos           | Staff baseline                          |
| `staff15@gmail.com` | Marketing Strategist           | Abuja           | Staff baseline                          |
| `staff16@gmail.com` | Client Relations Officer       | Enugu           | Staff baseline                          |
| `staff17@gmail.com` | Business Development Executive | Port Harcourt   | Staff baseline                          |
| `staff18@gmail.com` | Operations Coordinator         | Port Harcourt   | Staff baseline                          |
| `staff19@gmail.com` | Finance Officer                | Lagos           | Staff baseline                          |

Run from `bomach_os_backend` after confirming the active connection is the backend checkout's local SQLite database and `DEBUG` plus `BOMACH_RUNTIME_ENV` are enabled for local development:

```bash
.venv/bin/python manage.py seed_local_staff_scenario --password '<temporary-local-test-password>' --dry-run
.venv/bin/python manage.py seed_local_staff_scenario --password '<temporary-local-test-password>'
```

The seeder enforces the local `db.sqlite3` path and refuses to take over accounts whose employee IDs do not match its own cohort. It creates/refreshes users, role and department assignments, attendance, leave requests, reports, KPI and target history. Review those effects before running it; this is a scenario seeder, not a small user-only command.

## Permission and branch-scope coverage

Use the seeded manager and staff accounts for ordinary manager/staff flows. For a feature-specific access matrix, create a synthetic role with only the required permission combination and assign it to a synthetic user. Include at least:

| Persona        | Permissions/scope to configure                              | What it verifies                                                                |
| -------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Signed out     | No authenticated session                                    | Login redirect, deep-link return, and protected data not rendered               |
| No access      | Authenticated, no permission for the feature                | Route denial, hidden actions, and API 403 behavior                              |
| Read-only      | Feature `view`/`list` permission, no mutation permissions   | Read access with no create/edit/approve/reject controls; direct mutation denied |
| Single action  | Read plus exactly one action permission                     | That action is available while other actions remain unavailable and API-denied  |
| Company-scoped | Required company-wide permissions                           | Cross-branch list/detail access where contract allows it                        |
| Branch-scoped  | Same feature permission with one assigned branch            | List and action scope within the assigned branch                                |
| Out-of-scope   | Branch-scoped account accessing an unassigned branch record | No data leakage through direct URLs, filters, list totals, or mutations         |

Set employee branch and role branch scope according to the backend's actual authorization contract. Test both a record inside and outside that scope. Permission names and accepted actions come from the backend permission map and API checks; do not guess from route names or frontend button visibility.

## Finding the users currently in the database

The table above documents known seed identities, not every current account. Existing users' passwords cannot be listed: only password hashes are stored. If the password for a test identity is unknown, reset a dedicated synthetic account with an authorized local seed/setup path rather than attempting to recover it.

To inspect **all identities currently in the verified non-production database**, run this read-only Django shell listing from `bomach_os_backend`. The result is a current snapshot; it can differ from the seeded catalog above. Keep its output local and do not add real user data to a committed document or report.

```bash
.venv/bin/python manage.py shell <<'PY'
from django.contrib.auth import get_user_model
from user.models.employee import Employee

roles = {}
for user in get_user_model().objects.order_by("email"):
    employee = (
        Employee.objects.filter(user_id=user.pk)
        .select_related("role", "branch")
        .first()
    )
    role = getattr(employee, "role", None)
    branch = getattr(employee, "branch", None)
    scoped_branches = (
        ", ".join(str(item) for item in role.branches.all())
        if role and hasattr(role, "branches")
        else ""
    )
    print({
        "email": user.email,
        "username": user.username,
        "active": user.is_active,
        "verified": getattr(user, "is_verified", None),
        "employee_id": getattr(employee, "employee_id", None),
        "role": getattr(role, "name", None),
        "employee_branch": str(branch) if branch else None,
        "role_branches": scoped_branches,
    })
    if role:
        roles[role.pk] = role

for role in roles.values():
    print({
        "role": role.name,
        "role_branches": [str(item) for item in role.branches.all()]
        if hasattr(role, "branches") else [],
        "permissions": role.permissions,
    })
PY
```

This intentionally omits passwords. Do not add a `password` or password-hash field: Django stores one-way hashes, so existing passwords cannot be read back. For an unknown password, reset a dedicated synthetic account using a seed/setup path or create a new test identity; record any new test-only credential in the appropriate local secret store, not in findings or screenshots. If a user lacks an `Employee` record, inspect the backend's active identity model rather than silently assigning permissions from a different account.

## Fixture naming and cleanup

- Use unique markers such as `QA-20261023-company-branch-<case>` in names, notes, and external IDs where accepted.
- Record the fixture owner, account, role, branch assignment, and generated IDs before exercising actions.
- It is authorized to reset or remove fixtures created for the current test. Avoid deleting unrelated pre-existing QA records; preserve them unless the user specifically asks for cleanup.
- Do not send real email/SMS/push notifications. Use local delivery capture or a controlled mock, then verify the composed content and recipient selection.
