import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation } from "@tanstack/react-query";
import { Star } from "lucide-react";
import { login } from "../api/auth";
import { useAuth } from "../lib/auth";
import logo from "../assets/hrhub-logo.png";

export function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();
  const auth = useAuth();

  const mutation = useMutation({
    mutationFn: () => login(email, password),
    onSuccess: (data) => {
      auth.login(data.access_token);
      navigate("/", { replace: true });
    },
  });

  const submit = (e: FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password || mutation.isPending) return;
    mutation.mutate();
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-ink p-3 sm:p-6">
      <div className="relative w-full max-w-5xl overflow-hidden rounded-[2rem] bg-surface shadow-2xl">
        <div
          className="absolute inset-0"
          style={{
            backgroundImage:
              "linear-gradient(to right, rgba(26,26,26,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(26,26,26,0.05) 1px, transparent 1px)",
            backgroundSize: "56px 56px",
          }}
        />
        <div
          className="absolute -left-16 top-16 h-56 w-56 rounded-full opacity-60 blur-3xl"
          style={{ background: "radial-gradient(circle, #f5c842 0%, transparent 70%)" }}
        />
        <div
          className="absolute -right-10 bottom-0 h-64 w-64 rounded-full opacity-50 blur-3xl"
          style={{ background: "radial-gradient(circle, #f5c842 0%, transparent 70%)" }}
        />

        <div className="relative z-10 flex flex-col px-6 py-8 sm:px-10 sm:py-10">
          <div className="mb-12 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <img src={logo} alt="HRHub" className="h-9 w-9 rounded-xl" />
              <span className="font-heading text-lg font-bold tracking-tight text-ink">HRHub</span>
            </div>
            <span className="rounded-full bg-cream px-4 py-1.5 text-xs font-semibold text-ink-soft">
              Axia Solutions
            </span>
          </div>

          <div className="mx-auto flex w-full max-w-md flex-col items-center text-center">
            <span className="mb-5 inline-flex items-center gap-2 rounded-full bg-cream px-4 py-2 text-xs font-semibold text-ink-soft">
              <Star className="h-3.5 w-3.5 fill-accent text-accent" />
              HR Portal for Axia Solutions
            </span>

            <h1 className="font-heading text-4xl font-bold leading-[1.1] tracking-tight text-ink sm:text-5xl">
              Welcome Back to HRHub
            </h1>
            <p className="mt-4 text-sm text-ink-soft">
              Sign in to review requests, track decisions, and manage employee records for Axia
              Solutions.
            </p>

            <form onSubmit={submit} className="mt-8 flex w-full flex-col gap-3">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="hr@axiasolutions.com"
                autoComplete="username"
                className="w-full rounded-full border border-cream-soft bg-surface px-5 py-3 text-sm text-ink outline-none transition-all placeholder:text-ink-soft/60 focus:ring-2 focus:ring-accent/40"
              />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Password"
                autoComplete="current-password"
                className="w-full rounded-full border border-cream-soft bg-surface px-5 py-3 text-sm text-ink outline-none transition-all placeholder:text-ink-soft/60 focus:ring-2 focus:ring-accent/40"
              />
              <button
                type="submit"
                disabled={mutation.isPending}
                className="mt-1 w-full rounded-full bg-accent px-6 py-3 text-sm font-semibold text-ink-fixed shadow-[0_10px_24px_-8px_rgba(245,200,66,0.7)] transition-opacity hover:opacity-90 disabled:opacity-50"
              >
                {mutation.isPending ? "Signing in..." : "Sign In"}
              </button>
            </form>

            {mutation.isError && (
              <p className="mt-3 text-xs font-medium text-coral">
                Invalid email or password. Try again.
              </p>
            )}

            <p className="mt-6 text-xs text-ink-soft">
              Secure access for the Axia Solutions HR team only.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
