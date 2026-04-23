
$modernized = @(
    "lib\pages\services\service_leads.dart",
    "lib\pages\services\services_calculator.dart",
    "lib\pages\services\payment_approval.dart",
    "lib\pages\services\estate_detail_page.dart",
    "lib\pages\services\services.dart",
    "lib\pages\services\widget\view_performance_invoice_dialog.dart",
    "lib\pages\services\widget\add_performance_invoice_dialog.dart",
    "lib\pages\services\widget\add_invoice_dialog.dart",
    "lib\components\text\app_text.dart"
)

$files = Get-ChildItem -Recurse -Filter *.dart -Path "e:\Bomach Projects\Bomach OS\bomach_os\lib"
foreach ($file in $files) {
    $relative = $file.FullName.Substring("e:\Bomach Projects\Bomach OS\bomach_os\".Length)
    if ($modernized -contains $relative) {
        Write-Host "Skipping modernized file: $relative"
        continue
    }
    
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content.Contains("AppText.")) {
        Write-Host "Updating file: $relative"
        $newContent = $content.Replace("AppText.", "AppTextStyles.")
        [System.IO.File]::WriteAllText($file.FullName, $newContent)
    }
}
