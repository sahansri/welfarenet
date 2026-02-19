const news = [
  {
    id: 1,
    title: "Community Garden Opening",
    desc: "The community garden will be officially opened next week.",
    date: "2025-11-10"
  },
  {
    id: 2,
    title: "Blood Donation Camp",
    desc: "Join us for the annual blood donation event this Saturday.",
    date: "2025-11-08"
  }
];

export default function NewsFeed() {
  return (
    <div className="mt-8">
      <h2 className="text-2xl font-bold mb-4">Community Updates</h2>

      <div className="space-y-4">
        {news.map((item) => (
          <div
            key={item.id}
            className="border border-gray-200 p-5 rounded-2xl shadow-sm bg-white"
          >
            <h3 className="text-xl font-semibold">{item.title}</h3>
            <p className="text-gray-600">{item.desc}</p>
            <span className="text-gray-400 text-sm">{item.date}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
