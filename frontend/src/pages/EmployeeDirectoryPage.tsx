import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { fetchEmployee, fetchEmployees } from "../api/employees";
import { PageShell } from "../components/layout/PageShell";
import { FolderCard } from "../components/common/FolderCard";
import { EmployeeFilters } from "../components/employees/EmployeeFilters";
import { EmployeeTable } from "../components/employees/EmployeeTable";
import { EmployeeProfilePanel } from "../components/employees/EmployeeProfilePanel";
import { AddEmployeeModal } from "../components/employees/AddEmployeeModal";

export function EmployeeDirectoryPage() {
  const [search, setSearch] = useState("");
  const [department, setDepartment] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["employees", { search, department }],
    queryFn: () =>
      fetchEmployees({ search: search || undefined, department: department || undefined }),
  });

  const { data: editingEmployee } = useQuery({
    queryKey: ["employee", editingId],
    queryFn: () => fetchEmployee(editingId!),
    enabled: Boolean(editingId),
  });

  const departments = useMemo(
    () => Array.from(new Set((data ?? []).map((e) => e.department))).sort(),
    [data]
  );

  return (
    <PageShell title="Employees" subtitle="Browse employee records referenced by the AI agents">
      <div className="flex flex-col items-start gap-6 lg:flex-row">
        <div className="min-w-0 flex-1">
          <FolderCard>
            <EmployeeFilters
              search={search}
              onSearchChange={setSearch}
              department={department}
              onDepartmentChange={setDepartment}
              departments={departments}
              onAddEmployee={() => setShowAddModal(true)}
            />
            {isLoading ? (
              <p className="px-5 pb-5 text-sm text-ink-soft">Loading...</p>
            ) : (
              <EmployeeTable employees={data ?? []} selectedId={selectedId} onSelect={setSelectedId} />
            )}
          </FolderCard>
        </div>
        {selectedId && (
          <div className="w-full lg:sticky lg:top-8 lg:w-[360px] lg:shrink-0">
            <EmployeeProfilePanel
              employeeId={selectedId}
              onClose={() => setSelectedId(null)}
              onEdit={() => setEditingId(selectedId)}
            />
          </div>
        )}
      </div>
      {showAddModal && <AddEmployeeModal onClose={() => setShowAddModal(false)} />}
      {editingId && editingEmployee && (
        <AddEmployeeModal employee={editingEmployee} onClose={() => setEditingId(null)} />
      )}
    </PageShell>
  );
}
