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

## 2. Estructura obligatoria (11 secciones + tablas)

Toda vulnerabilidad reportada debe respetar exactamente este orden y estos títulos en nivel H2 después de `# Informe`. Opcionalmente, el archivo puede comenzar con un bloque `# Dump` con notas de trabajo crudas antes de `# Informe`.

1. `## Title` — una frase, en español, imperativa o declarativa. Ejemplo: "Acceso no autorizado a documentos PDF mediante IDOR en el endpoint `/documents/{id}`".
2. `## CVSS` — vector completo v3.1 + score. Ejemplo: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N (7.5 - Alto)`.
3. `## Sistemas afectados` — lista viñetada con host, endpoint y cualquier identificador de ambiente, cuenta o usuario de prueba.
4. `## Descripción` — **breve: 1 párrafo corto (2-3 frases SVO), máximo 2**. En tiempo pretérito y voz pasiva refleja ("Se identificó ..."). Describe la falla sin impacto ni mitigación. No repitas lo que ya dice el Title.
5. `## Impacto` — **1 a 2 párrafos cortos** (nunca lista viñetada). El primero abre con la fórmula canónica "Un actor de amenazas no autenticado podría ..." (ajusta el privilegio: "autenticado", "con rol corredor", etc.) + infinitivos, y enumera lo expuesto (datos, acciones, efecto CIA). El segundo (si existe) escala: desanonimización, enumeración masiva, divulgación pública, repercusiones legales y reputacionales para la Empresa.
6. `## Contramedidas` — **2 párrafos cortos + el párrafo de retest** (3 en total como tope habitual). El primero abre con "Para mitigar el presente hallazgo, se sugiere ..." + infinitivos (control de acceso, validación en servidor, enmascarar/omitir el dato sensible). El segundo, "Adicionalmente, se sugiere ..." (limitación de tasa, registro de consultas anómalas). El último es siempre: "Se recomienda, después de la mitigación, implementar pruebas de no regresión de seguridad y solicitar un *retest*.".
7. `## Referencias` — lista numerada. CWE y OWASP primero, siempre con URL `https://`; luego artefactos internos como URLs, repositorios o dashboards. Usa `---` como separador entre sub-listas.
8. `## Solicitud` — un fenced block ` ```ruby ` (resalta bien HTTP + JSON); pega la solicitud HTTP completa (método, path, cabeceras, cuerpo). Oculta tokens, cookies, firmas (`firma: <redactado>`), pero conserva el parámetro vulnerable y el cuerpo de ataque. Si el cuerpo viaja cifrado, muéstralo en claro y añade una línea explicando el cifrado ("El cuerpo `data` viaja cifrado ..."). **Para hallazgos de fuga de datos / IDOR, agrega un SEGUNDO bloque ` ```ruby ` con la respuesta REAL (descifrada si aplica), recortada a los campos que prueban la fuga**, y una frase final que mapee cada campo filtrado a su significado ("`glosa.haciaTitulo` (nombre), `cuentaIdCredito` (RUT) ...").
9. `## Parámetro vulnerable` — nombre exacto del parámetro (path variable, query-string key, body field, header), sin explicación larga. Si hay varios, separa con comas.
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

Tras la tabla de `# Tiempos` pueden ir párrafos de contexto de ejecución, cuando aporten trazabilidad: caveats de adjuntos ("No fue posible adjuntar la APK por tamaño"), y la ventana de prueba con fecha/hora, cuenta de prueba, dirección IP de origen y región del proveedor (p. ej. AWS `us-west-1`).

## 2b. Variante breve (`report-small.md`)

Cuando el usuario pida un reporte "breve", "directo", "small", "a mi forma" o "2 frases por sección y 1 por paso", escribe la **variante breve** en un archivo paralelo `report-small.md` (junto al `report.md`). Esta variante NO cambia los títulos ni el orden de las 11 secciones + tablas; solo recorta la prosa a su mínima expresión. El archivo de referencia canónico es `Report/<finding-id>/report-small.md`.

Reglas DURAS de la variante breve (no negociables):

