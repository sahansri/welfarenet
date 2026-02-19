import { useEffect, useState } from 'react';
import { ChevronLeft, ChevronRight, Calendar, Clock, MapPin, Users, Plus } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import axios from '../../config'

export default function eventCalendar() {
    const role = localStorage.getItem('role');
    const navigate = useNavigate();
    const [currentDate, setCurrentDate] = useState(new Date());
    const [selectedDate, setSelectedDate] = useState(null);
    const [events, setEvents] = useState([]);
    const [isLoading,setIsLoading] = useState(true);
    
    useEffect(()=>{
        const fetchEvents = async () =>{
            setIsLoading(true);
            try{
                const response = await axios.get('/events/getAll',{
                    headers:{
                        'Authorization': `Bearer ${localStorage.getItem('token')}`,
                        'Content-Type': 'application/json'
                    }
                })
                console.log('Fetched events:', response.data);
                setEvents(response.data);
            }
            catch(error){
                console.error('Error fetching events:', error); 
            }
            finally{
                setIsLoading(false);
            }
        };
        fetchEvents();
    },[]);

    /* -------------------- HELPERS -------------------- */
    const normalizeDate = (date) =>
        new Date(date).toISOString().split('T')[0];

    const isEventPast = (date) => {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return new Date(date) < today;
    };

    const getEventsForDate = (dateStr) =>
        events.filter(event => normalizeDate(event.date) === dateStr);

    const getEventTypeColor = (type) => {
        const colors = {
            community: 'bg-purple-500',
            meeting: 'bg-blue-500',
            charity: 'bg-orange-500',
            celebration: 'bg-pink-500',
            sports: 'bg-green-500',
            volunteer: 'bg-indigo-500',
        };
        return colors[type] || 'bg-gray-500';
    };

    const getEventTypeName = (type) => {
        const names = {
            community: 'Community',
            meeting: 'Meeting',
            charity: 'Charity',
            celebration: 'Celebration',
            sports: 'Sports',
            volunteer: 'Volunteer',
        };
        return names[type] || type;
    };


    const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ];

    const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    const getDaysInMonth = (date) => {
        const year = date.getFullYear();
        const month = date.getMonth();
        return new Date(year, month + 1, 0).getDate();
    };

    const getFirstDayOfMonth = (date) => {
        const year = date.getFullYear();
        const month = date.getMonth();
        return new Date(year, month, 1).getDay();
    };


    const isToday = (day) => {
        const today = new Date();
        return (
            day === today.getDate() &&
            currentDate.getMonth() === today.getMonth() &&
            currentDate.getFullYear() === today.getFullYear()
        );
    };


    const previousMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1));
        setSelectedDate(null);
    };

    const nextMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1));
        setSelectedDate(null);
    };

    const handleDateClick = (day) => {
        const dateStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
        const dayEvents = getEventsForDate(dateStr);
        if (dayEvents.length > 0) {
            setSelectedDate(dateStr);
        }
    };

    const handleAddEvent = () => {
        if(role==='president'){
            navigate(`/${role}/events/create`);
        }
        else if(role==='admin'){
            navigate(`/${role}/events/create`);
        }
    };

    const renderCalendarDays = () => {
        const daysInMonth = getDaysInMonth(currentDate);
        const firstDay = getFirstDayOfMonth(currentDate);
        const days = [];

        // Empty cells for days before month starts
        for (let i = 0; i < firstDay; i++) {
            days.push(
                <div key={`empty-${i}`} className="aspect-square p-2"></div>
            );
        }

        // Days of the month
        for (let day = 1; day <= daysInMonth; day++) {
            const dateStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            const dayEvents = getEventsForDate(dateStr);
            
            
            

            days.push(
                <div
                    key={day}
                    onClick={() => handleDateClick(day)}
                    className={`aspect-square p-2 border border-gray-200 rounded-xl transition-all ${
                        selectedDate === dateStr ? 'bg-purple-100 border-purple-500' : 'bg-white'
                    } ${
                        isToday(day) ? 'ring-2 ring-blue-500' : ''
                    }`}
                >
                    <div className="h-full flex flex-col">
                        <div className={`text-sm font-semibold mb-1 ${
                            isToday(day) ? 'text-blue-600' : isEventPast(day) ? 'text-gray-400' : 'text-gray-900'
                        }`}>
                            {day}
                        </div>
                        
                            <div className='hover:cursor-pointer'>
                                {dayEvents.slice(0, 3).map((event, idx) => (
                                    <div
                                        key={idx}
                                        className={`text-xs px-2 py-1 rounded text-white font-medium truncate ${getEventTypeColor(event.eventType)} ${
                                           isEventPast(day) ? 'opacity-60' : ''
                                        }`}
                                        title={event.eventName}
                                    >
                                        {event.eventName}
                                    </div>
                                ))}
                                {dayEvents.length > 3 && (
                                    <div className="text-xs text-gray-500 font-medium px-2">
                                        +{dayEvents.length - 3} more
                                    </div>
                                )} 
                            </div>    
                    </div>
                </div>
            );
        }

        return days;
    };

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const selectedDateEvents = selectedDate
        ? getEventsForDate(selectedDate)
        : [];

    const upcomingEvents = events.filter(
        event => new Date(event.date) >= today
    );

    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Calendar is Loading...
                </p>
            </div>
            </div>
        );
    }

    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-7xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="p-4">
                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            
                            <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                                <div>
                                    <div className="flex items-center gap-4 mb-3">
                                        <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                            <Calendar className="w-8 h-8 text-purple-900" />
                                        </div>
                                        <div>
                                            <h1 className="text-4xl font-bold tracking-tight">Events Calendar</h1>
                                        </div>
                                    </div>
                                    <p className="text-purple-100 text-lg">View all scheduled community events</p>
                                </div>
                                {(role ==='president' || role==='admin') && (
                                    <button
                                        onClick={handleAddEvent}
                                        className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                                    >
                                        <Plus className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                        Create Event
                                    </button>
                                )}
                            </div>
                        </div>

                        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                            {/* Calendar Section */}
                            <div className="lg:col-span-2">
                                <div className="bg-white rounded-3xl shadow-xl p-6 md:p-8 overflow-hidden border border-gray-100">
                                    <div className="h-2 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 rounded-t-3xl -mt-8 -mx-8 mb-6 "></div>
                                    
                                    {/* Calendar Header */}
                                    <div className="flex items-center justify-between mb-6">
                                        <h2 className="text-2xl font-bold text-gray-900">
                                            {monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}
                                        </h2>
                                        <div className="flex gap-2">
                                            <button
                                                onClick={previousMonth}
                                                className="p-2 bg-purple-100 text-purple-600 rounded-lg hover:bg-purple-200 transition-all"
                                            >
                                                <ChevronLeft className="w-5 h-5" />
                                            </button>
                                            <button
                                                onClick={nextMonth}
                                                className="p-2 bg-purple-100 text-purple-600 rounded-lg hover:bg-purple-200 transition-all"
                                            >
                                                <ChevronRight className="w-5 h-5" />
                                            </button>
                                        </div>
                                    </div>

                                    {/* Days of Week */}
                                    <div className="grid grid-cols-7 gap-2 mb-2">
                                        {daysOfWeek.map(day => (
                                            <div key={day} className="text-center text-sm font-semibold text-gray-600 py-2">
                                                {day}
                                            </div>
                                        ))}
                                    </div>

                                    {/* Calendar Grid */}
                                    <div className="grid grid-cols-7 gap-2">
                                        {renderCalendarDays()}
                                    </div>

                                    {/* Legend */}
                                    <div className="mt-6 pt-6 border-t border-gray-200">
                                        <h3 className="text-sm font-semibold text-gray-700 mb-3">Event Types</h3>
                                        <div className="flex flex-wrap gap-3">
                                            {Object.keys({community: '', charity: '', meeting: '', sports: '', volunteer: '', celebration: ''}).map(type => (
                                                <div key={type} className="flex items-center gap-2">
                                                    <div className={`w-3 h-3 rounded ${getEventTypeColor(type)}`}></div>
                                                    <span className="text-xs text-gray-600">{getEventTypeName(type)}</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Events List Section */}
                            <div className="lg:col-span-1">
                                <div className="bg-white rounded-3xl shadow-xl p-6 overflow-hidden border border-gray-100 sticky top-4">
                                    <div className="h-2 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 rounded-t-3xl -mt-6 -mx-6 mb-6"></div>
                                    
                                    <h2 className="text-xl font-bold text-gray-900 mb-4">
                                        {selectedDate ? 'Events on Selected Day' : 'Upcoming Events'}
                                    </h2>

                                    {selectedDate && (
                                        <button
                                            onClick={() => setSelectedDate(null)}
                                            className="text-sm text-purple-600 hover:text-purple-700 font-medium mb-4"
                                        >
                                            ← Show all upcoming events
                                        </button>
                                    )}

                                    <div className="space-y-4 max-h-[600px] overflow-y-auto">
                                        {(selectedDate ? selectedDateEvents : upcomingEvents).map(event => (
                                            <div
                                                key={event.eventId}
                                                className="bg-gradient-to-br from-gray-50 to-purple-50 rounded-2xl p-4 border border-gray-200 hover:shadow-lg transition-all"
                                            >
                                                <div className="flex items-start gap-3 mb-3">
                                                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${getEventTypeColor(event.eventType)}`}>
                                                        <Calendar className="w-5 h-5 text-white" />
                                                    </div>
                                                    <div className="flex-1">
                                                        <h3 className="font-bold text-gray-900 mb-1">{event.eventName}</h3>
                                                        <span className={`text-xs px-2 py-1 rounded-full ${getEventTypeColor(event.eventType)} text-white font-medium`}>
                                                            {getEventTypeName(event.eventType)}
                                                        </span>
                                                    </div>
                                                </div>

                                                <div className="space-y-2">
                                                    <div className="flex items-center gap-2 text-sm text-gray-600">
                                                        <Calendar className="w-4 h-4" />
                                                        <span>{event.date}</span>
                                                    </div>
                                                    <div className="flex items-center gap-2 text-sm text-gray-600">
                                                        <Clock className="w-4 h-4" />
                                                        <span>{event.time}</span>
                                                    </div>
                                                    <div className="flex items-center gap-2 text-sm text-gray-600">
                                                        <MapPin className="w-4 h-4" />
                                                        <span>{event.venue}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        ))}

                                        {selectedDate && selectedDateEvents.length === 0 && (
                                            <div className="text-center py-8 text-gray-500">
                                                <Calendar className="w-12 h-12 mx-auto mb-2 text-gray-300" />
                                                <p>No events on this day</p>
                                            </div>
                                        )}

                                        {!selectedDate && upcomingEvents.length === 0 && (
                                            <div className="text-center py-8 text-gray-500">
                                                <Calendar className="w-12 h-12 mx-auto mb-2 text-gray-300" />
                                                <p>No upcoming events</p>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    );
}