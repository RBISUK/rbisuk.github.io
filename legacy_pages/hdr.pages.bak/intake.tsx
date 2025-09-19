import Head from "next/head";

export default function HDRIntake(){
  return (
    <>
      <Head>
        <title>HDR Intake — Guided Funnel</title>
        <meta name="description" content="Guided HDR intake with behavioural prompts, timeline, and evidence hints. Autosaves your progress." />
      </Head>
      <main style={{fontFamily:"system-ui", padding:"24px", maxWidth:980, margin:"0 auto"}}>
        <h1>HDR Intake</h1>
        <p>This is a sanity placeholder to prove the route exists. If you can see this, the 404 is fixed.</p>
        <p><a href="/hdr">Back to HDR</a></p>
      </main>
    </>
  );
}
