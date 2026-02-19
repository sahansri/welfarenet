import React, { createContext, useContext, useState } from 'react';

const TopNavBarContext = createContext();

export function TobNavBarProvider({ children }) {
  const [TopNavBarOpen, setTopNavBarOpen] = useState(true);
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <TopNavBarContext.Provider value={{ TopNavBarOpen, setTopNavBarOpen, activeTab, setActiveTab }}>
      {children}
    </TopNavBarContext.Provider>
  );
}

export function useTopNavBar() {
  const context = useContext(TopNavBarContext);
  if (!context) {
    throw new Error('useSidebar must be used within a SidebarProvider');
  }
  return context;
}
