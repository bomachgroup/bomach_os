# BOMACH Backend Operations API OpenAPI Spec
Version: 1.0.0
Description: Backend API for BOMACH Operations
Total Endpoints: 39

## Endpoints by Tag

### Contracts

#### GET /api/v1/contracts
- **Summary:** List Contracts
- **Operation ID:** `api_api_v1_contracts_list_contracts`
- **Description:** List all contracts with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (query, optional, any)
  - `status` (query, optional, any)
  - `contract_type` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedContractOutSchema`

#### POST /api/v1/contracts
- **Summary:** Create Contract
- **Operation ID:** `api_api_v1_contracts_create_contract`
- **Description:** Create a new contract
- **Auth Required:** Yes
- **Request Body (application/json):** `ContractCreateSchema`
  - Fields:
    - `project_id`: integer *(required)*
    - `name`: string *(required)*
    - `contract_number`: string *(required)*
    - `contract_type`: string *(required)*
    - `status`: string
    - `value`: any *(required)*
    - `start_date`: string *(required)*
    - `end_date`: string *(required)*
- **Responses:**
  - `200` OK → `ContractOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/contracts/{contract_id}
- **Summary:** Get Contract
- **Operation ID:** `api_api_v1_contracts_get_contract`
- **Description:** Get a specific contract by ID
- **Auth Required:** Yes
- **Parameters:**
  - `contract_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ContractOutSchema`

#### PUT /api/v1/contracts/{contract_id}
- **Summary:** Update Contract
- **Operation ID:** `api_api_v1_contracts_update_contract`
- **Description:** Update an existing contract
- **Auth Required:** Yes
- **Parameters:**
  - `contract_id` (path, required, integer)
- **Request Body (application/json):** `ContractUpdateSchema`
  - Fields:
    - `project_id`: any
    - `name`: any
    - `contract_number`: any
    - `contract_type`: any
    - `status`: any
    - `value`: any
    - `start_date`: any
    - `end_date`: any
- **Responses:**
  - `200` OK → `ContractOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/contracts/{contract_id}
- **Summary:** Delete Contract
- **Operation ID:** `api_api_v1_contracts_delete_contract`
- **Description:** Delete a contract
- **Auth Required:** Yes
- **Parameters:**
  - `contract_id` (path, required, integer)
- **Responses:**
  - `200` OK


### Dashboard

#### GET /api/v1/dashboard/stats
- **Summary:** Get Dashboard Stats
- **Operation ID:** `api_api_v1_dashboard_get_dashboard_stats`
- **Description:** Get dashboard statistics
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `DashboardStatsSchema`


### Health

#### GET /api/v1/health
- **Summary:** Health Check
- **Operation ID:** `api_api_health_check`
- **Description:** Health check endpoint
- **Auth Required:** No
- **Responses:**
  - `200` OK


### Milestones

#### GET /api/v1/milestones
- **Summary:** List Milestones
- **Operation ID:** `api_api_v1_milestones_list_milestones`
- **Description:** List all milestones with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (query, optional, any)
  - `status` (query, optional, any)
  - `priority` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedMilestoneOutSchema`

#### POST /api/v1/milestones
- **Summary:** Create Milestone
- **Operation ID:** `api_api_v1_milestones_create_milestone`
- **Description:** Create a new milestone
- **Auth Required:** Yes
- **Request Body (application/json):** `MilestoneCreateSchema`
  - Fields:
    - `project_id`: integer *(required)*
    - `name`: string *(required)*
    - `description`: any
    - `priority`: string
    - `status`: string
    - `budget`: any
    - `progress`: integer
    - `start_date`: any
    - `end_date`: any
- **Responses:**
  - `200` OK → `MilestoneOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/milestones/{milestone_id}
- **Summary:** Get Milestone
- **Operation ID:** `api_api_v1_milestones_get_milestone`
- **Description:** Get a specific milestone by ID
- **Auth Required:** Yes
- **Parameters:**
  - `milestone_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MilestoneOutSchema`

#### PUT /api/v1/milestones/{milestone_id}
- **Summary:** Update Milestone
- **Operation ID:** `api_api_v1_milestones_update_milestone`
- **Description:** Update an existing milestone
- **Auth Required:** Yes
- **Parameters:**
  - `milestone_id` (path, required, integer)
- **Request Body (application/json):** `MilestoneUpdateSchema`
  - Fields:
    - `project_id`: any
    - `name`: any
    - `description`: any
    - `priority`: any
    - `status`: any
    - `budget`: any
    - `progress`: any
    - `start_date`: any
    - `end_date`: any
- **Responses:**
  - `200` OK → `MilestoneOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/milestones/{milestone_id}
