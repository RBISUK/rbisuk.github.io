import React from "react";
import { createRoot } from "react-dom/client";
import LegalHub from "./LegalHub";

const container = document.getElementById("root");
if (container) {
  createRoot(container).render(<LegalHub />);
}
