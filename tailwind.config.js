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
                        // Стили для инлайн-кода (`word`)
                        code: {
                            color: theme('colors.red[800]'),         // Цвет текста
                            fontWeight: '600',                          // Насыщенность шрифта (полужирный)
                            backgroundColor: theme('colors.purple[50]'),// Цвет фона
                            padding: '0.2em 0.4em',                     // Внутренние отступы
                            borderRadius: '0.25rem',                    // Скругление углов
                            margin: '0 0.15rem',                        // Небольшой внешний отступ
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
