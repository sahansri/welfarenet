import { useState } from 'react';
import { ArrowLeft, Gift, Star, CheckCircle, XCircle, Clock, User, Calendar, DollarSign, AlertTriangle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function RedemptionRequests() {
    const navigate = useNavigate();
    const [requests, setRequests] = useState([
        {
            id: 1,
            memberId: 1,
            memberName: "Sarah Johnson",
            memberEmail: "sarah.j@email.com",
            pointsToRedeem: 100,
            voucherValue: 1000,
            currentPoints: 156,
            requestDate: "2025-01-15",
            status: "pending",
            notes: "Please process at earliest convenience"
        },
        {
            id: 2,
            memberId: 3,
            memberName: "Emma Wilson",
            memberEmail: "emma.w@email.com",
            pointsToRedeem: 50,
            voucherValue: 500,
            currentPoints: 234,
            requestDate: "2025-01-14",
            status: "pending",
            notes: ""
        },
        {
            id: 3,
            memberId: 2,
            memberName: "Mike Chen",
            memberEmail: "mike.chen@email.com",
            pointsToRedeem: 200,
            voucherValue: 2000,
            currentPoints: 98,
            requestDate: "2025-01-13",
            status: "approved",
            notes: "Thank you for the voucher!",
            processedDate: "2025-01-14"
        },
        {
            id: 4,
            memberId: 5,
            memberName: "Lisa Anderson",
            memberEmail: "lisa.a@email.com",
            pointsToRedeem: 100,
            voucherValue: 1000,
            currentPoints: 178,
            requestDate: "2025-01-12",
            status: "approved",
            notes: "",
            processedDate: "2025-01-13"
        },
        {
            id: 5,
            memberId: 4,
            memberName: "David Brown",
            memberEmail: "david.b@email.com",
            pointsToRedeem: 100,
            voucherValue: 1000,
            currentPoints: 64,
            requestDate: "2025-01-10",
            status: "rejected",
            notes: "Insufficient points",
            processedDate: "2025-01-11",
            rejectionReason: "Member doesn't have enough points"
        }
    ]);

    const [filterStatus, setFilterStatus] = useState('all');
    const [showRejectModal, setShowRejectModal] = useState(false);
    const [rejectReason, setRejectReason] = useState('');
    const [selectedRequest, setSelectedRequest] = useState(null);

    const handleBack = () => {
        navigate('/tresurer/expenses');
    };

    const handleApprove = (requestId) => {
        const request = requests.find(r => r.id === requestId);
        if (request.currentPoints < request.pointsToRedeem) {
            alert('Error: Member does not have enough points!');
            return;
        }

        setRequests(prev => prev.map(r =>
            r.id === requestId
                ? { ...r, status: 'approved', processedDate: new Date().toISOString().split('T')[0] }
                : r
        ));
        alert('Redemption request approved! Member will receive their voucher.');
    };

    const handleRejectClick = (requestId) => {
        setSelectedRequest(requestId);
        setShowRejectModal(true);
    };

    const confirmReject = () => {
        if (!rejectReason.trim()) {
            alert('Please provide a rejection reason');
            return;
        }

        setRequests(prev => prev.map(r =>
            r.id === selectedRequest
                ? {
                    ...r,
                    status: 'rejected',
                    processedDate: new Date().toISOString().split('T')[0],
                    rejectionReason: rejectReason
                }
                : r
        ));

        setShowRejectModal(false);
        setRejectReason('');
        setSelectedRequest(null);
        alert('Redemption request rejected.');
    };

    const cancelReject = () => {
        setShowRejectModal(false);
        setRejectReason('');
        setSelectedRequest(null);
    };

    const filteredRequests = requests.filter(r =>
        filterStatus === 'all' || r.status === filterStatus
    );

    const pendingCount = requests.filter(r => r.status === 'pending').length;
    const approvedCount = requests.filter(r => r.status === 'approved').length;
    const rejectedCount = requests.filter(r => r.status === 'rejected').length;

    const getStatusBadge = (status) => {
        const badges = {
            pending: { bg: 'bg-orange-100', text: 'text-orange-700', border: 'border-orange-200', icon: Clock },
            approved: { bg: 'bg-green-100', text: 'text-green-700', border: 'border-green-200', icon: CheckCircle },
            rejected: { bg: 'bg-red-100', text: 'text-red-700', border: 'border-red-200', icon: XCircle }
        };
        return badges[status] || badges.pending;
    };

    const getVoucherColor = (points) => {
        if (points === 50) return 'from-yellow-500 to-amber-500';
        if (points === 100) return 'from-orange-500 to-red-500';
        if (points === 200) return 'from-red-500 to-pink-500';
        return 'from-gray-500 to-gray-600';
    };

    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-5xl mx-auto p-4">
                        {/* Back Button */}
                        <button
                            onClick={handleBack}
                            className="mb-6 flex items-center gap-2 text-white hover:text-purple-200 transition-colors"
                        >
                            <ArrowLeft className="w-5 h-5" />
                            <span className="font-medium">Back to UnityStars</span>
                        </button>

                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            
                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-3">
                                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                        <Gift className="w-8 h-8 text-purple-900" />
                                    </div>
                                    <div>
                                        <h1 className="text-4xl font-bold tracking-tight">Redemption Requests</h1>
                                    </div>
                                </div>
                                <p className="text-purple-100 text-lg">Manage member voucher redemption requests</p>
                            </div>
                        </div>

                        {/* Stats Cards */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Pending</p>
                                        <p className="text-3xl font-bold text-orange-600">{pendingCount}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-amber-500 rounded-xl flex items-center justify-center">
                                        <Clock className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Approved</p>
                                        <p className="text-3xl font-bold text-green-600">{approvedCount}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                                        <CheckCircle className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Rejected</p>
                                        <p className="text-3xl font-bold text-red-600">{rejectedCount}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-red-500 to-pink-500 rounded-xl flex items-center justify-center">
                                        <XCircle className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Filter Buttons */}
                        <div className="bg-white rounded-2xl shadow-lg p-4 mb-6 border border-gray-100">
                            <div className="flex flex-wrap gap-3">
                                <button
                                    onClick={() => setFilterStatus('all')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'all'
                                            ? 'bg-gradient-to-r from-purple-600 to-blue-600 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    All ({requests.length})
                                </button>
                                <button
                                    onClick={() => setFilterStatus('pending')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'pending'
                                            ? 'bg-gradient-to-r from-orange-500 to-amber-500 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    Pending ({pendingCount})
                                </button>
                                <button
                                    onClick={() => setFilterStatus('approved')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'approved'
                                            ? 'bg-gradient-to-r from-green-500 to-emerald-500 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    Approved ({approvedCount})
                                </button>
                                <button
                                    onClick={() => setFilterStatus('rejected')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'rejected'
                                            ? 'bg-gradient-to-r from-red-500 to-pink-500 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    Rejected ({rejectedCount})
                                </button>
                            </div>
                        </div>

                        {/* Requests List */}
                        <div className="space-y-6">
                            {filteredRequests.map((request) => {
                                const statusBadge = getStatusBadge(request.status);
                                const StatusIcon = statusBadge.icon;
                                const hasEnoughPoints = request.currentPoints >= request.pointsToRedeem;

                                return (
                                    <div
                                        key={request.id}
                                        className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-300 overflow-hidden border border-gray-100"
                                    >
                                        {/* Colorful Top Border */}
                                        <div className={`h-2 bg-gradient-to-r ${getVoucherColor(request.pointsToRedeem)}`}></div>
                                        
                                        <div className="p-6 md:p-8">
                                            {/* Header */}
                                            <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 mb-6">
                                                <div className="flex items-center gap-4">
                                                    <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center text-white font-bold text-xl shadow-lg">
                                                        {request.memberName.charAt(0)}
                                                    </div>
                                                    <div>
                                                        <h3 className="text-2xl font-bold text-gray-900">{request.memberName}</h3>
                                                        <p className="text-sm text-gray-500">{request.memberEmail}</p>
                                                    </div>
                                                </div>
                                                <span className={`px-4 py-2 rounded-full text-sm font-semibold border flex items-center gap-2 ${statusBadge.bg} ${statusBadge.text} ${statusBadge.border}`}>
                                                    <StatusIcon className="w-4 h-4" />
                                                    {request.status.toUpperCase()}
                                                </span>
                                            </div>

                                            {/* Request Details */}
                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 rounded-2xl p-5 border border-purple-100">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                        <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs text-gray-500 font-medium">Points to Redeem</p>
                                                        <p className="text-lg font-bold text-gray-900">{request.pointsToRedeem}</p>
                                                    </div>
                                                </div>

                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                        <DollarSign className="w-5 h-5 text-green-600" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs text-gray-500 font-medium">Voucher Value</p>
                                                        <p className="text-lg font-bold text-green-600">Rs. {request.voucherValue.toLocaleString()}/=</p>
                                                    </div>
                                                </div>

                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                        <User className="w-5 h-5 text-blue-600" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs text-gray-500 font-medium">Current Points</p>
                                                        <p className={`text-lg font-bold ${hasEnoughPoints ? 'text-gray-900' : 'text-red-600'}`}>
                                                            {request.currentPoints}
                                                        </p>
                                                    </div>
                                                </div>

                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                        <Calendar className="w-5 h-5 text-purple-600" />
                                                    </div>
                                                    <div>
                                                        <p className="text-xs text-gray-500 font-medium">Request Date</p>
                                                        <p className="text-sm font-semibold text-gray-900">{request.requestDate}</p>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Insufficient Points Warning */}
                                            {!hasEnoughPoints && request.status === 'pending' && (
                                                <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start gap-3">
                                                    <AlertTriangle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                                                    <div>
                                                        <p className="font-semibold text-red-900">Insufficient Points</p>
                                                        <p className="text-sm text-red-700">
                                                            Member needs {request.pointsToRedeem - request.currentPoints} more points to redeem this voucher.
                                                        </p>
                                                    </div>
                                                </div>
                                            )}

                                            {/* Notes */}
                                            {request.notes && (
                                                <div className="mb-6">
                                                    <h4 className="text-sm font-semibold text-gray-700 mb-2 uppercase tracking-wide">Notes</h4>
                                                    <p className="text-gray-700 leading-relaxed bg-gray-50 rounded-xl p-4 border border-gray-100">
                                                        {request.notes}
                                                    </p>
                                                </div>
                                            )}

                                            {/* Rejection Reason */}
                                            {request.status === 'rejected' && request.rejectionReason && (
                                                <div className="mb-6">
                                                    <h4 className="text-sm font-semibold text-red-700 mb-2 uppercase tracking-wide">Rejection Reason</h4>
                                                    <p className="text-gray-700 leading-relaxed bg-red-50 rounded-xl p-4 border border-red-200">
                                                        {request.rejectionReason}
                                                    </p>
                                                </div>
                                            )}

                                            {/* Processed Date */}
                                            {request.processedDate && (
                                                <p className="text-sm text-gray-500 mb-6">
                                                    Processed on: {request.processedDate}
                                                </p>
                                            )}

                                            {/* Action Buttons */}
                                            {request.status === 'pending' && (
                                                <div className="flex flex-wrap gap-3 pt-6 border-t border-gray-200">
                                                    <button
                                                        onClick={() => handleApprove(request.id)}
                                                        disabled={!hasEnoughPoints}
                                                        className={`flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl font-semibold shadow-md transition-all ${
                                                            hasEnoughPoints
                                                                ? 'bg-gradient-to-r from-green-500 to-emerald-500 text-white hover:shadow-lg hover:from-green-600 hover:to-emerald-600 transform hover:scale-105'
                                                                : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                                                        }`}
                                                    >
                                                        <CheckCircle className="w-5 h-5" />
                                                        Approve Request
                                                    </button>
                                                    <button
                                                        onClick={() => handleRejectClick(request.id)}
                                                        className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-red-500 to-pink-500 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-red-600 hover:to-pink-600 transform hover:scale-105 transition-all"
                                                    >
                                                        <XCircle className="w-5 h-5" />
                                                        Reject Request
                                                    </button>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                );
                            })}

                            {filteredRequests.length === 0 && (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <Gift className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No Requests Found</h3>
                                    <p className="text-gray-500">No redemption requests match the selected filter.</p>
                                </div>
                            )}
                        </div>
                    </div>
                </main>

                {/* Reject Modal */}
                {showRejectModal && (
                    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                    <XCircle className="w-6 h-6 text-red-600" />
                                </div>
                                <h3 className="text-xl font-bold text-gray-900">Reject Redemption Request</h3>
                            </div>
                            <p className="text-gray-600 mb-4">
                                Please provide a reason for rejecting this redemption request:
                            </p>
                            <textarea
                                value={rejectReason}
                                onChange={(e) => setRejectReason(e.target.value)}
                                rows="4"
                                placeholder="Enter rejection reason..."
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none mb-6"
                            />
                            <div className="flex gap-3 justify-end">
                                <button
                                    onClick={cancelReject}
                                    className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={confirmReject}
                                    className="px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all font-medium"
                                >
                                    Confirm Rejection
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}