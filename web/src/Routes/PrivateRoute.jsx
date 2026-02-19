import { useNavigate } from "react-router-dom";
import { useEffect } from "react";
import axios from '../config';

export default function PrivateRoute({ children,role }) {
    const navigate = useNavigate();
    const userRole = localStorage.getItem("role");
    const token = localStorage.getItem("token");

    const validateToken = async ()=>{
        if(!token){
            console.log("No token found!");
            return false;
        }

        try{
            //Replace with actual API endpoint for token validation
            const response = await axios.get("/auth/validate-token",{
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });
            console.log("Token validation response:", response.data);
            return response;
        }
        catch(error){
            console.error("Token validation failed:", error);
            return false;
        }
    }

    useEffect(()=>{
        if(!token || userRole !== role){
            localStorage.clear();
            navigate("/");
        }
        const checkToken = async ()=>{
            const isValid = await validateToken();
            if(!isValid || isValid.status !== 200){
                localStorage.clear();
                navigate("/");
            }
        }
        checkToken();
    },[role,userRole,token]);

    return children;
}