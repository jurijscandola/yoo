# Runs a Flutter command for Android from a substituted drive letter.
#
# The Gradle wrapper cannot load its jar when the project path contains "!"
# (Java treats "!" as the jar URL separator), and this project lives in "Yoo!".
# Usage: powershell -File tool/flutter_android.ps1 build apk --debug
#        powershell -File tool/flutter_android.ps1 run
# Plain $args (no param block): a [Parameter] attribute would make PowerShell
# swallow flags such as --debug as its own common parameters.
$flutterArgs = $args

$drive = 'Y:'
$parent = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path "$drive\")) { subst $drive $parent }
Set-Location "$drive\$(Split-Path -Leaf (Split-Path -Parent $PSScriptRoot))"
flutter @flutterArgs
exit $LASTEXITCODE
