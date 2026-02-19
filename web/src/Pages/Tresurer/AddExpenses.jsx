import React, { useState,useEffect } from 'react';
import { ArrowLeft, Upload, X, FileText, DollarSign, Calendar, Save, AlertCircle } from 'lucide-react';
import {useNavigate} from 'react-router-dom'
import axios from '../../config'

export default function AddExpenses() {
    const navigate = useNavigate();
 

    const [events, setEvents] = useState([]);
    const [formData, setFormData] = useState({
        eventId:'',
        amount: '',
        title:'',
        expenseType:'',
        description: '',
        createdDate: new Date().toISOString().split('T')[0],
        paymentDate: '',
    });

    const [errors, setErrors] = useState({});
    const [isLoading, setIsLoading] = useState(false);

    useEffect(()=>{
        const token = localStorage.getItem('token');
        const fetchEvents = async () => {
            setIsLoading(true);
            try{
                const response = await axios.get("/events/sorted-by-date",{
                    headers: {
                        Authorization: `Bearer ${token}`
                    }
                });
                console.log("Fetched events:", response.data);
                setEvents(response.data);
            }
            catch(error){
                console.error("Error fetching events:", error);
            }
            finally{  
                setIsLoading(false);        
            }

        }
        fetchEvents();
    },[]);

    
    const handleBack = () => {
        navigate('/treasurer/expenses');
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: name === "eventId" ? parseInt(value) : value
        }));
        // Clear error when user starts typing
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            // Validate file type
            const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
            if (!validTypes.includes(file.type)) {
                setErrors(prev => ({ ...prev, receipt: 'Please upload a valid image (JPG, PNG) or PDF file' }));
                return;
            }

            // Validate file size (5MB)
            if (file.size > 5 * 1024 * 1024) {
                setErrors(prev => ({ ...prev, receipt: 'File size must be less than 5MB' }));
                return;
            }

            // Create preview for images
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onloadend = () => {
                    setFormData(prev => ({
                        ...prev,
                        receiptFile: file,
                        receiptPreview: reader.result
                    }));
                };
                reader.readAsDataURL(file);
            } else {
                setFormData(prev => ({
                    ...prev,
                    receiptFile: file,
                    receiptPreview: null
                }));
            }

            // Clear error
            if (errors.receipt) {
                setErrors(prev => ({ ...prev, receipt: '' }));
            }
        }
    };

    const handleRemoveFile = () => {
        setFormData(prev => ({
            ...prev,
            receiptFile: null,
            receiptPreview: null
        }));
    };

    const validateForm = () => {
        const newErrors = {};

        if (!formData.eventId) {
            newErrors.eventId = 'Event name is required';
        }

        if (!formData.title) {
            newErrors.title = 'Title is required';
        }

        if (!formData.amount) {
            newErrors.amount = 'Amount is required';
        } else if (parseFloat(formData.amount) <= 0) {
            newErrors.amount = 'Amount must be greater than 0';
        }

        if (!formData.description) {
            newErrors.description = 'Description is required';
        }

        if (!formData.paymentDate) {
            newErrors.paymentDate = 'Payment date is required';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async () => {
        if (validateForm()) {
            try{
                const token = localStorage.getItem('token');
                console.log("Submitting form data:", formData);
                const response = await axios.post('/expenses/create',formData ,{
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });

                if(response.status === 200){
                    alert('Expense record added successfully!');
                    handleBack();
                }
            }
            catch(error){   
                console.error("Error submitting expense:", error);
            }
        }
    };

    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Loading ...
                </p>
            </div>
            </div>
        );
    }


    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-3xl mx-auto p-4">
                        {/* Back Button */}
                        <button
                            onClick={handleBack}
                            className="mb-6 flex items-center gap-2 text-white hover:text-purple-200 transition-colors"
                        >
                            <ArrowLeft className="w-5 h-5" />
                            <span className="font-medium">Back to Expenses</span>
                        </button>

                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            
                            <div className="relative z-10">
                                <div className="flex items-center gap-4 mb-3">
                                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                        <DollarSign className="w-8 h-8 text-purple-900" />
                                    </div>
                                    <div>
                                        <h1 className="text-4xl font-bold tracking-tight">Add Expense Record</h1>
                                    </div>
                                </div>
                                <p className="text-purple-100 text-lg">Record a new expense for your community</p>
                            </div>
                        </div>

                        {/* Form Card */}
                        <div className="bg-white rounded-3xl shadow-xl p-6 md:p-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-orange-500 via-red-500 to-pink-500 rounded-t-3xl -mt-8 -mx-8 mb-8"></div>
                            
                            <div className="space-y-6">
                                {/* Expense Type */}
                                <div>
                                    <label className="block text-gray-700 font-semibold mb-2">
                                        Expense Type *
                                    </label>
                                    <select
                                        value={formData.expenseType}
                                        onChange={(e) => setFormData({ ...formData, expenseType: e.target.value })}
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
                                    <select
                                       className='mb-4 w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all '
                                       name='eventId'
                                       value={formData.eventId}
                                       onChange={handleInputChange}
                                       required
                                    >
                                        <option value="" disabled>Select an event</option>
                                        {events.map((event) => (
                                            <option key={event.eventId} value={event.eventId}>{event.eventName}</option>
                                        ))}

                                    </select>
                                    
                                </div>
                                {/*Title*/}
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                                        Title*
                                    </label>
                                    <input
                                        type="text"
                                        name="title"
                                        value={formData.title}
                                        onChange={handleInputChange}
                                        placeholder="Expense Title"
                                        className={'w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all border-gray-300'}
                                    />
                                </div>
                                {/* Cost and Date */}
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                                            Cost (LKR) *
                                        </label>
                                        <div className="relative">
                                            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                                <DollarSign className="w-5 h-5 text-gray-400" />
                                            </div>
                                            <input
                                                type="number"
                                                name="amount"
                                                value={formData.amount}
                                                onChange={handleInputChange}
                                                placeholder="0.00"
                                                step="0.01"
                                                min="0"
                                                className={`w-full pl-10 pr-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all ${
                                                    errors.amount ? 'border-red-300 bg-red-50' : 'border-gray-300'
                                                }`}
                                            />
                                        </div>
                                        {errors.amount && (
                                            <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
                                                <AlertCircle className="w-4 h-4" />
                                                {errors.amount}
                                            </p>
                                        )}
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
                                                value={formData.paymentDate}
                                                onChange={handleInputChange}
                                                className={`w-full pl-10 pr-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all ${
                                                    errors.paymentDate ? 'border-red-300 bg-red-50' : 'border-gray-300'
                                                }`}
                                            />
                                        </div>
                                        {errors.paymentDate && (
                                            <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
                                                <AlertCircle className="w-4 h-4" />
                                                {errors.paymentDate}
                                            </p>
                                        )}
                                    </div>
                                </div>

                                {/* Reason */}
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                                        Reason for Expense *
                                    </label>
                                    <textarea
                                        name="description"
                                        value={formData.description}
                                        onChange={handleInputChange}
                                        rows="4"
                                        placeholder="Describe the purpose of this expense..."
                                        className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all resize-none ${
                                            errors.description ? 'border-red-300 bg-red-50' : 'border-gray-300'
                                        }`}
                                    />
                                    {errors.description && (
                                        <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
                                            <AlertCircle className="w-4 h-4" />
                                            {errors.description}
                                        </p>
                                    )}
                                </div>

                                {/* Receipt Upload */}
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                                        Receipt (Optional)
                                    </label>
                                    
                                    {!formData.receiptFile ? (
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
                                                onChange={handleFileChange}
                                                accept=".pdf,.png,.jpg,.jpeg"
                                                className="hidden"
                                            />
                                        </label>
                                    ) : (
                                        <div className="border-2 border-orange-200 rounded-2xl p-4 bg-orange-50">
                                            {formData.receiptPreview ? (
                                                <div className="relative">
                                                    <img
                                                        src={formData.receiptPreview}
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
                                                            <p className="font-semibold text-gray-900">{formData.receiptFile.name}</p>
                                                            <p className="text-sm text-gray-500">
                                                                {(formData.receiptFile.size / 1024).toFixed(2)} KB
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
                                    
                                    {errors.receipt && (
                                        <p className="mt-2 text-sm text-red-600 flex items-center gap-1">
                                            <AlertCircle className="w-4 h-4" />
                                            {errors.receipt}
                                        </p>
                                    )}
                                </div>

                                {/* Submit Buttons */}
                                <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
                                    <button
                                        onClick={handleBack}
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

                        {/* Info Card */}
                        <div className="mt-6 bg-blue-50 border border-blue-200 rounded-2xl p-6">
                            <div className="flex gap-3">
                                <AlertCircle className="w-6 h-6 text-blue-600 flex-shrink-0" />
                                <div>
                                    <h3 className="font-semibold text-blue-900 mb-1">Important Information</h3>
                                    <ul className="text-sm text-blue-800 space-y-1">
                                        <li>• All fields marked with * are required</li>
                                        <li>• Receipt upload is optional but recommended for record keeping</li>
                                        <li>• Accepted file formats: PNG, JPG, PDF (Max 5MB)</li>
                                        <li>• The submitted date will be recorded automatically</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    );
}