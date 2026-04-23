[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/EbtZGzoI)
[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=23668714)

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
```
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


## 7. Conclusiones

El desarrollo de este analizador demuestra la viabilidad y eficiencia de utilizar **Assembly ARM64** para tareas críticas de procesamiento de texto. Al prescindir de la sobrecarga de la biblioteca estándar de C (`libc`) y gestionar directamente las llamadas al sistema operativo, se logra una huella de memoria minúscula y un tiempo de ejecución altamente optimizado, ideal para entornos de Cloud Computing donde la eficiencia de recursos es fundamental.

