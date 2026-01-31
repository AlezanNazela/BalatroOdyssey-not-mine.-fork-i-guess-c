# Chat Conversation

Note: _This is purely the output of the chat conversation and does not contain any raw data, codebase snippets, etc. used to generate the output._

### User Input

# BalatroOdyssey

Expansión masiva para Balatro. Este mod introduce una capa profunda de contenido sistémico, centrada en la diversidad de arquetipos y mecánicas de escalado cuántico.

## 📊 Inventario de Contenido

| Categoría | Prefijo | Cantidad (Assets Únicos) | Descripción |
| :--- | :--- | :--- | :--- |
| **Jokers** | `odyssey_j_` | **1,081** | Clasificados en arquetipos (Anomaly, Celestial, Chaos, Economy, Quantum, Singularity). |
| **Vouchers** | `odyssey_v_` | 200 | Mejoras permanentes de tienda. |
| **Tarots** | `odyssey_tarot_` | 100 | Modificadores de baraja y consumibles. |
| **Spectrals** | `odyssey_spectral_` | 100 | Efectos de alto riesgo/recompensa. |
| **Planets** | `odyssey_planet_` | 100 | Nivelación de manos de póker. |
| **Blinds** | `odyssey_blind_` | 100 | Jefes y desafíos de ciegas personalizados. |

### Desglose de Arquetipos (Jokers)
* **Economy**: 54 assets.
* **Quantum**: 45 assets.
* **Chaos**: 43 assets.
* **Celestial**: 41 assets.
* **Anomaly**: 40 assets.
* **Singularity**: 42 assets.

## 🛠 Arquitectura del Proyecto

* **`BalatroOdyssey.lua`**: Núcleo lógico del mod (1.4MB). Contiene la arquitectura de clases y hooks.
* **`localization/`**: Diccionarios de strings para soporte multi-idioma.
* **`assets/`**: Estructura dual de resoluciones (`1x/` para rendimiento y `2x/` para visualización HD).

## 📝 Reglas de Contribución y Desarrollo

1.  **Nomenclatura**: Las variables, funciones y IDs internos deben usar **`camelCase`** obligatoriamente (ej: `jokerQuantumTrigger`, `applyOdysseyEffect`).
2.  **Assets**: Cada nuevo objeto requiere una textura en `1x` y `2x` siguiendo el prefijo correspondiente.
3.  **Inyecciones**: Cualquier modificación al core del juego debe documentarse en `lovely.toml`.

## ⚙️ Instalación

1. Descargar el repositorio.
2. Mover la carpeta `BalatroOdyssey` a `%AppData%/Balatro/Mods`.
3. Requiere **Steamodded** y el parcheador **Lovely**.
Script de Automatización de MD
He creado este script para que lo ejecutes cada vez que añadas nuevos archivos. Mantendrá tu tabla de assets actualizada automáticamente.

Python

import os

def update_asset_inventory(base_path):
    # Diccionario de categorías detectadas por prefijo
    cats = {
        "jokers": "odyssey_j_", "tarots": "odyssey_tarot_",
        "spectrals": "odyssey_spectral_", "planets": "odyssey_planet_",
        "vouchers": "odyssey_v_", "blinds": "odyssey_blind_"
    }
    
    unique_files = set()
    # Escanear solo 1x para evitar duplicados en el conteo
    path_1x = os.path.join(base_path, 'assets', '1x')
    
    if not os.path.exists(path_1x):
        return "Error: Ruta de assets no encontrada."

    for f in os.listdir(path_1x):
        if f.endswith(".png"):
            unique_files.add(f)

    results = {k: 0 for k in cats}
    for f in unique_files:
        for k, prefix in cats.items():
            if f.startswith(prefix):
                results[k] += 1
                break
                
    return results

# Ejecución: inventory = update_asset_inventory(".")


here is the md for this proyect 

main objective : split the monolith mod into manegable structure of files instead of one massive file

*Listed directory [BalatroOdyssey](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [lovely.toml](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/lovely.toml) *

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Grep searched codebase*

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Grep searched codebase*

*Grep searched codebase*

*Edited relevant file*

### User Input

looks good. we should use it as our instruccions MD

*User accepted the command `mkdir src`*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Grep searched codebase*

*Grep searched codebase*

*Edited relevant file*

*User accepted the command `python split_mod.py`*

*Checked command status*

*Checked command status*

*User accepted the command `py split_mod.py`*

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Viewed [BalatroOdyssey.lua](file:///c:/Users/Administrator/AppData/Roaming/Balatro/Mods/BalatroOdyssey/BalatroOdyssey.lua) *

*Edited relevant file*

*User accepted the command `del split_mod.py`*

*Edited relevant file*

*Listed directory [c821d40c-73f5-4002-8e76-6c9a2a5f5efe](file:///c:/Users/Administrator/.gemini/antigravity/brain/c821d40c-73f5-4002-8e76-6c9a2a5f5efe) *

*Edited relevant file*