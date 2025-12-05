# 🏍️ MotoRiders App

> **La red social definitiva para la comunidad motociclista.**
> *Conectando máquinas y pilotos a través de tecnología de alto rendimiento.*

![Status](https://img.shields.io/badge/Status-In%20Development-red) ![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B) ![Style](https://img.shields.io/badge/Style-Glassmorphism-black)

## 💡 Sobre el Proyecto

**MotoRiders** no es solo otra app de mapas; es un ecosistema completo diseñado para cubrir el vacío tecnológico en el mundo del motociclismo.

A diferencia de las redes sociales genéricas, MotoRiders está arquitecturada pensando en las necesidades específicas del nicho: gestión jerárquica de clubes (MCs), fichas técnicas de modificaciones ("Mods"), y privacidad en ruta.

Diseñada con una estética **"Tesla-Minimalist"** y un modo oscuro profundo inspirado en la estética underground/G59.

## 🚀 Características Principales (Core Features)

### 🛠️ El Garage (Perfil Técnico)
* **Ficha de Identidad:** Visualización inmersiva de la motocicleta.
* **Build Tracker:** Registro detallado de modificaciones (escapes, wraps, performance) con validación de comunidad.
* **Multi-Bike Support:** Gestión de múltiples máquinas por usuario.

### 📡 Radar Táctico (Mapas)
* **Integración Google Maps SDK:** Visualización personalizada en modo oscuro (Night Mode).
* **POIs Moteros:** Filtros para talleres, puntos de reunión y gasolineras.
* **Privacidad Dinámica:** El usuario decide cuándo es visible en el radar.

### 🛡️ Gestión de Clubes (MCs)
* **Sistema Jerárquico:** Roles granulares totalmente personalizables (Presidente, Capitán de Ruta, Miembro, Prospecto).
* **Comunicación Dual:** Canales separados para Chat (rápido) y Muro/Feed (anuncios oficiales).
* **Permisos ACL:** Control estricto de quién puede invitar, expulsar o gestionar rodadas.

## 🛠️ Stack Tecnológico

* **Frontend:** Flutter (Dart) - *Para una experiencia nativa fluida a 60fps.*
* **Arquitectura:** Clean Architecture + Provider/Riverpod (State Management).
* **Mapas:** Google Maps Platform (Android SDK).
* **Backend (En progreso):** Firebase / Google Cloud Platform.
* **Diseño:** Custom UI System con Glassmorphism y animaciones físicas.

## 📸 Capturas de Pantalla (Preview)

| Garage (Perfil) | Radar (Mapa) | Feed Social |
|:---:|:---:|:---:|
| *[Inserta aquí tu captura del perfil]* | *[Inserta aquí tu captura del mapa]* | *[Inserta aquí tu captura del feed]* |

## 🔧 Instalación y Desarrollo

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/tu-usuario/motoriders-app.git](https://github.com/tu-usuario/motoriders-app.git)
    ```
2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Configuración de Entorno:**
    * Añadir `API_KEY` de Google Maps en `android/app/src/main/AndroidManifest.xml`.
4.  **Ejecutar:**
    ```bash
    flutter run
    ```

---
*Developed with 💀 & 🏍️ by [Tu Nombre/Alias]*
