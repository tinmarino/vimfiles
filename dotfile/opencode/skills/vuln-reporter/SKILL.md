---
name: vuln-reporter
description: "Redacta hallazgos de pentest en español neutro chileno usando el formato Markdown de CyScope (Title, CVSS, Sistemas afectados, Descripción, Impacto, Contramedidas, Referencias, Solicitud, Parámetro vulnerable, Carga, Prueba de concepto + tablas Adjuntos/Tiempos). Activar siempre que un consultor redacte, convierta o revise un hallazgo técnico de auditoría en español para CyScope, incluyendo exportaciones JSON de CyScope (`out/json`), Dreamlab `InformeCollection` o archivos `Template*.md`."
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  language: es
  source-json: out/json
  source-reports: ~/Dreamlab/InformeCollection
  canonical-template: ~/Dreamlab/InformeCollection/Template/Template00.md
---

# vuln-reporter

Escribe hallazgos de auditorías en el formato canónico de CyScope: Markdown breve, explícito y reproducible. Texto en **español neutro chileno**; código, comandos y nombres de archivos en inglés. Úsame antes de editar cualquier hallazgo Markdown, informe técnico o plantilla destinada a CyScope.

## 0. Activación

Usa esta skill cuando el usuario pida redactar, convertir, completar o revisar un hallazgo de pentest en español, especialmente si menciona `out/json`, CyScope, Dreamlab, `InformeCollection`, `Template*.md`, `Template.md`, PoC, CVSS, contramedidas o un reporte Markdown.

No uses esta skill para informes ejecutivos completos en PDF, informes CIS, Table Top, auditorías de madurez, reportes forenses o documentos comerciales, salvo que el usuario pida extraer un hallazgo técnico puntual al formato Markdown de Template.

## 1. Fuentes y lectura inicial

Antes de escribir, lee los insumos concretos del caso y, si existen, compara contra ejemplos cercanos.

- Plantilla canónica: `~/Dreamlab/InformeCollection/Template.md`.
- Exportaciones CyScope: `out/json/*.json`, con campos frecuentes `name`, `cvss_vector`, `severity_score`, `targets`, `urls`, `description`, `impact`, `additional_information`, `request`, `affected_parameters`, `payload`, `steps`, `references` y adjuntos en `steps[].media.media_files`.
- Colección Dreamlab: `~/Dreamlab/InformeCollection`, útil para nomenclatura de servicios, tipos de informe y categorías, pero no para copiar estructura cuando el destino sea Template Markdown.
- Plantillas de apoyo, si existen: `~/Software/Pentest/ReportTemplate/`.

## 2. Estructura de carpeta y archivo

Cada hallazgo vive en su propia carpeta:

```
doc/vuln/vuln-<id>-<slug>/
  report.md          ← reporte principal (obligatorio)
  img/               ← capturas reales (opcionales; solo crear si hay imágenes)
```

- `<id>` es el correlativo de tres dígitos (`001`, `002`, …).
- `<slug>` es el título en kebab-case sin tildes ni caracteres especiales.
- Nunca crear un `report.md` en la raíz de `doc/vuln/`; siempre dentro de la subcarpeta.

## 2b. Imágenes — regla estricta

**Nunca citar una imagen que no existe.** Las reglas son:

1. Antes de escribir un paso de la PoC, verificar si hay archivos en `doc/vuln/vuln-<id>-<slug>/img/`.
2. Si la carpeta `img/` existe y contiene archivos, citar exactamente esos archivos con `![desc](img/<nombre-real>)`.
3. Si no hay imágenes, sustituir la captura por un bloque de código con el comando y su salida real (o salida representativa obtenida durante la prueba). Formato:
   ```bash
   $ <comando>
   <salida>
   ```
4. **Nunca** escribir `![...](img/vuln-XXX_NN.jpeg)` ni ningún otro marcador de imagen si el archivo no existe en disco.
5. Si el consultor quiere agregar imágenes después, las sube a `img/` y edita el reporte para sustituir el bloque de código por el marcador `![...]`.

## 2c. Estructura obligatoria (11 secciones + tablas)

Toda vulnerabilidad reportada debe respetar exactamente este orden y estos títulos en nivel H2 después de `# Informe`. Opcionalmente, el archivo puede comenzar con un bloque `# Dump` con notas de trabajo crudas antes de `# Informe`.

Cada hallazgo debe ser autocontenido. No cites otros hallazgos por su ID interno (`Tin001`, `Vuln105`, etc.), no describas la explotación como dependiente de otro writeup y no uses frases como "encadenado con el hallazgo X". Si existe un prerrequisito técnico, descríbelo de forma genérica dentro del mismo reporte o ajusta el privilegio del actor de amenazas para que la vulnerabilidad siga siendo independiente.

