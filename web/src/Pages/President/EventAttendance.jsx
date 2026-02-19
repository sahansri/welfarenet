import { useState,useEffect } from 'react';
import { ArrowLeft, QrCode, Download, Users, CheckCircle, Mail, Phone, Calendar, Clock, MapPin, Search, Trash2 } from 'lucide-react';
import { useNavigate,useParams } from 'react-router-dom';
import axios from '../../config';
import qr_404 from '../../assets/NotFound.jpg';
import qr_403 from '../../assets/acessDenied.jpg'


export default function EventAttendance() {
    const { id } = useParams();
    const navigate = useNavigate();
    const [eventData, setEventData] = useState({});
    const [isLoading, setIsLoading] = useState(false);
    
    const [attendees, setAttendees] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [qrCodeUrl, setQrCodeUrl] = useState(null);
    const [qrStatus, setQrStatus] = useState(null);

    const handleBack = () => {
        navigate('/president/events')
    };

    const fetchQrCode = async ()=>{
        setIsLoading(true);
        const token = localStorage.getItem('token');
        try{
            const response = await axios.get(`/qr/${id}`,{
                headers:{
                    'Authorization':`Bearer ${token}`,
                    'Content-Type':'application/json'
                }
            });
            if(response.status === 200){
                setQrCodeUrl(response.data.qrCodeUrl);
                setQrStatus(200);
            }
            else if(response.status ===403){
                setQrCodeUrl(null);
                setQrStatus(403);;
            }
            else{
                setQrCodeUrl(null);
                setQrStatus(null);
            }
        }
        catch (error){
            console.log("Error fetching QR code: ", error);
            setQrCodeUrl(null);
            setQrStatus(404);
        }
        finally{
            setIsLoading(false);
        }
    }

    useEffect(()=>{
        setIsLoading(true);
        const fetchEventData = async () => {
            const token = localStorage.getItem('token'); 
            try{
                const response = await axios.get(`/events/${id}`,{
                    headers:{
                        'Authorization':`Bearer ${token}`,
                        'Content-Type':'application/json'
                    }
                })
                console.log("Event Data: ", response.data);
                setEventData(response.data);
                fetchQrCode();

            }
            catch (error){
                console.log("Error fetching event data: ", error);
            }
            finally{    
                setIsLoading(false);
            }
        };
        fetchEventData();
        
    },[]);

    const handleDownloadQR = () => {
        // In real implementation, this would download the QR code
        const link = document.createElement('a');
        link.href = eventData.qrCodeUrl;
        link.download = `event_${eventData.id}_qr_code.png`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        alert('QR Code downloaded!');
    };

    const handleExportAttendees = () => {
        alert('Export attendees list as CSV/Excel');
    };

    const handleRemoveAttendee = (attendeeId) => {
        if (confirm('Are you sure you want to remove this attendee from the list?')) {
            setAttendees(attendees.filter(a => a.id !== attendeeId));
        }
    };

    // Filter and search logic
    const filteredAttendees = attendees.filter(attendee => {
        return attendee.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
               attendee.email.toLowerCase().includes(searchTerm.toLowerCase());
    });
    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                    Loading...
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
                        {/* Back Button */}
                        <button
                            onClick={handleBack}
                            className="mb-6 flex items-center gap-2 text-white hover:text-purple-200 transition-colors"
                        >
                            <ArrowLeft className="w-5 h-5" />
                            <span className="font-medium">Back to Events</span>
                        </button>

                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] duration-300">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            
                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-4">
                                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                        <Users className="w-8 h-8 text-purple-900" />
                                    </div>
                                    <div>
                                        <h1 className="text-4xl font-bold tracking-tight">{eventData.eventName}</h1>
                                        <p className="text-purple-100 text-lg mt-2">Attendance Management</p>
                                    </div>
                                </div>

                                {/* Event Info */}
                                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-6">
                                    <div className=" bg-white/20 backdrop-blur-sm rounded-xl p-4">
                                        <div className="flex items-center gap-2 text-purple-200 mb-1">
                                            <Calendar className="w-4 h-4" />
                                            <span className="text-sm">Date</span>
                                        </div>
                                        <p className="text-white font-semibold">{eventData.date}</p>
                                    </div>
                                    <div className="bg-white/20 backdrop-blur-sm rounded-xl p-4">
                                        <div className="flex items-center gap-2 text-purple-200 mb-1">
                                            <Clock className="w-4 h-4" />
                                            <span className="text-sm">Time</span>
                                        </div>
                                        <p className="text-white font-semibold">{eventData.time}</p>
                                    </div>
                                    <div className="bg-white/20 backdrop-blur-sm rounded-xl p-4">
                                        <div className="flex items-center gap-2 text-purple-200 mb-1">
                                            <MapPin className="w-4 h-4" />
                                            <span className="text-sm">Venue</span>
                                        </div>
                                        <p className="text-white font-semibold">{eventData.venue}</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Stats Cards */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                            <div className="bg-white/90 rounded-2xl shadow-4x1 p-6 border border-gray-100 transform hover:scale-[1.02] duration-300">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Total Attendees</p>
                                        <p className="text-3xl font-bold text-gray-900">{attendees.length}</p>
                                        <p className="text-xs text-gray-500 mt-1">Scanned QR Code</p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                                        <Users className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white/90 rounded-2xl shadow-4x1 p-6 border border-gray-100 transform hover:scale-[1.02] duration-300">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-gray-500 text-sm mb-1">Latest Check-In</p>
                                        <p className="text-xl font-bold text-green-600">
                                            {attendees.length > 0 ? attendees[attendees.length - 1].checkInTime : 'No check-ins yet'}
                                        </p>
                                    </div>
                                    <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                                        <CheckCircle className="w-6 h-6 text-white" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* QR Code Section */}
                        <div className="bg-white rounded-3xl shadow-xl p-6 md:p-8 mb-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 rounded-t-3xl -mt-8 -mx-8 mb-6"></div>
                            
                            <div className="flex flex-col md:flex-row items-center gap-8">
                                <div className="flex-shrink-0">
                                    <div className="bg-gradient-to-br from-purple-50 to-pink-50 p-6 rounded-2xl border-2 border-purple-200">
                                        {(qrCodeUrl &&qrStatus===200)&&(
                                            <img 
                                                src={qrCodeUrl} 
                                                alt="Event QR Code" 
                                                className="w-64 h-64 rounded-xl"
                                            />
                                        )}
                                        {(qrStatus===403)&&(
                                            <img 
                                                src={qr_403} 
                                                alt="Fobbiden Qr image" 
                                                className="w-64 h-64 rounded-xl"
                                            />
                                        )}
                                        {(qrStatus===404)&&(
                                            <img 
                                                src={qr_404} 
                                                alt="Qr not found" 
                                                className="w-64 h-64 rounded-xl"
                                            />
                                        )}
                                    </div>
                                </div>
                                
                                <div className="flex-1">
                                    <div className="flex items-center gap-3 mb-4">
                                        <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                                            <QrCode className="w-6 h-6 text-white" />
                                        </div>
                                        <h2 className="text-2xl font-bold text-gray-900">Event QR Code</h2>
                                    </div>
                                    
                                    <p className="text-gray-600 mb-6 leading-relaxed">
                                        Members can scan this QR code at the event venue to check in. Once scanned, they will automatically 
                                        appear in the attendees list below. You can download and display this QR code at the event entrance.
                                    </p>
                                    
                                    <button
                                        onClick={handleDownloadQR}
                                        className="flex items-center gap-2 px-6 py-3.5 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:from-purple-700 hover:to-blue-700 transform hover:scale-105 transition-all duration-300"
                                    >
                                        <Download className="w-5 h-5" />
                                        Download QR Code
                                    </button>
                                </div>
                            </div>
                        </div>

                        {/* Attendees List Section */}
                        <div className="bg-white rounded-3xl shadow-xl p-6 md:p-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 rounded-t-3xl -mt-8 -mx-8 mb-6"></div>
                            
                            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
                                <div>
                                    <h2 className="text-2xl font-bold text-gray-900">Checked-In Attendees</h2>
                                    <p className="text-sm text-gray-500 mt-1">Members who scanned the QR code</p>
                                </div>
                                <button
                                    onClick={handleExportAttendees}
                                    className="flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl font-medium shadow-md hover:shadow-lg hover:from-green-600 hover:to-emerald-700 transition-all"
                                >
                                    <Download className="w-4 h-4" />
                                    Export List
                                </button>
                            </div>

                            {/* Search */}
                            <div className="mb-6">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                                    <input
                                        type="text"
                                        placeholder="Search by name or email..."
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value)}
                                        className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                                    />
                                </div>
                            </div>

                            {/* Attendees Table */}
                            <div className="overflow-x-auto">
                                <table className="w-full">
                                    <thead>
                                        <tr className="border-b border-gray-200">
                                            <th className="text-left py-4 px-4 text-sm font-semibold text-gray-600">Name</th>
                                            <th className="text-left py-4 px-4 text-sm font-semibold text-gray-600">Contact</th>
                                            <th className="text-left py-4 px-4 text-sm font-semibold text-gray-600">Check-In Time</th>
                                            <th className="text-center py-4 px-4 text-sm font-semibold text-gray-600">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {filteredAttendees.map((attendee) => (
                                            <tr key={attendee.id} className="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                                                <td className="py-4 px-4">
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold">
                                                            {attendee.name.charAt(0)}
                                                        </div>
                                                        <span className="font-semibold text-gray-900">{attendee.name}</span>
                                                    </div>
                                                </td>
                                                <td className="py-4 px-4">
                                                    <div className="space-y-1">
                                                        <div className="flex items-center gap-2 text-sm text-gray-600">
                                                            <Mail className="w-4 h-4" />
                                                            {attendee.email}
                                                        </div>
                                                        <div className="flex items-center gap-2 text-sm text-gray-600">
                                                            <Phone className="w-4 h-4" />
                                                            {attendee.phone}
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="py-4 px-4">
                                                    <div className="flex items-center gap-2">
                                                        <CheckCircle className="w-4 h-4 text-green-600" />
                                                        <span className="text-sm text-gray-900 font-medium">{attendee.checkInTime}</span>
                                                    </div>
                                                </td>
                                                <td className="py-4 px-4 text-center">
                                                    <button
                                                        onClick={() => handleRemoveAttendee(attendee.id)}
                                                        className="px-4 py-2 rounded-lg font-medium text-sm bg-red-100 text-red-700 hover:bg-red-200 transition-all"
                                                    >
                                                        Remove
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>

                                {filteredAttendees.length === 0 && (
                                    <div className="text-center py-12">
                                        <QrCode className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                        <p className="text-gray-500 text-lg font-semibold mb-2">No attendees yet</p>
                                        <p className="text-gray-400 text-sm">Attendees will appear here once they scan the QR code</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    );
}