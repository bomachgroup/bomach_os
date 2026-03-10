# BOMACH API OpenAPI Spec
Version: 1.0.0
Description: BOMACH Backend REST API for frontend integration
Total Endpoints: 128

## Endpoints by Tag

### Announcements

#### GET /api/v1/announcements/
- **Summary:** List Announcements
- **Operation ID:** `user_api_v1_announcement_list_announcements`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (query, optional, any)
  - `department_id` (query, optional, any)
  - `announcement_type` (query, optional, any)
  - `priority` (query, optional, any)
  - `is_active` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedAnnouncementSchema`

#### POST /api/v1/announcements/
- **Summary:** Create Announcement
- **Operation ID:** `user_api_v1_announcement_create_announcement`
- **Auth Required:** Yes
- **Request Body (application/json):** `AnnouncementCreateSchema`
  - Fields:
    - `title`: string *(required)*
    - `content`: string *(required)*
    - `announcement_type`: string
    - `priority`: string
    - `branch_ids`: array
    - `department_ids`: array
    - `is_active`: boolean
    - `publish_at`: any
    - `expires_at`: any
- **Responses:**
  - `201` Created → `AnnouncementSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/announcements/choices
- **Summary:** Get Announcement Choices
- **Operation ID:** `user_api_v1_announcement_get_announcement_choices`
- **Auth Required:** No
- **Responses:**
  - `200` OK → `AnnouncementChoicesSchema`

#### GET /api/v1/announcements/{announcement_id}
- **Summary:** Get Announcement
- **Operation ID:** `user_api_v1_announcement_get_announcement`
- **Auth Required:** Yes
- **Parameters:**
  - `announcement_id` (path, required, integer)
- **Responses:**
  - `200` OK → `AnnouncementSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/announcements/{announcement_id}
- **Summary:** Update Announcement
- **Operation ID:** `user_api_v1_announcement_update_announcement`
- **Auth Required:** Yes
- **Parameters:**
  - `announcement_id` (path, required, integer)
- **Request Body (application/json):** `AnnouncementUpdateSchema`
  - Fields:
    - `title`: any
    - `content`: any
    - `announcement_type`: any
    - `priority`: any
    - `branch_ids`: any
    - `department_ids`: any
    - `is_active`: any
    - `publish_at`: any
    - `expires_at`: any
- **Responses:**
  - `200` OK → `AnnouncementSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/announcements/{announcement_id}
- **Summary:** Delete Announcement
- **Operation ID:** `user_api_v1_announcement_delete_announcement`
- **Auth Required:** Yes
- **Parameters:**
  - `announcement_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Approvals

#### GET /api/v1/approvals/flows
- **Summary:** List Approval Flows
- **Operation ID:** `user_api_v1_approval_list_approval_flows`
- **Auth Required:** Yes
- **Parameters:**
  - `action_type` (query, optional, any)
  - `is_active` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedApprovalFlowSchema`

#### POST /api/v1/approvals/flows
- **Summary:** Create Approval Flow
- **Operation ID:** `user_api_v1_approval_create_approval_flow`
- **Auth Required:** Yes
- **Request Body (application/json):** `ApprovalFlowCreateSchema`
  - Fields:
    - `name`: string *(required)*
    - `description`: any
    - `action_type`: string *(required)*
    - `steps`: array *(required)*
- **Responses:**
  - `201` Created → `ApprovalFlowSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/approvals/flows/choices
- **Summary:** Get Approval Flow Choices
- **Operation ID:** `user_api_v1_approval_get_approval_flow_choices`
- **Auth Required:** No
- **Responses:**
  - `200` OK → `ApprovalFlowChoicesSchema`

#### GET /api/v1/approvals/flows/{flow_id}
- **Summary:** Get Approval Flow
- **Operation ID:** `user_api_v1_approval_get_approval_flow`
- **Auth Required:** Yes
- **Parameters:**
  - `flow_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ApprovalFlowSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/approvals/flows/{flow_id}
- **Summary:** Update Approval Flow
- **Operation ID:** `user_api_v1_approval_update_approval_flow`
- **Auth Required:** Yes
- **Parameters:**
  - `flow_id` (path, required, integer)
- **Request Body (application/json):** `ApprovalFlowUpdateSchema`
  - Fields:
    - `name`: any
    - `description`: any
    - `action_type`: any
    - `is_active`: any
    - `steps`: any
- **Responses:**
  - `200` OK → `ApprovalFlowSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/approvals/flows/{flow_id}
- **Summary:** Deactivate Approval Flow
- **Operation ID:** `user_api_v1_approval_deactivate_approval_flow`
- **Auth Required:** Yes
- **Parameters:**
  - `flow_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### GET /api/v1/approvals/requests
- **Summary:** List Approval Requests
- **Operation ID:** `user_api_v1_approval_list_approval_requests`
- **Auth Required:** Yes
- **Parameters:**
  - `status` (query, optional, any)
  - `action_type` (query, optional, any)
  - `my_requests` (query, optional, any)
  - `pending_my_approval` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedApprovalRequestSchema`

#### POST /api/v1/approvals/requests
- **Summary:** Create Approval Request
- **Operation ID:** `user_api_v1_approval_create_approval_request`
- **Auth Required:** Yes
- **Request Body (application/json):** `ApprovalRequestCreateSchema`
  - Fields:
    - `flow_id`: integer *(required)*
    - `title`: string *(required)*
    - `description`: string *(required)*
    - `metadata`: any
- **Responses:**
  - `201` Created → `ApprovalRequestSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/approvals/requests/{request_id}
- **Summary:** Get Approval Request
- **Operation ID:** `user_api_v1_approval_get_approval_request`
- **Auth Required:** Yes
- **Parameters:**
  - `request_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ApprovalRequestSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/approvals/requests/{request_id}
- **Summary:** Cancel Approval Request
- **Operation ID:** `user_api_v1_approval_cancel_approval_request`
- **Auth Required:** Yes
- **Parameters:**
  - `request_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### POST /api/v1/approvals/requests/{request_id}/approve
- **Summary:** Approve Approval Request
- **Operation ID:** `user_api_v1_approval_approve_approval_request`
- **Auth Required:** Yes
- **Parameters:**
  - `request_id` (path, required, integer)
- **Request Body (application/json):** `ApprovalActionSchema`
  - Fields:
    - `comment`: any
- **Responses:**
  - `200` OK → `ApprovalRequestSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### POST /api/v1/approvals/requests/{request_id}/reject
- **Summary:** Reject Approval Request
- **Operation ID:** `user_api_v1_approval_reject_approval_request`
- **Auth Required:** Yes
- **Parameters:**
  - `request_id` (path, required, integer)
- **Request Body (application/json):** `ApprovalActionSchema`
  - Fields:
    - `comment`: any
- **Responses:**
  - `200` OK → `ApprovalRequestSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Audit Logs

#### GET /api/v1/audit-logs/
- **Summary:** List Audit Logs
- **Operation ID:** `user_api_v1_audit_log_list_audit_logs`
- **Auth Required:** Yes
- **Parameters:**
  - `search` (query, optional, any)
  - `user_id` (query, optional, any)
  - `audit_type` (query, optional, any)
  - `audit_status` (query, optional, any)
  - `start_date` (query, optional, any)
  - `end_date` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedAuditLogResponse`
  - `401` Unauthorized → `ErrorResponse`


### Audit Management (Legal)

#### GET /api/v1/audits/
- **Summary:** List Audits
- **Operation ID:** `user_api_v1_audit_list_audits`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_type` (query, optional, any)
  - `status` (query, optional, any)
  - `auditor_name` (query, optional, any)
  - `department` (query, optional, any)
  - `min_score` (query, optional, any)
  - `max_score` (query, optional, any)
  - `search` (query, optional, any)
  - `start_date` (query, optional, any)
  - `end_date` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedAuditResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/audits/
- **Summary:** Create Audit
- **Operation ID:** `user_api_v1_audit_create_audit`
- **Auth Required:** Yes
- **Request Body (application/json):** `CreateAuditRequest`
  - Fields:
    - `audit_name`: string *(required)*
    - `audit_type`: string *(required)*
    - `auditor_name`: string *(required)*
    - `auditor_title`: any
    - `status`: any
    - `score`: any
    - `audit_date`: string *(required)*
    - `audit_number`: any
    - `description`: any
    - `findings`: any
    - `recommendations`: any
    - `start_date`: any
    - `end_date`: any
    - `auditor_organization`: any
    - `department`: any
- **Responses:**
  - `201` Created → `AuditResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/audits/auditors/
- **Summary:** List Auditors
- **Operation ID:** `user_api_v1_audit_list_auditors`
- **Auth Required:** Yes
- **Parameters:**
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedAuditorSummaryResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/audits/failing-audits/
- **Summary:** Get Failing Audits
- **Operation ID:** `user_api_v1_audit_get_failing_audits`
- **Auth Required:** Yes
- **Parameters:**
  - `threshold` (query, optional, integer)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedAuditResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/audits/statistics/overview/
- **Summary:** Get Audit Statistics
- **Operation ID:** `user_api_v1_audit_get_audit_statistics`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `AuditStatisticsResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/audits/statistics/performance-trends/
- **Summary:** Get Performance Trends
- **Operation ID:** `user_api_v1_audit_get_performance_trends`
- **Auth Required:** Yes
- **Parameters:**
  - `period` (query, optional, string)
  - `months` (query, optional, integer)
- **Responses:**
  - `200` OK → `AuditPerformanceTrendsResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/audits/{audit_id}/
- **Summary:** Get Audit
- **Operation ID:** `user_api_v1_audit_get_audit`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_id` (path, required, integer)
- **Responses:**
  - `200` OK → `AuditResponse`
  - `404` Not Found → `ErrorResponse`

#### PUT /api/v1/audits/{audit_id}/
- **Summary:** Update Audit
- **Operation ID:** `user_api_v1_audit_update_audit`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_id` (path, required, integer)
- **Request Body (application/json):** `UpdateAuditRequest`
  - Fields:
    - `audit_name`: any
    - `audit_type`: any
    - `auditor_name`: any
    - `auditor_title`: any
    - `status`: any
    - `score`: any
    - `audit_date`: any
    - `audit_number`: any
    - `description`: any
    - `findings`: any
    - `recommendations`: any
    - `start_date`: any
    - `end_date`: any
    - `auditor_organization`: any
    - `department`: any
- **Responses:**
  - `200` OK → `AuditResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### DELETE /api/v1/audits/{audit_id}/
- **Summary:** Delete Audit
- **Operation ID:** `user_api_v1_audit_delete_audit`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `404` Not Found → `ErrorResponse`

