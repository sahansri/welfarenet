import React, { use, useState,useEffect } from "react";

import art1 from "../assets/freepik__talk__24374.png";
import lockImg from "../assets/Lock.png";
import axios from "../config";
import { useNavigate } from "react-router-dom";

export default function ForgotPassword() {
  
  const RESEND_OTP_DELAY = 120; // 120 seconds
  const navigate = useNavigate();
  
  const [step, setStep] = useState("email"); 
  const [email, setEmail] = useState("");
  
  const [otp, setOtp] = useState(new Array(6).fill(""));
  const [timeLeft,setTimeLeft] = useState(RESEND_OTP_DELAY);
  const [showResendOTP,setShowResendOTP]=useState(false);

  const [isSendingEmail, setIsSendingEmail] = useState(false);
  const [isVerifyingOtp, setIsVerifyingOtp] = useState(false);
  const [isResendingOtp, setIsResendingOtp] = useState(false);
  
  // "email" → First screen
  // "verify" → OTP screen
  
  {/*OTP Countdown */}
  useEffect(() => {
    if (step !== "verify") return;

    if (timeLeft <= 0) {
      setShowResendOTP(true);
      return;
    }

    const timer = setTimeout(() => {
      setTimeLeft(prev => prev - 1);
    }, 1000);

    return () => clearTimeout(timer);
  }, [timeLeft, step]);

  {/*Submit Email */}
  const handleEmailSubmit = async () => {
    if (!email) return alert("Please enter your email");

    try {
      setIsSendingEmail(true);

      const response = await axios.post(
        `/member/forgot-password?email=${email}`
      );

      if (response.status === 200) {
        setStep("verify");
        setOtp(Array(6).fill(""));
        setTimeLeft(RESEND_OTP_DELAY);
        setShowResendOTP(false);
      }
    } catch (error) {
      console.error(error);
      alert("Failed to send verification code");
    } finally {
      setIsSendingEmail(false);
    }
  };

  {/*Submit OTP */}
  const handleSubmitOtp = async () => {
    const enteredOtp = otp.join("");

    if (enteredOtp.length !== 6 || otp.includes("")) {
      return alert("Please enter the complete 6-digit OTP");
    }

    try {
      setIsVerifyingOtp(true);

      const response = await axios.post(
        `/member/verify-otp?email=${email}&otp=${enteredOtp}`
      );

      if (response.status === 200) {
        navigate(`/forgot-password/reset-password/${email}`);
      }
    } catch (error) {
      console.error(error);
      alert("Invalid or expired OTP");
      setOtp(Array(6).fill(""));
    } finally {
      setIsVerifyingOtp(false);
    }
  };

  {/*Resend OTP */}
  const handleResendOTP = async () => {
    try {
      setIsResendingOtp(true);
      setShowResendOTP(false);
      setTimeLeft(RESEND_OTP_DELAY);

      const response = await axios.post(
        `/member/forgot-password?email=${email}`
      );

      if (response.status === 200) {
        alert("OTP resent successfully");
      }
    } catch (error) {
      console.error(error);
      alert("Failed to resend OTP");
    } finally {
      setIsResendingOtp(false);
    }
  };

  return (
    <div className="max-w-screen-lg mx-auto p-20">
      <div className="w-full bg-white flex flex-col md:flex-row px-6 md:px-10 py-8 rounded-3xl">
        
        {/* LEFT SIDE */}
        <div className="w-full md:w-1/2 pt-1 pr-20 flex flex-col justify-center items-center text-center md:text-left">
          <h1 className="text-4xl md:text-5xl font-bold mb-2">WelfareNet</h1>
          <p className="text-gray-700 text-lg">Community Management System</p>
          <p className="text-gray-900 font-semibold text-base mt-1">Pathum Uyana Welfare Society</p>
          <p className="text-gray-900 font-semibold text-base mt-1">Kundasale.</p>

          <div className="w-full flex justify-center md:justify-end mt-6">
            <img 
              src={art1} 
              alt="Artwork" 
              className="w-11/12 md:w-full h-auto md:h-80 rounded-lg object-contain"
            />
          </div>
        </div>

        {/* Divider */}
        <div className="hidden md:block w-px bg-gray-400 mx-6"></div>

        {/* RIGHT SIDE */}
        <div className="w-full md:w-1/2 pl-6 md:pl-20 flex flex-col justify-start items-center md:items-start text-center md:text-left">

          <div className="flex flex-col items-center">

            {/* Lock Icon */}
            <div className="flex items-center justify-center bg-purple-50 rounded-full p-3">
              <img src={lockImg} alt="Lock" className="h-24 w-20" />
            </div>

            {/* SWITCH UI BASED ON CURRENT STEP */}
            {step === "email" && (
              <>
                <h2 className="text-2xl md:text-3xl font-semibold mb-2">Forgot Password</h2>
                <p className="text-gray-600 mb-6 text-center">
                  A verification code will be sent to your email to reset your password.
                </p>

                <label className="block text-sm font-medium text-gray-700 text-left w-full">Email</label>
                <input
                  type="email"
                  value={email}
                  onChange = {(e)=> {setEmail(e.target.value)}}
                  placeholder="you@example.com"
                  className="w-full mt-2 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none"
                />

                <button
                  disabled={isSendingEmail}
                  onClick={() =>  handleEmailSubmit()}
                  className="w-full mt-6 bg-gradient-to-r from-[#8862F2] to-[#5B2ED4] text-white py-3 rounded-full shadow-lg hover:opacity-90 transition"
                >
                  {isSendingEmail ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2" />
                        Processing...
                      </>
                    ) : (
                      "Send Verification Code"
                    )}<br />
                </button>

                <div className="mt-4 text-sm">
                  <a href="/" className="text-purple-600 hover:underline">Back to sign in</a>
                </div>
              </>
            )}

            {step === "verify" && (
              <>
                <h2 className="text-2xl md:text-3xl font-semibold mb-3">Forgot Password</h2>
                <p className="text-gray-600 text-center mb-6">
                  A reset code has been sent to <b>{email}</b>. 
                  Enter the code below.
                </p>

                {/* OTP BOXES */}
                <div className="flex gap-2 mb-4">
                  {otp.map((digit,idx) => (
                    <input
                      key={idx}
                      value={digit}
                      maxLength="1"
                      className="w-12 h-12 border border-gray-300 rounded-lg text-center text-xl focus:ring-2 focus:ring-purple-500 outline-none"
                      onChange={(e)=>{
                        const newOtp = [...otp];
                        newOtp[idx] = e.target.value;
                        setOtp(newOtp);
                        if (e.target.value && e.target.nextSibling) {
                          e.target.nextSibling.focus();
                        }
                      }}
                    />
                  ))}
                </div>

                <button
                  disabled={isVerifyingOtp}
                  onClick={()=>handleSubmitOtp()}
                  className="w-full bg-gradient-to-r from-[#8862F2] to-[#5B2ED4] text-white py-3 rounded-full shadow-lg hover:opacity-90 transition"
                >
                  {isVerifyingOtp ? "Verifying..." : "Verify Code"}
                </button>
              </>
            )}

          </div>
        </div>
      </div>
    </div>
  );
}
