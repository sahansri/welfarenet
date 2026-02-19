import React, { useState, useEffect } from 'react';
import { DollarSign, Plus, Trash2, Edit2, Save, X, TrendingUp, TrendingDown, Calendar, Receipt, PieChart, AlertCircle, CheckCircle, Download,ArrowLeft, Filter, Search} from 'lucide-react';
import { useParams } from 'react-router-dom';
import axios from '../../config';

export default function EventBudget() {
  const [event, setEvent] = useState({});
  const {id} = useParams();

  const [incomeItems, setIncomeItems] = useState([
    { id: 1, category: 'Donations', description: 'Community donations', amount: 500, date: '2024-03-01' },
    { id: 2, category: 'Sponsorship', description: 'Local business sponsor', amount: 1000, date: '2024-03-05' }
  ]);

  const [expenseItems, setExpenseItems] = useState([
    { id: 1, category: 'Food & Beverages', description: 'BBQ supplies', amount: 450, date: '2024-03-10', status: 'paid' },
    { id: 2, category: 'Equipment', description: 'Table rentals', amount: 200, date: '2024-03-12', status: 'pending' }
  ]);

  const [showAddIncome, setShowAddIncome] = useState(false);
  const [showAddExpense, setShowAddExpense] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [filterCategory, setFilterCategory] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const [newIncome, setNewIncome] = useState({
    category: 'Donations',
    description: '',
    amount: '',
    date: new Date().toISOString().split('T')[0]
  });

  const [newExpense, setNewExpense] = useState({
    category: 'Food & Beverages',
    description: '',
    amount: '',
    date: new Date().toISOString().split('T')[0],
    status: 'pending'
  });

    useEffect(()=>{
        const fetchEvent =async()=>{
            console.log("Fetching event data for eventId:", id);
            setIsLoading(true);
            try{
                const token = localStorage.getItem('token');
                const response = await axios.get(`/events/${id}`, {
                    headers:{
                        Authorization: `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                })
                setEvent(response.data);
                console.log("Event Data:",response.data);
            }
            catch(error){
                console.error("Error fetching event data:", error);
            }
            finally{
                setIsLoading(false);
            }
        }
        fetchEvent();
    },[])

  const incomeCategories = ['Donations', 'Sponsorship', 'Ticket Sales', 'Registration Fees', 'Other'];
  const expenseCategories = ['Food & Beverages', 'Equipment', 'Venue', 'Decorations', 'Entertainment', 'Staff', 'Marketing', 'Other'];

  // Calculate totals
  const totalIncome = incomeItems.reduce((sum, item) => sum + item.amount, 0);
  const totalExpenses = expenseItems.reduce((sum, item) => sum + item.amount, 0);
  const netBalance = totalIncome - totalExpenses;
  const paidExpenses = expenseItems.filter(e => e.status === 'paid').reduce((sum, item) => sum + item.amount, 0);
  const pendingExpenses = expenseItems.filter(e => e.status === 'pending').reduce((sum, item) => sum + item.amount, 0);

  // Add income
  const handleAddIncome = () => {
    if (newIncome.description && newIncome.amount) {
      const income = {
        id: Date.now(),
        ...newIncome,
        amount: parseFloat(newIncome.amount)
      };
      setIncomeItems([...incomeItems, income]);
      setNewIncome({ category: 'Donations', description: '', amount: '', date: new Date().toISOString().split('T')[0] });
      setShowAddIncome(false);
    }
  };

  // Add expense
  const handleAddExpense = () => {
    if (newExpense.description && newExpense.amount) {
      const expense = {
        id: Date.now(),
        ...newExpense,
        amount: parseFloat(newExpense.amount)
      };
      setExpenseItems([...expenseItems, expense]);
      setNewExpense({ category: 'Food & Beverages', description: '', amount: '', date: new Date().toISOString().split('T')[0], status: 'pending' });
      setShowAddExpense(false);
    }
  };

  // Delete item
  const handleDeleteIncome = (id) => {
    setIncomeItems(incomeItems.filter(item => item.id !== id));
  };

  const handleDeleteExpense = (id) => {
    setExpenseItems(expenseItems.filter(item => item.id !== id));
  };

  // Toggle expense status
  const toggleExpenseStatus = (id) => {
    setExpenseItems(expenseItems.map(item => 
      item.id === id ? { ...item, status: item.status === 'paid' ? 'pending' : 'paid' } : item
    ));
  };

  // Export to CSV
  const handleExport = () => {
    const csvContent = [
      ['Event Budget Report'],
      ['Event:', event.eventName],
      ['Date:', event.date],
      [''],
      ['INCOME'],
      ['Category', 'Description', 'Amount', 'Date'],
      ...incomeItems.map(i => [i.category, i.description, i.amount, i.date]),
      ['', '', 'Total Income:', totalIncome],
      [''],
      ['EXPENSES'],
      ['Category', 'Description', 'Amount', 'Date', 'Status'],
      ...expenseItems.map(e => [e.category, e.description, e.amount, e.date, e.status]),
      ['', '', 'Total Expenses:', totalExpenses],
      [''],
      ['NET BALANCE:', '', netBalance]
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${event.eventName}_budget.csv`;
    a.click();
  };

  if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Loading events...
                </p>
            </div>
            </div>
        );
    }

  return (
    <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
      <div className="max-w-7xl mx-auto pt-32">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
            <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
          <div className="relative z-10">
            <button 
                className="flex items-center gap-2 text-white/80 hover:text-white mb-4 transition"
                onClick={() => window.history.back()}
            >
              <ArrowLeft className="w-5 h-5" />
              Back to Events
            </button>
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-4xl font-bold mb-2">Event Budget</h1>
                <p className="text-purple-100 text-lg">{event.eventName}</p>
                <p className="text-purple-200 text-sm">Date: {event.date}</p>
              </div>
              <button
                onClick={handleExport}
                className="bg-white text-purple-600 px-6 py-3 rounded-xl font-semibold hover:bg-purple-50 transition-all shadow-lg flex items-center gap-2"
              >
                <Download className="w-5 h-5" />
                Export Report
              </button>
            </div>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-2xl shadow-lg p-6 border-l-4 border-green-500">
            <div className="flex items-center justify-between mb-2">
              <p className="text-gray-600 font-medium">Total Income</p>
              <TrendingUp className="w-6 h-6 text-green-500" />
            </div>
            <p className="text-3xl font-bold text-gray-900">${totalIncome.toFixed(2)}</p>
            <p className="text-sm text-gray-500 mt-1">{incomeItems.length} transactions</p>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-l-4 border-red-500">
            <div className="flex items-center justify-between mb-2">
              <p className="text-gray-600 font-medium">Total Expenses</p>
              <TrendingDown className="w-6 h-6 text-red-500" />
            </div>
            <p className="text-3xl font-bold text-gray-900">${totalExpenses.toFixed(2)}</p>
            <p className="text-sm text-gray-500 mt-1">{expenseItems.length} items</p>
          </div>

          <div className={`bg-white rounded-2xl shadow-lg p-6 border-l-4 ${netBalance >= 0 ? 'border-blue-500' : 'border-orange-500'}`}>
            <div className="flex items-center justify-between mb-2">
              <p className="text-gray-600 font-medium">Net Balance</p>
              <DollarSign className={`w-6 h-6 ${netBalance >= 0 ? 'text-blue-500' : 'text-orange-500'}`} />
            </div>
            <p className={`text-3xl font-bold ${netBalance >= 0 ? 'text-blue-600' : 'text-orange-600'}`}>
              ${Math.abs(netBalance).toFixed(2)}
            </p>
            <p className="text-sm text-gray-500 mt-1">
              {netBalance >= 0 ? 'Surplus' : 'Deficit'}
            </p>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 border-l-4 border-purple-500">
            <div className="flex items-center justify-between mb-2">
              <p className="text-gray-600 font-medium">Pending</p>
              <AlertCircle className="w-6 h-6 text-purple-500" />
            </div>
            <p className="text-3xl font-bold text-gray-900">${pendingExpenses.toFixed(2)}</p>
            <p className="text-sm text-gray-500 mt-1">Unpaid expenses</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Income Section */}
          <div className="bg-white rounded-2xl shadow-xl p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-green-600" />
                </div>
                <h2 className="text-2xl font-bold text-gray-900">Income</h2>
              </div>
              <button
                onClick={() => setShowAddIncome(true)}
                className="bg-gradient-to-r from-green-500 to-emerald-600 text-white px-4 py-2 rounded-xl font-semibold hover:from-green-600 hover:to-emerald-700 transition-all shadow-md flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                Add Income
              </button>
            </div>

            <div className="space-y-3 max-h-96 overflow-y-auto">
              {incomeItems.length === 0 ? (
                <div className="text-center py-12">
                  <DollarSign className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500">No income recorded yet</p>
                </div>
              ) : (
                incomeItems.map((item) => (
                  <div
                    key={item.id}
                    className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 border border-green-200 hover:shadow-md transition-all"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="px-3 py-1 bg-green-200 text-green-800 text-xs font-semibold rounded-full">
                            {item.category}
                          </span>
                        </div>
                        <p className="font-semibold text-gray-900">{item.description}</p>
                        <p className="text-sm text-gray-600 mt-1">{item.date}</p>
                      </div>
                      <div className="flex items-center gap-3">
                        <p className="text-2xl font-bold text-green-600">${item.amount.toFixed(2)}</p>
                        <button
                          onClick={() => handleDeleteIncome(item.id)}
                          className="text-red-500 hover:text-red-700 transition"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Expenses Section */}
          <div className="bg-white rounded-2xl shadow-xl p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
                  <TrendingDown className="w-6 h-6 text-red-600" />
                </div>
                <h2 className="text-2xl font-bold text-gray-900">Expenses</h2>
              </div>
              <button
                onClick={() => setShowAddExpense(true)}
                className="bg-gradient-to-r from-red-500 to-red-600 text-white px-4 py-2 rounded-xl font-semibold hover:from-red-600 hover:to-red-700 transition-all shadow-md flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                Add Expense
              </button>
            </div>

            <div className="space-y-3 max-h-96 overflow-y-auto">
              {expenseItems.length === 0 ? (
                <div className="text-center py-12">
                  <Receipt className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500">No expenses recorded yet</p>
                </div>
              ) : (
                expenseItems.map((item) => (
                  <div
                    key={item.id}
                    className="bg-gradient-to-r from-red-50 to-orange-50 rounded-xl p-4 border border-red-200 hover:shadow-md transition-all"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="px-3 py-1 bg-red-200 text-red-800 text-xs font-semibold rounded-full">
                            {item.category}
                          </span>
                          <button
                            onClick={() => toggleExpenseStatus(item.id)}
                            className={`px-3 py-1 text-xs font-semibold rounded-full transition ${
                              item.status === 'paid'
                                ? 'bg-green-200 text-green-800 hover:bg-green-300'
                                : 'bg-yellow-200 text-yellow-800 hover:bg-yellow-300'
                            }`}
                          >
                            {item.status === 'paid' ? '✓ Paid' : '⏳ Pending'}
                          </button>
                        </div>
                        <p className="font-semibold text-gray-900">{item.description}</p>
                        <p className="text-sm text-gray-600 mt-1">{item.date}</p>
                      </div>
                      <div className="flex items-center gap-3">
                        <p className="text-2xl font-bold text-red-600">${item.amount.toFixed(2)}</p>
                        <button
                          onClick={() => handleDeleteExpense(item.id)}
                          className="text-red-500 hover:text-red-700 transition"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Add Income Modal */}
        {showAddIncome && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full">
              <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-t-3xl p-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-2xl font-bold text-white">Add Income</h2>
                  <button
                    onClick={() => setShowAddIncome(false)}
                    className="w-10 h-10 bg-white/20 hover:bg-white/30 rounded-xl flex items-center justify-center transition"
                  >
                    <X className="w-5 h-5 text-white" />
                  </button>
                </div>
              </div>

              <div className="p-6 space-y-4">
                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Category</label>
                  <select
                    value={newIncome.category}
                    onChange={(e) => setNewIncome({ ...newIncome, category: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    {incomeCategories.map(cat => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Description</label>
                  <input
                    type="text"
                    value={newIncome.description}
                    onChange={(e) => setNewIncome({ ...newIncome, description: e.target.value })}
                    placeholder="e.g., Community member donation"
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Amount ($)</label>
                  <input
                    type="number"
                    value={newIncome.amount}
                    onChange={(e) => setNewIncome({ ...newIncome, amount: e.target.value })}
                    placeholder="0.00"
                    step="0.01"
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Date</label>
                  <input
                    type="date"
                    value={newIncome.date}
                    onChange={(e) => setNewIncome({ ...newIncome, date: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>

                <button
                  onClick={handleAddIncome}
                  className="w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white py-4 rounded-xl font-semibold hover:from-green-600 hover:to-emerald-700 transition-all shadow-lg"
                >
                  Add Income
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Add Expense Modal */}
        {showAddExpense && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full">
              <div className="bg-gradient-to-r from-red-500 to-red-600 rounded-t-3xl p-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-2xl font-bold text-white">Add Expense</h2>
                  <button
                    onClick={() => setShowAddExpense(false)}
                    className="w-10 h-10 bg-white/20 hover:bg-white/30 rounded-xl flex items-center justify-center transition"
                  >
                    <X className="w-5 h-5 text-white" />
                  </button>
                </div>
              </div>

              <div className="p-6 space-y-4">
                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Category</label>
                  <select
                    value={newExpense.category}
                    onChange={(e) => setNewExpense({ ...newExpense, category: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500"
                  >
                    {expenseCategories.map(cat => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Description</label>
                  <input
                    type="text"
                    value={newExpense.description}
                    onChange={(e) => setNewExpense({ ...newExpense, description: e.target.value })}
                    placeholder="e.g., Food supplies for BBQ"
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Amount ($)</label>
                  <input
                    type="number"
                    value={newExpense.amount}
                    onChange={(e) => setNewExpense({ ...newExpense, amount: e.target.value })}
                    placeholder="0.00"
                    step="0.01"
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Date</label>
                  <input
                    type="date"
                    value={newExpense.date}
                    onChange={(e) => setNewExpense({ ...newExpense, date: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-2">Status</label>
                  <select
                    value={newExpense.status}
                    onChange={(e) => setNewExpense({ ...newExpense, status: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500"
                  >
                    <option value="pending">Pending</option>
                    <option value="paid">Paid</option>
                  </select>
                </div>

                <button
                  onClick={handleAddExpense}
                  className="w-full bg-gradient-to-r from-red-500 to-red-600 text-white py-4 rounded-xl font-semibold hover:from-red-600 hover:to-red-700 transition-all shadow-lg"
                >
                  Add Expense
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}