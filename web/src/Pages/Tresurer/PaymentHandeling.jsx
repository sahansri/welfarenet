import React from 'react'
import { Receipt, Eye, Megaphone, Check, X, Clock, User, Calendar, CreditCard,BadgeDollarSign,Gift,AlertTriangle,RefreshCcw} from 'lucide-react'
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery,useQueryClient,useMutation } from '@tanstack/react-query';
import axios from '../../config'

export default function PaymentHandling() {

    const navigate = useNavigate();
    const queryClient = useQueryClient();
    const token = localStorage.getItem('token');

    const [showImage,setShowImage] = useState(false);
    const [showingImage,setShowingImage] = useState(null);
    const [processingId, setProcessingId] = useState(null);
    const [showRejectPaymentModal, setShowRejectPaymentModal] = useState(false);
    const [rejectReason, setRejectReason] = useState("");
    const [selectedPaymentId, setSelectedPaymentId] = useState(null);

    const fetchNotApprovedPayments = async () => {
        const response = await axios.get('/payment/unapproved',{
            headers:{
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })
        console.log("Not approved payments fetched:", response.data);
        if(Array.isArray(response.data)) {
            console.log("Not approved payments fetched:", response.data);
            return response.data;
        }
        return [];
    }

    const aprrovePayment = async (paymentId) => {
        try{
            const response = await axios.put(`payment/${paymentId}/approve`,null,{
                    headers:{
                        "Authorization": `Bearer ${token}`,
                        "Content-Type": 'application/json'
                    }
            });
        }
        catch(error){
            console.log("Error occured while approving payment:", error);
        }
    }
    
    const rejectPayment = async (paymentId, reason)=>{
        try{
            //URL may change based on backend implementation
            const response = await axios.put(`payment/${paymentId}/reject`,{
                reason: reason
            },{
                    headers:{
                        "Authorization": `Bearer ${token}`,
                        "Content-Type": 'application/json'
                    }
            });
        }
        catch(error){
            console.log("Error occured while rejecting payment:", error);
        }
    }

    const {
        data: notApprovedPayments=[],
        isLoading,
        isError,
        error,
        refetch
    } = useQuery({
        queryKey: ['notApprovedPayments'],
        queryFn: fetchNotApprovedPayments,
        staleTime: 5*60*1000, //fetch after 5mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    });

    const paymentApproveMutation = useMutation({
        mutationFn:({paymentId,reason})=>{
            aprrovePayment(paymentId);
        },
        onSuccess:()=>{
            queryClient.invalidateQueries(['notApprovedPayments']);
        },
        onError:(error)=>{
            alert("Failed to approve payment!",error);
        }
    });

    const paymentRejectMutation = useMutation({
        mutationFn:({paymentId})=>{
            rejectPayment(paymentId);
        },
        onSuccess:()=>{
            queryClient.invalidateQueries(['notApprovedPayments']);
            setShowRejectPaymentModal(false);
            setRejectReason("");
        },
        onError:(error)=>{
            alert("Failed to reject payment!",error);
        }
    });

    const handleViewPaymentHistory = () => {
        navigate('/treasurer/payments/history');
    }

    const handleViewReceipt = (imageLink) => {
        setShowImage(true);
        setShowingImage(imageLink);
    }


    if (isError){
        return (
            <div className="min-h-screen flex flex-col items-center justify-center pt-32  py-12 text-center">
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
                Loading Payments...
                </p>
            </div>
            </div>
        );
    }

  return (
    <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4  md:p-8'>
        <div className="max-w-6xl mx-auto pt-28">
            <main className="transition-all duration-300 pt-4">
                <div className="max-w-5xl mx-auto p-4">
                    {/* Header Section */}
                    <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
                        <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                        <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                        <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
                        
                        <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                            <div>
                                <div className="flex items-center gap-4 mb-3">
                                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                        <Receipt className="w-8 h-8 text-purple-900" />
                                    </div>
                                    <div>
                                        <h1 className="text-4xl font-bold tracking-tight">Payment Handling</h1>
                                        <div className="flex items-center gap-2 mt-1">
                                            <Clock className="w-4 h-4" />
                                            <span className="text-sm text-purple-100">{notApprovedPayments.length} pending approval</span>
                                        </div>
                                    </div>
                                </div>
                                <p className="text-purple-100 text-lg">Manage payments done by your community members</p>
                            </div>
                            <button
                                onClick={handleViewPaymentHistory}
                                className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                            >
                                <Eye className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                Payment History
                            </button>
                        </div>
                    </div>

                    {/* Payments List */}
                    <div className="space-y-6">
                        {notApprovedPayments.length === 0 ? (
                            <div className="bg-gradient-to-br from-white to-purple-50 rounded-3xl shadow-xl p-16 text-center border-2 border-purple-100">
                                <div className="bg-gradient-to-br from-purple-100 to-pink-100 w-24 h-24 rounded-full flex items-center justify-center mx-auto mb-6">
                                    <Megaphone className="w-12 h-12 text-purple-600" />
                                </div>
                                <h3 className="text-2xl font-bold text-gray-800 mb-3">All Clear!</h3>
                                <p className="text-gray-600 text-lg">No pending receipts at the moment. You'll be notified when a member uploads a receipt.</p>
                            </div>
                        ) : (
                            notApprovedPayments.map((payment, index) => {
                                const isProcessing = processingId === payment.paymentId;
                                return (
                                    <div
                                        key={payment.paymentId}
                                        className={`bg-gradient-to-br from-white via-purple-50 to-pink-50 rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-500 overflow-hidden border-2 border-purple-100 hover:border-purple-300 transform hover:-translate-y-1 ${isProcessing ? 'opacity-50 scale-95' : ''}`}
                                        style={{
                                            animationDelay: `${index * 100}ms`
                                        }}
                                    >
                                        <div className="p-8">
                                            <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-8">
                                                {/* Payment Info */}
                                                <div className="flex-1 w-full">
                                                    <div className="flex items-start gap-6 mb-6">
                                                        <div className="bg-gradient-to-br from-purple-500 to-pink-500 w-16 h-16 rounded-2xl flex items-center justify-center text-white font-bold text-2xl shadow-lg flex-shrink-0">
                                                            {payment.fullName.charAt(0)}
                                                        </div>
                                                        <div className="flex-1">
                                                            <h3 className="text-2xl font-bold text-gray-800 mb-2 flex items-center gap-3">
                                                                {payment.fullName}
                                                                <span className="inline-block bg-gradient-to-r from-yellow-400 to-orange-400 text-white px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-wide shadow-md">
                                                                    Pending
                                                                </span>
                                                            </h3>
                                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                                                                <div className="flex items-center gap-3 bg-white p-3 rounded-xl shadow-sm">
                                                                    <div className="bg-purple-100 p-2 rounded-lg">
                                                                        <CreditCard className="w-5 h-5 text-purple-600" />
                                                                    </div>
                                                                    <div>
                                                                        <p className="text-xs text-gray-500 font-semibold">Reference</p>
                                                                        <p className="font-mono text-sm font-bold text-gray-800">{payment.refNo}</p>
                                                                    </div>
                                                                </div>
                                                                <div className="flex items-center gap-3 bg-white p-3 rounded-xl shadow-sm">
                                                                    <div className="bg-pink-100 p-2 rounded-lg">
                                                                        <Calendar className="w-5 h-5 text-pink-600" />
                                                                    </div>
                                                                    <div>
                                                                        <p className="text-xs text-gray-500 font-semibold">Date</p>
                                                                        <p className="text-sm font-bold text-gray-800">{payment.paymentDate}</p>
                                                                    </div>
                                                                </div>
                                                                <div className="flex items-center gap-3 bg-white p-3 rounded-xl shadow-sm">
                                                                    <div className="bg-purple-100 p-2 rounded-lg">
                                                                        {payment.paymentType === "DONATION" ?(
                                                                            <Gift className="w-5 h-5 text-purple-600"/>
                                                                        ):(
                                                                            <Receipt className="w-5 h-5 text-purple-600" />
                                                                        )}
                                                                        
                                                                    </div>
                                                                    <div>
                                                                        <p className="text-xs text-gray-500 font-semibold">Type</p>
                                                                        <p className="font-mono text-sm font-bold text-gray-800">{payment.paymentType}</p>
                                                                    </div>
                                                                </div>
                                
                                                            </div>
                                                        </div>
                                                    </div>
                                                    
                                                    <button
                                                        onClick={() => handleViewReceipt(payment.image)}
                                                        className="flex items-center gap-3 text-purple-600 hover:text-purple-700 font-bold transition-all group bg-purple-50 hover:bg-purple-100 px-6 py-3 rounded-xl"
                                                    >
                                                        <Eye className='w-5 h-5 group-hover:scale-125 transition-transform'/>
                                                        <span className="group-hover:underline">View Receipt</span>
                                                    </button>
                                                </div>

                                                {/* Amount and Actions */}
                                                <div className="flex flex-col items-center lg:items-end gap-6 w-full lg:w-auto">
                                                    <div className="bg-gradient-to-br from-purple-600 to-pink-600 text-white px-8 py-4 rounded-2xl shadow-xl">
                                                        <p className="text-sm font-semibold opacity-90">Amount</p>
                                                        <p className="text-3xl font-bold">{payment.amount}</p>
                                                    </div>
                                                    
                                                    <div className="flex gap-4 w-full lg:w-auto">
                                                        <button
                                                            onClick={() => {paymentApproveMutation.mutate({paymentId: payment.paymentId})}}
                                                            disabled={paymentApproveMutation.isPending}
                                                            className="flex-1 lg:flex-initial bg-gradient-to-r from-green-500 to-emerald-600 text-white px-8 py-4 rounded-2xl font-bold hover:from-green-600 hover:to-emerald-700 transition-all shadow-lg hover:shadow-green-500/50 hover:scale-105 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                                                        >
                                                            <Check className="w-6 h-6" />
                                                            Approve
                                                        </button>
                                                        <button
                                                            onClick={() =>{
                                                                setShowRejectPaymentModal(true); 
                                                                setSelectedPaymentId(payment.paymentId);
                                                            }}
                                                            className="flex-1 lg:flex-initial bg-gradient-to-r from-red-500 to-rose-600 text-white px-8 py-4 rounded-2xl font-bold hover:from-red-600 hover:to-rose-700 transition-all shadow-lg hover:shadow-red-500/50 hover:scale-105 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                                                        >
                                                            <X className="w-6 h-6" />
                                                            Reject
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </div>
            </main>

            {/*View Recipt Model*/}
            {showImage && showingImage &&(
                <div 
                    className="fixed inset-0 bg-black/90 flex items-center justify-center z-50"
                    onClick={()=>{setShowImage(false)}}
                >
                    <img 
                        src={showingImage}
                        alt="recipt_Image"
                        className="max-w max-h rounded-lg"
                    />
                </div>
            )}

            {/*Reject Payment model*/}
            {showRejectPaymentModal && (
            <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                <div className="bg-white rounded-2xl p-6 w-full max-w-md shadow-xl">
                
                <h2 className="text-xl font-bold mb-4">Reject Payment</h2>

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
                        setShowRejectPaymentModal(false);
                        setRejectReason("");
                    }}
                    className="px-4 py-2 bg-gray-200 rounded-lg hover:bg-gray-300"
                    >
                    Cancel
                    </button>

                    <button
                    onClick={() => paymentRejectMutation.mutate({paymentId: selectedPaymentId, reason: rejectReason})}
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
  )
}