# Guía superdetallada — Semana 9 (Next.js + Perl con Mojolicious)

Esta guía documenta **paso a paso** lo que se hizo para construir:

- Un **backend en Perl** usando **Mojolicious** con un endpoint `GET /saludo`.
- Un **frontend en Next.js (React)** que hace una petición **GET** al backend y **muestra el texto centrado**.

La meta final fue que el navegador muestre:

> Hola estudiante de Estructuras

tomándolo desde el backend.

---

## 0) Requisitos previos (Windows)

### 0.1 Node.js / npm

- Tener Node.js instalado (incluye `npm`).
- Verificación rápida:

```powershell
node -v
npm -v
```

### 0.2 Perl

- Tener Perl instalado (por ejemplo Strawberry Perl en Windows).
- Verificación rápida:

```powershell
perl -v
```

### 0.3 Mojolicious

El backend usa el módulo `Mojolicious`.

Opción A (recomendada): instalar `cpanm` y luego Mojolicious:

```powershell
cpan App::cpanminus
cpanm Mojolicious
```

Opción B (si ya tienes `cpanm`):

```powershell
cpanm Mojolicious
```

Verificación rápida (si el comando existe):

```powershell
morbo -h
```

---

## 1) Estructura creada en Semana 9

Se crearon dos carpetas dentro de `Semana9`:

- `Semana9/backend` → servidor Perl (Mojolicious)
- `Semana9/frontend` → app Next.js

Estructura relevante:

```text
Semana9/
	backend/
		app.pl
		cpanfile
	frontend/
		package.json
		src/
			app/
				page.tsx
	README.md
	Guia.md
```

---

## 2) Construcción del BACKEND (Perl + Mojolicious)

### 2.1 Crear carpeta del backend

Se creó la ruta:

- `Semana9/backend`

### 2.2 Crear el archivo principal del servidor

Se creó el archivo [Semana9/backend/app.pl](Semana9/backend/app.pl) con estas responsabilidades:

1) **Levantar un servidor web** usando `Mojolicious::Lite`.
2) Exponer un endpoint `GET /saludo`.
3) Responder en JSON con la clave `mensaje`.
4) Configurar **CORS** para permitir que el frontend (puerto 3000) pueda consumir el endpoint (puerto 3001).

#### 2.2.1 ¿Qué endpoint se implementó?

- Ruta: `GET /saludo`
- Respuesta:

```json
{ "mensaje": "Hola estudiante de Estructuras" }
```

#### 2.2.2 ¿Por qué se agregó CORS?

El frontend corre en `http://localhost:3000` y el backend en `http://localhost:3001`.
Como son **orígenes distintos (puerto distinto)**, el navegador bloquea peticiones por seguridad si el backend no permite CORS.

Por eso se añadieron headers:

- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type`

Y adicionalmente una ruta:

- `OPTIONS /saludo`

Esto cubre los casos de “preflight” (aunque un GET simple normalmente no lo requiere, es una configuración robusta y evita sorpresas).

### 2.3 Registrar la dependencia

Se creó el archivo [Semana9/backend/cpanfile](Semana9/backend/cpanfile) con:

- `requires 'Mojolicious', '>= 9.0';`

Esto documenta que el proyecto necesita Mojolicious.

### 2.4 Levantar el backend

Ubícate en la carpeta del backend:

```powershell
cd .\Semana9\backend
```

Levanta el servidor en el puerto 3001:

```powershell
morbo -l http://localhost:3001 app.pl
```

Notas:

- `morbo` es el servidor de desarrollo de Mojolicious.
- `-l http://localhost:3001` fuerza el puerto `3001`.

### 2.5 Probar el endpoint del backend (sin frontend)

En otra terminal, prueba con PowerShell:

```powershell
Invoke-RestMethod http://localhost:3001/saludo
```

Debe devolver algo similar a:

```text
mensaje
-------
Hola estudiante de Estructuras
```

Si falla:

- Verifica que el backend sigue corriendo (la terminal del `morbo` no debe estar cerrada).
- Verifica el puerto `3001`.

---

