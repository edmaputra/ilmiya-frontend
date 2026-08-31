import React from 'react';
import { DeviceView } from '../types';
import { Wifi, Battery, Signal } from 'lucide-react';

interface DeviceFrameWrapperProps {
  deviceView: DeviceView;
  children: React.ReactNode;
}

export const DeviceFrameWrapper: React.FC<DeviceFrameWrapperProps> = ({
  deviceView,
  children,
}) => {
  if (deviceView === 'responsive') {
    return <div className="w-full">{children}</div>;
  }

  if (deviceView === 'ios') {
    return (
      <div className="flex justify-center py-6">
        {/* iPhone 16 Pro Frame */}
        <div className="w-[400px] h-[850px] bg-[#1E201E] rounded-[50px] p-3 shadow-2xl ring-8 ring-[#2C2E2A] relative flex flex-col overflow-hidden border border-[#D9D1C5]/30">
          
          {/* Dynamic Island */}
          <div className="absolute top-4 left-1/2 -translate-x-1/2 w-28 h-7 bg-black rounded-full z-50 flex items-center justify-between px-3">
            <div className="w-2.5 h-2.5 rounded-full bg-[#2C2E2A] border border-[#5F6F52]/40" />
            <div className="w-2.5 h-2.5 rounded-full bg-[#5F6F52]/50" />
          </div>

          {/* iOS Status Bar */}
          <div className="pt-2 px-6 pb-2 flex items-center justify-between text-[#2C2E2A] text-[11px] font-semibold z-40 bg-[#FAF9F6]">
            <span>9:41</span>
            <div className="flex items-center gap-1.5 text-[#2C2E2A]">
              <Signal className="w-3 h-3" />
              <Wifi className="w-3 h-3" />
              <Battery className="w-3.5 h-3.5" />
            </div>
          </div>

          {/* Screen Content */}
          <div className="flex-1 overflow-y-auto rounded-[38px] bg-[#FAF9F6] text-[#2C2E2A] relative p-1">
            {children}
          </div>

          {/* Home Indicator */}
          <div className="py-2 flex justify-center bg-[#FAF9F6]">
            <div className="w-32 h-1 bg-[#2C2E2A]/40 rounded-full" />
          </div>
        </div>
      </div>
    );
  }

  if (deviceView === 'android') {
    return (
      <div className="flex justify-center py-6">
        {/* Android Pixel 9 Pro Frame */}
        <div className="w-[410px] h-[860px] bg-[#1E201E] rounded-[44px] p-3 shadow-2xl ring-8 ring-[#2C2E2A] relative flex flex-col overflow-hidden border border-[#D9D1C5]/30">
          
          {/* Camera Hole Punch */}
          <div className="absolute top-4 left-1/2 -translate-x-1/2 w-4 h-4 bg-black rounded-full z-50 ring-1 ring-[#5F6F52]/40" />

          {/* Android Status Bar */}
          <div className="pt-2 px-6 pb-2 flex items-center justify-between text-[#2C2E2A] text-[11px] font-mono z-40 bg-[#FAF9F6]">
            <span>10:30</span>
            <div className="flex items-center gap-2 text-[#2C2E2A]">
              <Wifi className="w-3.5 h-3.5" />
              <Battery className="w-3.5 h-3.5" />
            </div>
          </div>

          {/* Screen Content */}
          <div className="flex-1 overflow-y-auto rounded-[32px] bg-[#FAF9F6] text-[#2C2E2A] relative p-1">
            {children}
          </div>

          {/* Android Navigation Bar */}
          <div className="py-2 flex justify-center bg-[#FAF9F6]">
            <div className="w-20 h-1 bg-[#2C2E2A]/40 rounded-full" />
          </div>
        </div>
      </div>
    );
  }

  return <div className="w-full">{children}</div>;
};
