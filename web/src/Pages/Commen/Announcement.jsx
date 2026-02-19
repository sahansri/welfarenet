import { useState,useEffect } from 'react';
import { Plus, Edit2, Trash2, Megaphone, Calendar, AlertCircle, CheckCircle, User, Paperclip ,Eye,Send,Image,Save} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import axios from '../../config'
import { useQuery } from '@tanstack/react-query';

export default function Announcements() {
    const role = localStorage.getItem('role');
    const havePrivilege = (role === 'PRESIDENT' || role === 'ADMIN' || role==='TREASURER');
    console.log("User role:", role, "Have Privilege:", havePrivilege);

    const navigate = useNavigate();

     
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [showPreview,setShowPreview] = useState(false);
    const [showEditModel, setShowEditModel] = useState(false);
    const [editingAnnouncement,setEditingAnnouncement] = useState({
        title: '',
        content: '',
        priority: '',
        expiryDate: '',
        attachments: []
    });
    const [deleteId, setDeleteId] = useState(null);
        
    const fetchAnnouncements = async ()=>{
            const token = localStorage.getItem('token');
            try{
                const response = await axios.get('/announcements/getall',{
                    headers:{
                        Authorization: `Bearer ${token}`,
                        contentType: 'application/json'
                    }
                })
                console.log("Fetched announcements:", response.data);
                
                return response.data;
            }
            catch(error){
                console.error("Error fetching announcements:", error);
                return [];
            }
            
    }

    const{
        data:announcements=[],
        isLoading,
        isError,
        error
    } = useQuery({
        queryKey:["Announcements"],
        queryFn:fetchAnnouncements,
        staleTime: 5*60*1000, //fetch after 5mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    })


    const priorities = [
    { value: 'LOW', label: 'Low', color: 'bg-blue-100 text-blue-700 border-green-300' },
    { value: 'MEDIUM', label: 'Medium', color: 'bg-gray-100 text-gray-700 border-blue-300' },
    { value: 'HIGH', label: 'High', color: 'bg-orange-100 text-orange-700 border-orange-300' },
    { value: 'URGENT', label: 'Urgent', color: 'bg-red-100 text-red-700 border-red-300' }
  ];

    const handleCreateAnnouncement = () => {
        if(havePrivilege){
            navigate(`/${role.toLocaleLowerCase()}/announcements/create`);
        }
    };

    const handleEdit = (announcement) => {
        setShowEditModel(true);
        setEditingAnnouncement(announcement);
    };

    const handleEditSubmit = async () =>{
        console.log("Hamdle Edit submit clicked!")
        try{
            const token = localStorage.getItem('token');
            const response = await axios.put(`/announcements/update/${editingAnnouncement.announcementId}`,editingAnnouncement,{
                headers:{
                    "Authorization": `Bearer ${token}`,
                    "contentType": 'application/json'
                }
            });
            console.log("Update response:", response.data);
            if(response.status === 200){
                setAnnouncements(announcements.map(ann => ann.announcement_id === editingAnnouncement.announcementId ? editingAnnouncement : ann));
                alert("Announcement updated successfully!");
                setShowEditModel(false);
                setEditingAnnouncement(null);

            }
        }
        catch(error){
            console.error("Error updating announcement:", error);
        }
    }

    const handleSubmit = ()=>{
        alert("Clicked Submit!");
    }


    const handleDeleteClick = (id) => {
        setDeleteId(id);
        setShowDeleteModal(true);
    };

    const confirmDelete = async () => {
        try{
            const token = localStorage.getItem('token');
            const response = await axios.delete(`/announcements/delete/${deleteId}`,{
                headers:{
                    Authorization: `Bearer ${token}`,
                    contentType: 'application/json'
                }
            });
            console.log("Delete response:", response.data);
            if(response.status === 200){
                setAnnouncements(announcements.filter(ann => ann.announcementId !== deleteId));
            }
        }
        catch(error){
            console.error("Error deleting announcement:", error);
        }
        finally{
            setShowDeleteModal(false);
            setDeleteId(null);
        }
    };

    const cancelDelete = () => {
        setShowDeleteModal(false);
        setDeleteId(null);
    };

    const handleFileUpload = (e) => {
    const files = Array.from(e.target.files);
    setEditingAnnouncement({
      ...editingAnnouncement,
      attachments: [...editingAnnouncement.attachments, ...files]
    });
  };


    const getPriorityStyles = (priority) => {
        switch(priority) {
            case 'HIGH':
                return {
                    badge: 'bg-red-100 text-red-700 border-red-200',
                    gradient: 'from-red-500 via-pink-500 to-orange-500',
                    icon: <AlertCircle className="w-5 h-5 text-red-500" />
                };
            case 'MEDIUM':
                return {
                    badge: 'bg-yellow-100 text-yellow-700 border-yellow-200',
                    gradient: 'from-yellow-500 via-orange-500 to-amber-500',
                    icon: <AlertCircle className="w-5 h-5 text-yellow-500" />
                };
            case 'LOW':
                return {
                    badge: 'bg-green-100 text-green-700 border-green-200',
                    gradient: 'from-green-500 via-emerald-500 to-teal-500',
                    icon: <CheckCircle className="w-5 h-5 text-green-500" />
                };
            default:
                return {
                    badge: 'bg-gray-100 text-gray-700 border-gray-200',
                    gradient: 'from-gray-500 via-slate-500 to-gray-600',
                    icon: <AlertCircle className="w-5 h-5 text-gray-500" />
                };
        }
    };
    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Announcements are Loading...
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
                            <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
                            
                            <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                                <div>
                                    <div className="flex items-center gap-4 mb-3">
                                        <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                            <Megaphone className="w-8 h-8 text-purple-900" />
                                        </div>
                                        <div>
                                            <h1 className="text-4xl font-bold tracking-tight">Announcements</h1>
                                        </div>
                                    </div>
                                    <p className="text-purple-100 text-lg">Inform your community with announcements</p>
                                </div>
                                {havePrivilege &&(
                                    <button
                                        onClick={handleCreateAnnouncement}
                                        className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                                    >
                                        <Plus className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                        Create Announcement
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* Announcements List */}
                        <div className="space-y-6">
                            {announcements.length === 0 ? (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <Megaphone className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No Announcements Yet</h3>
                                    {havePrivilege &&(
                                        <div>
                                            <p className="text-gray-500 mb-6">Create your first announcement to keep your community informed</p>
                                            <button
                                                onClick={handleCreateAnnouncement}
                                                className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-blue-700 transition-all shadow-md"
                                            >
                                                Create Announcement
                                            </button>
                                        </div>
                                    )}   
                                </div>
                            ) : (
                                announcements.map((announcement) => {
                                    const priorityStyles = getPriorityStyles(announcement.priority);
                                    return (
                                        <div 
                                            key={announcement.announcementId} 
                                            className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transform hover:scale-[1.01] transition-all duration-300 overflow-hidden border border-gray-100"
                                        >
                                            {/* Colorful Top Border */}
                                            <div className={`h-2 bg-gradient-to-r ${priorityStyles.gradient}`}></div>
                                            
                                            <div className="p-6 md:p-8">
                                                {/* Announcement Header */}
                                                <div className="mb-6">
                                                    <div className="flex items-start justify-between gap-4 mb-4">
                                                        <div className="flex-1">
                                                            <div className="flex items-center gap-3 mb-3">
                                                                <div className={`w-12 h-12 bg-gradient-to-br ${priorityStyles.gradient} rounded-2xl flex items-center justify-center shadow-lg`}>
                                                                    <Megaphone className="w-6 h-6 text-white" />
                                                                </div>
                                                                <div>
                                                                    <h2 className="text-2xl font-bold text-gray-900 leading-tight">
                                                                        {announcement.title}
                                                                    </h2>
                                                                    <p className="text-sm text-gray-500 mt-1">Posted on {announcement.createdDate.split('T')[0]}</p>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${priorityStyles.badge} whitespace-nowrap`}>
                                                            {announcement.priority.toUpperCase()}
                                                        </span>
                                                    </div>

                                                    {/* Announcement Details */}
                                                    <div className="flex flex-wrap items-center gap-4 bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 rounded-2xl p-4 border border-purple-100">
                                                        <div className="flex items-center gap-2">
                                                            {/*
                                                            <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center shadow-sm">
                                                                <Calendar className="w-4 h-4 text-purple-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Date</p>
                                                                <p className="text-sm font-semibold text-gray-900">{announcement.date}</p>
                                                            </div>
                                                            */}
                                                        </div>
                                                        
                                                        <div className="flex items-center gap-2">
                                                            <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center shadow-sm">
                                                                <User className="w-4 h-4 text-blue-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Author</p>
                                                                <p className="text-sm font-semibold text-gray-900">{announcement.postedBy.fullName}</p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Announcement Content */}
                                                <div className="mb-6">
                                                    <h3 className="text-sm font-semibold text-gray-700 mb-2 uppercase tracking-wide">Message</h3>
                                                    <p className="text-gray-700 leading-relaxed bg-gray-50 rounded-xl p-4 border border-gray-100">
                                                        {announcement.description}
                                                    </p>
                                                </div>

                                                {/* Action Buttons */}
                                                {havePrivilege &&(
                                                    <div className="flex flex-wrap gap-3 pt-6 border-t border-gray-200">
                                                        <button
                                                            onClick={() => handleEdit(announcement)}
                                                            className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-blue-600 hover:to-blue-700 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Edit2 className="w-4 h-4" />
                                                            <span>Edit</span>
                                                        </button>
                                                        <button
                                                            onClick={() => handleDeleteClick(announcement.announcementId)}
                                                            className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-red-600 hover:to-red-700 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Trash2 className="w-4 h-4" />
                                                            <span>Delete</span>
                                                        </button>
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    );
                                })
                            )}
                        </div>
                    </div>
                </main>

                {/* Delete Confirmation Modal */}
                {showDeleteModal && (
                    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                    <Trash2 className="w-6 h-6 text-red-600" />
                                </div>
                                <h3 className="text-xl font-bold text-gray-900">Delete Announcement</h3>
                            </div>
                            <p className="text-gray-600 mb-6">
                                Are you sure you want to delete this announcement? This action cannot be undone.
                            </p>
                            <div className="flex gap-3 justify-end">
                                <button
                                    onClick={cancelDelete}
                                    className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={confirmDelete}
                                    className="px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all font-medium"
                                >
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/*Handle Editing Model*/}
                {showEditModel && editingAnnouncement &&(
                    <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-[999] p-4">
                        <div className="bg-white rounded-2xl shadow-xl overflow-auto max-h-[90vh] w-full max-w-5xl">
                            <div className="bg-white rounded-2xl shadow-xl overflow-hidden p-6">
                                <form onSubmit={()=>{handleEditSubmit}}>
                                    <div className="p-8 space-y-6">
                                    {/* Title Input */}
                                    <div>
                                        <label className="block text-gray-700 font-semibold mb-2">
                                        Announcement Title *
                                        </label>
                                        <input
                                        type="text"
                                        required
                                        value={editingAnnouncement.title}
                                        onChange={(e) => setEditingAnnouncement({ ...editingAnnouncement, title: e.target.value })}
                                        placeholder="Enter announcement title..."
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                        />
                                    </div>

                                    {/* Content Textarea */}
                                    <div>
                                        <label className="block text-gray-700 font-semibold mb-2">
                                        Content *
                                        </label>
                                        <textarea
                                        required
                                        value={editingAnnouncement.description}
                                        onChange={(e) => setEditingAnnouncement({ ...editingAnnouncement, description: e.target.value })}
                                        placeholder="Write your announcement details here..."
                                        rows="8"
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition resize-none"
                                        />
                                    </div>

                                    {/* Priority Selection */}
                                    <div>
                                        <label className="block text-gray-700 font-semibold mb-3">
                                        Priority Level
                                        </label>
                                        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                                        {priorities.map((priority) => (
                                            <button
                                            key={priority.value}
                                            type="button"
                                            onClick={() => setEditingAnnouncement({ ...editingAnnouncement, priority: priority.value })}
                                            className={`px-4 py-3 rounded-lg border-2 font-medium transition-all ${
                                                editingAnnouncement.priority === priority.value
                                                ? priority.color + ' ring-2 ring-offset-2 ring-purple-500'
                                                : 'bg-gray-50 text-gray-600 border-gray-200 hover:border-gray-300'
                                            }`}
                                            >
                                            {priority.label}
                                            </button>
                                        ))}
                                        </div>
                                    </div>

                                    {/* Expiry Date */}
                                    <div>
                                        <label className="block text-gray-700 font-semibold mb-2 flex items-center gap-2">
                                        <Calendar size={18} />
                                        Expiry Date (Optional)
                                        </label>
                                        <input
                                        type="date"
                                        value={editingAnnouncement.expiryDate.split('T')[0]}
                                        onChange={(e) => setEditingAnnouncement({ ...editingAnnouncement, expiryDate: e.target.value })}
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                        />
                                        <p className="text-gray-500 text-sm mt-1">Announcement will be automatically removed after this date</p>
                                    </div>


                                    {/* Info Box */}
                                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 flex gap-3">
                                        <AlertCircle size={20} className="text-blue-600 flex-shrink-0 mt-0.5" />
                                        <div className="text-sm text-blue-800">
                                        <p className="font-semibold mb-1">Before Publishing:</p>
                                        <p>Make sure your announcement is clear and provides all necessary information. You can preview it before publishing.</p>
                                        </div>
                                    </div>
                                    </div>

                                    {/* Action Buttons */}
                                    <div className="bg-gray-50 px-8 py-6 flex justify-between items-center border-t">
                                    <button
                                        type="button"
                                        onClick={() => setShowPreview(!showPreview)}
                                        className="flex items-center gap-2 px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition font-medium"
                                    >
                                        <Eye size={18} />
                                        Preview
                                    </button>
                                    <div className="flex gap-3">
                                        <button
                                            type="button"
                                            className="px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-red-700 hover:text-white transition font-medium"
                                            onClick={()=>setShowEditModel(false)}
                                        >
                                        Cancel
                                        </button>
                                        <button
                                            type="button"
                                            className="flex items-center gap-2 px-8 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium shadow-lg hover:shadow-xl"
                                            onClick ={()=>handleEditSubmit()}
                                        >
                                        <Save size={18} />
                                        Save Changes
                                        </button>
                                    </div>
                                    </div>
                                </form>
                            </div>
                        </div>   
                    </div>    
                )}
            </div>
        </div>
    );
}