- **Summary:** Delete Milestone
- **Operation ID:** `api_api_v1_milestones_delete_milestone`
- **Description:** Delete a milestone
- **Auth Required:** Yes
- **Parameters:**
  - `milestone_id` (path, required, integer)
- **Responses:**
  - `200` OK


### Projects

#### GET /api/v1/projects
- **Summary:** List Projects
- **Operation ID:** `api_api_v1_projects_list_projects`
- **Description:** List all projects with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `status` (query, optional, any)
  - `priority` (query, optional, any)
  - `client_id` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedProjectOutSchema`

#### POST /api/v1/projects
- **Summary:** Create Project
- **Operation ID:** `api_api_v1_projects_create_project`
- **Description:** Create a new project
- **Auth Required:** Yes
- **Request Body (application/json):** `ProjectCreateSchema`
  - Fields:
    - `name`: string *(required)*
    - `short_code`: string *(required)*
    - `category`: string *(required)*
    - `department`: any
    - `client_id`: string *(required)*
    - `employee_ids`: array
    - `location`: any
    - `priority`: string
    - `summary`: any
    - `status`: string
    - `budget`: any *(required)*
    - `progress`: integer
    - `start_date`: any
    - `deadline`: any
    - `file_url`: any
- **Responses:**
  - `200` OK → `ProjectOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/projects/stats/
- **Summary:** Stats Project
- **Operation ID:** `api_api_v1_projects_stats_project`
- **Description:** Delete a project
- **Auth Required:** Yes
- **Responses:**
  - `200` OK

#### GET /api/v1/projects/{project_id}
- **Summary:** Get Project
- **Operation ID:** `api_api_v1_projects_get_project`
- **Description:** Get a specific project by ID
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ProjectOutSchema`

#### PUT /api/v1/projects/{project_id}
- **Summary:** Update Project
- **Operation ID:** `api_api_v1_projects_update_project`
- **Description:** Update an existing project
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (path, required, integer)
- **Request Body (application/json):** `ProjectUpdateSchema`
  - Fields:
    - `name`: any
    - `short_code`: any
    - `category`: any
    - `department`: any
    - `client_id`: any
    - `employee_ids`: any
    - `location`: any
    - `priority`: any
    - `summary`: any
    - `status`: any
    - `budget`: any
    - `progress`: any
    - `start_date`: any
    - `deadline`: any
    - `file_url`: any
- **Responses:**
  - `200` OK → `ProjectOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/projects/{project_id}
- **Summary:** Delete Project
- **Operation ID:** `api_api_v1_projects_delete_project`
- **Description:** Delete a project
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (path, required, integer)
- **Responses:**
  - `200` OK

#### GET /api/v1/projects/{project_id}/employees
- **Summary:** List Project Employees
- **Operation ID:** `api_api_v1_projects_list_project_employees`
- **Description:** List employees assigned to a project with pagination
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (path, required, integer)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PaginatedEmployeeResponse`


### Site Equipment

#### GET /api/v1/site-equipment
- **Summary:** List Site Equipment
- **Operation ID:** `api_api_v1_site_equipment_list_site_equipment`
- **Description:** List all site equipment with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `worksite_id` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedSiteEquipmentOutSchema`

#### POST /api/v1/site-equipment
- **Summary:** Create Site Equipment
- **Operation ID:** `api_api_v1_site_equipment_create_site_equipment`
- **Description:** Create a new site equipment item
- **Auth Required:** Yes
- **Request Body (application/json):** `SiteEquipmentCreateSchema`
  - Fields:
    - `worksite_id`: integer *(required)*
    - `name`: string *(required)*
    - `unit_value`: string *(required)*
