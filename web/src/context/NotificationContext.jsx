import {useState,useEffect,useContext,createContext} from 'react';
import {Client} from'@stomp/stompjs';
import SockJs from 'sockjs-client/dist/sockjs';


export const NotificationContext = createContext();

export const NotificationContextProvider = ({children})=>{
    const [notifications, setNotifications] = useState([]);
    const[stompClient,setStompClient]=useState(null);
    const [connected,setConnected]=useState(false);


    useEffect(()=>{
        const token = localStorage.getItem('token');
        const role = localStorage.getItem('role');

        const socket = new SockJs('http://localhost:8080/ws');

        const client = new Client({
            webSocketFactory:()=>socket,
            reconnectionDelay:5000,
            connectHeaders:{
                'Authorization':`Bearer ${token}`
            },
            onConnect:()=>{
                console.log('Connected to WebSocket');
                setConnected(true);

                const handleMessage = (msg) => {
                try {
                    const notif =
                    typeof msg.body === "string" ? JSON.parse(msg.body) : msg.body;
                    setNotifications((prevNotifs) => [notif, ...prevNotifs]);
                } catch (error) {
                    console.error("Error parsing message:", error);
                }
                };

                //Role base Dubscription
                if(role !== 'null' && token !== 'null'){
                    const roleToLower = role.toLowerCase();
                    client.subscribe(`/topic/notifications/${roleToLower}`,handleMessage);
                }

                //Genaral Subscription
                client.subscribe("/topic/notifications/broadcast", handleMessage);
            },
            onWebSocketClose: () => {
                console.warn(" WebSocket closed!");
                setConnected(false);
        },
        });

        client.activate();
        setStompClient(client);

        return () => {
        if (client && connected) {
            client.deactivate();
        }
        };

    },[]);

    return(
        <NotificationContext.Provider
            value={{notifications,setNotifications,stompClient,connected}}
        >
            {children}
        </NotificationContext.Provider>
    );

};