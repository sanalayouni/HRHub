import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import {
  Building2,
  Calendar,
  Clock,
  Mail,
  MapPin,
  Pencil,
  ShieldCheck,
  Star,
  Trash2,
  User,
  Wallet,
  X,
} from "lucide-react";
import type { ComponentType } from "react";
import { deleteEmployee, fetchEmployee, fetchEmployeeRequests } from "../../api/employees";
import { CategoryBadge } from "../common/CategoryBadge";
import { StatusBadge } from "../common/StatusBadge";
import { initials, formatDate } from "../../lib/labels";

function InfoRow({
  icon: Icon,
  label,
  value,
}: {
  icon: ComponentType<{ className?: string }>;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center gap-3 py-2">
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-slate-soft text-slate">
        <Icon className="h-4 w-4" />
      </div>
      <span className="shrink-0 text-sm text-ink-soft">{label}</span>
      <span className="h-px flex-1 border-b border-dotted border-cream-soft" />
      <span className="shrink-0 truncate text-sm font-medium">{value}</span>
    </div>
  );
}

const STAT_TONE_CLASSES = {
  accent: "bg-accent text-ink-fixed",
  sage: "bg-sage text-ink-fixed",
  dustyblue: "bg-dustyblue text-ink-fixed",
  coral: "bg-coral text-ink-fixed",
} as const;

