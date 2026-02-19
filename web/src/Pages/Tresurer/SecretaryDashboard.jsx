import React, { useState, useEffect } from 'react';
import { Home, Bell, Users, Settings, Menu, X, Calendar, Droplet, Sprout, ChevronLeft, ChevronRight,IdCard,FileWarning,Boxes,FileBarChart, } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import axios from '../../config';


export default function SecretaryDashboard() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [announcementIndex, setAnnouncementIndex] = useState(0);

  const token = localStorage.getItem('token');

  const fetchRecentAnnouncements = async ()=>{
    try{
      const response = await axios.get('/announcement/recent-3',{
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
    }
  }


  const{
    data:recentAnnouncements=[],
    isLoading:isCarasouleLoading,
    isError:isCarasouelError,
    error:CarasouelError
  }=useQuery({
    queryKey:['importantAnnouncements'],
    queryFn:fetchRecentAnnouncements,
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

  const updates = [
    {
      id: 1,
      title: "Community Garden Opening",
      description: "The community garden will be officially opened next week.",
      date: "2025-11-10",
      icon: Sprout,
      color: "from-emerald-500 to-teal-500"
    },
    {
      id: 2,
      title: "Blood Donation Camp",
      description: "Join us for the annual blood donation event this Saturday.",
      date: "2025-11-08",
      icon: Droplet,
      color: "from-rose-500 to-pink-500"
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      {/* Sidebar */}
      <aside className={`fixed left-0 top-16 h-full bg-gradient-to-b from-purple-600 to-indigo-700 text-white transition-all duration-300 z-2 ${sidebarOpen ? 'w-64' : 'w-20'}`}>
        <div className="flex items-center justify-between p-6 pb-1 mt-8">
          <button 
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-2 rounded-lg hover:bg-white/10 transition-colors"
          >
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        <nav className="mt-2 space-y-2 px-4">
          {[
            { icon: Home, label: 'Dashboard', id: 'dashboard' },
            { icon: Bell, label: 'Announcements', id: 'announcements' },
            { icon: Users, label: 'Community', id: 'community' },
            { icon: IdCard, label: 'Member Details', id: 'memberDetails' },
            { icon: Boxes, label: 'Inventory', id: 'inventory' },
            { icon: FileBarChart, label: 'Reports', id: 'reports' },
            { icon: FileSpreadsheet, label: 'Finances', id: 'finances' },

            { icon: FileWarning, label: 'Complains', id: 'complains' },
            { icon: Settings, label: 'Settings', id: 'settings' }
          ].map((item) => (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`w-full flex items-center gap-4 px-4 py-3 rounded-xl transition-all duration-200 ${
                activeTab === item.id 
                  ? 'bg-white/20 shadow-lg' 
                  : 'hover:bg-white/10'
              }`}
            >
              <item.icon size={20} />
              <span className={`font-medium transition-opacity duration-300 ${sidebarOpen ? 'opacity-100' : 'opacity-0 w-0'}`}>
                {item.label}
              </span>
            </button>
          ))}
        </nav>
      </aside>

      {/* Main Content */}
      <main className={`transition-all duration-300 ${sidebarOpen ? 'ml-64' : 'ml-20'}`}>
        {/* Header */}
        <header className="bg-white/80 backdrop-blur-sm border-b border-slate-200 sticky top-0 z-10">
          <div className="px-8 py-6">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-3xl font-bold text-slate-800">Welcome Back!</h2>
                <p className="text-slate-600 mt-1">Here's what's happening in your community</p>
              </div>
              <div className="flex items-center gap-4">
                <div className="relative">
                  <Bell className="text-slate-600 cursor-pointer hover:text-purple-600 transition-colors" />
                  <span className="absolute -top-1 -right-1 w-4 h-4 bg-rose-500 rounded-full text-white text-xs flex items-center justify-center">3</span>
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <div className="p-8 space-y-8">
          {/* Important Announcements Carousel */}
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-purple-600 via-violet-600 to-indigo-600 p-8 shadow-2xl">
            <div className="absolute inset-0 bg-white/5 backdrop-blur-sm"></div>
            <div className="relative z-10">
              <div className="flex items-start justify-between gap-6">
                <div className="flex items-start gap-3 flex-1">
                  <div className="bg-white/20 p-3 rounded-xl flex-shrink-0">
                    <Bell className="text-white" size={24} />
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
              <div className="flex gap-2 mt-4 justify-center">
                {announcements.map((_, idx) => (
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
            <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-32 translate-x-32"></div>
            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white/5 rounded-full translate-y-24 -translate-x-24"></div>
          </div>

          {/* Community Updates Section */}
          <div>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-2xl font-bold text-slate-800">Community Updates</h3>
              <button className="text-purple-600 hover:text-purple-700 font-medium transition-colors">
                View All →
              </button>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
              {updates.map((update) => {
                const IconComponent = update.icon;
                return (
                  <div 
                    key={update.id}
                    className="group bg-white rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all duration-300 cursor-pointer border border-slate-100 hover:border-purple-200 hover:-translate-y-1"
                  >
                    <div className="flex gap-4">
                      <div className={`flex-shrink-0 w-14 h-14 rounded-xl bg-gradient-to-br ${update.color} flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                        <IconComponent className="text-white" size={24} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="text-xl font-bold text-slate-800 mb-2 group-hover:text-purple-600 transition-colors">
                          {update.title}
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