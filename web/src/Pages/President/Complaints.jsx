import React, { useState, useEffect } from "react";
import { ChevronDown, ChevronUp, FileText, CheckCircle, Clock, AlertCircle, Lightbulb, Filter, Eye, MessageSquare } from "lucide-react";
import { useNavigate } from "react-router-dom";
import axios from "../../config"

export default function Complaints() {

  const navigate = useNavigate();

  const [complaints, setComplaints] = useState([]);
  const [expanded, setExpanded] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [filterType, setFilterType] = useState("all");
  const [filterStatus, setFilterStatus] = useState("all");


  // Fetch complaints
  useEffect(() => {
    setIsLoading(true);
    const fetchComplaints = async ()=>{
      const token = localStorage.getItem('token');
      try{
        const response = await axios.get('/complaints/all',{
          headers:{
            Authorization: `Bearer ${token}`
          }
        });
        if(Array.isArray(response.data)){
          console.log("Fetched complaints:", response.data);
          setComplaints(response.data);
        }
      }
      catch(error){
        console.error("Error fetching complaints:", error);
      }
      finally{
        setIsLoading(false);
      }
    }
    fetchComplaints();
    
  }, []);

  const toggleExpand = (id) => {
    setExpanded(expanded === id ? null : id);
  };

  const markAsReviwed = async (id) => {
    try{
      const token = localStorage.getItem('token');

      const response = await axios.post(`/complaints/review/${id}`,{},{
        headers:{
          "Authorization": `Bearer ${token}`,
          "Content-Type": 'application/json'
        }
      })

      if(response.status === 200){
        setComplaints((old) =>
          old.map((c) => (c.id === id ? response.data : c))
        );
      }
    }
    catch(error){
      console.error("Error updating complaint status:", error);
    }
    
  };

  const filteredComplaints = complaints.filter((c) => {
  const typeMatch =
    filterType === "all" || c.type === filterType;

  const statusMatch =
    filterStatus === "all" ||
    (filterStatus === "reviewed" && c.isReviewed === true) ||
    (filterStatus === "not_reviewed" && c.isReviewed === false);

  return typeMatch && statusMatch;
});

  const getStatusBadge = (isReviwed) => {
    if(isReviwed === true) {
      return "bg-green-100 text-green-700 border-green-200";
    }
    else{
      return "bg-orange-100 text-orange-700 border-orange-200";
    }
  };

  const getTypeGradient = (type) => {
    return type === "complaint" 
      ? "from-red-500 via-orange-500 to-pink-500"
      : "from-yellow-500 via-amber-500 to-orange-500";
  };

  const handleViewOldComplaints = () => {
    navigate('/president/complaints/view');
  };
  if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Fetching complaints...
                </p>
            </div>
            </div>
        );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8">
      <div className="max-w-6xl mx-auto pt-28">
        <main className="transition-all duration-300 pt-4">
          <div className="max-w-5xl mx-auto p-4">
            
            {/* Header */}
            <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
              <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
              <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
              <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
              
              <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div>
                  <div className="flex items-center gap-4 mb-3">
                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                      <MessageSquare className="w-8 h-8 text-purple-900" />
                    </div>
                    <div>
                      <h1 className="text-4xl font-bold tracking-tight">Complaints & Suggestions</h1>
                    </div>
                  </div>
                  <p className="text-purple-100 text-lg">Review feedback from your community members</p>
                </div>
                <button
                  onClick={handleViewOldComplaints}
                  className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                >
                  <Eye className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                  View History
                </button>
              </div>
            </div>

            {/* Filters Card */}
            <div className="bg-white rounded-2xl shadow-lg p-6 mb-6 border border-gray-100">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                  <Filter className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Filters</h3>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Type</label>
                  <select
                    value={filterType}
                    onChange={(e) => setFilterType(e.target.value)}
                    className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  >
                    <option value="all">All Types</option>
                    <option value="COMPLAINT">Complaints</option>
                    <option value="SUGGESTION">Suggestions</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                  <select
                    value={filterStatus}
                    onChange={(e) => setFilterStatus(e.target.value)}
                    className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-gray-900 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  >
                    <option value="all">All Status</option>
                    <option value="not_reviewed">Not Reviewed</option>
                    <option value="reviewed">Reviewed</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Complaints List */}
            <div className="space-y-6">
              {filteredComplaints.map((c) => (
                <div
                  key={c.complaintId}
                  className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-300 overflow-hidden border border-gray-100"
                >
                  {/* Colorful Top Border */}
                  <div className={`h-2 bg-gradient-to-r ${getTypeGradient(c.type)}`}></div>
                  
                  <div className="p-6 md:p-8">
                    {/* Header */}
                    <div className="flex justify-between items-start mb-4">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-3">
                          <div className={`w-12 h-12 bg-gradient-to-br ${getTypeGradient(c.type)} rounded-2xl flex items-center justify-center shadow-lg`}>
                            {c.type === 'complaint' ? (
                              <AlertCircle className="w-6 h-6 text-white" />
                            ) : (
                              <Lightbulb className="w-6 h-6 text-white" />
                            )}
                          </div>
                          <div className="flex-1">
                            <h3 className="text-2xl font-bold text-gray-900 leading-tight">{c.title}</h3>
                            <p className="text-sm text-gray-500 mt-1">
                              Submitted by <span className="font-semibold text-gray-900">{c.submittedBy===null?"Anonymus member":c.submittedBy.fullName}</span> • {c.date}
                            </p>
                          </div>
                        </div>
                        
                        <div className="flex flex-wrap gap-2">
                          <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getStatusBadge(c.isReviewed)}`}>
                            {c.isReviewed ? "REVIEWED" : "NOT REVIEWED"}
                          </span>
                          <span className="px-3 py-1 rounded-full text-xs font-semibold bg-purple-100 text-purple-700 border border-purple-200">
                            {c.type.toUpperCase()}
                          </span>
                        </div>
                      </div>

                      <button
                        className="p-3 rounded-xl hover:bg-gray-100 text-gray-600 transition ml-4"
                        onClick={() => toggleExpand(c.complaintId)}
                      >
                        {expanded === c.complaintId ? <ChevronUp size={24} /> : <ChevronDown size={24} />}
                      </button>
                    </div>

                    {/* Expanded section */}
                    {expanded === c.complaintId && (
                      <div className="mt-6 pt-6 border-t border-gray-200">
                        
                        <div className="bg-gray-50 rounded-xl p-4 mb-6 border border-gray-100">
                          <p className="text-sm font-semibold text-gray-700 mb-2 uppercase tracking-wide">Description</p>
                          <p className="text-gray-700 leading-relaxed">{c.description}</p>
                        </div>

                        {/* Attachment */}
                        {c.attachment && (
                          <a
                            href={c.attachment}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 text-purple-600 hover:text-purple-700 font-medium mb-6"
                          >
                            <FileText size={18} /> View Attachment
                          </a>
                        )}

                        {/* Status Action Buttons */}
                        {c.isReviewed ===false &&(
                          <div className="flex flex-wrap gap-3">
                            <button
                              onClick={() => markAsReviwed(c.complaintId)}
                              className={`flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all ${
                                c.isReviewed === true
                                  ? "bg-gradient-to-r from-blue-500 to-cyan-500 text-white shadow-lg"
                                  : "bg-blue-100 text-blue-700 hover:bg-blue-200"
                              }`}
                            >
                              <Clock size={18} /> Mark As Reviwed
                            </button>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              ))}

              {filteredComplaints.length === 0 && (
                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                  <MessageSquare className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <h3 className="text-xl font-semibold text-gray-700 mb-2">No Items Found</h3>
                  <p className="text-gray-500">No complaints or suggestions match your current filters.</p>
                </div>
              )}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}