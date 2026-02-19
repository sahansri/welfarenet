import React, { useState } from 'react';
import { Megaphone, Calendar, Users, AlertCircle, Send, X, Image, Paperclip, Eye } from 'lucide-react';
import axios from '../../config';
import {useNavigate} from 'react-router-dom';

const CreateAnnouncement = () => {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    priority: 'MEDIUM',
    expiryDate: ''
  });

  const [showPreview, setShowPreview] = useState(false);

   const priorities = [
    { value: 'LOW', label: 'Low', color: 'bg-blue-100 text-blue-700 border-green-300' },
    { value: 'MEDIUM', label: 'Medium', color: 'bg-gray-100 text-gray-700 border-blue-300' },
    { value: 'HIGH', label: 'High', color: 'bg-orange-100 text-orange-700 border-orange-300' },
    { value: 'URGENT', label: 'Urgent', color: 'bg-red-100 text-red-700 border-red-300' }
  ];

  const handleSubmit = async () => {
    const token = localStorage.getItem("token");
    const role = localStorage.getItem('role');
    try{
      const response = await axios.post('/announcements/create',formData,{
        headers:{
          "Authorization":`Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      if(response.status === 200){
        alert("Announcement Submitted Sucessfully!");
        navigate(`/${role}/announcements`);
      }
    }
    catch (error){
        console.log("Error occured while submitting!",error);
    }
  };


  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 via-purple-500 to-purple-700 p-8 ">
      {/* Main Container */}
      <div className="max-w-5xl mx-auto pt-36">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-2xl p-8 mb-6 shadow-xl">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-white rounded-xl flex items-center justify-center">
              <Megaphone size={32} className="text-purple-900" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white mb-1">Create Announcement</h1>
              <p className="text-purple-100">Share important updates with your community members</p>
            </div>
          </div>
        </div>

        {/* Form Card */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
          <form>
            <div className="p-8 space-y-6">
              {/* Title Input */}
              <div>
                <label className="block text-gray-700 font-semibold mb-2">
                  Announcement Title *
                </label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
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
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
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
                      onClick={() => setFormData({ ...formData, priority: priority.value })}
                      className={`px-4 py-3 rounded-lg border-2 font-medium transition-all ${
                        formData.priority === priority.value
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
                  value={formData.expiryDate}
                  onChange={(e) => setFormData({ ...formData, expiryDate: e.target.value })}
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
                  className="px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition font-medium"
                >
                  Save Draft
                </button>
                <button
                  type="button"
                  className="flex items-center gap-2 px-8 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium shadow-lg hover:shadow-xl"
                  onClick = {()=>handleSubmit()}
                >
                  <Send size={18} />
                  Publish Announcement
                </button>
              </div>
            </div>
          </form>
        </div>

        {/* Preview Modal */}
        {showPreview && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[80vh] overflow-y-auto">
              <div className="sticky top-0 bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center">
                <h3 className="text-xl font-bold text-white">Preview</h3>
                <button
                  onClick={() => setShowPreview(false)}
                  className="text-white hover:bg-white/20 rounded-lg p-2 transition"
                >
                  <X size={24} />
                </button>
              </div>
              <div className="p-8">
                <div className="mb-4">
                  <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${
                    priorities.find(p => p.value === formData.priority)?.color
                  }`}>
                    {priorities.find(p => p.value === formData.priority)?.label} Priority
                  </span>
                </div>
                <h2 className="text-2xl font-bold text-gray-900 mb-4">
                  {formData.title || 'Untitled Announcement'}
                </h2>
                <p className="text-gray-700 whitespace-pre-wrap mb-4">
                  {formData.content || 'No content added yet...'}
                </p>
                {formData.expiryDate && (
                  <p className="text-gray-500 text-sm">
                    Expires on: {new Date(formData.expiryDate).toLocaleDateString()}
                  </p>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default CreateAnnouncement;