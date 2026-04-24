import json
import os

spec_path = r"C:\Users\ukaeg\.gemini\antigravity\brain\2a1683fb-7c0f-4e79-97a3-12d822079550\.system_generated\steps\5420\content.md"

with open(spec_path, 'r', encoding='utf-8') as f:
    content = f.read()
    # Find the start of the JSON
    json_start = content.find('{')
    json_content = content[json_start:]
    spec = json.loads(json_content)

relevant_schemas = [
    "DashboardStatsSchema",
    "LegalCaseStatisticsResponse",
    "AuditStatisticsResponse",
    "CompanyProfileSchema",
    "ShareholderSummarySchema",
    "EmployeeOutSchema",
    "EstateSchema"
]

results = {}
for schema_name in relevant_schemas:
    if schema_name in spec.get("components", {}).get("schemas", {}):
        results[schema_name] = spec["components"]["schemas"][schema_name]
    else:
        results[schema_name] = "NOT FOUND"

# Also check paths
relevant_paths = [
    "/api/v1/stats/dashboard",
    "/api/v1/dashboard/stats",
    "/api/v1/company/company/profile",
    "/api/v1/cases/statistics/overview/",
    "/api/v1/audits/statistics/overview/",
    "/api/v1/shareholders/summary",
    "/api/v1/employees/employees"
]

path_results = {}
for path in relevant_paths:
    if path in spec.get("paths", {}):
        path_results[path] = spec["paths"][path]
    else:
        path_results[path] = "NOT FOUND"

print(json.dumps({"schemas": results, "paths": path_results}, indent=2))
