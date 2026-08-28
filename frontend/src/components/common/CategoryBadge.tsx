import { CATEGORY_CLASSES, CATEGORY_DOT_CLASSES, CATEGORY_LABELS } from "../../lib/labels";
import type { RequestCategory } from "../../api/types";

export function CategoryBadge({ category }: { category: RequestCategory }) {
  return (
    <span className="inline-flex items-center gap-1.5 rounded-full border border-cream-soft bg-surface px-3 py-1 text-xs font-semibold">
      <span className={`h-1.5 w-1.5 rounded-full ${CATEGORY_DOT_CLASSES[category]}`} />
      <span className={CATEGORY_CLASSES[category]}>{CATEGORY_LABELS[category]}</span>
    </span>
  );
}
