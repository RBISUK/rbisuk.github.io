export type ReportItem = {
  slug: string;
  title: string;
  org: string;
  category: "Repairs & Compliance" | "Complaints Timeliness" | "Escalation Audit" | "Ombudsman Readiness" | "Root Cause" | "Index";
  priceGBP?: number;         // optional – can be populated later
  summary?: string;
  href: string;              // public URL to the PDF
};

export const REPORTS: ReportItem[] = [
  {
    slug: "northbank-repairs-compliance",
    title: "Housing Repairs & Compliance Audit",
    org: "Northbank Borough Homes",
    category: "Repairs & Compliance",
    priceGBP: 495,
    summary: "Evidence-led sampling of repairs and statutory compliance.",
    href: "/reports/RBIS_Demo_Report_Northbank.pdf"
  },
  {
    slug: "northbank-stage1-timeliness",
    title: "Stage 1 Complaints Timeliness Review",
    org: "Northbank Borough Homes",
    category: "Complaints Timeliness",
    priceGBP: 295,
    summary: "Benchmarks Stage 1 responses vs. policy & Code of Practice.",
    href: "/reports/RBIS_Demo_Report_Northbank_Stage1.pdf"
  },
  {
    slug: "southmere-stage2-escalation",
    title: "Stage 2 Escalation Audit",
    org: "Southmere Housing Association",
    category: "Escalation Audit",
    priceGBP: 395,
    summary: "Checks whether escalation requests were processed/recorded.",
    href: "/reports/RBIS_Demo_Report_Southmere_Stage2.pdf"
  },
  {
    slug: "harper-ombudsman-readiness",
    title: "Ombudsman Determination Readiness",
    org: "Harper Lettings Ltd",
    category: "Ombudsman Readiness",
    priceGBP: 495,
    summary: "Pre-determination review against Ombudsman good practice.",
    href: "/reports/RBIS_Demo_Report_Harper_Ombudsman.pdf"
  },
  {
    slug: "riverbank-root-cause",
    title: "Complaints Root Cause Analysis",
    org: "Riverbank Housing Co-Op",
    category: "Root Cause",
    priceGBP: 595,
    summary: "Aggregates themes; isolates systemic drivers and fixes.",
    href: "/reports/RBIS_Demo_Report_Riverbank_RootCause.pdf"
  },
  {
    slug: "rbis-demo-master-index",
    title: "RBIS Demo Reports – Master Index",
    org: "RBIS Intelligence",
    category: "Index",
    summary: "Single view of the demonstration pack, with references.",
    href: "/reports/RBIS_DemoReports_Master_Index.pdf"
  }
];
