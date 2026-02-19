import { useState, useEffect } from "react";

const announcements = [
  "Meeting this Sunday at 4 PM at the Community Hall.",
  "New WelfareNet mobile app update available!",
  "Maintenance work in Block A from Monday to Wednesday."
];

export default function AnnouncementCarousel() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setIndex((i) => (i + 1) % announcements.length);
    }, 4000);

    return () => clearInterval(timer);
  }, []);

  return (
    <div className="w-full bg-gradient-to-r from-purple-500 to-purple-700 text-white py-6 px-6 rounded-2xl shadow-lg">
      <h2 className="text-xl font-semibold mb-2">Important Announcements</h2>
      <p className="text-lg transition-all duration-500">{announcements[index]}</p>
    </div>
  );
}
