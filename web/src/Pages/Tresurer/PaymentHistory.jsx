import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { History, Search, Filter, Download, Eye,AlertTriangle,RefreshCcw ,Calendar, DollarSign, User, ArrowUpDown, ArrowUp, ArrowDown, CheckCircle, XCircle, Clock } from 'lucide-react';
import axios from '../../config';

const PaymentHistory = () => {
  const token = localStorage.getItem('token');

  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState('desc');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedPayment, setSelectedPayment] = useState(null);

  const fetchPaymentHistory = async ()=>{
    try{
        const response = await axios.get('/payment/getAll',{
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        console.log("Payment history fetched successfully:", response.data);
        return response.data;

    }
    catch(error){
        console.log("Error occured while fetching payment history:", error);
        return [];
    }
  }


  const{
    data:payments=[],
    isLoading:isPaymentsLoading,
    isError:isPaymentsError,
    error:paymentsError,
    refetch:refetchPayments
  }=useQuery({
    queryKey:['paymentHistory'],
    queryFn:fetchPaymentHistory,
    staleTime:6*60*1000, //6minutes
    cacheTime:30*60*1000, //30minutes
  });

  // Sorting function
  const handleSort = (field) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortOrder('asc');
    }
  };

  // Filter and sort payments
  const filteredAndSortedPayments = payments
    .filter(payment => {
      const matchesSearch = 
        payment.member?.fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (payment.reference?.toLowerCase()||'N/A').includes(searchTerm.toLowerCase()) ||
        payment.paymentType.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesStatus = statusFilter === 'all' || payment.paymentStatus === statusFilter;
      return matchesSearch && matchesStatus;
    })
    .sort((a, b) => {
      let aValue, bValue;
      
      if (sortBy === 'date') {
        aValue = new Date(a.paymentDate);
        bValue = new Date(b.paymentDate);
      } else if (sortBy === 'amount') {
        aValue = a.amount;
        bValue = b.amount;
      } else if (sortBy === 'payee') {
        aValue = a.payee.toLowerCase();
        bValue = b.payee.toLowerCase();
      }

      if (sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

  // Calculate statistics
  const totalAmount = payments.reduce((sum, p) => sum + p.amount, 0);
  const approvedCount = payments.filter(p => p.paymentStatus === 'APPROVED').length;
  const pendingCount = payments.filter(p => p.paymentStatus === 'PENDING').length;
  const rejectedCount = payments.filter(p => p.paymentStatus === 'REJECTED').length;

  const getStatusBadge = (status) => {
    const styles = {
      APPROVED: 'bg-green-100 text-green-700 border-green-300',
      PENDING: 'bg-yellow-100 text-yellow-700 border-yellow-300',
      REJECTED: 'bg-red-100 text-red-700 border-red-300'
    };
    const icons = {
      APPROVED: <CheckCircle size={14} />,
      PENDING: <Clock size={14} />,
      REJECTED: <XCircle size={14} />
    };
    
    return (
      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium border ${styles[status]}`}>
        {icons[status]}
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </span>
    );
  };

  const SortIcon = ({ field }) => {
    if (sortBy !== field) return <ArrowUpDown size={16} className="text-gray-400" />;
    return sortOrder === 'asc' ? 
      <ArrowUp size={16} className="text-purple-600" /> : 
      <ArrowDown size={16} className="text-purple-600" />;
  };

  if (isPaymentsError){
        return (
            <div className="min-h-screen flex flex-col items-center justify-center pt-32  py-12 text-center">
            <AlertTriangle className="h-10 w-10 text-red-500 mb-4" />
            <h2 className="text-lg font-semibold text-gray-800">
                Something went wrong
            </h2>
            <p className="text-sm text-gray-600 mt-2 max-w-sm">
                {paymentsError?.message || "We couldn’t load the data. Please try again."}
            </p>
            <button
                onClick={() => refetchPayments()}
                className="mt-6 inline-flex items-center gap-2 rounded-lg bg-red-500 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 transition"
            >
                <RefreshCcw size={16} />
                Retry
            </button>
            </div>
        );
    }

  if (isPaymentsLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Loading Payments History...
                </p>
            </div>
            </div>
        );
    }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 via-purple-500 to-purple-700 p-8">
      {/* Main Container */}
      <div className="max-w-7xl mx-auto pt-36">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900 to-purple-800 to-purple-600 rounded-2xl p-8 mb-6 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-white rounded-xl flex items-center justify-center">
                <History size={32} className="text-purple-900" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-white mb-1">Payment History</h1>
                <p className="text-purple-100">View and manage all payment transactions</p>
              </div>
            </div>
            <button className="flex items-center gap-2 px-6 py-3 bg-white text-purple-600 rounded-lg hover:bg-purple-50 transition font-medium shadow-lg">
              <Download size={18} />
              Export
            </button>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Total Payments</span>
              <DollarSign size={20} className="text-purple-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{payments.length}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Total Amount</span>
              <DollarSign size={20} className="text-green-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">${totalAmount.toFixed(2)}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Approved</span>
              <CheckCircle size={20} className="text-green-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{approvedCount}</p>
          </div>
          <div className="bg-white rounded-xl p-6 shadow-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 text-sm font-medium">Pending</span>
              <Clock size={20} className="text-yellow-600" />
            </div>
            <p className="text-3xl font-bold text-gray-900">{pendingCount}</p>
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
                  placeholder="Search by payee, reference, or type..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                />
              </div>
            </div>

            {/* Status Filter */}
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-600" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              >
                <option value="all">All Status</option>
                <option value="approved">Approved</option>
                <option value="pending">Pending</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
          </div>
        </div>

        {/* Payment Table */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
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
                    <span className="text-sm font-semibold text-gray-700">Reference</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('payee')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Payee
                      <SortIcon field="payee" />
                    </button>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <span className="text-sm font-semibold text-gray-700">Type</span>
                  </th>
                  <th className="px-6 py-4 text-left">
                    <button
                      onClick={() => handleSort('amount')}
                      className="flex items-center gap-2 text-sm font-semibold text-gray-700 hover:text-purple-600 transition"
                    >
                      Amount
                      <SortIcon field="amount" />
                    </button>
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
                {filteredAndSortedPayments.map((payment) => (
                  <tr key={payment.paymentId} className="hover:bg-purple-50 transition">
                    <td className="px-6 py-4 text-sm text-gray-900">
                      {new Date(payment.paymentDate).toLocaleDateString('en-US', { 
                        year: 'numeric', 
                        month: 'short', 
                        day: 'numeric' 
                      })}
                    </td>
                    <td className="px-6 py-4 text-sm font-medium text-gray-900">
                      {payment.reference || "N/A"}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 font-semibold text-xs">
                          {payment.member?.fullName.split(' ').map(n => n[0]).join('')}
                        </div>
                        {payment.member?.fullName}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {payment.paymentType || "N/A"}
                    </td>
                    <td className="px-6 py-4 text-sm font-semibold text-gray-900">
                      LKR.{payment.amount.toFixed(2)}
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(payment.paymentStatus)}
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => setSelectedPayment(payment)}
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

          {filteredAndSortedPayments.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500 text-lg">No payments found</p>
              <p className="text-gray-400 text-sm mt-2">Try adjusting your search or filters</p>
            </div>
          )}
        </div>
      </div>

      {/* Payment Detail Modal */}
      {selectedPayment && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full">
            <div className="bg-gradient-to-r from-purple-600 to-purple-500 p-6 flex justify-between items-center rounded-t-2xl">
              <h3 className="text-xl font-bold text-white">Payment Details</h3>
              <button
                onClick={() => setSelectedPayment(null)}
                className="text-white hover:bg-white/20 rounded-lg p-2 transition"
              >
                <span className="text-2xl">x</span>
              </button>
            </div>
            <div className="p-8 space-y-6">
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Reference Number</p>
                  <p className="text-gray-900 font-semibold">{selectedPayment.reference || "N/A"}</p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Status</p>
                  {getStatusBadge(selectedPayment.paymentStatus)}
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Payee</p>
                  <p className="text-gray-900 font-semibold">{selectedPayment.member?.fullName || "N/A"}</p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Payment Type</p>
                  <p className="text-gray-900 font-semibold">{selectedPayment.paymentType || "N/A"}</p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Date</p>
                  <p className="text-gray-900 font-semibold">
                    {new Date(selectedPayment.paymentDate).toLocaleDateString('en-US', { 
                      year: 'numeric', 
                      month: 'long', 
                      day: 'numeric' 
                    })}
                  </p>
                </div>
                <div>
                  <p className="text-gray-600 text-sm font-medium mb-1">Amount</p>
                  <p className="text-gray-900 font-bold text-2xl">LKR.{selectedPayment.amount.toFixed(2)}</p>
                </div>
              </div>
              <div className="border-t pt-6 flex gap-3">
                <button className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition font-medium">
                  Download Receipt
                </button>
                <button 
                  onClick={() => setSelectedPayment(null)}
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

export default PaymentHistory;