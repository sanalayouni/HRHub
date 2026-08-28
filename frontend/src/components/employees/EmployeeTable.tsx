import type { EmployeeListItem } from "../../api/types";
import { initials, formatDate } from "../../lib/labels";

interface Props {
  employees: EmployeeListItem[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

export function EmployeeTable({ employees, selectedId, onSelect }: Props) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[640px] text-left text-sm">
        <thead>
          <tr className="border-b border-cream-soft text-xs uppercase tracking-wide text-ink-soft">
            <th className="px-5 py-3 font-medium">Name</th>
            <th className="px-5 py-3 font-medium">Role</th>
            <th className="px-5 py-3 font-medium">Department</th>
            <th className="px-5 py-3 font-medium">Location</th>
            <th className="px-5 py-3 font-medium">Start Date</th>
          </tr>
        </thead>
        <tbody>
          {employees.length === 0 && (
            <tr>
              <td colSpan={5} className="px-5 py-10 text-center text-ink-soft">
                No employees match these filters.
              </td>
            </tr>
          )}
          {employees.map((emp) => {
            const name = `${emp.first_name} ${emp.last_name}`;
            const isSelected = emp.employee_id === selectedId;
            return (
              <tr
                key={emp.employee_id}
                onClick={() => onSelect(emp.employee_id)}
                className={`cursor-pointer border-b border-cream-soft last:border-0 transition-colors ${
                  isSelected ? "bg-accent/30" : "hover:bg-cream"
                }`}
              >
                <td className="px-5 py-3">
                  <div className="flex items-center gap-3">
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-slate-soft text-xs font-semibold text-slate">
                      {initials(name)}
                    </div>
                    <span className="font-medium">{name}</span>
                  </div>
                </td>
                <td className="px-5 py-3 text-ink-soft">{emp.job_title}</td>
                <td className="px-5 py-3 text-ink-soft">{emp.department}</td>
                <td className="px-5 py-3 text-ink-soft">{emp.location}</td>
                <td className="px-5 py-3 text-ink-soft">
                  {formatDate(emp.employment_start_date)}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
