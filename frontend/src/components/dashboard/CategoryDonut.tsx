import { Cell, Pie, PieChart, ResponsiveContainer } from "recharts";
import type { CategorySplit } from "../../api/types";
import { CATEGORY_LABELS } from "../../lib/labels";

const COLORS: Record<keyof CategorySplit, string> = {
  leave: "#7b96ad",
  salary: "#f5c842",
  flexwork: "#8fa88a",
};

export function CategoryDonut({ split }: { split: CategorySplit }) {
  const data = (Object.keys(split) as (keyof CategorySplit)[]).map((key) => ({
    key,
    name: CATEGORY_LABELS[key],
    value: split[key],
  }));
  const total = data.reduce((sum, d) => sum + d.value, 0);

  return (
    <div className="glass-card rounded-3xl p-5">
      <h2 className="mb-4 font-heading text-lg font-semibold">Requests by Category</h2>
      <div className="relative h-48">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              innerRadius={55}
              outerRadius={80}
              paddingAngle={3}
              strokeWidth={0}
            >
              {data.map((d) => (
                <Cell key={d.key} fill={COLORS[d.key]} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
          <span className="font-heading text-2xl font-bold">{total}</span>
          <span className="text-xs text-ink-soft">total requests</span>
        </div>
      </div>
      <div className="mt-4 flex flex-wrap justify-center gap-4">
        {data.map((d) => (
          <div key={d.key} className="flex items-center gap-2 text-xs">
            <span
              className="h-2.5 w-2.5 rounded-full"
              style={{ backgroundColor: COLORS[d.key] }}
            />
            <span className="text-ink-soft">{d.name}</span>
            <span className="font-semibold">{d.value}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
