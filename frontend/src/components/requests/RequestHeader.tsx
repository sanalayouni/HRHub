import { Link } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import type { RequestDetail } from "../../api/types";
import { CategoryBadge } from "../common/CategoryBadge";
import { StatusBadge } from "../common/StatusBadge";
import { initials, formatDate } from "../../lib/labels";

export function RequestHeader({ request }: { request: RequestDetail }) {
  const employeeName = request.employee
    ? `${request.employee.first_name} ${request.employee.last_name}`
    : "Unknown Employee";
  const status = request.decision?.status ?? "pending";

  return (
    <div className="mb-6">
      <Link
        to="/requests"
        className="mb-4 inline-flex items-center gap-1 text-sm text-ink-soft hover:text-ink"
      >
        <ArrowLeft className="h-4 w-4" /> Back to requests
      </Link>
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-slate text-sm font-semibold text-cream">
            {initials(employeeName)}
          </div>
          <div>
            <h1 className="font-heading text-2xl font-bold">{employeeName}</h1>
            <p className="text-xs text-ink-soft">
              {request.employee_email ?? "no email on file"} · Submitted{" "}
              {formatDate(request.created_at)}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <CategoryBadge category={request.request_type} />
          <StatusBadge status={status} />
        </div>
      </div>
    </div>
  );
}
