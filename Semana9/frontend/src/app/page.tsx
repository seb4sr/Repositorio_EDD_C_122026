"use client";

import { useEffect, useState } from "react";

type SaludoResponse = {
  mensaje: string;
};

export default function Home() {
  const [mensaje, setMensaje] = useState<string>("");

  useEffect(() => {
    const controller = new AbortController();

    (async () => {
      try {
        const res = await fetch("http://localhost:3001/saludo", {
          method: "GET",
          signal: controller.signal,
        });

        if (!res.ok) {
          setMensaje(`Error: ${res.status}`);
          return;
        }

        const data = (await res.json()) as SaludoResponse;
        setMensaje(data.mensaje);
      } catch (err) {
        if (err instanceof DOMException && err.name === "AbortError") return;
        setMensaje("Error al conectar con el backend");
      }
    })();

    return () => controller.abort();
  }, []);

  return (
    <main
      style={{
        flex: 1,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        textAlign: "center",
        padding: 24,
        fontSize: 54,
      }}
    >
      <div
        style={{
          backgroundColor: "var(--foreground)",
          color: "var(--background)",
          padding: "18px 28px",
          borderRadius: 14,
          fontWeight: 600,
          lineHeight: 1.2,
        }}
      >
        {mensaje}
      </div>
    </main>
  );
}