#### PATCH /api/v1/audits/{audit_id}/score/
- **Summary:** Update Audit Score
- **Operation ID:** `user_api_v1_audit_update_audit_score`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_id` (path, required, integer)
- **Request Body (application/json):** `UpdateAuditScoreRequest`
  - Fields:
    - `score`: integer *(required)*
- **Responses:**
  - `200` OK → `AuditResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### PATCH /api/v1/audits/{audit_id}/status/
- **Summary:** Update Audit Status
- **Operation ID:** `user_api_v1_audit_update_audit_status`
- **Auth Required:** Yes
- **Parameters:**
  - `audit_id` (path, required, integer)
- **Request Body (application/json):** `UpdateAuditStatusRequest`
  - Fields:
    - `status`: string *(required)*
- **Responses:**
  - `200` OK → `AuditResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`


### Authentication

#### POST /api/v1/auth/forgot-password
- **Summary:** Forgot Password
- **Operation ID:** `user_api_v1_auth_forgot_password`
- **Auth Required:** No
- **Request Body (application/json):** `ForgotPasswordRequest`
  - Fields:
    - `email`: string *(required)*
- **Responses:**
  - `200` OK → `ForgotPasswordResponse`
  - `404` Not Found → `ErrorResponse`
  - `500` Internal Server Error → `ErrorResponse`

#### POST /api/v1/auth/login
- **Summary:** Login
- **Operation ID:** `user_api_v1_auth_login`
- **Auth Required:** No
- **Request Body (application/json):** `LoginRequest`
  - Fields:
    - `email`: string *(required)*
    - `password`: string *(required)*
- **Responses:**
  - `200` OK → `LoginResponse`
  - `401` Unauthorized → `ErrorResponse`

#### POST /api/v1/auth/logout
- **Summary:** Logout
- **Operation ID:** `user_api_v1_auth_logout`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `LogoutResponse`
  - `500` Internal Server Error → `ErrorResponse`

#### GET /api/v1/auth/me
- **Summary:** Get Current User
- **Operation ID:** `user_api_v1_auth_get_current_user`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `UserResponse`
  - `401` Unauthorized → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### POST /api/v1/auth/refresh
- **Summary:** Refresh Token
- **Operation ID:** `user_api_v1_auth_refresh_token`
- **Auth Required:** No
- **Request Body (application/json):** `RefreshTokenRequest`
  - Fields:
    - `refresh_token`: string *(required)*
- **Responses:**
  - `200` OK → `RefreshTokenResponse`
  - `401` Unauthorized → `ErrorResponse`

#### POST /api/v1/auth/reset-password
- **Summary:** Reset Password
- **Operation ID:** `user_api_v1_auth_reset_password`
- **Auth Required:** No
- **Request Body (application/json):** `ResetPasswordRequest`
  - Fields:
    - `email`: string *(required)*
    - `code`: string *(required)*
    - `new_password`: string *(required)*
- **Responses:**
  - `200` OK → `ResetPasswordResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/auth/verify-token
- **Summary:** Verify Token
- **Operation ID:** `user_api_v1_auth_verify_token`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `VerifyTokenResponse`


### Biometric Authentication

#### GET /api/v1/biometric/attendance/my-records
- **Summary:** Get My Attendance Records
- **Operation ID:** `user_api_v1_biometric_get_my_attendance_records`
- **Auth Required:** Yes
- **Parameters:**
  - `limit` (query, optional, integer)
- **Responses:**
  - `200` OK → `AttendanceRecordResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/biometric/clockin
- **Summary:** Biometric Clockin
- **Operation ID:** `user_api_v1_biometric_biometric_clockin`
- **Auth Required:** Yes
- **Request Body (application/json):** `BiometricClockInRequest`
  - Fields:
    - `biometric_data`: string *(required)*
    - `biometric_type`: string *(required)*
    - `attendance_type`: string *(required)*
- **Responses:**
  - `200` OK → `BiometricClockInResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### POST /api/v1/biometric/login
- **Summary:** Biometric Login
- **Operation ID:** `user_api_v1_biometric_biometric_login`
- **Auth Required:** Yes
- **Request Body (application/json):** `BiometricLoginRequest`
  - Fields:
    - `email`: string *(required)*
    - `biometric_data`: string *(required)*
    - `biometric_type`: string *(required)*
- **Responses:**
  - `200` OK → `LoginResponse`
  - `400` Bad Request → `ErrorResponse`
  - `401` Unauthorized → `ErrorResponse`

#### POST /api/v1/biometric/remove
- **Summary:** Remove Biometric
- **Operation ID:** `user_api_v1_biometric_remove_biometric`
- **Auth Required:** Yes
- **Request Body (application/json):** `RemoveBiometricRequest`
  - Fields:
    - `biometric_type`: string *(required)*
- **Responses:**
  - `200` OK → `BiometricSetupResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/biometric/setup-face
- **Summary:** Setup Face
- **Operation ID:** `user_api_v1_biometric_setup_face`
- **Auth Required:** Yes
- **Request Body (application/json):** `SetupFaceRequest`
  - Fields:
    - `biometric_data`: string *(required)*
- **Responses:**
  - `200` OK → `BiometricSetupResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/biometric/setup-fingerprint
- **Summary:** Setup Fingerprint
- **Operation ID:** `user_api_v1_biometric_setup_fingerprint`
- **Auth Required:** Yes
- **Request Body (application/json):** `SetupFingerprintRequest`
  - Fields:
    - `biometric_data`: string *(required)*
- **Responses:**
  - `200` OK → `BiometricSetupResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/biometric/status
- **Summary:** Get Biometric Status
- **Operation ID:** `user_api_v1_biometric_get_biometric_status`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `BiometricStatusResponse`


### Board Resolutions

#### GET /api/v1/board-resolutions/
- **Summary:** List Board Resolutions
- **Operation ID:** `user_api_v1_board_resolution_list_board_resolutions`
- **Auth Required:** Yes
- **Parameters:**
  - `status` (query, optional, any)
  - `resolution_type` (query, optional, any)
  - `date_from` (query, optional, any)
  - `date_to` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedBoardResolutionSchema`

#### POST /api/v1/board-resolutions/
- **Summary:** Create Board Resolution
- **Operation ID:** `user_api_v1_board_resolution_create_board_resolution`
- **Auth Required:** Yes
- **Request Body (application/json):** `BoardResolutionCreateSchema`
  - Fields:
    - `title`: string *(required)*
    - `description`: string *(required)*
    - `resolution_type`: string *(required)*
    - `resolution_date`: string *(required)*
    - `status`: any
    - `attachment_url`: any
    - `notes`: any
- **Responses:**
  - `201` Created → `BoardResolutionSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/board-resolutions/choices
- **Summary:** Get Board Resolution Choices
- **Operation ID:** `user_api_v1_board_resolution_get_board_resolution_choices`
- **Auth Required:** No
- **Responses:**
  - `200` OK → `BoardResolutionChoicesSchema`

#### GET /api/v1/board-resolutions/{resolution_id}
- **Summary:** Get Board Resolution
- **Operation ID:** `user_api_v1_board_resolution_get_board_resolution`
- **Auth Required:** Yes
- **Parameters:**
  - `resolution_id` (path, required, integer)
- **Responses:**
  - `200` OK → `BoardResolutionSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/board-resolutions/{resolution_id}
- **Summary:** Update Board Resolution
- **Operation ID:** `user_api_v1_board_resolution_update_board_resolution`
- **Auth Required:** Yes
- **Parameters:**
  - `resolution_id` (path, required, integer)
- **Request Body (application/json):** `BoardResolutionUpdateSchema`
  - Fields:
    - `title`: any
    - `description`: any
    - `resolution_type`: any
    - `resolution_date`: any
    - `status`: any
    - `attachment_url`: any
    - `notes`: any
- **Responses:**
  - `200` OK → `BoardResolutionSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/board-resolutions/{resolution_id}
- **Summary:** Archive Board Resolution
- **Operation ID:** `user_api_v1_board_resolution_archive_board_resolution`
- **Auth Required:** Yes
- **Parameters:**
  - `resolution_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### POST /api/v1/board-resolutions/{resolution_id}/approve
- **Summary:** Approve Board Resolution
- **Operation ID:** `user_api_v1_board_resolution_approve_board_resolution`
- **Auth Required:** Yes
- **Parameters:**
  - `resolution_id` (path, required, integer)
- **Responses:**
  - `200` OK → `BoardResolutionSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Branch

#### GET /api/v1/branch/branches
- **Summary:** List Branches
- **Operation ID:** `user_api_v1_branch_list_branches`
- **Auth Required:** Yes
- **Parameters:**
  - `country_id` (query, optional, any)
  - `state_id` (query, optional, any)
  - `operational_status` (query, optional, any)
  - `branch_role` (query, optional, any)
  - `is_active` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedBranchSchema`

#### POST /api/v1/branch/branches
- **Summary:** Create Branch
- **Operation ID:** `user_api_v1_branch_create_branch`
- **Auth Required:** Yes
- **Request Body (application/json):** `BranchCreateSchema`
  - Fields:
    - `branch_name`: string *(required)*
    - `branch_id`: any
    - `default_currency`: any
    - `language_preference`: any
    - `country_id`: integer *(required)*
    - `state_id`: integer *(required)*
    - `lga`: any
    - `office_address`: string *(required)*
    - `operational_status`: string
    - `branch_role`: string
    - `contact_email`: string *(required)*
    - `contact_phone`: string *(required)*
    - `manager_id`: any
    - `branch_file`: any
    - `notes`: any
    - `business_hours`: any
- **Responses:**
  - `201` Created → `BranchSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/branch/branches/choices/fields
- **Summary:** Get Branch Field Choices
- **Operation ID:** `user_api_v1_branch_get_branch_field_choices`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `BranchChoicesSchema`

#### GET /api/v1/branch/branches/{branch_id}
- **Summary:** Get Branch
- **Operation ID:** `user_api_v1_branch_get_branch`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (path, required, integer)
- **Responses:**
  - `200` OK → `BranchSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/branch/branches/{branch_id}
- **Summary:** Update Branch
- **Operation ID:** `user_api_v1_branch_update_branch`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (path, required, integer)
- **Request Body (application/json):** `BranchUpdateSchema`
  - Fields:
    - `branch_name`: any
    - `default_currency`: any
    - `language_preference`: any
    - `country_id`: any
    - `state_id`: any
    - `lga`: any
    - `office_address`: any
    - `operational_status`: any
    - `branch_role`: any
    - `contact_email`: any
    - `contact_phone`: any
    - `manager_id`: any
    - `branch_file`: any
    - `is_active`: any
    - `notes`: any
    - `business_hours`: any
- **Responses:**
  - `200` OK → `BranchSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### GET /api/v1/branch/branches/{branch_id}/business-hours
