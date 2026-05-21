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
  canonical-template: ~/Dreamlab/InformeCollection/Template00.md
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
4. `## Descripción` — 2 a 4 párrafos en tiempo pretérito/presente y voz pasiva refleja ("Se identificó ..."). Describe la falla sin impacto ni mitigación.
5. `## Impacto` — 2 a 4 **párrafos** (nunca lista viñetada). Cada párrafo debe abrir con la fórmula canónica "Un actor de amenazas no autenticado podría ..." (ajusta el nivel de privilegio si aplica: "autenticado", "con rol corredor", etc.), seguida de verbos en infinitivo. Enumera lo que el atacante obtendría o podría hacer (datos expuestos, acciones no autorizadas, alcance masivo, efecto CIA).
6. `## Contramedidas` — 2 a 5 **párrafos** de recomendaciones técnicas (proceso al final). Cada párrafo debe abrir con la fórmula canónica "Para mitigar el presente hallazgo, se sugiere ...", seguida de verbos en infinitivo. Prioriza controles de autorización, validación en servidor, rate limiting y logging. Siempre termina con un último párrafo: "Se recomienda, después de la mitigación, implementar pruebas de no regresión de seguridad y solicitar un *retest*.".
7. `## Referencias` — lista numerada. CWE y OWASP primero, siempre con URL `https://`; luego artefactos internos como URLs, repositorios o dashboards. Usa `---` como separador entre sub-listas.
8. `## Solicitud` — un fenced block ` ```text `; pega aquí la solicitud HTTP completa (método, path, headers, body). Oculta tokens (`Authorization: Bearer ...`), cookies, RUT, correos, IDs reales sensibles y firmas presignadas.
9. `## Parámetro vulnerable` — nombre exacto del parámetro (path variable, query-string key, body field, header), sin explicación larga. Si hay varios, separa con comas.
10. `## Carga` — un fenced block ` ```bash ` con un `curl` o `HTTPie` reproducible, listo para copy-paste; usa `$TOKEN`, `$USER_ID`, `$RESOURCE_ID` o placeholders equivalentes. Si el `payload` de CyScope es parcial, transfórmalo a `curl` completo.
11. `## Prueba de concepto` — subsecciones `### Paso 1`, `### Paso 2`, ... Cada paso incluye precondición, acción, solicitud/comando, resultado observado y evidencia. Capturas referenciadas con `![Descripción](img/Finding-01.png)`. Reserva al menos 5 pasos para vulnerabilidades no triviales.

Al final del archivo, estas dos tablas siempre presentes, aun vacías:

```markdown
# Adjuntos

| __Archivo__ | __Descripción__ |
| ---         | --- |
|             |   |

# Tiempos

| __Tarea__                   | __Tiempo__ | __Explicación__ |
| ---                         | ---        | --- |
| Encontrar la vulnerabilidad |            |   |
| Explotar la vulnerabilidad  |            |   |
| Reportar la vulnerabilidad  |            |   |
```

Los tiempos se expresan en unidades naturales: `15 minutos`, `30 minutos`, `1 hora`, `1 hora 30 minutos`, `2 horas`, `3 horas`. No uses decimales ni minutos sueltos > 60.

## 3. Mapeo desde CyScope JSON

Cuando partas de una exportación `out/json/*.json`, mapea así:

- `## Title`: usa `name`; elimina prefijos internos solo si estorban la lectura, pero conserva identificadores útiles como `BT143`, `CT089` o el nombre del endpoint.
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