1. `## Title` — una frase, en español, imperativa o declarativa. Ejemplo: "Acceso no autorizado a documentos PDF mediante IDOR en el endpoint `/documents/{id}`".
2. `## CVSS` — vector completo v3.1 + score. Ejemplo: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N (7.5 - Alto)`.
3. `## Sistemas afectados` — por defecto (perfil 2e) **solo la(s) URL(s) afectada(s), una por línea y sin viñetas**. La forma viñetada con host/endpoint/ambiente/cuenta es una alternativa legacy; no la uses salvo que el consultor la pida.
4. `## Descripción` — **breve: 1 párrafo corto (2-3 frases SVO), máximo 2**. En tiempo pretérito y voz pasiva refleja ("Se identificó ..."). Describe la falla sin impacto ni mitigación. No repitas lo que ya dice el Title.
5. `## Impacto` — **1 a 2 párrafos cortos** (nunca lista viñetada). El primero abre con la fórmula canónica "Un actor de amenazas no autenticado podría ..." (ajusta el privilegio: "autenticado", "con rol corredor", etc.) + infinitivos, y enumera lo expuesto (datos, acciones, efecto CIA). El segundo (si existe) escala: desanonimización, enumeración masiva, divulgación pública, repercusiones legales y reputacionales para la Empresa.
6. `## Contramedidas` — **2 párrafos cortos + el párrafo de retest** (3 en total como tope habitual). El primero abre con "Para mitigar el presente hallazgo, se sugiere ..." + infinitivos (control de acceso, validación en servidor, enmascarar/omitir el dato sensible). El segundo, "Adicionalmente, se sugiere ..." (limitación de tasa, registro de consultas anómalas). El último es siempre: "Se recomienda, después de la mitigación, implementar pruebas de no regresión de seguridad y solicitar un *retest*.".
7. `## Referencias` — lista numerada. CWE y OWASP primero, siempre con URL `https://`. Formato obligatorio: texto plano con título y URL separados por `: ` (sin Markdown href), para que la URL sea legible en un PDF impreso. Ejemplo: `1. CWE-312: Cleartext Storage of Sensitive Information: https://cwe.mitre.org/data/definitions/312.html`. Luego referencias públicas o contextuales necesarias para entender la falla. Los archivos internos del proyecto no van aquí: si es necesario adjuntarlos, se listan y explican al final en `# Adjuntos`. Usa `---` como separador entre sub-listas.
8. `## Solicitud` — un fenced block ` ```ruby ` (resalta bien HTTP + JSON); pega la solicitud HTTP completa (método, path, cabeceras, cuerpo). Perfil 2e: divide en subsecciones `### Solicitud` (la petición) y `### Respuesta` (el/los bloque(s) de respuesta real), cada una con su ` ```ruby `. Oculta tokens, cookies, firmas (`firma: <redactado>`), pero conserva el parámetro vulnerable y el cuerpo de ataque. Si el cuerpo viaja cifrado, muéstralo en claro y añade una línea explicando el cifrado ("El cuerpo `data` viaja cifrado ..."). **Para hallazgos de fuga de datos / IDOR, agrega un SEGUNDO bloque ` ```ruby ` con la respuesta REAL (descifrada si aplica), recortada a los campos que prueban la fuga**, y una frase final que mapee cada campo filtrado a su significado ("`glosa.haciaTitulo` (nombre), `cuentaIdCredito` (RUT) ...").
9. `## Parámetro vulnerable` — nombre exacto del parámetro (path variable, query-string key, body field, header), sin explicación larga. Perfil 2e: **pelado, sin backticks ni paréntesis** (p. ej. `idParty`, no `` `idParty` (*query string*) ``). Si hay varios, separa con comas.
10. `## Carga` — un fenced block ` ```bash ` reproducible, listo para copy-paste. Usa un `curl`/`HTTPie` con `$TOKEN`, `$USER_ID` o placeholders; o, si la explotación fue una herramienta propia, la **secuencia de comandos reales con nombre base** (sin rutas largas) y un comentario numerado por paso (p. ej. `python3 steal_session.py   # 1. robo de sesión`).
11. `## Prueba de concepto` — subsecciones `### Paso N — Título corto`. Cada paso es 1-2 frases SVO en voz pasiva refleja con conector secuencial, **seguidas de UNA captura** `![Descripción](img/<finding-id>_NN.jpeg)` debajo (el usuario adjunta las imágenes; cita el archivo aunque aún no exista). Un screenshot por paso. Reserva al menos 5 pasos para vulnerabilidades no triviales. Si la explotación se automatizó con scripts propios, cierra con un `### Paso N — Automatización` que nombre los scripts y los archivos de resultados, y declárelos como adjuntos.

Al final del archivo, estas dos tablas siempre presentes, aun vacías:

