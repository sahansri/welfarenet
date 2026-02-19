import { useState } from 'react';
import { ArrowLeft, Flag, Eye, Trash2, CheckCircle, XCircle, AlertTriangle, User, Calendar, MessageSquare } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function ManageReportedPosts() {
    const navigate = useNavigate();
    const [reportedPosts, setReportedPosts] = useState([
        {
            id: 1,
            postId: 2,
            author: "Mike Chen",
            avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Mike",
            timestamp: "5 hours ago",
            content: "Check out this amazing street performance downtown!",
            media: {
                type: "video",
                url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            },
            likes: 42,
            comments: 8,
            reports: [
                {
                    id: 1,
                    reportedBy: "Sarah Johnson",
                    reportedByEmail: "sarah.j@email.com",
                    reason: "Inappropriate Content",
                    details: "This content is not suitable for our community.",
                    reportDate: "2025-01-15"
                },
                {
                    id: 2,
                    reportedBy: "David Brown",
                    reportedByEmail: "david.b@email.com",
                    reason: "Spam",
                    details: "This looks like promotional spam.",
                    reportDate: "2025-01-15"
                }
            ],
            status: "pending"
        },
        {
            id: 2,
            postId: 5,
            author: "John Doe",
            avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=John",
            timestamp: "1 day ago",
            content: "This is a controversial political statement that might offend some members.",
            media: null,
            likes: 15,
            comments: 23,
            reports: [
                {
                    id: 3,
                    reportedBy: "Emma Wilson",
                    reportedByEmail: "emma.w@email.com",
                    reason: "Hate Speech",
                    details: "Contains offensive political content.",
                    reportDate: "2025-01-14"
                }
            ],
            status: "pending"
        },
        {
            id: 3,
            postId: 7,
            author: "Jane Smith",
            avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Jane",
            timestamp: "3 days ago",
            content: "Buy my products now! Limited time offer!",
            media: {
                type: "image",
                url: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80"
            },
            likes: 8,
            comments: 2,
            reports: [
                {
                    id: 4,
                    reportedBy: "Lisa Anderson",
                    reportedByEmail: "lisa.a@email.com",
                    reason: "Spam",
                    details: "Advertising products, not community related.",
                    reportDate: "2025-01-12"
                },
                {
                    id: 5,
                    reportedBy: "Mike Chen",
                    reportedByEmail: "mike.chen@email.com",
                    reason: "Spam",
                    details: "Commercial spam post.",
                    reportDate: "2025-01-12"
                }
            ],
            status: "reviewed",
            reviewedDate: "2025-01-13",
            action: "removed"
        }
    ]);

    const [filterStatus, setFilterStatus] = useState('all');
    const [selectedPost, setSelectedPost] = useState(null);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [showDismissModal, setShowDismissModal] = useState(false);
    const [actionReason, setActionReason] = useState('');

    const handleBack = () => {
        navigate('/president/feed');
    };

    const handleViewPost = (postId) => {
        alert(`View full post: /admin/newsfeed/post/${postId}`);
    };

    const handleRemovePost = (reportId) => {
        setSelectedPost(reportId);
        setShowDeleteModal(true);
    };

    const confirmRemovePost = () => {
        if (!actionReason.trim()) {
            alert('Please provide a reason for removing the post');
            return;
        }

        setReportedPosts(prev => prev.map(post =>
            post.id === selectedPost
                ? {
                    ...post,
                    status: 'reviewed',
                    reviewedDate: new Date().toISOString().split('T')[0],
                    action: 'removed',
                    actionReason: actionReason
                }
                : post
        ));

        setShowDeleteModal(false);
        setActionReason('');
        setSelectedPost(null);
        alert('Post removed successfully. User will be notified.');
    };

    const handleDismissReports = (reportId) => {
        setSelectedPost(reportId);
        setShowDismissModal(true);
    };

    const confirmDismissReports = () => {
        if (!actionReason.trim()) {
            alert('Please provide a reason for dismissing the reports');
            return;
        }

        setReportedPosts(prev => prev.map(post =>
            post.id === selectedPost
                ? {
                    ...post,
                    status: 'reviewed',
                    reviewedDate: new Date().toISOString().split('T')[0],
                    action: 'dismissed',
                    actionReason: actionReason
                }
                : post
        ));

        setShowDismissModal(false);
        setActionReason('');
        setSelectedPost(null);
        alert('Reports dismissed. Post remains visible.');
    };

    const cancelAction = () => {
        setShowDeleteModal(false);
        setShowDismissModal(false);
        setActionReason('');
        setSelectedPost(null);
    };

    const filteredPosts = reportedPosts.filter(post =>
        filterStatus === 'all' || post.status === filterStatus
    );

    const pendingCount = reportedPosts.filter(p => p.status === 'pending').length;
    const reviewedCount = reportedPosts.filter(p => p.status === 'reviewed').length;

    const getReasonColor = (reason) => {
        const colors = {
            'Spam': 'bg-orange-100 text-orange-700 border-orange-200',
            'Inappropriate Content': 'bg-red-100 text-red-700 border-red-200',
            'Hate Speech': 'bg-purple-100 text-purple-700 border-purple-200',
            'Harassment': 'bg-pink-100 text-pink-700 border-pink-200',
            'False Information': 'bg-yellow-100 text-yellow-700 border-yellow-200'
        };
        return colors[reason] || 'bg-gray-100 text-gray-700 border-gray-200';
    };

    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-5xl mx-auto p-4">

                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            
                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-3">
                                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                        <Flag className="w-8 h-8 text-red-500" />
                                    </div>
                                    <div>
                                        <h1 className="text-4xl font-bold tracking-tight">Reported Posts</h1>
                                    </div>
                                </div>
                                <p className="text-purple-100 text-lg">Review and manage community-reported content</p>
                            </div>
                        </div>

                        {/* Stats Cards */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Total Reported</p>
                                        <p className="text-3xl font-bold text-gray-900">{reportedPosts.length}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-red-500 rounded-xl flex items-center justify-center">
                                        <Flag className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Pending Review</p>
                                        <p className="text-3xl font-bold text-orange-600">{pendingCount}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center">
                                        <AlertTriangle className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Reviewed</p>
                                        <p className="text-3xl font-bold text-green-600">{reviewedCount}</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                                        <CheckCircle className="w-6 h-6 text-white" />
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
                                    All ({reportedPosts.length})
                                </button>
                                <button
                                    onClick={() => setFilterStatus('pending')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'pending'
                                            ? 'bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    Pending ({pendingCount})
                                </button>
                                <button
                                    onClick={() => setFilterStatus('reviewed')}
                                    className={`px-5 py-2.5 rounded-xl font-medium transition-all ${
                                        filterStatus === 'reviewed'
                                            ? 'bg-gradient-to-r from-green-500 to-emerald-500 text-white shadow-md'
                                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                    }`}
                                >
                                    Reviewed ({reviewedCount})
                                </button>
                            </div>
                        </div>

                        {/* Reported Posts List */}
                        <div className="space-y-6">
                            {filteredPosts.map((post) => (
                                <div
                                    key={post.id}
                                    className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-300 overflow-hidden border border-gray-100"
                                >
                                    {/* Colorful Top Border */}
                                    <div className={`h-2 ${
                                        post.status === 'pending' 
                                            ? 'bg-gradient-to-r from-orange-500 via-red-500 to-pink-500'
                                            : post.action === 'removed'
                                            ? 'bg-gradient-to-r from-red-500 via-red-600 to-red-700'
                                            : 'bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500'
                                    }`}></div>
                                    
                                    <div className="p-6 md:p-8">
                                        {/* Status Badge */}
                                        <div className="flex items-center justify-between mb-6">
                                            <div className="flex items-center gap-3">
                                                <div className="w-12 h-12 bg-gradient-to-br from-red-500 to-pink-500 rounded-xl flex items-center justify-center">
                                                    <Flag className="w-6 h-6 text-white" />
                                                </div>
                                                <div>
                                                    <p className="text-sm text-gray-500">Report ID</p>
                                                    <p className="font-bold text-gray-900">#{post.id}</p>
                                                </div>
                                            </div>
                                            {post.status === 'reviewed' && (
                                                <span className={`px-4 py-2 rounded-full text-sm font-semibold border flex items-center gap-2 ${
                                                    post.action === 'removed'
                                                        ? 'bg-red-100 text-red-700 border-red-200'
                                                        : 'bg-green-100 text-green-700 border-green-200'
                                                }`}>
                                                    {post.action === 'removed' ? <Trash2 className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}
                                                    {post.action === 'removed' ? 'POST REMOVED' : 'REPORTS DISMISSED'}
                                                </span>
                                            )}
                                        </div>

                                        {/* Post Content */}
                                        <div className="bg-gray-50 rounded-2xl p-6 mb-6 border border-gray-200">
                                            <div className="flex items-center gap-3 mb-4">
                                                <img
                                                    src={post.avatar}
                                                    className="w-12 h-12 rounded-full border-2 border-purple-200"
                                                    alt={post.author}
                                                />
                                                <div>
                                                    <h3 className="text-gray-900 font-semibold">{post.author}</h3>
                                                    <p className="text-gray-500 text-sm">{post.timestamp}</p>
                                                </div>
                                            </div>
                                            <p className="text-gray-800 leading-relaxed mb-4">{post.content}</p>
                                            
                                            {post.media && (
                                                <div className="rounded-xl overflow-hidden border border-gray-200">
                                                    {post.media.type === 'image' ? (
                                                        <img src={post.media.url} alt="Post media" className="w-full h-48 object-cover" />
                                                    ) : (
                                                        <video src={post.media.url} className="w-full h-48" controls />
                                                    )}
                                                </div>
                                            )}

                                            <div className="flex items-center gap-4 mt-4 text-sm text-gray-600">
                                                <span>{post.likes} likes</span>
                                                <span>•</span>
                                                <span>{post.comments} comments</span>
                                            </div>
                                        </div>

                                        {/* Reports Section */}
                                        <div className="mb-6">
                                            <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                                                <AlertTriangle className="w-5 h-5 text-orange-600" />
                                                Reports ({post.reports.length})
                                            </h3>
                                            
                                            <div className="space-y-3">
                                                {post.reports.map((report) => (
                                                    <div key={report.id} className="bg-gradient-to-br from-orange-50 to-red-50 rounded-xl p-4 border border-orange-200">
                                                        <div className="flex items-start justify-between mb-2">
                                                            <div>
                                                                <div className="flex items-center gap-2 mb-1">
                                                                    <User className="w-4 h-4 text-gray-600" />
                                                                    <p className="font-semibold text-gray-900">{report.reportedBy}</p>
                                                                </div>
                                                                <p className="text-sm text-gray-600">{report.reportedByEmail}</p>
                                                            </div>
                                                            <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getReasonColor(report.reason)}`}>
                                                                {report.reason}
                                                            </span>
                                                        </div>
                                                        <p className="text-sm text-gray-700 mt-2">{report.details}</p>
                                                        <p className="text-xs text-gray-500 mt-2 flex items-center gap-1">
                                                            <Calendar className="w-3 h-3" />
                                                            Reported on {report.reportDate}
                                                        </p>
                                                    </div>
                                                ))}
                                            </div>
                                        </div>

                                        {/* Review Info */}
                                        {post.status === 'reviewed' && (
                                            <div className="bg-blue-50 rounded-xl p-4 mb-6 border border-blue-200">
                                                <p className="text-sm text-blue-900 mb-1">
                                                    <span className="font-semibold">Reviewed on:</span> {post.reviewedDate}
                                                </p>
                                                {post.actionReason && (
                                                    <p className="text-sm text-blue-900">
                                                        <span className="font-semibold">Reason:</span> {post.actionReason}
                                                    </p>
                                                )}
                                            </div>
                                        )}

                                        {/* Action Buttons */}
                                        {post.status === 'pending' && (
                                            <div className="flex flex-wrap gap-3 pt-6 border-t border-gray-200">
                                                <button
                                                    onClick={() => handleViewPost(post.postId)}
                                                    className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-blue-600 hover:to-cyan-600 transform hover:scale-105 transition-all"
                                                >
                                                    <Eye className="w-5 h-5" />
                                                    View Full Post
                                                </button>
                                                <button
                                                    onClick={() => handleDismissReports(post.id)}
                                                    className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-green-600 hover:to-emerald-600 transform hover:scale-105 transition-all"
                                                >
                                                    <CheckCircle className="w-5 h-5" />
                                                    Dismiss Reports
                                                </button>
                                                <button
                                                    onClick={() => handleRemovePost(post.id)}
                                                    className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-red-500 to-pink-500 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-red-600 hover:to-pink-600 transform hover:scale-105 transition-all"
                                                >
                                                    <Trash2 className="w-5 h-5" />
                                                    Remove Post
                                                </button>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            ))}

                            {filteredPosts.length === 0 && (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <Flag className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No Reports Found</h3>
                                    <p className="text-gray-500">No posts match the selected filter.</p>
                                </div>
                            )}
                        </div>
                    </div>
                </main>

                {/* Remove Post Modal */}
                {showDeleteModal && (
                    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                    <Trash2 className="w-6 h-6 text-red-600" />
                                </div>
                                <h3 className="text-xl font-bold text-gray-900">Remove Post</h3>
                            </div>
                            <p className="text-gray-600 mb-4">
                                This will permanently remove the post from the community feed. Please provide a reason:
                            </p>
                            <textarea
                                value={actionReason}
                                onChange={(e) => setActionReason(e.target.value)}
                                rows="4"
                                placeholder="Reason for removing post..."
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent resize-none mb-6"
                            />
                            <div className="flex gap-3 justify-end">
                                <button
                                    onClick={cancelAction}
                                    className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={confirmRemovePost}
                                    className="px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all font-medium"
                                >
                                    Remove Post
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/* Dismiss Reports Modal */}
                {showDismissModal && (
                    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                                    <CheckCircle className="w-6 h-6 text-green-600" />
                                </div>
                                <h3 className="text-xl font-bold text-gray-900">Dismiss Reports</h3>
                            </div>
                            <p className="text-gray-600 mb-4">
                                The post will remain visible. Please provide a reason for dismissing the reports:
                            </p>
                            <textarea
                                value={actionReason}
                                onChange={(e) => setActionReason(e.target.value)}
                                rows="4"
                                placeholder="Reason for dismissing reports..."
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-transparent resize-none mb-6"
                            />
                            <div className="flex gap-3 justify-end">
                                <button
                                    onClick={cancelAction}
                                    className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={confirmDismissReports}
                                    className="px-5 py-2.5 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-all font-medium"
                                >
                                    Dismiss Reports
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}