<<<<<<< HEAD
import FloatBubbles from '@/app/components/FloatBubbles';

export default function RBISHome() {
  return (
    <main className="relative overflow-hidden min-h-screen flex items-center justify-center">
      <FloatBubbles />
      <div className="relative z-10 text-center">
        <h1 className="text-4xl font-bold">RBIS Intelligence</h1>
        <p className="mt-4 text-lg text-slate-600">
          Behavioural & Intelligence Services Showcase
        </p>
      </div>
    </main>
  );
}
=======
import { redirect } from 'next/navigation';
export default function Root() { redirect('/main'); }
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
