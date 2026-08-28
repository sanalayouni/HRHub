import { useEffect, useState } from "react";
import { NavLink } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Bell, LogOut, Moon, Settings, Sun } from "lucide-react";
import { fetchMe } from "../../api/auth";
import { useAuth } from "../../lib/auth";
import { initials } from "../../lib/labels";
import logo from "../../assets/hrhub-logo.png";

const NAV_ITEMS = [
  { to: "/", label: "Dashboard" },
  { to: "/requests", label: "Requests" },
  { to: "/decisions", label: "Decisions" },
  { to: "/employees", label: "Employees" },
];

type Theme = "light" | "dark";

function getStoredTheme(): Theme {
  if (typeof window === "undefined") return "light";
  return localStorage.getItem("hrhub-theme") === "dark" ? "dark" : "light";
}

export function TopNav() {
  const [theme, setTheme] = useState<Theme>(getStoredTheme);
  const [openMenu, setOpenMenu] = useState<"settings" | "account" | null>(null);
  const auth = useAuth();
  const { data: me } = useQuery({ queryKey: ["me"], queryFn: fetchMe });
  const displayName = me?.email.split("@")[0] ?? "HR Manager";

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("hrhub-theme", theme);
  }, [theme]);

  const toggleMenu = (menu: "settings" | "account") =>
    setOpenMenu((current) => (current === menu ? null : menu));

  return (
    <header className="sticky top-0 z-10 px-6 pt-6">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-3">
        <div className="flex items-center gap-2 rounded-full bg-shell py-1.5 pl-1.5 pr-5 shadow-sm">
          <img src={logo} alt="HRHub" className="h-8 w-8 rounded-lg" />
          <span className="font-heading text-lg font-bold tracking-tight text-ink">
            HRHub
          </span>
        </div>

        <nav className="flex items-center gap-1 rounded-full bg-shell p-1.5 shadow-sm">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === "/"}
              className={({ isActive }) =>
                `rounded-full px-4 py-2 text-sm font-medium transition-colors ${
                  isActive
                    ? "bg-ink text-cream"
                    : "text-ink-soft hover:text-ink"
                }`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="relative flex items-center gap-2 rounded-full bg-shell p-1.5 shadow-sm">
          <button
            type="button"
            aria-label="Settings"
            onClick={() => toggleMenu("settings")}
            className={`flex h-9 w-9 items-center justify-center rounded-full transition-colors ${
              openMenu === "settings"
                ? "bg-ink text-cream"
                : "bg-surface text-ink-soft hover:text-ink"
            }`}
          >
            <Settings className="h-4 w-4" />
          </button>
          <button
            type="button"
            aria-label="Notifications"
            className="flex h-9 w-9 items-center justify-center rounded-full bg-surface text-ink-soft hover:text-ink transition-colors"
          >
            <Bell className="h-4 w-4" />
          </button>
          <button
            type="button"
            aria-label="Account"
            onClick={() => toggleMenu("account")}
            className="flex h-9 w-9 items-center justify-center rounded-full bg-accent text-sm font-semibold text-ink-fixed"
          >
            {initials(displayName)}
          </button>

          {openMenu && (
            <button
              type="button"
              aria-label="Close menu"
              tabIndex={-1}
              onClick={() => setOpenMenu(null)}
              className="fixed inset-0 z-40 cursor-default"
            />
          )}

          {openMenu === "settings" && (
            <div className="absolute right-0 top-full z-50 mt-3 w-64 rounded-2xl border border-white/40 bg-surface/90 p-4 shadow-xl backdrop-blur-xl dark:border-white/10">
              <h3 className="mb-3 font-heading text-sm font-semibold">Settings</h3>
              <p className="mb-2 text-xs font-medium text-ink-soft">Appearance</p>
              <div className="flex items-center gap-1 rounded-full bg-cream p-1">
                <button
                  type="button"
                  onClick={() => setTheme("light")}
                  className={`flex flex-1 items-center justify-center gap-1.5 rounded-full py-1.5 text-xs font-medium transition-colors ${
                    theme === "light" ? "bg-ink text-cream" : "text-ink-soft hover:text-ink"
                  }`}
                >
                  <Sun className="h-3.5 w-3.5" /> Light
                </button>
                <button
                  type="button"
                  onClick={() => setTheme("dark")}
                  className={`flex flex-1 items-center justify-center gap-1.5 rounded-full py-1.5 text-xs font-medium transition-colors ${
                    theme === "dark" ? "bg-ink text-cream" : "text-ink-soft hover:text-ink"
                  }`}
                >
                  <Moon className="h-3.5 w-3.5" /> Dark
                </button>
              </div>
            </div>
          )}

          {openMenu === "account" && (
            <div className="absolute right-0 top-full z-50 mt-3 w-64 rounded-2xl border border-white/40 bg-surface/90 p-5 shadow-xl backdrop-blur-xl dark:border-white/10">
              <div className="mb-4 flex items-center gap-3">
                <div className="flex h-11 w-11 items-center justify-center rounded-full bg-accent text-sm font-semibold text-ink-fixed">
                  {initials(displayName)}
                </div>
                <div>
                  <p className="font-heading text-sm font-bold capitalize">{displayName}</p>
                  <p className="text-xs text-ink-soft">{me?.company ?? "Axia Solutions"}</p>
                </div>
              </div>
              <div className="mb-3 flex flex-col gap-2 rounded-2xl bg-cream p-3 text-sm">
                <div>
                  <p className="text-xs text-ink-soft">Email</p>
                  <p className="font-medium">{me?.email ?? "—"}</p>
                </div>
              </div>
              <button
                type="button"
                onClick={auth.logout}
                className="flex w-full items-center justify-center gap-1.5 rounded-full bg-ink py-2 text-xs font-semibold text-cream hover:opacity-90"
              >
                <LogOut className="h-3.5 w-3.5" /> Log out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
