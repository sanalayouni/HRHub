import type { DecisionStatus, RequestCategory } from "../api/types";

export const CATEGORY_LABELS: Record<RequestCategory, string> = {
  leave: "Leave",
  salary: "Salary",
  flexwork: "Flexible Work",
};

export const CATEGORY_CLASSES: Record<RequestCategory, string> = {
  leave: "text-dustyblue",
  salary: "text-ink",
  flexwork: "text-sage",
};

export const CATEGORY_DOT_CLASSES: Record<RequestCategory, string> = {
  leave: "bg-dustyblue",
  salary: "bg-accent",
  flexwork: "bg-sage",
};

export const STATUS_LABELS: Record<DecisionStatus, string> = {
  pending: "Not Yet Reviewed",
  needs_review: "Needs Review",
  approved: "Approved",
  rejected: "Rejected",
};

export const STATUS_CLASSES: Record<DecisionStatus, string> = {
  pending: "text-dustyblue",
  needs_review: "text-dustyblue",
  approved: "text-sage",
  rejected: "text-coral",
};

export const STATUS_DOT_CLASSES: Record<DecisionStatus, string> = {
  pending: "bg-dustyblue",
  needs_review: "bg-dustyblue",
  approved: "bg-sage",
  rejected: "bg-coral",
};

export function normalizeAiRecommendation(raw: string | null): {
  label: string;
  className: string;
  dotClassName: string;
} {
  if (!raw) return { label: "—", className: "text-ink-soft", dotClassName: "bg-ink-soft" };
  const v = raw.toLowerCase();
  if (v.includes("approve"))
    return { label: "Approve", className: "text-sage", dotClassName: "bg-sage" };
  if (v.includes("reject"))
    return { label: "Reject", className: "text-coral", dotClassName: "bg-coral" };
  if (v.includes("info"))
    return { label: "Request Info", className: "text-dustyblue", dotClassName: "bg-dustyblue" };
  return { label: raw, className: "text-ink-soft", dotClassName: "bg-ink-soft" };
}

export function formatConfidence(confidence: number | null): string {
  if (confidence === null || confidence === undefined) return "—";
  return `${Math.round(confidence * 100)}%`;
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function initials(name: string): string {
  return name
    .split(" ")
    .map((p) => p[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}
