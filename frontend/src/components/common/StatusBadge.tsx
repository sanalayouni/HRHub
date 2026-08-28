import { STATUS_CLASSES, STATUS_DOT_CLASSES, STATUS_LABELS } from "../../lib/labels";
import type { DecisionStatus } from "../../api/types";

export function StatusBadge({ status }: { status: DecisionStatus }) {
  return (
    <span className="inline-flex items-center gap-1.5 rounded-full border border-cream-soft bg-surface px-3 py-1 text-xs font-semibold">
      <span className={`h-1.5 w-1.5 rounded-full ${STATUS_DOT_CLASSES[status]}`} />
      <span className={STATUS_CLASSES[status]}>{STATUS_LABELS[status]}</span>
    </span>
  );
}
