interface Props {
  label: string;
  value: string | number;
  tone?: "ink" | "accent" | "sage" | "coral";
}

const TONE_CLASSES: Record<NonNullable<Props["tone"]>, string> = {
  ink: "bg-ink text-cream",
  accent: "bg-accent text-ink-fixed",
  sage: "bg-surface text-ink border border-cream-soft",
  coral: "bg-surface text-ink border border-cream-soft",
};

export function StatPill({ label, value, tone = "ink" }: Props) {
  return (
    <div
      className={`inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm ${TONE_CLASSES[tone]}`}
    >
      <span className="font-heading text-lg font-bold">{value}</span>
      <span className="opacity-70">{label}</span>
    </div>
  );
}
