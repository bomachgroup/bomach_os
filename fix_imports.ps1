$files = Get-ChildItem -Path lib, test -Recurse -Filter *.dart
$searchToken = "ApiConstants"
$importLine = "import 'package:bomach_os/src/constants/api_constants.dart';"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -like "*$searchToken*") {
        # Add import if missing
        if ($content -notlike "*$importLine*") {
            # Try to add after the first import line, or at the top
            if ($content -match "import '") {
                $content = $content -replace "(import '.*?;)", "`$1`r`n$importLine"
            } elseif ($content -match "import `".*?`";") {
                $content = $content -replace "(import `".*?`";)", "`$1`r`n$importLine"
            } else {
                $content = "$importLine`r`n$content"
            }
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Added import to $($file.FullName)"
        }
    }
}
