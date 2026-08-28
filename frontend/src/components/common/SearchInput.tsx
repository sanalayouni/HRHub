import { Search } from "lucide-react";

interface Props {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}

export function SearchInput({ value, onChange, placeholder = "Search..." }: Props) {
  return (
    <div className="relative flex-1 min-w-[200px]">
      <div className="absolute left-1.5 top-1/2 flex h-8 w-8 -translate-y-1/2 items-center justify-center rounded-full bg-cream dark:bg-cream-soft">
        <Search className="h-4 w-4 text-ink-soft" />
      </div>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full rounded-full border border-white/60 bg-surface py-2.5 pl-12 pr-5 text-sm shadow-[0_8px_24px_-12px_rgba(26,26,26,0.15)] outline-none transition-all placeholder:text-ink-soft/60 focus:ring-2 focus:ring-accent/40 dark:border-white/10 dark:shadow-black/30"
      />
    </div>
  );
}
