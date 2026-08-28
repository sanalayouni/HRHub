import { Navigate, Outlet, Route, Routes } from "react-router-dom";
import { TopNav } from "./components/layout/TopNav";
import { DashboardPage } from "./pages/DashboardPage";
import { RequestsPage } from "./pages/RequestsPage";
import { RequestDetailPage } from "./pages/RequestDetailPage";
import { DecisionHistoryPage } from "./pages/DecisionHistoryPage";
import { EmployeeDirectoryPage } from "./pages/EmployeeDirectoryPage";
import { LoginPage } from "./pages/LoginPage";
import { useAuth } from "./lib/auth";

function ProtectedLayout() {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return (
    <div className="min-h-screen font-body">
      <TopNav />
      <Outlet />
    </div>
  );
}

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<ProtectedLayout />}>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/requests" element={<RequestsPage />} />
        <Route path="/requests/:requestId" element={<RequestDetailPage />} />
        <Route path="/decisions" element={<DecisionHistoryPage />} />
        <Route path="/employees" element={<EmployeeDirectoryPage />} />
      </Route>
    </Routes>
  );
}

export default App;
