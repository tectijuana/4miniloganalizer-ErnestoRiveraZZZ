<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/a44bb0d7-30f9-4fff-95bf-f08277476255" />

# Práctica 1: Mini Cloud Log Analyzer en ARM64

**Autor:** Ernesto Ezequiel Rivera Calderon  
**No. de Control:** 23212061  
**Profesor:** René Solís Reyes  
**Entorno de Trabajo:** AWS Ubuntu 24 ARM64  
**Variante Asignada:** A (Contabilizar códigos 2xx, 4xx y 5xx)

---

## 1. Descripción del Proyecto

Este proyecto consiste en un analizador de logs de servidor desarrollado nativamente en **ARM64 Assembly (AArch64 Linux)**. El programa lee secuencias de códigos de estado HTTP suministrados mediante la entrada estándar (`stdin`) y realiza un conteo categórico.

Todo el procesamiento se realiza interactuando directamente con el kernel de Linux a través de **syscalls** (`read`, `write`, `exit`), cumpliendo con la estricta restricción de no utilizar la biblioteca estándar de C (`libc`) ni lenguajes de alto nivel.

---

## 2. Diseño y Lógica de Implementación

Para optimizar el rendimiento y minimizar el uso de memoria y ciclos de CPU, el programa no convierte cadenas de texto completas a enteros. En su lugar, utiliza un enfoque eficiente basado en el análisis de caracteres ASCII:

1. **Lectura por bloques (Buffer):** Se utiliza el syscall `read` para cargar fragmentos de la entrada estándar en un buffer temporal alojado en la sección `.bss`, reduciendo masivamente la cantidad de llamadas al sistema en comparación con leer byte por byte.
2. **Detección de inicio de línea:** Se itera sobre el buffer buscando el carácter de salto de línea (`\n` o ASCII 10).
3. **Clasificación directa en ASCII:** Al detectar el inicio de una nueva línea, el programa captura únicamente el **primer byte** del código HTTP y lo evalúa:
   - Si es `'2'` (ASCII 50) -> Incrementa contador de Éxitos (2xx).
   - Si es `'4'` (ASCII 52) -> Incrementa contador de Errores de Cliente (4xx).
   - Si es `'5'` (ASCII 53) -> Incrementa contador de Errores de Servidor (5xx).
4. **Manejo de Registros:** Se emplearon registros *callee-saved* para evitar pérdida de datos durante el flujo de ejecución.
   - `x19`: Contador total de códigos 2xx.
   - `x20`: Contador total de códigos 4xx.
   - `x21`: Contador total de códigos 5xx.

---

## 3. Instrucciones de Ejecución

El repositorio incluye un archivo `Makefile` preconfigurado para automatizar el ensamblado, enlazado y ejecución del código fuente en entornos ARM64.

### 3.1 Compilar el proyecto
`make`

### 3.2 Ejecutar con los datos de prueba base
`make run`
*(Alternativa de ejecución manual: `cat data/logs_A.txt | ./src/analyzer`)*

### 3.3 Ejecutar suite de pruebas automatizadas
`make test`

### 3.4 Limpiar el entorno (eliminar binarios y objetos)
`make clean`

---

## 4. Evidencia de Ejecución (Asciinema)

Para validar la correcta compilación y el funcionamiento del programa en el entorno AWS (demostrando la autoría y la ejecución pura del ensamblador), se ha documentado el proceso mediante Asciinema.

https://asciinema.org/a/dfyoBYQRdyc6NYMk

---

## 5. Estructura del Repositorio

```text
cloud-log-analyzer/
├── README.md                 # Documentación técnica del estudiante
├── Makefile                  # Script de automatización de compilación
├── run.sh                    # Script auxiliar de ejecución
├── src/
│   └── analyzer.s            # Código fuente principal en ARM64 Assembly
├── data/
│   └── logs_A.txt            # Dataset de prueba para Variante A
├── tests/
│   ├── test.sh               # Script de validación
│   └── expected_outputs.txt  # Resultados esperados para las pruebas
└── instructor/
    └── VARIANTES.md          # Especificaciones originales de la práctica
## 6) Instrucciones de uso en AWS Ubuntu 24 ARM64

### 6.1 Compilar

```bash
make
```

### 6.2 Ejecutar ejemplo base

```bash
make run
```

### 6.3 Ejecutar pruebas

```bash
make test
```

### 6.4 Limpiar artefactos

```bash
make clean
```

---

## 7) Variantes de práctica

- **A**: contar 2xx, 4xx, 5xx.
- **B**: encontrar código más frecuente.
- **C**: detectar primer 503.
- **D**: detectar 3 errores consecutivos.
- **E**: calcular health score.

Detalles de asignación docente: ver `instructor/VARIANTES.md`.

---

## 8) Rúbrica propuesta

Toda solución debe tener:
1. Encabezado del programador
2. Pseudocódigo
3. Código ARM64 comentado

| Criterio | Ponderación |
|---|---:|
| Correctitud funcional de la variante asignada | 40% |
| Dominio técnico de ARM64 + syscalls | 25% |
| Pruebas automatizadas y reproducibilidad | 20% |
| Calidad de documentación y claridad de código | 15% |

### Criterios de descuento sugeridos
- No compila en ARM64: hasta -40%.
- Usa C/libc: evaluación inválida por incumplir restricción.
- Sin evidencia de pruebas: hasta -20%. Utiliar Asciinema (con su nombre y preferente), o tambien LOOM.com compartido link

---

## 9) Notas para estudiantes

- Lean y entiendan el pseudocódigo al inicio de `src/analyzer.s`.
- Mantengan comentarios técnicos claros y breves.
- Trabajen incrementalmente: primero parser, luego lógica de variante, luego pruebas.
- Si trabajan en host x86_64, se recomienda emulación con `qemu-aarch64` o compilar/ejecutar directamente en AWS ARM64.
