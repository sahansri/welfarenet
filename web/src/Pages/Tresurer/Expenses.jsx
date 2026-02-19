import React from 'react'
import { Receipt, Eye, Megaphone, Plus, DollarSign, Calendar, Wallet, FileText, Edit2, Trash2,Upload,Save, CalendarDays } from 'lucide-react'
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery,QueryClient } from '@tanstack/react-query';
import axios from '../../config';

export default function Expenses() {
    const queryClient = new QueryClient();
    const navigate = useNavigate();
    const token = localStorage.getItem('token');
   
    const [showEditModel,setShowEditModel] = useState(false);
    const [editingExpense,setEditingExpense] = useState([
        {
            event: '',
            amount: '',
            title:'',
            expenseType:'',
            description: '',
            paymentDate: '',
            receiptFile: null,
            receiptPreview: null
        }
    ]);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [deleteId, setDeleteId] = useState(null);

    const fetchExpenses = async ()=>{
        try{
            const response = await axios.get('/expenses/all', {
                headers:{
                    'Authorization': `Bearer ${token}`,
                    'Content-Type' : 'application/json' 
                }
            });
            console.log("Fetched expenses:",response.data);
            return response.data;
        }
        catch(error){
            console.log("Error fetching Expenses!",error);
            return [];
        }
    }


    const {
        data:expenses=[],
        isLoading,
        isError,
        error,
        refetch
    } = useQuery({
        queryKey: ["expenses"],
        queryFn:fetchExpenses,
        staleTime: 5*60*1000, //fetch after 5mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    })


    const handleViewReceipt = (expenseId) => {
        console.log("View Receipt clicked for expense ID:", expenseId);
        alert(`View receipt for expense ${expenseId}`);
    }

    const handleEdit = (expense) => {
        setShowEditModel(true);
        setEditingExpense(expense);
    }

    const handleDeleteClick = (expenseId) => {
        setDeleteId(expenseId);
        setShowDeleteModal(true);
    }

    const confirmDelete = async () => {
        try{
            const response = await axios.delete(`/expenses/delete/${deleteId}`,{
                headers:{
                    'Authorization': `Bearer ${token}`,
                    'Content-Type' : 'application/json' 
                }
            });
            console.log("Delete response:",response.data);
            refetch();
        }  
        catch (error){
            console.error("Error deleting expense:", error);
        }
        finally{
            setShowDeleteModal(false);
            setDeleteId(null);
        }
    }

    const handleRemoveFile = ()=>{
        alert("Remove file button clicked!");
    }

    const cancelDelete = () => {
        setShowDeleteModal(false);
        setDeleteId(null);
    }

    const handleSubmit = async ()=>{
        try{
            const token = localStorage.getItem('token');
            const response = await axios.put(`/expenses/update/${editingExpense.expenseId}`,editingExpense,{
                headers:{
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": 'application/json'
                }
            });
            console.log("Submit response:",response.data);
            if(response.status === 200){
                alert("Expense added successfully!");
                setShowEditModel(false);
                setEditingExpense(null);
                refetch();
            }
        }
        catch(error){
            console.error("Error adding expense:", error);
        }
    }

    const handleAddExpensesRecord = () => {
        navigate('/treasurer/expenses/add');
    }

    const getTotalExpenses = () => {
        return expenses.reduce((sum, expense) => sum + parseFloat(expense.cost), 0);
    }

     if (isError){
            return (
                <div className="min-h-screen flex flex-col items-center justify-center py-12 text-center">
                <AlertTriangle className="h-10 w-10 text-red-500 mb-4" />
                <h2 className="text-lg font-semibold text-gray-800">
                    Something went wrong
                </h2>
                <p className="text-sm text-gray-600 mt-2 max-w-sm">
                    {error?.message || "We couldn’t load the data. Please try again."}
                </p>
                <button
                    onClick={refetch}
                    className="mt-6 inline-flex items-center gap-2 rounded-lg bg-red-500 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 transition"
                >
                    <RefreshCcw size={16} />
                    Retry
                </button>
                </div>
            );
        }
    
        if (isLoading) {
            return (
                <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
                <div className="text-center">
                    <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                    <p className="mt-4 text-gray-700 font-medium">
                    Loading Expenses...
                    </p>
                </div>
                </div>
            );
        }
    

    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-5xl mx-auto p-4">
                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
                            
                            <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                                <div>
                                    <div className="flex items-center gap-4 mb-3">
                                        <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                            <Wallet className="w-8 h-8 text-purple-900" />
                                        </div>
                                        <div>
                                            <h1 className="text-4xl font-bold tracking-tight">Expenses</h1>
                                        </div>
                                    </div>
                                    <p className="text-purple-100 text-lg mb-4">View and manage all outgoing payments</p>
                                </div>
                                <button
                                    onClick={handleAddExpensesRecord}
                                    className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                                >
                                    <Plus className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                                    Add Expense Record
                                </button>
                            </div>
                        </div>

                        {/* Expenses List */}
                        <div className="space-y-6">
                            {expenses.length === 0 ? (
                                <div className="bg-white rounded-2xl shadow-md p-12 text-center">
                                    <Wallet className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                    <h3 className="text-xl font-semibold text-gray-700 mb-2">No Expenses Yet</h3>
                                    <p className="text-gray-500 mb-6">Start tracking expenses to manage your community finances</p>
                                    <button
                                        onClick={handleAddExpensesRecord}
                                        className="bg-gradient-to-r from-purple-600 to-blue-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-blue-700 transition-all shadow-md"
                                    >
                                        Add First Expense
                                    </button>
                                </div>
                            ) : (
                                expenses.map((expense) => {
                                    return (
                                        <div
                                            key={expense.expenseId}
                                            className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transform hover:scale-[1.01] transition-all duration-300 overflow-hidden border border-gray-100"
                                        >
                                            {/* Colorful Top Border */}
                                            <div className="h-2 bg-gradient-to-r from-orange-500 via-red-500 to-pink-500"></div>
                                            
                                            <div className="p-6 md:p-8">
                                                {/* Expense Header */}
                                                <div className="mb-6">
                                                    <div className="flex items-start justify-between gap-4 mb-4">
                                                        <div className="flex-1">
                                                            <div className="flex items-center gap-3 mb-3">
                                                                <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-red-500 rounded-2xl flex items-center justify-center shadow-lg">
                                                                    <Receipt className="w-6 h-6 text-white" />
                                                                </div>
                                                                <div>
                                                                    <h2 className="text-2xl font-bold text-gray-900 leading-tight">
                                                                        {expense.title}
                                                                    </h2>
                                                                    <p className="text-sm text-gray-500 mt-1">Submitted on {expense.createdDate}</p>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div className="text-right">
                                                            <p className="text-sm text-gray-500 mb-1">Amount</p>
                                                            <p className="text-3xl font-bold text-red-600">
                                                                LKR {parseFloat(expense.amount).toLocaleString()}
                                                            </p>
                                                        </div>
                                                    </div>

                                                    {/* Expense Details Grid */}
                                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-gradient-to-br from-orange-50 via-red-50 to-pink-50 rounded-2xl p-5 border border-orange-100">
                                                        
                                                        <div className="flex items-center gap-3">
                                                            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                                <CalendarDays className="w-5 h-5 text-orange-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Event</p>
                                                                <p className="text-sm font-semibold text-gray-900">{expense.event.eventName}</p>
                                                            </div>
                                                        </div>
                                                        
                                                        <div className="flex items-center gap-3">
                                                            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                                <Calendar className="w-5 h-5 text-orange-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Payment Date</p>
                                                                <p className="text-sm font-semibold text-gray-900">{expense.paymentDate}</p>
                                                            </div>
                                                        </div>
                                                        
                                                        <div className="flex items-center gap-3">
                                                            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                                <FileText className="w-5 h-5 text-red-600" />
                                                            </div>
                                                            <div>
                                                                <p className="text-xs text-gray-500 font-medium">Has Receipt</p>
                                                                <p className="text-sm font-semibold text-gray-900">
                                                                    {expense.image ? 'Yes' : 'No'}
                                                                </p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Expense Reason */}
                                                <div className="mb-6">
                                                    <h3 className="text-sm font-semibold text-gray-700 mb-2 uppercase tracking-wide">Reason</h3>
                                                    <p className="text-gray-700 leading-relaxed bg-gray-50 rounded-xl p-4 border border-gray-100">
                                                        {expense.description}
                                                    </p>
                                                </div>

                                                {/* Action Buttons */}
                                                <div className="flex flex-wrap gap-3 pt-6 border-t border-gray-200">
                                                    {expense.image && (
                                                        <button
                                                            onClick={() => handleViewReceipt(expense.expenseId)}
                                                            className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-purple-500 to-blue-500 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-purple-600 hover:to-blue-600 transform hover:scale-105 transition-all duration-300"
                                                        >
                                                            <Eye className="w-4 h-4" />
                                                            <span>View Receipt</span>
                                                        </button>
                                                    )}
                                                    <button
                                                        onClick={() => handleEdit(expense)}
                                                        className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-blue-600 hover:to-blue-700 transform hover:scale-105 transition-all duration-300"
                                                    >
                                                        <Edit2 className="w-4 h-4" />
                                                        <span>Edit</span>
                                                    </button>
                                                    <button
                                                        onClick={() => handleDeleteClick(expense.expenseId)}
                                                        className="flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl font-semibold shadow-md hover:shadow-lg hover:from-red-600 hover:to-red-700 transform hover:scale-105 transition-all duration-300"
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                        <span>Delete</span>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    );
                                })
                            )}
                        </div>
                    </div>
                </main>

                {/* Delete Confirmation Modal */}
                {showDeleteModal && (
                    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                        <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
                            <div className="flex items-center gap-3 mb-4">
                                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                                    <Trash2 className="w-6 h-6 text-red-600" />
                                </div>
                                <h3 className="text-xl font-bold text-gray-900">Delete Expense</h3>
                            </div>
                            <p className="text-gray-600 mb-6">
                                Are you sure you want to delete this expense record? This action cannot be undone.
                            </p>
                            <div className="flex gap-3 justify-end">
                                <button
                                    onClick={cancelDelete}
                                    className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={confirmDelete}
                                    className="px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all font-medium"
                                >
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/*Expenses Edit Model*/}
                {showEditModel && editingExpense &&(
                    <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-[999] p-4">
                        <div className="bg-white rounded-2xl shadow-xl overflow-auto max-h-[90vh] w-full max-w-5xl p-6">
                            <div className="bg-white rounded-2xl shadow-xl overflow-hidden p-8">
                                <div className="space-y-6">
                                    {/* Expense Type */}
                                    <div>
                                        <label className="block text-gray-700 font-semibold mb-2">
                                            Expense Type *
                                        </label>
                                        <select
                                            value={editingExpense.expenseType}
                                            onChange={(e) => setFormData({ ...editingExpense, expenseType: e.target.value })}
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                                        >
                                            <option value="EVENT">Event Expense</option>
                                            <option value="OPERATIONAL">Operational Expense</option>
                                            <option value="MAINTENANCE">Maintenance Expense</option>
                                            <option value="OTHER">Other Expense</option>
                                        </select>
                                    </div>

                                    {/* Event Name */}
                                    <div>
                                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                                            Event Name *
                                        </label>
                                        <input
                                            type="text"
                                            name="event"
                                            value={editingExpense.event.eventName}
                                            onChange={(e)=>{setEditingExpense({...editingExpense ,event : e.target.value})}}
                                            placeholder="e.g., Annual Meeting, Blood Donation Camp"
                                            className={'w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all border-gray-300'}
                                            disabled
                                        />
                                        </div>

                                        {/*Title*/}
                                        <div>
                                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                                Title*
                                            </label>
                                            <input
                                                type="text"
                                                name="title"
                                                value={editingExpense.title}
                                                onChange={(e)=>{setEditingExpense({...editingExpense, title:e.target.value})}}
                                                placeholder="Expense Title"
                                                className={'w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all border-gray-300'}
                                            />
                                        </div>

                                        {/* Cost and Date */}
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <div>
                                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                                    Amount (LKR) *
                                                </label>
                                                <div className="relative">
                                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <DollarSign className="w-5 h-5 text-gray-400" />
                                                    </div>
                                                    <input
                                                        type="number"
                                                        name="cost"
                                                        value={editingExpense.amount}
                                                        onChange={(e)=>{setEditingExpense({...editingExpense, amount:e.target.value})}}
                                                        placeholder="0.00"
                                                        step="0.01"
                                                        min="0"
                                                        className={'w-full pl-10 pr-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all border-red-300 bg-red-50 border-gray-300'}
                                                    />
                                                </div>
                                            </div>

                                            <div>
                                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                                    Payment Date *
                                                </label>
                                                <div className="relative">
                                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                        <Calendar className="w-5 h-5 text-gray-400" />
                                                    </div>
                                                    <input
                                                        type="date"
                                                        name="paymentDate"
                                                        value={editingExpense.paymentDate}
                                                        onChange={(e)=>{setEditingExpense({...editingExpense, paymentDate: e.target.value})}}
                                                        className={'w-full pl-10 pr-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all border-gray-300'}
                                                    />
                                                </div>
                                            </div>
                                        </div>

                                        {/* Reason */}
                                        <div>
                                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                                Reason for Expense *
                                            </label>
                                            <textarea
                                                name="reason"
                                                value={editingExpense.description}
                                                onChange={(e)=>{setEditingExpense({...editingExpense,description:e.target.value})}}
                                                    rows="4"
                                                    placeholder="Describe the purpose of this expense..."
                                                    className={'w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all resize-none border-gray-300'}
                                            />
                                        </div>

                                        {/* Receipt Upload */}
                                        <div>
                                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                                Receipt (Optional)
                                            </label>
                                                
                                            {!editingExpense.receiptFile ? (
                                                <label className="flex flex-col items-center justify-center w-full h-48 border-2 border-orange-300 border-dashed rounded-2xl cursor-pointer bg-orange-50 hover:bg-orange-100 transition-colors">
                                                <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                                    <div className="w-16 h-16 bg-gradient-to-br from-orange-500 to-red-500 rounded-2xl flex items-center justify-center mb-4">
                                                        <Upload className="w-8 h-8 text-white" />
                                                    </div>
                                                    <p className="mb-2 text-sm font-semibold text-gray-700">
                                                        <span className="text-orange-600">Click to upload</span> or drag and drop
                                                    </p>
                                                    <p className="text-xs text-gray-500">PNG, JPG or PDF (MAX. 5MB)</p>
                                                </div>
                                                <input
                                                    type="file"
                                                    onChange={(e)=>{setEditingExpense({...editingExpense, receiptFile:e.target.value})}}
                                                    accept=".pdf,.png,.jpg,.jpeg"
                                                    className="hidden"
                                                />
                                                </label>
                                                ) : (
                                                    <div className="border-2 border-orange-200 rounded-2xl p-4 bg-orange-50">
                                                        {editingExpense.receiptPreview ? (
                                                            <div className="relative">
                                                                <img
                                                                    src={editingExpense.receiptPreview}
                                                                    alt="Receipt preview"
                                                                    className="w-full h-64 object-contain rounded-xl bg-white"
                                                                />
                                                                <button
                                                                    onClick={handleRemoveFile}
                                                                    className="absolute top-2 right-2 p-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors shadow-lg"
                                                                >
                                                                    <X className="w-5 h-5" />
                                                                </button>
                                                            </div>
                                                        ) : (
                                                            <div className="flex items-center justify-between bg-white rounded-xl p-4 border border-orange-200">
                                                                <div className="flex items-center gap-3">
                                                                    <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-red-500 rounded-xl flex items-center justify-center">
                                                                        <FileText className="w-6 h-6 text-white" />
                                                                    </div>
                                                                    <div>
                                                                        <p className="font-semibold text-gray-900">{editingExpense.receiptFile.name}</p>
                                                                        <p className="text-sm text-gray-500">
                                                                            {(editingExpense.receiptFile.size / 1024).toFixed(2)} KB
                                                                        </p>
                                                                    </div>
                                                                </div>
                                                                <button
                                                                    onClick={handleRemoveFile}
                                                                    className="p-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-colors"
                                                                >
                                                                    <X className="w-5 h-5" />
                                                                </button>
                                                            </div>
                                                        )}
                                                    </div>
                                                )}
                                            </div>

                                            {/* Submit Buttons */}
                                            <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
                                                <button
                                                    onClick={()=>{setShowEditModel(false)}}
                                                    className="flex-1 px-6 py-3.5 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-all font-semibold"
                                                >
                                                    Cancel
                                                </button>
                                                <button
                                                    onClick={handleSubmit}
                                                    className="flex-1 flex items-center justify-center gap-2 px-6 py-3.5 bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:from-orange-600 hover:to-red-600 transform hover:scale-105 transition-all duration-300"
                                                >
                                                    <Save className="w-5 h-5" />
                                                    Save Expense Record
                                                </button>
                                            </div>
                                        </div>
                                </div>
                            </div>
                        </div>                           
                )}
            </div>
        </div>
    );
}