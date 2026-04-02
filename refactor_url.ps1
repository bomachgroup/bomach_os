$files = Get-ChildItem -Path lib, test -Recurse -Filter *.dart
$searchUrl = "https://bomachauth.bgbot.app"
$importLine = "import 'package:bms_front_end/src/constants/api_constants.dart';"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -like "*$searchUrl*") {
        # Add import if missing
        if ($content -notlike "*$importLine*") {
            if ($content -match "(?m)^import ") {
                $content = $content -replace "(?m)^(import .*;)$", "`$1`r`n$importLine"
            } else {
                $content = "$importLine`r`n$content"
            }
        }
        
        # Replace occurrences
        # Handle /api/v1 suffix first
        $content = $content -replace "'$searchUrl/api/v1'", "'`${ApiConstants.baseUrl}/api/v1'"
        $content = $content -replace "`"$searchUrl/api/v1`"", "`"`${ApiConstants.baseUrl}/api/v1`""
        
        # Handle raw URL
        # For default parameters/assignments, we want to remove quotes if the whole string was just the URL
        $content = $content -replace "'$searchUrl'", "ApiConstants.baseUrl"
        $content = $content -replace "`"$searchUrl`"", "ApiConstants.baseUrl"
        
        # Handle cases where it was part of a larger string but not /api/v1 (though rare based on grep)
        $content = $content -replace "$searchUrl", "`${ApiConstants.baseUrl}"
        
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated $($file.FullName)"
    }
}
