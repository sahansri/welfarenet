import React from "react";
import { useState} from "react";
import { useParams,useNavigate } from "react-router-dom";
import axios from "../config";

import lady from "../assets/freepik__background__64725.png";
import lockImg from "../assets/Lock.png";

export default function ResetPassword() {
    const navigate = useNavigate();
    const [password,setPassword] = useState("");
    const [confirmPassword,setConfirmPassword] = useState("");
    const [isLoading,setIsLoading] = useState(false);
    const { email } = useParams();
    

    const handleSubmit = async () => {
        if(password !== confirmPassword){
            alert("Passwords do not match! Please try again.");
            return;
        }
        setIsLoading(true);

        try{

            const response =await axios.post(`/member/reset-password?email=${email}&password=${password}&confirmPassword=${confirmPassword}`,null,{
                headers:{
                    'Content-Type':'application/json'
                }
            });

            console.log("Response from server: ", response);
            if(response.status === 200){
                alert("Password reset successfully! You can now log in with your new password.");
                navigate('/');
            }
            else{
                alert("Error occured while resetting the password! Please try again.");
                setPassword("");
                setConfirmPassword("");
            }
        }
        catch(error){
            console.log("Error occured while resetting the password! ",error);
        }
        finally{
            setIsLoading(false);
        }
    }

    return(
        <div className="max-w-screen-lg mx-auto p-4">
            <div className="w-full bg-white flex flex-col md:flex-row px-6 md:px-10 py-8 rounded-3xl pt-30">
            
                    {/* Left Side */}
                    <div className="w-full md:w-1/2 pt-1 pr-20 flex flex-col justify-center items-center text-center md:text-left">
                        <h1 className="text-4xl md:text-5xl font-bold mb-2">WelfareNet</h1>
                        <p className="text-gray-700 text-lg">Community Management System</p>
                        <p className="text-gray-900 font-semibold text-base mt-1">Pathum Uyana Welfare Society</p>
                        <p className="text-gray-900 font-semibold text-base mt-1">Kundasale.</p>
                    
                        <div className="w-full flex justify-center md:justify-end mt-6">
                                <img 
                                  src={lady} 
                                  alt="Lady with arms crossed" 
                                  className="w-11/12 md:w-full h-auto md:h-80 rounded-lg object-contain"
                                />
                              </div>
                    </div>
                    {/* Divider (Hide on small screens) */}
                    <div className="hidden md:block w-px bg-gray-400 mx-6"></div>

                    {/*Right Side*/}
                    <div className="w-full md:w-1/2 pl-6 md:pl-20 flex flex-col justify-start items-center md:items-start text-center md:text-left">
                        <div className="w-full max-w-md bg-white/0 p-0">
                            <div className="flex flex-col items-center md:items-start space-y-2">
                                <div className="flex items-center justify-center bg-purple-50 rounded-full self-center">
                                    <img src={lockImg} alt="Lock Image" className="h-24 w-20" />
                                </div>
                                <div className="w-full">
                                <h2 className="w-full text-center text-2xl md:text-3xl font-semibold mb-1">Set a New Password</h2>
                                </div>
                                <p className="text-gray-600 text-center md:text-center">
                                    Please set a new password to secure your account.
                                </p>

                                <div className="w-full">
                                    <label className="block text-sm font-medium text-gray-700 text-left w-full">Password</label>
                                    <input
                                        type="password"
                                        placeholder="Input Password"
                                        className="w-full mt-2 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none"
                                        value ={password}
                                        onChange={(e)=>setPassword(e.target.value)}
                                    />
                                </div>

                                <div className="w-full">
                                    <label className="block text-sm font-medium text-gray-700 text-left w-full">Confirm Password</label>
                                    <input
                                        type="password"
                                        placeholder="Re-enter your password"
                                        className="w-full mt-2 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none"
                                        value ={confirmPassword}
                                        onChange={(e)=>setConfirmPassword(e.target.value)}
                                    />
                                </div>

                                <button
                                    disabled={isLoading}
                                    className="w-full mt-2 bg-gradient-to-r from-[#8862F2] to-[#5B2ED4] text-white py-3 rounded-full shadow-lg hover:opacity-90 transition"
                                    onClick={()=>handleSubmit()}
                                >
                                    {isLoading ? (
                                        <>
                                        <span className="spinner-border spinner-border-sm me-2" />
                                        Submitting...
                                        </>
                                    ) : (
                                        "Submit"
                                    )}
                                </button>
                            </div>
                        </div>
                    </div>
            </div>
        </div>
    );
}