```markdown
# Adjuntos

| __Archivo__ | __Descripción__ |
| ---         | --- |
|             |   |

# Tiempos

| __Tarea__                    | __Tiempo__ | __Explicación__ |
| ---                          | ---        | --- |
| Encontrar la vulnerabilidad  |            |   |
| Explotar la vulnerabilidad   |            |   |
| Reportar la vulnerabilidad   |            |   |
| Reproducir la vulnerabilidad |            |   |
```

Los tiempos se expresan en unidades naturales: `15 minutos`, `30 minutos`, `1 hora`, `1 hora 30 minutos`, `2 horas`, `40 horas`. No uses decimales ni minutos sueltos > 60; las horas grandes son válidas para tareas de ingeniería inversa o reproducción compleja. La columna `Explicación` puede ser rica: justifica el esfuerzo, anota bloqueos observados (p. ej. bloqueo de cuenta) o limitaciones de la prueba.

Si es necesario apoyar el hallazgo con archivos internos, agrégalos solo en la tabla `# Adjuntos`, usando el nombre base del archivo y una descripción breve de su propósito. No cites rutas internas ni dejes referencias huérfanas a esos archivos en `## Referencias`, `## Descripción` o `## Prueba de concepto`.

Tras la tabla de `# Tiempos` pueden ir párrafos de contexto de ejecución, cuando aporten trazabilidad: caveats de adjuntos ("No fue posible adjuntar la APK por tamaño"), y la ventana de prueba con fecha/hora, cuenta de prueba, dirección IP de origen y región del proveedor (p. ej. AWS `us-west-1`).

## 2d. Estilo por defecto: breve y directo

El estilo **por defecto** de todo `report.md` es el estilo breve. No existe un modo "largo" por defecto; si el usuario pide más detalle en alguna sección, se expande solo esa sección.

Reglas DURAS (no negociables):

- **Todo en pretérito y en forma impersonal con "Se ..."**: cada frase narrativa empieza por "Se " + verbo en pasado ("Se identificó", "Se invocó", "Se obtuvo", "Se constató", "Se modificó"). Nunca "El atacante hace ...", nunca presente, nunca primera persona.
- **Secciones narrativas = EXACTAMENTE 2 frases SVO**: `## Descripción`, `## Impacto` y `## Contramedidas` se redactan con **exactamente dos frases** cortas cada una. Frase 1 = el hecho; frase 2 = la consecuencia/escala. Sin subordinadas largas, sin listas, sin tercer enunciado. (Perfil 2e: cada una de esas dos frases va en su propio párrafo, separadas por línea en blanco.)
- **Prueba de concepto — frases por paso**: cada `### Paso N — Título corto` es breve, en pretérito impersonal, seguido (si procede) del bloque de código, la URL en su propia línea o la imagen. El perfil 2e permite **2–3 frases por paso** cuando el paso intercala una URL/fuente en su propia línea (frase-guía → URL → continuación); fuera de ese caso, mantén 1 frase. El `### Paso 1` puede ir precedido por la frase de entorno: "Para reportar el presente hallazgo, se ejecutaron los siguientes pasos desde la CLI de AWS." y luego su frase de acción.

Esqueleto mínimo:

```markdown
## Descripción

Se identificó que el *endpoint* `<endpoint>` no validó la pertenencia entre el recurso solicitado y el RUT del *token* JWT. Cualquier usuario autenticado consultó un identificador ajeno y obtuvo `<dato sensible>`.

## Impacto

Un actor de amenazas autenticado podría extraer `<PII>` en cada respuesta. El identificador es secuencial, por lo que la enumeración podría convertir el IDOR en una fuga masiva de datos.

## Contramedidas

Para mitigar el presente hallazgo, se sugiere validar la pertenencia del recurso contra el RUT del *token* y retornar `403`/`404`. Se recomienda, después de la mitigación, implementar pruebas de no regresión de seguridad y solicitar un *retest*.

## Prueba de concepto

### Paso 1

Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*.
Se inició sesión con la cuenta `<rut-prueba>`.

### Paso 2

Se capturó el *Bearer token* JWT de la sesión.

### Paso 3

Se invocó `<solicitud>` con un identificador ajeno.

### Paso 4

Se obtuvo una respuesta `HTTP/2 200` con `<dato sensible>`.

### Paso 5

Se constató que el RUT autenticado no figuraba en la respuesta y que el servidor no aplicó control de pertenencia.

### Paso 6

Se modificó el identificador y se obtuvieron otros registros, confirmando la enumeración masiva.
```

## 2e. Perfil de estilo por defecto (formato "-edited")

Este es el estilo canónico del consultor y es el **formato por defecto** para todo `report.md`. Cuando cualquier regla previa choque con este perfil, **manda este perfil**. El reporte de referencia es `Report/Acme226/report-edited.md`.

Reglas concretas del perfil (con ejemplo real):

