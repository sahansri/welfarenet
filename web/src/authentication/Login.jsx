import React from "react";
import { useState } from "react";
import { Link,useNavigate } from 'react-router-dom'
import axios from '../config'
import art from "../assets/hand-drawn-diversity-concept-background.png"

export default function Login() {
  const navigate = useNavigate();
  const [email,setEmail] = useState("");
  const [password,setPassword] = useState("");
  const [isLoading,setIsLoading] = useState(false);

 

  const handleSignin = async (e)=>{
    setIsLoading(true);
    try{
      
      const response = await axios.post('/auth/login',{
        email:email,
        password:password
      });
      localStorage.setItem("token",response.data.token);
      localStorage.setItem("role",response.data.role);

      const role = localStorage.getItem("role");
      const token = localStorage.getItem("token");

      try{
          const response = await axios.get('/member/me',{
              headers:{
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
              }
          });

            console.log("Member details fetched successfully:",response.data);
            localStorage.setItem('username',response.data.fullName);
            localStorage.setItem('email',response.data.email);
      }
      catch (error){
          console.log("error while fetching member details!",error);
      }
      finally{
        if( role === 'president'){
          navigate('/president/dashboard');
        }
        else if(role ==='treasurer'){
          navigate('/treasurer/dashboard');
        }
        else {
          navigate('/admin/dashboard');
        }
      }
    }

    catch{
      console.log("Error occored while SignIn!");
    }
    finally{
      setIsLoading(false);
    }
  }

  return (
    <div className="w-full max-w-5xl mx-auto aspect-[16/10] min-h-screen screen mx-auto p-20">
      <div className="w-full bg-white flex flex-col md:flex-row px-6 md:px-10 pt-16 rounded-3xl">

        {/* Left Side */}
        <div className="w-full md:w-1/2 pt-4 pr-20 flex flex-col justify-center items-center text-center md:text-left">
          <h1 className="text-4xl md:text-5xl font-bold mb-2">WelfareNet</h1>
          <p className="text-gray-700 text-lg">Community Management System</p>
          <p className="text-gray-900 font-semibold text-base mt-1">Pathum Uyana Welfare Society</p>
          <p className="text-gray-900 font-semibold text-base mt-1">Kundasale.</p>

          <div className="w-full flex justify-center md:justify-end mt-6">
            <img 
              src={art} 
              alt="Diversity Art" 
              className="w-3/4 md:w-full h-auto rounded-lg"
            />
          </div>
        </div>

        {/* Divider (Hide on small screens) */}
        <div className="hidden md:block w-px bg-gray-400 mx-6"></div>

        {/* Right Side */}
        <div className="w-full md:w-1/2 pl-20 flex flex-col justify-center mt-10 md:mt-0">
          <h2 className="text-4xl md:text-4xl font-bold mb-4 text-center">Sign In</h2>
          <h3 className="text-xl md:text-2xl text-center mb-6">Sign in to your account</h3>

          <form className="space-y-6">
            <div>
              <label htmlFor="username" className="block text-lg font-medium text-gray-700">
                Username
              </label>
              <input 
                type="text" 
                id="username" 
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md text-lg focus:outline-none focus:ring-purple-500 focus:border-purple-500" 
                placeholder="Enter your Username" 
                value={email} 
                onChange={e => {
                  setEmail(e.target.value)
                }}
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-lg font-medium text-gray-700">
                Password
              </label>
              <input 
                type="password" 
                id="password" 
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md text-lg focus:outline-none focus:ring-purple-500 focus:border-purple-500" 
                placeholder="Enter your password"
                value={password}
                onChange={e => {
                  setPassword(e.target.value)
                }} 
              />
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center text-lg">
                <input 
                  type="checkbox" 
                  className="h-4 w-4 text-purple-600 border-gray-300 rounded" 
                />
                <span className="ml-2 text-gray-900">Remember me</span>
              </label>

              <Link 
                to="/forgot-password" 
                className="text-purple-600 hover:text-purple-500 text-lg"
              >
                Forgot password?
              </Link>
            </div>

            <button 
              type="button" 
              className={isLoading ? "w-full opacity-90 py-3 bg-purple-600 text-white rounded-md text-lg hover:bg-purple-700 shadow":"w-full py-3 bg-purple-600 text-white rounded-md text-lg hover:bg-purple-700 shadow"}
              onClick={()=>{handleSignin()}}
            >
              {isLoading ? "Signing In...."  :"Sign In"}
            </button>
          </form>
        </div>

      </div>
    </div>
  );
}
