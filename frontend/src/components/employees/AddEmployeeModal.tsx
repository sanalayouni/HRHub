import { useState, type FormEvent, type ReactNode } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { isAxiosError } from "axios";
import { X } from "lucide-react";
import { createEmployee, updateEmployee } from "../../api/employees";
import { PERFORMANCE_RATINGS } from "../../api/types";
import type { EmployeeCreate, EmployeeOut, PerformanceRating } from "../../api/types";

const EMPTY_FORM: EmployeeCreate = {
  first_name: "",
  last_name: "",
  email: "",
  department: "",
  job_title: "",
  manager_name: "",
  employment_start_date: "",
  salary: 0,
  location: "",
  probation_completed: false,
  annual_leave_balance: null,
  performance_rating: null,
};

function toForm(employee: EmployeeOut): EmployeeCreate {
  return {
    first_name: employee.first_name,
    last_name: employee.last_name,
    email: employee.email,
    department: employee.department,
    job_title: employee.job_title,
    manager_name: employee.manager_name,
    employment_start_date: employee.employment_start_date,
    salary: employee.salary,
    location: employee.location,
    probation_completed: employee.probation_completed,
    annual_leave_balance: employee.annual_leave_balance,
    performance_rating: employee.performance_rating,
  };
}

function errorMessage(error: unknown, isEditing: boolean): string {
  const fallback = `Couldn't ${isEditing ? "update" : "add"} this employee. Check the fields and try again.`;
  if (!isAxiosError(error)) return fallback;

  const detail = (error.response?.data as { detail?: unknown } | undefined)?.detail;
  if (typeof detail === "string") return detail;

  // FastAPI validation errors arrive as a list; surface the first failing field.
  if (Array.isArray(detail) && detail.length > 0) {
    const first = detail[0] as { loc?: unknown[]; msg?: string };
    const field = Array.isArray(first.loc) ? first.loc[first.loc.length - 1] : null;
    if (typeof field === "string" && first.msg) return `${field}: ${first.msg}`;
  }
  return fallback;
}

const inputClass =
  "w-full rounded-xl border border-cream-soft bg-surface px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-accent/40";

function Field({
  label,
  full,
  children,
}: {
  label: string;
  full?: boolean;
  children: ReactNode;
}) {
  return (
    <label className={`flex flex-col gap-1 text-sm ${full ? "col-span-2" : ""}`}>
      <span className="text-xs font-medium text-ink-soft">{label}</span>
      {children}
    </label>
  );
}

