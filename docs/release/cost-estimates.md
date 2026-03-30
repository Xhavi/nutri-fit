# NutriFit V1 — Costos y escenarios (100 / 500 / 1000 usuarios)

Estado: estimación base para decisión de lanzamiento.
Fecha: 2026-03-30.

## 1) Objetivo de este documento

Estimar unit economics iniciales para Android-first con modelo freemium:

- Precio premium IA: **USD $4.99/mes**.
- Billing: **Google Play Billing**.
- Infra: **Firebase Blaze + OpenAI API server-side**.
- IA de lanzamiento: **principalmente texto** (voz no obligatoria para V1).

> Estas cifras son aproximaciones de planeación, no forecast financiero final.

## 2) Supuestos explícitos (marcados)

### 2.1 Supuestos comerciales

1. **Usuarios activos mensuales totales (MAU)** por escenario: 100, 500, 1000.
2. **Tasa de conversión a premium IA (supuesto): 8%** de MAU.
   - Justificación: app freemium nueva con paywall temprano suele iniciar en un dígito.
3. **Precio mensual premium:** USD $4.99.
4. **Fee Google Play (supuesto base): 15%** sobre ingresos de suscripción.
   - Nota: si aplicara 30%, se incluye sensibilidad al final.

### 2.2 Supuestos técnicos (prudentes)

5. **Costo OpenAI por suscriptor premium/mes (texto): USD $0.80 a $2.50**.
   - Incluye prompts + respuestas + margen por picos/uso desigual.
   - Es rango deliberadamente conservador para etapa inicial.
6. **Costo Firebase Blaze + Functions + Firestore + Auth + logging (base):**
   - 100 MAU: **USD $20–$40/mes**
   - 500 MAU: **USD $40–$90/mes**
   - 1000 MAU: **USD $70–$160/mes**
7. **Otros costos operativos mínimos (dominio/email/monitoring liviano): USD $15–$40/mes**.

> Si cambian cuotas de uso IA o frecuencia de mensajes, el costo de OpenAI es la variable más sensible.

## 3) Fórmulas usadas

- **Suscriptores premium** = MAU × conversión.
- **Ingresos brutos** = suscriptores × 4.99.
- **Fee Play** = ingresos brutos × 15%.
- **Ingresos netos antes de IA** = ingresos brutos − fee Play.
- **Costo OpenAI** = suscriptores × (0.80 a 2.50).
- **Costo técnico total** = costo OpenAI + Firebase + otros.
- **Margen operativo estimado** = neto antes IA − costo técnico total.

## 4) Escenarios

## Escenario A — 100 usuarios (MAU)

- Premium (8%): **8 suscriptores**.
- Ingresos brutos: **USD $39.92**.
- Fee Play (15%): **USD $5.99**.
- Neto antes IA: **USD $33.93**.

Costos técnicos estimados:
- OpenAI: **USD $6.40 – $20.00**.
- Firebase Blaze: **USD $20 – $40**.
- Otros: **USD $15 – $40**.
- **Total técnico:** **USD $41.40 – $100.00**.

Resultado estimado:
- **Margen operativo:** **USD -66.07 a -7.47** (pérdida esperable en etapa temprana).

## Escenario B — 500 usuarios (MAU)

- Premium (8%): **40 suscriptores**.
- Ingresos brutos: **USD $199.60**.
- Fee Play (15%): **USD $29.94**.
- Neto antes IA: **USD $169.66**.

Costos técnicos estimados:
- OpenAI: **USD $32.00 – $100.00**.
- Firebase Blaze: **USD $40 – $90**.
- Otros: **USD $15 – $40**.
- **Total técnico:** **USD $87.00 – $230.00**.

Resultado estimado:
- **Margen operativo:** **USD -60.34 a +82.66** (zona de equilibrio probable según uso IA real).

## Escenario C — 1000 usuarios (MAU)

- Premium (8%): **80 suscriptores**.
- Ingresos brutos: **USD $399.20**.
- Fee Play (15%): **USD $59.88**.
- Neto antes IA: **USD $339.32**.

Costos técnicos estimados:
- OpenAI: **USD $64.00 – $200.00**.
- Firebase Blaze: **USD $70 – $160**.
- Otros: **USD $15 – $40**.
- **Total técnico:** **USD $149.00 – $400.00**.

Resultado estimado:
- **Margen operativo:** **USD -60.68 a +190.32** (depende de disciplina de cuotas IA).

## 5) Sensibilidad rápida (fee de tienda)

Si el fee de Play fuera **30%** en lugar de 15%:

- Neto antes IA cae en ~15% de ingresos brutos adicionales.
- Impacto aproximado en neto mensual:
  - 100 MAU: -USD $5.99 adicional.
  - 500 MAU: -USD $29.94 adicional.
  - 1000 MAU: -USD $59.88 adicional.

## 6) Riesgos principales de costos

1. **Sobrecosto OpenAI por usuarios intensivos** (prompt largos, muchas sesiones).
2. **Conversión premium menor al 8%** durante primeros meses.
3. **Errores de verificación billing** que provoquen pérdida de ingresos o soporte alto.
4. **Costo de soporte** por fricción en compras/cancelaciones.

## 7) Recomendaciones para proteger margen V1

- Arrancar con cuotas IA premium conservadoras y visibles.
- Medir costo IA por suscriptor semanalmente.
- Ajustar prompt/longitud máxima para controlar tokens.
- Automatizar reconciliación de suscripciones (RTDN o job diario).
- Mantener voz como opcional (o apagada) hasta validar economía de texto.

## 8) Datos faltantes para pasar de estimación a presupuesto

Para refinar a presupuesto real faltan:

- Consumo promedio real de tokens por usuario premium (p50/p90).
- Conversión premium real por cohorte.
- Tasa de cancelación mensual (churn).
- Política de fee Play efectiva según cuenta/programa.
- Costo real de soporte operativo por ticket.