- **Responses:**
  - `200` OK → `SiteEquipmentOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/site-equipment/{equipment_id}
- **Summary:** Get Site Equipment
- **Operation ID:** `api_api_v1_site_equipment_get_site_equipment`
- **Description:** Get a specific site equipment item by ID
- **Auth Required:** Yes
- **Parameters:**
  - `equipment_id` (path, required, integer)
- **Responses:**
  - `200` OK → `SiteEquipmentOutSchema`

#### PUT /api/v1/site-equipment/{equipment_id}
- **Summary:** Update Site Equipment
- **Operation ID:** `api_api_v1_site_equipment_update_site_equipment`
- **Description:** Update an existing site equipment item
- **Auth Required:** Yes
- **Parameters:**
  - `equipment_id` (path, required, integer)
- **Request Body (application/json):** `SiteEquipmentUpdateSchema`
  - Fields:
    - `worksite_id`: any
    - `name`: any
    - `unit_value`: any
- **Responses:**
  - `200` OK → `SiteEquipmentOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/site-equipment/{equipment_id}
- **Summary:** Delete Site Equipment
- **Operation ID:** `api_api_v1_site_equipment_delete_site_equipment`
- **Description:** Delete a site equipment item
- **Auth Required:** Yes
- **Parameters:**
  - `equipment_id` (path, required, integer)
- **Responses:**
  - `200` OK


### Tasks

#### GET /api/v1/tasks
- **Summary:** List Tasks
- **Operation ID:** `api_api_v1_tasks_list_tasks`
- **Description:** List all tasks with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (query, optional, any)
  - `status` (query, optional, any)
  - `priority` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedTaskOutSchema`

#### POST /api/v1/tasks
- **Summary:** Create Task
- **Operation ID:** `api_api_v1_tasks_create_task`
- **Description:** Create a new task
- **Auth Required:** Yes
- **Request Body (application/json):** `TaskCreateSchema`
  - Fields:
    - `milestone_id`: any
    - `name`: string *(required)*
    - `description`: any
    - `status`: string
    - `priority`: string
    - `assigned_to`: array
    - `due_date`: any
    - `estimated_hours`: any
- **Responses:**
  - `200` OK → `TaskOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/tasks/{task_id}
- **Summary:** Get Task
- **Operation ID:** `api_api_v1_tasks_get_task`
- **Description:** Get a specific task by ID
- **Auth Required:** Yes
- **Parameters:**
  - `task_id` (path, required, integer)
- **Responses:**
  - `200` OK → `TaskOutSchema`

#### PUT /api/v1/tasks/{task_id}
- **Summary:** Update Task
- **Operation ID:** `api_api_v1_tasks_update_task`
- **Description:** Update an existing task
- **Auth Required:** Yes
- **Parameters:**
  - `task_id` (path, required, integer)
- **Request Body (application/json):** `TaskUpdateSchema`
  - Fields:
    - `milestone_id`: any
    - `name`: any
    - `description`: any
    - `status`: any
    - `priority`: any
    - `assigned_to`: any
    - `due_date`: any
    - `estimated_hours`: any
- **Responses:**
  - `200` OK → `TaskOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/tasks/{task_id}
- **Summary:** Delete Task
- **Operation ID:** `api_api_v1_tasks_delete_task`
- **Description:** Delete a task
- **Auth Required:** Yes
- **Parameters:**
  - `task_id` (path, required, integer)
- **Responses:**
  - `200` OK


### Timelines

#### GET /api/v1/timelines
- **Summary:** List Timelines
- **Operation ID:** `api_api_v1_timelines_list_timelines`
- **Description:** List all timelines with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (query, optional, any)
  - `status` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedTimelineOutSchema`

#### POST /api/v1/timelines
- **Summary:** Create Timeline
- **Operation ID:** `api_api_v1_timelines_create_timeline`
- **Description:** Create a new timeline
- **Auth Required:** Yes
- **Request Body (application/json):** `TimelineCreateSchema`
  - Fields:
    - `project_id`: integer *(required)*
    - `name`: string *(required)*
    - `description`: any
    - `status`: string
    - `start_date`: string *(required)*
    - `end_date`: string *(required)*
- **Responses:**
  - `200` OK → `TimelineOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/timelines/{timeline_id}
- **Summary:** Get Timeline
- **Operation ID:** `api_api_v1_timelines_get_timeline`
- **Description:** Get a specific timeline by ID
- **Auth Required:** Yes
- **Parameters:**
  - `timeline_id` (path, required, integer)
- **Responses:**
  - `200` OK → `TimelineOutSchema`

#### PUT /api/v1/timelines/{timeline_id}
- **Summary:** Update Timeline
- **Operation ID:** `api_api_v1_timelines_update_timeline`
- **Description:** Update an existing timeline
- **Auth Required:** Yes
- **Parameters:**
  - `timeline_id` (path, required, integer)
- **Request Body (application/json):** `TimelineUpdateSchema`
  - Fields:
    - `project_id`: any
    - `name`: any
    - `description`: any
    - `status`: any
    - `start_date`: any
    - `end_date`: any
- **Responses:**
  - `200` OK → `TimelineOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/timelines/{timeline_id}
