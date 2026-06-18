import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Óculos Store — Sistema de Gestão" },
      { name: "description", content: "Sistema de gestão de ordens de serviço da Óculos Store." },
      { property: "og:title", content: "Óculos Store — Sistema de Gestão" },
      { property: "og:description", content: "Sistema de gestão de ordens de serviço da Óculos Store." },
    ],
  }),
  component: Index,
});

function Index() {
  useEffect(() => {
    window.location.replace("app.html");
  }, []);
  return (
    <div style={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: "#f5f2ee", fontFamily: "system-ui, sans-serif", color: "#6B7C64" }}>
      Carregando Óculos Store…
    </div>
  );
}
