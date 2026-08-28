import type { DecisionOut } from "../../api/types";
import { normalizeAiRecommendation } from "../../lib/labels";
import { ConfidenceGauge } from "./ConfidenceGauge";

export function AiRecommendationCard({ decision }: { decision: DecisionOut | null }) {
  const ai = normalizeAiRecommendation(decision?.ai_recommendation ?? null);

  return (
    <div className="glass-card rounded-3xl p-5">
      <h2 className="mb-4 font-heading text-lg font-semibold">AI Recommendation</h2>

      {!decision || !decision.ai_recommendation ? (
        <p className="py-6 text-center text-sm text-ink-soft">
          This request hasn't been processed by an agent yet.
        </p>
      ) : (
        <>
          <div className="flex items-center justify-center gap-4">
            <ConfidenceGauge confidence={decision.confidence} />
            <div>
              <span className="inline-flex items-center gap-1.5 rounded-full border border-cream-soft bg-surface px-3 py-1 text-sm font-semibold">
                <span className={`h-1.5 w-1.5 rounded-full ${ai.dotClassName}`} />
                <span className={ai.className}>{ai.label}</span>
              </span>
            </div>
          </div>
          {decision.decision_reason && (
            <div className="mt-4 rounded-2xl bg-cream p-4">
              <p className="mb-1 text-xs font-semibold uppercase tracking-wide text-ink-soft">
                Reasoning
              </p>
              <p className="text-sm leading-relaxed text-ink">{decision.decision_reason}</p>
            </div>
          )}
        </>
      )}
    </div>
  );
}
