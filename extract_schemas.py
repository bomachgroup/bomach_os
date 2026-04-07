import json
import os

file_path = r'C:\Users\ukaeg\.gemini\antigravity\brain\4d393282-4ef7-43cf-b0ab-19023c31b9d4\.system_generated\steps\286\content.md'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# The content starts with "Source: ... \n\n---\n\n"
json_str = content.split('---')[-1].strip()
data = json.loads(json_str)

schemas_to_extract = [
    "TwoFactorRequiredResponse", 
    "TwoFactorVerifyRequest", 
    "TwoFactorVerifyResponse", 
    "BiometricLoginRequest", 
    "BiometricClockInRequest", 
    "SetupFaceRequest",
    "LoginResponse"
]

extracted = {}
components = data.get('components', {}).get('schemas', {})

for s in schemas_to_extract:
    extracted[s] = components.get(s, "Not found")

print(json.dumps(extracted, indent=2))
