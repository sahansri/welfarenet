import React from 'react';
import { Calendar, CalendarDays, Plus, Edit2, Trash2, CheckSquare, Clock, MapPin,RefreshCcw ,Users,Tag,FileText,AlertCircle,Eye,Send,Image, Save,Check,X,AlertTriangle,Receipt} from 'lucide-react';
import { useState } from 'react'; 
import { useNavigate } from 'react-router-dom';
import { useQuery,useMutation,useQueryClient } from '@tanstack/react-query';
import axios from '../../config';

export default function Events() {
    const role = localStorage.getItem('role');
    const token = localStorage.getItem('token');
    const navigate = useNavigate();
    const queryClient = useQueryClient();


    const [showEditModel,setShowEditModel] = useState(false);
    const [showPreview,setShowPreview] = useState(false);
    const [showDeleteConfirmModel,setShowDeleteConfirmModel] = useState(false);
    const [eventToDelete, setEventToDelete] = useState(null);
    const [editingEvent,setEditingEvent] = useState({
        eventId:"",
        eventName: "",
        description: "",
        eventType:"",
        createdAt: "",
        date: "",
        time: "",
        venue: "",
        organizer: "",
        banner:"",
        donationAccepted:""
    });

    const fetchEvents = async ()=>{
        const response = await axios.get("/events/sorted-by-date");
        if(Array.isArray(response.data)){
            return response.data;
        }
        else{
            return [];
        }    
    }

    const {
        data:events=[],
        isLoading,
        isError,
        error,
        refetch
    } = useQuery({
        queryKey:["Events"],
        queryFn: fetchEvents,
        staleTime: 5*60*1000, //fetch after 5mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    });

    const deleteEventsMutation = useMutation({
        mutationFn:(id) =>
            axios.delete(`/events/${id}`,{
                headers:{
                    Authorization: `Bearer ${token}`,
                    "Content-Type": 'application/json'
                }
            }),
        onSuccess:()=>{
            queryClient.invalidateQueries(["Events"]);
            setShowDeleteConfirmModel(false);
            setEventToDelete(null);
        },
        onError:(error)=>{
            alert("Faild to delete Event",error);
        }
    });

    const editEventsMutation = useMutation({
        mutationFn:({id,data}) =>
            axios.put(`/events/update/${id}`,data,{
                headers:{
                    'Authorization':`bearer ${token}`,
                    'content-type' : 'application/json'
                }
            }),
        onSuccess:()=>{
            queryClient.invalidateQueries(["Events"]);
            setShowEditModel(false);
            setEditingEvent(null);
        },
        onError:(error)=>{
            alert("failed to Edit Event!",error);
        }
    });



    const eventTypes = [
        { value: 'community', label: 'Community Gathering', color: 'bg-purple-100 text-purple-700 border-purple-300' },
        { value: 'meeting', label: 'Official Meeting', color: 'bg-blue-100 text-blue-700 border-blue-300' },
        { value: 'maintenance', label: 'Maintenance Work', color: 'bg-orange-100 text-orange-700 border-orange-300' },
        { value: 'celebration', label: 'Celebration', color: 'bg-pink-100 text-pink-700 border-pink-300' },
        { value: 'sports', label: 'Sports & Recreation', color: 'bg-green-100 text-green-700 border-green-300' },
        { value: 'workshop', label: 'Workshop/Training', color: 'bg-indigo-100 text-indigo-700 border-indigo-300' }
    ];

    const handleCreateEvent = () => {
        if(role === 'president'|| role === 'admin'){
            navigate(`/${role}/events/create`)
        }
    };

    const handleEdit = (event) => {
        setEditingEvent(event);
        setShowEditModel(true);
    };

    const handleBannerUpload = () =>{
        alert("Banner upload clicked!");
    }

    const removeBanner = ()=>{
        alert("Remove Banner Clicked!");
    }

    {/*Event Deletion handling functions */}
    const handleDeleteClick = async (event) => {
        setEventToDelete(event);
        setShowDeleteConfirmModel(true);
    };

    const cancelDelete = ()=>{
        setShowDeleteConfirmModel(false);
    }

    const handleEventFinance = (id) => {
        console.log("Handling event finance for eventId: ",id);
        navigate(`/tresurer/event-budget/${id}`);
    }


    const handleAttendance = (id) => {
        navigate(`/president/events/${id}/attendance`);
    };
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
                Loading events...
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
                                            <CalendarDays className="w-8 h-8 text-purple-900" />
                                        </div>
                                        <div>
                                            <h1 className="text-4xl font-bold tracking-tight">Events</h1>
                                        </div>
                                    </div>
                                    <p className="text-purple-100 text-lg">Manage upcoming events in your community</p>
                                </div>
                                {(role === 'president' || role === 'admin')&&(
                                    <button
                                        onClick={handleCreateEvent}
                                        className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                                    >
                                        <Plus className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                        Create Event
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* Event List */}
                        <div className="space-y-6">
                            {events.length === 0 ? (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <CalendarDays className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No Events Yet</h3>
                                    <p className="text-gray-500 mb-6">Create your first event to keep your community informed</p>
                                    <button
                                        onClick={handleCreateEvent}
                                        className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-blue-700 transition-all shadow-md"
                                    >
                                        Create Event
                                    </button>
                                </div>
                            ) : (
                                events.map((event) => (
                                    <div
                                        key={event.eventId}
                                        className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transform hover:scale-[1.01] transition-all duration-300 overflow-hidden border border-gray-100"
                                    >
                                        {/* Colorful Top Border */}
                                        <div className="h-2 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500"></div>
                                        
                                        <div className="p-6 md:p-8">
                                            {/* Event Header */}
                                            <div className="mb-6">
                                                <div className="flex items-start justify-between gap-4 mb-4">
                                                    <div className="flex-1">
                                                        <div className="flex items-center gap-3 mb-3">
                                                            <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center shadow-lg">
                                                                <Calendar className="w-6 h-6 text-white" />
                                                            </div>
                                                            <div>
                                                                <h2 className="text-2xl font-bold text-gray-900 leading-tight">
                                                                    {event.eventName}
                                                                </h2>
                                                                <p className="text-sm text-gray-500 mt-1">Posted {event.createdAt}</p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Event Details Grid */}
                                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50 rounded-2xl p-5 border border-purple-100">
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                            <Calendar className="w-5 h-5 text-purple-600" />
                                                        </div>
                                                        <div>
                                                            <p className="text-xs text-gray-500 font-medium">Date</p>
                                                            <p className="text-sm font-semibold text-gray-900">{event.date}</p>
                                                        </div>
                                                    </div>
                                                    
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                            <Clock className="w-5 h-5 text-pink-600" />
                                                        </div>
                                                        <div>
                                                            <p className="text-xs text-gray-500 font-medium">Time</p>
                                                            <p className="text-sm font-semibold text-gray-900">{event.time}</p>
                                                        </div>
                                                    </div>
                                                    
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                            <MapPin className="w-5 h-5 text-blue-600" />
                                                        </div>
                                                        <div>
                                                            <p className="text-xs text-gray-500 font-medium">Venue</p>
                                                            <p className="text-sm font-semibold text-gray-900">{event.venue}</p>
                                                        </div>
                                                    </div>
                                                    
                                                    {event.donationAccepted ? (
                                                        <div className="flex items-center gap-3">
                                                            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                                <Check className="w-5 h-5 text-green-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Donations</p>
                                                                <p className="text-sm font-semibold text-gray-900">Accept Donations</p>
                                                            </div>
                                                        </div>
                                                        ):(
                                                            <div className="flex items-center gap-3">
                                                                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                                    <X className="w-5 h-5 text-red-600" />
                                                                </div>
                                                                <div>
                                                                    <p className="text-xs text-gray-500 font-medium">Donations</p>
                                                                    <p className="text-sm font-semibold text-gray-900">Do not accept Donetions</p>
                                                                </div>
                                                            </div>
                                                        )}
                                                </div>
                                            </div>

                                            {/* Event Description */}
                                            <div className="mb-6">
                                                <h3 className="text-sm font-semibold text-gray-700 mb-2 uppercase tracking-wide">Description</h3>
                                                <p className="text-gray-700 leading-relaxed bg-gray-50 rounded-xl p-4 border border-gray-100">
                                                    {event.description}
                                                </p>
                                            </div>

                                            {/* Organizer Badge */}
                                            {event.organizer &&(
                                                <div className="mb-6">
                                                    <div className="inline-flex items-center gap-2 bg-gradient-to-r from-purple-100 to-pink-100 px-4 py-2 rounded-full border border-purple-200">
                                                        <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-xs">
                                                            {event.organizer.charAt(0)}
                                                        </div>
                                                        <div>
                                                            <p className="text-xs text-gray-500">Organized by</p>
                                                            <p className="text-sm font-semibold text-gray-900">{event.organizer}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            )}

                                            {/* Action Buttons */}
                                            {(role === 'president' || role === 'admin') && (   
                                                <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
                                                    <button
                                                        onClick={() => handleAttendance(event.eventId)}
                                                        className="flex-1 flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:from-green-600 hover:to-emerald-700 transform hover:scale-105 transition-all duration-300"
                                                    >
                                                        <CheckSquare className="w-5 h-5" />
                                                        Manage Attendance
                                                    </button>
                                                    
                                                    <div className="flex gap-3">
                                                        <button
                                                            onClick={() => handleEdit(event)}
                                                            className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-blue-600 hover:to-blue-700 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Edit2 className="w-4 h-4" />
                                                            <span className="hidden sm:inline">Edit</span>
                                                        </button>
                                                        <button
                                                            onClick={() => handleDeleteClick(event)}
                                                            className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-red-600 hover:to-red-700 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Trash2 className="w-4 h-4" />
                                                            <span className="hidden sm:inline">Delete</span>
                                                        </button>
                                                    </div>
                                                </div>
                                            )}

                                            {role === 'tresurer'&&(
                                                    <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
                                                        <button
                                                            onClick={() => handleEventFinance(event.eventId)}
                                                            className="flex-1 flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:from-green-600 hover:to-emerald-700 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Receipt className="w-5 h-5" />
                                                            Handle Event Finance
                                                        </button>
                                                    </div>
                                            )}
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </main>
            </div>
           
            {/*Edit Events Model*/}
            {showEditModel && editingEvent && (
                <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-[999] p-4">
                    <div className="bg-white rounded-2xl shadow-xl overflow-auto max-h-[90vh] w-full max-w-6xl">
                        <div className="bg-white rounded-2xl shadow-xl overflow-hidden p-8">
                            <div className="p-8">
                                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                                    {/* Left Column - Main Details */}
                                    <div className="lg:col-span-2 space-y-6">
                                        {/* Event Title */}
                                        <div>
                                        <label className="block text-gray-700 font-semibold mb-2">
                                            Event Title *
                                        </label>
                                        <input
                                            type="text"
                                            value={editingEvent.eventName}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, eventName: e.target.value })}
                                            placeholder="e.g., Annual Community BBQ"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                        />
                                        </div>

                                        {/* Event Type */}
                                        <div>
                                        <label className="block text-gray-700 font-semibold mb-3 flex items-center gap-2">
                                            <Tag size={18} />
                                            Event Type
                                        </label>
                                        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                                            {eventTypes.map((type) => (
                                            <button
                                                key={type.value}
                                                onClick={() => setEditingEvent({ ...editingEvent, eventType: type.value })}
                                                className={`px-4 py-3 rounded-lg border-2 font-medium transition-all text-sm ${
                                                editingEvent.eventType === type.value
                                                    ? type.color + ' ring-2 ring-offset-2 ring-purple-500'
                                                    : 'bg-gray-50 text-gray-600 border-gray-200 hover:border-gray-300'
                                                }`}
                                            >
                                                {type.label}
                                            </button>
                                            ))}
                                        </div>
                                        </div>

                                        {/* Description */}
                                        <div>
                                        <label className="block text-gray-700 font-semibold mb-2 flex items-center gap-2">
                                            <FileText size={18} />
                                            Event Description
                                        </label>
                                        <textarea
                                            value={editingEvent.description}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, description: e.target.value })}
                                            placeholder="Describe your event, activities, and what attendees should expect..."
                                            rows="6"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition resize-none"
                                        />
                                        </div>

                                        {/* Date and Time */}
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            Start Date *
                                            </label>
                                            <input
                                            type="date"
                                            value={editingEvent.date}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, date: e.target.value })}
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            Start Time *
                                            </label>
                                            <input
                                            type="time"
                                            value={editingEvent.time}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, time: e.target.value })}
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            End Date
                                            </label>
                                            <input
                                            type="date"
                                            value={editingEvent.endDate}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, endDate: e.target.value })}
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            End Time
                                            </label>
                                            <input
                                            type="time"
                                            value={editingEvent.endTime}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, endTime: e.target.value })}
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                            />
                                        </div>
                                        </div>

                                        {/* Location */}
                                        <div>
                                        <label className="block text-gray-700 font-semibold mb-2 flex items-center gap-2">
                                            <MapPin size={18} />
                                            Location *
                                        </label>
                                        <input
                                            type="text"
                                            value={editingEvent.venue}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, venue: e.target.value })}
                                            placeholder="e.g., Community Hall, Pool Area, Garden"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                        />
                                        </div>

                                        {/* Event Banner */}
                                        <div>
                                        <label className="block text-gray-700 font-semibold mb-2 flex items-center gap-2">
                                            <Image size={18} />
                                            Event Banner (Optional)
                                        </label>
                                        {!editingEvent.banner ? (
                                            <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-purple-400 transition cursor-pointer">
                                            <input
                                                type="file"
                                                accept="image/*"
                                                onChange={handleBannerUpload}
                                                className="hidden"
                                                id="banner-upload"
                                            />
                                            <label htmlFor="banner-upload" className="cursor-pointer">
                                                <Image size={32} className="mx-auto text-gray-400 mb-2" />
                                                <p className="text-gray-600">Click to upload event banner</p>
                                                <p className="text-gray-400 text-sm mt-1">PNG, JPG or JPEG (Max 5MB)</p>
                                            </label>
                                            </div>
                                        ) : (
                                            <div className="relative bg-purple-50 rounded-lg p-4 flex items-center justify-between">
                                            <div className="flex items-center gap-3">
                                                <Image size={20} className="text-purple-600" />
                                                <span className="text-gray-700">{editingEvent.banner.name}</span>
                                            </div>
                                            <button
                                                onClick={removeBanner}
                                                className="text-red-500 hover:text-red-700 transition"
                                            >
                                                <X size={20} />
                                            </button>
                                            </div>
                                        )}
                                        </div>
                                    </div>

                                    {/* Right Column - Additional Details */}
                                    <div className="space-y-6">
                                        {/* Registration Settings */}
                                        <div className="bg-purple-50 rounded-xl p-6 space-y-4">
                                        <h3 className="font-semibold text-gray-900 text-lg mb-4">Donations</h3>
                                        
                                        <div className="flex items-center gap-3">
                                            <input
                                            type="checkbox"
                                            id="registration-required"
                                            checked={editingEvent.donationAccepted}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, donationAccepted: e.target.checked })}
                                            className="w-5 h-5 text-purple-600 rounded focus:ring-purple-500"
                                            />
                                            <label htmlFor="registration-required" className="text-gray-700 font-medium">
                                            Accept Donations
                                            </label>
                                        </div>
                                        </div>

                                        {/* Contact Information */}
                                        <div className="bg-blue-50 rounded-xl p-6 space-y-4">
                                        <h3 className="font-semibold text-gray-900 text-lg mb-4">Contact Info</h3>
                                        
                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            Organizer Name
                                            </label>
                                            <input
                                            type="text"
                                            value={editingEvent.organizer}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, organizer: e.target.value })}
                                            placeholder="Event organizer"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                                            />
                                        </div>

                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            Contact Email
                                            </label>
                                            <input
                                            type="email"
                                            value={editingEvent.contactEmail}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, contactEmail: e.target.value })}
                                            placeholder="email@example.com"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                                            />
                                        </div>

                                        <div>
                                            <label className="block text-gray-700 font-semibold mb-2">
                                            Contact Phone
                                            </label>
                                            <input
                                            type="tel"
                                            value={editingEvent.contactPhone}
                                            onChange={(e) => setEditingEvent({ ...editingEvent, contactPhone: e.target.value })}
                                            placeholder="+1 (555) 000-0000"
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                                            />
                                        </div>
                                        </div>

                                        {/* Info Box */}
                                        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 flex gap-3">
                                        <AlertCircle size={20} className="text-yellow-600 flex-shrink-0 mt-0.5" />
                                        <div className="text-sm text-yellow-800">
                                            <p className="font-semibold mb-1">Tip:</p>
                                            <p>Add an attractive banner and detailed description to increase event attendance!</p>
                                        </div>
                                        </div>
                                    </div>
                                    </div>
                                </div>

                                {/* Action Buttons */}
                                <div className="bg-gray-50 px-8 py-6 flex justify-between items-center border-t">
                                    <button
                                    onClick={() => setShowPreview(!showPreview)}
                                    className="flex items-center gap-2 px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition font-medium"
                                    >
                                    <Eye size={18} />
                                    Preview
                                    </button>
                                    <div className="flex gap-3">
                                        <button
                                            onClick={()=>{setShowEditModel(false)}}
                                            className="px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-red-600 hover:text-white transition font-medium"
                                        >
                                            Cancel
                                        </button>

                                        <button
                                            onClick={()=>{editEventsMutation.mutate({
                                                id:editingEvent.eventId,
                                                data:editingEvent
                                            })}}
                                            disabled={editEventsMutation.isPending}
                                            className="flex items-center gap-2 px-8 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium shadow-lg hover:shadow-xl"
                                        >
                                            <Save size={18} />
                                            {editEventsMutation.isPending?'Saving...':'Save Changes'}
                                        </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/*Delete Confirm Model*/}
            {showDeleteConfirmModel && (
                <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 animate-fadeIn">
                <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full transform animate-scaleIn">
                    {/* Modal Header */}
                    <div className="bg-gradient-to-r from-red-500 to-red-600 rounded-t-3xl p-6 relative">
                    <div className="flex items-center gap-4">
                        <div className="w-14 h-14 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center">
                        <AlertTriangle className="w-8 h-8 text-white" />
                        </div>
                        <div>
                        <h2 className="text-2xl font-bold text-white">Delete Event?</h2>
                        <p className="text-red-100 text-sm mt-1">This action cannot be undone</p>
                        </div>
                    </div>
                    
                    {/* Close button */}
                    <button
                        onClick={cancelDelete}
                        className="absolute top-4 right-4 w-10 h-10 bg-white/20 hover:bg-white/30 rounded-xl flex items-center justify-center transition-colors"
                        disabled={deleteEventsMutation.isPending}
                    >
                        <X className="w-5 h-5 text-white" />
                    </button>
                    </div>

                    {/* Modal Body */}
                    <div className="p-8">
                    <div className="bg-red-50 border-2 border-red-200 rounded-2xl p-6 mb-6">
                        <p className="text-gray-700 text-lg leading-relaxed">
                            Are you sure you want to delete{' '}
                            <span className="font-bold text-red-600">"{eventToDelete.eventName}"</span>?
                        </p>
                        <div className="mt-4 space-y-2">
                        <div className="flex items-start gap-2 text-sm text-gray-600">
                            <div className="w-1.5 h-1.5 bg-red-500 rounded-full mt-1.5 flex-shrink-0"></div>
                            <span>All event data will be permanently removed</span>
                        </div>
                        <div className="flex items-start gap-2 text-sm text-gray-600">
                            <div className="w-1.5 h-1.5 bg-red-500 rounded-full mt-1.5 flex-shrink-0"></div>
                            <span>Attendees will no longer see this event</span>
                        </div>
                        <div className="flex items-start gap-2 text-sm text-gray-600">
                            <div className="w-1.5 h-1.5 bg-red-500 rounded-full mt-1.5 flex-shrink-0"></div>
                            <span>This action cannot be reversed</span>
                        </div>
                        </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="flex gap-3">
                        <button
                        onClick={cancelDelete}
                        disabled={deleteEventsMutation.isPending}
                        className="flex-1 px-6 py-4 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                        Cancel
                        </button>
                        <button
                        onClick={()=>{
                            deleteEventsMutation.mutate(eventToDelete.eventId)
                        }}
                        disabled={deleteEventsMutation.isPending}
                        className="flex-1 px-6 py-4 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl font-semibold hover:from-red-600 hover:to-red-700 transition-all shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-2"
                        >
                        {deleteEventsMutation.isPending ? (
                            <>
                            <div className="w-5 h-5 border-3 border-white border-t-transparent rounded-full animate-spin"></div>
                            Deleting...
                            </>
                        ) : (
                            <>
                            <Trash2 className="w-5 h-5" />
                            Delete Event
                            </>
                        )}
                        </button>
                    </div>
                    </div>
                </div>
                </div>
            )}


        </div>
    );   
}