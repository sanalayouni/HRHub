import { useQuery } from "@tanstack/react-query";
import { fetchDashboardSummary } from "../api/dashboard";
import { fetchRequests } from "../api/requests";
import { PageShell } from "../components/layout/PageShell";
import { StatPill } from "../components/dashboard/StatPill";
import { PendingQueueCard } from "../components/dashboard/PendingQueueCard";
import { CategoryDonut } from "../components/dashboard/CategoryDonut";
import { RecentDecisionsFeed } from "../components/dashboard/RecentDecisionsFeed";

export function DashboardPage() {
  const summaryQuery = useQuery({
    queryKey: ["dashboard-summary"],
    queryFn: fetchDashboardSummary,
  });
  const pendingQuery = useQuery({
    queryKey: ["requests", { status: "pending-queue" }],
    queryFn: () => fetchRequests(),
  });

  const summary = summaryQuery.data;
  const pendingRequests = (pendingQuery.data ?? []).filter(
    (r) => r.status === "pending" || r.status === "needs_review"
  );

  return (
    <PageShell title="Dashboard" subtitle="Welcome back, HR Manager">
      <div className="mb-6 flex flex-wrap gap-3">
        <StatPill label="Pending" value={summary?.pending_count ?? "—"} tone="accent" />
        <StatPill
          label="Approved This Week"
          value={summary?.approved_this_week_count ?? "—"}
          tone="sage"
        />
        <StatPill label="Rejected" value={summary?.rejected_count ?? "—"} tone="coral" />
        <StatPill label="Total Employees" value={summary?.total_employees ?? "—"} tone="ink" />
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <PendingQueueCard requests={pendingRequests} />
        </div>
        <CategoryDonut split={summary?.category_split ?? { leave: 0, salary: 0, flexwork: 0 }} />
      </div>

      <div className="mt-5">
        <RecentDecisionsFeed items={summary?.recent_decisions ?? []} />
      </div>
    </PageShell>
  );
}
