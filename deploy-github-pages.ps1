# Script de Deployment para GitHub Pages

# Configuración automática de GitHub Pages para KalunBot
# Ejecutar en PowerShell desde la carpeta del proyecto

Write-Host "🚀 Configurando KalunBot Website para GitHub Pages..." -ForegroundColor Green

# Verificar que estamos en la carpeta correcta
if (!(Test-Path "website\index.html")) {
    Write-Host "❌ Error: No se encuentra el archivo website\index.html" -ForegroundColor Red
    Write-Host "   Ejecuta este script desde la carpeta raíz del proyecto (FUTBIN-BOT)" -ForegroundColor Yellow
    exit 1
}

# Crear repositorio Git si no existe
if (!(Test-Path ".git")) {
    Write-Host "📁 Inicializando repositorio Git..." -ForegroundColor Yellow
    git init
}

# Verificar archivos necesarios
$requiredFiles = @(
    "website\index.html",
    "website\terminos.html", 
    "website\privacidad.html",
    "website\disclaimer.html",
    "website\guia-instalacion.html",
    "website\sitemap.xml",
    "website\robots.txt",
    "website\manifest.json"
)

Write-Host "📋 Verificando archivos necesarios..." -ForegroundColor Yellow
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file - FALTA" -ForegroundColor Red
    }
}

# Crear branch gh-pages si no existe
$currentBranch = git branch --show-current
if ($currentBranch -ne "gh-pages") {
    Write-Host "🌿 Creando branch gh-pages..." -ForegroundColor Yellow
    git checkout -b gh-pages 2>$null
    if ($LASTEXITCODE -ne 0) {
        git checkout gh-pages
    }
}

# Limpiar archivos innecesarios para GitHub Pages
Write-Host "🧹 Limpiando archivos innecesarios..." -ForegroundColor Yellow

# Crear .gitignore específico para GitHub Pages
@"
# Archivos Python innecesarios para la web
*.py
*.pyc
__pycache__/
*.pyo
*.pyd
.Python
env/
venv/
.env

# Archivos de desarrollo
backups/
dist/
*.iss
*.log
.vscode/
.idea/

# Archivos temporales
*.tmp
*.temp
*~

# Solo mantener archivos web
!website/
!website/*
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Copiar archivos web a la raíz para GitHub Pages
Write-Host "📁 Copiando archivos web a la raíz..." -ForegroundColor Yellow
Copy-Item "website\*" -Destination "." -Recurse -Force

# Crear CNAME si se especifica dominio personalizado
if ($args[0]) {
    Write-Host "🌐 Configurando dominio personalizado: $($args[0])" -ForegroundColor Yellow
    $args[0] | Out-File -FilePath "CNAME" -Encoding ASCII -NoNewline
}

# Crear archivo README para GitHub
@"
# KalunBot Website

Sitio web oficial de KalunBot - El bot de sniping #1 para EA FC 25

🌐 **Website**: https://$(if($args[0]){$args[0]}else{"tu-usuario.github.io/kalunbot"})

## 🚀 Características

- Bot de sniping automático para EA FC 25
- Interfaz intuitiva y fácil de usar
- Actualizaciones regulares
- Soporte completo en Discord

## 📥 Descarga

Descarga la última versión desde nuestro [sitio web oficial](https://$(if($args[0]){$args[0]}else{"tu-usuario.github.io/kalunbot"})).

## 🛡️ Disclaimer

⚠️ **Importante**: El uso de bots puede violar los términos de servicio de EA FC 25. 
Usa bajo tu propio riesgo. Lee nuestro [disclaimer](disclaimer.html) completo.

## 📞 Soporte

- 💬 [Discord](https://discord.gg/tu-servidor)
- 📧 Email: soporte@kalunbot.com
- ⭐ [TrustPilot](https://www.trustpilot.com/review/tu-dominio.com)

---
© 2025 KalunBot. Todos los derechos reservados.
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Actualizar URLs en los archivos si se proporciona dominio
if ($args[0]) {
    Write-Host "🔄 Actualizando URLs con dominio personalizado..." -ForegroundColor Yellow
    
    $files = Get-ChildItem -Filter "*.html"
    foreach ($file in $files) {
        (Get-Content $file.FullName) -replace "https://tu-dominio.com", "https://$($args[0])" | Set-Content $file.FullName
    }
    
    (Get-Content "sitemap.xml") -replace "https://tu-dominio.com", "https://$($args[0])" | Set-Content "sitemap.xml"
    (Get-Content "robots.txt") -replace "https://tu-dominio.com", "https://$($args[0])" | Set-Content "robots.txt"
}

# Agregar archivos a Git
Write-Host "📦 Agregando archivos a Git..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "💾 Haciendo commit..." -ForegroundColor Yellow
git commit -m "Deploy KalunBot website to GitHub Pages - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

Write-Host "`n✅ Configuración completa!" -ForegroundColor Green
Write-Host "`n📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Sube el código a GitHub:" -ForegroundColor White
Write-Host "   git remote add origin https://github.com/TU-USUARIO/TU-REPOSITORIO.git" -ForegroundColor Gray
Write-Host "   git push -u origin gh-pages" -ForegroundColor Gray
Write-Host "`n2. Configura GitHub Pages:" -ForegroundColor White
Write-Host "   - Ve a Settings → Pages en tu repositorio" -ForegroundColor Gray
Write-Host "   - Selecciona 'Deploy from a branch'" -ForegroundColor Gray
Write-Host "   - Elige 'gh-pages' branch y '/ (root)'" -ForegroundColor Gray

if ($args[0]) {
    Write-Host "`n3. Tu sitio estará disponible en: https://$($args[0])" -ForegroundColor Green
} else {
    Write-Host "`n3. Tu sitio estará disponible en: https://TU-USUARIO.github.io/TU-REPOSITORIO" -ForegroundColor Green
}

Write-Host "`n4. Personaliza los archivos:" -ForegroundColor White
Write-Host "   - Actualiza enlaces de Discord, email, etc." -ForegroundColor Gray
Write-Host "   - Configura Google Analytics" -ForegroundColor Gray
Write-Host "   - Crea cuenta en TrustPilot" -ForegroundColor Gray

Write-Host "`n🎉 ¡Tu sitio web está listo para desplegar!" -ForegroundColor Green
