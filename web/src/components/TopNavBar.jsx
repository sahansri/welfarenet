import React, { useState } from 'react';
import { Home, Bell, Users, Settings, Menu, X, Receipt, FileWarning, FileBarChart,MoreHorizontal,CalendarDays,DollarSign,Gift, Wallet, Star, Newspaper} from "lucide-react";
import { useNavigate } from 'react-router-dom';
import { useTopNavBar } from '../context/TopNavBarContext.jsx';

export default function TopNavBar() {
  const navigate = useNavigate();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { activeTab, setActiveTab } = useTopNavBar();
  const role = localStorage.getItem('role'); // This should come from your auth context

  const navBarItems = () => {
    if(role === 'TREASURER'){
      return [
        { icon: Home, label: 'Dashboard', id: 'dashboard', path: '/treasurer/dashboard'},
        { icon: Bell, label: 'Announcements', id: 'announcements',path:'/treasurer/announcements'},
        { icon: Users, label: 'News Feed', id: 'community',path:'/treasurer/feed'},
        { icon: Receipt, label: 'Payments', id: 'payments', path:'/treasurer/payments' },
        { icon: Gift , label: 'Star Claims', id:'claims',path:'/treasurer/starClaims'},
        { icon:Wallet, label:'Expenses', id:'expenses', path:'/treasurer/expenses'},
        { icon:CalendarDays, label:'Calendar', id:'calendar', path:'/treasurer/calendar'},
        { icon:Star, label:'Unity Stars', id:'unityStars', path:'/treasurer/unityStars'},
        { icon: MoreHorizontal, label: 'More', id: 'more' ,path:'/treasurer/more'}
      ];
    } 
    else if (role === 'ADMIN') {
      return [
        { icon: Home, label: 'Dashboard', id: 'dashboard', path:'/admin/dashboard' },
        { icon: Bell, label: 'Announcements', id: 'announcements', path:'/admin/announcements' },
        { icon: Users, label: 'News Feed', id: 'feed',path:'/admin/feed'},
        { icon: CalendarDays, label: 'Events', id: 'events',path:'/admin/events' },
        { icon: Users, label:'User Management', id:'users', path:'/admin/users'},
        { icon:CalendarDays, label:'Calendar', id:'calendar', path:'/admin/calendar'},
        { icon: FileBarChart, label: 'Reports', id: 'reports' },
        { icon: FileWarning, label: 'Complaints', id: 'complaints', path:'/admin/complaints' },
        { icon: MoreHorizontal, label: 'More', id: 'more' ,path:'/admin/more'},
      ];
    }
    else if(role==='PRESIDENT'){
      return [
        { icon: Home, label: 'Dashboard', id: 'dashboard', path:'/president/dashboard' },
        { icon: Bell, label: 'Announcements', id: 'announcements', path:'/president/announcements' },
        { icon: Newspaper, label: 'News Feed', id: 'feed',path:'/president/feed'},
        { icon: CalendarDays, label: 'Events', id: 'events',path:'/president/events' },
        
        { icon: FileWarning, label: 'Complaints', id: 'complaints', path:'/president/complaints' },
        { icon: Users, label:'User Management', id:'users', path:'/president/users'},
        { icon:CalendarDays, label:'Calendar', id:'calendar', path:'/president/calendar'},
        { icon:Star, label:'Unity Stars', id:'unityStars', path:'/president/unityStars'},
        { icon: MoreHorizontal, label: 'More', id: 'more' ,path:'/president/more'},
      ];

    }
    else {
      return [
        { icon: Home, label: 'Dashboard', id: 'dashboard', path: '/member/dashboard'},
        { icon: Bell, label: 'Announcements', id: 'announcements' },
        { icon: Users, label: 'Community Feed', id: 'community', path: '/member/feed'},
        { icon: Receipt, label: 'Payments', id: 'payments' },
        { icon: FileWarning, label: 'Complains', id: 'complains' },
        { icon: Settings, label: 'Settings', id: 'settings' },
      ];
    }
  };

  return (
    <div className="w-full flex items-center justify-between relative ">
      {/* Desktop Navigation */}
      <div className="hidden lg:flex items-center justify-center w-full gap-6">
        {navBarItems().map((item) => (
          <button
            key={item.id}
            onClick={() => {
              setActiveTab(item.id);
              if (item.path) navigate(item.path);
            }}
            className={`flex items-center gap-2 px-4 py-1.5 rounded-lg transition-all duration-200 ${
              activeTab === item.id 
                ? 'bg-purple-100 text-purple-700 shadow-sm' 
                : 'text-gray-700 hover:bg-gray-100'
            }`}
          >
            <item.icon size={16} />
            <span className="font-medium text-sm whitespace-nowrap">{item.label}</span>
          </button>
        ))}
      </div>
      {/* Mobile Menu Button */}
      <button
        onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        className="lg:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors text-gray-700"
      >
        {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
      </button>

      {/* Mobile Dropdown Menu */}
      {mobileMenuOpen && (
        <div className="lg:hidden absolute top-full left-0 right-0 mt-2 bg-white shadow-lg border border-gray-200 rounded-xl z-[60]">
          <div className="px-4 py-2 space-y-1 max-h-[70vh] overflow-y-auto">
            {navBarItems().map((item) => (
              <button
                key={item.id}
                onClick={() => {
                  setActiveTab(item.id);
                  if (item.path) navigate(item.path);
                  setMobileMenuOpen(false);
                }}
                className={`w-full flex items-center gap-3 px-4 py-2.5 rounded-lg transition-all duration-200 ${
                  activeTab === item.id 
                    ? 'bg-purple-100 text-purple-700 shadow-sm' 
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <item.icon size={18} />
                <span className="font-medium">{item.label}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}