1. **`## Title` compacto con prefijo e *endpoint***: formato `BT<id>: /<ruta-endpoint>: <descripción corta> (<calificadores>)`. El calificador entre paréntesis resume el contexto (`no autenticado, masivo`, `autenticado`, `corredor`, etc.). Conserva el identificador interno (`BT226`, `Acme224`) como prefijo. Ejemplo:

   `BT226: /<flujo>/datoscliente: datos de contacto y domicilio de terceros por \`idParty\` secuencial (no autenticado, masivo)`

   No uses la forma larga "IDOR no autenticado en X de Y".

2. **`## Sistemas afectados` = solo la(s) URL(s), sin viñetas**: escribe cada URL afectada completa, **una por línea, sin bullet, sin desglose** Host/Endpoint/Backend/Parámetro/Ambiente. Ejemplo:

   `https://api.target.example.com/svc/ind/PlanningMobileServices/rest/<flujo>/datoscliente`

3. **Una frase por párrafo en `## Descripción`, `## Impacto`, `## Contramedidas`**: se mantienen las 2 frases canónicas, pero **cada frase va en su propio párrafo**, separada por una línea en blanco (no en un bloque compacto). El párrafo de *retest* de Contramedidas queda como párrafo aparte.

4. **`## Solicitud` con subsecciones `### Solicitud` y `### Respuesta`**: dentro de `## Solicitud`, la solicitud HTTP va bajo `### Solicitud` y el/los bloque(s) de respuesta real bajo `### Respuesta`. Ambos en ` ```ruby `. La frase que mapea campos filtrados a su significado va al final, tras la respuesta.

5. **`## Parámetro vulnerable` pelado**: solo el nombre del parámetro, **sin backticks y sin paréntesis explicativo**. Ejemplo: `idParty` (no `` `idParty` (*query string*) ``).

6. **URLs siempre en su propia línea, en toda la PoC**: cuando un paso menciona una URL o fuente, va una frase-guía corta, luego la URL sola en su propia línea, luego la continuación. Se permiten **2–3 frases por paso** (relaja la regla de "exactamente 1 frase"). Ejemplo (`### Paso 1`):

   ```markdown
   Primero, se descargó el siguiente código Javascript.

   https://oca.target.example.com/app.js

   A continuación, sin autenticación, se localizó la cabecera `x-<gateway>-client-id` ...
   ```

7. **Paso de cuantificación cuando hubo barrido masivo**: agrega un `### Paso N — Cuantificación del alcance mediante barrido`. **No embebas el código del script**: nómbralo inline con backticks (`` `acme226_step1_sweep_datoscliente.py` ``) y descríbelo en prosa. Declara el origen: qué se hizo desde IP residencial (con la IP pública en backticks, p. ej. `` `203.0.113.10` ``) y qué usó rotación de IP vía AWS API Gateway. Los resultados van como **lista viñetada** (única excepción permitida a "nada de bullets"): titulares distintos, total de registros por tipo, rango de IDs observado. Cierra apuntando a los adjuntos (`.xlsx` y muestras `.json`).

