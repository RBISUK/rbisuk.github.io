import FloatBubbles from '@/app/components/FloatBubbles';

export default function HDRHome() {
  return (
    <main className="relative overflow-hidden min-h-screen flex items-center justify-center">
      <FloatBubbles />
      <div className="relative z-10 text-center">
        <h1 className="text-4xl font-bold">Claim-Fix-AI</h1>
        <p className="mt-4 text-lg text-slate-600">
          Audit-ready housing disrepair funnel.
        </p>
      </div>
    </main>
  );
}
