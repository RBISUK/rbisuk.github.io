import EditClient from "./ui";

export const metadata = { title: "Edit Funnel | Veridex Admin" };

export default function Page({ params }: { params: { id: string } }) {
  return <EditClient id={params.id} />;
}