- **Idioma**: español neutro chileno, directo y técnico. *Endpoint*, *proxy*, *token*, *payload*, *dashboard* y demás términos técnicos van entre *cursivas* (`*endpoint*`).
- **Voz pasiva refleja** para narrar: "se identificó", "se reportó", "se alteró", "se observó", "se verificó". Evita primera persona ("repetí", "llamé", "completé"): usa "se repitió", "se invocó", "se completó".
- **Prohibido el gerundio** para encadenar acciones ("Cambiando X y pidiendo Y ..."). Reescribe siempre en forma declarativa con sujeto explícito y verbos en infinitivo: "Un actor de amenazas no autenticado podría alterar X, establecer Y y solicitar Z". Esta regla aplica especialmente en `## Descripción` e `## Impacto`.
- **Apertura canónica de `## Impacto`**: el primer párrafo abre con "Un actor de amenazas no autenticado podría ..." (o el nivel de privilegio que corresponda) + infinitivos. Párrafos siguientes pueden variar la apertura para fluidez ("Con esta información, un actor de amenazas podría ...", "La ausencia de ... permite ..."). Nada de bullets. Nunca usar "atacante"; siempre "actor de amenazas".
- **Apertura canónica de `## Contramedidas`**: el primer párrafo abre con "Para mitigar el presente hallazgo, se sugiere ..." + infinitivos. Párrafos siguientes pueden variar ("Adicionalmente, se sugiere ...", "Se sugiere también ..."). No repetir la misma fórmula en cada párrafo. El último párrafo es siempre la fórmula de *retest*. Nada de bullets.
- **Condicional para impactos**: `podría permitir`, `podría conducir`, `podría facilitar`, `podría obtener`.
- **Terminología obligatoria**: usar siempre "actor de amenazas" (nunca "atacante", "hacker", "adversario"). Nivel de privilegio: "no autenticado", "autenticado", "con rol corredor", etc.
- **Mitigaciones como acciones verificables**: `implementar control de acceso`, `validar pertenencia del recurso`, `rechazar IDs fuera del contexto`, `registrar intentos`, `limitar tasa`, `inmutabilizar campos identitarios`.
- **Secciones cortas**: 1 a 4 párrafos por sección, salvo PoC y tablas. Impacto y Contramedidas deben ser concisos (2-3 párrafos preferidos); evitar repetir la fórmula de apertura en cada párrafo.
- **PoC reproducible y fluida**: NO usar estructura rígida "Precondición: / Acción: / Resultado observado:" en cada paso. Escribir párrafos narrativos cortos en voz pasiva refleja. El primer paso de la PoC debe abrir con la frase introductoria: "Para reportar el presente hallazgo, se realizaron los siguientes pasos en un navegador configurado con la herramienta Burp Suite en modo *proxy*." (o variante apropiada si no se usa Burp). Luego, cada paso es un `### Paso N — Título corto` seguido de 1-3 frases fluidas que describan la acción y el resultado, más la captura. No usar listas ni encabezados internos dentro de cada paso.
- **Nunca** borres comentarios ni docstrings preexistentes del usuario; la regla `python-writer` también aplica aquí a cualquier snippet en las pruebas de concepto.
- **Capturas**: guarda en `img/<finding-id>-<n>.png`. Cita siempre con `![Descripción](img/Finding-01.png)` debajo del paso que las usa.
- **Placeholders permitidos**: `TODO`, `<organizacion>`, `<endpoint>`, `<user-id>`, `<resource-id>`, `<token-jwt>`, `<rut-prueba>`, `<id-poliza>`, `<host>`, o variables `$TOKEN`, `$RUT`, `$ID`. Ningún valor real de producción salvo URL pública (host sin path sensible).
- **No inventes** evidencias, URLs, adjuntos, tiempos ni CVSS. Si falta un dato, deja el espacio vacío o una marca `TODO` mínima.
- **CVSS**: elige siempre el vector, no solo el score. Adjunta el link a la calculadora FIRST si el vector es discutible.
- **Markdown sin hard-wrap**: una línea por párrafo (o por ítem de lista / celda de tabla). Deja que el renderizador haga el ajuste.

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
- `## Impacto` está en párrafos abriendo con "Un actor de amenazas ... podría ...".
- `## Contramedidas` está en párrafos abriendo con "Para mitigar el presente hallazgo, se sugiere ...", y termina con el párrafo de *retest*.
- No hay gerundios encadenando acciones ni primera persona.
- La PoC permite reproducir con navegador, Burp Suite o `curl` sin depender de conocimiento implícito.
- Las credenciales, tokens, cookies, firmas S3, RUT reales y datos personales están redactados.
- Las tablas `# Adjuntos` y `# Tiempos` existen aunque queden parcialmente vacías.
- El resultado es Markdown simple, sin HTML innecesario, sin hard-wrap y sin formato de informe ejecutivo Dreamlab.

## 9. Cuándo NO usar esta skill

- Informes ejecutivos completos en PDF: usan un formato distinto y no corresponden al Markdown técnico de hallazgos.
- Informes CIS, Table Top, auditorías de madurez, reportes forenses o documentos comerciales.
- Retests cortos: basta con añadir "Retest <fecha>: corregido / no corregido" en la sección `## Contramedidas` del hallazgo existente.
- Drafts muy tempranos de CTFs o ejercicios internos; ahí usa la estructura del proyecto correspondiente.
