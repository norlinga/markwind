/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './public/index.html',
  ],
  theme: {
    extend: {
      typography: (theme) => ({
        DEFAULT: {
          css: {
            h1: {
              color: theme('colors.red.500'),
              fontWeight: theme('fontWeight.bold'),
            },
          },
        },
      }),
    },
  },
  plugins: [require('@tailwindcss/typography')],
}