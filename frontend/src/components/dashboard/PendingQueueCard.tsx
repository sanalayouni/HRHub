import { Link } from "react-router-dom";
import { ArrowUpRight } from "lucide-react";
import type { RequestListItem } from "../../api/types";
import { CategoryBadge } from "../common/CategoryBadge";
import { formatConfidence, normalizeAiRecommendation } from "../../lib/labels";

export function PendingQueueCard({ requests }: { requests: RequestListItem[] }) {
  return (
    <div className="glass-card rounded-3xl p-5">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="font-heading text-lg font-semibold">Pending Requests</h2>
        <Link
          to="/requests"
          className="flex items-center gap-1 text-xs font-medium text-ink-soft hover:text-ink"
        >
          View all <ArrowUpRight className="h-3.5 w-3.5" />
        </Link>
      </div>

      {requests.length === 0 ? (
        <p className="py-8 text-center text-sm text-ink-soft">
          Nothing waiting on you right now.
        </p>
      ) : (
        <ul className="flex flex-col gap-2">
          {requests.slice(0, 6).map((req) => {
            const ai = normalizeAiRecommendation(req.ai_recommendation);
            return (
              <li key={req.id}>
                <Link
                  to={`/requests/${req.id}`}
                  className="flex items-center justify-between gap-3 rounded-2xl bg-cream px-4 py-3 hover:bg-cream-soft transition-colors"
                >
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <CategoryBadge category={req.request_type} />
                      <span className="truncate text-sm font-medium">
                        {req.employee_name ?? "Unknown Employee"}
                      </span>
                    </div>
                    <p className="mt-1 truncate text-xs text-ink-soft">
                      {req.summary ?? "No summary available"}
                    </p>
                  </div>
                  <div className="flex shrink-0 items-center gap-2">
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-cream-soft bg-surface px-2.5 py-1 text-xs font-semibold">
                      <span className={`h-1.5 w-1.5 rounded-full ${ai.dotClassName}`} />
                      <span className={ai.className}>{ai.label}</span>
                    </span>
                    <span className="text-xs text-ink-soft">
                      {formatConfidence(req.confidence)}
                    </span>
                  </div>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