- **Summary:** Delete Timeline
- **Operation ID:** `api_api_v1_timelines_delete_timeline`
- **Description:** Delete a timeline
- **Auth Required:** Yes
- **Parameters:**
  - `timeline_id` (path, required, integer)
- **Responses:**
  - `200` OK


### Worksites

#### GET /api/v1/worksites
- **Summary:** List Worksites
- **Operation ID:** `api_api_v1_worksites_list_worksites`
- **Description:** List all worksites with optional filters
- **Auth Required:** Yes
- **Parameters:**
  - `project_id` (query, optional, any)
  - `status` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedWorksiteOutSchema`

#### POST /api/v1/worksites
- **Summary:** Create Worksite
- **Operation ID:** `api_api_v1_worksites_create_worksite`
- **Description:** Create a new worksite
- **Auth Required:** Yes
- **Request Body (application/json):** `WorksiteCreateSchema`
  - Fields:
    - `project_id`: integer *(required)*
    - `name`: string *(required)*
    - `location`: string *(required)*
    - `status`: string
    - `description`: any
- **Responses:**
  - `200` OK → `WorksiteOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/worksites/{worksite_id}
- **Summary:** Get Worksite
- **Operation ID:** `api_api_v1_worksites_get_worksite`
- **Description:** Get a specific worksite by ID
- **Auth Required:** Yes
- **Parameters:**
  - `worksite_id` (path, required, integer)
- **Responses:**
  - `200` OK → `WorksiteOutSchema`

#### PUT /api/v1/worksites/{worksite_id}
- **Summary:** Update Worksite
- **Operation ID:** `api_api_v1_worksites_update_worksite`
- **Description:** Update an existing worksite
- **Auth Required:** Yes
- **Parameters:**
  - `worksite_id` (path, required, integer)
- **Request Body (application/json):** `WorksiteUpdateSchema`
  - Fields:
    - `project_id`: any
    - `name`: any
    - `location`: any
    - `status`: any
    - `description`: any
- **Responses:**
  - `200` OK → `WorksiteOutSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/worksites/{worksite_id}
- **Summary:** Delete Worksite
- **Operation ID:** `api_api_v1_worksites_delete_worksite`
- **Description:** Delete a worksite
- **Auth Required:** Yes
- **Parameters:**
  - `worksite_id` (path, required, integer)
- **Responses:**
  - `200` OK


## Schemas

### ContractCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `contract_number` | string | Yes |  |
| `contract_type` | string | Yes |  |
| `status` | string | No |  |
| `value` | number | string | Yes |  |
| `start_date` | string | Yes |  |
| `end_date` | string | Yes |  |

### ContractOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `contract_number` | string | Yes |  |
| `contract_type` | string | Yes |  |
| `status` | string | Yes |  |
| `value` | string | Yes |  |
| `start_date` | string | Yes |  |
| `end_date` | string | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### ContractUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `contract_number` | string | null | No |  |
| `contract_type` | string | null | No |  |
| `status` | string | null | No |  |
| `value` | number | string | null | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |

### DashboardStatsSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_projects` | integer | Yes |  |
| `total_budget` | string | Yes |  |
| `budget_utilization` | string | Yes |  |
| `total_worksites` | integer | Yes |  |
| `total_contracts` | integer | Yes |  |
| `total_timelines` | integer | Yes |  |

### EmployeeOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes |  |
| `employee_id` | string | Yes |  |
| `email` | string | Yes |  |
| `full_name` | string | Yes |  |
| `phone` | string | Yes |  |
| `department_id` | string | Yes |  |
| `position` | string | Yes |  |
| `is_active` | boolean | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |
| `department_name` | string | Yes |  |
| `branch_name` | string | Yes |  |
| `gross_salary` | string | Yes |  |
| `allowances` | object | Yes |  |
| `employment_type` | string | Yes |  |

### Input

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `limit` | integer | No |  |
| `offset` | integer | No |  |

### MessageSchema
_Schema for success/error messages_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `detail` | string | Yes |  |

### MilestoneCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `priority` | string | No |  |
| `status` | string | No |  |
| `budget` | number | string | null | No |  |
| `progress` | integer | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |

### MilestoneOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | Yes |  |
| `priority` | string | Yes |  |
| `status` | string | Yes |  |
| `budget` | string | null | Yes |  |
| `progress` | integer | Yes |  |
| `start_date` | string | null | Yes |  |
| `end_date` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### MilestoneUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `description` | string | null | No |  |
| `priority` | string | null | No |  |
| `status` | string | null | No |  |
| `budget` | number | string | null | No |  |
| `progress` | integer | null | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |

### PagedContractOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedMilestoneOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedProjectOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedSiteEquipmentOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedTaskOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedTimelineOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedWorksiteOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PaginatedEmployeeResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### ProjectCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes |  |
| `short_code` | string | Yes |  |
| `category` | string | Yes |  |
| `department` | string | null | No |  |
| `client_id` | string | Yes |  |
| `employee_ids` | array | No |  |
| `location` | string | null | No |  |
| `priority` | string | No |  |
| `summary` | string | null | No |  |
| `status` | string | No |  |
| `budget` | number | string | Yes |  |
| `progress` | integer | No |  |
| `start_date` | string | null | No |  |
| `deadline` | string | null | No |  |
| `file_url` | string | null | No |  |

### ProjectOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |
| `short_code` | string | Yes |  |
| `category` | string | Yes |  |
| `department` | string | null | Yes |  |
| `client_id` | string | Yes |  |
| `employee_ids` | array | Yes |  |
| `location` | string | null | Yes |  |
| `priority` | string | Yes |  |
| `summary` | string | null | Yes |  |
| `status` | string | Yes |  |
| `budget` | string | Yes |  |
| `progress` | integer | Yes |  |
| `start_date` | string | null | Yes |  |
| `deadline` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |
| `file_url` | string | null | No |  |

### ProjectUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | null | No |  |
| `short_code` | string | null | No |  |
| `category` | string | null | No |  |
| `department` | string | null | No |  |
| `client_id` | string | null | No |  |
| `employee_ids` | array | null | No |  |
| `location` | string | null | No |  |
| `priority` | string | null | No |  |
| `summary` | string | null | No |  |
| `status` | string | null | No |  |
| `budget` | number | string | null | No |  |
| `progress` | integer | null | No |  |
| `start_date` | string | null | No |  |
| `deadline` | string | null | No |  |
| `file_url` | string | null | No |  |

### SiteEquipmentCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `worksite_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `unit_value` | string | Yes |  |

### SiteEquipmentOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `worksite_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `unit_value` | string | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### SiteEquipmentUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `worksite_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `unit_value` | string | null | No |  |

### TaskCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `milestone_id` | integer | null | No |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `status` | string | No |  |
| `priority` | string | No |  |
| `assigned_to` | array | No |  |
| `due_date` | string | null | No |  |
| `estimated_hours` | number | string | null | No |  |

### TaskOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `milestone_id` | integer | null | No |  |
| `name` | string | Yes |  |
| `description` | string | null | Yes |  |
| `status` | string | Yes |  |
| `priority` | string | Yes |  |
| `assigned_to` | array | Yes |  |
| `due_date` | string | null | Yes |  |
| `estimated_hours` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### TaskUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `milestone_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `description` | string | null | No |  |
| `status` | string | null | No |  |
| `priority` | string | null | No |  |
| `assigned_to` | array | null | No |  |
| `due_date` | string | null | No |  |
| `estimated_hours` | number | string | null | No |  |

### TimelineCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `status` | string | No |  |
| `start_date` | string | Yes |  |
| `end_date` | string | Yes |  |

### TimelineOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | Yes |  |
| `status` | string | Yes |  |
| `start_date` | string | Yes |  |
| `end_date` | string | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### TimelineUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `description` | string | null | No |  |
| `status` | string | null | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |

### WorksiteCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `location` | string | Yes |  |
| `status` | string | No |  |
| `description` | string | null | No |  |

### WorksiteOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `project_id` | integer | Yes |  |
| `name` | string | Yes |  |
| `location` | string | Yes |  |
| `status` | string | Yes |  |
| `description` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### WorksiteUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | integer | null | No |  |
| `name` | string | null | No |  |
| `location` | string | null | No |  |
| `status` | string | null | No |  |
| `description` | string | null | No |  |
