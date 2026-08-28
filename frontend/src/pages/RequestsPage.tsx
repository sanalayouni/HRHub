import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { fetchRequests } from "../api/requests";
import { PageShell } from "../components/layout/PageShell";
import { FolderCard } from "../components/common/FolderCard";
import { RequestsFilters } from "../components/requests/RequestsFilters";
import { DecisionTable } from "../components/decisions/DecisionTable";
import type { DecisionStatus, RequestCategory } from "../api/types";

export function RequestsPage() {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState<RequestCategory | "">("");
  const [status, setStatus] = useState<DecisionStatus | "">("");

  const { data, isLoading } = useQuery({
    queryKey: ["requests", { search, category, status }],
    queryFn: () =>
      fetchRequests({
        search: search || undefined,
        category: category || undefined,
        status: status || undefined,
      }),
  });

  return (
    <PageShell title="Requests" subtitle="Every request submitted by employees, open or resolved">
      <FolderCard>
        <RequestsFilters
          search={search}
          onSearchChange={setSearch}
          category={category}
          onCategoryChange={setCategory}
          status={status}
          onStatusChange={setStatus}
        />
        {isLoading ? (
          <p className="px-5 pb-5 text-sm text-ink-soft">Loading...</p>
        ) : (
          <DecisionTable items={data ?? []} />
        )}
      </FolderCard>
    </PageShell>
  );
}
