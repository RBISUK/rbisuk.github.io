import type { Config } from "tailwindcss";
const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: { extend: { colors: { rbis: { ink:"#0b1220", blue:"#2C3344", brand:"#07e59b", rose:"#f0595b", amber:"#ffbf3b" } } } },
  plugins: []
};
export default config;
