export default function Contact(){
  return (
    <main style={{padding:"2rem", fontFamily:"system-ui", lineHeight:1.5, maxWidth:720, margin:"0 auto"}}>
      <h1>Smart Enquiries</h1>
      <p>Every enquiry is structured, time-stamped, and routed securely to Contact@RBISIntelligence.com.</p>
      <form method="post" action="#" style={{display:"grid", gap:12}}>
        <input required placeholder="Name" name="name" style={{padding:10, border:"1px solid #ccc", borderRadius:8}} />
        <input required type="email" placeholder="Email" name="email" style={{padding:10, border:"1px solid #ccc", borderRadius:8}} />
        <select name="area" style={{padding:10, border:"1px solid #ccc", borderRadius:8}}>
          <option>Consulting</option>
          <option>Veridex</option>
          <option>PACT Ledger</option>
          <option>Other</option>
        </select>
        <textarea required placeholder="Message" name="message" rows={5} style={{padding:10, border:"1px solid #ccc", borderRadius:8}} />
        <label style={{display:"flex", gap:8, alignItems:"center"}}>
          <input type="checkbox" required />
          <span>I agree to RBIS processing my enquiry in line with the <a href="/privacy">Privacy Policy</a>.</span>
        </label>
        <label style={{display:"flex", gap:8, alignItems:"center"}}>
          <input type="checkbox" />
          <span>I consent to receive marketing updates from RBIS (optional).</span>
        </label>
        <button type="submit" style={{padding:"12px 16px", background:"#111", color:"#fff", border:"none", borderRadius:8}}>Submit</button>
      </form>
    </main>
  );
}
