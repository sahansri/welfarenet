import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Settings, Users, FileText, Shield, HelpCircle, LogOut, Bell, CreditCard, BarChart3, Lock, Globe, Download, Upload, Archive, Trash2,CalendarDays,Gift,Star,Wallet } from 'lucide-react';

const MoreOptionsTresurer = () => {
  const navigate = useNavigate();
  const [activePage, setActivePage] = useState('more');

  const menuSections = [
    {
      title: 'Management',
      items: [
        { icon: CalendarDays, label: 'Events', description: 'Manage events in your community', color: 'purple',path:'/treasurer/more/events' },
        { icon: Users, label:'User Management', description:'Manage community members', color:'blue',path:'/treasurer/more/userManagement' },
       
      ]
    },
    {
      title: 'Finance',
      items: [
        { icon: Star, label: 'Unity Stars', description: 'Manage unity star points of the members', color: 'yellow',path:'/President/more/unityStars' },
        { icon: BarChart3, label: 'Reports', description: 'View financial reports and analytics', color: 'green',path:'/treasurer/more/reports' }, 
      ]
    },
    {
      title: 'Data & Import/Export',
      items: [
        { icon: Upload, label: 'Import Data', description: 'Upload and import data', color: 'teal' },
        { icon: Download, label: 'Export Data', description: 'Download and export data', color: 'orange' },
        { icon: Trash2, label: 'Data Management', description: 'Clean up and manage data', color: 'red' },
      ]
    },
    {
      title: 'Support & Resources',
      items: [
        { icon: HelpCircle, label: 'Help & Support', description: 'Get help and support resources', color: 'violet' },
        { icon: Globe, label: 'Community Forum', description: 'Connect with other users', color: 'lime' },
        { icon: Shield, label: 'Terms & Policies', description: 'Review terms and policies', color: 'slate' },
      ]
    }
  ];

  const getColorClasses = (color) => {
    const colors = {
      purple: 'bg-purple-100 text-purple-600',
      blue: 'bg-blue-100 text-blue-600',
      yellow: 'bg-yellow-100 text-yellow-600',
      green: 'bg-green-100 text-green-600',
      indigo: 'bg-indigo-100 text-indigo-600',
      gray: 'bg-gray-100 text-gray-600',
      pink: 'bg-pink-100 text-pink-600',
      cyan: 'bg-cyan-100 text-cyan-600',
      teal: 'bg-teal-100 text-teal-600',
      orange: 'bg-orange-100 text-orange-600',
      red: 'bg-red-100 text-red-600',
      violet: 'bg-violet-100 text-violet-600',
      lime: 'bg-lime-100 text-lime-600',
      slate: 'bg-slate-100 text-slate-600',
    };
    return colors[color] || colors.purple;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] pt-34">
      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-2xl p-8 mb-8 shadow-xl">
          <h1 className="text-4xl font-bold text-white mb-2">More Options</h1>
          <p className="text-purple-100">Access additional features and settings for your community</p>
        </div>

        {/* Options Grid */}
        {menuSections.map((section, sectionIndex) => (
          <div key={sectionIndex} className="mb-8">
            <h2 className="text-white text-xl font-semibold mb-4 px-2">{section.title}</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {section.items.map((item, itemIndex) => {
                const Icon = item.icon;
                return (
                  <button
                    key={itemIndex}
                    onClick={() => {
                      if(item.path){
                        navigate(item.path);
                      }
                    }}
                    className="bg-white rounded-xl p-6 hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 text-left group"
                  >
                    <div className={`w-12 h-12 rounded-lg ${getColorClasses(item.color)} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                      <Icon size={24} />
                    </div>
                    <h3 className="text-gray-900 font-semibold text-lg mb-2">{item.label}</h3>
                    <p className="text-gray-600 text-sm">{item.description}</p>
                  </button>
                );
              })}
            </div>
          </div>
        ))}

        {/* Logout Section */}
        <div className="mt-12">
          <button className="bg-white rounded-xl p-6 hover:shadow-2xl transition-all duration-300 hover:-translate-y-1 text-left group w-full md:w-auto">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-red-100 text-red-600 flex items-center justify-center group-hover:scale-110 transition-transform">
                <LogOut size={24} />
              </div>
              <div>
                <h3 className="text-gray-900 font-semibold text-lg">Logout</h3>
                <p className="text-gray-600 text-sm">Sign out from your account</p>
              </div>
            </div>
          </button>
        </div>
      </div>
    </div>
  );
};

export default MoreOptionsTresurer;