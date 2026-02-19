import { Routes, Route } from 'react-router-dom'
import Login from './authentication/Login.jsx'
import ForgotPassword from './authentication/ForgotPassword.jsx'
import ResetPassword from './authentication/ResetPassword.jsx'
import Topnotch from './components/Topnotch.jsx'
import Footer from './components/Footer.jsx'
import PresidentDashboard from './Pages/Commen/Dashboard.jsx'
import SecretaryDashboard from './Pages/Tresurer/SecretaryDashboard.jsx'
import CommunityFeed from './Pages/Commen/CommunityFeed.jsx'
import Announcements from './Pages/Commen/Announcement.jsx'
import MemberDetails from './Pages/President/MemberDetails.jsx'
import Complaints from './Pages/President/Complaints.jsx'
import Events from './Pages/Commen/Events.jsx'
import PaymentHandeling from './Pages/Tresurer/PaymentHandeling.jsx'
import MoreOptions from './Pages/President/MoreOptions.jsx'
import CreateAnnouncement from './Pages/Commen/CreateAnnouncement.jsx'
import CreateEvent from './Pages/President/CreateEvent.jsx'
import PaymentHistory from './Pages/Tresurer/PaymentHistory.jsx'
import OldComplaints from './Pages/President/OldComplaints.jsx'
import UserManagement from './Pages/President/UserManagement.jsx'
import EventAttendance from './Pages/President/EventAttendance.jsx'
import Expenses from './Pages/Tresurer/Expenses.jsx'
import AddExpenses from './Pages/Tresurer/AddExpenses.jsx'
import UnityStars from './Pages/Commen/UnityStars.jsx'
import RedemptionRequests from './Pages/Tresurer/RedemptionRequests.jsx'
import ManageReportedPosts from './Pages/President/ManageReportedPosts.jsx'
import EventCalendar from './Pages/Commen/EventCalendar.jsx'
import Dashboard from './Pages/Commen/Dashboard.jsx'
import MoreOptionsTresurer from './Pages/Tresurer/MoreOptionsTresurer.jsx'
import EventBudget from './Pages/Tresurer/EventBudget.jsx'
import { Calendar } from 'lucide-react'
import StarClaims from './Pages/Tresurer/StarClaims.jsx'
import Reports from './Pages/Commen/Reports.jsx'


export default function App() {
  return (
    <Routes>
      <Route path="/" element={<><Topnotch /><Login /><Footer /></>} />
      <Route path="/forgot-password" element={<><Topnotch /><ForgotPassword /><Footer /></>} />
      <Route path="/forgot-password/reset-password/:email" element={<><Topnotch /><ResetPassword /><Footer /></>} />

    {/*Routs for president*/}
      <Route path="/president/dashboard" element={<><Topnotch/><PresidentDashboard/><Footer/></>}/>
      <Route path="/president/announcements" element={<><Topnotch/><Announcements/><Footer/></>}/>
      <Route path="/president/announcements/create" element={<><Topnotch/><CreateAnnouncement/><Footer/></>}/>
      <Route path="/president/feed" element={<><Topnotch/><ManageReportedPosts/><Footer/></>}/>
      <Route path="/president/member-details" element={<><Topnotch/><MemberDetails/><Footer/></>}/>
      <Route path="/president/complaints" element={<><Topnotch/><Complaints/><Footer/></>}/>
      <Route path="/President/complaints/view" element={<><Topnotch/><OldComplaints/><Footer/></>}/>
      <Route path="/president/events" element={<><Topnotch/><Events/><Footer/></>}/>
      <Route path="/President/events/create" element={<><Topnotch/><CreateEvent/><Footer/></>}/>
      <Route path="/President/events/:id/attendance" element={<><Topnotch/><EventAttendance/><Footer/></>}/>
      <Route path="/president/more" element={<><Topnotch/><MoreOptions/><Footer/></>}/> 
      <Route path="/President/users" element={<><Topnotch/><UserManagement/><Footer/></>}/>
      <Route path="/President/calendar" element={<><Topnotch/><EventCalendar/><Footer/></>}/>
      <Route path="/President/unityStars" element={<><Topnotch/><UnityStars/><Footer/></>}/>
      <Route path="/President/reports" element={<><Topnotch/><Reports/><Footer/></>}/>
      
      
     
      
      
      {/*Only Tresurer should have Payment Handeling access*/ }
      <Route path='/treasurer/dashboard' element={<><Topnotch/><Dashboard/><Footer/></>}/>
      <Route path='/treasurer/announcements' element={<><Topnotch/><Announcements/><Footer/></>}/>
      <Route path='/treasurer/announcements/create' element={<><Topnotch/><CreateAnnouncement/><Footer/></>}/>
      <Route path='/treasurer/feed' element={<><Topnotch/><ManageReportedPosts/><Footer/></>}/>
      <Route path="/treasurer/payments" element={<><Topnotch/><PaymentHandeling/><Footer/></>}/>
      <Route path="/treasurer/payments/history" element={<><Topnotch/><PaymentHistory/><Footer/></>}/>
      <Route path="/treasurer/starClaims" element={<><Topnotch/><StarClaims/><Footer/></>}/>  
      <Route path="/treasurer/expenses" element={<><Topnotch/><Expenses/><Footer/></>}/>
      <Route path="/treasurer/expenses/add" element={<><Topnotch/><AddExpenses/><Footer/></>}/>  
      <Route path="/treasurer/calendar" element={<><Topnotch/><EventCalendar/><Footer/></>}/>
      <Route path="/treasurer/unityStars" element={<><Topnotch/><UnityStars/><Footer/></>}/>
      <Route path="/treasurer/unityStars/redemptions" element={<><Topnotch/><RedemptionRequests/><Footer/></>}/> 
      <Route path="/treasurer/more" element={<><Topnotch/><MoreOptionsTresurer/><Footer/></>}/> 
      <Route path="/treasurer/more/events" element={<><Topnotch/><Events/><Footer/></>}/> 
      <Route path="/treasurer/more/userManagement" element={<><Topnotch/><UserManagement/><Footer/></>}/>
      <Route path="/treasurer/event-budget/:id" element={<><Topnotch/><EventBudget/><Footer/></>}/>
      <Route path="/treasurer/more/reports" element={<><Topnotch/><Reports/><Footer/></>}/>

      {/*Routes for admin*/}
      <Route path="/admin/dashboard" element={<><Topnotch/><Dashboard/><Footer/></>}/>
      <Route path="/admin/announcements" element={<><Topnotch/><Announcements/><Footer/></>}/>
      <Route path="/admin/announcements/create" element={<><Topnotch/><CreateAnnouncement/><Footer/></>}/>
      <Route path="/admin/feed" element={<><Topnotch/><CommunityFeed/><Footer/></>}/>
      <Route path="/admin/events" element={<><Topnotch/><Events/><Footer/></>}/>
      <Route path="/admin/events/create" element={<><Topnotch/><CreateEvent/><Footer/></>}/>
      <Route path="/admin/users" element={<><Topnotch/><UserManagement/><Footer/></>}/>
      <Route path="/admin/calendar" element={<><Topnotch/><EventCalendar/><Footer/></>}/>
      <Route path="/admin/complaints" element={<><Topnotch/><Complaints/><Footer/></>}/>
      <Route path="/admin/complaints/view" element={<><Topnotch/><OldComplaints/><Footer/></>}/>
      <Route path="/admin/more" element={<><Topnotch/><MoreOptions/><Footer/></>}/> 
      

   
    </Routes>
  )
}