- **Summary:** Get Branch Business Hours
- **Operation ID:** `user_api_v1_branch_get_branch_business_hours`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (path, required, integer)
- **Responses:**
  - `200` OK
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/branch/branches/{branch_id}/business-hours
- **Summary:** Set Branch Business Hours
- **Operation ID:** `user_api_v1_branch_set_branch_business_hours`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (path, required, integer)
- **Responses:**
  - `200` OK
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### GET /api/v1/branch/branches/{branch_id}/performance
- **Summary:** Get Branch Performance
- **Operation ID:** `user_api_v1_branch_get_branch_performance`
- **Auth Required:** Yes
- **Parameters:**
  - `branch_id` (path, required, integer)
- **Responses:**
  - `200` OK → `BranchPerformanceAnalysisSchema`
  - `404` Not Found → `MessageSchema`

#### GET /api/v1/branch/countries
- **Summary:** List Countries
- **Operation ID:** `user_api_v1_branch_list_countries`
- **Auth Required:** Yes
- **Parameters:**
  - `is_active` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedCountrySchema`

#### GET /api/v1/branch/countries/{country_id}
- **Summary:** Get Country
- **Operation ID:** `user_api_v1_branch_get_country`
- **Auth Required:** Yes
- **Parameters:**
  - `country_id` (path, required, integer)
- **Responses:**
  - `200` OK → `CountrySchema`

#### GET /api/v1/branch/states
- **Summary:** List States
- **Operation ID:** `user_api_v1_branch_list_states`
- **Auth Required:** Yes
- **Parameters:**
  - `country_id` (query, optional, any)
  - `is_active` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedStateSchema`

#### GET /api/v1/branch/states/{state_id}
- **Summary:** Get State
- **Operation ID:** `user_api_v1_branch_get_state`
- **Auth Required:** Yes
- **Parameters:**
  - `state_id` (path, required, integer)
- **Responses:**
  - `200` OK → `StateSchema`


### Client Inventory

#### GET /api/v1/inventory/
- **Summary:** List Inventory Items
- **Operation ID:** `user_api_v1_client_inventory_list_inventory_items`
- **Auth Required:** Yes
- **Parameters:**
  - `search` (query, optional, string)
  - `status` (query, optional, string)
  - `unit` (query, optional, string)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedInventoryItemResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/inventory/
- **Summary:** Create Inventory Item
- **Operation ID:** `user_api_v1_client_inventory_create_inventory_item`
- **Auth Required:** Yes
- **Request Body (application/json):** `CreateInventoryItemRequest`
  - Fields:
    - `item_name`: string *(required)*
    - `quantity`: any *(required)*
    - `quantity_used`: any
    - `unit`: string *(required)*
    - `total_value`: any *(required)*
    - `status`: string *(required)*
- **Responses:**
  - `201` Created → `InventoryItemResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/inventory/{item_id}/
- **Summary:** Get Inventory Item
- **Operation ID:** `user_api_v1_client_inventory_get_inventory_item`
- **Auth Required:** Yes
- **Parameters:**
  - `item_id` (path, required, integer)
- **Responses:**
  - `200` OK → `InventoryItemResponse`
  - `404` Not Found → `ErrorResponse`

#### PUT /api/v1/inventory/{item_id}/
- **Summary:** Update Inventory Item
- **Operation ID:** `user_api_v1_client_inventory_update_inventory_item`
- **Auth Required:** Yes
- **Parameters:**
  - `item_id` (path, required, integer)
- **Request Body (application/json):** `UpdateInventoryItemRequest`
  - Fields:
    - `item_name`: any
    - `quantity`: any
    - `quantity_used`: any
    - `unit`: any
    - `total_value`: any
    - `status`: any
- **Responses:**
  - `200` OK → `InventoryItemResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### DELETE /api/v1/inventory/{item_id}/
- **Summary:** Delete Inventory Item
- **Operation ID:** `user_api_v1_client_inventory_delete_inventory_item`
- **Auth Required:** Yes
- **Parameters:**
  - `item_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `404` Not Found → `ErrorResponse`


### Client Management

#### GET /api/v1/clients/clients/
- **Summary:** List Clients
- **Operation ID:** `user_api_v1_clients_list_clients`
- **Description:** List all clients with pagination and filtering
- **Auth Required:** Yes
- **Parameters:**
  - `search` (query, optional, string)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedClientResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/clients/clients/
- **Summary:** Create Client
- **Operation ID:** `user_api_v1_clients_create_client`
- **Auth Required:** Yes
- **Request Body (application/json):** `CreateClientRequest`
  - Fields:
    - `email`: string *(required)*
    - `first_name`: string *(required)*
    - `last_name`: string *(required)*
    - `phone_number`: string *(required)*
- **Responses:**
  - `201` Created → `ClientResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/clients/clients/{client_id}/
- **Summary:** Get Client
- **Operation ID:** `user_api_v1_clients_get_client`
- **Description:** Get client details by ID
- **Auth Required:** Yes
- **Parameters:**
  - `client_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ClientResponse`
  - `404` Not Found → `ErrorResponse`

#### PUT /api/v1/clients/clients/{client_id}/
- **Summary:** Update Client
- **Operation ID:** `user_api_v1_clients_update_client`
- **Description:** Update client information
- **Auth Required:** Yes
- **Parameters:**
  - `client_id` (path, required, integer)
- **Request Body (application/json):** `UpdateClientRequest`
  - Fields:
    - `first_name`: string *(required)*
    - `last_name`: string *(required)*
    - `email`: string *(required)*
    - `profile_picture`: any
    - `address`: any
    - `phone_number`: any
    - `gender`: any
- **Responses:**
  - `200` OK → `ClientResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### GET /api/v1/clients/leads/
- **Summary:** List Leads
- **Operation ID:** `user_api_v1_clients_list_leads`
- **Description:** List all leads with pagination and filtering
- **Auth Required:** Yes
- **Parameters:**
  - `search` (query, optional, string)
  - `status` (query, optional, string)
  - `source` (query, optional, string)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedLeadResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/clients/leads/
- **Summary:** Create Lead
- **Operation ID:** `user_api_v1_clients_create_lead`
- **Description:** Create a new lead
- **Auth Required:** Yes
- **Request Body (application/json):** `CreateLeadRequest`
  - Fields:
    - `email`: string *(required)*
    - `first_name`: string *(required)*
    - `last_name`: string *(required)*
    - `gender`: any
    - `marital_status`: any
    - `address`: any
    - `phone_number`: any
    - `profile_picture`: any
    - `source`: any
    - `status`: any
    - `company_name`: any
    - `interested_services`: string *(required)*
    - `assigned_to_id`: any
    - `notes`: any
- **Responses:**
  - `201` Created → `LeadResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/clients/leads/{lead_id}/
- **Summary:** Get Lead
- **Operation ID:** `user_api_v1_clients_get_lead`
- **Description:** Get lead details by ID
- **Auth Required:** Yes
- **Parameters:**
  - `lead_id` (path, required, integer)
- **Responses:**
  - `200` OK → `LeadResponse`
  - `404` Not Found → `ErrorResponse`

#### PUT /api/v1/clients/leads/{lead_id}/
- **Summary:** Update Lead
- **Operation ID:** `user_api_v1_clients_update_lead`
- **Description:** Update lead details
- **Auth Required:** Yes
- **Parameters:**
  - `lead_id` (path, required, integer)
- **Request Body (application/json):** `UpdateLeadRequest`
  - Fields:
    - `email`: any
    - `first_name`: any
    - `last_name`: any
    - `gender`: any
    - `marital_status`: any
    - `address`: any
    - `phone_number`: any
    - `profile_picture`: any
    - `source`: any
    - `status`: any
    - `company_name`: any
    - `interested_services`: any
    - `assigned_to_id`: any
    - `notes`: any
- **Responses:**
  - `200` OK → `LeadResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### DELETE /api/v1/clients/leads/{lead_id}/
- **Summary:** Delete Lead
- **Operation ID:** `user_api_v1_clients_delete_lead`
- **Description:** Delete a lead
- **Auth Required:** Yes
- **Parameters:**
  - `lead_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `404` Not Found → `ErrorResponse`

#### POST /api/v1/clients/leads/{lead_id}/convert-to-client/
- **Summary:** Convert Lead To Client
- **Operation ID:** `user_api_v1_clients_convert_lead_to_client`
- **Auth Required:** Yes
- **Parameters:**
  - `lead_id` (path, required, integer)
- **Responses:**
  - `201` Created → `ClientResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`


### Company

#### GET /api/v1/company/company-settings
- **Summary:** Get Company Settings
- **Operation ID:** `user_api_v1_company_get_company_settings`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `CompanySettingsSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/company/company-settings
- **Summary:** Update Company Settings
- **Operation ID:** `user_api_v1_company_update_company_settings`
- **Auth Required:** Yes
- **Request Body (application/json):** `CompanySettingsUpdateSchema`
  - Fields:
    - `company_name`: any
    - `company_email`: any
    - `company_phone`: any
    - `company_addresses`: any
    - `company_logo`: any
    - `rc_number`: any
    - `primary_color_code`: any
    - `secondary_color_code`: any
    - `company_slogan`: any
    - `default_currency`: any
    - `language_preference`: any
    - `business_rules`: any
- **Responses:**
  - `200` OK → `CompanySettingsSchema`
  - `400` Bad Request → `MessageSchema`


### Compliance

#### GET /api/v1/compliance/compliance-records
- **Summary:** List Compliance Records
- **Operation ID:** `user_api_v1_compliance_list_compliance_records`
- **Auth Required:** Yes
- **Parameters:**
  - `date_from` (query, optional, any)
  - `date_to` (query, optional, any)
  - `compliance_type` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedComplianceRecordSchema`

#### POST /api/v1/compliance/compliance-records
- **Summary:** Create Compliance Record
- **Operation ID:** `user_api_v1_compliance_create_compliance_record`
- **Auth Required:** Yes
- **Request Body (application/json):** `ComplianceRecordCreateSchema`
  - Fields:
    - `full_name`: string *(required)*
    - `email_address`: string *(required)*
    - `phone_number`: string *(required)*
    - `department_id`: integer *(required)*
    - `compliance_type`: string *(required)*
    - `reference_number`: any *(required)*
    - `date_of_issue`: string *(required)*
    - `expiry_date`: string *(required)*
    - `issuing_authority`: string *(required)*
    - `status`: string *(required)*
    - `description`: any
    - `contact_person`: any *(required)*
    - `contact_email`: any *(required)*
    - `cost`: any *(required)*
    - `priority_level`: any *(required)*
    - `documents`: array *(required)*
