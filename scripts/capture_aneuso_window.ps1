# Capture the ANEUSO Flutter window as PNG.
# Usage: .\scripts\capture_aneuso_window.ps1 -Name "01_login"
param(
  [Parameter(Mandatory = $true)]
  [string]$Name,
  [string]$OutDir = "docs\manual_screenshots"
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;
public class WinCap {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
  public static void Capture(IntPtr hWnd, string path) {
    RECT r; GetWindowRect(hWnd, out r);
    int w = r.Right - r.Left; int h = r.Bottom - r.Top;
    if (w <= 0 || h <= 0) throw new Exception("Invalid window size");
    SetForegroundWindow(hWnd);
    System.Threading.Thread.Sleep(400);
    using (var bmp = new Bitmap(w, h)) {
      using (var g = Graphics.FromImage(bmp)) {
        g.CopyFromScreen(r.Left, r.Top, 0, 0, new Size(w, h));
      }
      bmp.Save(path, ImageFormat.Png);
    }
  }
}
"@

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$targetDir = Join-Path $root $OutDir
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$proc = Get-Process -Name "aneuso_app" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) {
  Write-Error "aneuso_app is not running. Start with: flutter run -d windows"
  exit 1
}

$outFile = Join-Path $targetDir ("{0}.png" -f $Name)
[WinCap]::Capture($proc.MainWindowHandle, $outFile)
Write-Host "Saved $outFile"
