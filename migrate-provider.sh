#!/bin/bash

PROVIDER=$1
OLD_DIR="$HOME/Documents/storm-ext/$PROVIDER"
NEW_DIR="$HOME/Documents/mis-providers-cloudstream/$PROVIDER"

if [ -z "$PROVIDER" ]; then
    echo "Uso: ./migrate-provider.sh NombreDelProvider"
    echo "Ejemplo: ./migrate-provider.sh AnimeJlProvider"
    exit 1
fi

if [ ! -d "$OLD_DIR" ]; then
    echo "Error: No existe $OLD_DIR"
    echo "Asegurate de que storm-ext este clonado en ~/Documents/storm-ext"
    exit 1
fi

echo "🔧 Migrando $PROVIDER..."

# Crear estructura
mkdir -p "$NEW_DIR/src/main/kotlin/com/stormunblessed"
mkdir -p "$NEW_DIR/src/main/resources"

# Copiar archivo Kotlin original
cp "$OLD_DIR/src/main/kotlin/com/stormunblessed/"*.kt "$NEW_DIR/src/main/kotlin/com/stormunblessed/"

# Crear build.gradle.kts
cat > "$NEW_DIR/build.gradle.kts" << EOF
version = 1

cloudstream {
    language = "es"
    authors = listOf("DavidAbsenta")
    status = 1
    tvTypes = listOf("Movie", "Anime")
}
EOF

# Crear AndroidManifest.xml (CORRECTO con <manifest simple)
cat > "$NEW_DIR/src/main/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>
EOF

# Arreglar doble < en tipos genericos
KT_FILES=$(find "$NEW_DIR/src/main/kotlin/com/stormunblessed/" -name "*.kt" ! -name "*Plugin.kt")
for KT_FILE in $KT_FILES; do
    echo "  Arreglando $KT_FILE"
    
    # Quitar doble < en tipos genericos
    sed -i 's/<<HomePageList>/<HomePageList>/g' "$KT_FILE"
    sed -i 's/<<SearchResponse>/<SearchResponse>/g' "$KT_FILE"
    sed -i 's/<<Episode>/<Episode>/g' "$KT_FILE"
    sed -i 's/<<SubtitleFile>/<SubtitleFile>/g' "$KT_FILE"
    sed -i 's/<<LoadResponse>/<LoadResponse>/g' "$KT_FILE"
    sed -i 's/<<ExtractorLink>/<ExtractorLink>/g' "$KT_FILE"
    sed -i 's/<<Any>/<Any>/g' "$KT_FILE"
    
    # Reemplazos simples
    sed -i 's/\.apmap\s*{/\.amap {/g' "$KT_FILE"
    sed -i 's/suspendSafeApiCall/safeAsync/g' "$KT_FILE"
    
    # Constructores antiguos -> nuevos (reemplazo simple)
    sed -i 's/\bTvSeriesSearchResponse(/newTvSeriesSearchResponse(/g' "$KT_FILE"
    sed -i 's/\bMovieSearchResponse(/newMovieSearchResponse(/g' "$KT_FILE"
    sed -i 's/\bAnimeSearchResponse(/newAnimeSearchResponse(/g' "$KT_FILE"
    sed -i 's/\bLiveSearchResponse(/newLiveSearchResponse(/g' "$KT_FILE"
    sed -i 's/\bEpisode(/newEpisode(/g' "$KT_FILE"
    sed -i 's/\bExtractorLink(/newExtractorLink(/g' "$KT_FILE"
    sed -i 's/\bHomePageResponse(/newHomePageResponse(/g' "$KT_FILE"
    sed -i 's/\bMovieLoadResponse(/newMovieLoadResponse(/g' "$KT_FILE"
    sed -i 's/\bTvSeriesLoadResponse(/newTvSeriesLoadResponse(/g' "$KT_FILE"
done

# Crear Plugin.kt si no existe
if [ ! -f "$NEW_DIR/src/main/kotlin/com/stormunblessed/${PROVIDER}Plugin.kt" ]; then
    # Buscar nombre de la clase principal
    CLASS_NAME=$(grep -o "class [A-Za-z]*Provider" "$NEW_DIR/src/main/kotlin/com/stormunblessed/"*.kt | grep -v "Plugin" | head -1 | sed 's/class //')
    if [ -z "$CLASS_NAME" ]; then
        CLASS_NAME="${PROVIDER}"
    fi
    
    cat > "$NEW_DIR/src/main/kotlin/com/stormunblessed/${PROVIDER}Plugin.kt" << EOF
package com.stormunblessed

import android.content.Context
import com.lagradost.cloudstream3.plugins.CloudstreamPlugin
import com.lagradost.cloudstream3.plugins.Plugin

@CloudstreamPlugin
class ${PROVIDER}Plugin : Plugin() {
    override fun load(context: Context) {
        registerMainAPI(${CLASS_NAME}())
    }
}
EOF
    echo "✅ Creado ${PROVIDER}Plugin.kt"
fi

echo ""
echo "✅ $PROVIDER migrado!"
echo ""
echo "⚠️  IMPORTANTE: Revisa manualmente el codigo porque:"
echo "   - Los constructores con multiples parametros pueden necesitar"
echo "     conversion a sintaxis de lambda (newEpisode(data) { ... })"
echo "   - Algunos proveedores pueden usar APIs adicionales no cubiertas"
echo ""
echo "🧪 Prueba con: ./gradlew :${PROVIDER}:build"
