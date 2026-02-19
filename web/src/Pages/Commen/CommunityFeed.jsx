import { Newspaper, Heart, MessageCircle, Share2, MoreVertical, Flag, Edit2, Trash2, ShieldAlert,AlertTriangle,RefreshCcw } from "lucide-react";
import { useState,useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery,useQueryClient } from "@tanstack/react-query";
import axios from "../../config";


export default function CommunityFeed() {
  const role = localStorage.getItem('role');
  const navigate = useNavigate();
  const token = localStorage.getItem('token');
  const queryClient = useQueryClient();
  

  const [showCreatePost, setShowCreatePost] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [deletePostId, setDeletePostId] = useState(null);
  const [activeMenu, setActiveMenu] = useState(null);
  const [newPost, setNewPost] = useState({
    content: "",
    media: null,
    mediaPreview: null,
    mediaType: null,
  });

  const fetchPosts = async ()=>{
        const response = await axios.get('/newsfeed/sorted-bydate',{
            headers:{
              'Authorization':`Bearer ${token}`,
              'Content-Type':'application/json'
            }
          });
        if(Array.isArray(response.data)){
            console.log("Fetched Posts:", response.data);
            return response.data;
        }
        else{
            return [];
        }    
    }

  const{
    data:posts=[],
    isLoading,
    isError,
    error,
    refetch
  }=useQuery({
    queryKey:['Posts'],
    queryFn:fetchPosts,
    staleTime: 5*60*1000, //fetch after 5mins
    cacheTime:30*60*1000 // Keep in memory 30mins
  })

  
  const handleLike = (postId) => {
    setPosts(posts.map(post => 
      post.id === postId 
        ? { ...post, liked: !post.liked, likes: post.liked ? post.likes - 1 : post.likes + 1 }
        : post
    ));
  };

  const handleDeleteClick = (postId) => {
    setDeletePostId(postId);
    setShowDeleteModal(true);
    setActiveMenu(null);
  };

  const confirmDelete = () => {
    setPosts(posts.filter(post => post.id !== deletePostId));
    setShowDeleteModal(false);
    setDeletePostId(null);
  };

  const cancelDelete = () => {
    setShowDeleteModal(false);
    setDeletePostId(null);
  };

  const handleReportManagement = () => {
    if(role === 'president'){
      navigate(`/${role}/feed/reports`)
    }
  };

  const handleEditPost = (postId) => {
    alert(`Navigate to: /admin/newsfeed/edit/${postId}`);
    setActiveMenu(null);
  };

  const toggleMenu = (postId) => {
    setActiveMenu(activeMenu === postId ? null : postId);
  };

  if (isError){
        return (
            <div className="min-h-screen flex flex-col items-center justify-center pt-30 py-12 text-center">
            <AlertTriangle className="h-10 w-10 text-red-500 mb-4" />
            <h2 className="text-lg font-semibold text-gray-800">
                Something went wrong
            </h2>
            <p className="text-sm text-gray-600 mt-2 max-w-sm">
                {error?.message || "We couldn’t load the data. Please try again."}
            </p>
            <button
                onClick={refetch}
                className="mt-6 inline-flex items-center gap-2 rounded-lg bg-red-500 px-4 py-2 text-sm font-medium text-white hover:bg-red-600 transition"
            >
                <RefreshCcw size={16} />
                Retry
            </button>
            </div>
        );
    }

  if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="text-center">
                <div className="w-12 h-12 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mx-auto"></div>
                <p className="mt-4 text-gray-700 font-medium">
                Loading Posts...
                </p>
            </div>
            </div>
        );
    }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#7A5AF8] via-purple-600 to-[#5D45BC] p-4 md:p-8">
      <div className="max-w-6xl mx-auto pt-28">
        <main className="transition-all duration-300 pt-4">
          <div className="max-w-5xl mx-auto p-4">
            {/* Header */}
            <div className="bg-gradient-to-r from-purple-900 to-purple-800 rounded-3xl shadow-2xl p-8 md:p-10 mb-8 text-white relative overflow-hidden transform hover:scale-[1.02] transition-transform duration-300">
              <div className="absolute top-0 right-0 w-64 h-64 bg-white opacity-10 rounded-full -mr-32 -mt-32 blur-3xl"></div>
              <div className="absolute bottom-0 left-0 w-48 h-48 bg-white opacity-10 rounded-full -ml-24 -mb-24 blur-2xl"></div>
              <div className="absolute top-1/2 right-1/4 w-32 h-32 bg-yellow-300 opacity-10 rounded-full blur-2xl"></div>
              
              <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div>
                  <div className="flex items-center gap-4 mb-3">
                    <div className="bg-white bg-opacity-20 p-3 rounded-2xl backdrop-blur-sm">
                      <Newspaper className="w-8 h-8 text-purple-900" />
                    </div>
                    <div>
                      <h1 className="text-4xl font-bold tracking-tight">News Feed</h1>
                    </div>
                  </div>
                  <p className="text-purple-100 text-lg">See what's happening in your community</p>
                </div>
                {role === 'president'&&(
                  <button
                    onClick={handleReportManagement}
                    className="bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold hover:bg-purple-50 transition-all shadow-2xl hover:shadow-purple-500/50 hover:scale-105 flex items-center gap-3 whitespace-nowrap group"
                  >
                    <ShieldAlert className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                    Manage Reports
                  </button>
                )}
              </div>
            </div>

            {/* Posts */}
            <div className="space-y-6">
              {posts.map((post) => (
                <div
                  key={post.postID}
                  className="bg-white rounded-3xl shadow-xl hover:shadow-2xl transition-all duration-300 overflow-hidden border border-gray-100"
                >
                  {/* Colorful Top Border */}
                  <div className="h-2 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500"></div>
                  
                  {/* Header */}
                  <div className="p-6 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <img
                        src={post.avatar}
                        className="w-12 h-12 rounded-full border-2 border-purple-200 shadow-md"
                        alt={post.author.fullName}
                      />
                      <div>
                        <h3 className="text-gray-900 font-semibold">{post.author.fullName}</h3>
                        <p className="text-gray-500 text-sm">{post.timePosted}</p>
                      </div>
                    </div>
                    
                    {/* Action Menu */}
                    <div className="relative">
                      <button
                        onClick={() => toggleMenu(post.postID)}
                        className="p-2 hover:bg-gray-100 rounded-lg transition"
                      >
                        <MoreVertical className="w-5 h-5 text-gray-600" />
                      </button>
                      
                      {activeMenu === post.postID && (
                        <div className="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-2xl border border-gray-200 py-2 z-10">
                          <button
                            onClick={() => handleEditPost(post.postID)}
                            className="w-full px-4 py-2 text-left hover:bg-gray-50 flex items-center gap-2 text-gray-700"
                          >
                            <Edit2 className="w-4 h-4" />
                            Edit Post
                          </button>
                          <button
                            onClick={() => handleDeleteClick(post.postID)}
                            className="w-full px-4 py-2 text-left hover:bg-gray-50 flex items-center gap-2 text-red-600"
                          >
                            <Trash2 className="w-4 h-4" />
                            Delete Post
                          </button>
                          {post.reports > 0 && (
                            <div className="px-4 py-2 border-t border-gray-100 mt-2">
                              <div className="flex items-center gap-2 text-orange-600 text-sm">
                                <Flag className="w-4 h-4" />
                                {post.reports} Report{post.reports > 1 ? 's' : ''}
                              </div>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Content */}
                  <div className="px-6 pb-4 ">
                    <p className="text-gray-800 leading-relaxed">{post.content}</p>
                  </div>

                  {/* Media */}
                  {post.images?.map((image) => (
                    <div className="aspect-square w-48 overflow-hidden rounded-xl">
                      <img
                        key={image.imgId}
                        src={image.imagePath}
                        alt="Post"
                        loading="lazy"
                        className="w-full h-full object-cover rounded-lg mt-3"
                    />
                    </div>
                  ))}   

                  {/* Engagement Stats */}
                  <div className="px-6 py-3 border-t border-gray-100 flex items-center justify-between text-sm text-gray-600">
                    <span>{post.likeCount} likes</span>
                    <span>{post.commentCount} comments</span>
                  </div>

                  {/* Action Buttons */}
                  <div className="px-6 pb-6 flex gap-2 border-t border-gray-100 pt-3">
                    <button
                      onClick={() => handleLike(post.postID)}
                      className={`flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl font-medium transition-all ${
                        post.liked
                          ? 'bg-gradient-to-r from-pink-500 to-red-500 text-white shadow-md hover:from-pink-600 hover:to-red-600'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                    >
                      <Heart className={`w-5 h-5 ${post.liked ? 'fill-current' : ''}`} />
                      Like
                    </button>
                    
                    <button className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 font-medium transition-all">
                      <MessageCircle className="w-5 h-5" />
                      Comment
                    </button>
                    
                    <button className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 font-medium transition-all">
                      <Share2 className="w-5 h-5" />
                      Share
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </main>

        {/* Delete Confirmation Modal */}
        {showDeleteModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 transform transition-all">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                  <Trash2 className="w-6 h-6 text-red-600" />
                </div>
                <h3 className="text-xl font-bold text-gray-900">Delete Post</h3>
              </div>
              <p className="text-gray-600 mb-6">
                Are you sure you want to delete this post? This action cannot be undone.
              </p>
              <div className="flex gap-3 justify-end">
                <button
                  onClick={cancelDelete}
                  className="px-5 py-2.5 text-gray-700 hover:bg-gray-100 rounded-xl transition-all font-medium"
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDelete}
                  className="px-5 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all font-medium"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}