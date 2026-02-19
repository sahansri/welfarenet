import React, { useState,useEffect } from 'react';
import { Users, Search, Filter, Plus, Edit2, Trash2, Eye, UserCheck, UserX, Mail, Phone, MapPin, Calendar, Shield, Key, X, ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react';
import axios from "../../config"

const UserManagement = () => {
  // Sample user data
  const [users, setUsers] = useState([]);

  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [sortBy, setSortBy] = useState('name');
  const [sortOrder, setSortOrder] = useState('asc');

  const [selectedUser, setSelectedUser] = useState(null);
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    contactNumber: '',
    houseNo: '',
    address: '',
    password:'',
    role: 'resident',
  });

  const [showAddUser,setShowAddUser] = useState(false);
  const [showViewUserModel,setShowViewUserModal] = useState(false);
  const [showEditModel,setShowEditModal] = useState(false);
  const [editingUser,setEditingUser] = useState(null);
  const [isLoading,setIsLoading] = useState(false);

  useEffect(()=>{
    setIsLoading(true);
    const fetchUsers = async()=>{
      try{
        const token = localStorage.getItem("token");
        const response = await axios.get('/member/all',{
          headers:{
            Authorization:`Bearer ${token}`
          }
        });
        console.log("Fetched users:",response.data);
        setUsers(response.data);
      }
      catch (error){
        console.error("Error fetching users:",error);
      }
      finally{
        setIsLoading(false);
      }
    }
    fetchUsers();
  },[])

  // Sorting function
  const handleSort = (field) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortOrder('asc');
    }
  };

  // Filter and sort users
  const filteredUsers = users
    .filter(user => {
      const matchesSearch = 
        user.fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.houseNo.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesRole = roleFilter === 'all' || user.role === roleFilter;
      const matchesStatus = statusFilter === 'all' || user.status === statusFilter;
      return matchesSearch && matchesRole && matchesStatus;
    })
    .sort((a, b) => {
      let aValue, bValue;
      
      if (sortBy === 'name') {
        aValue = a.fullName.toLowerCase();
        bValue = b.fullName.toLowerCase();
      } else if (sortBy === 'unit') {
        aValue = a.houseNo.toLowerCase();
        bValue = b.houseNo.toLowerCase();
      } else if (sortBy === 'joinDate') {
        aValue = new Date(a.joinDate);
        bValue = new Date(b.joinDate);
      }

      if (sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

  // Calculate statistics
  const totalUsers = users.length;
  const activeUsers = users.filter(u => u.status === 'active').length;
  const adminCount = users.filter(u => u.role === 'admin').length;
  const residentCount = users.filter(u => u.role === 'resident').length;

  const getRoleBadge = (role) => {
    const styles = {
      ADMIN: 'bg-purple-100 text-purple-700 border-purple-300',
      PRESIDENT: 'bg-blue-100 text-blue-700 border-blue-300',
      TREASURER: 'bg-green-100 text-green-700 border-green-300',
      VICE_PRESIDENT: 'bg-yellow-100 text-yellow-700 border-yellow-300',
      SECRETARY: 'bg-pink-100 text-pink-700 border-pink-300',
      MEMBER: 'bg-gray-100 text-gray-700 border-gray-300'
    };
    
    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${styles[role]}`}>
        {role === 'ADMIN' && <Shield size={12} />}
        {role.charAt(0).toUpperCase() + role.slice(1)}
      </span>
    );
  };


  const SortIcon = ({ field }) => {
    if (sortBy !== field) return <ArrowUpDown size={16} className="text-gray-400" />;
    return sortOrder === 'asc' ? 
      <ArrowUp size={16} className="text-purple-600" /> : 
      <ArrowDown size={16} className="text-purple-600" />;
  };

  const handleEditSubmit = async ()=>{
    try{
      const token = localStorage.getItem("token");
      
      const response = await axios.put(`/member/update/${editingUser.memberID}`,editingUser,{
        headers:{
          'Authorization':`Bearer ${token}`,
          'Content-Type':'application/json'
        }
      });

      const updatedUser = response.data;
      setUsers(prevUsers=>prevUsers.filter(u=>u.memberID !== updatedUser.memberID).concat(updatedUser));
      setEditingUser(null);
    }
    catch(error){
      console.error("Error updating user:",error);
    }

  }

  const handleDelete = (userId) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try{
        const token = localStorage.getItem("token");
        const response =  axios.delete(`/member/${userId}`,{
          headers:{
            'Authorization':`Bearer ${token}`,
            'Content-Type':'application/json'
          }
        });
        setUsers(users.filter(u => u.memberID !== userId));
        alert('User deleted successfully!');
      }
      catch(error){
        console.error("Error deleting user:",error);
        alert("Failed to delete user. Try again.");
      }
    }
  };

  const handleAddUser = ()=>{
    setShowAddUser(true);
  }

  const handleAddUserSubmit = async ()=>{
    try{
      const token = localStorage.getItem("token");
      const response = await axios.post('/member/add',formData,{
        headers:{
          'Authorization':`Bearer ${token}`,
          'Content-Type':'application/json'
        }
      });
      alert("User added successfully!");
      setUsers([...users,response.data]);
      setShowAddUser(false);
    }
    catch (err) {
      if (err.response?.status === 409) {
        alert(err.response.data); // "Member already exists!"
      } else {
        // Unexpected error
        console.error("Unexpected error:", err);
        alert("Something went wrong. Try again.");
      }
    }
  }

  if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Loading User Information...
                </p>
            </div>
            </div>
        );
    }


  return (
    <div className="min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-8">
      {/* Main Container */}
      <div className="max-w-7xl mx-auto pt-34">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900  to-purple-800 rounded-2xl p-8 mb-6 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-white rounded-xl flex items-center justify-center">
                <Users size={32} className="text-purple-900" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-white mb-1">User Management</h1>
                <p className="text-purple-100">Manage community members and their access</p>
              </div>
            </div>
            <button 
              className="flex items-center gap-2 px-6 py-3 bg-white text-purple-600 rounded-lg hover:bg-purple-100 transition font-medium trnsform hover:scale-[1.05] shadow-lg"
              onClick={() => handleAddUser()}
            >
              <Plus size={18} />
              Add User
            </button>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Total Users</span>
              <Users size={20} className="text-purple-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{totalUsers}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Active Users</span>
              <UserCheck size={20} className="text-green-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{activeUsers}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Admins</span>
              <Shield size={20} className="text-purple-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{adminCount}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Residents</span>
              <Users size={20} className="text-blue-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{residentCount}</p>
          </div>
        </div>

        {/* Filters and Search */}
        <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search Bar */}
            <div className="flex-1">
              <div className="relative">
                <Search size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search by name, email, or unit..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                />
              </div>
            </div>

            {/* Role Filter */}
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-600" />
              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              >
                <option value="all">All Roles</option>
                <option value="admin">Admin</option>
                <option value="committee">Committee</option>
                <option value="resident">Resident</option>
              </select>
            </div>

            {/* Status Filter */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>

        {/* Users Table */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('name')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Name
                      <SortIcon field="name" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Email</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Phone</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('unit')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Unit
                      <SortIcon field="unit" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Role</span>
                  </th>
                  
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('joinDate')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Join Date
                      <SortIcon field="joinDate" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredUsers.map((user) => (
                  <tr key={user.memberID} className="hover:bg-purple-50 transition">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-semibold text-sm">
                          {user.fullName.split(' ').map(n => n[0]).join('')}
                        </div>
                        <span className="text-sm font-semibold text-gray-900">{user.fullName}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {user.email}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {user.contactNumber}
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-gray-900">
                      {user.houseNo}
                    </td>
                    <td className="px-6 py-4">
                      {user?.role? getRoleBadge(user.role):null}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {new Date(user.joinDate).toLocaleDateString('en-US', { 
                        year: 'numeric', 
                        month: 'short', 
                        day: 'numeric' 
                      })}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => {
                              setShowViewUserModal(true)
                              setSelectedUser(user)
                            }}
                          className="text-blue-600 hover:text-blue-700 transition p-1"
                          title="View Details"
                        >
                          <Eye size={18} />
                        </button>
                        <button
                          onClick={() =>{
                            setShowEditModal(true)
                            setEditingUser(user)
                            console.log("Editing user:",user);
                          }}
                          className="text-purple-600 hover:text-purple-700 transition p-1"
                          title="Edit User"
                        >
                          <Edit2 size={18} />
                        </button>

                        <button
                          onClick={() => handleDelete(user.memberID)}
                          className="text-red-600 hover:text-red-700 transition p-1"
                          title="Delete User"
                        >
                          <Trash2 size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredUsers.length === 0 && (
            <div className="text-center py-12">
              <Users size={64} className="mx-auto text-gray-300 mb-4" />
              <p className="text-gray-500 text-lg">No users found</p>
              <p className="text-gray-400 text-sm mt-2">Try adjusting your search or filters</p>
            </div>
          )}
        </div>
      </div>

      {/*Edit User Model*/}
      {showEditModel && editingUser !==null &&(
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center rounded-t-2xl">
              <h3 className="text-xl font-bold text-white">
                Edit User
              </h3>
              <button
                onClick={()=>{setShowEditModal(false)}}
                className="text-white hover:bg-white/20 rounded-lg p-2 transition"
              >
                <X size={24} />
              </button>
            </div>
            <div className="p-8 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    value={editingUser.fullName?editingUser.fullName:''}
                    onChange={(e) => setEditingUser({ ...editingUser, fullName: e.target.value })}
                    placeholder="Enter full name"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Email *
                  </label>
                  <input
                    type="email"
                    value={editingUser.email?editingUser.email:''}
                    onChange={(e) => setEditingUser({ ...editingUser, email: e.target.value })}
                    placeholder="email@example.com"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Phone *
                  </label>
                  <input
                    type="tel"
                    value={editingUser.contactNumber?editingUser.contactNumber:''}
                    onChange={(e) => setEditingUser({ ...editingUser, contactNumber: e.target.value })}
                    placeholder="+1 (555) 000-0000"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Unit *
                  </label>
                  <input
                    type="text"
                    value={editingUser.houseNo?editingUser.houseNo:''}
                    onChange={(e) => setEditingUser({ ...editingUser, houseNo: e.target.value })}
                    placeholder="A-101"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Role *
                  </label>
                  <select
                    value={editingUser.role?editingUser.role:''}
                    onChange={(e) => setEditingUser({ ...editingUser, role: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  >
                    <option value="MEMBER">Member</option>
                    <option value="PRESIDENT">President</option>
                    <option value="TREASURER">Tresurer</option>
                    <option value="VICE_PRESIDENT">Vice President</option>
                    <option value="SECRETARY">Secretary</option>
                    <option value="ADMIN">Admin</option>
                  </select>
                </div>

              </div>

              <div className="border-t pt-6 flex gap-3">
                <button
                  onClick={()=>{setShowEditModal(false)}}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
                >
                  Cancel
                </button>
                <button
                  onClick={handleEditSubmit}
                  className="flex-1 px-6 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium"
                >
                  Save Changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )} 

      {/*view User Model*/}
      {showViewUserModel&&(
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center rounded-t-2xl">
              <h3 className="text-xl font-bold text-white">
                View User Information
              </h3>
              <button
                onClick={()=>{setShowViewUserModal(false)}}
                className="text-white hover:bg-white/20 rounded-lg p-2 transition"
              >
                <X size={24} />
              </button>
            </div>

            <div className="p-8 space-y-6">
                <div className="text-center mb-6">
                  <div className="w-24 h-24 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-bold text-3xl mx-auto mb-4">
                    {selectedUser.fullName.split(' ').map(n => n[0]).join('')}
                  </div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-2">{selectedUser.fullName}</h2>
                  <div className="flex gap-2 justify-center">
                    {selectedUser?.role?getRoleBadge(selectedUser.role):null}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-6">
                  <div>
                    <p className="text-gray-600 text-sm font-medium mb-1">Email</p>
                    <p className="text-gray-900 font-semibold">{selectedUser.email}</p>
                  </div>
                  <div>
                    <p className="text-gray-600 text-sm font-medium mb-1">Phone</p>
                    <p className="text-gray-900 font-semibold">{selectedUser.contactNumber}</p>
                  </div>
                  <div>
                    <p className="text-gray-600 text-sm font-medium mb-1">Unit</p>
                    <p className="text-gray-900 font-semibold">{selectedUser.houseNo}</p>
                  </div>
                  <div>
                    <p className="text-gray-600 text-sm font-medium mb-1">Join Date</p>
                    <p className="text-gray-900 font-semibold">
                      {new Date(selectedUser.joinDate).toLocaleDateString('en-US', { 
                        year: 'numeric', 
                        month: 'long', 
                        day: 'numeric' 
                      })}
                    </p>
                  </div>
                </div>

                <div className="border-t pt-6 flex gap-3">
                  <button
                    onClick={ console.log("Edit user")}
                    className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition font-medium"
                  >
                    Edit User
                  </button>
                  <button
                    onClick={()=>{setShowViewUserModal(false)}}
                    className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
                  >
                    Close
                  </button>
                </div>
              </div>
              
          </div>
        </div>
        
      )}

      {/*Add User Model*/}
      {showAddUser&&(
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center rounded-t-2xl">
              <h3 className="text-xl font-bold text-white">
                Add New User
              </h3>
              <button
                onClick={()=>{setShowAddUser(false)}}
                className="text-white hover:bg-white/20 rounded-lg p-2 transition"
              >
                <X size={24} />
              </button>
            </div>
            
            <div className="p-8 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    value={formData.fullName}
                    onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                    placeholder="Enter full name"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Email *
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    placeholder="email@example.com"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Contact No. *
                  </label>
                  <input
                    type="tel"
                    value={formData.contactNumber}
                    onChange={(e) => setFormData({ ...formData, contactNumber: e.target.value })}
                    placeholder="+94 45 2200000"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    House No. *
                  </label>
                  <input
                    type="text"
                    value={formData.houseNo}
                    onChange={(e) => setFormData({ ...formData, houseNo: e.target.value })}
                    placeholder="40/A"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Address *
                  </label>
                  <input
                    type="text"
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    placeholder="40/A"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Role *
                  </label>
                  <select
                    value={formData.role}
                    onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  >
                    <option value="MEMBER">Member</option>
                    <option value="PRESIDENT">President</option>
                    <option value="TREASURER">Tresurer</option>
                    <option value="VICE_PRESIDENT">Vice President</option>
                    <option value="SECRETARY">Secretary</option>
                    <option value="ADMIN">Admin</option>
                   
                  </select>
                </div>

                 <div>
                  <label className="block text-gray-700 font-semibold mb-2">
                    Password *
                  </label>
                  <input
                    type="text"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    placeholder="1234@gh"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  />
                </div>
              </div>

              <div className="border-t pt-6 flex gap-3">
                <button
                  onClick={()=>{setShowAddUser(false)}}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition font-medium"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddUserSubmit}
                  className="flex-1 px-6 py-3 bg-gradient-to-r from-purple-600 to-purple-500 text-white rounded-lg hover:from-purple-700 hover:to-purple-600 transition font-medium"
                >
                  Add User
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UserManagement;