- **Todo en pretérito y en forma impersonal con "Se ..."**: cada frase narrativa empieza por "Se " + verbo en pasado ("Se identificó", "Se invocó", "Se obtuvo", "Se constató", "Se modificó"). Nunca "El atacante hace ...", nunca presente, nunca primera persona. El servidor es sujeto solo para describir su respuesta observada ("Se obtuvo una respuesta `HTTP/2 200` ..." es preferible a "El servidor responde ...").
- **Secciones narrativas = EXACTAMENTE 2 frases SVO**: `## Descripción`, `## Impacto` y `## Contramedidas` se redactan con **exactamente dos frases** cortas sujeto-verbo-objeto cada una. Frase 1 = el hecho; frase 2 = la consecuencia/escala. Sin subordinadas largas, sin listas, sin tercer enunciado. Si no cabe en dos frases, se está escribiendo de más.
- **Prueba de concepto = EXACTAMENTE 1 frase por paso**: cada `### Paso N` contiene **una sola frase SVO** en pretérito impersonal. La única excepción es el `### Paso 1`, que puede ir precedido por la frase de entorno ("Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*.") y luego su frase de acción. Ningún paso lleva captura embebida en la variante breve (las capturas son opcionales aquí); no se obliga el marcador `![...]`.
- **Resto igual que el reporte completo**: `## CVSS`, `## Sistemas afectados`, `## Solicitud`, `## Parámetro vulnerable`, `## Carga`, `# Adjuntos` y `# Tiempos` se mantienen idénticos en formato (pueden quedar más escuetos, pero sin perder el vector CVSS ni la solicitud reproducible).

Esqueleto mínimo de la variante breve (2 frases por sección narrativa, 1 frase por paso):

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

## 3. Mapeo desde CyScope JSON

Cuando partas de una exportación `out/json/*.json`, mapea así:

- `## Title`: usa `name`; elimina prefijos internos solo si estorban la lectura, pero conserva identificadores útiles como `AB143`, `CD089` o el nombre del endpoint.
- `## CVSS`: usa `cvss_vector` y `severity_score`; si falta el score, calcula o deja el vector y marca el cálculo como pendiente solo si no hay datos suficientes.
- `## Sistemas afectados`: combina `targets`, `urls[].url`, host, endpoint, ambiente y servicio afectado; usa viñetas cortas.
- `## Descripción`: parte desde `description`; explica la causa técnica sin mezclar impacto ni mitigación.
- `## Impacto`: parte desde `impact`; reescribe en párrafos con la apertura canónica.
- `## Contramedidas`: parte desde `additional_information`; reescribe en párrafos con la apertura canónica.
- `## Referencias`: combina `references`, CWE/OWASP aplicables, URLs internas y dashboard de CyScope si aporta trazabilidad.
- `## Solicitud`: usa `request`; redacta tokens, cookies, RUT, correos, IDs reales sensibles y firmas presignadas.
- `## Parámetro vulnerable`: usa `affected_parameters`; si hay varios, separa con comas.
- `## Carga`: usa `payload`; transforma a `curl` reproducible cuando el payload sea parcial.
- `## Prueba de concepto`: transforma cada elemento de `steps` en `### Paso N`, conserva comandos y tablas útiles, mueve tablas de adjuntos/tiempos al final si venían incrustadas en el último paso.
- `# Adjuntos`: lista `steps[].media.media_files[].name` y una descripción concreta; no pegues URLs S3 firmadas completas.

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
| payload | *carga útil* o *payload* (cursiva) |
| token | *token* (cursiva) |
| proxy | *proxy* (cursiva) |
| bypass | omisión, elusión, o *bypass* en cursiva según contexto |
| nonce | *nonce* (cursiva — término criptográfico sin equivalente) |
| Burp Repeater | módulo Repetidor de Burp |

