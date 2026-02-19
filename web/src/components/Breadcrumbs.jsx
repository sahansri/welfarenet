import { Link, useLocation } from "react-router-dom";
import { Home } from "lucide-react";

export default function Breadcrumb() {
  const location = useLocation();
  const segments = location.pathname.split("/").filter(Boolean);

  const isDashboardRoot =
    segments.length === 1 && segments[0] === "dashboard";

  return (
    <div className="px-2 py-1 rounded-md">
      <div className="flex items-center gap-1 bg-[#874ECE]  px-2 pt-2 rounded-md text-sm">

        {/* Home Link */}
        <Link
          to="/dashboard"
          className="flex items-center text-white hover:text-black font-medium"
        >
          <Home size={16} />
          Home
        </Link>

        {/* When not on dashboard, show remaining path */}
        {!isDashboardRoot &&
          segments.slice(1).map((segment, index) => (
            <div key={index} className="flex items-center gap-2">
              <span className="text-white">/</span>
              <span className="capitalize text-white">
                {segment.replace("-", " ")}
              </span>
            </div>
          ))}
      </div>
    </div>
  );
}
