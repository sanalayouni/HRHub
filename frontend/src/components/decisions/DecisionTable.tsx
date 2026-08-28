import { useNavigate } from "react-router-dom";
import type { RequestListItem } from "../../api/types";
import { CategoryBadge } from "../common/CategoryBadge";
import { StatusBadge } from "../common/StatusBadge";
import { formatConfidence, formatDate, normalizeAiRecommendation } from "../../lib/labels";

export function DecisionTable({ items }: { items: RequestListItem[] }) {
  const navigate = useNavigate();

  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[720px] text-left text-sm">
        <thead>
          <tr className="border-b border-cream-soft text-xs uppercase tracking-wide text-ink-soft">
            <th className="px-5 py-3 font-medium">Employee</th>
            <th className="px-5 py-3 font-medium">Category</th>
            <th className="px-5 py-3 font-medium">AI Recommendation</th>
            <th className="px-5 py-3 font-medium">Confidence</th>
            <th className="px-5 py-3 font-medium">Final Decision</th>
            <th className="px-5 py-3 font-medium">Date</th>
          </tr>
        </thead>
        <tbody>
          {items.length === 0 && (
            <tr>
              <td colSpan={6} className="px-5 py-10 text-center text-ink-soft">
                No decisions match these filters.
              </td>
            </tr>
          )}
          {items.map((item) => {
            const ai = normalizeAiRecommendation(item.ai_recommendation);
            return (
              <tr
                key={item.id}
                onClick={() => navigate(`/requests/${item.id}`)}
                className="cursor-pointer border-b border-cream-soft last:border-0 hover:bg-cream transition-colors"
              >
                <td className="px-5 py-3 font-medium">
                  {item.employee_name ?? "Unknown Employee"}
                </td>
                <td className="px-5 py-3">
                  <CategoryBadge category={item.request_type} />
                </td>
                <td className="px-5 py-3">
                  <span className="inline-flex items-center gap-1.5 rounded-full border border-cream-soft bg-surface px-2.5 py-1 text-xs font-semibold">
                    <span className={`h-1.5 w-1.5 rounded-full ${ai.dotClassName}`} />
                    <span className={ai.className}>{ai.label}</span>
                  </span>
                </td>
                <td className="px-5 py-3 text-ink-soft">{formatConfidence(item.confidence)}</td>
                <td className="px-5 py-3">
                  <StatusBadge status={item.status} />
                </td>
                <td className="px-5 py-3 text-ink-soft">{formatDate(item.created_at)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
