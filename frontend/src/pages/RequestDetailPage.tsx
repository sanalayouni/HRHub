import { useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { fetchRequest } from "../api/requests";
import { RequestHeader } from "../components/requests/RequestHeader";
import { RequestContentCard } from "../components/requests/RequestContentCard";
import { EmployeeContextCard } from "../components/requests/EmployeeContextCard";
import { AiRecommendationCard } from "../components/requests/AiRecommendationCard";
import { DecisionActionBar } from "../components/requests/DecisionActionBar";

export function RequestDetailPage() {
  const { requestId } = useParams<{ requestId: string }>();
  const { data: request, isLoading } = useQuery({
    queryKey: ["request", requestId],
    queryFn: () => fetchRequest(requestId!),
    enabled: !!requestId,
  });

  if (isLoading || !request) {
    return (
      <main className="mx-auto max-w-6xl px-6 pt-8">
        <p className="text-sm text-ink-soft">Loading request...</p>
      </main>
    );
  }

  const status = request.decision?.status ?? "pending";
  const isActionable = status === "pending" || status === "needs_review";

  return (
    <main className="mx-auto max-w-6xl px-6 pb-16 pt-8">
      <RequestHeader request={request} />

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <div className="flex flex-col gap-5 lg:col-span-2">
          <RequestContentCard request={request} />
          <EmployeeContextCard employee={request.employee} />
        </div>
        <div>
          <AiRecommendationCard decision={request.decision} />
        </div>
      </div>

      {isActionable ? (
        <DecisionActionBar requestId={request.id} existingNotes={request.decision?.notes} />
      ) : (
        <div className="glass-card mt-6 rounded-3xl p-5">
          <p className="text-xs font-semibold uppercase tracking-wide text-ink-soft">
            Final decision
          </p>
          <p className="mt-1 text-sm text-ink">
            This request was {status} on{" "}
            {request.decision && new Date(request.decision.updated_at).toLocaleDateString()}.
          </p>
          {request.decision?.notes && (
            <p className="mt-2 text-sm text-ink-soft">"{request.decision.notes}"</p>
          )}
        </div>
      )}
    </main>
  );
}
