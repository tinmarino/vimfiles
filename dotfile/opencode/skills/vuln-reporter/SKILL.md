---
name: vuln-reporter
description: "Redacta hallazgos de pentest en español usando el formato Markdown de CyScope (11 secciones: Title, CVSS, Sistemas afectados, Descripción, Impacto, Contramedidas, Referencias, Solicitud, Parámetro vulnerable, Carga, Prueba de concepto + tablas Adjuntos/Tiempos). Activar siempre que un consultor redacte, convierta o revise un hallazgo técnico de auditoría en español para CyScope."
license: MIT
compatibility: opencode
metadata:
  audience: opencode-agents
  language: es
---

# vuln-reporter

Escribe hallazgos de auditorías en el formato canónico de CyScope. Texto en **español neutro**; código, comandos y nombres de archivos en inglés. Úsame antes de editar cualquier hallazgo Markdown, informe técnico o plantilla destinada a CyScope.

## 1. Estructura obligatoria (11 secciones + tablas)

Toda vulnerabilidad reportada debe respetar exactamente este orden y estos títulos en nivel H2 después de `# Informe`:

1. `## Title` — una frase, en español, imperativa o declarativa. Ejemplo: "Acceso no autorizado a documentos PDF mediante IDOR en el endpoint `/documents/{id}`".
2. `## CVSS` — vector completo v3.1 + score. Ejemplo: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N (7.5 - Alto)`.
3. `## Sistemas afectados` — lista viñetada con host, endpoint y cualquier identificador de ambiente, cuenta o usuario de prueba.
4. `## Descripción` — 2 a 4 párrafos en tiempo pretérito/presente y voz pasiva refleja ("Se identificó ..."). Describe la falla sin impacto ni mitigación.
5. `## Impacto` — 2 a 4 párrafos en condicional ("podría conducir a ..."). Enumera lo que un atacante obtendría o podría hacer.
6. `## Contramedidas` — recomendaciones técnicas primero y luego proceso, como retests o cláusulas contractuales. Siempre termina con: "Se recomienda, después de la mitigación, implementar pruebas de no regresión de seguridad y solicitar un retest.".
7. `## Referencias` — lista numerada. CWE y OWASP primero, siempre con URL `https://`; luego artefactos internos como URLs, repositorios o dashboards. Usa `---` como separador entre sub-listas.
8. `## Solicitud` — un fenced block ` ```text `; pega aquí la solicitud HTTP completa (método, path, headers, body). Oculta tokens (`Authorization: Bearer ...`).
9. `## Parámetro vulnerable` — nombre exacto del parámetro (path variable, query-string key, body field, header), sin explicación larga.
10. `## Carga` — un fenced block ` ```bash ` con un `curl` o `HTTPie` reproducible, listo para copy-paste; usa `$TOKEN`, `$USER_ID`, `$RESOURCE_ID` o placeholders equivalentes.
11. `## Prueba de concepto` — subsecciones `### Paso 1`, `### Paso 2`, ... Cada paso incluye 1 a 2 párrafos y capturas referenciadas (`![...](./img/<n>.png)`). Reserva al menos 5 pasos para vulnerabilidades no triviales.

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

## 2. Reglas de estilo

- **Idioma**: español neutro. *Endpoint*, *proxy*, *token* y demás términos técnicos van entre *cursivas* (`*endpoint*`).
- **Voz pasiva refleja** para narrar: "se identificó", "se reportó", "se alteró". Evita primera persona.
- **Nunca** borres comentarios ni docstrings preexistentes del usuario; la regla `python-writer` también aplica aquí a cualquier snippet en las pruebas de concepto.
- **Capturas**: guarda en `img/<finding-id>-<n>.png`. Cita siempre con `![Descripción](img/Finding-01.png)` debajo del paso que las usa.
- **Placeholders permitidos**: `TODO`, `<organizacion>`, `<endpoint>`, `<user-id>`, `<resource-id>`, `<token-jwt>`. Ningún valor real de producción salvo URL pública (host sin path sensible).
- **CVSS**: elige siempre el vector, no solo el score. Adjunta el link a la calculadora FIRST si el vector es discutible.

## 3. Selección de plantilla

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

## 4. Comando mental para redactar

1. **Lee** el Markdown de referencia si necesitas refrescar las secciones.
2. **Lee** 2 a 3 hallazgos reales de la misma categoría para alinear tono.
3. **Copia** la plantilla de la categoría que mejor calce, si existe una en el repositorio o en la base de conocimiento del equipo.
4. **Rellena** sin alterar títulos; deja las secciones que no aplican vacías (no pongas "N/A").
5. **Verifica** que la sección `## Prueba de concepto` tenga pasos numerados en orden, con enlaces a capturas.
6. **Revisa** que CVSS esté calculado con base a CIA real, no copiado del hallazgo anterior.
7. **Adjunta** archivos en `img/` y cárgalos en la tabla Adjuntos.
8. **Cronometra** las tres tareas (Encontrar / Explotar / Reportar) en la tabla Tiempos.

## 5. Cuándo NO usar esta skill

- Informes ejecutivos completos en PDF: usan un formato distinto y no corresponden al Markdown técnico de hallazgos.
- Retests cortos: basta con añadir "Retest <fecha>: corregido / no corregido" en la sección `## Contramedidas` del hallazgo existente.
- Drafts muy tempranos de CTFs o ejercicios internos; ahí usa la estructura del proyecto correspondiente.
