import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Check, MessageCircleQuestion, X } from "lucide-react";
import { decideRequest } from "../../api/requests";
import type { DecisionDecideIn } from "../../api/types";

interface Props {
  requestId: string;
  existingNotes?: string | null;
}

export function DecisionActionBar({ requestId, existingNotes }: Props) {
  const [notes, setNotes] = useState(existingNotes ?? "");
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (payload: DecisionDecideIn) => decideRequest(requestId, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["request", requestId] });
      queryClient.invalidateQueries({ queryKey: ["requests"] });
      queryClient.invalidateQueries({ queryKey: ["decisions"] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-summary"] });
    },
  });

  const decide = (status: DecisionDecideIn["status"]) => {
    mutation.mutate({ status, notes: notes.trim() || null });
  };

  return (
    <div className="mt-6 rounded-3xl bg-ink p-5 text-cream shadow-lg">
      <p className="mb-3 text-xs font-semibold uppercase tracking-wide text-cream/60">
        Your decision
      </p>
      <textarea
        value={notes}
        onChange={(e) => setNotes(e.target.value)}
        placeholder="Add an optional note explaining your decision..."
        rows={2}
        className="w-full resize-none rounded-2xl bg-cream/10 p-3 text-sm text-cream placeholder:text-cream/40 outline-none focus:bg-cream/15"
      />
      <div className="mt-3 flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => decide("approved")}
          disabled={mutation.isPending}
          className="flex items-center gap-1.5 rounded-full bg-sage px-4 py-2 text-sm font-semibold text-ink hover:opacity-90 disabled:opacity-50"
        >
          <Check className="h-4 w-4" /> Approve
        </button>
        <button
          type="button"
          onClick={() => decide("rejected")}
          disabled={mutation.isPending}
          className="flex items-center gap-1.5 rounded-full bg-coral px-4 py-2 text-sm font-semibold text-ink hover:opacity-90 disabled:opacity-50"
        >
          <X className="h-4 w-4" /> Reject
        </button>
        <button
          type="button"
          onClick={() => decide("needs_review")}
          disabled={mutation.isPending}
          className="flex items-center gap-1.5 rounded-full bg-dustyblue px-4 py-2 text-sm font-semibold text-ink hover:opacity-90 disabled:opacity-50"
        >
          <MessageCircleQuestion className="h-4 w-4" /> Request Info
        </button>
      </div>
      {mutation.isError && (
        <p className="mt-2 text-xs text-coral">Couldn't save your decision. Try again.</p>
      )}
    </div>
  );
}
