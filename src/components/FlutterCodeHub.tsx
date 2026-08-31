import React, { useState } from 'react';
import { 
  Code2, 
  Copy, 
  Check, 
  Download, 
  FileCode, 
  Terminal, 
  Layers, 
  Smartphone, 
  Globe, 
  Cpu, 
  FolderTree,
  ExternalLink,
  ShieldCheck
} from 'lucide-react';
import { FLUTTER_CODE_FILES } from '../data/flutterSourceCode';
import { FlutterCodeFile } from '../types';

export const FlutterCodeHub: React.FC = () => {
  const [selectedFile, setSelectedFile] = useState<FlutterCodeFile>(FLUTTER_CODE_FILES[0]);
  const [copied, setCopied] = useState(false);
  const [activeTab, setActiveTab] = useState<'code' | 'architecture' | 'cli'>('code');

  const handleCopyCode = () => {
    navigator.clipboard.writeText(selectedFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadFile = () => {
    const blob = new Blob([selectedFile.content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = selectedFile.filename;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      
      {/* Hero Header */}
      <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 shadow-sm">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-[#E9E4DB]">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                Flutter 3.19+ Cross-Platform
              </span>
              <span className="text-xs text-[#8C887D]">Open Source MIT Licensed</span>
            </div>
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A] mt-1.5">Multiplatform Flutter Codebase & Architecture</h1>
            <p className="text-xs text-[#6B6E68] mt-0.5">Production-ready Flutter & Dart source files targeting iOS, Android, and Web with Riverpod state management and E2EE messaging</p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setActiveTab('code')}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                activeTab === 'code' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-[#FAF9F6] border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Source Code Viewer
            </button>
            <button
              onClick={() => setActiveTab('architecture')}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                activeTab === 'architecture' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-[#FAF9F6] border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Architecture Diagram
            </button>
            <button
              onClick={() => setActiveTab('cli')}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                activeTab === 'cli' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-[#FAF9F6] border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              CLI & Build Guide
            </button>
          </div>
        </div>

        {/* Multiplatform targets indicator */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-4 text-xs">
          <div className="bg-[#FAF9F6] p-3.5 rounded-2xl border border-[#E9E4DB] flex items-center gap-3">
            <div className="p-2 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              <Smartphone className="w-4 h-4" />
            </div>
            <div>
              <p className="font-bold text-[#2C2E2A]">Apple iOS</p>
              <p className="text-[#6B6E68] text-[11px]">Cupertino HIG, APNs Push, Secure Enclave</p>
            </div>
          </div>

          <div className="bg-[#FAF9F6] p-3.5 rounded-2xl border border-[#E9E4DB] flex items-center gap-3">
            <div className="p-2 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              <Cpu className="w-4 h-4" />
            </div>
            <div>
              <p className="font-bold text-[#2C2E2A]">Google Android</p>
              <p className="text-[#6B6E68] text-[11px]">Material 3, Firebase FCM, Biometrics</p>
            </div>
          </div>

          <div className="bg-[#FAF9F6] p-3.5 rounded-2xl border border-[#E9E4DB] flex items-center gap-3">
            <div className="p-2 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              <Globe className="w-4 h-4" />
            </div>
            <div>
              <p className="font-bold text-[#2C2E2A]">Flutter Web</p>
              <p className="text-[#6B6E68] text-[11px]">CanvasKit, Web Push, Responsive Grid</p>
            </div>
          </div>
        </div>
      </div>

      {/* TAB 1: Code Viewer */}
      {activeTab === 'code' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] overflow-hidden grid grid-cols-1 lg:grid-cols-12 shadow-sm">
          
          {/* File Tree Left Sidebar */}
          <div className="lg:col-span-4 bg-[#FAF9F6] p-4 border-r border-[#E9E4DB] space-y-3">
            <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#2C2E2A]">
              <FolderTree className="w-4 h-4 text-[#5F6F52]" />
              <span>Project Structure</span>
            </div>

            <div className="space-y-1">
              {FLUTTER_CODE_FILES.map((file) => {
                const isSelected = selectedFile.filename === file.filename;
                return (
                  <button
                    key={file.filename}
                    onClick={() => setSelectedFile(file)}
                    className={`w-full text-left p-2.5 rounded-xl text-xs transition-all flex items-center justify-between cursor-pointer ${
                      isSelected
                        ? 'bg-[#FEFAE0] text-[#5F6F52] border border-[#5F6F52]/40 font-bold shadow-xs'
                        : 'text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]/60 border border-transparent'
                    }`}
                  >
                    <div className="flex items-center gap-2 truncate">
                      <FileCode className={`w-4 h-4 ${isSelected ? 'text-[#5F6F52]' : 'text-[#8C887D]'}`} />
                      <span className="truncate font-mono">{file.path}</span>
                    </div>
                    <span className="text-[10px] text-[#8C887D] uppercase font-mono">{file.language}</span>
                  </button>
                );
              })}
            </div>

            <div className="p-3.5 bg-white rounded-2xl border border-[#E9E4DB] text-[11px] text-[#6B6E68] space-y-1 mt-4">
              <p className="font-bold text-[#2C2E2A]">{selectedFile.filename}</p>
              <p className="text-[#6B6E68] leading-relaxed">{selectedFile.description}</p>
            </div>
          </div>

          {/* Code Viewer Right Box */}
          <div className="lg:col-span-8 flex flex-col bg-[#FAF9F6]">
            
            {/* Action Bar */}
            <div className="px-5 py-3.5 bg-white border-b border-[#E9E4DB] flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="text-xs font-mono font-bold text-[#5F6F52]">{selectedFile.path}</span>
              </div>

              <div className="flex items-center gap-2">
                <button
                  onClick={handleCopyCode}
                  className="px-3 py-1.5 rounded-xl bg-[#FAF9F6] hover:bg-[#F2EDE4] text-[#2C2E2A] border border-[#D9D1C5] text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
                >
                  {copied ? <Check className="w-3.5 h-3.5 text-[#5F6F52]" /> : <Copy className="w-3.5 h-3.5 text-[#6B6E68]" />}
                  <span>{copied ? 'Copied!' : 'Copy Dart'}</span>
                </button>

                <button
                  onClick={handleDownloadFile}
                  className="px-3.5 py-1.5 rounded-xl bg-[#5F6F52] hover:bg-[#4E5C43] text-white text-xs font-bold flex items-center gap-1.5 shadow-sm transition-colors cursor-pointer"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>Download</span>
                </button>
              </div>
            </div>

            {/* Code Body */}
            <div className="p-5 overflow-x-auto text-xs font-mono text-[#E9E4DB] max-h-[600px] leading-relaxed select-text bg-[#242724]">
              <pre className="whitespace-pre">
                <code>{selectedFile.content}</code>
              </pre>
            </div>

          </div>

        </div>
      )}

      {/* TAB 2: Architecture Diagram */}
      {activeTab === 'architecture' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-6 shadow-sm">
          <h2 className="text-lg font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
            <Layers className="w-5 h-5 text-[#5F6F52]" />
            Clean Feature-First Flutter Architecture
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-xs">
            <div className="bg-[#FAF9F6] border border-[#E9E4DB] p-4.5 rounded-2xl space-y-2">
              <span className="px-2.5 py-0.5 rounded-md bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] font-bold text-[10px] uppercase">1. UI Presentation</span>
              <h4 className="font-serif font-bold text-[#2C2E2A] text-sm">Adaptive Widgets</h4>
              <p className="text-[#6B6E68] leading-relaxed">
                Cupertino widgets on iOS, Material 3 on Android, and Fluid Flex Layout for Web.
              </p>
            </div>

            <div className="bg-[#FAF9F6] border border-[#E9E4DB] p-4.5 rounded-2xl space-y-2">
              <span className="px-2.5 py-0.5 rounded-md bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] font-bold text-[10px] uppercase">2. State Management</span>
              <h4 className="font-serif font-bold text-[#2C2E2A] text-sm">Flutter Riverpod 2.5</h4>
              <p className="text-[#6B6E68] leading-relaxed">
                Compile-safe reactive state with AsyncNotifier, code generation, and auto-dispose caching.
              </p>
            </div>

            <div className="bg-[#FAF9F6] border border-[#E9E4DB] p-4.5 rounded-2xl space-y-2">
              <span className="px-2.5 py-0.5 rounded-md bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] font-bold text-[10px] uppercase">3. Real-Time Network</span>
              <h4 className="font-serif font-bold text-[#2C2E2A] text-sm">WebSocket + Push</h4>
              <p className="text-[#6B6E68] leading-relaxed">
                Full-duplex WebSocket stream for live chat, combined with APNs (iOS) & FCM (Android).
              </p>
            </div>

            <div className="bg-[#FAF9F6] border border-[#E9E4DB] p-4.5 rounded-2xl space-y-2">
              <span className="px-2.5 py-0.5 rounded-md bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] font-bold text-[10px] uppercase">4. Security & E2EE</span>
              <h4 className="font-serif font-bold text-[#2C2E2A] text-sm">AES-256-GCM + FERPA</h4>
              <p className="text-[#6B6E68] leading-relaxed">
                Client-side ECDH key agreement with hardware-backed Keystore / Keychain storage.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* TAB 3: CLI Guide */}
      {activeTab === 'cli' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-5 shadow-sm">
          <h2 className="text-lg font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
            <Terminal className="w-5 h-5 text-[#5F6F52]" />
            CLI Setup & Multiplatform Build Instructions
          </h2>

          <div className="space-y-4 text-xs font-mono">
            <div className="bg-[#FAF9F6] p-4.5 rounded-2xl border border-[#E9E4DB] space-y-2">
              <p className="text-[#2C2E2A] font-sans font-bold">1. Initialize and Install Dependencies</p>
              <pre className="text-[#5F6F52] bg-[#242724] p-3.5 rounded-xl text-[#A9B388]">git clone https://github.com/ilmiya/ilmiya-flutter.git
cd ilmiya-flutter
flutter pub get</pre>
            </div>

            <div className="bg-[#FAF9F6] p-4.5 rounded-2xl border border-[#E9E4DB] space-y-2">
              <p className="text-[#2C2E2A] font-sans font-bold">2. Run in Development on Any Device</p>
              <pre className="bg-[#242724] p-3.5 rounded-xl text-[#A9B388]"># Run on Chrome / Web browser
flutter run -d chrome

# Run on iOS Simulator or connected iPhone
flutter run -d ios

# Run on Android Emulator or Pixel device
flutter run -d android</pre>
            </div>

            <div className="bg-[#FAF9F6] p-4.5 rounded-2xl border border-[#E9E4DB] space-y-2">
              <p className="text-[#2C2E2A] font-sans font-bold">3. Compile Production Distribution Builds</p>
              <pre className="bg-[#242724] p-3.5 rounded-xl text-[#A9B388]"># Production Web Build
flutter build web --release --web-renderer canvaskit

# Production Android APK / AAB for Google Play
flutter build appbundle --release

# Production iOS Archive for App Store Connect
flutter build ipa --release</pre>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