8. **Tablas `# Adjuntos` / `# Tiempos` pulidas**: alinea las columnas con relleno de espacios y **termina cada celda de descripción con punto**. En `# Adjuntos`, la imagen/*thumbnail* ilustrativa (`<id>-thumb.png`) va como **última fila**. Para familias de archivos usa una fila placeholder que anuncie el contenido: `idparty-*.json | Respuesta 200 cruda del barrido para el idParty indicado ...`. Nunca `wave01/` ni carpetas; lista solo lo que efectivamente se adjunta.

9. **Carpeta de adjuntos `Ad/`**: **todos** los adjuntos viven exclusivamente en `Report/<ID>/Ad/`; en la raíz de `Report/<ID>/` solo quedan los `report*.md`. Nunca dejes `.json`, `.csv`, `.xlsx`, scripts ni imágenes sueltos en la raíz: muévelos a `Ad/` (bundle, evidencias base, script, `.xlsx`, las N respuestas `.json` más grandes como muestra, y la imagen). El `.csv` no se adjunta si ya va el `.xlsx`. En la tabla `# Adjuntos` se cita el **nombre base pelado** del archivo (sin el prefijo `Ad/`), que se sobreentiende.

## 3. Mapeo desde CyScope JSON

Cuando partas de una exportación `out/json/*.json`, mapea así:

- `## Title`: usa `name`; elimina prefijos internos solo si estorban la lectura, pero conserva identificadores útiles como `AB143`, `CD089` o el nombre del endpoint.
- `## CVSS`: usa `cvss_vector` y `severity_score`; si falta el score, calcula o deja el vector y marca el cálculo como pendiente solo si no hay datos suficientes.
- `## Sistemas afectados`: por defecto (perfil 2e) escribe solo la(s) URL(s) de `urls[].url`/`targets`, una por línea y sin viñetas. Solo desglosa host/endpoint/ambiente en viñetas si el consultor lo pide.
- `## Descripción`: parte desde `description`; explica la causa técnica sin mezclar impacto ni mitigación.
- `## Impacto`: parte desde `impact`; reescribe en párrafos con la apertura canónica.
- `## Contramedidas`: parte desde `additional_information`; reescribe en párrafos con la apertura canónica.
- `## Referencias`: combina `references`, CWE/OWASP aplicables y referencias públicas o contextuales. Si el insumo incluye archivos internos del proyecto, muévelos a `# Adjuntos` con una descripción breve, en vez de listarlos aquí.
- `## Solicitud`: usa `request`; redacta tokens, cookies, RUT, correos, IDs reales sensibles y firmas presignadas.
- `## Parámetro vulnerable`: usa `affected_parameters`; si hay varios, separa con comas.
- `## Carga`: usa `payload`; transforma a `curl` reproducible cuando el payload sea parcial.
- `## Prueba de concepto`: transforma cada elemento de `steps` en `### Paso N`, conserva comandos y tablas útiles, mueve tablas de adjuntos/tiempos al final si venían incrustadas en el último paso.
- `# Adjuntos`: lista `steps[].media.media_files[].name` y una descripción concreta; no pegues URLs S3 firmadas completas. Si el reporte depende de scripts, binarios, notas internas o artefactos de apoyo, agrégalos aquí por nombre base y explica para qué sirvieron.

## 4. Reglas de estilo

- **Idioma**: español neutro chileno, directo y técnico. Minimizar anglicismos en prosa; usar siempre el equivalente en español cuando existe uno natural. Términos sin equivalente natural van en *cursiva*. Tabla de sustituciones obligatorias:

| Anglicismo (prohibido en prosa) | Equivalente en español |
| --- | --- |
| header / headers | cabecera / cabeceras |
| body (HTTP) | cuerpo |
| request | solicitud |
| response | respuesta |
| rate limiting | limitación de tasa |
| rate limit | límite de tasa |
| endpoint | *endpoint* (en cursiva, no hay sustituto preciso) |
| backend | *backend* (en cursiva) |
| frontend / front-end | *frontend* (en cursiva) |
| firewall | *firewall* (en cursiva) |
| payload | *carga útil* o *payload* (cursiva) |
| token | *token* (cursiva) |
| proxy | *proxy* (cursiva) |
| bypass | omisión, elusión, o *bypass* en cursiva según contexto |
| nonce | *nonce* (cursiva — término criptográfico sin equivalente) |
| Burp Repeater | módulo Repetidor de Burp |

Regla práctica: si un término técnico en inglés se usa en prosa general y no es un nombre de producto, una cabecera HTTP, un campo literal, una ruta, ni texto visible de interfaz, debe ir en *cursiva*. Esto aplica, por ejemplo, a *backend*, *frontend*, *firewall*, *bundle* y otros anglicismos técnicos sin equivalente natural.

Nombres de productos, campos HTTP en backticks (`x-captcha`, `Authorization`) y bloques de código siempre en inglés.
- **Voz pasiva refleja, SIEMPRE en pretérito y forma impersonal**: toda frase narrativa (en `## Descripción`, `## Prueba de concepto` y donde se relaten hechos) empieza por "Se " + verbo en pasado: "Se identificó", "Se reportó", "Se alteró", "Se observó", "Se verificó", "Se invocó", "Se obtuvo", "Se constató". Prohibido el presente ("se identifica", "responde", "permite"), prohibida la primera persona ("repetí", "llamé", "completé") y prohibido el sujeto-agente personal ("El atacante inicia sesión" → "Se inició sesión"). El servidor solo aparece como sujeto para describir su respuesta observada en pasado ("El servidor respondió ..."), pero se prefiere "Se obtuvo una respuesta ...".
- **Prohibido el gerundio** para encadenar acciones ("Cambiando X y pidiendo Y ...", "permitiendo Z", "enviando W"). Reemplaza gerundios de consecuencia con "lo que podría permitir X" o "mediante el/la N"; reemplaza gerundios de acción con una oración declarativa nueva: "Se alteró X. Luego, se obtuvo Y.". Esta regla aplica especialmente en `## Descripción` e `## Impacto`. Ejemplo correcto: "El servidor no invalidó el *token*, lo que podría permitir reutilizarlo de forma indefinida." Ejemplo incorrecto: "El servidor no invalidó el *token*, permitiendo reutilizarlo."
- **Apertura canónica de `## Impacto`**: el primer párrafo abre con "Un actor de amenazas no autenticado podría ..." (o el nivel de privilegio que corresponda) + infinitivos. Párrafos siguientes pueden variar la apertura para fluidez ("Con esta información, un actor de amenazas podría ...", "La ausencia de ... permite ..."). Nada de bullets. Nunca usar "atacante"; siempre "actor de amenazas".
- **Apertura canónica de `## Contramedidas`**: el primer párrafo abre con "Para mitigar el presente hallazgo, se sugiere ..." + infinitivos. Párrafos siguientes pueden variar ("Adicionalmente, se sugiere ...", "Se sugiere también ..."). No repetir la misma fórmula en cada párrafo. El último párrafo es siempre la fórmula de *retest*. Nada de bullets.
- **Condicional para impactos**: `podría permitir`, `podría conducir`, `podría facilitar`, `podría obtener`.
- **Tiempo verbal en Descripción y PoC**: SIEMPRE pretérito ("se identificó", "se verificó", "no validó", "retornó", "confirmó", "aceptó", "rechazó"). Nunca presente indicativo para describir comportamiento del servidor ("permite", "acepta", "verifica", "retorna", "rechaza") — el reporte narra hechos ya observados durante las pruebas. Excepción: `## Impacto` y `## Contramedidas` usan condicional ("podría permitir") o infinitivo ("se sugiere implementar").
- **Descripción siempre en condicional**: cuando la Descripción establece la consecuencia de la falla, usar "podría permitir", NO "permite". Ejemplo correcto: "Esto podría permitir a un usuario autenticado ejecutar ...". Ejemplo incorrecto: "Esto permite a un usuario autenticado ejecutar ...".
- **URLs completas solo en `## Sistemas afectados`**: listar cada URL afectada completa con protocolo, host y path, una por línea (`https://host.example.com/api/v1/endpoint`). En el resto del texto narrativo, los *endpoints* se citan como la parte final del path en backticks (p. ej. `sessions/logout`, `metadata-search/status`) o como URL completa en su propia línea si se quiere destacar. Nunca incrustar URLs largas en medio de una frase.
- **Hallazgos independientes**: cada writeup debe entenderse por sí solo. Nunca referenciar otros hallazgos por ID interno ni escribir dependencias del tipo "esto se explota junto con X". Si otra falla fue un prerrequisito observado durante la prueba, exprésala como condición técnica genérica dentro del mismo hallazgo, o cambia el nivel de privilegio del actor de amenazas para evitar dependencia externa.
- **Terminología obligatoria**: usar siempre "actor de amenazas" (nunca "atacante", "hacker", "adversario"). Nivel de privilegio: "no autenticado", "autenticado", "con rol corredor", etc.
- **Mitigaciones como acciones verificables**: `implementar control de acceso`, `validar pertenencia del recurso`, `rechazar IDs fuera del contexto`, `registrar intentos`, `limitar tasa`, `inmutabilizar campos identitarios`.
- **Secciones cortas por defecto**: prioriza la brevedad. `## Descripción` 1 párrafo corto (máx 2); `## Impacto` 1-2 párrafos; `## Contramedidas` 2 + retest. Nunca repitas la fórmula de apertura en cada párrafo ni rellenes con prosa. Si una sección se puede decir en dos frases, déjala en dos frases.
- **Etiquetas de interfaz en backticks**: todo texto que el usuario lee o pulsa en pantalla va en backticks tal cual aparece: `Acme Pay`, `Transferir`, `Confirma tu pago`, `$1`, mensajes de error (`Cuenta destino no está activa`) y valores ingresados (`CyScope`). Esto desambigua la PoC de la prosa.
- **PoC reproducible y fluida**: NO usar estructura rígida "Precondición: / Acción: / Resultado observado:" en cada paso. Escribir frases narrativas cortas en voz pasiva refleja, en tiempo pasado, en forma impersonal. El párrafo introductorio de `## Prueba de concepto` describe el entorno real usado: "Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*." — o el que aplique, p. ej. "... en la aplicación móvil con un Gadget Frida instalado.". Cada paso es un `### Paso N — Título corto` seguido de 1–3 frases SVO que abren con un conector secuencial: `Primero, se ...`, `Luego, se ...`, `A continuación, se ...`, `Seguidamente, se ...`, `Posteriormente, se ...`, `Finalmente, se ...`. No usar listas ni encabezados internos dentro de cada paso.
- **Paso de identificación del *endpoint* o fuente**: cuando un paso documenta de dónde salió una ruta o un *endpoint*, preferir bloques visuales cortos y separados, no una sola frase larga. Formato preferido: una frase breve (`Se identificó la siguiente ruta.`), luego la ruta sola en su propia línea (`GET /...`), luego otra frase breve (`La cual fue encontrada en el siguiente archivo.`), luego la URL fuente sola en su propia línea (`https://.../config.production.json`), luego la mención de la clave o campo (`bajo la clave \`certificadoCobertura\` (ver referencia N).`), luego la URL base completa del *endpoint* en una línea sola (`https://host/...`) y finalmente el snippet de configuración en un bloque `json`. Si la fuente es una URL pública, preferir citar esa URL en vez de una ruta local del repo.
- **Imágenes solo si existen en disco**: debajo de cada paso incluye UNA captura `![Descripción](img/<nombre-real>)` SOLO si el archivo existe en `img/`. Si no existe imagen, pon en su lugar un bloque de código con el comando y su salida real: ` ```bash\n$ <cmd>\n<output>\n``` `. Nunca citar una imagen inexistente. Respeta nombre y extensión exactos de los archivos en disco.
- **Paso de automatización y adjuntos no-imagen**: cuando la explotación usó herramientas propias, cierra la PoC con un `### Paso N — Automatización` que nombre los scripts (`hook_idor_cuenta.py`, `steal_session.py`, `get_pii_by_phone.py`) y los archivos de resultados (`*.xlsx`), y la tabla `# Adjuntos` lista esos scripts, datos y *thumbnails* además de las capturas.
- **Nunca** borres comentarios ni docstrings preexistentes del usuario; la regla `python-writer` también aplica aquí a cualquier snippet en las pruebas de concepto.
- **Placeholders permitidos**: `TODO`, `<organizacion>`, `<endpoint>`, `<user-id>`, `<resource-id>`, `<token-jwt>`, `<rut-prueba>`, `<id-poliza>`, `<host>`, o variables `$TOKEN`, `$RUT`, `$ID`. Ningún valor real de producción salvo URL pública (host sin path sensible).
- **No inventes** evidencias, URLs, adjuntos, tiempos ni CVSS. Si falta un dato, deja el espacio vacío o una marca `TODO` mínima.
- **CVSS**: elige siempre el vector, no solo el score. Adjunta el link a la calculadora FIRST si el vector es discutible.
- **Markdown sin hard-wrap**: una línea por párrafo (o por ítem de lista / celda de tabla). Deja que el renderizador haga el ajuste.
- **Frases cortas SVO por defecto**: cada sección narrativa (`## Descripción`, `## Impacto`, `## Contramedidas`) se redacta con frases cortas de estructura sujeto-verbo-objeto. El ideal es 2 frases por sección; el máximo es 4. Ejemplo: "El logout de la aplicación no revoca la sesión en el servidor." o "Un actor de amenazas autenticado podría reutilizar un *token* capturado después del logout." Nunca subordinadas largas ni listas de condiciones encadenadas dentro de una misma frase.

## 5. Categorías frecuentes observadas

Usa estas categorías para escoger CWE/OWASP, referencias y contramedidas.

- IDOR y Broken Access Control sobre IDs numéricos, RUT, póliza, documento, liquidación, cuenta, empresa o usuario.
- Descarga masiva de PDF o datos personales, financieros o de salud.
- Enumeración de usuarios, correos, pólizas, agentes, empresas, documentos o productos.
- Autenticación ausente, bypass de OTP, validación solo cliente, JWT débil o contexto cruzado persona/empresa.
- Fallas de lógica de negocio: montos negativos, porcentajes arbitrarios, manipulación de precio o estado.
- Divulgación de configuración, versiones, endpoints, mensajes de error, caché o metadatos sensibles.
- Exposición de *backend* interno, HTTP claro, falta de limitación de tasa o acciones no autenticadas.

## 6. Selección de plantilla

Antes de escribir desde cero, revisa si el equipo mantiene plantillas por categoría. Copia la más cercana y rellena los stubs con el caso concreto.

Mapeo categoría -> archivo (kebab-case):

| Categoría                                       | Archivo plantilla                           |
| ---                                             | ---                                         |
| IDOR con ID numérico                            | `idor-numeric-id.md`                        |
| IDOR con descarga masiva de PDFs                | `idor-masive-template.md`                   |
| IDOR encadenado multi-servicio                  | `idor-chained.md`                           |
| Broken Access Control en GraphQL                | `graphql-broken-access-control.md`          |
| JWT sin verificación de firma                   | `jwt-signature-not-verified.md`             |
| JWT forjable (algoritmo / clave débil)          | `jwt-forgery.md`                            |
| Bypass de OTP (validación solo en *frontend*)   | `otp-bypass-client-side.md`                 |
| CAPTCHA sin validación en servidor              | `captcha-missing-validation.md`             |
| Login sin contraseña (auth rota)                | `auth-login-without-password.md`            |
| Contraseña por defecto / predecible             | `weak-default-password.md`                  |
| Logic flaw: porcentaje beneficiario >100 %      | `business-logic-percentage-overflow.md`     |
| Logic flaw: manipulación de precio              | `business-logic-price-tampering.md`         |
| Confusión de contexto Persona <-> Empresa       | `cross-context-auth-confusion.md`           |
| *backend* interno / legado expuesto             | `exposed-internal-backend.md`               |
| HTTP en claro sobre dato sensible               | `plaintext-http-sensitive.md`               |
| Config.prod.json filtra endpoints               | `config-file-endpoint-disclosure.md`        |
| Extracción masiva de PII sin rate-limit         | `mass-pii-scraping-no-rate-limit.md`        |
| Escritura no autenticada (e.g. createMovement)  | `unauthenticated-write-action.md`           |
| Enumeración de usuarios                         | `user-enumeration.md`                       |
| Business logic genérica en inglés               | `english-business-logic-template.md`        |
| Redondeo en cambio de divisa                    | `logic-finance-convert-currency-rouding.md` |
| Datos sensibles en caché de pantalla (Android)  | `screenshot-cache-sensitive-data.md`        |

Si la categoría no está en la tabla, crea primero una plantilla nueva siguiendo esta skill, añádela a la tabla y luego instancia el hallazgo concreto.

## 7. Comando mental para redactar

1. **Lee** el Markdown de referencia (`Template.md`) si necesitas refrescar las secciones.
2. **Lee** 2 a 3 hallazgos reales de la misma categoría para alinear tono.
3. **Copia** la plantilla de la categoría que mejor calce, si existe.
4. **Rellena** sin alterar títulos; deja las secciones que no aplican vacías (no pongas "N/A").
5. **Verifica** que `## Impacto` y `## Contramedidas` cumplan las aperturas canónicas, sin gerundios y sin bullets.
6. **Verifica** que la sección `## Prueba de concepto` tenga pasos numerados en orden, con enlaces a capturas.
7. **Revisa** que CVSS esté calculado con base a CIA real, no copiado del hallazgo anterior.
8. **Adjunta** archivos en `img/` y cárgalos en la tabla Adjuntos.
9. **Cronometra** las tres tareas (Encontrar / Explotar / Reportar) en la tabla Tiempos, en unidades naturales.

## 8. Checklist final

- El hallazgo está en `doc/vuln/vuln-<id>-<slug>/report.md`, no en un `.md` suelto.
- El orden y los títulos coinciden con la estructura obligatoria.
- Hay CVSS vectorial o queda explícito que falta información para calcularlo.
- **Exactamente 2 frases SVO** en Descripción, Impacto y Contramedidas (perfil 2e: cada frase en su propio párrafo). Nada de relleno.
- `## Sistemas afectados` es solo la(s) URL(s), una por línea, sin viñetas (perfil 2e).
- `## Parámetro vulnerable` va pelado, sin backticks ni paréntesis (perfil 2e).
- `# Adjuntos` con columnas alineadas, descripciones con punto final, y la imagen `<id>-thumb.png` como última fila (perfil 2e).
- `## Impacto` abre con "Un actor de amenazas ... podría ...".
- `## Contramedidas` abre con "Para mitigar el presente hallazgo, se sugiere ...", y termina con el párrafo de *retest*.
- `## Solicitud` usa ` ```ruby `; para fugas de datos incluye un segundo bloque con la respuesta real recortada a los campos filtrados.
- Toda frase narrativa está en pretérito impersonal ("Se ..."), sin presente, sin primera persona y sin sujeto-agente personal.
- Pasos de PoC breves (perfil 2e: 2–3 frases cuando el paso intercala una URL en su propia línea; 1 frase en el resto), seguidos de imagen (si existe en `img/`) o bloque de código con salida real. URLs siempre en su propia línea.
- **Ningún marcador `![...]` que apunte a una imagen inexistente en disco.**
- No hay gerundios encadenando acciones ni primera persona.
- La PoC permite reproducir con `curl`, CLI AWS o los scripts adjuntos sin conocimiento implícito.
- El hallazgo es autocontenido; no remite a otros hallazgos por ID interno.
- Las credenciales, tokens, cookies, firmas S3, RUT reales y datos personales están redactados.
- Las tablas `# Adjuntos` y `# Tiempos` existen aunque queden parcialmente vacías.
- Sin rutas absolutas ni relativas internas; scripts citados solo por nombre base en `# Adjuntos`.
- Sin capturas de pantalla en `# Adjuntos`; las imágenes van solo en los pasos de PoC.
- Sin backticks en la columna Archivo de `# Adjuntos`.

## 9. Cuándo NO usar esta skill

- Informes ejecutivos completos en PDF: usan un formato distinto y no corresponden al Markdown técnico de hallazgos.
- Informes CIS, Table Top, auditorías de madurez, reportes forenses o documentos comerciales.
- Retests cortos: basta con añadir "Retest <fecha>: corregido / no corregido" en la sección `## Contramedidas` del hallazgo existente.
- Drafts muy tempranos de CTFs o ejercicios internos; ahí usa la estructura del proyecto correspondiente.
