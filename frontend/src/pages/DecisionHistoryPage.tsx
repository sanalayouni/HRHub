import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { fetchDecisions } from "../api/decisions";
import { PageShell } from "../components/layout/PageShell";
import { FolderCard } from "../components/common/FolderCard";
import { DecisionFilters } from "../components/decisions/DecisionFilters";
import { DecisionTable } from "../components/decisions/DecisionTable";
import type { DecisionStatus, RequestCategory } from "../api/types";

export function DecisionHistoryPage() {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState<RequestCategory | "">("");
  const [status, setStatus] = useState<DecisionStatus | "">("");

  const { data, isLoading } = useQuery({
    queryKey: ["decisions", { search, category, status }],
    queryFn: () =>
      fetchDecisions({
        search: search || undefined,
        category: category || undefined,
        status: status || undefined,
      }),
  });

  return (
    <PageShell title="Decision History" subtitle="The audit trail of every finalized HR decision">
      <FolderCard>
        <DecisionFilters
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
