import type { ReactNode } from "react";

export function FolderCard({ children }: { children: ReactNode }) {
  return (
    <div className="relative mt-9">
      <div className="glass-card absolute left-6 top-0 h-11 w-52 -translate-y-8 rounded-t-2xl" />
      <div className="glass-card relative z-10 rounded-2xl">
        {children}
      </div>
    </div>
  );
}
