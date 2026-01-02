Add-Type -AssemblyName System.Drawing

$iconPath = "C:\Users\pexel\OneDrive\Desktop\SixV_2025_FxServer\txData\ESXLegacy_0F8EEB.base\six_icons\inventory"
$files = Get-ChildItem -Path $iconPath -Filter "*.png"

foreach ($file in $files) {
    $fullPath = $file.FullName

    # Load image
    $img = [System.Drawing.Image]::FromFile($fullPath)
    $currentWidth = $img.Width
    $currentHeight = $img.Height

    Write-Host "Processing: $($file.Name) - Current size: ${currentWidth}x${currentHeight}"

    # Create new 512x512 image
    $newImg = New-Object System.Drawing.Bitmap(512, 512)
    $graphics = [System.Drawing.Graphics]::FromImage($newImg)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Draw resized image
    $graphics.DrawImage($img, 0, 0, 512, 512)

    # Dispose old image
    $img.Dispose()
    $graphics.Dispose()

    # Determine new filename (lowercase for weapons)
    $newName = $file.Name
    $shouldRename = $false
    if ($file.Name -like "WEAPON_*" -or $file.Name -like "weapon_*" -or $file.Name -like "Weapon_*") {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name).ToLower()
        $newName = "$baseName.png"
        $shouldRename = $true
    }

    # Save with temporary name if renaming to avoid conflicts
    if ($shouldRename) {
        $tempPath = Join-Path $iconPath "temp_$($file.Name)"
        $newImg.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $newImg.Dispose()

        # Delete original and rename temp
        Remove-Item $fullPath -Force
        $newPath = Join-Path $iconPath $newName
        Move-Item $tempPath $newPath -Force
        Write-Host "Renamed: $($file.Name) -> $newName"
    } else {
        $newPath = Join-Path $iconPath $newName
        $newImg.Save($newPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $newImg.Dispose()
    }

    Write-Host "Resized to 512x512: $newName"
}

Write-Host "Done! All icons resized to 512x512 and weapon names converted to lowercase."
