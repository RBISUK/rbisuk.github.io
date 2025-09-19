export default function StickyCTA() {
  return (
    <div
      className="fixed inset-x-0 bottom-0 z-40 border-t border-neutral-200 bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/70"
      role="region"
      aria-label="Quick actions"
    >
      <div className="container py-3 flex items-center justify-between gap-3">
        <span className="text-sm font-medium">Ready to see RBIS in action?</span>
        <a href="/contact" className="btn-primary">Book a Demo</a>
      </div>
    </div>
  );
}
