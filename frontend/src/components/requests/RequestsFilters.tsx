import { SearchInput } from "../common/SearchInput";
import type { DecisionStatus, RequestCategory } from "../../api/types";

interface Props {
  search: string;
  onSearchChange: (v: string) => void;
  category: RequestCategory | "";
  onCategoryChange: (v: RequestCategory | "") => void;
  status: DecisionStatus | "";
  onStatusChange: (v: DecisionStatus | "") => void;
}

const selectClass =
  "rounded-full border border-white/60 bg-surface px-5 py-2.5 text-sm shadow-[0_8px_24px_-12px_rgba(26,26,26,0.15)] outline-none transition-all focus:ring-2 focus:ring-accent/40 dark:border-white/10 dark:shadow-black/30";

export function RequestsFilters({
  search,
  onSearchChange,
  category,
  onCategoryChange,
  status,
  onStatusChange,
}: Props) {
  return (
    <div className="flex flex-wrap items-center gap-3 p-5">
      <SearchInput value={search} onChange={onSearchChange} placeholder="Search by employee or request..." />
      <select
        value={category}
        onChange={(e) => onCategoryChange(e.target.value as RequestCategory | "")}
        className={selectClass}
      >
        <option value="">All categories</option>
        <option value="leave">Leave</option>
        <option value="salary">Salary</option>
        <option value="flexwork">Flexible Work</option>
      </select>
      <select
        value={status}
        onChange={(e) => onStatusChange(e.target.value as DecisionStatus | "")}
        className={selectClass}
      >
        <option value="">All statuses</option>
        <option value="pending">Not Yet Reviewed</option>
        <option value="needs_review">Needs Review</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
      </select>
    </div>
  );
}