- **Responses:**
  - `201` Created → `ComplianceRecordSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/compliance/compliance-records/{record_id}
- **Summary:** Get Compliance Record
- **Operation ID:** `user_api_v1_compliance_get_compliance_record`
- **Auth Required:** Yes
- **Parameters:**
  - `record_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ComplianceRecordSchema`

#### PUT /api/v1/compliance/compliance-records/{record_id}
- **Summary:** Update Compliance Record
- **Operation ID:** `user_api_v1_compliance_update_compliance_record`
- **Auth Required:** Yes
- **Parameters:**
  - `record_id` (path, required, integer)
- **Request Body (application/json):** `ComplianceRecordUpdateSchema`
  - Fields:
    - `full_name`: any *(required)*
    - `email_address`: any *(required)*
    - `phone_number`: any *(required)*
    - `department_id`: any *(required)*
    - `compliance_type`: any *(required)*
    - `reference_number`: any *(required)*
    - `date_of_issue`: any
    - `expiry_date`: any
    - `issuing_authority`: any *(required)*
    - `status`: any *(required)*
    - `description`: any
    - `contact_person`: any *(required)*
    - `contact_email`: any *(required)*
    - `cost`: any *(required)*
    - `priority_level`: any *(required)*
    - `documents`: array *(required)*
- **Responses:**
  - `200` OK → `ComplianceRecordSchema`
  - `404` Not Found → `MessageSchema`
  - `400` Bad Request → `MessageSchema`

#### DELETE /api/v1/compliance/compliance-records/{record_id}
- **Summary:** Delete Compliance Record
- **Operation ID:** `user_api_v1_compliance_delete_compliance_record`
- **Auth Required:** Yes
- **Parameters:**
  - `record_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Employees

#### GET /api/v1/employees/department
- **Summary:** List Departments
- **Operation ID:** `user_api_v1_employee_list_departments`
- **Auth Required:** Yes
- **Parameters:**
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedDepartmentOutSchema`

#### POST /api/v1/employees/department
- **Summary:** Create Department
- **Operation ID:** `user_api_v1_employee_create_department`
- **Auth Required:** Yes
- **Request Body (application/json):** `DepartmentInSchema`
  - Fields:
    - `name`: string *(required)*
    - `description`: string *(required)*
- **Responses:**
  - `201` Created → `DepartmentOutSchema`
  - `400` Bad Request → `MessageSchema`

#### PUT /api/v1/employees/department/{department_id}
- **Summary:** Update Department
- **Operation ID:** `user_api_v1_employee_update_department`
- **Auth Required:** Yes
- **Parameters:**
  - `department_id` (path, required, integer)
- **Request Body (application/json):** `DepartmentInSchema`
  - Fields:
    - `name`: string *(required)*
    - `description`: string *(required)*
- **Responses:**
  - `200` OK → `DepartmentOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/employees/employee-levels
- **Summary:** List Employee Levels
- **Operation ID:** `user_api_v1_employee_list_employee_levels`
- **Auth Required:** Yes
- **Parameters:**
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedEmployeeLevelsOutSchema`

#### POST /api/v1/employees/employees
- **Summary:** Create Employee
- **Operation ID:** `user_api_v1_employee_create_employee`
- **Auth Required:** Yes
- **Request Body (application/json):** `EmployeeCreateSchema`
  - Fields:
    - `email`: string *(required)*
    - `password`: any
    - `first_name`: string *(required)*
    - `last_name`: string *(required)*
    - `gender`: string
    - `marital_status`: string
    - `phone_number`: any
    - `date_of_birth`: any
    - `address`: string
    - `profile_picture`: any
    - `employment_type`: string
    - `branch_id`: any
    - `department_id`: any
    - `level_id`: any
    - `start_date`: any
    - `is_active`: boolean
    - `gross_salary`: any
    - `allowances`: any
- **Responses:**
  - `201` Created → `EmployeeOutSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/employees/employees
- **Summary:** List Employees
- **Operation ID:** `user_api_v1_employee_list_employees`
- **Auth Required:** Yes
- **Parameters:**
  - `is_active` (query, optional, boolean)
  - `add_shareholders` (query, optional, boolean)
  - `employment_type` (query, optional, string)
  - `department_id` (query, optional, integer)
  - `branch_id` (query, optional, integer)
  - `search` (query, optional, string)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedEmployeeOutSchema`

#### GET /api/v1/employees/employees/{user_id}
- **Summary:** Get Employee
- **Operation ID:** `user_api_v1_employee_get_employee`
- **Auth Required:** Yes
- **Parameters:**
  - `user_id` (path, required, integer)
- **Responses:**
  - `200` OK → `EmployeeOutSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/employees/employees/{user_id}
- **Summary:** Update Employee
- **Operation ID:** `user_api_v1_employee_update_employee`
- **Auth Required:** Yes
- **Parameters:**
  - `user_id` (path, required, integer)
- **Request Body (application/json):** `EmployeeUpdateSchema`
  - Fields:
    - `first_name`: any
    - `last_name`: any
    - `gender`: any
    - `marital_status`: any
    - `phone_number`: any
    - `date_of_birth`: any
    - `address`: any
    - `profile_picture`: any
    - `employment_type`: any
    - `branch_id`: any
    - `department_id`: any
    - `level_id`: any
    - `start_date`: any
    - `is_active`: any
    - `gross_salary`: any
    - `allowances`: any
- **Responses:**
  - `200` OK → `EmployeeOutSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### GET /api/v1/employees/unit
- **Summary:** List Department Units
- **Operation ID:** `user_api_v1_employee_list_department_units`
- **Auth Required:** Yes
- **Parameters:**
  - `department_id` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedDepartmentUnitOutSchema`

#### POST /api/v1/employees/unit
- **Summary:** Create Department Unit
- **Operation ID:** `user_api_v1_employee_create_department_unit`
- **Auth Required:** Yes
- **Request Body (application/json):** `DepartmentUnitInSchema`
  - Fields:
    - `name`: string *(required)*
    - `description`: any
    - `department_id`: integer *(required)*
- **Responses:**
  - `201` Created → `DepartmentUnitOutSchema`
  - `400` Bad Request → `MessageSchema`

#### PUT /api/v1/employees/unit/{unit_id}
- **Summary:** Update Department Unit
- **Operation ID:** `user_api_v1_employee_update_department_unit`
- **Auth Required:** Yes
- **Parameters:**
  - `unit_id` (path, required, integer)
- **Request Body (application/json):** `DepartmentUnitInSchema`
  - Fields:
    - `name`: string *(required)*
    - `description`: any
    - `department_id`: integer *(required)*
- **Responses:**
  - `200` OK → `DepartmentUnitOutSchema`
  - `400` Bad Request → `MessageSchema`


### Health

#### GET /api/v1/health
- **Summary:** Health Check
- **Operation ID:** `user_api_health_check`
- **Description:** Health check endpoint
- **Auth Required:** No
- **Responses:**
  - `200` OK


### Legal Case Management

#### GET /api/v1/cases/
- **Summary:** List Legal Cases
- **Operation ID:** `user_api_v1_cases_list_legal_cases`
- **Auth Required:** Yes
- **Parameters:**
  - `case_type` (query, optional, any)
  - `status` (query, optional, any)
  - `search` (query, optional, any)
  - `start_date` (query, optional, any)
  - `end_date` (query, optional, any)
  - `has_upcoming_hearing` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedLegalCaseResponse`
  - `400` Bad Request → `ErrorResponse`

#### POST /api/v1/cases/
- **Summary:** Create Legal Case
- **Operation ID:** `user_api_v1_cases_create_legal_case`
- **Auth Required:** Yes
- **Request Body (application/json):** `CreateLegalCaseRequest`
  - Fields:
    - `case_name`: string *(required)*
    - `case_type`: string *(required)*
    - `status`: any
    - `exposure`: any
    - `next_hearing`: any
    - `case_number`: any
    - `description`: any
    - `date_filed`: any
    - `date_closed`: any
- **Responses:**
  - `201` Created → `LegalCaseResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/cases/statistics/overview/
- **Summary:** Get Case Statistics
- **Operation ID:** `user_api_v1_cases_get_case_statistics`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `LegalCaseStatisticsResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/cases/upcoming-hearings/
- **Summary:** Get Upcoming Hearings
- **Operation ID:** `user_api_v1_cases_get_upcoming_hearings`
- **Auth Required:** Yes
- **Parameters:**
  - `days` (query, optional, integer)
- **Responses:**
  - `200` OK
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/cases/{case_id}/
- **Summary:** Get Legal Case
- **Operation ID:** `user_api_v1_cases_get_legal_case`
- **Auth Required:** Yes
- **Parameters:**
  - `case_id` (path, required, integer)
- **Responses:**
  - `200` OK → `LegalCaseResponse`
  - `404` Not Found → `ErrorResponse`

#### PUT /api/v1/cases/{case_id}/
- **Summary:** Update Legal Case
- **Operation ID:** `user_api_v1_cases_update_legal_case`
- **Auth Required:** Yes
- **Parameters:**
  - `case_id` (path, required, integer)
- **Request Body (application/json):** `UpdateLegalCaseRequest`
  - Fields:
    - `case_name`: any
    - `case_type`: any
    - `status`: any
    - `exposure`: any
    - `next_hearing`: any
    - `case_number`: any
    - `description`: any
    - `date_filed`: any
    - `date_closed`: any
- **Responses:**
  - `200` OK → `LegalCaseResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`

#### DELETE /api/v1/cases/{case_id}/
- **Summary:** Delete Legal Case
- **Operation ID:** `user_api_v1_cases_delete_legal_case`
- **Auth Required:** Yes
- **Parameters:**
  - `case_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `404` Not Found → `ErrorResponse`

#### PATCH /api/v1/cases/{case_id}/status/
- **Summary:** Update Case Status
- **Operation ID:** `user_api_v1_cases_update_case_status`
- **Auth Required:** Yes
- **Parameters:**
  - `case_id` (path, required, integer)
  - `status` (query, required, string)
- **Responses:**
  - `200` OK → `LegalCaseResponse`
  - `400` Bad Request → `ErrorResponse`
  - `404` Not Found → `ErrorResponse`


### Meetings

#### GET /api/v1/meetings/
- **Summary:** List Meetings
- **Operation ID:** `user_api_v1_meeting_list_meetings`
- **Auth Required:** Yes
- **Parameters:**
  - `status` (query, optional, any)
  - `location_type` (query, optional, any)
  - `date_from` (query, optional, any)
  - `date_to` (query, optional, any)
  - `my_meetings` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedMeetingSchema`

#### POST /api/v1/meetings/
- **Summary:** Create Meeting
- **Operation ID:** `user_api_v1_meeting_create_meeting`
- **Auth Required:** Yes
- **Request Body (application/json):** `MeetingCreateSchema`
  - Fields:
    - `title`: string *(required)*
    - `agenda`: string *(required)*
    - `meeting_date`: string *(required)*
    - `meeting_time`: string *(required)*
    - `duration_minutes`: integer *(required)*
    - `status`: string
    - `location_type`: string
    - `location`: any
    - `attendee_ids`: array
    - `notes`: any
- **Responses:**
  - `201` Created → `MeetingSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/meetings/choices
