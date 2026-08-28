import type { EmployeeOut } from "../../api/types";

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs text-ink-soft">{label}</p>
      <p className="text-sm font-medium">{value}</p>
    </div>
  );
}

export function EmployeeContextCard({ employee }: { employee: EmployeeOut | null }) {
  if (!employee) {
    return (
      <div className="glass-card rounded-3xl p-5">
        <h2 className="mb-2 font-heading text-lg font-semibold">Employee Data</h2>
        <p className="text-sm text-ink-soft">
          No matching employee record found for this request's sender.
        </p>
      </div>
    );
  }

  return (
    <div className="glass-card rounded-3xl p-5">
      <h2 className="mb-4 font-heading text-lg font-semibold">Employee Data</h2>
      <div className="grid grid-cols-2 gap-4">
        <Field label="Role" value={employee.job_title} />
        <Field label="Department" value={employee.department} />
        <Field label="Manager" value={employee.manager_name} />
        <Field label="Tenure" value={`${employee.tenure_years} years`} />
        <Field
          label="Probation"
          value={employee.probation_completed ? "Completed" : "In progress"}
        />
        <Field
          label="Leave Balance"
          value={
            employee.annual_leave_balance !== null
              ? `${employee.annual_leave_balance} days`
              : "—"
          }
        />
        <Field label="Performance Rating" value={employee.performance_rating ?? "—"} />
        <Field label="Location" value={employee.location} />
      </div>
    </div>
  );
}
