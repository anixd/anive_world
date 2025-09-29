import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["toggleable"]

    // Этот метод будет вызван при загрузке контроллера
    connect() {
        // Находим наш select внутри области действия контроллера
        this.selectElement = this.scope.findElement("select[data-action*='change->toggle-visibility#toggle']")
        // И сразу вызываем toggle, чтобы установить правильное состояние при загрузке страницы
        this.toggle()
    }

    // Этот метод будет вызываться при каждом изменении select'а
    toggle() {
        // Получаем текущее значение из select'а
        const currentValue = this.selectElement.value
        // Проверяем, нужно ли показывать дополнительное поле
        const show = ['inherited', 'borrowed'].includes(currentValue)

        // Показываем или скрываем все элементы-цели
        this.toggleableTargets.forEach(target => {
            target.classList.toggle('hidden', !show)
        })
    }
}
