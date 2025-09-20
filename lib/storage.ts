import fs from "node:fs/promises";
import path from "node:path";

export type Funnel = {
  id: string;
  name: string;
  steps: any[];
  createdAt: string;
  updatedAt: string;
};

const ROOT = path.join(process.cwd(), "verdiex");
const FUNNELS = path.join(ROOT, "flows.json");
const EVENTS = path.join(ROOT, "events.json");

async function readJSON<T>(file: string, fallback: T): Promise<T> {
  try {
    const s = await fs.readFile(file, "utf8");
    return JSON.parse(s) as T;
  } catch {
    return fallback;
  }
}
async function writeJSON<T>(file: string, data: T) {
  await fs.mkdir(path.dirname(file), { recursive: true });
  await fs.writeFile(file, JSON.stringify(data, null, 2), "utf8");
}

/* Funnels CRUD */
export async function listFunnels(): Promise<Funnel[]> {
  return readJSON<Funnel[]>(FUNNELS, []);
}
export async function getFunnel(id: string): Promise<Funnel | undefined> {
  const all = await listFunnels();
  return all.find(f => f.id === id);
}
export async function createFunnel(input: Partial<Funnel>): Promise<Funnel> {
  const all = await listFunnels();
  const now = new Date().toISOString();
  const id = input.id ?? crypto.randomUUID();
  const item: Funnel = {
    id,
    name: input.name ?? "Untitled Funnel",
    steps: Array.isArray(input.steps) ? input.steps : [],
    createdAt: now,
    updatedAt: now,
  };
  all.push(item);
  await writeJSON(FUNNELS, all);
  return item;
}
export async function updateFunnel(
  id: string,
  patch: Partial<Funnel>
): Promise<Funnel | null> {
  const all = await listFunnels();
  const i = all.findIndex(f => f.id === id);
  if (i === -1) return null;
  all[i] = { ...all[i], ...patch, id, updatedAt: new Date().toISOString() };
  await writeJSON(FUNNELS, all);
  return all[i];
}
export async function deleteFunnel(id: string): Promise<boolean> {
  const all = await listFunnels();
  const next = all.filter(f => f.id !== id);
  if (next.length === all.length) return false;
  await writeJSON(FUNNELS, next);
  return true;
}

/* Events (optional) */
export async function listEvents(): Promise<any[]> {
  return readJSON<any[]>(EVENTS, []);
}
export async function appendEvent(evt: any): Promise<void> {
  const all = await listEvents();
  all.push({ ...evt, ts: new Date().toISOString() });
  await writeJSON(EVENTS, all);
}
