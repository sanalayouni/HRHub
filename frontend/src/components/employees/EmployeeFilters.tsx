import { Plus, Search } from "lucide-react";

interface Props {
  search: string;
  onSearchChange: (v: string) => void;
  department: string;
  onDepartmentChange: (v: string) => void;
  departments: string[];
  onAddEmployee: () => void;
}

export function EmployeeFilters({
  search,
  onSearchChange,
  department,
  onDepartmentChange,
  departments,
  onAddEmployee,
}: Props) {
  return (
    <div className="flex items-center gap-3 p-5">
      <div className="flex flex-1 items-center gap-1 rounded-xl border border-cream-soft bg-surface pl-1.5 pr-1.5 shadow-[0_8px_24px_-12px_rgba(26,26,26,0.1)]">
        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-slate-soft text-slate">
          <Search className="h-4 w-4" />
        </div>
        <input
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder="Search employees..."
          className="min-w-0 flex-1 bg-transparent px-3 py-2.5 text-sm outline-none placeholder:text-ink-soft/60"
        />
        <span className="h-6 w-px shrink-0 bg-cream-soft" />
        <select
          value={department}
          onChange={(e) => onDepartmentChange(e.target.value)}
          className="shrink-0 bg-transparent px-3 py-2.5 text-sm text-ink-soft outline-none"
        >
          <option value="">All departments</option>
          {departments.map((d) => (
            <option key={d} value={d}>
              {d}
            </option>
          ))}
        </select>
      </div>
      <button
        type="button"
        onClick={onAddEmployee}
        aria-label="Add employee"
        title="Add employee"
        className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-accent text-ink-fixed shadow-[0_8px_24px_-12px_rgba(245,200,66,0.7)] hover:opacity-90"
      >
        <Plus className="h-5 w-5" />
      </button>
    </div>
  );
}
