"use client";
import { useState, useEffect } from "react";

export default function Home() {
  //test
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    // Check API status on component mount
    const checkStatus = async () => {
      try {
        const response = await fetch('/api/chat-status');
        const data = await response.json();
        setIsOnline(data.status === 'online');
      } catch (error) {
        setIsOnline(false);
      }
    };

    checkStatus();
    const interval = setInterval(checkStatus, 30000); // Check every 30 seconds
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-green-900/20 to-gray-900 text-white">
      {/* Header */}
      <header className="border-b border-green-500/30 bg-black/50 backdrop-blur-sm">
        <div className="container mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
              <span className="text-black font-bold text-sm">MC</span>
            </div>
            <h1 className="text-xl font-bold text-green-400">Minecraft AI Chatbot</h1>
          </div>
          <div className="flex items-center space-x-2">
            <div className={`w-3 h-3 rounded-full ${isOnline ? 'bg-green-400' : 'bg-red-400'}`}></div>
            <span className="text-sm text-gray-300">
              {isOnline ? 'Server Online' : 'Server Offline'}
            </span>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-6 py-16">
        <div className="text-center mb-16">
          <h2 className="text-6xl font-bold mb-6 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400 bg-clip-text text-transparent">
            AI-Powered Minecraft
          </h2>
          <h3 className="text-4xl font-semibold mb-8 text-gray-200">
            Chatbot with Real-Time Streaming
          </h3>
          <p className="text-xl text-gray-400 max-w-3xl mx-auto leading-relaxed">
            Transform your Minecraft server with intelligent AI responses. Connect ComputerCraft computers
            to stream chat messages in real-time and get AI-powered conversations that bring your world to life.
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <div className="bg-gray-800/50 backdrop-blur-sm border border-green-500/30 rounded-xl p-6 hover:border-green-400/50 transition-all duration-300">
            <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mb-4">
              <span className="text-green-400 text-2xl">🤖</span>
            </div>
            <h4 className="text-xl font-semibold mb-3 text-green-400">AI Chatbot</h4>
            <p className="text-gray-400">
              Advanced AI responses that understand context and provide intelligent conversations
              in your Minecraft world.
            </p>
          </div>

          <div className="bg-gray-800/50 backdrop-blur-sm border border-blue-500/30 rounded-xl p-6 hover:border-blue-400/50 transition-all duration-300">
            <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mb-4">
              <span className="text-blue-400 text-2xl">⚡</span>
            </div>
            <h4 className="text-xl font-semibold mb-3 text-blue-400">Real-Time Streaming</h4>
            <p className="text-gray-400">
              Live chat monitoring with instant message processing and streaming capabilities
              for seamless integration.
            </p>
          </div>

          <div className="bg-gray-800/50 backdrop-blur-sm border border-purple-500/30 rounded-xl p-6 hover:border-purple-400/50 transition-all duration-300">
            <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mb-4">
              <span className="text-purple-400 text-2xl">🖥️</span>
            </div>
            <h4 className="text-xl font-semibold mb-3 text-purple-400">ComputerCraft Ready</h4>
            <p className="text-gray-400">
              Native ComputerCraft integration with Advanced Peripherals support for
              authentic Minecraft automation.
            </p>
          </div>
        </div>

        {/* How It Works */}
        <div className="bg-gray-800/30 backdrop-blur-sm border border-gray-600/50 rounded-2xl p-8 mb-16">
          <h3 className="text-3xl font-bold text-center mb-8 text-white">How It Works</h3>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl font-bold text-white">
                1
              </div>
              <h5 className="text-lg font-semibold mb-2 text-green-400">Chat Detection</h5>
              <p className="text-gray-400">
                ComputerCraft monitors all Minecraft chat messages in real-time using Advanced Peripherals.
              </p>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-cyan-600 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl font-bold text-white">
                2
              </div>
              <h5 className="text-lg font-semibold mb-2 text-blue-400">AI Processing</h5>
              <p className="text-gray-400">
                Messages are sent to our AI engine for intelligent analysis and response generation.
              </p>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-600 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl font-bold text-white">
                3
              </div>
              <h5 className="text-lg font-semibold mb-2 text-purple-400">Instant Response</h5>
              <p className="text-gray-400">
                Smart replies are broadcast back to your Minecraft server through the chat system.
              </p>
            </div>
          </div>
        </div>

        {/* Tech Stack */}
        <div className="text-center">
          <h3 className="text-2xl font-bold mb-6 text-white">Powered By</h3>
          <div className="flex flex-wrap justify-center gap-6">
            <div className="bg-gray-800/50 border border-gray-600/50 rounded-lg px-4 py-2">
              <span className="text-green-400 font-semibold">ComputerCraft</span>
            </div>
            <div className="bg-gray-800/50 border border-gray-600/50 rounded-lg px-4 py-2">
              <span className="text-blue-400 font-semibold">Advanced Peripherals</span>
            </div>
            <div className="bg-gray-800/50 border border-gray-600/50 rounded-lg px-4 py-2">
              <span className="text-purple-400 font-semibold">Next.js</span>
            </div>
            <div className="bg-gray-800/50 border border-gray-600/50 rounded-lg px-4 py-2">
              <span className="text-emerald-400 font-semibold">AI Integration</span>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-gray-700/50 bg-black/30 backdrop-blur-sm">
        <div className="container mx-auto px-6 py-8 text-center">
          <p className="text-gray-400">
            © 2024 Minecraft AI Chatbot • Built with ❤️ for the Minecraft community
          </p>
        </div>
      </footer>
    </div>
  );
}
