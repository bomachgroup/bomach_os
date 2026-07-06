import json

# Read OpenAPI spec paths
with open('bomach_os_docs.json') as f:
    data = json.load(f)
openapi_paths = set(data.get('paths', {}).keys())

# Read used paths from Flutter codebase (from previous output)
used_paths = {
    '/api/v1/announcements/',
    '/api/v1/announcements/{id}',
    '/api/v1/announcements/choices',
    '/api/v1/approvals/flows',
    '/api/v1/approvals/flows/',
    '/api/v1/approvals/flows/{flow_id}',
    '/api/v1/approvals/flows/choices',
    '/api/v1/approvals/requests',
    '/api/v1/approvals/requests/',
    '/api/v1/approvals/requests/{request_id}',
    '/api/v1/approvals/requests/{request_id}/approve',
    '/api/v1/approvals/requests/{request_id}/reject',
    '/api/v1/assets/',
    '/api/v1/assets/{asset_id}',
    '/api/v1/audit-logs/',
    '/api/v1/audits/',
    '/api/v1/audits/{id}/',
    '/api/v1/audits/{id}/score/',
    '/api/v1/audits/{id}/status/',
    '/api/v1/audits/statistics/overview/',
    '/api/v1/auth/2fa/disable',
    '/api/v1/auth/2fa/enable',
    '/api/v1/auth/2fa/status',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/login',
    '/api/v1/auth/logout',
    '/api/v1/auth/refresh',
    '/api/v1/auth/reset-password',
    '/api/v1/auth/verify-2fa',
    '/api/v1/auth/verify-token',
    '/api/v1/biometric/location/pending',
    '/api/v1/biometric/location/whitelisted',
    '/api/v1/board-resolutions/',
    '/api/v1/board-resolutions/{resolution_id}',
    '/api/v1/board-resolutions/{resolution_id}/approve',
    '/api/v1/board-resolutions/choices',
    '/api/v1/branch/branches',
    '/api/v1/branch/branches/',
    '/api/v1/branch/branches/choices/fields',
    '/api/v1/budgets',
    '/api/v1/budgets/{id}',
    '/api/v1/cases/',
    '/api/v1/cases/{id}/',
    '/api/v1/cases/{id}/status/',
    '/api/v1/cases/statistics/overview/',
    '/api/v1/cases/upcoming-hearings/',
    '/api/v1/clients/clients/',
    '/api/v1/clients/leads/',
    '/api/v1/company/company/branding',
    '/api/v1/company/company/choices',
    '/api/v1/company/company/preferences',
    '/api/v1/company/company/profile',
    '/api/v1/compliance/compliance-records',
    '/api/v1/compliance/compliance-records/',
    '/api/v1/compliance/compliance-records/{id}',
    '/api/v1/contracts',
    '/api/v1/contracts/',
    '/api/v1/dashboard/stats',
    '/api/v1/employees/',
    '/api/v1/employees/department',
    '/api/v1/employees/department/',
    '/api/v1/employees/employees',
    '/api/v1/employees/employees/',
    '/api/v1/employees/reviews/',
    '/api/v1/employees/unit',
    '/api/v1/employees/unit/',
    '/api/v1/estates/',
    '/api/v1/estates/choices/fields',
    '/api/v1/events/',
    '/api/v1/events/{id}',
    '/api/v1/events/{id}/',
    '/api/v1/expenses',
    '/api/v1/expenses/{id}',
    '/api/v1/expenses/{id}/approve',
    '/api/v1/expenses/{id}/reject',
    '/api/v1/invoices',
    '/api/v1/invoices/{id}',
    '/api/v1/meetings/',
    '/api/v1/meetings/{meeting_id}',
    '/api/v1/meetings/choices',
    '/api/v1/milestones',
    '/api/v1/milestones/',
    '/api/v1/others/upload-file',
    '/api/v1/partners/',
    '/api/v1/payments',
    '/api/v1/payments/{id}',
    '/api/v1/projects',
    '/api/v1/projects/',
    '/api/v1/projects/stats',
    '/api/v1/roles/',
    '/api/v1/roles/employees/',
    '/api/v1/roles/permissions-map',
    '/api/v1/shareholders/',
    '/api/v1/shareholders/equity',
    '/api/v1/site-equipment',
    '/api/v1/site-equipment/',
    '/api/v1/stats/dashboard',
    '/api/v1/tasks',
    '/api/v1/tasks/',
    '/api/v1/timelines',
    '/api/v1/timelines/',
    '/api/v1/worksites',
    '/api/v1/worksites/',
}

# Normalize paths - remove trailing slashes for comparison
def normalize(path):
    return path.rstrip('/') if path != '/' else path

openapi_normalized = {normalize(p) for p in openapi_paths}
used_normalized = {normalize(p) for p in used_paths}

# Find unused
unused = openapi_normalized - used_normalized
unused_sorted = sorted(unused)

print(f"Total OpenAPI paths: {len(openapi_normalized)}")
print(f"Used paths: {len(used_normalized)}")
print(f"Unused paths: {len(unused_sorted)}")
print()
print("=== UNUSED API ENDPOINTS ===")
for p in unused_sorted:
    print(p)