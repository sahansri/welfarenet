import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Calendar, Clock, MapPin, Users, DollarSign, Image, X, Eye, Send, AlertCircle, Tag, FileText } from 'lucide-react';
import axios from '../../config'

const CreateEvent = () => {
  const navigate = useNavigate();
  const role = localStorage.getItem('role');
  const [formData, setFormData] = useState({
    eventName: '',
    description: '',
    eventType: 'community',
    date: '',
    time: '',
    venue:'',
    endDate: '',
    endTime: '',
    venue: '',
    donationAccepted: false,
    organizer: '',
    contactEmail: '',
    contactPhone: '',
    banner: null
  });

  const [showPreview, setShowPreview] = useState(false);


  const eventTypes = [
    { value: 'community', label: 'Community Gathering', color: 'bg-purple-100 text-purple-700 border-purple-300' },
    { value: 'meeting', label: 'Official Meeting', color: 'bg-blue-100 text-blue-700 border-blue-300' },
    { value: 'charity', label: 'Charity Event', color: 'bg-orange-100 text-orange-700 border-orange-300' },
    { value: 'celebration', label: 'Celebration', color: 'bg-pink-100 text-pink-700 border-pink-300' },
    { value: 'sports', label: 'Sports & Recreation', color: 'bg-green-100 text-green-700 border-green-300' },
    { value: 'volunteer', label: 'Volunteer Event', color: 'bg-indigo-100 text-indigo-700 border-indigo-300' }
  ];

  const handleSubmit = async () => {
    if (!formData.eventName || !formData.date || !formData.time || !formData.venue) {
      alert('Please fill in all required fields');
      return;
    }
    try{
        const token = localStorage.getItem('token');
        const submit  = await axios.post("/events/create",formData,{
          headers:{
            'Authorization' : `Bearer ${token}`,
            'Content-Type' : 'application/json'
          }
        });
        alert('Event created successfully!');
        navigate(`/${role}/events`);
    }
    catch (error){
      console.log("Error occured while submitting the form!",error);
    }

  };

  const handleBannerUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData({ ...formData, banner: file });
    }
  };

  const removeBanner = () => {
    setFormData({ ...formData, banner: null });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 via-purple-500 to-purple-700 p-8">
      {/* Main Container */}
      <div className="max-w-6xl mx-auto pt-36">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-2xl p-8 mb-6 shadow-xl">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-white rounded-xl flex items-center justify-center">
              <Calendar size={32} className="text-purple-900" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white mb-1">Create Community Event</h1>
              <p className="text-purple-100">Organize and schedule events for your community members</p>
            </div>
          </div>
        </div>

        {/* Form Card */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
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
                    value={formData.eventName}
                    onChange={(e) => setFormData({ ...formData, eventName: e.target.value })}
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
                        onClick={() => setFormData({ ...formData, eventType: type.value })}
                        className={`px-4 py-3 rounded-lg border-2 font-medium transition-all text-sm ${
                          formData.eventType === type.value
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
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
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
                      value={formData.date}
                      onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 font-semibold mb-2">
                      Start Time *
                    </label>
                    <input
                      type="time"
                      value={formData.time}
                      onChange={(e) => setFormData({ ...formData, time: e.target.value })}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 font-semibold mb-2">
                      End Date
                    </label>
                    <input
                      type="date"
                      value={formData.endDate}
                      onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 font-semibold mb-2">
                      End Time
                    </label>
                    <input
                      type="time"
                      value={formData.endTime}
                      onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
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
                    value={formData.venue}
                    onChange={(e) => setFormData({ ...formData, venue: e.target.value })}
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
                  {!formData.banner ? (
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
                        <span className="text-gray-700">{formData.banner.name}</span>
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
                      checked={formData.donationAccepted}
                      onChange={(e) => setFormData({ ...formData, donationAccepted: e.target.checked })}
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
                      value={formData.organizer}
                      onChange={(e) => setFormData({ ...formData, organizer: e.target.value })}
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
                      value={formData.contactEmail}
                      onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
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
                      value={formData.contactPhone}
                      onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
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
                onClick={() => alert('Draft saved!')}
                className="px-6 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition font-medium"
              >
                Save Draft
              </button>
              <button
                onClick={handleSubmit}
                className="flex items-center gap-2 px-8 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium shadow-lg hover:shadow-xl"
              >
                <Send size={18} />
                Create Event
              </button>
            </div>
          </div>
        </div>

        {/* Preview Modal */}
        {showPreview && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-2xl max-w-3xl w-full max-h-[80vh] overflow-y-auto">
              <div className="sticky top-0 bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center">
                <h3 className="text-xl font-bold text-white">Event Preview</h3>
                <button
                  onClick={() => setShowPreview(false)}
                  className="text-white hover:bg-white/20 rounded-lg p-2 transition"
                >
                  <X size={24} />
                </button>
              </div>
              <div className="p-8">
                {formData.banner && (
                  <div className="w-full h-48 bg-purple-100 rounded-lg mb-6 flex items-center justify-center">
                    <Image size={48} className="text-purple-300" />
                  </div>
                )}
                <div className="mb-4">
                  <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${
                    eventTypes.find(t => t.value === formData.eventType)?.color
                  }`}>
                    {eventTypes.find(t => t.value === formData.eventType)?.label}
                  </span>
                </div>
                <h2 className="text-3xl font-bold text-gray-900 mb-4">
                  {formData.title || 'Untitled Event'}
                </h2>
                <div className="space-y-3 mb-6">
                  <div className="flex items-center gap-3 text-gray-700">
                    <Calendar size={20} className="text-purple-600" />
                    <span>
                      {formData.startDate ? new Date(formData.startDate).toLocaleDateString() : 'Date not set'} 
                      {formData.startTime && ` at ${formData.startTime}`}
                    </span>
                  </div>
                  {formData.location && (
                    <div className="flex items-center gap-3 text-gray-700">
                      <MapPin size={20} className="text-purple-600" />
                      <span>{formData.location}</span>
                    </div>
                  )}
                  {formData.maxAttendees && (
                    <div className="flex items-center gap-3 text-gray-700">
                      <Users size={20} className="text-purple-600" />
                      <span>Max {formData.maxAttendees} attendees</span>
                    </div>
                  )}
                  {formData.fee && (
                    <div className="flex items-center gap-3 text-gray-700">
                      <DollarSign size={20} className="text-purple-600" />
                      <span>${formData.fee} entry fee</span>
                    </div>
                  )}
                </div>
                <p className="text-gray-700 whitespace-pre-wrap mb-6">
                  {formData.description || 'No description added yet...'}
                </p>
                {formData.organizer && (
                  <div className="border-t pt-6">
                    <h3 className="font-semibold text-gray-900 mb-2">Contact</h3>
                    <p className="text-gray-700">Organized by: {formData.organizer}</p>
                    {formData.contactEmail && (
                      <p className="text-gray-600 text-sm">{formData.contactEmail}</p>
                    )}
                    {formData.contactPhone && (
                      <p className="text-gray-600 text-sm">{formData.contactPhone}</p>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default CreateEvent;