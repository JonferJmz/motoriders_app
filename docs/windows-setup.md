# Configuración y solución de problemas para Windows

Este documento muestra los pasos para instalar y configurar las herramientas necesarias para compilar y ejecutar la aplicación Flutter en Windows (desktop).

## Resumen del problema

Si durante `flutter run -d windows` ves un error como:

```
CMake Error at CMakeLists.txt:3 (project):
  No CMAKE_CXX_COMPILER could be found.

Error: Unable to generate build files
```

Significa que Flutter no pudo localizar una herramienta de compilación de C++ compatible (MSVC) en tu sistema. Para compilar aplicaciones de Windows, Flutter necesita el compilador MSVC (cl.exe), Windows SDK y el soporte de C++ en la instalación de Visual Studio.

## Pasos recomendados para corregirlo

1) Ejecuta `flutter doctor -v` para obtener un diagnóstico y ver exactamente qué falta. Usa PowerShell en la carpeta raíz del proyecto:

```powershell
flutter doctor -v
```

2) Si falta el compilador C++ o Visual Studio, instala Visual Studio 2019/2022 (Community o Build Tools) o actualiza la instalación existente. Recomendación mínima: instala la carga de trabajo "Desktop development with C++" (Desarrollo de escritorio con C++).

- Abre el "Visual Studio Installer".
- Marca la carga de trabajo: **Desktop development with C++**.
- En la sección de componentes individuales, asegúrate de incluir:
  - MSVC (Visual C++ toolset) - la versión compatible (p. ej. v142/v143)
  - Windows 10/11 SDK (p. ej. 10.0.x)
  - C++ CMake tools for Windows
  - MSBuild

3) Usando Visual Studio Build Tools:

Si instalaste la versión **Build Tools** (sin IDE) debes incluir las mismas cargas de trabajo/compontes (C++ build tools y Windows SDK). Uno de los errores habituales es instalar solo "Build Tools" sin los componentes de C++.

4) Verifica que `cl.exe` (el compilador de MSVC) esté en la PATH o a través del Developer Command Prompt. En PowerShell comprueba:

```powershell
where cl
```

Si no aparece, abre el "Developer Command Prompt for VS" (o ejecuta `vcvarsall.bat`) o reinicia para que la instalación agregue los binarios al entorno.

5) Comprueba que `vswhere.exe` encuentre tu instalación de Visual Studio (esto ayuda a Flutter a detectar Visual Studio):

```powershell
"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json
```

Si no devuelve nada, la instalación de C++ no fue detectada.

6) Flutter no tiene la opción `--visual-studio-path` ni `--windows-desktop-path` en `flutter config`. Por eso verás: "Could not find an option named --visual-studio-path". En lugar de eso, debes:

- Instalar Visual Studio y los componentes adecuados
- Ejecutar `flutter doctor` para forzar la detección

7) Después de instalar/actualizar Visual Studio, reinicia tu equipo (o al menos cierra-reabre terminales y VSCode) y vuelve a ejecutar:

```powershell
flutter clean
flutter doctor -v
flutter run -d windows
```

8) Sobre la eliminación de `.dart_tool` o la carpeta `build`:

Si al ejecutar `flutter clean` falla al eliminar `.dart_tool`, probablemente hay un proceso en uso (p. ej. `dart` o un análisis en VSCode). Cierra el IDE y termina procesos de Dart/Flutter/Analyzer:

```powershell
Get-Process dart, dart.exe -ErrorAction SilentlyContinue | Stop-Process -Force
```

O reinicia tu PC si no estás seguro.

## Alternativas de ejecución

Si por rapidez no deseas aún configurar Visual Studio, puedes ejecutar la aplicación en:

- Chrome (web) - `flutter run -d chrome`
- Edge (web) - `flutter run -d edge`
- Android / iOS simuladores (si tiene SDKs configurados)

## Ejemplo de comandos útiles

```powershell
# Diagnóstico
flutter doctor -v
# Forzar reconfiguración y limpiar
flutter clean
# Ejecutar en windows
flutter run -d windows
# (Si no compilara) verificar compilador cl.exe
where cl
# Use vswhere para revisar la instalación
"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json | ConvertFrom-Json
```

## Nota sobre permisos y PATH

No es necesario añadir la ruta de Visual Studio a `PATH` manualmente si instalaste Visual Studio con las cargas de trabajo correspondientes, `vswhere` y Visual Studio instalador deberían permitir que Flutter lo detecte.

Si tras la instalación de la carga de trabajo aún tienes errores, comparte el resultado de `flutter doctor -v` y los outputs de los comandos anteriores para diagnosticar la detección.

---

Si quieres, puedo agregar estos pasos a `README.md` y crear un archivo de documentación dentro del proyecto para que cualquiera que clone el repo pueda arreglar el problema de Windows rápidamente.
