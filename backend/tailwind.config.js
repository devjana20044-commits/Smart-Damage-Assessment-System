/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./resources/**/*.blade.php",
        "./resources/**/*.js",
        "./resources/**/*.vue",
    ],
    theme: {
        extend: {
            fontFamily: {
                cairo: ['Cairo', 'sans-serif'],
            },
            colors: {
                sand: '#C9A97C',
                charcoal: '#2D3A50',
                sage: '#78A9C1',
                beige: '#E8E6E1',
                light: '#FAFAFA',
                ivory: '#FAFAFA',
                terracotta: '#9C5D4D',
                'muted-amber': '#D6B570',
                'sage-green': '#91A68A',
            },
        },
    },
    plugins: [],
}
