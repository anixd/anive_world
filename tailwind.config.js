module.exports = {
    content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js'
    ],
    theme: {
        extend: {
            typography: ({ theme }) => ({
                DEFAULT: {
                    css: {
                        // -- Цвета по умолчанию --
                        '--tw-prose-body': theme('colors.gray[800]'),
                        '--tw-prose-headings': theme('colors.gray[900]'),
                        '--tw-prose-lead': theme('colors.gray[700]'),
                        '--tw-prose-links': theme('colors.blue[700]'),
                        '--tw-prose-bold': theme('colors.blue[500]'),

                        a: {
                            textDecoration: 'underline',
                            fontWeight: '500',
                            '&:hover': {
                                color: theme('colors.blue[800]'),
                            },
                        },
                        'pre code': {
                            backgroundColor: theme('colors.slate[100]'),
                            padding: '0.5rem',
                            borderRadius: '0.25rem',
                        },
                        code: {
                            color: theme('colors.red[800]'),
                            fontWeight: '900',
                            backgroundColor: theme('colors.purple[50]'),
                            padding: '0.2em 0.4em',
                            borderRadius: '0.25rem',
                            margin: '0 0.15rem',
                        },
                        // Плагин typography по умолчанию добавляет кавычки вокруг <code>.
                        // Этот блок убирает их, чтобы избежать двойных кавычек.
                        'code::before': {
                            content: '""',
                        },
                        'code::after': {
                            content: '""',
                        },
                    },
                },
            }),
        },
    },
    plugins: [
        require('@tailwindcss/typography'),
    ]
}