- **Summary:** Get Meeting Choices
- **Operation ID:** `user_api_v1_meeting_get_meeting_choices`
- **Auth Required:** No
- **Responses:**
  - `200` OK → `MeetingChoicesSchema`

#### GET /api/v1/meetings/{meeting_id}
- **Summary:** Get Meeting
- **Operation ID:** `user_api_v1_meeting_get_meeting`
- **Auth Required:** Yes
- **Parameters:**
  - `meeting_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MeetingSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/meetings/{meeting_id}
- **Summary:** Update Meeting
- **Operation ID:** `user_api_v1_meeting_update_meeting`
- **Auth Required:** Yes
- **Parameters:**
  - `meeting_id` (path, required, integer)
- **Request Body (application/json):** `MeetingUpdateSchema`
  - Fields:
    - `title`: any
    - `agenda`: any
    - `meeting_date`: any
    - `meeting_time`: any
    - `duration_minutes`: any
    - `status`: any
    - `location_type`: any
    - `location`: any
    - `attendee_ids`: any
    - `notes`: any
- **Responses:**
  - `200` OK → `MeetingSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/meetings/{meeting_id}
- **Summary:** Cancel Meeting
- **Operation ID:** `user_api_v1_meeting_cancel_meeting`
- **Auth Required:** Yes
- **Parameters:**
  - `meeting_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Policies

#### GET /api/v1/policies/
- **Summary:** List Policies
- **Operation ID:** `user_api_v1_policy_list_policies`
- **Auth Required:** Yes
- **Parameters:**
  - `category` (query, optional, any)
  - `status` (query, optional, any)
  - `department_id` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedPolicySchema`

#### POST /api/v1/policies/
- **Summary:** Create Policy
- **Operation ID:** `user_api_v1_policy_create_policy`
- **Auth Required:** Yes
- **Request Body (application/json):** `PolicyCreateSchema`
  - Fields:
    - `title`: string *(required)*
    - `category`: string *(required)*
    - `content`: string *(required)*
    - `version`: string
    - `status`: string
    - `effective_date`: string *(required)*
    - `review_date`: any
    - `department_ids`: array
    - `attachment_url`: any
- **Responses:**
  - `201` Created → `PolicySchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/policies/choices
- **Summary:** Get Policy Choices
- **Operation ID:** `user_api_v1_policy_get_policy_choices`
- **Auth Required:** No
- **Responses:**
  - `200` OK → `PolicyChoicesSchema`

#### GET /api/v1/policies/{policy_id}
- **Summary:** Get Policy
- **Operation ID:** `user_api_v1_policy_get_policy`
- **Auth Required:** Yes
- **Parameters:**
  - `policy_id` (path, required, integer)
- **Responses:**
  - `200` OK → `PolicySchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/policies/{policy_id}
- **Summary:** Update Policy
- **Operation ID:** `user_api_v1_policy_update_policy`
- **Auth Required:** Yes
- **Parameters:**
  - `policy_id` (path, required, integer)
- **Request Body (application/json):** `PolicyUpdateSchema`
  - Fields:
    - `title`: any
    - `category`: any
    - `content`: any
    - `version`: any
    - `status`: any
    - `effective_date`: any
    - `review_date`: any
    - `department_ids`: any
    - `attachment_url`: any
- **Responses:**
  - `200` OK → `PolicySchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`

#### DELETE /api/v1/policies/{policy_id}
- **Summary:** Archive Policy
- **Operation ID:** `user_api_v1_policy_archive_policy`
- **Auth Required:** Yes
- **Parameters:**
  - `policy_id` (path, required, integer)
- **Responses:**
  - `200` OK → `MessageSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Shareholders / Board

#### GET /api/v1/shareholders/
- **Summary:** List Shareholders
- **Operation ID:** `user_api_v1_shareholder_list_shareholders`
- **Auth Required:** Yes
- **Parameters:**
  - `is_active` (query, optional, any)
  - `is_board_member` (query, optional, any)
  - `title` (query, optional, any)
  - `search` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedShareholderSchema`

#### POST /api/v1/shareholders/
- **Summary:** Create Shareholder
- **Operation ID:** `user_api_v1_shareholder_create_shareholder`
- **Auth Required:** Yes
- **Request Body (application/json):** `ShareholderCreateSchema`
  - Fields:
    - `email`: string *(required)*
    - `password`: any
    - `first_name`: string *(required)*
    - `last_name`: string *(required)*
    - `gender`: string
    - `marital_status`: string
    - `phone_number`: any
    - `date_of_birth`: any
    - `address`: string
    - `profile_picture`: any
    - `title`: string
    - `share_percentage`: any *(required)*
    - `share_count`: any
    - `is_board_member`: boolean
    - `is_active`: boolean
    - `notes`: any
- **Responses:**
  - `201` Created → `ShareholderSchema`
  - `400` Bad Request → `MessageSchema`

#### GET /api/v1/shareholders/summary
- **Summary:** Get Shareholder Summary
- **Operation ID:** `user_api_v1_shareholder_get_shareholder_summary`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `ShareholderSummarySchema`

#### GET /api/v1/shareholders/{shareholder_id}
- **Summary:** Get Shareholder
- **Operation ID:** `user_api_v1_shareholder_get_shareholder`
- **Auth Required:** Yes
- **Parameters:**
  - `shareholder_id` (path, required, integer)
- **Responses:**
  - `200` OK → `ShareholderSchema`
  - `404` Not Found → `MessageSchema`

#### PUT /api/v1/shareholders/{shareholder_id}
- **Summary:** Update Shareholder
- **Operation ID:** `user_api_v1_shareholder_update_shareholder`
- **Auth Required:** Yes
- **Parameters:**
  - `shareholder_id` (path, required, integer)
- **Request Body (application/json):** `ShareholderUpdateSchema`
  - Fields:
    - `first_name`: any
    - `last_name`: any
    - `gender`: any
    - `marital_status`: any
    - `phone_number`: any
    - `date_of_birth`: any
    - `address`: any
    - `profile_picture`: any
    - `title`: any
    - `share_percentage`: any
    - `share_count`: any
    - `is_board_member`: any
    - `is_active`: any
    - `notes`: any
- **Responses:**
  - `200` OK → `ShareholderSchema`
  - `400` Bad Request → `MessageSchema`
  - `404` Not Found → `MessageSchema`


### Stats

#### GET /api/v1/stats/dashboard
- **Summary:** Get Dashboard Stats
- **Operation ID:** `user_api_v1_stats_get_dashboard_stats`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `DashboardStatsSchema`


### Upload

#### POST /api/v1/others/upload-file
- **Summary:** Upload File
- **Operation ID:** `user_api_v1_others_upload_file`
- **Auth Required:** Yes
- **Responses:**
  - `200` OK → `FileUploadResponseSchema`
  - `400` Bad Request → `MessageSchema`


### Wallet Management

#### GET /api/v1/wallet/balance/{user_id}/
- **Summary:** Get Wallet Balance
- **Operation ID:** `user_api_v1_wallet_get_wallet_balance`
- **Auth Required:** Yes
- **Parameters:**
  - `user_id` (path, required, integer)
- **Responses:**
  - `200` OK → `WalletBalanceResponse`
  - `404` Not Found → `ErrorResponse`

#### POST /api/v1/wallet/fund-wallet-webhook/
- **Summary:** Fund Wallet Webhook
- **Operation ID:** `user_api_v1_wallet_fund_wallet_webhook`
- **Auth Required:** No
- **Responses:**
  - `200` OK

#### GET /api/v1/wallet/transactions/
- **Summary:** List Transactions
- **Operation ID:** `user_api_v1_wallet_list_transactions`
- **Auth Required:** Yes
- **Parameters:**
  - `user_id` (query, optional, any)
  - `transaction_type` (query, optional, any)
  - `status` (query, optional, any)
  - `start_date` (query, optional, any)
  - `end_date` (query, optional, any)
  - `limit` (query, optional, integer)
  - `offset` (query, optional, integer)
- **Responses:**
  - `200` OK → `PagedTransactionResponse`
  - `400` Bad Request → `ErrorResponse`

#### GET /api/v1/wallet/transactions/{transaction_id}/
- **Summary:** Get Transaction
- **Operation ID:** `user_api_v1_wallet_get_transaction`
- **Description:** Get transaction details by ID
- **Auth Required:** Yes
- **Parameters:**
  - `transaction_id` (path, required, integer)
- **Responses:**
  - `200` OK → `TransactionResponse`
  - `404` Not Found → `ErrorResponse`


## Schemas

### AnnouncementBranchSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `branch_name` | string | Yes |  |
| `branch_id` | string | Yes |  |

### AnnouncementChoicesSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `announcement_types` | array | Yes |  |
| `priorities` | array | Yes |  |

### AnnouncementCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `content` | string | Yes |  |
| `announcement_type` | string | No |  |
| `priority` | string | No |  |
| `branch_ids` | array | No |  |
| `department_ids` | array | No |  |
| `is_active` | boolean | No |  |
| `publish_at` | string | null | No |  |
| `expires_at` | string | null | No |  |

### AnnouncementDepartmentSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |

### AnnouncementSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `announcement_id` | string | Yes |  |
| `title` | string | Yes |  |
| `content` | string | Yes |  |
| `announcement_type` | string | Yes |  |
| `announcement_type_display` | string | Yes |  |
| `priority` | string | Yes |  |
| `priority_display` | string | Yes |  |
| `branches` | array | Yes |  |
| `departments` | array | Yes |  |
| `targets_all_branches` | boolean | Yes |  |
| `targets_all_departments` | boolean | Yes |  |
| `created_by_id` | integer | null | No |  |
| `created_by_name` | string | null | No |  |
| `is_active` | boolean | Yes |  |
| `publish_at` | string | null | No |  |
| `expires_at` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### AnnouncementUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | null | No |  |
| `content` | string | null | No |  |
| `announcement_type` | string | null | No |  |
| `priority` | string | null | No |  |
| `branch_ids` | array | null | No |  |
| `department_ids` | array | null | No |  |
| `is_active` | boolean | null | No |  |
| `publish_at` | string | null | No |  |
| `expires_at` | string | null | No |  |

### ApprovalActionSchema
_Payload for approve / reject endpoints._

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment` | string | null | No |  |

### ApprovalDecisionSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `step_order` | integer | Yes |  |
| `step_name` | string | Yes |  |
| `decision` | string | Yes |  |
| `decision_display` | string | Yes |  |
| `comment` | string | null | No |  |
| `approver_id` | integer | null | No |  |
| `approver_name` | string | null | No |  |
| `created_at` | string | Yes |  |

### ApprovalFlowChoicesSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action_types` | array | Yes |  |

### ApprovalFlowCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `action_type` | string | Yes |  |
| `steps` | array | Yes |  |

### ApprovalFlowSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `action_type` | string | Yes |  |
| `action_type_display` | string | Yes |  |
| `is_active` | boolean | Yes |  |
| `steps` | array | Yes |  |
| `created_by_id` | integer | null | No |  |
| `created_by_name` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### ApprovalFlowStepInputSchema
_One step definition when creating / updating a flow._

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `step_order` | integer | Yes |  |
| `step_name` | string | Yes |  |
| `required_level` | string | Yes |  |

### ApprovalFlowStepSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `step_order` | integer | Yes |  |
| `step_name` | string | Yes |  |
| `required_level` | string | Yes |  |
| `required_level_display` | string | Yes |  |

### ApprovalFlowUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | null | No |  |
| `description` | string | null | No |  |
| `action_type` | string | null | No |  |
| `is_active` | boolean | null | No |  |
| `steps` | array | null | No |  |

### ApprovalRequestCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `flow_id` | integer | Yes |  |
| `title` | string | Yes |  |
| `description` | string | Yes |  |
| `metadata` | object | null | No |  |

### ApprovalRequestSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `approval_request_id` | string | Yes |  |
| `flow_id` | integer | Yes |  |
| `flow_name` | string | Yes |  |
| `action_type` | string | Yes |  |
| `action_type_display` | string | Yes |  |
| `title` | string | Yes |  |
| `description` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `current_step` | integer | Yes |  |
| `total_steps` | integer | Yes |  |
| `pending_step_name` | string | null | No |  |
| `pending_step_required_level` | string | null | No |  |
| `pending_step_required_level_display` | string | null | No |  |
| `decisions` | array | Yes |  |
| `metadata` | object | null | No |  |
| `created_by_id` | integer | null | No |  |
| `created_by_name` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### AttendanceRecordResponse
_Single attendance record_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `attendance_type` | string | Yes |  |
| `timestamp` | string | Yes |  |
| `verification_method` | string | Yes |  |
| `notes` | string | Yes |  |

### AuditLogResponse
_Schema for a single audit log entry_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `activity` | string | Yes |  |
| `audit_type` | string | Yes |  |
| `audit_type_display` | string | Yes |  |
| `audit_status` | string | Yes |  |
| `audit_status_display` | string | Yes |  |
| `ip_address` | string | null | No |  |
| `metadata` | object | null | No |  |
| `user` | UserInfo | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### AuditPerformanceTrendsResponse
_Response schema for audit performance trends_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `period` | string | Yes |  |
| `trends` | array | Yes |  |
| `overall_improvement` | number | null | Yes |  |

### AuditResponse
_Response schema for audit details_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `audit_name` | string | Yes |  |
| `audit_type` | string | Yes |  |
| `audit_type_display` | string | Yes |  |
| `auditor_name` | string | Yes |  |
| `auditor_title` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `score` | integer | null | Yes |  |
| `score_percentage` | string | Yes |  |
| `is_passed` | boolean | null | Yes |  |
| `score_category` | string | Yes |  |
| `audit_date` | string | Yes |  |
| `audit_number` | string | null | Yes |  |
| `description` | string | Yes |  |
| `findings` | string | Yes |  |
| `recommendations` | string | Yes |  |
| `start_date` | string | null | Yes |  |
| `end_date` | string | null | Yes |  |
| `auditor_organization` | string | Yes |  |
| `department` | string | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### AuditStatisticsResponse
_Response schema for audit statistics_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_audits` | integer | Yes |  |
| `completed_audits` | integer | Yes |  |
| `in_progress_audits` | integer | Yes |  |
| `scheduled_audits` | integer | Yes |  |
| `cancelled_audits` | integer | Yes |  |
| `failed_audits` | integer | Yes |  |
| `average_score` | number | null | Yes |  |
| `pass_rate` | number | null | Yes |  |
| `audits_by_type` | object | Yes |  |
| `audits_by_score_category` | object | Yes |  |
| `upcoming_audits_count` | integer | Yes |  |

### AuditorSummaryResponse
_Response schema for auditor summary_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `auditor_name` | string | Yes |  |
| `auditor_title` | string | Yes |  |
| `auditor_organization` | string | Yes |  |
| `total_audits` | integer | Yes |  |
| `average_score` | number | null | Yes |  |
| `audits_conducted` | array | Yes |  |

### BiometricClockInRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_data` | string | Yes |  |
| `biometric_type` | string | Yes |  |
| `attendance_type` | string | Yes |  |

### BiometricClockInResponse
_Response after successful biometric clock-in/out_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `employee_id` | integer | Yes |  |
| `employee_name` | string | Yes |  |
| `attendance_type` | string | Yes |  |
| `timestamp` | string | Yes |  |

### BiometricLoginRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `biometric_data` | string | Yes |  |
| `biometric_type` | string | Yes |  |

### BiometricSetupResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_enabled` | boolean | Yes |  |

### BiometricStatusResponse
_Check biometric status for current user_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_enabled` | boolean | Yes |  |
| `has_fingerprint` | boolean | Yes |  |
| `has_face` | boolean | Yes |  |

### BoardCompositionSchema
_Schema for per-title breakdown in summary_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `title_display` | string | Yes |  |
| `count` | integer | Yes |  |

### BoardResolutionChoicesSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `types` | array | Yes |  |
| `statuses` | array | Yes |  |

### BoardResolutionCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `description` | string | Yes |  |
| `resolution_type` | string | Yes |  |
| `resolution_date` | string | Yes |  |
| `status` | string | null | No |  |
| `attachment_url` | string | null | No |  |
| `notes` | string | null | No |  |

### BoardResolutionSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `resolution_id` | string | Yes |  |
| `title` | string | Yes |  |
| `description` | string | Yes |  |
| `resolution_type` | string | Yes |  |
| `resolution_type_display` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `resolution_date` | string | Yes |  |
| `attachment_url` | string | null | No |  |
| `notes` | string | null | No |  |
| `created_by_id` | integer | null | No |  |
| `created_by_name` | string | null | No |  |
| `approved_by_id` | integer | null | No |  |
| `approved_by_name` | string | null | No |  |
| `approved_at` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### BoardResolutionUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | null | No |  |
| `description` | string | null | No |  |
| `resolution_type` | string | null | No |  |
| `resolution_date` | string | null | No |  |
| `status` | string | null | No |  |
| `attachment_url` | string | null | No |  |
| `notes` | string | null | No |  |

### BranchChoicesSchema
_Schema for branch choice fields_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `operational_status` | array | Yes |  |
| `branch_role` | array | Yes |  |

### BranchCreateSchema
_Schema for creating a branch_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branch_name` | string | Yes |  |
| `branch_id` | string | null | No |  |
| `default_currency` | string | null | No |  |
| `language_preference` | string | null | No |  |
| `country_id` | integer | Yes |  |
| `state_id` | integer | Yes |  |
| `lga` | string | null | No |  |
| `office_address` | string | Yes |  |
| `operational_status` | string | No |  |
| `branch_role` | string | No |  |
| `contact_email` | string | Yes |  |
| `contact_phone` | string | Yes |  |
| `manager_id` | integer | null | No |  |
| `branch_file` | string | null | No |  |
| `notes` | string | null | No |  |
| `business_hours` | array | null | No |  |

