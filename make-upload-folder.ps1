# Creates ..\HealthMateAI-upload: a clean copy of the project without node_modules, caches, local database or secrets.
# Use it if you want to upload to GitHub through the website instead of using Git.
$src = $PSScriptRoot
$dst = Join-Path (Split-Path $src -Parent) "HealthMateAI-upload"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
robocopy $src $dst /E /XD node_modules dist data .venv __pycache__ .pytest_cache .git presentation /XF .env *.db *.pyc /NFL /NDL /NJH /NJS | Out-Null
$n = (Get-ChildItem $dst -Recurse -File).Count
Write-Host "Created $dst with $n files."
if ($n -gt 100) { Write-Host "More than 100 files: GitHub's website upload accepts about 100 files at a time, so upload folder by folder, or use Git." }
