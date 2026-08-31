import React from 'react';

interface IlmiyaLogoProps {
  className?: string;
  size?: number | string;
  variant?: 'full' | 'icon' | 'badge' | 'app-squircle';
  showText?: boolean;
}

/**
 * Official ILMIYA Vector Logo & Favicon Artwork
 * Accurately vectorized from user-provided assets.
 */
export const IlmiyaLogo: React.FC<IlmiyaLogoProps> = ({
  className = '',
  size = 40,
  variant = 'icon',
  showText = false,
}) => {
  if (variant === 'app-squircle') {
    return (
      <div 
        className={`relative inline-flex items-center justify-center shrink-0 overflow-hidden shadow-md ${className}`}
        style={{ width: size, height: size }}
      >
        <svg 
          viewBox="0 0 512 512" 
          className="w-full h-full" 
          fill="none" 
          xmlns="http://www.w3.org/2000/svg"
        >
          <defs>
            <linearGradient id="ilmiyaSquircleGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#2D7A82" />
              <stop offset="50%" stopColor="#1E6570" />
              <stop offset="100%" stopColor="#144C57" />
            </linearGradient>
          </defs>

          {/* Squircle container */}
          <rect x="24" y="24" width="464" height="464" rx="112" ry="112" fill="url(#ilmiyaSquircleGrad)" />
          <rect x="24" y="24" width="464" height="464" rx="112" ry="112" fill="none" stroke="#FFFFFF" strokeOpacity="0.15" strokeWidth="4" />

          {/* Symbol */}
          <g transform="translate(0, -20)" fill="#FFFFFF">
            <polygon points="256,120 380,166 256,212 132,166" />
            <path d="M190 186 V216 C190 240 322 240 322 216 V186" />
            <path d="M336 178 C338 205 341 228 341 242 C335 248 340 258 344 258 C348 258 353 248 347 242 C347 228 344 205 342 178 Z" />

            <path d="M130 252 C130 248 134 244 138 244 C142 244 146 248 146 252 V336 C146 350 182 362 248 376 V392 C176 378 130 364 130 342 Z" />
            <path d="M382 252 C382 248 378 244 374 244 C370 244 366 248 366 252 V336 C366 350 330 362 264 376 V392 C336 378 382 364 382 342 Z" />

            <path d="M172 232 C178 228 238 228 250 248 V356 C232 342 182 340 178 342 C174 342 172 340 172 336 V236 C172 232 174 232 172 232 Z" />
            <path d="M340 232 C334 228 274 228 262 248 V356 C280 342 330 340 334 342 C338 342 340 340 340 336 V236 C340 232 338 232 340 232 Z" />

            <path d="M136 356 C190 382 240 398 256 406 C272 398 322 382 376 356 C382 354 386 358 384 364 C360 394 304 416 256 418 C208 416 152 394 128 364 C126 358 130 354 136 356 Z" />
          </g>

          <text x="256" y="420" fontFamily="'Lora', 'Newsreader', Georgia, serif" fontSize="66" fontWeight="600" fill="#FFFFFF" textAnchor="middle" letterSpacing="2">Ilmiya</text>
        </svg>
      </div>
    );
  }

  return (
    <div className={`inline-flex items-center gap-2.5 ${className}`}>
      <svg 
        viewBox="0 0 100 100" 
        style={{ width: size, height: size }}
        className="shrink-0 drop-shadow-xs" 
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Graduation Mortarboard */}
        <polygon points="50,14 78,25 50,36 22,25" />
        
        {/* Skull Cap Base */}
        <path d="M34 29.5 V38 C34 44 66 44 66 38 V29.5" />
        
        {/* Tassel */}
        <path d="M68 28.5 C68.5 35 69 40 69 44 C67.5 45.5 69 48 70 48 C71 48 72.5 45.5 71 44 C71 40 70.5 35 70 28.5 Z" />

        {/* Open Book Wings - Layer 1 */}
        <path d="M19 46.5 C19 45.5 20 44.5 21 44.5 C22 44.5 23 45.5 23 46.5 V68 C23 72 32 75 48 79 L48 83.5 C30 79.5 19 76 19 70 Z" />
        <path d="M81 46.5 C81 45.5 80 44.5 79 44.5 C78 44.5 77 45.5 77 46.5 V68 C77 72 68 75 52 79 L52 83.5 C70 79.5 81 76 81 70 Z" />

        {/* Open Book Wings - Layer 2 */}
        <path d="M26 44.5 C26 43.5 27 42.5 28 42.5 C29 42.5 30 43.5 30 44.5 V66 C30 70 38 72.5 48 76 L48 80.5 C36 77 26 74 26 68 Z" />
        <path d="M74 44.5 C74 43.5 73 42.5 72 42.5 C71 42.5 70 43.5 70 44.5 V66 C70 70 62 72.5 52 76 L52 80.5 C64 77 74 74 74 68 Z" />

        {/* Main Pages */}
        <path d="M33 41 C34 40 45 40 48 44.5 V73 C44 69.5 34 69 33 69.5 C32 69.5 31.5 69 31.5 68 V42 C31.5 41 32 41 33 41 Z" />
        <path d="M67 41 C66 40 55 40 52 44.5 V73 C56 69.5 66 69 67 69.5 C68 69.5 68.5 69 68.5 68 V42 C68.5 41 68 41 67 41 Z" />

        {/* Bottom Spine Ribbon Arc */}
        <path d="M20 73.5 C34 80 46 84 50 86 C54 84 66 80 80 73.5 C81.5 73 82.5 74 82 75.5 C76 83 62 88.5 50 89 C38 88.5 24 83 18 75.5 C17.5 74 18.5 73 20 73.5 Z" />
      </svg>

      {showText && (
        <span className="font-serif font-bold text-xl tracking-tight text-[#2C2E2A]">
          ILMIYA
        </span>
      )}
    </div>
  );
};