### BranchDetailsSchema
_Schema for branch detail information_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branch_name` | string | Yes |  |
| `location` | string | Yes |  |
| `status` | string | Yes |  |
| `revenue` | string | Yes |  |
| `revenue_percentage` | string | Yes |  |
| `employees` | integer | Yes |  |
| `employee_productivity` | string | Yes |  |
| `projects` | integer | Yes |  |
| `active_projects` | integer | Yes |  |
| `customer_satisfaction_percentage` | string | Yes |  |
| `customer_count` | integer | Yes |  |

### BranchPerformanceAnalysisSchema
_Schema for complete branch performance analysis_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `metrics` | BranchPerformanceMetricsSchema | Yes |  |
| `key_insights` | array | Yes |  |
| `revenue_trend` | array | Yes |  |
| `branch_details` | BranchDetailsSchema | Yes |  |

### BranchPerformanceMetricsSchema
_Schema for top-level performance metrics_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `revenue_generated` | string | Yes |  |
| `operational_efficiency` | string | Yes |  |
| `customer_satisfaction` | string | Yes |  |
| `total_employees` | integer | Yes |  |

### BranchSchema
_Schema for branch response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `branch_name` | string | Yes |  |
| `branch_id` | string | Yes |  |
| `default_currency` | string | null | No |  |
| `language_preference` | string | null | No |  |
| `country_id` | integer | Yes |  |
| `country_name` | string | Yes |  |
| `state_id` | integer | Yes |  |
| `state_name` | string | Yes |  |
| `lga` | string | null | No |  |
| `office_address` | string | Yes |  |
| `full_address` | string | Yes |  |
| `operational_status` | string | Yes |  |
| `operational_status_display` | string | Yes |  |
| `branch_role` | string | Yes |  |
| `branch_role_display` | string | Yes |  |
| `contact_email` | string | Yes |  |
| `contact_phone` | string | Yes |  |
| `manager_id` | integer | null | No |  |
| `manager_name` | string | null | No |  |
| `branch_file` | string | null | No |  |
| `is_active` | boolean | Yes |  |
| `is_operational` | boolean | Yes |  |
| `notes` | string | null | No |  |
| `business_hours` | array | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### BranchUpdateSchema
_Schema for updating a branch_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `branch_name` | string | null | No |  |
| `default_currency` | string | null | No |  |
| `language_preference` | string | null | No |  |
| `country_id` | integer | null | No |  |
| `state_id` | integer | null | No |  |
| `lga` | string | null | No |  |
| `office_address` | string | null | No |  |
| `operational_status` | string | null | No |  |
| `branch_role` | string | null | No |  |
| `contact_email` | string | null | No |  |
| `contact_phone` | string | null | No |  |
| `manager_id` | integer | null | No |  |
| `branch_file` | string | null | No |  |
| `is_active` | boolean | null | No |  |
| `notes` | string | null | No |  |
| `business_hours` | array | null | No |  |

### BusinessHoursInputSchema
_Schema for creating/updating a single day's business hours_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `day_of_week` | integer | Yes |  |
| `open_time` | string | null | No |  |
| `close_time` | string | null | No |  |
| `is_open` | boolean | No |  |

### BusinessHoursSchema
_Schema for business hours response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `day_of_week` | integer | Yes |  |
| `day_name` | string | Yes |  |
| `open_time` | string | null | No |  |
| `close_time` | string | null | No |  |
| `is_open` | boolean | Yes |  |

### ChoiceSchema
_Schema for choice options_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `value` | string | Yes |  |
| `label` | string | Yes |  |

### ClientResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `user_id` | integer | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `email` | string | Yes |  |
| `profile_picture` | string | null | No |  |
| `address` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `gender` | string | null | No |  |
| `balance` | number | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### CompanySettingsSchema
_Schema for company settings response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `company_name` | string | Yes |  |
| `company_email` | string | Yes |  |
| `company_phone` | string | Yes |  |
| `company_addresses` | string | Yes |  |
| `company_logo` | string | null | No |  |
| `rc_number` | string | Yes |  |
| `primary_color_code` | string | Yes |  |
| `secondary_color_code` | string | Yes |  |
| `company_slogan` | string | null | No |  |
| `default_currency` | string | Yes |  |
| `language_preference` | string | Yes |  |
| `business_rules` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### CompanySettingsUpdateSchema
_Schema for updating company settings_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `company_name` | string | null | No |  |
| `company_email` | string | null | No |  |
| `company_phone` | string | null | No |  |
| `company_addresses` | string | null | No |  |
| `company_logo` | string | null | No |  |
| `rc_number` | string | null | No |  |
| `primary_color_code` | string | null | No |  |
| `secondary_color_code` | string | null | No |  |
| `company_slogan` | string | null | No |  |
| `default_currency` | string | null | No |  |
| `language_preference` | string | null | No |  |
| `business_rules` | string | null | No |  |

### ComplianceRecordCreateSchema
_Schema for creating a compliance record_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `full_name` | string | Yes |  |
| `email_address` | string | Yes |  |
| `phone_number` | string | Yes |  |
| `department_id` | integer | Yes |  |
| `compliance_type` | string | Yes |  |
| `reference_number` | string | null | Yes |  |
| `date_of_issue` | string | Yes |  |
| `expiry_date` | string | Yes |  |
| `issuing_authority` | string | Yes |  |
| `status` | string | Yes |  |
| `description` | string | null | No |  |
| `contact_person` | string | null | Yes |  |
| `contact_email` | string | null | Yes |  |
| `cost` | number | string | null | Yes |  |
| `priority_level` | string | null | Yes |  |
| `documents` | array | Yes |  |

### ComplianceRecordSchema
_Schema for compliance record response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `full_name` | string | Yes |  |
| `email_address` | string | Yes |  |
| `phone_number` | string | Yes |  |
| `department_id` | integer | Yes |  |
| `compliance_type` | string | Yes |  |
| `reference_number` | string | null | Yes |  |
| `date_of_issue` | string | Yes |  |
| `expiry_date` | string | Yes |  |
| `issuing_authority` | string | Yes |  |
| `status` | string | Yes |  |
| `description` | string | null | Yes |  |
| `contact_person` | string | null | Yes |  |
| `contact_email` | string | null | Yes |  |
| `cost` | number | string | null | Yes |  |
| `priority_level` | string | null | Yes |  |
| `is_expired` | boolean | Yes |  |
| `days_until_expiry` | integer | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |
| `documents` | array | Yes |  |

### ComplianceRecordUpdateSchema
_Schema for updating a compliance record (all fields optional)_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `full_name` | string | null | Yes |  |
| `email_address` | string | null | Yes |  |
| `phone_number` | string | null | Yes |  |
| `department_id` | integer | null | Yes |  |
| `compliance_type` | string | null | Yes |  |
| `reference_number` | string | null | Yes |  |
| `date_of_issue` | string | null | No |  |
| `expiry_date` | string | null | No |  |
| `issuing_authority` | string | null | Yes |  |
| `status` | string | null | Yes |  |
| `description` | string | null | No |  |
| `contact_person` | string | null | Yes |  |
| `contact_email` | string | null | Yes |  |
| `cost` | number | string | null | Yes |  |
| `priority_level` | string | null | Yes |  |
| `documents` | array | Yes |  |

### CountrySchema
_Schema for country response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |
| `code` | string | Yes |  |
| `is_active` | boolean | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### CreateAuditRequest
_Request schema for creating a new audit_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `audit_name` | string | Yes |  |
| `audit_type` | string | Yes |  |
| `auditor_name` | string | Yes |  |
| `auditor_title` | string | null | No |  |
| `status` | string | null | No |  |
| `score` | integer | null | No |  |
| `audit_date` | string | Yes |  |
| `audit_number` | string | null | No |  |
| `description` | string | null | No |  |
| `findings` | string | null | No |  |
| `recommendations` | string | null | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |
| `auditor_organization` | string | null | No |  |
| `department` | string | null | No |  |

### CreateClientRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `phone_number` | string | Yes |  |

### CreateInventoryItemRequest
_Schema for creating a new inventory item_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `item_name` | string | Yes |  |
| `quantity` | number | string | Yes |  |
| `quantity_used` | number | string | null | No |  |
| `unit` | string | Yes |  |
| `total_value` | number | string | Yes |  |
| `status` | string | Yes |  |

### CreateLeadRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `gender` | string | null | No |  |
| `marital_status` | string | null | No |  |
| `address` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `profile_picture` | string | null | No |  |
| `source` | string | null | No |  |
| `status` | string | null | No |  |
| `company_name` | string | null | No |  |
| `interested_services` | string | Yes |  |
| `assigned_to_id` | integer | null | No |  |
| `notes` | string | null | No |  |

### CreateLegalCaseRequest
_Request schema for creating a new legal case_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `case_name` | string | Yes |  |
| `case_type` | string | Yes |  |
| `status` | string | null | No |  |
| `exposure` | number | string | null | No |  |
| `next_hearing` | string | null | No |  |
| `case_number` | string | null | No |  |
| `description` | string | null | No |  |
| `date_filed` | string | null | No |  |
| `date_closed` | string | null | No |  |

### DashboardStatsSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_employees` | integer | Yes |  |
| `new_employees_count` | integer | Yes |  |
| `total_branches` | integer | Yes |  |
| `removed_branches_count` | integer | Yes |  |
| `pending_approvals` | integer | Yes |  |
| `overdue_tasks_count` | integer | Yes |  |
| `asset_inventory` | integer | Yes |  |
| `new_inventory_count` | integer | Yes |  |

### DepartmentInSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes |  |
| `description` | string | Yes |  |

### DepartmentOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |

### DepartmentUnitInSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `department_id` | integer | Yes |  |

### DepartmentUnitOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |
| `description` | string | null | No |  |
| `department_id` | integer | Yes |  |

### EmployeeCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `password` | string | null | No |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `gender` | string | No |  |
| `marital_status` | string | No |  |
| `phone_number` | string | null | No |  |
| `date_of_birth` | string | null | No |  |
| `address` | string | No |  |
| `profile_picture` | string | null | No |  |
| `employment_type` | string | No |  |
| `branch_id` | integer | null | No |  |
| `department_id` | integer | null | No |  |
| `level_id` | integer | null | No |  |
| `start_date` | string | null | No |  |
| `is_active` | boolean | No |  |
| `gross_salary` | number | string | null | No |  |
| `allowances` | object | null | No |  |

### EmployeeLevelsOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `level` | string | Yes |  |

### EmployeeOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | integer | Yes |  |
| `username` | string | Yes |  |
| `email` | string | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `gender` | string | Yes |  |
| `marital_status` | string | Yes |  |
| `phone_number` | string | null | No |  |
| `date_of_birth` | string | null | No |  |
| `address` | string | Yes |  |
| `profile_picture` | string | null | No |  |
| `is_verified` | boolean | Yes |  |
| `is_active` | boolean | Yes |  |
| `id` | integer | Yes |  |
| `employee_id` | string | Yes |  |
| `employment_type` | string | Yes |  |
| `branch_id` | integer | null | No |  |
| `branch_name` | string | null | No |  |
| `department_id` | integer | null | No |  |
| `department_name` | string | null | No |  |
| `level_id` | integer | null | No |  |
| `employee_level` | string | null | No |  |
| `start_date` | string | null | No |  |
| `gross_salary` | number | string | null | No |  |
| `allowances` | object | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### EmployeeUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `first_name` | string | null | No |  |
| `last_name` | string | null | No |  |
| `gender` | string | null | No |  |
| `marital_status` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `date_of_birth` | string | null | No |  |
| `address` | string | null | No |  |
| `profile_picture` | string | null | No |  |
| `employment_type` | string | null | No |  |
| `branch_id` | integer | null | No |  |
| `department_id` | integer | null | No |  |
| `level_id` | integer | null | No |  |
| `start_date` | string | null | No |  |
| `is_active` | boolean | null | No |  |
| `gross_salary` | number | string | null | No |  |
| `allowances` | object | null | No |  |

### ErrorResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `detail` | string | Yes |  |

### FileUploadResponseSchema
_Schema for file upload response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | Yes |  |

### ForgotPasswordRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |

### ForgotPasswordResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `detail` | string | No |  |

### Input

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `limit` | integer | No |  |
| `offset` | integer | No |  |

### InventoryItemResponse
_Schema for inventory item response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `item_name` | string | Yes |  |
| `quantity` | number | string | Yes |  |
| `quantity_used` | number | string | Yes |  |
| `unit` | string | Yes |  |
| `unit_display` | string | Yes |  |
| `total_value` | number | string | Yes |  |
| `formatted_value` | string | Yes |  |
| `unit_price` | number | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `is_low_stock` | boolean | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### KeyInsightSchema
_Schema for individual key insight_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `value` | string | Yes |  |
| `status` | string | Yes |  |
| `recommendation` | string | Yes |  |

### LeadResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `email` | string | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `gender` | string | Yes |  |
| `marital_status` | string | Yes |  |
| `address` | string | Yes |  |
| `phone_number` | string | null | Yes |  |
| `profile_picture` | string | null | Yes |  |
| `source` | string | Yes |  |
| `status` | string | Yes |  |
| `company_name` | string | null | Yes |  |
| `interested_services` | string | Yes |  |
| `assigned_to_name` | string | null | Yes |  |
| `notes` | string | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### LegalCaseResponse
_Response schema for legal case details_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `case_name` | string | Yes |  |
| `case_type` | string | Yes |  |
| `case_type_display` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `exposure` | number | string | null | Yes |  |
| `next_hearing` | string | null | Yes |  |
| `case_number` | string | null | Yes |  |
| `description` | string | Yes |  |
| `date_filed` | string | null | Yes |  |
| `date_closed` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### LegalCaseStatisticsResponse
_Response schema for legal case statistics_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_cases` | integer | Yes |  |
| `open_cases` | integer | Yes |  |
| `in_progress_cases` | integer | Yes |  |
| `settled_cases` | integer | Yes |  |
| `closed_cases` | integer | Yes |  |
| `won_cases` | integer | Yes |  |
| `lost_cases` | integer | Yes |  |
| `dismissed_cases` | integer | Yes |  |
| `pending_cases` | integer | Yes |  |
| `total_exposure` | number | string | Yes |  |
| `upcoming_hearings` | integer | Yes |  |
| `cases_by_type` | object | Yes |  |

### LoginRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `password` | string | Yes |  |

### LoginResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `access_token` | string | Yes |  |
| `refresh_token` | string | Yes |  |
| `user_id` | integer | Yes |  |
| `detail` | string | No |  |

### LogoutResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `detail` | string | No |  |

### MeetingAttendeeSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | integer | Yes |  |
| `full_name` | string | Yes |  |
| `email` | string | Yes |  |

### MeetingChoicesSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `statuses` | array | Yes |  |
| `location_types` | array | Yes |  |

### MeetingCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `agenda` | string | Yes |  |
| `meeting_date` | string | Yes |  |
| `meeting_time` | string | Yes |  |
| `duration_minutes` | integer | Yes |  |
| `status` | string | No |  |
| `location_type` | string | No |  |
| `location` | string | null | No |  |
| `attendee_ids` | array | No |  |
| `notes` | string | null | No |  |

### MeetingSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `meeting_id` | string | Yes |  |
| `title` | string | Yes |  |
| `agenda` | string | Yes |  |
| `meeting_date` | string | Yes |  |
| `meeting_time` | string | Yes |  |
| `duration_minutes` | integer | Yes |  |
| `duration_display` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `location_type` | string | Yes |  |
| `location_type_display` | string | Yes |  |
| `location` | string | null | No |  |
| `attendees` | array | Yes |  |
| `attendee_count` | integer | Yes |  |
| `organizer_id` | integer | null | No |  |
| `organizer_name` | string | null | No |  |
| `notes` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### MeetingUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | null | No |  |
| `agenda` | string | null | No |  |
| `meeting_date` | string | null | No |  |
| `meeting_time` | string | null | No |  |
| `duration_minutes` | integer | null | No |  |
| `status` | string | null | No |  |
| `location_type` | string | null | No |  |
| `location` | string | null | No |  |
| `attendee_ids` | array | null | No |  |
| `notes` | string | null | No |  |

### MessageSchema
_Schema for success/error messages_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `detail` | string | Yes |  |

### PagedAnnouncementSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedApprovalFlowSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedApprovalRequestSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedAuditLogResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedAuditResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedAuditorSummaryResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedBoardResolutionSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedBranchSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedClientResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedComplianceRecordSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedCountrySchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedDepartmentOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedDepartmentUnitOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedEmployeeLevelsOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedEmployeeOutSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedInventoryItemResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedLeadResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedLegalCaseResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedMeetingSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedPolicySchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedShareholderSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedStateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PagedTransactionResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `items` | array | Yes |  |
| `count` | integer | Yes |  |

### PolicyChoicesSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `categories` | array | Yes |  |
| `statuses` | array | Yes |  |

### PolicyCreateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes |  |
| `category` | string | Yes |  |
| `content` | string | Yes |  |
| `version` | string | No |  |
| `status` | string | No |  |
| `effective_date` | string | Yes |  |
| `review_date` | string | null | No |  |
| `department_ids` | array | No |  |
| `attachment_url` | string | null | No |  |

### PolicyDepartmentSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `name` | string | Yes |  |

### PolicySchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `policy_id` | string | Yes |  |
| `title` | string | Yes |  |
| `category` | string | Yes |  |
| `category_display` | string | Yes |  |
| `content` | string | Yes |  |
| `version` | string | Yes |  |
| `status` | string | Yes |  |
| `status_display` | string | Yes |  |
| `effective_date` | string | Yes |  |
| `review_date` | string | null | No |  |
| `departments` | array | Yes |  |
| `applies_to_all_departments` | boolean | Yes |  |
| `attachment_url` | string | null | No |  |
| `created_by_id` | integer | null | No |  |
| `created_by_name` | string | null | No |  |
| `last_updated_by_id` | integer | null | No |  |
| `last_updated_by_name` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### PolicyUpdateSchema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | null | No |  |
| `category` | string | null | No |  |
| `content` | string | null | No |  |
| `version` | string | null | No |  |
| `status` | string | null | No |  |
| `effective_date` | string | null | No |  |
| `review_date` | string | null | No |  |
| `department_ids` | array | null | No |  |
| `attachment_url` | string | null | No |  |

### RefreshTokenRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `refresh_token` | string | Yes |  |

### RefreshTokenResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `access_token` | string | Yes |  |
| `detail` | string | No |  |

### RemoveBiometricRequest
_Remove biometric data_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_type` | string | Yes |  |

### ResetPasswordRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `code` | string | Yes |  |
| `new_password` | string | Yes |  |

### ResetPasswordResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `detail` | string | No |  |

### RevenueTrendPointSchema
_Schema for revenue trend data point_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `month` | string | Yes |  |
| `actual_revenue` | number | Yes |  |
| `projected_revenue` | number | Yes |  |

### SetupFaceRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_data` | string | Yes |  |

### SetupFingerprintRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `biometric_data` | string | Yes |  |

### ShareholderCreateSchema
_Schema for creating a shareholder / board member_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes |  |
| `password` | string | null | No |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `gender` | string | No |  |
| `marital_status` | string | No |  |
| `phone_number` | string | null | No |  |
| `date_of_birth` | string | null | No |  |
| `address` | string | No |  |
| `profile_picture` | string | null | No |  |
| `title` | string | No |  |
| `share_percentage` | number | string | Yes |  |
| `share_count` | integer | null | No |  |
| `is_board_member` | boolean | No |  |
| `is_active` | boolean | No |  |
| `notes` | string | null | No |  |

### ShareholderSchema
_Schema for shareholder response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `shareholder_id` | string | Yes |  |
| `user_id` | integer | Yes |  |
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `email` | string | Yes |  |
| `phone_number` | string | null | No |  |
| `profile_picture` | string | null | No |  |
| `title` | string | Yes |  |
| `title_display` | string | Yes |  |
| `share_percentage` | number | string | Yes |  |
| `share_count` | integer | null | No |  |
| `is_board_member` | boolean | Yes |  |
| `is_active` | boolean | Yes |  |
| `notes` | string | null | No |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### ShareholderSummarySchema
_Schema for shareholder summary/overview_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_shareholders` | integer | Yes |  |
| `active_shareholders` | integer | Yes |  |
| `total_share_percentage` | number | string | Yes |  |
| `unallocated_percentage` | number | string | Yes |  |
| `board_composition` | array | Yes |  |

### ShareholderUpdateSchema
_Schema for updating a shareholder / board member_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `first_name` | string | null | No |  |
| `last_name` | string | null | No |  |
| `gender` | string | null | No |  |
| `marital_status` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `date_of_birth` | string | null | No |  |
| `address` | string | null | No |  |
| `profile_picture` | string | null | No |  |
| `title` | string | null | No |  |
| `share_percentage` | number | string | null | No |  |
| `share_count` | integer | null | No |  |
| `is_board_member` | boolean | null | No |  |
| `is_active` | boolean | null | No |  |
| `notes` | string | null | No |  |

### StateSchema
_Schema for state response_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `country_id` | integer | Yes |  |
| `country_name` | string | Yes |  |
| `name` | string | Yes |  |
| `code` | string | null | No |  |
| `is_active` | boolean | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### TransactionResponse
_Response schema for transaction details_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `user_id` | integer | Yes |  |
| `user_full_name` | string | Yes |  |
| `user_email` | string | Yes |  |
| `date` | string | Yes |  |
| `description` | string | Yes |  |
| `amount` | number | string | Yes |  |
| `transaction_type` | string | Yes |  |
| `status` | string | Yes |  |
| `reference` | string | null | Yes |  |
| `created_at` | string | Yes |  |
| `updated_at` | string | Yes |  |

### UpdateAuditRequest
_Request schema for updating an audit_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `audit_name` | string | null | No |  |
| `audit_type` | string | null | No |  |
| `auditor_name` | string | null | No |  |
| `auditor_title` | string | null | No |  |
| `status` | string | null | No |  |
| `score` | integer | null | No |  |
| `audit_date` | string | null | No |  |
| `audit_number` | string | null | No |  |
| `description` | string | null | No |  |
| `findings` | string | null | No |  |
| `recommendations` | string | null | No |  |
| `start_date` | string | null | No |  |
| `end_date` | string | null | No |  |
| `auditor_organization` | string | null | No |  |
| `department` | string | null | No |  |

### UpdateAuditScoreRequest
_Request schema for updating audit score_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `score` | integer | Yes |  |

### UpdateAuditStatusRequest
_Request schema for updating audit status_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | Yes |  |

### UpdateClientRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `first_name` | string | Yes |  |
| `last_name` | string | Yes |  |
| `email` | string | Yes |  |
| `profile_picture` | string | null | No |  |
| `address` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `gender` | string | null | No |  |

### UpdateInventoryItemRequest
_Schema for updating an inventory item_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `item_name` | string | null | No |  |
| `quantity` | number | string | null | No |  |
| `quantity_used` | number | string | null | No |  |
| `unit` | string | null | No |  |
| `total_value` | number | string | null | No |  |
| `status` | string | null | No |  |

### UpdateLeadRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | null | No |  |
| `first_name` | string | null | No |  |
| `last_name` | string | null | No |  |
| `gender` | string | null | No |  |
| `marital_status` | string | null | No |  |
| `address` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `profile_picture` | string | null | No |  |
| `source` | string | null | No |  |
| `status` | string | null | No |  |
| `company_name` | string | null | No |  |
| `interested_services` | string | null | No |  |
| `assigned_to_id` | integer | null | No |  |
| `notes` | string | null | No |  |

### UpdateLegalCaseRequest
_Request schema for updating a legal case_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `case_name` | string | null | No |  |
| `case_type` | string | null | No |  |
| `status` | string | null | No |  |
| `exposure` | number | string | null | No |  |
| `next_hearing` | string | null | No |  |
| `case_number` | string | null | No |  |
| `description` | string | null | No |  |
| `date_filed` | string | null | No |  |
| `date_closed` | string | null | No |  |

### UserInfo
_User information for audit log entries_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | null | No |  |
| `email` | string | null | No |  |
| `full_name` | string | null | No |  |

### UserResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | Yes |  |
| `email` | string | Yes |  |
| `username` | string | Yes |  |
| `first_name` | string | null | No |  |
| `last_name` | string | null | No |  |
| `phone_number` | string | null | No |  |
| `is_verified` | boolean | Yes |  |
| `created_at` | string | Yes |  |

### VerifyTokenResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | No |  |
| `valid` | boolean | Yes |  |
| `user_id` | integer | null | No |  |
| `detail` | string | No |  |

### WalletBalanceResponse
_Response schema for wallet balance_

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | integer | Yes |  |
| `user_full_name` | string | Yes |  |
| `total_credits` | number | string | Yes |  |
| `total_debits` | number | string | Yes |  |
| `current_balance` | number | string | Yes |  |
| `pending_transactions` | integer | Yes |  |
| `completed_transactions` | integer | Yes |  |
| `last_transaction_date` | string | null | Yes |  |
