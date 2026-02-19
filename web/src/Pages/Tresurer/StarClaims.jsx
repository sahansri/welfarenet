import { useState } from 'react';
import { Plus, Edit2, Trash2, DollarSign,Eye ,Calendar, User, FileText, Upload, X, CheckCircle, Download, Gift,Check } from 'lucide-react';
import { useQuery ,useQueryClient,useMutation} from '@tanstack/react-query';
import axios from '../../config'

export default function StarClaims() {

    const queryClient = useQueryClient();
    const token = localStorage.getItem("token");
    const processedBy = localStorage.getItem("fullName");

    const[showRejectStarClaimModal,setShowRejectStarClaimModal] = useState(false);
    const [rejectReason,setRejectReason] = useState("");
    const [selectedClaimId,setSelectedClaimId] = useState(null);
    
    const fetchClaims = async () =>{
        try{
            const response = await axios.get("/claims/getAllStarClaims",{
                headers:{
                    'Authorization':`Bearer ${token}`,
                    'Content-Type':'application/json'
                }
            });
            console.log(response.data);
            return response.data;
        }
        catch(error){
            console.error("Error fetching claims:", error);
            return [];
        }
    }

    
    const {
        data:claims=[],
        isLoading,
        isError,
        error,
        refetch
    }= useQuery({
        queryKey:['starClaims'],
        queryFn:fetchClaims,
        staleTime: 10*60*1000, //fetch after 10mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    });

    const approveClaimMutation = useMutation({
        mutationFn:({claimId,reason}) =>
            axios.post(`/claims/approve/${claimId}`,{
                'reason':reason
            },{
                headers:{
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                params:{
                    'processedBy':`${processedBy}`
                }
            }),
        onSuccess:()=>{
            queryClient.invalidateQueries(["starClaims"]);
        },
        onError:(error)=>{
            alert("Failed to Approve Claim!",error);
        }
    });

    const rejectClaimMutation = useMutation({
        mutationFn:(id) =>
            axios.post(`/claims/reject/${id}`,{
                'processedBy':`${processedBy}`,
            },{
                headers:{
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            }),
        onSuccess:()=>{
            queryClient.invalidateQueries(["starClaims"]);
            setRejectReason("");
            setShowRejectStarClaimModal(false);
        },
        onError:(error)=>{
            alert("Failed to Reject Claim!",error);
        }
    });
    
    if (isError){
            return (
                <div className="min-h-screen flex flex-col items-center justify-center py-12 text-center">
                <AlertTriangle className="h-10 w-10 text-red-500 mb-4" />
                <h2 className="text-lg font-semibold text-gray-800">
                    Something went wrong
                </h2>
                <p className="text-sm text-gray-600 mt-2 max-w-sm">
                    {error?.message || "We couldn’t load the data. Please try again."}
                </p>
                <button
                    onClick={refetch}
                    className="mt-6 inline-flex items-center gap-2 rounded-lg bg-red-500 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 transition"
                >
                    <RefreshCcw size={16} />
                    Retry
                </button>
                </div>
            );
        }
    
        if (isLoading) {
            return (
                <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
                <div className="text-center">
                    <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                    <p className="mt-4 text-gray-700 font-medium">
                        Loading Claims...
                    </p>
                </div>
                </div>
            );
        }
    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-5xl mx-auto p-4">
                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="w-16 h-16 bg-white rounded-xl flex items-center justify-center">
                                            <Gift size={32} className="text-purple-900" />
                                        </div>
                                        <div>
                                            <h1 className="text-3xl font-bold text-white mb-1">Unity Star Claims</h1>
                                            <p className="text-purple-100">View and manage star claims from members</p>
                                        </div>
                                    </div>

                                    <button
                                    onClick={() => handleOpenModal()}
                                    className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                                    >
                                        <Eye className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                        Previous Claims
                                    </button>     
                                </div>         
                        </div>

                        {/* Claims List */}
                        <div className="space-y-4">
                            {claims.length === 0 ? (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <DollarSign className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No New Claims Yet</h3>
                                    <p className="text-gray-500 mb-6">Come back later to see new claims</p>
                                    <button
                                        onClick={() => handleOpenModal()}
                                        className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-blue-700 transition-all shadow-md"
                                    >
                                        View Previous Claims
                                    </button>
                                </div>
                            ) : (
                                claims.map((claim) => (
                                    <div 
                                        key={claim.requestId} 
                                        className="bg-gradient-to-br from-white via-purple-50 to-pink-100 rounded-2xl shadow-md transform hover:scale-[1.02] transition-all duration-300 overflow-hidden border-l-4 border-l-green-500"
                                    >
                                        <div className="p-6">
                                            {/* Claim Request Header */}
                                            <div className="flex flex-col sm:flex-row items-start justify-between gap-4 mb-4">
                                                <div className="flex-1">
                                                    <div className="flex items-center gap-3 mb-2">
                                                        <User className="w-5 h-5 text-purple-600" />
                                                        <h2 className="text-xl font-bold text-gray-900">
                                                            {claim.fullName}
                                                        </h2>
                                                    </div>
                                                    <div className="flex flex-wrap items-center gap-2 text-sm text-gray-600">
                                                        <span className="flex items-center gap-1">
                                                            <Calendar className="w-4 h-4" />
                                                            {new Date(claim.appliedAt).toLocaleDateString()}
                                                        </span>
                                                        <span>•</span>
                                                        <span>{new Date(claim.appliedAt).toLocaleTimeString()}</span>
                                                    </div>
                                                </div>
                                                <div className="flex flex-col items-end gap-2">
                                                    <div className="text-right">
                                                        <p className="text-2xl font-bold text-purple-600">
                                                            ⭐ {claim.starsDeducted}
                                                        </p>
                                                        <p className="text-xs text-gray-500">Stars Claimed</p>
                                                    </div>
                                                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                                                        claim.status === 'APPROVED' ? 'bg-green-100 text-green-700' :
                                                        claim.status === 'REJECTED' ? 'bg-red-100 text-red-700' :
                                                        claim.status === 'PENDING' ? 'bg-yellow-100 text-yellow-700' :
                                                        'bg-gray-100 text-gray-700'
                                                    }`}>
                                                        {claim.status}
                                                    </span>
                                                </div>
                                            </div>

                                            {/* Claim Details */}
                                            <div className="space-y-2 mb-4">
                                                <div className="flex items-center gap-2 text-sm">
                                                    <span className="font-semibold text-gray-700">Reward:</span>
                                                    <span className="text-gray-600">{claim.rewardValue}</span>
                                                </div>
                                                {claim.processedAt && (
                                                    <div className="flex items-center gap-2 text-sm">
                                                        <span className="font-semibold text-gray-700">Processed:</span>
                                                        <span className="text-gray-600">
                                                            {new Date(claim.processedAt).toLocaleDateString()} by {claim.processedBy}
                                                        </span>
                                                    </div>
                                                )}
                                                {claim.adminMessage && (
                                                    <div className="mt-3 p-3 bg-blue-50 rounded-lg border border-blue-200">
                                                        <p className="text-sm text-gray-700">
                                                            <span className="font-semibold">Admin Message:</span> {claim.adminMessage}
                                                        </p>
                                                    </div>
                                                )}
                                            </div>

                                            {/* Action Buttons */}
                                            <div className="flex flex-wrap items-center gap-3 pt-4 border-t border-gray-200">
                                                <button
                                                    onClick={() => {approveClaimMutation.mutate(claim.requestId)}}
                                                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-xl transform hover:scale-110 hover:bg-blue-700 transition-all font-medium"
                                                >
                                                    <Check className="w-6 h-6" />
                                                        Approve
                                                </button>
                                                <button
                                                    onClick={() => {
                                                        setSelectedClaimId(claim.requestId);
                                                        setShowRejectStarClaimModal(true);
                                                    }}
                                                    className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-xl transform hover:scale-110 hover:bg-red-700 transition-all font-medium"
                                                >
                                                    <X className="w-6 h-6" />
                                                        Reject
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                            )))}
                        </div>
                    </div>
                </main>

                {/*Reject StarClaim model*/}
                {showRejectStarClaimModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                    
                    <h2 className="text-xl font-bold mb-4">Reject Star Claim</h2>

                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Reason for rejection
                    </label>

                    <textarea
                        value={rejectReason}
                        onChange={(e) => setRejectReason(e.target.value)}
                        placeholder="Enter reason..."
                        className="w-full border rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-red-400"
                        rows={4}
                    />

                    <div className="flex justify-end gap-3 mt-6">
                        <button
                        onClick={() => {
                            setShowRejectStarClaimModal(false);
                            setRejectReason("");
                        }}
                        className="px-4 py-2 bg-gray-200 rounded-lg hover:bg-gray-300"
                        >
                        Cancel
                        </button>

                        <button
                        onClick={() => rejectClaimMutation.mutate({claimId: selectedClaimId, reason: rejectReason})}
                        className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
                        >
                        Confirm Reject
                        </button>
                    </div>

                    </div>
                </div>
                )} 

            </div>
        </div>
    );
}