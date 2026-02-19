import React, { useState } from 'react';
import { MessageSquare, Search, Filter, Eye, Calendar, User, AlertCircle, Lightbulb, CheckCircle, Clock, XCircle, ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react';

const OldComplaints = () => {
  // Sample data
  const [items, setItems] = useState([
    { id: 1, type: 'complaint', title: 'Broken Elevator in Building A', author: 'John Doe', date: '2024-06-15', category: 'Maintenance', status: 'resolved', priority: 'high', description: 'The elevator in Building A has been out of service for 3 days.' },
    { id: 2, type: 'suggestion', title: 'Add More Security Cameras', author: 'Jane Smith', date: '2024-06-14', category: 'Security', status: 'under_review', priority: 'medium', description: 'We should install more cameras at the parking entrance.' },
    { id: 3, type: 'complaint', title: 'Noisy Neighbors at Night', author: 'Bob Johnson', date: '2024-06-13', category: 'Noise', status: 'in_progress', priority: 'medium', description: 'Unit 302 is consistently loud after 11 PM.' },
    { id: 4, type: 'suggestion', title: 'Community Garden Proposal', author: 'Alice Williams', date: '2024-06-12', category: 'Amenities', status: 'approved', priority: 'low', description: 'Create a community garden in the unused space near the pool.' },
    { id: 5, type: 'complaint', title: 'Water Leakage in Unit 205', author: 'Charlie Brown', date: '2024-06-11', category: 'Maintenance', status: 'resolved', priority: 'high', description: 'Ceiling is leaking water from the unit above.' },
    { id: 6, type: 'suggestion', title: 'Install EV Charging Stations', author: 'Diana Prince', date: '2024-06-10', category: 'Parking', status: 'under_review', priority: 'medium', description: 'Add electric vehicle charging stations in the parking area.' },
    { id: 7, type: 'complaint', title: 'Dirty Swimming Pool', author: 'Edward Norton', date: '2024-06-09', category: 'Amenities', status: 'in_progress', priority: 'medium', description: 'Pool water appears cloudy and needs cleaning.' },
    { id: 8, type: 'suggestion', title: 'Weekend Yoga Classes', author: 'Fiona Apple', date: '2024-06-08', category: 'Activities', status: 'rejected', priority: 'low', description: 'Organize free yoga classes for residents on weekends.' },
    { id: 9, type: 'complaint', title: 'Insufficient Parking Spaces', author: 'George Martin', date: '2024-06-07', category: 'Parking', status: 'under_review', priority: 'high', description: 'Not enough visitor parking spots available.' },
    { id: 10, type: 'suggestion', title: 'Recycling Program', author: 'Helen Troy', date: '2024-06-06', category: 'Environment', status: 'approved', priority: 'medium', description: 'Implement a comprehensive recycling program.' },
  ]);

  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState('desc');
  const [selectedItem, setSelectedItem] = useState(null);

  // Get unique categories
  const categories = ['all', ...new Set(items.map(item => item.category))];

  // Sorting function
  const handleSort = (field) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortOrder('asc');
    }
  };

  // Filter and sort items
  const filteredAndSortedItems = items
    .filter(item => {
      const matchesSearch = 
        item.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.author.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.description.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesType = typeFilter === 'all' || item.type === typeFilter;
      const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
      const matchesCategory = categoryFilter === 'all' || item.category === categoryFilter;
      return matchesSearch && matchesType && matchesStatus && matchesCategory;
    })
    .sort((a, b) => {
      let aValue, bValue;
      
      if (sortBy === 'date') {
        aValue = new Date(a.date);
        bValue = new Date(b.date);
      } else if (sortBy === 'title') {
        aValue = a.title.toLowerCase();
        bValue = b.title.toLowerCase();
      } else if (sortBy === 'author') {
        aValue = a.author.toLowerCase();
        bValue = b.author.toLowerCase();
      }

      if (sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

  // Calculate statistics
  const totalComplaints = items.filter(i => i.type === 'complaint').length;
  const totalSuggestions = items.filter(i => i.type === 'suggestion').length;
  const resolvedCount = items.filter(i => i.status === 'resolved').length;
  const pendingCount = items.filter(i => i.status === 'in_progress' || i.status === 'under_review').length;

  const getStatusBadge = (status) => {
    const styles = {
      resolved: 'bg-green-100 text-green-700 border-green-300',
      in_progress: 'bg-blue-100 text-blue-700 border-blue-300',
      under_review: 'bg-yellow-100 text-yellow-700 border-yellow-300',
      approved: 'bg-purple-100 text-purple-700 border-purple-300',
      rejected: 'bg-red-100 text-red-700 border-red-300'
    };
    const icons = {
      resolved: <CheckCircle size={14} />,
      in_progress: <Clock size={14} />,
      under_review: <Clock size={14} />,
      approved: <CheckCircle size={14} />,
      rejected: <XCircle size={14} />
    };
    const labels = {
      resolved: 'Resolved',
      in_progress: 'In Progress',
      under_review: 'Under Review',
      approved: 'Approved',
      rejected: 'Rejected'
    };
    
    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${styles[status]}`}>
        {icons[status]}
        {labels[status]}
      </span>
    );
  };

  const getPriorityBadge = (priority) => {
    const styles = {
      high: 'bg-red-100 text-red-700',
      medium: 'bg-orange-100 text-orange-700',
      low: 'bg-blue-100 text-blue-700'
    };
    
    return (
      <span className={`px-2 py-1 rounded text-xs font-medium ${styles[priority]}`}>
        {priority.charAt(0).toUpperCase() + priority.slice(1)}
      </span>
    );
  };

  const SortIcon = ({ field }) => {
    if (sortBy !== field) return <ArrowUpDown size={16} className="text-gray-400" />;
    return sortOrder === 'asc' ? 
      <ArrowUp size={16} className="text-purple-600" /> : 
      <ArrowDown size={16} className="text-purple-600" />;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 via-purple-500 to-purple-700 p-8">
      {/* Main Container */}
      <div className="max-w-7xl mx-auto pt-36">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-2xl p-8 mb-6 shadow-xl">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-white/20 rounded-xl flex items-center justify-center">
              <MessageSquare size={32} className="text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white mb-1">Complaints & Suggestions</h1>
              <p className="text-purple-100">View and manage community feedback</p>
            </div>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Total Items</span>
              <MessageSquare size={20} className="text-purple-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{items.length}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Complaints</span>
              <AlertCircle size={20} className="text-red-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{totalComplaints}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Suggestions</span>
              <Lightbulb size={20} className="text-yellow-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{totalSuggestions}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Resolved</span>
              <CheckCircle size={20} className="text-green-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{resolvedCount}</p>
          </div>
        </div>

        {/* Filters and Search */}
        <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
          <div className="flex flex-col gap-4">
            {/* Search Bar */}
            <div className="relative">
              <Search size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by title, author, or description..."
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              />
            </div>

            {/* Filters Row */}
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex items-center gap-2 flex-1">
                <Filter size={20} className="text-gray-600" />
                <select
                  value={typeFilter}
                  onChange={(e) => setTypeFilter(e.target.value)}
                  className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                >
                  <option value="all">All Types</option>
                  <option value="complaint">Complaints Only</option>
                  <option value="suggestion">Suggestions Only</option>
                </select>
              </div>

              <select
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              >
                <option value="all">All Categories</option>
                {categories.filter(c => c !== 'all').map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>

              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              >
                <option value="all">All Status</option>
                <option value="resolved">Resolved</option>
                <option value="in_progress">In Progress</option>
                <option value="under_review">Under Review</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
          </div>
        </div>

        {/* Items List */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Type</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('title')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Title
                      <SortIcon field="title" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('author')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Author
                      <SortIcon field="author" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Category</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('date')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Date
                      <SortIcon field="date" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Priority</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Status</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredAndSortedItems.map((item) => (
                  <tr key={item.id} className="hover:bg-purple-50 transition">
                    <td className="px-6 py-4">
                      {item.type === 'complaint' ? (
                        <div className="flex items-center gap-2 text-red-600">
                          <AlertCircle size={18} />
                          <span className="text-sm font-medium">Complaint</span>
                        </div>
                      ) : (
                        <div className="flex items-center gap-2 text-yellow-600">
                          <Lightbulb size={18} />
                          <span className="text-sm font-medium">Suggestion</span>
                        </div>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm font-semibold text-gray-900">{item.title}</p>
                      <p className="text-xs text-gray-500 mt-1 truncate max-w-xs">{item.description}</p>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-semibold text-xs">
                          {item.author.split(' ').map(n => n[0]).join('')}
                        </div>
                        {item.author}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {item.category}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      {new Date(item.date).toLocaleDateString('en-US', { 
                        year: 'numeric', 
                        month: 'short', 
                        day: 'numeric' 
                      })}
                    </td>
                    <td className="px-6 py-4">
                      {getPriorityBadge(item.priority)}
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(item.status)}
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => setSelectedItem(item)}
                        className="text-purple-600 hover:text-purple-700 transition"
                      >
                        <Eye size={18} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredAndSortedItems.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500 text-lg">No items found</p>
              <p className="text-gray-400 text-sm mt-2">Try adjusting your search or filters</p>
            </div>
          )}
        </div>
      </div>

      {/* Detail Modal */}
      {selectedItem && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-3xl w-full max-h-[80vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center rounded-t-2xl">
              <div className="flex items-center gap-3">
                {selectedItem.type === 'complaint' ? (
                  <AlertCircle size={24} className="text-white" />
                ) : (
                  <Lightbulb size={24} className="text-white" />
                )}
                <h3 className="text-xl font-bold text-white">
                  {selectedItem.type === 'complaint' ? 'Complaint Details' : 'Suggestion Details'}
                </h3>
              </div>
              <button
                onClick={() => setSelectedItem(null)}
                className="text-white hover:bg-white/20 rounded-lg p-2 transition"
              >
                <span className="text-2xl">×</span>
              </button>
            </div>
            <div className="p-8 space-y-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-4">{selectedItem.title}</h2>
                <div className="flex gap-2 mb-4">
                  {getStatusBadge(selectedItem.status)}
                  {getPriorityBadge(selectedItem.priority)}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Submitted By</p>
                  <div className="flex items-center gap-2">
                    <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-semibold">
                      {selectedItem.author.split(' ').map(n => n[0]).join('')}
                    </div>
                    <p className="text-gray-900 font-semibold">{selectedItem.author}</p>
                  </div>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Category</p>
                  <p className="text-gray-900 font-semibold">{selectedItem.category}</p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Date Submitted</p>
                  <p className="text-gray-900 font-semibold">
                    {new Date(selectedItem.date).toLocaleDateString('en-US', { 
                      year: 'numeric', 
                      month: 'long', 
                      day: 'numeric' 
                    })}
                  </p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Type</p>
                  <p className="text-gray-900 font-semibold capitalize">{selectedItem.type}</p>
                </div>
              </div>

              <div className="border-t pt-6">
                <p className="text-gray-600 text-sm font-medium mb-2">Description</p>
                <p className="text-gray-700 leading-relaxed">{selectedItem.description}</p>
              </div>

              <div className="border-t pt-6 flex gap-3">
                <button 
                  onClick={() => setSelectedItem(null)}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default OldComplaints;