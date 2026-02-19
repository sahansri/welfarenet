//Added to fix module resolution issue with sockjs-client
declare module 'sockjs-client/dist/sockjs'{
    import SockJS from 'sockjs-client';
    export default SockJS;
}