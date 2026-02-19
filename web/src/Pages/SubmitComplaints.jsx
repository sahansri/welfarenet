import React, { useState } from "react";
import { Send, Loader2, Upload } from "lucide-react";

export default function SubmitComplaints() {
  const [form, setForm] = useState({
    type: "complaint",
    title: "",
    message: "",
    priority: "normal",
    attachment: null,
  });

  const [loading, setLoading] = useState(false);
  const [successMsg, setSuccessMsg] = useState("");

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleFile = (e) => {
    setForm((prev) => ({ ...prev, attachment: e.target.files[0] }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setSuccessMsg("");

    try {
      // Prepare FormData for backend
      const data = new FormData();
      data.append("type", form.type);
      data.append("title", form.title);
      data.append("message", form.message);
      data.append("priority", form.priority);
      if (form.attachment) data.append("attachment", form.attachment);

      // API call (Spring Boot backend)
      await fetch("/api/complaints", { method: "POST", body: data });

      setSuccessMsg("Your complaint/suggestion has been submitted.");
      setForm({
        type: "complaint",
        title: "",
        message: "",
        priority: "normal",
        attachment: null,
      });
    } catch (err) {
      console.error(err);
      alert("Something went wrong. Try again.");
    }

    setLoading(false);
  };

  return (
    <div className="max-w-xl mx-auto bg-white p-6 rounded-2xl shadow-md border">
      <h2 className="text-xl font-semibold mb-4">Submit a Complaint or Suggestion</h2>

      <form onSubmit={handleSubmit} className="space-y-4">

        {/* Type Selector */}
        <div>
          <label className="block mb-1 font-medium">Type</label>
          <select
            name="type"
            value={form.type}
            onChange={handleChange}
            className="w-full border rounded-lg p-2"
          >
            <option value="complaint">Complaint</option>
            <option value="suggestion">Suggestion</option>
          </select>
        </div>

        {/* Title */}
        <div>
          <label className="block mb-1 font-medium">Title</label>
          <input
            type="text"
            name="title"
            value={form.title}
            onChange={handleChange}
            placeholder="Short title for your complaint"
            className="w-full border rounded-lg p-2"
            required
          />
        </div>

        {/* Message */}
        <div>
          <label className="block mb-1 font-medium">Message</label>
          <textarea
            name="message"
            value={form.message}
            onChange={handleChange}
            placeholder="Describe your complaint or suggestion"
            className="w-full border rounded-lg p-2 h-32"
            required
          ></textarea>
        </div>

        {/* Priority (optional) */}
        {form.type === "complaint" && (
          <div>
            <label className="block mb-1 font-medium">Priority</label>
            <select
              name="priority"
              value={form.priority}
              onChange={handleChange}
              className="w-full border rounded-lg p-2"
            >
              <option value="low">Low</option>
              <option value="normal">Normal</option>
              <option value="high">High</option>
            </select>
          </div>
        )}

        {/* File Upload */}
        <div>
          <label className="block mb-1 font-medium">Attachment (optional)</label>
          <div className="flex items-center gap-3">
            <label className="cursor-pointer flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg hover:bg-gray-200">
              <Upload size={18} />
              <span>Upload File</span>
              <input type="file" onChange={handleFile} className="hidden" />
            </label>
            {form.attachment && (
              <span className="text-sm text-gray-600">{form.attachment.name}</span>
            )}
          </div>
        </div>

        {/* Submit */}
        <button
          type="submit"
          disabled={loading}
          className="w-full flex items-center justify-center gap-2 bg-purple-600 text-white py-2 rounded-lg hover:bg-purple-700 transition disabled:opacity-50"
        >
          {loading ? <Loader2 className="animate-spin" size={18} /> : <Send size={18} />}
          Submit
        </button>

        {successMsg && (
          <p className="text-green-600 text-center mt-2">{successMsg}</p>
        )}
      </form>
    </div>
  );
}
