import { RadialBar, RadialBarChart, ResponsiveContainer } from "recharts";

export function ConfidenceGauge({ confidence }: { confidence: number | null }) {
  const pct = confidence !== null ? Math.round(confidence * 100) : 0;
  const data = [{ name: "confidence", value: pct, fill: "#f5c842" }];

  return (
    <div className="relative flex h-32 items-center justify-center">
      <ResponsiveContainer width="100%" height="100%">
        <RadialBarChart
          innerRadius="70%"
          outerRadius="100%"
          data={data}
          startAngle={90}
          endAngle={-270}
        >
          <RadialBar dataKey="value" cornerRadius={12} background={{ fill: "#eee8d8" }} />
        </RadialBarChart>
      </ResponsiveContainer>
      <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
        <span className="font-heading text-xl font-bold">
          {confidence !== null ? `${pct}%` : "—"}
        </span>
        <span className="text-[10px] text-ink-soft">confidence</span>
      </div>
    </div>
  );
}
