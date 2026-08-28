import type { RequestDetail } from "../../api/types";

export function RequestContentCard({ request }: { request: RequestDetail }) {
  return (
    <div className="glass-card rounded-3xl p-5">
      <h2 className="mb-3 font-heading text-lg font-semibold">Original Request</h2>
      {request.summary && (
        <p className="mb-3 rounded-2xl bg-cream p-4 text-sm text-ink-soft">
          {request.summary}
        </p>
      )}
      <p className="whitespace-pre-wrap text-sm leading-relaxed text-ink">
        {request.request_text}
      </p>
    </div>
  );
}
