# 1. Release the Git index lock if it was orphaned by the abort
if (Test-Path .git\index.lock) { Remove-Item .git\index.lock -Force }

# 2. Scan the repository and output folder file counts from highest to lowest
Get-ChildItem -Directory | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
    [PSCustomObject]@{
        DirectoryName = $_.Name
        FileCount = (Get-ChildItem -Path $_.FullName -File -Recurse -ErrorAction SilentlyContinue).Count
    }
} | Sort-Object FileCount -Descending | Format-Table -AutoSize