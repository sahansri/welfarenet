import React, { useState, useEffect } from 'react';
import { Home, Bell, Users, Settings, Menu, X, Calendar,Briefcase,HeartHandshake,PartyPopper,Trophy,HandHelping ,Droplet, Sprout, ChevronLeft, ChevronRight,IdCard,FileWarning,Boxes,FileBarChart,RefreshCcw } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import axios from '../../config';

export default function Dashboard() {
  
  const [announcementIndex, setAnnouncementIndex] = useState(0);
  const token = localStorage.getItem('token');

  const fetchRecentAnnouncements = async ()=>{
    try{
      const response = await axios.get('/announcements/recent-3',{
        headers:{
          'Authorization':`Bearer ${token}`,
          'Content-Type':'application/json'
        }
      })
      console.log("Fetched Recent Announcements: ",response.data);
      return response.data;
    }
    catch (error){
      console.log("Error Occcored while fetching recent announcements!");
      return [];
    }
  }

  const fetchCommunityUpdates = async ()=>{
    try{
      const response = await axios.get('/events/upcoming',{
        headers:{
          'Authorization':`Bearer ${token}`,
          'Content-Type':'application/json'
        }
      });
      console.log("Fetched Community Updates: ",response.data);
      return response.data;
    }
    catch(error){
      console.log("Error Occcored while fetching community updates!");
      return [];
    }
  }

  const{
    data:recentAnnouncements=[],
    isLoading:isCarasouleLoading,
    isError:isCarasouelError,
    error:CarasouelError,
    isFetching:isCarasoulFetching,
    refetch
  }=useQuery({
    queryKey:['importantAnnouncements'],
    queryFn:fetchRecentAnnouncements,
    staleTime:20*60*1000, // 20 minutes,
    cacheTime:60*60*1000 // 60 minutes

  });

  const{
    data:updates=[],
    isLoading:isUpdatesLoading,
    isError:isUpdatesError,
    error:UpdatesError,
    isFetching:isUpdatesFetching,
  }=useQuery({
    queryKey:['communityUpdates'],
    queryFn:fetchCommunityUpdates,
    staleTime:20*60*1000, // 20 minutes,
    cacheTime:60*60*1000 // 60 minutes
  });
  

  useEffect(() => {
    const timer = setInterval(() => {
      setAnnouncementIndex((prev) => (prev + 1) % recentAnnouncements.length);
    }, 5000);
    return () => clearInterval(timer);
  }, [recentAnnouncements.length]);

  const prevAnnouncement = () => {
    setAnnouncementIndex((prev) => (prev - 1 + recentAnnouncements.length) % recentAnnouncements.length);
  };

  const nextAnnouncement = () => {
    setAnnouncementIndex((prev) => (prev + 1) % recentAnnouncements.length);
  };

  const eventTypeConfig = {
  community: {
    color: "bg-purple-500",
    icon: Users,
  },
  meeting: {
    color: "bg-blue-500",
    icon: Briefcase,
  },
  charity: {
    color: "bg-orange-500",
    icon: HeartHandshake,
  },
  celebration: {
    color: "bg-pink-500",
    icon: PartyPopper,
  },
  sports: {
    color: "bg-green-500",
    icon: Trophy,
  },
  volunteer: {
    color: "bg-indigo-500",
    icon: HandHelping,
  },
};


  return (
    <div className="min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC]">
      {/* Main Content */}
      <main className={`transition-all duration-300 ml-4 mr-4 pt-36`}>
        {/* Header */}
        <header className="backdrop-blur-sm   sticky top-0 z-10">
          <div className="px-8 py-6">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-4xl font-extrabold text-white">
                  Welcome Back!
                </h2>
                <p className="text-white mt-2 text-lg">
                  Let's keep your community running smoothly.
                </p>
              </div>
              
            </div>
          </div>
        </header>

        {/* Content Area */}
        <div className="p-8 space-y-8">
          {/* Important Announcements Carousel */}
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-purple-900  to-purple-800 p-8 shadow-2xl transform hover:scale-[1.02] transition-transform duration-300">
            <div className="relative z-10">
              {(isCarasouleLoading || isCarasoulFetching)?(
                <div>
                  <p className="text-white text-lg text-center">Loading announcements...</p>
                </div>
                ):(isCarasouelError || recentAnnouncements.length===0)?(
                  <div className="flex flex-col items-center justify-center text-center min-h-[200px]">
                    <p className="text-white text-lg">
                      Failed to load announcements!
                    </p>

                    <button
                      onClick={refetch}
                      className="mt-6 inline-flex items-center gap-2 rounded-lg 
                                bg-purple-600 px-4 py-2 text-sm font-medium text-white 
                                hover:bg-purple-700 transition"
                    >
                      <RefreshCcw size={16} />
                      Retry
                    </button>
                  </div>
                ):(
                <div className="flex items-start justify-between gap-6">
                  <div className="flex items-start gap-3 flex-1">
                    <div className="bg-white p-3 rounded-xl flex-shrink-0">
                      <Bell className="text-purple-900" size={24} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-2xl font-bold text-white mb-2">{recentAnnouncements[announcementIndex].title}</h3>
                      <p className="text-purple-100 text-lg">{recentAnnouncements[announcementIndex].description}</p>
                    </div>
                  </div>
                  <div className="flex gap-2 flex-shrink-0">
                    <button
                      onClick={prevAnnouncement}
                      className="p-2 rounded-lg bg-white/20 hover:bg-white/30 transition-colors"
                    >
                      <ChevronLeft className="text-white" size={20} />
                    </button>
                    <button
                      onClick={nextAnnouncement}
                      className="p-2 rounded-lg bg-white/20 hover:bg-white/30 transition-colors"
                    >
                      <ChevronRight className="text-white" size={20} />
                    </button>
                  </div>
                </div>
              )}
              <div className="flex gap-2 mt-4 justify-center">
                {recentAnnouncements.map((_, idx) => (
                  <button
                    key={idx}
                    onClick={() => setAnnouncementIndex(idx)}
                    className={`w-2 h-2 rounded-full transition-all ${
                      idx === announcementIndex ? 'bg-white w-6' : 'bg-white/40'
                    }`}
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Community Updates Section */}
          <div>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-2xl font-bold text-white">Community Updates</h3>
              <button className="text-purple-600 hover:text-purple-700 font-medium transition-colors">
                View All →
              </button>
            </div>

            {(isUpdatesLoading || isUpdatesFetching) &&(
              <div>
                  <p className="text-white text-lg text-center">Loading Updates...</p>
                </div>
              )}

            {(updates.length === 0 && !isUpdatesLoading && !isUpdatesFetching)? (
                <div className="text-center py-12">
                  <p className="text-white text-lg">No community updates available.</p>
                </div>
              ):(
                <div className="grid gap-6 md:grid-cols-2">
                  {updates.map((update) => {
                    const config = eventTypeConfig[update.eventType] || eventTypeConfig.community;
                    const IconComponent = config.icon;
                    const colorClass = config.color;
                    return (
                      <div 
                        key={update.eventId}
                        className="group bg-white rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all duration-300 cursor-pointer border border-slate-100 hover:border-purple-200 hover:-translate-y-1"
                      >
                        <div className="flex gap-4">
                          <div className={`flex-shrink-0 w-14 h-14 rounded-xl bg-gradient-to-br ${colorClass} flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                            <IconComponent className="text-white" size={24} />
                          </div>
                          <div className="flex-1 min-w-0">
                            <h4 className="text-xl font-bold text-slate-800 mb-2 group-hover:text-purple-600 transition-colors">
                              {update.eventName}
                            </h4>
                            <p className="text-slate-600 mb-4 leading-relaxed">
                              {update.description}
                            </p>
                            <div className="flex items-center gap-2 text-sm text-slate-500">
                              <Calendar size={16} />
                              <span>{update.date}</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
            )}
          </div>

          {/* Quick Stats */}
          <div className="grid gap-6 md:grid-cols-3">
            {[
              { label: 'Active Members', value: '1,234', change: '+12%', color: 'from-blue-500 to-cyan-500' },
              { label: 'Events This Month', value: '8', change: '+3', color: 'from-purple-500 to-pink-500' },
              { label: 'Participation Rate', value: '87%', change: '+5%', color: 'from-emerald-500 to-teal-500' }
            ].map((stat, index) => (
              <div key={index} className="bg-white rounded-2xl p-6 shadow-lg border border-slate-100">
                <div className={`inline-block px-3 py-1 rounded-full bg-gradient-to-r ${stat.color} text-white text-sm font-medium mb-3`}>
                  {stat.change}
                </div>
                <h4 className="text-slate-600 text-sm font-medium mb-1">{stat.label}</h4>
                <p className="text-3xl font-bold text-slate-800">{stat.value}</p>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}