Nombres de productos, campos HTTP en backticks (`x-captcha`, `Authorization`) y bloques de código siempre en inglés.
- **Voz pasiva refleja, SIEMPRE en pretérito y forma impersonal**: toda frase narrativa (en `## Descripción`, `## Prueba de concepto` y donde se relaten hechos) empieza por "Se " + verbo en pasado: "Se identificó", "Se reportó", "Se alteró", "Se observó", "Se verificó", "Se invocó", "Se obtuvo", "Se constató". Prohibido el presente ("se identifica", "responde", "permite"), prohibida la primera persona ("repetí", "llamé", "completé") y prohibido el sujeto-agente personal ("El atacante inicia sesión" → "Se inició sesión"). El servidor solo aparece como sujeto para describir su respuesta observada en pasado ("El servidor respondió ..."), pero se prefiere "Se obtuvo una respuesta ...".
- **Prohibido el gerundio** para encadenar acciones ("Cambiando X y pidiendo Y ...", "permitiendo Z", "enviando W"). Reemplaza gerundios de consecuencia con "lo que podría permitir X" o "mediante el/la N"; reemplaza gerundios de acción con una oración declarativa nueva: "Se alteró X. Luego, se obtuvo Y.". Esta regla aplica especialmente en `## Descripción` e `## Impacto`. Ejemplo correcto: "El servidor no invalidó el *token*, lo que podría permitir reutilizarlo de forma indefinida." Ejemplo incorrecto: "El servidor no invalidó el *token*, permitiendo reutilizarlo."
- **Apertura canónica de `## Impacto`**: el primer párrafo abre con "Un actor de amenazas no autenticado podría ..." (o el nivel de privilegio que corresponda) + infinitivos. Párrafos siguientes pueden variar la apertura para fluidez ("Con esta información, un actor de amenazas podría ...", "La ausencia de ... permite ..."). Nada de bullets. Nunca usar "atacante"; siempre "actor de amenazas".
- **Apertura canónica de `## Contramedidas`**: el primer párrafo abre con "Para mitigar el presente hallazgo, se sugiere ..." + infinitivos. Párrafos siguientes pueden variar ("Adicionalmente, se sugiere ...", "Se sugiere también ..."). No repetir la misma fórmula en cada párrafo. El último párrafo es siempre la fórmula de *retest*. Nada de bullets.
- **Condicional para impactos**: `podría permitir`, `podría conducir`, `podría facilitar`, `podría obtener`.
- **Tiempo verbal en Descripción y PoC**: SIEMPRE pretérito ("se identificó", "se verificó", "no validó", "retornó", "confirmó", "aceptó", "rechazó"). Nunca presente indicativo para describir comportamiento del servidor ("permite", "acepta", "verifica", "retorna", "rechaza") — el reporte narra hechos ya observados durante las pruebas. Excepción: `## Impacto` y `## Contramedidas` usan condicional ("podría permitir") o infinitivo ("se sugiere implementar").
- **Descripción siempre en condicional**: cuando la Descripción establece la consecuencia de la falla, usar "podría permitir", NO "permite". Ejemplo correcto: "Esto podría permitir a un usuario autenticado ejecutar ...". Ejemplo incorrecto: "Esto permite a un usuario autenticado ejecutar ...".
- **URLs completas solo en `## Sistemas afectados`**: listar cada URL afectada completa con protocolo, host y path, una por línea (`https://host.example.com/api/v1/endpoint`). En el resto del texto narrativo, los *endpoints* se citan como la parte final del path en backticks (p. ej. `sessions/logout`, `metadata-search/status`) o como URL completa en su propia línea si se quiere destacar. Nunca incrustar URLs largas en medio de una frase.
- **Terminología obligatoria**: usar siempre "actor de amenazas" (nunca "atacante", "hacker", "adversario"). Nivel de privilegio: "no autenticado", "autenticado", "con rol corredor", etc.
- **Mitigaciones como acciones verificables**: `implementar control de acceso`, `validar pertenencia del recurso`, `rechazar IDs fuera del contexto`, `registrar intentos`, `limitar tasa`, `inmutabilizar campos identitarios`.
- **Secciones cortas por defecto**: prioriza la brevedad. `## Descripción` 1 párrafo corto (máx 2); `## Impacto` 1-2 párrafos; `## Contramedidas` 2 + retest. Nunca repitas la fórmula de apertura en cada párrafo ni rellenes con prosa. Si una sección se puede decir en dos frases, déjala en dos frases.
- **Etiquetas de interfaz en backticks**: todo texto que el usuario lee o pulsa en pantalla va en backticks tal cual aparece: `Acme Pay`, `Transferir`, `Confirma tu pago`, `$1`, mensajes de error (`Cuenta destino no está activa`) y valores ingresados (`CyScope`). Esto desambigua la PoC de la prosa.
- **PoC reproducible y fluida**: NO usar estructura rígida "Precondición: / Acción: / Resultado observado:" en cada paso. Escribir frases narrativas cortas en voz pasiva refleja, en tiempo pasado, en forma impersonal. El párrafo introductorio de `## Prueba de concepto` describe el entorno real usado: "Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*." — o el que aplique, p. ej. "... en la aplicación móvil con un Gadget Frida instalado.". Cada paso es un `### Paso N — Título corto` seguido de 1–3 frases SVO que abren con un conector secuencial: `Primero, se ...`, `Luego, se ...`, `A continuación, se ...`, `Seguidamente, se ...`, `Posteriormente, se ...`, `Finalmente, se ...`. No usar listas ni encabezados internos dentro de cada paso.
- **Una captura por paso (el usuario las adjunta)**: debajo de cada paso cita exactamente una imagen `![Descripción](img/<finding-id>_NN.jpeg)`. Cita el archivo aunque el usuario aún no lo haya adjuntado — los marcadores quedan listos para cuando pegue las imágenes en `img/`. Respeta el nombre y la extensión reales de los archivos (no asumas `.png`; pueden ser `.jpeg`), y conserva guion/guion-bajo tal como existan en disco.
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
- Exposición de backend interno, HTTP claro, falta de rate limiting o acciones no autenticadas.

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
| Bypass de OTP (validación solo en front-end)    | `otp-bypass-client-side.md`                 |
| CAPTCHA sin validación en servidor              | `captcha-missing-validation.md`             |
| Login sin contraseña (auth rota)                | `auth-login-without-password.md`            |
| Contraseña por defecto / predecible             | `weak-default-password.md`                  |
| Logic flaw: porcentaje beneficiario >100 %      | `business-logic-percentage-overflow.md`     |
| Logic flaw: manipulación de precio              | `business-logic-price-tampering.md`         |
| Confusión de contexto Persona <-> Empresa       | `cross-context-auth-confusion.md`           |
| Backend interno / legado expuesto               | `exposed-internal-backend.md`               |
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