## 3) Construcción del FRONTEND (Next.js)

### 3.1 Inicializar el proyecto Next.js

Se creó el proyecto en `Semana9/frontend` con `create-next-app`.

Se usó configuración:

- TypeScript
- App Router
- ESLint
- Sin Tailwind

Comando equivalente (desde `Semana9`):

```powershell
npx --yes create-next-app@latest frontend --ts --eslint --app --src-dir --no-tailwind --use-npm
```

Esto genera toda la estructura base de Next.js.

### 3.2 Modificar la pantalla principal

Se editó [Semana9/frontend/src/app/page.tsx](Semana9/frontend/src/app/page.tsx) para:

1) Ejecutar un `fetch` al backend `http://localhost:3001/saludo`.
2) Leer el JSON (`{ mensaje: string }`).
3) Guardar el texto en estado (`useState`).
4) Mostrar el texto centrado usando un contenedor flex.

#### 3.2.1 ¿Por qué el archivo tiene `"use client"`?

En Next.js App Router, los componentes son Server Components por defecto.
Como usamos hooks (`useEffect`, `useState`) y `fetch` desde el navegador, se necesita marcar el componente como **Client Component**:

- `"use client"`

#### 3.2.2 ¿Cómo se centró el texto?

Se hizo centrado vertical + horizontal con estilos inline en el `<main>`:

- `display: "flex"`
- `alignItems: "center"`
- `justifyContent: "center"`
- `textAlign: "center"`

Esto cumple exactamente el requerimiento de “solo centrado el texto”.

#### 3.2.3 Manejo básico de errores

Se dejó un manejo simple para que si el backend no responde, el usuario vea:

- `Error: <status>` si el HTTP no es 200
- `Error al conectar con el backend` si no hay conexión

### 3.3 Levantar el frontend

En una terminal:

```powershell
cd .\Semana9\frontend
npm install
npm run dev
```

Luego abrir:

- `http://localhost:3000`

Si el backend está activo, verás el texto del backend **centrado** en la pantalla.

---

## 4) Cómo se conectan FRONTEND y BACKEND

### 4.1 Puertos usados

- Frontend Next.js: `http://localhost:3000`
- Backend Mojolicious: `http://localhost:3001`

### 4.2 URL exacta consumida por el frontend

El frontend hace:

- `GET http://localhost:3001/saludo`

### 4.3 Formato de respuesta esperado

El frontend espera JSON con esta forma:

```ts
type SaludoResponse = { mensaje: string };
```

Si cambias el backend para responder otra cosa, también debes actualizar el frontend.

---

## 5) Checklist de ejecución (lo mínimo para que funcione)

1) Abrir 2 terminales.
2) Terminal A (backend):

```powershell
cd .\Semana9\backend
morbo -l http://localhost:3001 app.pl
```

3) Terminal B (frontend):

```powershell
cd .\Semana9\frontend
npm run dev
```

4) Abrir `http://localhost:3000`.

---

## 6) Problemas comunes y solución rápida

### 6.1 “Error al conectar con el backend”

- El backend no está corriendo.
- Estás usando otro puerto.
- Mojolicious no está instalado.

Solución:

```powershell
cd .\Semana9\backend
cpanm Mojolicious
morbo -l http://localhost:3001 app.pl
```

### 6.2 CORS bloqueando la petición

Si ves errores CORS en la consola del navegador:

- Asegúrate de estar usando el archivo [Semana9/backend/app.pl](Semana9/backend/app.pl) tal como está (incluye headers CORS).

### 6.3 `morbo` no se reconoce

- Mojolicious no está instalado, o el PATH de Perl no está bien.

Verifica:

```powershell
perl -v
cpanm -V
```

---

## 7) Referencias dentro del proyecto

- Backend:
	- [Semana9/backend/app.pl](Semana9/backend/app.pl)
	- [Semana9/backend/cpanfile](Semana9/backend/cpanfile)
- Frontend:
	- [Semana9/frontend/src/app/page.tsx](Semana9/frontend/src/app/page.tsx)
- Instrucciones cortas:
	- [Semana9/README.md](Semana9/README.md)

