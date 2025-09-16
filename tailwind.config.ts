import type { Config } from "tailwindcss";
<<<<<<< HEAD
const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: { extend: { colors: { rbis: { ink:"#0b1220", blue:"#2C3344", brand:"#07e59b", rose:"#f0595b", amber:"#ffbf3b" } } } },
  plugins: []
};
export default config;
=======

export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./pages/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: { extend: {} },
  plugins: []
} satisfies Config;
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
