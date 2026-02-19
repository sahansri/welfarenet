import React, { useState } from 'react';
import { UserPlus, Edit2, Trash2, Save, X, Mail, Phone, Calendar, Search, Users } from 'lucide-react';


export default function MemberDetails() {
  const [members, setMembers] = useState([
    { id: 1, name: 'Alice Johnson', email: 'alice@example.com', phone: '555-0101', joinDate: '2024-01-15', status: 'Active' },
    { id: 2, name: 'Bob Smith', email: 'bob@example.com', phone: '555-0102', joinDate: '2024-02-20', status: 'Active' },
    { id: 3, name: 'Carol Williams', email: 'carol@example.com', phone: '555-0103', joinDate: '2024-03-10', status: 'Inactive' }
  ]);


  
  const [editingId, setEditingId] = useState(null);
  const [isAdding, setIsAdding] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    joinDate: '',
    status: 'Active'
  });

  const filteredMembers = members.filter(member =>
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleEdit = (member) => {
    setEditingId(member.id);
    setFormData(member);
    setIsAdding(false);
  };

  const handleDelete = (id) => {
    if (window.confirm('Are you sure you want to delete this member?')) {
      setMembers(members.filter(m => m.id !== id));
    }
  };

  const handleSave = () => {
    if (editingId) {
      setMembers(members.map(m => m.id === editingId ? { ...formData, id: editingId } : m));
      setEditingId(null);
    } else {
      const newMember = { ...formData, id: Date.now() };
      setMembers([...members, newMember]);
      setIsAdding(false);
    }
    resetForm();
  };

  const handleCancel = () => {
    setEditingId(null);
    setIsAdding(false);
    resetForm();
  };

  const resetForm = () => {
    setFormData({ name: '', email: '', phone: '', joinDate: '', status: 'Active' });
  };

  const handleAdd = () => {
    setIsAdding(true);
    setEditingId(null);
    resetForm();
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-8 pt-36">
      {/* Sidebar (extracted to reusable component) */}
        {/* Main Content */}
      <div className={`transition-all duration-300 ${sidebarOpen ? "ml-64" : "ml-18"}`}>
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <Users className="text-purple-400" size={32} />
            <h1 className="text-4xl font-bold text-white">Member Management</h1>
          </div>
          <p className="text-purple-200">Manage your team members and their information</p>
        </div>

        {/* Controls Bar */}
        <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 mb-6 border border-white/20">
          <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
            <div className="relative flex-1 w-full md:max-w-md">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-purple-300" size={20} />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search members..."
                className="w-full pl-11 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              />
            </div>
            <button
              onClick={handleAdd}
              className="flex items-center gap-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-6 py-3 rounded-xl hover:from-purple-600 hover:to-pink-600 transition shadow-lg shadow-purple-500/50 font-medium"
            >
              <UserPlus size={20} />
              Add Member
            </button>
          </div>
        </div>

        {/* Form Modal */}
        {(isAdding || editingId) && (
          <div className="bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-xl rounded-2xl p-8 mb-6 border border-white/20 shadow-2xl">
            <h2 className="text-2xl font-bold mb-6 text-white">
              {isAdding ? '✨ Add New Member' : '✏️ Edit Member'}
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-purple-200 mb-2">Full Name</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="John Doe"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-purple-200 mb-2">Email Address</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="john@example.com"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-purple-200 mb-2">Phone Number</label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="555-0100"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-purple-200 mb-2">Join Date</label>
                <input
                  type="date"
                  value={formData.joinDate}
                  onChange={(e) => setFormData({ ...formData, joinDate: e.target.value })}
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-purple-200 mb-2">Status</label>
                <select
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                >
                  <option value="Active" className="bg-slate-800">Active</option>
                  <option value="Inactive" className="bg-slate-800">Inactive</option>
                </select>
              </div>
            </div>
            <div className="flex gap-4 mt-6">
              <button
                onClick={handleSave}
                className="flex items-center gap-2 bg-gradient-to-r from-green-500 to-emerald-500 text-white px-6 py-3 rounded-xl hover:from-green-600 hover:to-emerald-600 transition shadow-lg shadow-green-500/50 font-medium"
              >
                <Save size={18} />
                Save Changes
              </button>
              <button
                onClick={handleCancel}
                className="flex items-center gap-2 bg-white/10 border border-white/20 text-white px-6 py-3 rounded-xl hover:bg-white/20 transition font-medium"
              >
                <X size={18} />
                Cancel
              </button>
            </div>
          </div>
        )}

        {/* Members Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredMembers.map((member) => (
            <div key={member.id} className="group bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-xl rounded-2xl p-6 border border-white/20 hover:border-purple-400/50 transition shadow-xl hover:shadow-purple-500/20">
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg">
                    {member.name.charAt(0)}
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-white">{member.name}</h3>
                    <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold mt-1 ${
                      member.status === 'Active' 
                        ? 'bg-green-500/20 text-green-300 border border-green-400/30' 
                        : 'bg-gray-500/20 text-gray-300 border border-gray-400/30'
                    }`}>
                      {member.status}
                    </span>
                  </div>
                </div>
              </div>
              
              <div className="space-y-3 mb-4">
                <div className="flex items-center gap-2 text-purple-200">
                  <Mail size={16} className="text-purple-400" />
                  <span className="text-sm">{member.email}</span>
                </div>
                <div className="flex items-center gap-2 text-purple-200">
                  <Phone size={16} className="text-purple-400" />
                  <span className="text-sm">{member.phone}</span>
                </div>
                <div className="flex items-center gap-2 text-purple-200">
                  <Calendar size={16} className="text-purple-400" />
                  <span className="text-sm">Joined {member.joinDate}</span>
                </div>
              </div>

              <div className="flex gap-2 pt-4 border-t border-white/10">
                <button
                  onClick={() => handleEdit(member)}
                  className="flex-1 flex items-center justify-center gap-2 bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg transition font-medium"
                >
                  <Edit2 size={16} />
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(member.id)}
                  className="flex items-center justify-center gap-2 bg-red-500/20 hover:bg-red-500/30 text-red-300 px-4 py-2 rounded-lg transition border border-red-400/30 font-medium"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
        </div>

        {filteredMembers.length === 0 && (
          <div className="text-center py-16 bg-white/5 backdrop-blur-lg rounded-2xl border border-white/20">
            <Users size={48} className="mx-auto text-purple-400 mb-4" />
            <p className="text-purple-200 text-lg">
              {searchTerm ? 'No members found matching your search.' : 'No members yet. Click "Add Member" to get started.'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}