function StatChip({
  icon: Icon,
  tone,
  label,
  value,
}: {
  icon: ComponentType<{ className?: string }>;
  tone: keyof typeof STAT_TONE_CLASSES;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center gap-3 rounded-xl bg-cream p-3">
      <div
        className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl ${STAT_TONE_CLASSES[tone]}`}
      >
        <Icon className="h-4 w-4" />
      </div>
      <div className="min-w-0">
        <p className="truncate text-xs font-semibold">{value}</p>
        <p className="truncate text-xs text-ink-soft">{label}</p>
      </div>
    </div>
  );
}

export function EmployeeProfilePanel({
  employeeId,
  onClose,
  onEdit,
}: {
  employeeId: string;
  onClose: () => void;
  onEdit: () => void;
}) {
  const { data: employee } = useQuery({
    queryKey: ["employee", employeeId],
    queryFn: () => fetchEmployee(employeeId),
  });
  const { data: requests } = useQuery({
    queryKey: ["employee-requests", employeeId],
    queryFn: () => fetchEmployeeRequests(employeeId),
  });
  const [confirmingDelete, setConfirmingDelete] = useState(false);
  const queryClient = useQueryClient();

  const deleteMutation = useMutation({
    mutationFn: () => deleteEmployee(employeeId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["employees"] });
      onClose();
    },
  });

  if (!employee) return null;
  const name = `${employee.first_name} ${employee.last_name}`;

  return (
    <aside className="glass-card relative w-full overflow-hidden rounded-2xl shadow-xl">
        <div className="absolute right-4 top-4 z-10 flex items-center gap-2">
          <button
            type="button"
            onClick={onEdit}
            aria-label="Edit employee"
            className="flex h-8 w-8 items-center justify-center rounded-xl bg-surface/80 text-ink-soft shadow-sm backdrop-blur hover:bg-surface"
          >
            <Pencil className="h-3.5 w-3.5" />
          </button>
          <button
            type="button"
            onClick={onClose}
            aria-label="Close"
            className="flex h-8 w-8 items-center justify-center rounded-xl bg-surface/80 text-ink-soft shadow-sm backdrop-blur hover:bg-surface"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div
          className="h-24 w-full"
          style={{
            background:
              "radial-gradient(120% 140% at 15% 10%, #fff6da 0%, transparent 45%), radial-gradient(90% 120% at 85% 0%, #f7d35c 0%, transparent 55%), linear-gradient(135deg, #33353f 0%, #565a6b 45%, #f5c842 100%)",
          }}
        />

        <div className="relative z-10 -mt-10 mb-3 flex justify-center px-6">
          <div className="flex h-20 w-20 items-center justify-center rounded-full border-4 border-surface bg-slate text-xl font-bold text-cream shadow-lg">
            {initials(name)}
          </div>
        </div>

        <div className="mb-6 px-6 text-center">
          <h2 className="font-heading text-xl font-bold">{name}</h2>
          <p className="text-sm text-ink-soft">{employee.job_title}</p>
        </div>

        <div className="max-h-[calc(100vh-22rem)] overflow-y-auto px-6 pb-6">
          <h3 className="mb-1 font-heading text-sm font-semibold">Basic Information</h3>
          <div className="mb-6 flex flex-col divide-y divide-cream-soft/60">
            <InfoRow icon={Mail} label="E-Mail" value={employee.email} />
            <InfoRow icon={Calendar} label="Start Date" value={formatDate(employee.employment_start_date)} />
            <InfoRow icon={User} label="Manager" value={employee.manager_name} />
            <InfoRow icon={Building2} label="Department" value={employee.department} />
            <InfoRow icon={MapPin} label="Location" value={employee.location} />
            <InfoRow
              icon={ShieldCheck}
              label="Probation"
              value={employee.probation_completed ? "Completed" : "In progress"}
            />
          </div>

          <h3 className="mb-3 font-heading text-sm font-semibold">Statistics</h3>
          <div className="mb-6 grid grid-cols-2 gap-3">
            <StatChip icon={Clock} tone="dustyblue" label="Tenure" value={`${employee.tenure_years} yrs`} />
            <StatChip
              icon={Calendar}
              tone="sage"
              label="Leave Balance"
              value={employee.annual_leave_balance !== null ? `${employee.annual_leave_balance} days` : "—"}
            />
            <StatChip
              icon={Star}
              tone="accent"
              label="Performance"
              value={employee.performance_rating ?? "—"}
            />
            <StatChip icon={Wallet} tone="coral" label="Salary" value={`$${employee.salary.toLocaleString()}`} />
          </div>

          <h3 className="mb-3 font-heading text-sm font-semibold">Request History</h3>
          {!requests || requests.length === 0 ? (
            <p className="text-sm text-ink-soft">No requests from this employee yet.</p>
          ) : (
            <ul className="flex flex-col gap-2">
              {requests.map((req) => (
                <li key={req.id}>
                  <Link
                    to={`/requests/${req.id}`}
                    className="flex items-center justify-between gap-2 rounded-xl bg-cream px-3 py-2.5 hover:bg-cream-soft transition-colors"
                  >
                    <div className="min-w-0">
                      <CategoryBadge category={req.request_type} />
                      <p className="mt-1 truncate text-xs text-ink-soft">{formatDate(req.created_at)}</p>
                    </div>
                    <StatusBadge status={req.status} />
                  </Link>
                </li>
              ))}
            </ul>
          )}

          <div className="mt-6 border-t border-cream-soft/60 pt-4">
            {confirmingDelete ? (
              <div className="flex items-center gap-2 rounded-xl bg-coral-soft p-3">
                <p className="flex-1 text-xs font-medium text-ink">
                  Delete {name}? This can't be undone.
                </p>
                <button
                  type="button"
                  onClick={() => setConfirmingDelete(false)}
                  className="rounded-xl px-3 py-1.5 text-xs font-medium text-ink-soft hover:bg-surface"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={() => deleteMutation.mutate()}
                  disabled={deleteMutation.isPending}
                  className="rounded-xl bg-coral px-3 py-1.5 text-xs font-semibold text-ink-fixed hover:opacity-90 disabled:opacity-50"
                >
                  {deleteMutation.isPending ? "Deleting..." : "Confirm"}
                </button>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => setConfirmingDelete(true)}
                className="flex items-center gap-1.5 text-xs font-medium text-coral hover:opacity-80"
              >
                <Trash2 className="h-3.5 w-3.5" /> Delete Employee
              </button>
            )}
            {deleteMutation.isError && (
              <p className="mt-2 text-xs text-coral">Couldn't delete this employee. Try again.</p>
            )}
          </div>
        </div>
    </aside>
  );
}