export function AddEmployeeModal({
  employee,
  onClose,
}: {
  employee?: EmployeeOut;
  onClose: () => void;
}) {
  const isEditing = Boolean(employee);
  const [form, setForm] = useState<EmployeeCreate>(employee ? toForm(employee) : EMPTY_FORM);
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (payload: EmployeeCreate) =>
      isEditing && employee
        ? updateEmployee(employee.employee_id, payload)
        : createEmployee(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["employees"] });
      if (isEditing && employee) {
        queryClient.invalidateQueries({ queryKey: ["employee", employee.employee_id] });
      }
      onClose();
    },
  });

  const set = <K extends keyof EmployeeCreate>(key: K, value: EmployeeCreate[K]) =>
    setForm((f) => ({ ...f, [key]: value }));

  const isValid =
    form.first_name.trim() !== "" &&
    form.last_name.trim() !== "" &&
    form.email.trim() !== "" &&
    form.department.trim() !== "" &&
    form.job_title.trim() !== "" &&
    form.manager_name.trim() !== "" &&
    form.employment_start_date !== "" &&
    form.location.trim() !== "" &&
    form.salary >= 0;

  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (!isValid || mutation.isPending) return;
    mutation.mutate({
      ...form,
      annual_leave_balance: form.annual_leave_balance ?? null,
      performance_rating: form.performance_rating || null,
    });
  };

  return (
    <div className="fixed inset-0 z-30 flex items-center justify-center bg-ink/40 p-4 backdrop-blur-sm">
      <div className="glass-card max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-xl bg-surface p-6 shadow-2xl">
        <div className="mb-5 flex items-center justify-between">
          <h2 className="font-heading text-lg font-bold">
            {isEditing ? "Edit Employee" : "Add Employee"}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="Close"
            className="flex h-8 w-8 items-center justify-center rounded-xl text-ink-soft hover:bg-cream"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <form onSubmit={submit} className="grid grid-cols-2 gap-4">
          <Field label="First Name">
            <input
              className={inputClass}
              value={form.first_name}
              onChange={(e) => set("first_name", e.target.value)}
              required
            />
          </Field>
          <Field label="Last Name">
            <input
              className={inputClass}
              value={form.last_name}
              onChange={(e) => set("last_name", e.target.value)}
              required
            />
          </Field>
          <Field label="Email" full>
            <input
              type="email"
              className={inputClass}
              value={form.email}
              onChange={(e) => set("email", e.target.value)}
              required
            />
          </Field>
          <Field label="Job Title">
            <input
              className={inputClass}
              value={form.job_title}
              onChange={(e) => set("job_title", e.target.value)}
              required
            />
          </Field>
          <Field label="Department">
            <input
              className={inputClass}
              value={form.department}
              onChange={(e) => set("department", e.target.value)}
              required
            />
          </Field>
          <Field label="Manager">
            <input
              className={inputClass}
              value={form.manager_name}
              onChange={(e) => set("manager_name", e.target.value)}
              required
            />
          </Field>
          <Field label="Location">
            <input
              className={inputClass}
              value={form.location}
              onChange={(e) => set("location", e.target.value)}
              required
            />
          </Field>
          <Field label="Start Date">
            <input
              type="date"
              className={inputClass}
              value={form.employment_start_date}
              onChange={(e) => set("employment_start_date", e.target.value)}
              required
            />
          </Field>
          <Field label="Salary">
            <input
              type="number"
              min={0}
              step="0.01"
              className={inputClass}
              value={form.salary}
              onChange={(e) => set("salary", Number(e.target.value))}
              required
            />
          </Field>
          <Field label="Leave Balance (days)">
            <input
              type="number"
              min={0}
              className={inputClass}
              value={form.annual_leave_balance ?? ""}
              onChange={(e) =>
                set("annual_leave_balance", e.target.value === "" ? null : Number(e.target.value))
              }
            />
          </Field>
          <Field label="Performance Rating">
            <select
              className={inputClass}
              value={form.performance_rating ?? ""}
              onChange={(e) =>
                set(
                  "performance_rating",
                  e.target.value === "" ? null : (e.target.value as PerformanceRating)
                )
              }
            >
              <option value="">Not rated</option>
              {PERFORMANCE_RATINGS.map((rating) => (
                <option key={rating} value={rating}>
                  {rating}
                </option>
              ))}
            </select>
          </Field>
          <label className="col-span-2 flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={form.probation_completed ?? false}
              onChange={(e) => set("probation_completed", e.target.checked)}
              className="h-4 w-4 rounded border-cream-soft accent-accent"
            />
            Probation completed
          </label>

          {mutation.isError && (
            <p className="col-span-2 text-xs text-coral">
              {errorMessage(mutation.error, isEditing)}
            </p>
          )}

          <div className="col-span-2 mt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-xl px-4 py-2 text-sm font-medium text-ink-soft hover:bg-cream"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!isValid || mutation.isPending}
              className="rounded-xl bg-accent px-4 py-2 text-sm font-semibold text-ink-fixed hover:opacity-90 disabled:opacity-50"
            >
              {mutation.isPending
                ? isEditing
                  ? "Saving..."
                  : "Adding..."
                : isEditing
                  ? "Save Changes"
                  : "Add Employee"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
