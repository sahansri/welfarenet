import logo from "../assets/IMG_2315.PNG"
import avatar from "../assets/avatar1.png"
import React from "react";
import { useState , useEffect, useRef} from "react";
import { useLocation,useNavigate } from "react-router-dom";
import {Bell,LogOut, Star,Settings} from "lucide-react"
import Breadcrumbs from "./Breadcrumbs.jsx";
import TopNavBar from "./TopNavBar.jsx";
import { useTopNavBar } from "../context/TopNavBarContext.jsx";

export default function Topnotch() {
    const location = useLocation();

    const navigate = useNavigate();

    const dropDownRef = useRef(null);

    const userName = localStorage.getItem('username');
    const email = localStorage.getItem('email');
    const role = localStorage.getItem('role');
    const profilePic = avatar; {/*localStorage.getItem("profilePic");*/}    
    const pathname = location?.pathname || '';
    const hideBreadcrumb = pathname === '/' || pathname.startsWith('/forgot') || pathname.startsWith('/login');
    
    const { activeTab, setActiveTab, TopNavBarOpen, setTopNavBarOpen } = useTopNavBar();

    const [showProfileDropdown,setShowProfileDropdown] = useState(false);
    const [showNotifications,setShowNotifications] = useState(false);
    const [notifications,setNotifications] = useState([]);
    
    useEffect(()=>{
        function handleClickOutside(event) {
            if (dropDownRef.current && !dropDownRef.current.contains(event.target)) {
                setShowNotifications(false);
                setShowProfileDropdown(false); 
            }
        }

        document.addEventListener("mousedown",handleClickOutside);

        () =>{
            document.removeEventListener("mousedown",handleClickOutside);
        }
    },[]);

    

    const handleNotificationClick = () => {
        // Handle notification click logic here
        setShowNotifications(!showNotifications);
    }

    const handleSettingsClick = () =>{
        console.log("Settings Button Clicked!");
    }

    const handleLogout = () => {
        localStorage.removeItem('role');
        localStorage.removeItem('token');
        setShowProfileDropdown(false);
        navigate("/");
    }

    const handleProfilePicClick = () => {
       setShowProfileDropdown(!showProfileDropdown);
    }

    return(
        <div className="fixed w-full min-h-20 bg-slate-950 flex flex-col z-50">
                <div className="pl-4 flex">
                    <div className="flex justify-between w-full items-center  px-6">
                        <div>    
                            <img src={logo} alt="Logo" className="h-14 w-14" />
                        </div>
                        {!hideBreadcrumb &&(
                            <div className="flex items-center gap-4">
                                <div>
                                    <Bell className="text-white cursor-pointer hover:text-purple-400 transition-colors"
                                    onClick={handleNotificationClick}
                                />
                                </div>
                                    <div 
                                        className="flex items-center gap-2 cursor-pointer hover:opacity-80 transition-opacity"
                                        onClick={handleProfilePicClick}
                                    >
                                    <div>
                                        <img src={profilePic} alt="profile_pic" className="h-8 w-8"/>
                                    </div>
                                    <div>
                                        {userName !== ''&& userName !=='undefined'&&(
                                            <p className="text-white text-sm">{userName}</p>
                                        )}
                                    </div>
                                </div>
                            </div>
                        )}

                    </div>
                </div>   
            {/* Top Purple Header */}
            <div className="relative translate-y-0 h-14 w-full bg-[#874ECE] rounded-t-3xl">
                {!hideBreadcrumb && (
                    <div className="ml-6">
                        <Breadcrumbs />
                    </div>
                )}
                {/* Main Content */}
                <div className={`relative ${hideBreadcrumb?"translate-y-2/5":"translate-y-1/8"} w-full min-h-10 bg-white flex items-center px-6 py-2 rounded-t-2xl z-50`}>
                    {!hideBreadcrumb &&(
                        <div>
                            <TopNavBar/>
                        </div>
                    )}
                            
                </div>
            </div>

            {/*Profile Dropdown*/}
            {showProfileDropdown && (
                <div 
                    className="absolute top-10 right-8 w-[300px] h-auto bg-white/90 rounded-md shadow-lg " 
                    ref={dropDownRef}
                >
                    <div className="flex flex-col items-center bg-slate-950/80 pt-8 pb-6 gap-1">
                        
                        <img src={avatar} className="w-20 h-20 rounded-full" />
                        {userName !== ''&& userName !=='undefined'&&(
                            <p className="text-white text-lg font-semibold">{userName}</p>
                        )}
                        <p className="text-white text-sm opacity-80">{email}</p>

                        <p className="text-white text-lg font-semibold">{role}</p>

                    </div>
                    <div className="flex flex-col items-center pt-1 gap-1">
                        <div 
                            className="flex gap-3 px-3 py-2 items-center justify-center rounded-md hover:bg-black/10 cursor-pointer w-full "
                            onClick={handleSettingsClick}
                        >
                            <Settings className="w-5 h-5"/>
                            <p>Settings</p>
                        </div>
                            
                        <div 
                            className="flex gap-3 px-3 py-2 items-center justify-center  rounded-md w-full hover:bg-black/10 cursor-pointer"
                            onClick={handleLogout}    
                        >
                            <LogOut className="w-5 h-5 text-red-500"/>
                            <p className="text-red-500">LogOut</p>
                        </div>
                    </div>
                </div>
            )}

            {/*Notification Dropdown*/}
            {showNotifications&&(
                <div 
                    className="absolute top-10 right-30 w-[300px] h-auto bg-slate-950/90 rounded-md shadow-lg" 
                    ref={dropDownRef}
                >
                    <div className="flex flex-col items-center pt-4">
                        <h2 className="text-white font-semibold">Notifications</h2>
                    </div>

                    <div>
                        {notifications.length > 0 ?(
                            <>
                            </>
                        ):(
                            <div className="flex items-center justify-center p-10">
                                <p className="text-white">No new Notifications</p>
                            </div>
                        )}
                    </div>
                </div>
        
            
            )}
        </div>
    );
}