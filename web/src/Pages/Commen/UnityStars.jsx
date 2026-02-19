import { useState } from 'react';
import { Star, Users, Award, Gift, TrendingUp, Calendar, DollarSign, UserCheck, Eye, Plus, Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import axios from '../../config'

export default function UnityStars() {
    const navigate = useNavigate();
    const role = localStorage.getItem('role');
    const token = localStorage.getItem('token');

    const [searchTerm, setSearchTerm] = useState('');

    const fetchOffers = async ()=>{
        try{
            const response = await axios.get('/claims/offers',{
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });
            console.log('Fetched offers:', response.data);
            return response.data;
        }
        catch(error){
            console.error('Error fetching offers:', error);
            return [];
        }
    }

    const fetchMembers = async ()=>{
        try{
            const response = await axios.get('/stars/balances',{
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });
            console.log('Fetched members:', response.data);
            return response.data;
        }
        catch(error){
            console.error('Error fetching members:', error);
            return [];
        }
    }


    const {
        data:members=[],
        isLoading:isMemberLoading,
        isError:isMemberError,
        error:memberFetchError
    } = useQuery({
        queryKey: ['unitystars-members'],
        queryFn: fetchMembers,
        staleTime: 10*60*1000, //fetch after 10mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    })

    const {
        data:offers=[],
        isLoading:offersLoading,
        isError:offersError,
        error:offersFetchError  
    } = useQuery({
        queryKey: ['offers'],
        queryFn:fetchOffers,
        staleTime: 10*60*1000, //fetch after 10mins
        cacheTime:30*60*1000 // Keep in memory 30mins
    });

    // Calculate statistics
    const totalMembers = members.length;
    const totalPointsIssued = members.reduce((sum, m) => sum + m.totalPoints + m.redeemedPoints, 0);
    const totalPointsRedeemed = members.reduce((sum, m) => sum + m.redeemedPoints, 0);
    const activeMembers = members.filter(m => m.totalPoints > 0).length;

    // Filter members based on search
    const filteredMembers = members.filter(member =>
        member.memberName.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const handleViewMember = (memberId) => {
        alert(`Navigate to: /admin/unitystars/member/${memberId}`);
    };

    const handleAddPoints = () => {
        alert('Navigate to: /admin/unitystars/add-points');
    };

    const handleRedemptionRequests = () => {
        if(role === 'tresurer'){
            navigate('/tresurer/unityStars/redemptions');
        }
    };

    const handlePointsHistory = () => {
        alert('Navigate to: /admin/unitystars/history');
    };

    return (
        <div className='min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8'>
            <div className="max-w-6xl mx-auto pt-28">
                <main className="transition-all duration-300 pt-4">
                    <div className="max-w-6xl mx-auto p-4">
                        {/* Header Section */}
                        <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
                            <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
                            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
                            <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
                            
                            <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                                <div>
                                    <div className="flex items-center gap-4 mb-3">
                                        <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                                            <Star className="w-8 h-8 text-yellow-400 fill-yellow-400" />
                                        </div>
                                        <div>
                                            <h1 className="text-4xl font-bold tracking-tight">UnityStars</h1>
                                        </div>
                                    </div>
                                    <p className="text-purple-100 text-lg">Member reward and recognition system</p>
                                </div>
                                <div className="flex flex-wrap gap-3">
                                    <button
                                        onClick={handleAddPoints}
                                        className="bg-white text-purple-600 px-6 py-3 rounded-xl font-bold hover:bg-purple-50 transition-all shadow-lg hover:scale-105 flex items-center gap-2 whitespace-nowrap"
                                    >
                                        <Plus className="w-5 h-5" />
                                        Add Points
                                    </button>
                                    {role==='tresurer'&&(
                                        <button
                                            onClick={handleRedemptionRequests}
                                            className="bg-yellow-400 text-purple-900 px-6 py-3 rounded-xl font-bold hover:bg-yellow-300 transition-all shadow-lg hover:scale-105 flex items-center gap-2 whitespace-nowrap"
                                        >
                                            <Gift className="w-5 h-5" />
                                            Redemptions
                                        </button>
                                    )}       
                                </div>
                            </div>
                        </div>

                        {/* Points Allocation Info Card */}
                        <div className="bg-white rounded-3xl shadow-xl overflow-hidden p-6 md:p-8 mb-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-yellow-500 via-orange-500 to-red-500 rounded-t-3xl -mt-8 -mx-8 mb-6"></div>
                            
                            <div className="flex items-center gap-3 mb-6">
                                <div className="w-12 h-12 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center">
                                    <Award className="w-6 h-6 text-white" />
                                </div>
                                <h2 className="text-2xl font-bold text-gray-900">Point Allocation Criteria</h2>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <div className="bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl p-6 border border-blue-200">
                                    <div className="flex items-center gap-3 mb-3">
                                        <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center">
                                            <Calendar className="w-5 h-5 text-white" />
                                        </div>
                                        <h3 className="font-bold text-gray-900">Event Attendance</h3>
                                    </div>
                                    <p className="text-3xl font-bold text-blue-600 mb-1">4 points</p>
                                    <p className="text-sm text-gray-600">Per event or meeting attended</p>
                                </div>

                                <div className="bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl p-6 border border-green-200">
                                    <div className="flex items-center gap-3 mb-3">
                                        <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                                            <DollarSign className="w-5 h-5 text-white" />
                                        </div>
                                        <h3 className="font-bold text-gray-900">Welfare Payments</h3>
                                    </div>
                                    <p className="text-3xl font-bold text-green-600 mb-1">2 points</p>
                                    <p className="text-sm text-gray-600">Per on-time payment</p>
                                </div>

                                <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-6 border border-purple-200">
                                    <div className="flex items-center gap-3 mb-3">
                                        <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                                            <UserCheck className="w-5 h-5 text-white" />
                                        </div>
                                        <h3 className="font-bold text-gray-900">Volunteer Work</h3>
                                    </div>
                                    <p className="text-3xl font-bold text-purple-600 mb-1">1 point</p>
                                    <p className="text-sm text-gray-600">Per volunteer activity</p>
                                </div>
                            </div>
                        </div>

                        {/* Redemption Options Card */}
                        <div className="bg-white rounded-3xl shadow-xl overflow-hidden p-6 md:p-8 mb-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 rounded-t-3xl -mt-8 -mx-8 mb-6"></div>
                            
                            <div className="flex items-center gap-3 mb-6">
                                <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                                    <Gift className="w-6 h-6 text-white" />
                                </div>
                                <h2 className="text-2xl font-bold text-gray-900">Redemption Options</h2>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <div className="bg-gradient-to-br from-amber-50 to-yellow-50 rounded-2xl p-6 border-2 border-yellow-300 relative overflow-hidden">
                                    <div className="absolute top-0 right-0 w-20 h-20 bg-yellow-400 opacity-20 rounded-full -mr-10 -mt-10"></div>
                                    <div className="relative z-10">
                                        <div className="flex items-center justify-between mb-4">
                                            <span className="text-4xl font-bold text-yellow-600">50</span>
                                            <Star className="w-8 h-8 text-yellow-500 fill-yellow-500" />
                                        </div>
                                        <p className="text-sm text-gray-600 mb-2">points</p>
                                        <p className="text-2xl font-bold text-gray-900">Rs. 500/=</p>
                                        <p className="text-sm text-gray-600 mt-2">Gift Voucher</p>
                                    </div>
                                </div>

                                <div className="bg-gradient-to-br from-orange-50 to-amber-50 rounded-2xl p-6 border-2 border-orange-300 relative overflow-hidden">
                                    <div className="absolute top-0 right-0 w-20 h-20 bg-orange-400 opacity-20 rounded-full -mr-10 -mt-10"></div>
                                    <div className="relative z-10">
                                        <div className="flex items-center justify-between mb-4">
                                            <span className="text-4xl font-bold text-orange-600">100</span>
                                            <Star className="w-8 h-8 text-orange-500 fill-orange-500" />
                                        </div>
                                        <p className="text-sm text-gray-600 mb-2">points</p>
                                        <p className="text-2xl font-bold text-gray-900">Rs. 1,000/=</p>
                                        <p className="text-sm text-gray-600 mt-2">Gift Voucher</p>
                                    </div>
                                </div>

                                <div className="bg-gradient-to-br from-red-50 to-pink-50 rounded-2xl p-6 border-2 border-red-300 relative overflow-hidden">
                                    <div className="absolute top-0 right-0 w-20 h-20 bg-red-400 opacity-20 rounded-full -mr-10 -mt-10"></div>
                                    <div className="relative z-10">
                                        <div className="flex items-center justify-between mb-4">
                                            <span className="text-4xl font-bold text-red-600">200</span>
                                            <Star className="w-8 h-8 text-red-500 fill-red-500" />
                                        </div>
                                        <p className="text-sm text-gray-600 mb-2">points</p>
                                        <p className="text-2xl font-bold text-gray-900">Rs. 2,000/=</p>
                                        <p className="text-sm text-gray-600 mt-2">Gift Voucher</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Members List */}
                        <div className="bg-white overflow-hidden rounded-3xl shadow-xl p-6 md:p-8 border border-gray-100">
                            <div className="h-2 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 rounded-t-3xl -mt-8 -mx-8 mb-6"></div>
                            
                            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
                                <div>
                                    <h2 className="text-2xl font-bold text-gray-900">Member Points</h2>
                                    <p className="text-sm text-gray-500 mt-1">View and manage member reward points</p>
                                </div>
                                <button
                                    onClick={handlePointsHistory}
                                    className="flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-purple-500 to-blue-500 text-white rounded-xl font-medium shadow-md hover:shadow-lg hover:from-purple-600 hover:to-blue-600 transition-all"
                                >
                                    <Eye className="w-4 h-4" />
                                    View History
                                </button>
                            </div>

                            {/* Search */}
                            <div className="mb-6">
                                <div className="relative">
                                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                                    <input
                                        type="text"
                                        placeholder="Search by name or email..."
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value)}
                                        className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                                    />
                                </div>
                            </div>

                            {isMemberLoading ?( 
                                <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
                                <div className="text-center">
                                    <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                                    <p className="mt-4 text-gray-700 font-medium">
                                    Loading Star Details...
                                    </p>
                                </div>
                                </div>
                            ):(
                                <div className="overflow-x-auto">
                                    <table className="w-full">
                                        <thead>
                                            <tr className="border-b-2 border-gray-200">
                                                <th className="text-left py-4 px-4 text-sm font-semibold text-gray-600">Member</th>
                                                <th className="text-center py-4 px-4 text-sm font-semibold text-gray-600">Total Points</th>
                                                <th className="text-center py-4 px-4 text-sm font-semibold text-gray-600">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {filteredMembers.map((member) => (
                                                <tr key={member.memberId} className="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                                                    <td className="py-4 px-4">
                                                        <div className="flex items-center gap-3">
                                                            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold">
                                                                {member.memberName.charAt(0)}
                                                            </div>
                                                            <div>
                                                                <p className="font-semibold text-gray-900">{member.memberName}</p>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td className="py-4 px-4 text-center">
                                                        <div className="flex items-center justify-center gap-1">
                                                            <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                                                            <span className="text-lg font-bold text-gray-900">{member.availableStars}</span>
                                                        </div>
                                                    </td>
                                                    <td className="py-4 px-4 text-center">
                                                        <button
                                                            onClick={() => handleViewMember(member.memberId)}
                                                            className="px-4 py-2 bg-purple-100 text-purple-700 rounded-lg hover:bg-purple-200 transition-all font-medium text-sm"
                                                        >
                                                            View Details
                                                        </button>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>

                                    {filteredMembers.length === 0 && (
                                        <div className="text-center py-12">
                                            <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                                            <p className="text-gray-500 text-lg">No members found</p>
                                        </div>
                                    )}
                                </div>
                            )};
                        </div>
                    </div>
                </main>
            </div>
        </div>
    );
}