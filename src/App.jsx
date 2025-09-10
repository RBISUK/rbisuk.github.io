import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LegalHub, { RBISCookieGate, RBISFooterLegal, RBISConsentSnippet } from "./LegalHub";

function AppLayout() {
  return (
    <Router>
      <RBISCookieGate />
      {/* header goes here */}
      <Routes>
        {/* other routes */}
        <Route path="/legal" element={<LegalHub />} />
      </Routes>
      <footer>
        <RBISFooterLegal />
      </footer>
    </Router>
  );
}

export default AppLayout;
export { RBISConsentSnippet };
