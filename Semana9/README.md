# Semana 9 — Next.js + Perl (Mojolicious)

## Backend (Perl / Mojolicious)

1) Instala Mojolicious (una vez):

- Si tienes `cpanm`:

```powershell
cd .\Semana9\backend
cpanm Mojolicious
```

- Si NO tienes `cpanm`:

```powershell
cpan App::cpanminus
cd .\Semana9\backend
cpanm Mojolicious
```

2) Ejecuta el servidor en el puerto 3001:

```powershell
cd .\Semana9\backend
morbo -l http://localhost:3001 app.pl
```

Endpoint:

- `GET http://localhost:3001/saludo`
  - Respuesta JSON: `{ "mensaje": "Hola estudiante de Estructuras" }`

## Frontend (Next.js)

1) Instala dependencias y levanta el servidor:

```powershell
cd .\Semana9\frontend
npm install
npm run dev
```

2) Abre:

- `http://localhost:3000`

La página hace un `GET` al backend (`http://localhost:3001/saludo`) y muestra el mensaje centrado.