- El orden y los títulos coinciden con `Template.md`.
- Hay CVSS vectorial o queda explícito que falta información para calcularlo.
- Cada sección es breve: Descripción 1 párrafo (máx 2), Impacto 1-2, Contramedidas 2 + retest. Nada de relleno.
- `## Impacto` abre con "Un actor de amenazas ... podría ...".
- `## Contramedidas` abre con "Para mitigar el presente hallazgo, se sugiere ...", y termina con el párrafo de *retest*.
- `## Solicitud` usa ` ```ruby `; para fugas de datos incluye un segundo bloque con la respuesta real (descifrada) recortada a los campos filtrados.
- Toda frase narrativa está en pretérito impersonal ("Se ..."), sin presente, sin primera persona y sin sujeto-agente personal ("El atacante ...").
- Si se pidió la variante breve (`report-small.md`): cada sección narrativa tiene EXACTAMENTE 2 frases SVO y cada `### Paso N` EXACTAMENTE 1 frase (ver sección 2b).
- No hay gerundios encadenando acciones ni primera persona.
- La PoC tiene un `### Paso N — Título` por acción, con exactamente una captura `![...](img/<id>_NN.jpeg)` debajo, y las etiquetas de interfaz van en backticks.
- La PoC permite reproducir con navegador, Burp Suite, `curl` o los scripts adjuntos sin depender de conocimiento implícito.
- Las credenciales, tokens, cookies, firmas S3, RUT reales y datos personales están redactados.
- Las tablas `# Adjuntos` y `# Tiempos` existen aunque queden parcialmente vacías.
- El resultado es Markdown simple, sin HTML innecesario, sin hard-wrap y sin formato de informe ejecutivo Dreamlab.
- **Sin rutas internas de archivos**: los scripts y archivos se citan solo por su nombre base (`hook_idor_cuenta.py`, no `Script/util/hook_idor_cuenta.py`). Nunca incluir rutas absolutas ni relativas de directorios internos del proyecto en ninguna sección del informe.
- **Sin capturas de pantalla en `# Adjuntos`**: la tabla `# Adjuntos` lista únicamente scripts, herramientas y archivos de datos. Las imágenes van exclusivamente en los pasos de `## Prueba de concepto` mediante el marcador `![...](img/...)` — nunca en la tabla de adjuntos.
- **Sin backticks en la columna Archivo de `# Adjuntos`**: los nombres de archivo en la tabla van en texto plano, sin backticks. Los backticks se reservan para referencias inline en el cuerpo del texto.

## 9. Cuándo NO usar esta skill

- Informes ejecutivos completos en PDF: usan un formato distinto y no corresponden al Markdown técnico de hallazgos.
- Informes CIS, Table Top, auditorías de madurez, reportes forenses o documentos comerciales.
- Retests cortos: basta con añadir "Retest <fecha>: corregido / no corregido" en la sección `## Contramedidas` del hallazgo existente.
- Drafts muy tempranos de CTFs o ejercicios internos; ahí usa la estructura del proyecto correspondiente.
