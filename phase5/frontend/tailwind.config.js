/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ['Playfair Display', 'Georgia', 'serif'],
        body: ['DM Sans', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        sand: {
          50: '#fdf8f0',
          100: '#f9edd8',
          200: '#f2d9b0',
          300: '#e8c07e',
          400: '#dca04e',
          500: '#d08530',
          600: '#b86b24',
          700: '#985220',
          800: '#7c4220',
          900: '#66371d',
        },
        forest: {
          50: '#f0f7f0',
          100: '#dceedd',
          200: '#bcdcbe',
          300: '#8fc393',
          400: '#60a567',
          500: '#3d8845',
          600: '#2d6d34',
          700: '#255729',
          800: '#1f4523',
          900: '#1a391e',
        },
        stone: {
          850: '#1c1917',
        }
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out forwards',
        'slide-up': 'slideUp 0.4s ease-out forwards',
        'slide-in-left': 'slideInLeft 0.4s ease-out forwards',
      },
      keyframes: {
        fadeIn: {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        slideUp: {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        slideInLeft: {
          from: { opacity: '0', transform: 'translateX(-20px)' },
          to: { opacity: '1', transform: 'translateX(0)' },
        },
      },
    },
  },
  plugins: [],
}
