import { Link } from "react-router-dom";
import type { RecentDecisionItem } from "../../api/types";
import { CategoryBadge } from "../common/CategoryBadge";
import { StatusBadge } from "../common/StatusBadge";
import { formatDate } from "../../lib/labels";

export function RecentDecisionsFeed({ items }: { items: RecentDecisionItem[] }) {
  return (
    <div className="glass-card rounded-3xl p-5">
      <h2 className="mb-4 font-heading text-lg font-semibold">Recent Decisions</h2>
      {items.length === 0 ? (
        <p className="py-8 text-center text-sm text-ink-soft">
          No decisions made yet.
        </p>
      ) : (
        <ul className="flex flex-col gap-2">
          {items.map((item) => (
            <li key={item.request_id}>
              <Link
                to={`/requests/${item.request_id}`}
                className="flex items-center justify-between gap-3 rounded-2xl px-2 py-2 hover:bg-cream transition-colors"
              >
                <div className="flex items-center gap-2 min-w-0">
                  <CategoryBadge category={item.request_type} />
                  <span className="truncate text-sm font-medium">
                    {item.employee_name ?? "Unknown Employee"}
                  </span>
                </div>
                <div className="flex shrink-0 items-center gap-3">
                  <span className="text-xs text-ink-soft">
                    {formatDate(item.updated_at)}
                  </span>
                  <StatusBadge status={item.status as "approved" | "rejected"} />
                </div>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
